extends StaticBody3D

@export var MESH: MeshInstance3D

var last_targeted: float = -1000

func targeted() -> void:
	last_targeted = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var time: float = clamp(Time.get_unix_time_from_system() - last_targeted, 0, 1) * 0.1

	var target_value: float = 1 if time < 0.05 else 0
	var original_value: float = 1 - target_value
	var current_value: float = original_value + (target_value - original_value) * time

	if Time.get_unix_time_from_system() - last_targeted < self.get_physics_process_delta_time():
		current_value = 1
	else:
		current_value = 0

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color.ORANGE.lerp(Color.BLUE, current_value)
	material.shading_mode = BaseMaterial3D.ShadingMode.SHADING_MODE_UNSHADED

	var mesh: PrimitiveMesh = MESH.mesh;
	mesh.material = material
