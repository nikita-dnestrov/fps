extends CharacterBody3D

@onready var head = $Head
@onready var container = $Head/Container

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var walking_speed := 5.0
@export var sprinting_speed := 8.0
@export var crouching_speed := 3.0

var current_speed = 5.0
var jump_strength = 6.5
var lerp_speed = 10.0

var movement_velocity: Vector3

var direction := Vector3.ZERO

var is_able_to_jump := true
var is_crouched := false

var crouch_head_position := 0.0

var mouse_sensitivity = 0.1

var mouse_captured = false

var rotation_target: Vector3
var input_mouse: Vector2

func _physics_process(delta):
	if is_on_floor():
		is_able_to_jump = true
	
	if not is_on_floor():
		velocity.y -= gravity * 2.4 * delta
	
	handle_controls(delta)
	move_and_slide()

func _input(event):
	handle_mouse_controls(event)

func handle_controls(delta):
	handle_movement(delta)
	handle_jump()
	handle_sprint()
	handle_crouch(delta)
	if Input.is_action_just_pressed("capture_mouse"):
		mouse_captured = !mouse_captured
		if mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else: 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func handle_jump():
	if Input.is_action_just_pressed("jump"): 
		if is_able_to_jump:
			velocity.y = jump_strength
			is_able_to_jump = false

func handle_movement(delta):
	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_back")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

func handle_mouse_controls(event):
	if event is InputEventMouseMotion and mouse_captured:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func handle_sprint():
	if(!is_crouched):
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
		if Input.is_action_just_released("sprint"):
			current_speed = walking_speed
		
func handle_crouch(delta):
	if Input.is_action_just_pressed("crouch"):
		is_crouched = !is_crouched
		if is_crouched:
			head.position.y = crouch_head_position
		else:
			head.position.y = 0.9
		
