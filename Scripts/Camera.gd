extends Camera3D

@export var target: Node3D
@export var sensitivity: float

func _process(delta: float) -> void:
	self.global_transform = target.global_transform
