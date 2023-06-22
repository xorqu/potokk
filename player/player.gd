extends CharacterBody3D
class_name Player

@export_category("Player")

@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 4.0, 0.1) var jump_height: float = 2.5 # m
@export_range(0.1, 9.25, 0.05, "or_greater") var camera_sens: float = 160

#var hp = 100
#var max_hp = 150

var speed: float = 7.0 # m/s
var speed_default: float = 7.0
var speed_shift: float = 20.0

@export var state : Player_state


var jumping: bool = false
var mouse_captured: bool = false

#var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity: float = 40.0
#
var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var camera: Camera3D = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var walk_sound = $Walk_sound

func _ready() -> void:
	capture_mouse()
	walk_sound.set_stream_paused(true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	if Input.is_action_just_pressed("space"): jumping = true
	if Input.is_action_just_pressed("ui_cancel"): get_tree().quit()
	if Input.is_action_just_pressed("shift"): speed = speed_shift
	if Input.is_action_just_released("shift"): speed = speed_default
	

func _physics_process(delta: float) -> void:
	if mouse_captured: _rotate_camera(delta)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()
	walk_sound_play()
	if position.y < -60:
		death()


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(delta: float, sens_mod: float = 1.0) -> void:
	#look_dir += Input.get_vector("look_left","look_right","look_up","look_down")
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO
	pass
	
func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("a", "d", "w", "s")
	var _forward: Vector3 = camera.transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func walk_sound_play():
	if 	walk_sound.get_stream_paused():
		if (Input.is_action_pressed('w') or Input.is_action_pressed('a') or Input.is_action_pressed('s') or Input.is_action_pressed('d')) and is_on_floor():
			walk_sound.set_stream_paused(false)		
	if !is_on_floor() or (!walk_sound.get_stream_paused() and (Input.is_action_just_released('w') or Input.is_action_just_released('a') or Input.is_action_just_released('s') or Input.is_action_just_released('d'))):
		walk_sound.set_stream_paused(true)

func take_damage(dmg):
	state.hp = state.hp - dmg
	if state.hp <= 0:
		death()
		
func heal(heal_hp):
	state.hp += heal_hp
	state.hp = clamp(state.hp, 0, state.max_hp)
	
func death():
	print("death")
	get_tree().reload_current_scene()

