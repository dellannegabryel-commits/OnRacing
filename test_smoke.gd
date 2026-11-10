extends SceneTree

var frames := 0
var car: Vehicle

func _initialize() -> void:
	var scene := load("res://main.tscn") as PackedScene
	var root_node := scene.instantiate()
	get_root().add_child(root_node)
	car = root_node.get_node("Car") as Vehicle
	Input.action_press("throttle", 1.0)

func _physics_process(_delta: float) -> bool:
	frames += 1
	if frames == 300:
		Input.action_release("throttle")
		Input.action_press("brake", 1.0)
		Input.action_press("steer_left", 1.0)
		print(">>> BRAKE+STEER at f=300, spd=%.2f" % car.linear_velocity.length())
	if frames == 360:
		Input.action_release("brake")
		Input.action_release("steer_left")
		var yaw_rate := absf(car.angular_velocity.y)
		var pos_y := car.global_position.y
		var contacts := 0
		for wheel in car.wheel_array:
			if wheel.is_colliding():
				contacts += 1
		print(">>> SMOKE_TEST: yaw_rate=%.2f pos_y=%.2f vel=%.2f contacts=%d" % [yaw_rate, pos_y, car.linear_velocity.length(), contacts])
		if yaw_rate <= 2.0 and pos_y > 10.0 and contacts == 4:
			print(">>> PASS")
			quit(0)
		else:
			print(">>> FAIL (yaw_rate=%.2f > 2.0 or pos_y=%.2f <= 10.0 or contacts=%d != 4)" % [yaw_rate, pos_y, contacts])
			quit(1)
		return true
	return false
