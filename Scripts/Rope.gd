@tool

extends StaticBody3D

@export var a: Node3D
@export var b: Node3D

func _ready() -> void:
	var x: Vector3 = a.global_position
	var y: Vector3 = b.global_position

	self.global_position = x
	self.transform = self.transform.looking_at(y)
	self.scale.z = x.distance_to(y)

	update_configuration_warnings
