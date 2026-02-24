extends CharacterBody3D


var speed = 5.0
const WALK_SPEED = 5
const RUN_SPEED = 10
const JUMP_VELOCITY = 4.5


@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D
var SENSITIVITY = 0.005

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

const BASE_FOV = 75.0
const FOV_Change = 1
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x= clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if event.is_action_pressed("interact"):
		
		try_pickup_item()

func try_pickup_item():
	
	if raycast.is_colliding():
		
		var collider = raycast.get_collider()
		# Check if the collider is an item (has pickup function)
		
		if collider.has_method("pickup"):
			
			collider.pickup()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	##spriting
	
	if Input.is_action_pressed("sprint"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			##Supposed to slowly deselerate but IDK. For now just go to 0
			velocity.x = lerp(velocity.x,direction.x * speed, delta *7	)
			velocity.z = lerp(velocity.z,direction.z * speed, delta *7)
			#velocity.x = move_toward(velocity.x, 0, SPEED)
			#velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = lerp(velocity.x,direction.x * speed, delta *3)
		velocity.z = lerp(velocity.z,direction.z * speed, delta *3)
	##Head bob y add
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	##IM FOV velocityClaped is the var that changes as you move Currently it adds walk speed and any above walk speed x3 to the FOV
	var velocity_clamped :float = clamp(velocity.length(), WALK_SPEED, RUN_SPEED * 2) *3
	var target_fov : float = BASE_FOV * FOV_Change + velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos =Vector3.ZERO
	pos.y = sin(time *BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos
