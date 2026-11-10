extends SceneTree

var frames := 0
var car: VehicleBody3D
var scene_tm: Node

func _initialize() -> void:
	var scene := load("res://main.tscn") as PackedScene
	if scene == null:
		printerr("FAIL: main.tscn falhou ao carregar"); quit(1); return
	var root_node := scene.instantiate()
	get_root().add_child(root_node)
	car = root_node.get_node("Car") as VehicleBody3D
	scene_tm = root_node.get_node("TrackManager")
	if car == null or scene_tm == null:
		printerr("FAIL: Car ou TrackManager ausente"); quit(1); return
	_test_track_manager(car)
	Input.action_press("throttle", 1.0)

func _test_track_manager(test_car: VehicleBody3D) -> void:
	var tm_script := load("res://track_manager.gd") as GDScript
	var tm: Node = tm_script.new()
	for i in 3:
		tm.add_child(Area3D.new())
	tm._ready()
	var laps: Array[float] = []
	var bests: Array[float] = []
	tm.lap_completed.connect(func(t: float): laps.append(t))
	tm.new_best_lap.connect(func(t: float): bests.append(t))

	tm._on_area_entered(test_car, 0)
	tm.current_lap_time = 71.234
	tm._on_area_entered(test_car, 2)
	tm._on_area_entered(test_car, 0)
	if not laps.is_empty():
		printerr("FAIL: Batota contou volta"); quit(1); return

	tm.current_lap_time = 89.456
	tm._on_area_entered(test_car, 1)
	tm._on_area_entered(test_car, 2)
	tm._on_area_entered(test_car, 0)
	if laps.size() != 1 or bests.size() != 1 or tm_script.format_time(89.456) != "01:29.456":
		printerr("FAIL: Volta valida ou format_time"); quit(1); return
	tm.free()

func _physics_process(_delta: float) -> bool:
	frames += 1
	if frames == 1:
		if scene_tm.total_checkpoints != 5 or not scene_tm.has_node("RoadBody"):
			printerr("FAIL: Interlagos CPs=%d RoadBody=%s" % [scene_tm.total_checkpoints, scene_tm.has_node("RoadBody")])
			quit(1)
			return true
		var path := scene_tm.get_node_or_null("TrackPath") as Path3D
		if path == null or path.curve == null or path.curve.get_point_count() != 14:
			printerr("FAIL: TrackPath Path3D ausente ou curva invalida")
			quit(1)
			return true
		if not car.has_node("CorsaModel") or not car.get_node("WheelFL").has_node("CorsaWheel"):
			printerr("FAIL: CorsaModel nao instanciado no Car")
			quit(1)
			return true
	# Acelera por 90 frames, depois freia forte virando a esquerda por 30 frames
	if frames == 90:
		Input.action_release("throttle")
		Input.action_press("brake", 1.0)
		Input.action_press("steer_left", 1.0)
	if frames == 120:
		Input.action_release("brake")
		Input.action_release("steer_left")
		var yaw_rate := absf(car.angular_velocity.y)
		if yaw_rate > 2.0 or car.global_position.y <= 10.0:
			printerr("FAIL: Spin ao frear virando! yaw_rate=%.2f pos_y=%.2f" % [yaw_rate, car.global_position.y])
			quit(1)
			return true
		print("SMOKE_OK: Estavel na frenagem em curva (yaw_rate=%.2f rad/s, vel=%.2f m/s)" % [yaw_rate, car.linear_velocity.length()])
		quit(0)
	return false
