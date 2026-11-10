class_name CarConfig
extends Resource
## Assists e tuning por carro/modo. Aplicado ao Vehicle antes do initialize().

@export_group("Assists")
@export var abs_enabled := true
@export var tc_enabled := true
@export var stability_enabled := true
## 0 = contra-esterco totalmente manual; 1 = maximo assistido.
@export_range(0.0, 1.0) var countersteer_assist := 0.7
## Slip lateral (rad) a partir do qual o esterco e reduzido.
@export_range(0.0, 0.5) var steering_slip_assist := 0.15

@export_group("Tuning")
@export var vehicle_mass := 1250.0
@export var max_torque := 400.0
@export var max_rpm := 8500.0
@export_range(0.3, 0.8) var front_weight_distribution := 0.55
## Downforce (N por m^2/s^2). 0 = sem asa.
@export var downforce := 2.2

func apply_to(v: Vehicle) -> void:
	v.enable_stability = stability_enabled
	v.front_abs_pulse_time = 0.03 if abs_enabled else 0.0
	v.rear_abs_pulse_time = 0.03 if abs_enabled else 0.0
	v.traction_control_max_slip = 6.0 if tc_enabled else -1.0
	v.countersteer_assist = countersteer_assist
	v.steering_slip_assist = steering_slip_assist
	v.vehicle_mass = vehicle_mass
	v.max_torque = max_torque
	v.max_rpm = max_rpm
	v.front_weight_distribution = front_weight_distribution

# ponytail: presets hardcoded por modo; adicionar UI de setup quando existir menu de lobby.
static func preset_ranked() -> CarConfig:
	var c := CarConfig.new()
	c.abs_enabled = true
	c.tc_enabled = true
	c.stability_enabled = true
	c.countersteer_assist = 0.7
	return c

static func preset_casual() -> CarConfig:
	var c := CarConfig.new()
	c.abs_enabled = true
	c.tc_enabled = true
	c.stability_enabled = true
	c.countersteer_assist = 0.9
	return c

static func preset_time_trial() -> CarConfig:
	var c := CarConfig.new()
	c.abs_enabled = false
	c.tc_enabled = false
	c.stability_enabled = false
	c.countersteer_assist = 0.0
	return c
