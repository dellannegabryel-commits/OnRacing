extends SceneTree

func _initialize() -> void:
	var ps := load("res://assets/corsa/corsa.dae") as PackedScene
	var inst := ps.instantiate()
	var body := inst.get_node("b1c9b_body0") as MeshInstance3D
	var mdt := MeshDataTool.new()
	for s in [6, 7, 8, 9, 12, 14, 18]:
		mdt.create_from_surface(body.mesh, s)
		var mat := body.mesh.surface_get_material(s)
		print("SURF ", s, " (", mat.resource_name, ") v0=", mdt.get_vertex(0))
	inst.free()
	quit(0)
