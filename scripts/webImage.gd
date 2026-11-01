extends TextureRect
class_name WebImage

signal load_started
signal load_finished

## Time needed to load the image in seconds.
@export var load_duration: float = 2.0
## Minor Random Variance from original duration in seconds
@export var duration_variance: float = 0.0

## How many chunks to break the reveal into
@export var stagger_steps: int = 60

## Chance (0.0-1.0) of a pause after each chunk finishes.
@export_range(0.0, 1.0) var stall_chance: float = 0.15

# Random pause length range, in seconds, when a stall triggers.
@export var stall_min: float = 0.05
@export var stall_max: float = 0.4

@export var line_count: int = 60
## Enable flicker scan line effect
@export var show_scan_edge: bool = true

## Alternative text if image 'fails' to load
@export var altText: String = "Alt Text"

var _shader_material: ShaderMaterial
var _tween: Tween
var _is_loading: bool = false
var _load_generation: int = 0

func _ready() -> void:
	_shader_material = material as ShaderMaterial
	_shader_material.set_shader_parameter("progress", 0.0)
	_shader_material.set_shader_parameter("line_count", line_count)
	_shader_material.set_shader_parameter("show_scan_edge", show_scan_edge)
	
	# Cap Line Count
	var safe_line_count := line_count
	if texture:
		safe_line_count = min(line_count, max(1, int(texture.get_size().y)))
	_shader_material.set_shader_parameter("line_count", safe_line_count)

	# Remove after testing:
	#start_load()

func start_load(duration_override: float = -1.0) -> void:
	if _is_loading:
		return

	_is_loading = true
	load_started.emit()
	_load_generation += 1
	var my_generation := _load_generation

	var duration := duration_override if duration_override > 0.0 else _rolled_duration()
	var step_duration := duration / float(stagger_steps)

	_shader_material.set_shader_parameter("progress", 0.0)

	for step in range(1, stagger_steps + 1):
		var target_progress := float(step) / float(stagger_steps)

		_tween = create_tween()
		_tween.tween_method(
			func(p): _shader_material.set_shader_parameter("progress", p),
			float(step - 1) / float(stagger_steps), target_progress, step_duration
		)
		await _tween.finished

		# If skip_load() or a new start_load() took over while we were midchunk.
		if my_generation != _load_generation:
			return

		if step < stagger_steps and randf() < stall_chance:
			await get_tree().create_timer(randf_range(stall_min, stall_max)).timeout
			if my_generation != _load_generation:
				return

	_is_loading = false
	load_finished.emit()

func skip_load() -> void:
	_load_generation += 1
	if _tween:
		_tween.kill()
	_is_loading = false
	_shader_material.set_shader_parameter("progress", 1.0)
	load_finished.emit()

func is_loading() -> bool:
	return _is_loading

func _rolled_duration() -> float:
	if duration_variance <= 0.0:
		return load_duration
	return load_duration + randf_range(-duration_variance, duration_variance)
