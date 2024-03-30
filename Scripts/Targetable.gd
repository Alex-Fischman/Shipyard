extends StaticBody3D

@export var MESH: MeshInstance3D

var last_targeted: float = -1000

var off_material: StandardMaterial3D
var on_material: StandardMaterial3D

func _ready() -> void:
	var mesh: PrimitiveMesh = MESH.mesh
	var material: StandardMaterial3D = mesh.material
	off_material = material

	on_material = material.duplicate()
	on_material.albedo_color = Color.CYAN

func targeted() -> void:
	last_targeted = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	var elapsed: float = Time.get_unix_time_from_system() - last_targeted
	var threshold: float = self.get_physics_process_delta_time() * 2.0
	MESH.material_override = on_material if elapsed < threshold else off_material
