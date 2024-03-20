extends CharacterBody3D

@export var JUMP_DIST: float
@export var JUMP_HEIGHT: float
@export var JUMP_TIME: float

func _physics_process(delta: float) -> void:
	var MOVE_SPEED: float = JUMP_DIST / JUMP_TIME
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
	var direction: Vector3 = self.transform.basis * Vector3(input.x, 0, input.y) * MOVE_SPEED
	velocity = velocity.lerp(direction, 0.5)

	velocity.y = vertical
	move_and_slide()
