# ==============================================================================
# GUIA DE INTEGRACAO (GODOT 4) — TRACK MANAGER (Ex.: Interlagos)
# ==============================================================================
# 1. ARVORE DE NOS (Node Tree):
#    Adicione um no `TrackManager` (Node) na cena da pista e anexe `track_manager.gd`.
#    Adicione os checkpoints (`Area3D`) como FILHOS DIRETOS na ordem exata do tracado.
#    O PRIMEIRO filho (indice 0) e a Linha de Largada/Chegada; os seguintes sao o
#    setor 1, setor 2, etc. (ex.: S do Senna, Curva do Sol, Descida do Lago, Bico de Pato, Junçao):
#
#    Main (Node3D)
#    ├── Car (VehicleBody3D)
#    └── TrackManager (Node)  [script: res://track_manager.gd]
#        ├── StartFinish (Area3D)
#        │   └── CollisionShape3D (BoxShape3D atravessando toda a largura da pista)
#        ├── CP1_SennaS (Area3D)
#        │   └── CollisionShape3D
#        ├── CP2_Lago (Area3D)
#        │   └── CollisionShape3D
#        └── CP3_Juncao (Area3D)
#            └── CollisionShape3D
#
# 2. COLLISION LAYERS & MASKS (Para detetar o VehicleBody3D):
#    - No `Car` (`VehicleBody3D`):
#        Inspector -> Collision -> Layer: ative a Layer 2 (ex.: "Vehicles") além da 1,
#        ou mantenha na Layer 1 se a pista/estáticos não dispararem Area3D.
#    - Em cada `Area3D` filha de `TrackManager`:
#        Inspector -> Monitoring: `true`
#        Inspector -> Collision -> Layer: desative todas (o checkpoint nao e solido).
#        Inspector -> Collision -> Mask: ative a mesma Layer do `Car` (Layer 1 ou 2).
#    - O script filtra automaticamente por `body is VehicleBody3D`, ignorando chao/paredes.
#
# 3. FUNCIONAMENTO:
#    - Passar em `StartFinish` (indice 0) inicia o cronometro.
#    - Cada `Area3D` seguinte so valida se `idx == next_checkpoint` (ordem 1, 2, 3...).
#    - Cruzar `StartFinish` novamente com todos os checkpoints validados fecha a volta,
#      emite `lap_completed` (e `new_best_lap` se recorde) e ja inicia a proxima volta.
# ==============================================================================
extends Node

signal checkpoint_passed(index: int)
signal lap_completed(lap_time: float)
signal new_best_lap(time: float)

# ponytail: single-car state; mover para Dictionary[VehicleBody3D, int] quando entrar lobby multiplayer.
var total_checkpoints := 0
var next_checkpoint := 0
var lap_running := false
var current_lap_time := 0.0
var best_lap_time := INF

func _ready() -> void:
	for child in get_children():
		if child is Area3D:
			var idx := total_checkpoints
			total_checkpoints += 1
			child.body_entered.connect(_on_area_entered.bind(idx))

func _physics_process(delta: float) -> void:
	if lap_running:
		current_lap_time += delta

func _on_area_entered(body: Node3D, idx: int) -> void:
	if not (body is VehicleBody3D):
		return
	if idx == 0:
		if lap_running and next_checkpoint == total_checkpoints:
			var finished_time := current_lap_time
			lap_completed.emit(finished_time)
			if finished_time < best_lap_time:
				best_lap_time = finished_time
				new_best_lap.emit(best_lap_time)
		current_lap_time = 0.0
		lap_running = true
		next_checkpoint = 1
		checkpoint_passed.emit(0)
	elif lap_running and idx == next_checkpoint:
		next_checkpoint += 1
		checkpoint_passed.emit(idx)

static func format_time(t: float) -> String:
	if is_inf(t):
		return "--:--.---"
	var total_ms := int(roundf(t * 1000.0))
	return "%02d:%02d.%03d" % [total_ms / 60000, (total_ms / 1000) % 60, total_ms % 1000]
