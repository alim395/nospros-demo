extends Control

const FREQ_MAX = 5000.0
const SCAN_COUNT = 96

const WIDTH = 160
const HEIGHT = 90
const MIN_HZ = 80.0

const MIN_DB = 60
const PEAK_ENERGY_THRESHOLD = 0.55
const NOTE_COOLDOWN = 0.15

const FIREFLY_MAX = 80
const FIREFLY_LIFETIME = 2.5
const FIREFLY_SIZE = 3.0          # square side length now, not a radius
const FIREFLY_COLOR = Color(1, 1, 0)
const FIREFLY_DRIFT_SPEED = 6.0
const FIREFLY_PULSE_SPEED = 3.0
const ALPHA_STEPS = 3             # quantizes fade/pulse into hard steps instead of a smooth blend

const SPARK_COUNT_MIN = 2
const SPARK_COUNT_MAX = 4
const SPARK_LIFETIME = 0.35
const SPARK_SPEED_MIN = 40.0
const SPARK_SPEED_MAX = 90.0
const SPARK_SIZE = 1.5
const SPARK_COLOR = Color(1.0, 1.0, 0.75)

var spectrum
var _bin_cooldowns : PackedFloat32Array
var _fireflies : Array = []
var _sparks : Array = []
var _time : float = 0.0


func _ready() -> void:
	spectrum = AudioServer.get_bus_effect_instance(1, 1)
	_bin_cooldowns.resize(SCAN_COUNT)
	_bin_cooldowns.fill(0.0)


func hz_to_y(hz: float) -> float:
	var octaves : float = log(hz / MIN_HZ) / log(2.0)
	var max_octaves : float = log(FREQ_MAX / MIN_HZ) / log(2.0)
	var t : float = clampf(octaves / max_octaves, 0.0, 1.0)
	return HEIGHT - t * HEIGHT


func _quantize(value: float, steps: int) -> float:
	return floor(value * steps) / float(steps)


func _process(delta: float) -> void:
	_time += delta
	var step_hz : float = FREQ_MAX / SCAN_COUNT

	var magnitudes : Array = []
	for i in range(SCAN_COUNT):
		var lo : float = i * step_hz
		var hi : float = (i + 1) * step_hz
		magnitudes.append(spectrum.get_magnitude_for_frequency_range(lo, hi).length())

	for i in range(SCAN_COUNT):
		_bin_cooldowns[i] -= delta

	for i in range(1, SCAN_COUNT - 1):
		var m : float = magnitudes[i]
		var energy : float = clampf((MIN_DB + linear_to_db(m)) / MIN_DB, 0.0, 1.0)
		var is_local_peak : bool = m > magnitudes[i - 1] and m > magnitudes[i + 1]

		if is_local_peak and energy > PEAK_ENERGY_THRESHOLD and _bin_cooldowns[i] <= 0.0 and _fireflies.size() < FIREFLY_MAX:
			_bin_cooldowns[i] = NOTE_COOLDOWN
			_spawn_firefly(i, step_hz, energy)

	var alive_fireflies : Array = []
	for f in _fireflies:
		f["age"] += delta
		f["pos"].x += sin(_time * 1.3 + f["seed"]) * FIREFLY_DRIFT_SPEED * delta
		f["pos"].y += cos(_time * 0.9 + f["seed"] * 1.7) * FIREFLY_DRIFT_SPEED * 0.5 * delta
		if f["age"] < f["lifetime"]:
			alive_fireflies.append(f)
	_fireflies = alive_fireflies

	var alive_sparks : Array = []
	for s in _sparks:
		s["age"] += delta
		s["pos"] += s["vel"] * delta
		if s["age"] < s["lifetime"]:
			alive_sparks.append(s)
	_sparks = alive_sparks

	queue_redraw()


func _spawn_firefly(bin_index: int, step_hz: float, energy: float) -> void:
	var hz : float = (bin_index + 0.5) * step_hz
	var y : float = hz_to_y(hz)
	var x : float = randf_range(0.0, WIDTH)
	var pos := Vector2(x, y)

	_fireflies.append({
		"pos": pos,
		"age": 0.0,
		"lifetime": FIREFLY_LIFETIME * randf_range(0.7, 1.3),
		"brightness": energy,
		"seed": randf_range(0.0, TAU),
	})

	# A quick burst of sparks is the "flare" - these are short-lived and
	# separate from the firefly itself, same spawn-and-fade pattern as
	# the particle jets in the radial visualizer, just much shorter-lived.
	var spark_count : int = randi_range(SPARK_COUNT_MIN, SPARK_COUNT_MAX)
	for i in range(spark_count):
		var angle : float = randf_range(0.0, TAU)
		var speed : float = randf_range(SPARK_SPEED_MIN, SPARK_SPEED_MAX)
		_sparks.append({
			"pos": pos,
			"vel": Vector2(cos(angle), sin(angle)) * speed,
			"age": 0.0,
			"lifetime": SPARK_LIFETIME * randf_range(0.6, 1.0),
		})


func _draw() -> void:
	# Sparks drawn first so fireflies sit visually "on top"
	for s in _sparks:
		var t : float = s["age"] / s["lifetime"]
		var alpha : float = _quantize(1.0 - t, ALPHA_STEPS)
		if alpha <= 0.0:
			continue
		var color : Color = SPARK_COLOR
		color.a = alpha
		var p : Vector2 = s["pos"].round()  # pixel-snap - keeps it crisp at this resolution
		draw_rect(Rect2(p.x - SPARK_SIZE * 0.5, p.y - SPARK_SIZE * 0.5, SPARK_SIZE, SPARK_SIZE), color)

	for f in _fireflies:
		var t : float = f["age"] / f["lifetime"]
		var fade : float = 1.0 - t
		var pulse : float = 0.5 + 0.5 * sin(_time * FIREFLY_PULSE_SPEED + f["seed"])
		var alpha : float = _quantize(fade * (0.4 + 0.6 * pulse) * f["brightness"], ALPHA_STEPS)
		if alpha <= 0.0:
			continue

		var color : Color = FIREFLY_COLOR
		color.a = alpha
		var p : Vector2 = f["pos"].round()

		# faint square halo, one step dimmer, instead of a soft circular glow
		var halo : Color = color
		halo.a = alpha * 0.3
		draw_rect(Rect2(p.x - FIREFLY_SIZE, p.y - FIREFLY_SIZE, FIREFLY_SIZE * 2.0, FIREFLY_SIZE * 2.0), halo)
		draw_rect(Rect2(p.x - FIREFLY_SIZE * 0.5, p.y - FIREFLY_SIZE * 0.5, FIREFLY_SIZE, FIREFLY_SIZE), color)
