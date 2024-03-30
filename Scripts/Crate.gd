@tool

extends StaticBody3D

@export var colors: Array[Color]

func _enter_tree() -> void:
	var mesh_instance: MeshInstance3D = self.get_node("MeshInstance3D")
	var material: StandardMaterial3D = mesh_instance.get_surface_override_material(0).duplicate()
	material.albedo_color = colors[randi_range(0, len(colors) - 1)]
	mesh_instance.set_surface_override_material(0, material)
