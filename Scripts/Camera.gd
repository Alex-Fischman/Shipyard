extends Camera3D

@export var target: Node3D
@export var player: Node3D
@export var sensitivity: float

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	self.global_transform = target.global_transform

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var e: InputEventMouseMotion = event as InputEventMouseMotion
		player.rotate_y(-e.relative.x * sensitivity)
		target.rotate_x(-e.relative.y * sensitivity)
		target.rotation.x = clamp(target.rotation.x, -PI / 2, PI / 2)
