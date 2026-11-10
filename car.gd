extends VehicleBody3D

# ponytail: valores hardcoded GT3/Touring (~1250kg); extrair pra Resource quando tiver 2+ classes.
const MAX_STEER := 0.42
const STEER_SPEED := 3.2
const ENGINE_POWER := 4200.0
const BRAKE_FRONT := 45.0
const BRAKE_REAR := 18.0
const DOWNFORCE := 1.8
const GRIP_FRONT := 3.1
const GRIP_REAR := 3.6
const GRIP_DRIFT := 1.65
const YAW_DAMP := 2.5

@onready var wheels_front: Array[VehicleWheel3D] = [$WheelFL, $WheelFR]
@onready var wheels_rear: Array[VehicleWheel3D] = [$WheelRL, $WheelRR]
var brake_smooth := 0.0

func _ready() -> void:
	angular_damp = YAW_DAMP
	for w in wheels_front:
		w.wheel_friction_slip = GRIP_FRONT
		w.wheel_roll_influence = 0.05
	for w in wheels_rear:
		w.wheel_friction_slip = GRIP_REAR
		w.wheel_roll_influence = 0.05
	_setup_corsa_visuals()

func _setup_corsa_visuals() -> void:
	var path := "res://assets/corsa/corsa.glb" if ResourceLoader.exists("res://assets/corsa/corsa.glb") else "res://assets/corsa/corsa.dae"
	var ps := load(path) as PackedScene
	if ps == null:
		return
	var model := ps.instantiate() as Node3D
	model.name = "CorsaModel"
	# No Collada da Automation a frente fica em -Z; rodamos 180° para alinhar com +Z do VehicleBody3D
	model.rotation.y = PI
	model.position = Vector3(0.0, -0.32, 0.0)

	var wheel_f := model.get_node_or_null("b1c9b_wheel_f3") as MeshInstance3D
	var tyre_f := model.get_node_or_null("b1c9b_tyre_f2") as MeshInstance3D
	var wheel_r := model.get_node_or_null("b1c9b_wheel_r10") as MeshInstance3D
	var tyre_r := model.get_node_or_null("b1c9b_tyre_r9") as MeshInstance3D

	for c in model.get_children():
		if c is MeshInstance3D:
			_apply_corsa_materials(c)
			var cname := c.name.to_lower()
			if not cname.begins_with("b1c9b_body") and not cname.begins_with("b1c9b_chassis"):
				c.visible = false

	if has_node("ChassisVisual"):
		$ChassisVisual.visible = false
	add_child(model)

	_attach_wheel_visual($WheelFL, wheel_f, tyre_f, false)
	_attach_wheel_visual($WheelFR, wheel_f, tyre_f, true)
	_attach_wheel_visual($WheelRL, wheel_r, tyre_r, false)
	_attach_wheel_visual($WheelRR, wheel_r, tyre_r, true)

func _attach_wheel_visual(w: VehicleWheel3D, rim: MeshInstance3D, tyre: MeshInstance3D, flip_x: bool) -> void:
	if w.has_node("Mesh"):
		w.get_node("Mesh").visible = false
	var pivot := Node3D.new()
	pivot.name = "CorsaWheel"
	if flip_x:
		pivot.rotation.y = PI
	for src in [rim, tyre]:
		if src and src.mesh:
			var mi := MeshInstance3D.new()
			mi.mesh = src.mesh
			for s in mi.mesh.get_surface_count():
				mi.set_surface_override_material(s, src.get_surface_override_material(s))
			pivot.add_child(mi)
	w.add_child(pivot)

func _apply_corsa_materials(mi: MeshInstance3D) -> void:
	if mi.mesh == null:
		return
	for s in mi.mesh.get_surface_count():
		var orig := mi.mesh.surface_get_material(s)
		var mname := orig.resource_name.to_lower() if orig else ""
		var mat := StandardMaterial3D.new()
		if "carpaint" in mname:
			mat.albedo_color = Color(0.78, 0.08, 0.10)
			mat.metallic = 0.65
			mat.roughness = 0.18
			mat.clearcoat_enabled = true
		elif "carwindows" in mname:
			mat.albedo_color = Color(0.06, 0.09, 0.12, 0.72)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.roughness = 0.08
			mat.metallic = 0.2
		elif "tyre" in mname or "rubber" in mname:
			mat.albedo_color = Color(0.11, 0.11, 0.12)
			mat.roughness = 0.88
		elif "chrome" in mname or "brushedsteel" in mname or "machinedmetal" in mname:
			mat.albedo_color = Color(0.82, 0.84, 0.88)
			mat.metallic = 0.9
			mat.roughness = 0.22
		elif "brakelight" in mname:
			mat.albedo_color = Color(0.85, 0.05, 0.05)
			mat.emission_enabled = true
			mat.emission = Color(0.9, 0.08, 0.05)
			mat.emission_energy_multiplier = 1.6
		elif "headlight" in mname or "bulb" in mname:
			mat.albedo_color = Color(0.95, 0.97, 1.0)
			mat.emission_enabled = true
			mat.emission = Color(0.9, 0.95, 1.0)
			mat.emission_energy_multiplier = 2.0
		else:
			mat.albedo_color = Color(0.14, 0.14, 0.16)
			mat.roughness = 0.65
		mi.set_surface_override_material(s, mat)

func _physics_process(delta: float) -> void:
	var steer_in := Input.get_axis("steer_right", "steer_left")
	var throttle_in := Input.get_action_strength("throttle")
	var brake_in := Input.get_action_strength("brake")
	var hb := Input.is_action_pressed("handbrake")

	var speed := linear_velocity.length()
	var forward_speed := linear_velocity.dot(global_transform.basis.z)
	var speed_factor := clampf(1.0 - (speed / 70.0) * 0.72, 0.28, 1.0)
	steering = move_toward(steering, steer_in * MAX_STEER * speed_factor, STEER_SPEED * delta)
	brake_smooth = move_toward(brake_smooth, brake_in, 5.0 * delta)
	brake = 0.0

	if hb:
		engine_force = 0.0
		for w in wheels_front:
			w.brake = 0.0
		for w in wheels_rear:
			w.brake = BRAKE_REAR * 2.5
			w.wheel_friction_slip = move_toward(w.wheel_friction_slip, GRIP_DRIFT, 10.0 * delta)
	else:
		for w in wheels_rear:
			w.wheel_friction_slip = move_toward(w.wheel_friction_slip, GRIP_REAR, 6.0 * delta)

		if brake_in > 0.1 and forward_speed < 1.0:
			engine_force = -ENGINE_POWER * 0.5 * brake_in
			for w in wheels_front + wheels_rear:
				w.brake = 0.0
		else:
			engine_force = throttle_in * ENGINE_POWER
			var trail_scale := 1.0 - absf(steer_in) * 0.5
			for w in wheels_front:
				w.brake = brake_smooth * BRAKE_FRONT
			for w in wheels_rear:
				w.brake = brake_smooth * BRAKE_REAR * trail_scale

	apply_central_force(-global_transform.basis.y * speed * speed * DOWNFORCE)
