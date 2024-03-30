extends CharacterBody3D

@export var JUMP_DIST: float
@export var JUMP_HEIGHT: float
@export var JUMP_TIME: float
@export var MOVE_ACCEL: float
@export var AIR_MOVE_ACCEL: float

@export var ROPE_CAST: ShapeCast3D
var ROPE_WITH_ENDPOINTS: PackedScene = preload("res://Scenes/RopeWithEndpoints.tscn")

var mouse_down: bool = false
var current_target: Node3D = null
var grapple_rope: Node3D = null
var grapple_point: Vector3
var rope_slip_velocity: float
var rope_length: float

func _physics_process(delta: float) -> void:
	var MOVE_SPEED: float = JUMP_DIST / JUMP_TIME
	var MOVE_FRICTION: float = MOVE_ACCEL / MOVE_SPEED
	var AIR_MOVE_FRICTION: float = MOVE_SPEED / AIR_MOVE_ACCEL
	var GRAVITY_FORCE: float = 8 * JUMP_HEIGHT / JUMP_TIME / JUMP_TIME
	var JUMP_IMPULSE: float = 4 * JUMP_HEIGHT / JUMP_TIME

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
	var move_accel: float = MOVE_ACCEL if self.is_on_floor() else AIR_MOVE_ACCEL
	var move_friction: float = MOVE_FRICTION if self.is_on_floor() else AIR_MOVE_FRICTION
	var direction: Vector3 = self.transform.basis * Vector3(input.x, 0, input.y) * move_accel
	velocity += (direction - velocity * move_friction) * delta

	velocity.y = vertical
	move_and_slide()

	if mouse_down:
		if current_target == null:
			if ROPE_CAST.is_colliding():
				current_target = ROPE_CAST.get_collider(0)
				current_target = current_target.get_parent()
				grapple_rope = ROPE_WITH_ENDPOINTS.instantiate()
				self.get_tree().get_root().add_child(grapple_rope)
				grapple_point = ROPE_CAST.get_collision_point(0)
				rope_slip_velocity = 0
				rope_length = self.global_position.distance_to(grapple_point)

		if current_target != null:
			grapple_point = compute_grapple_point(delta)

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

func compute_grapple_point(delta: float) -> Vector3:
	var a: Vector3 = current_target.get("a").global_position
	var b: Vector3 = current_target.get("b").global_position
	var c: Vector3 = self.global_position
	var ab: Vector3 = b - a
	var ac: Vector3 = c - a
	var x: float = clamp(ab.dot(ac) / ab.dot(ab), 0, 1)
	var y: float = a.distance_to(grapple_point) / a.distance_to(b)

	y += delta * rope_slip_velocity
	rope_slip_velocity += delta * (x - y - rope_slip_velocity / (2 * PI)) * (4 * PI * PI)

	if y < 0:
		y = 0
		rope_slip_velocity = 0
	if y > 1:
		y = 1
		rope_slip_velocity = 0

	return a + ab * y

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			mouse_down = e.pressed
