extends Control

const FREQ_MAX = 2750.0
const SAMPLE_COUNT = 32

const WIDTH = 136
const HEIGHT = 76

const MIN_DB = 60
const ANIMATION_SPEED = 0.6

# Circle geometry
const BASE_RADIUS = 18.0
const WAVE_SCALE = 12.0

# Main ring color
const COLOR_DIM = Color(0.75, 0.0, 0.0)
const COLOR_BRIGHT = Color(1.0, 0.0, 0.0)

# Noise ring settings
const NOISE_COLOR = Color(0.9, 0.15, 0.0, 0.35)
const NOISE_RADIUS_MAX = 4.5
const NOISE_ANGLE_MAX = 0.09
const NOISE_SPEED = 11.0

# Particle jet settings 
const JET_THRESHOLD = 0.7 # normalised energy a band must exceed to spawn particles
const JET_RATE = 0.25 # seconds between spawns per active band
const JET_SPEED_MIN = 18.0 # px/sec minimum outward velocity
const JET_SPEED_MAX = 48.0 # px/sec maximum outward velocity
const JET_LIFETIME = 0.9 # seconds before a particle fully fades
const JET_MAX = 120 # Max number of Particles Visible
const JET_RADIUS_DOT = 0.6 # dot draw radius in px
const COLOR_SPAWN = Color(1.0, 0.45, 0.0)
const COLOR_DEAD = Color(0.4, 0.0, 0.0)

# State
var spectrum
var _smoothed : PackedFloat32Array
var _time : float = 0.0
# Per-band spawn cooldown timers
var _jet_timers : PackedFloat32Array
# Particle pool: each entry { pos, vel, age, lifetime }
var _particles : Array = []

# Secret 3
@export var showSecret : bool   = false
@export_multiline var secretMessage : String = "" # Should not exceed 32 x 9 Chars
@export var secretFont : FontFile
@export var secretFontSize : int = 8
@export var s3Label : Label

func setSecret(message: String, vis: bool) -> void:
	secretMessage = message
	showSecret = vis
	s3Label.text = secretMessage
	s3Label.visible = vis

func clearSecret() -> void:
	setSecret("", false)

func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(1, 1)
	_smoothed.resize(SAMPLE_COUNT)
	_smoothed.fill(0.0)
	_jet_timers.resize(SAMPLE_COUNT)
	_jet_timers.fill(0.0)
	
	if secretFont:
		s3Label.add_theme_font_override("font", secretFont)
	s3Label.add_theme_font_size_override("font_size", secretFontSize)
	if secretMessage != "":
		s3Label.text = secretMessage
	if showSecret:
		s3Label.visible = showSecret


func _process(delta: float) -> void:
	_time += delta * NOISE_SPEED

	# Sample spectrum
	var step_hz : float = FREQ_MAX / SAMPLE_COUNT
	var prev_hz : float = 0.0
	for i in range(SAMPLE_COUNT):
		var hz : float = (i + 1) * step_hz
		var magnitude : float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy : float = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0.0, 1.0)
		_smoothed[i]  = lerpf(_smoothed[i], energy, ANIMATION_SPEED)
		prev_hz = hz

	# Normalise
	var peak_energy : float = 0.001
	for i in range(SAMPLE_COUNT):
		if _smoothed[i] > peak_energy:
			peak_energy = _smoothed[i]

	# Spawn particles from active jets
	var center := Vector2(WIDTH * 0.5, HEIGHT * 0.5)
	for i in range(SAMPLE_COUNT):
		var norm_energy : float = _smoothed[i] / peak_energy
		_jet_timers[i] -= delta

		if norm_energy >= JET_THRESHOLD and _jet_timers[i] <= 0.0 and _particles.size() < JET_MAX:
			_jet_timers[i] = JET_RATE

			# Spawn position is the band's current point on the ring surface
			var angle  : float = (float(i) / float(SAMPLE_COUNT)) * TAU
			var radius : float = BASE_RADIUS + norm_energy * WAVE_SCALE
			var pos    := center + Vector2(cos(angle), sin(angle)) * radius

			# Velocity is purely radial, scaled by band energy
			var speed  : float = lerpf(JET_SPEED_MIN, JET_SPEED_MAX, norm_energy)
			var vel    := Vector2(cos(angle), sin(angle)) * speed

			_particles.append({"pos": pos, "vel": vel, "age": 0.0, "lifetime": JET_LIFETIME })

	# Advance and cull particles
	var alive : Array = []
	for p in _particles:
		p["age"] += delta
		p["pos"] += p["vel"] * delta
		if p["age"] < p["lifetime"]:
			alive.append(p)
	_particles = alive

	queue_redraw()


func _noise(x: float, y: float) -> float:
	return sin(x * 1.7 + _time) * cos(y * 2.3 - _time * 0.8)


func _draw() -> void:
	var center := Vector2(WIDTH * 0.5, HEIGHT * 0.5)

	# Energy metrics
	var avg_energy : float = 0.0
	var peak_energy : float = 0.0001
	for i in range(SAMPLE_COUNT):
		avg_energy += _smoothed[i]
		if _smoothed[i] > peak_energy:
			peak_energy = _smoothed[i]
	avg_energy /= SAMPLE_COUNT
	var energy_scale : float = pow(avg_energy, 0.2)

	if showSecret and secretMessage != "":
		var secret_color := Color(1.0, 0.0, 0.0)
		# Dim ceiling kept low — never reads as intentional at a glance
		secret_color.a   = clampf(avg_energy, 0.02, 0.75)
		#var font : Font = secretFont
		#var fontSize : int = 8
		s3Label.add_theme_color_override("font_color", secret_color)
		##var textWidth  : float = font.get_string_size(secretMessage, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize).x
		##var textHeight : float = font.get_height(fontSize)
		##var textDimensions : Vector2 = font.get_multiline_string_size(secretMessage, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize)
		#var textWidth  : float = font.get_multiline_string_size(secretMessage, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize).x
		##var textHeight : float = font.get_height(fontSize) * secretMessage.split("\n").size()
		##var textHeight : float = font.get_multiline_string_size(secretMessage, HORIZONTAL_ALIGNMENT_LEFT, -1, fontSize).y
		#var textHeight : float = font.get_ascent(fontSize)
#
		##draw_string(
			##font,
			##Vector2(
				##(WIDTH * 0.5)  - (textWidth  * 0.5),
				##(HEIGHT * 0.5) + (textHeight * 0.5)
			##),
			##secretMessage,
			##HORIZONTAL_ALIGNMENT_LEFT,
			##-1,
			##fontSize,
			##secret_color
		##)
		#
		#draw_multiline_string(
			#font,
			#Vector2(
				#(WIDTH * 0.5)  - (textWidth  * 0.5),
				#(HEIGHT * 0.5) + (textHeight * 0.5)
			#),
			#secretMessage,
			#HORIZONTAL_ALIGNMENT_LEFT,
			#textWidth,
			#fontSize,
			#-1,
			#secret_color
		#)

	# Particles (furthest back)
	for p in _particles:
		var t : float = p["age"] / p["lifetime"]
		var color : Color = COLOR_SPAWN.lerp(COLOR_DEAD, t)
		color.a = 1.0 - t
		var psize : float = JET_RADIUS_DOT * 2.0
		draw_rect(Rect2(p["pos"].x - JET_RADIUS_DOT, p["pos"].y - JET_RADIUS_DOT, psize, psize), color)

	# Noise ring
	var noise_pts : PackedVector2Array
	noise_pts.resize(SAMPLE_COUNT + 1)

	for i in range(SAMPLE_COUNT):
		var energy : float = _smoothed[i] / peak_energy
		var base_radius : float = BASE_RADIUS + energy * WAVE_SCALE
		var base_angle : float = (float(i) / float(SAMPLE_COUNT)) * TAU

		var r_jitter : float = _noise(float(i) * 0.5, 0.0) * NOISE_RADIUS_MAX * energy_scale
		var a_jitter : float = _noise(0.0, float(i) * 0.5) * NOISE_ANGLE_MAX  * energy_scale

		var energy_boost : float = 1.0 + energy * 1.4
		var radius : float = base_radius + r_jitter * energy_boost
		var angle : float = base_angle  + a_jitter
		noise_pts[i] = center + Vector2(cos(angle), sin(angle)) * radius

	noise_pts[SAMPLE_COUNT] = noise_pts[0]

	var noise_color := NOISE_COLOR
	noise_color.a = NOISE_COLOR.a * energy_scale

	for i in range(SAMPLE_COUNT):
		draw_line(noise_pts[i], noise_pts[i + 1], noise_color, 0.75, true)

	# Main ring
	var main_pts : PackedVector2Array
	var colors : PackedColorArray
	main_pts.resize(SAMPLE_COUNT + 1)
	colors.resize(SAMPLE_COUNT + 1)

	for i in range(SAMPLE_COUNT):
		var energy : float = _smoothed[i] / peak_energy
		var radius : float = BASE_RADIUS + energy * WAVE_SCALE
		var angle : float = (float(i) / float(SAMPLE_COUNT)) * TAU
		main_pts[i] = center + Vector2(cos(angle), sin(angle)) * radius
		colors[i] = COLOR_DIM.lerp(COLOR_BRIGHT, energy)

	main_pts[SAMPLE_COUNT] = main_pts[0]
	colors[SAMPLE_COUNT] = colors[0]

	for i in range(SAMPLE_COUNT):
		draw_line(main_pts[i], main_pts[i + 1], colors[i], 0.3, true)
