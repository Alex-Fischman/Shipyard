extends CharacterBody3D

@export var JUMP_DIST: float
@export var JUMP_HEIGHT: float
@export var JUMP_TIME: float
@export var MOVE_ACCEL: float

@export var ROPE_CAST: ShapeCast3D

var current_target: Node = null
var mouse_down: bool = false

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

		if current_target != null:
			current_target.get_node("StaticBody3D").call("targeted")
	else:
		current_target = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT:
			mouse_down = e.pressed
