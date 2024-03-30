extends CharacterBody3D

@export var JUMP_DIST: float
@export var JUMP_HEIGHT: float
@export var JUMP_TIME: float
@export var MOVE_ACCEL: float

@export var ROPE_CAST: ShapeCast3D
var ROPE_WITH_ENDPOINTS: PackedScene = preload("res://Scenes/RopeWithEndpoints.tscn")

var mouse_down: bool = false
var current_target: Node3D = null
var grapple_rope: Node3D = null
var grapple_point: Vector3

func _physics_process(delta: float) -> void:
	var MOVE_SPEED: float = JUMP_DIST / JUMP_TIME
	var GRAVITY_FORCE: float = 8 * JUMP_HEIGHT / JUMP_TIME / JUMP_TIME
	var JUMP_IMPULSE: float = 4 * JUMP_HEIGHT / JUMP_TIME
	var MOVE_FRICTION: float = MOVE_ACCEL / MOVE_SPEED

	var vertical: float = velocity.y
	velocity.y = 0

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vertical = JUMP_IMPULSE
		else:
			vertical = 0
	else:
		vertical -= GRAVITY_FORCE * delta

	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = self.transform.basis * Vector3(input.x, 0, input.y) * MOVE_ACCEL
	velocity += (direction - velocity * MOVE_FRICTION) * delta

	velocity.y = vertical
	move_and_slide()

	if mouse_down:
		if current_target == null:
			if ROPE_CAST.is_colliding():
				current_target = ROPE_CAST.get_collider(0)
				current_target = current_target.get_parent()
				grapple_rope = ROPE_WITH_ENDPOINTS.instantiate()
				grapple_point = ROPE_CAST.get_collision_point(0)
				self.get_tree().get_root().add_child(grapple_rope)

		if current_target != null:
			current_target.get_node("StaticBody3D").call("targeted")
			var a: Node3D = grapple_rope.get_node("A")
			a.global_position = self.global_position
			var b: Node3D = grapple_rope.get_node("B")
			b.global_position = grapple_point
	else:
		if current_target != null:
			grapple_rope.queue_free()
			current_target = null
			grapple_rope = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			mouse_down = e.pressed
