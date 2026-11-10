extends Vehicle
## Carro OnRacing: GEVP Vehicle + downforce + camera + input.

# ponytail: preset fixo; trocar por CarConfig Resource vinda do lobby quando existir selecao de modo.
var config: CarConfig = CarConfig.preset_ranked()

# Downforce: aplicado em _physics_process via config.downforce (N por m^2/s^2).

var cam: Camera3D
var cam_dir := Vector3.BACK

func _ready() -> void:
	front_left_wheel = $WheelFL
	front_right_wheel = $WheelFR
	rear_left_wheel = $WheelRL
	rear_right_wheel = $WheelRR
	$WheelFL.wheel_node = $WheelFL/Mesh
	$WheelFR.wheel_node = $WheelFR/Mesh
	$WheelRL.wheel_node = $WheelRL/Mesh
	$WheelRR.wheel_node = $WheelRR/Mesh
	front_tire_radius = 0.34
	rear_tire_radius = 0.34
	front_spring_length = 0.22
	rear_spring_length = 0.22
	clutch_out_rpm = 2000.0
	idle_rpm = 1500.0
	motor_drag = 0.01
	motor_moment = 4.0
	max_clutch_torque_ratio = 1.0
	shift_time = 0.1
	var controller := get_node_or_null("CarController")
	if controller:
		controller.vehicle_node = self
		controller.string_clutch_input = ""
		controller.string_toggle_transmission = ""
		controller.string_shift_up = ""
		controller.string_shift_down = ""
	config.apply_to(self)
	super._ready()
	cam = get_node_or_null("Camera3D")
	if cam:
		cam.top_level = true
		cam_dir = global_transform.basis.z

func _physics_process(delta: float) -> void:
	steering_input = Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	throttle_input = Input.get_action_strength("throttle")
	brake_input = Input.get_action_strength("brake")
	handbrake_input = Input.get_action_strength("handbrake")
	super._physics_process(delta)
	if linear_velocity.length() > 1.0:
		apply_central_force(-global_transform.basis.y * linear_velocity.length_squared() * config.downforce)
	_update_camera(delta)

func _update_camera(delta: float) -> void:
	if cam == null:
		return
	var flat_fwd := Vector3(global_transform.basis.z.x, 0, global_transform.basis.z.z)
	if flat_fwd.length_squared() < 0.01:
		flat_fwd = Vector3.BACK
	flat_fwd = flat_fwd.normalized()
	var vel_flat := Vector3(linear_velocity.x, 0, linear_velocity.z)
	var target_dir := flat_fwd
	if vel_flat.length() > 3.0 and linear_velocity.dot(global_transform.basis.z) > -1.0:
		target_dir = flat_fwd.slerp(vel_flat.normalized(), 0.35)
	cam_dir = cam_dir.slerp(target_dir, clampf(10.0 * delta, 0.0, 1.0)).normalized()
	var cam_pos := global_position - cam_dir * 6.2 + Vector3(0, 2.25, 0)
	var look_target := global_position + cam_dir * 4.0 + Vector3(0, 0.55, 0)
	cam.global_transform = Transform3D(Basis.looking_at(look_target - cam_pos, Vector3.UP), cam_pos)
	cam.fov = lerpf(cam.fov, clampf(72.0 + linear_velocity.length() * 0.22, 72.0, 86.0), clampf(6.0 * delta, 0.0, 1.0))
