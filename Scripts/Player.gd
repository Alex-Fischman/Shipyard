extends CharacterBody3D

@export var JUMP_DIST: float
@export var JUMP_HEIGHT: float
@export var JUMP_TIME: float
@export var MOVE_ACCEL: float
@export var AIR_MOVE_ACCEL: float

@export var ROPE_CAST: ShapeCast3D
var ROPE_WITH_ENDPOINTS: PackedScene = preload("res://Scenes/RopeWithEndpoints.tscn")

var mouse_down: bool = false
var jump_pressed: bool = false

var current_target: Node3D = null
var grapple_rope: Node3D = null
var grapple_point: Vector3
var rope_length: float

func _physics_process(delta: float) -> void:
	if not Input.is_action_pressed("jump"):
		jump_pressed = false
	if Input.is_action_just_pressed("jump"):
		jump_pressed = true

	var MOVE_SPEED: float = JUMP_DIST / JUMP_TIME
	var MOVE_FRICTION: float = MOVE_ACCEL / MOVE_SPEED
	var AIR_MOVE_FRICTION: float = MOVE_SPEED / AIR_MOVE_ACCEL
	var GRAVITY_FORCE: float = 8 * JUMP_HEIGHT / JUMP_TIME / JUMP_TIME
	var JUMP_IMPULSE: float = 4 * JUMP_HEIGHT / JUMP_TIME

	var vertical: float = velocity.y
	velocity.y = 0

	if self.is_on_floor():
		if jump_pressed:
			vertical = JUMP_IMPULSE
			jump_pressed = false
		else:
			vertical = 0
	else:
		vertical -= GRAVITY_FORCE * delta

	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_accel: float = MOVE_ACCEL if self.is_on_floor() else AIR_MOVE_ACCEL
	var move_friction: float = MOVE_FRICTION if self.is_on_floor() else AIR_MOVE_FRICTION
	var direction: Vector3 = self.transform.basis * Vector3(input.x, 0, input.y) * move_accel
	self.velocity += (direction - velocity * move_friction) * delta

	self.velocity.y = vertical

	if mouse_down:
		if current_target == null:
			if ROPE_CAST.is_colliding():
				current_target = ROPE_CAST.get_collider(0)
				current_target = current_target.get_parent()
				grapple_rope = ROPE_WITH_ENDPOINTS.instantiate()
				self.get_tree().get_root().add_child(grapple_rope)
				grapple_point = ROPE_CAST.get_collision_point(0)
				rope_length = abs(ROPE_CAST.target_position.z)

		if current_target != null:
			grapple_point = compute_grapple_point()

			var distance: float = self.global_position.distance_to(grapple_point)
			if distance > rope_length:
				var speed: float = self.velocity.length()
				self.velocity -= self.velocity.project(self.global_position - grapple_point)
				self.velocity = self.velocity.normalized() * speed
				self.global_position = self.global_position.move_toward(grapple_point, distance - rope_length)

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

	self.move_and_slide()

func compute_grapple_point() -> Vector3:
	var a: Vector3 = current_target.get("a").global_position
	var b: Vector3 = current_target.get("b").global_position
	var c: Vector3 = self.global_position
	var ab: Vector3 = b - a
	var ac: Vector3 = c - a
	var x: float = clamp(ab.dot(ac) / ab.dot(ab), 0, 1)
	return a + ab * x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			mouse_down = e.pressed
			if not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
