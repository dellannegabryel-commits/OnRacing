extends "res://track_manager.gd"

const TRACK_HALF_WIDTH := 8.0
const KERB_WIDTH := 1.1
const WALL_HEIGHT := 1.4
const STEP := 3.0
const TRACK_CURVE := preload("res://assets/paths/interlagos_curve.tres")

# ponytail: checkpoints por fração de volta; substituir por "Path3D @ perc" quando os nós forem Path3D.
const CP_FRACTIONS: Array[float] = [0.0, 0.2192, 0.4201, 0.6253, 0.8205]

const TRACK_SHADER := """
shader_type spatial;
render_mode cull_disabled;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	float u = UV.x;
	float v = UV.y;
	float g = hash(floor(UV * vec2(90.0, 20.0)));
	if (u < 0.12 || u > 0.88) {
		float post = step(0.88, fract(v * 0.25));
		ALBEDO = mix(vec3(0.55, 0.57, 0.6), vec3(0.12, 0.25, 0.55), post) * (0.9 + 0.1 * g);
		ROUGHNESS = 0.7;
	} else if (u < 0.20 || u > 0.80) {
		float stripe = step(0.5, fract(v * 0.45));
		vec3 kerb = mix(vec3(0.82, 0.12, 0.12), vec3(0.92, 0.92, 0.92), stripe);
		if (u > 0.80 && fract(v * 0.225) < 0.33) kerb = vec3(0.08, 0.52, 0.22);
		ALBEDO = kerb * (0.92 + 0.08 * g);
		ROUGHNESS = 0.78;
	} else {
		vec3 asphalt = vec3(0.14, 0.15, 0.17) + (g - 0.5) * 0.04;
		float groove = exp(-pow((u - 0.45) * 7.5, 2.0));
		asphalt *= 1.0 - groove * 0.28;
		float edge_line = step(abs(u - 0.215), 0.008) + step(abs(u - 0.785), 0.008);
		float start_box = step(v, 1.2) * step(0.5, fract(u * 24.0 + floor(v * 4.0) * 0.5));
		ALBEDO = mix(asphalt, vec3(0.92), clamp(edge_line + start_box, 0.0, 1.0));
		ROUGHNESS = mix(0.88, 0.62, groove);
	}
}
"""

func _ready() -> void:
	var curve: Curve3D = TRACK_CURVE

	var path := Path3D.new()
	path.name = "TrackPath"
	path.curve = curve
	add_child(path)

	_build_road(curve)
	_build_infield()
	_build_checkpoints(curve)
	super._ready()

func _build_road(curve: Curve3D) -> void:
	var length := curve.get_baked_length()
	var steps := int(length / STEP)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var w := TRACK_HALF_WIDTH
	var kw := KERB_WIDTH
	var h := WALL_HEIGHT
	var profile: Array[Vector2] = [
		Vector2(-w - kw - 0.5, 0.0), Vector2(-w - kw - 0.5, h),
		Vector2(-w - kw, h),         Vector2(-w - kw, 0.06),
		Vector2(-w, 0.0),            Vector2(w, 0.0),
		Vector2(w + kw, 0.06),       Vector2(w + kw, h),
		Vector2(w + kw + 0.5, h),    Vector2(w + kw + 0.5, 0.0),
	]
	var u_coords: Array[float] = [0.0, 0.04, 0.08, 0.12, 0.20, 0.80, 0.88, 0.92, 0.96, 1.0]

	var rings: Array[Array] = []
	for i in steps + 1:
		var dist := fmod(i * STEP, length)
		var xform := curve.sample_baked_with_rotation(dist, true, true)
		var ring: Array[Vector3] = []
		for p in profile:
			ring.append(xform * Vector3(p.x, p.y, 0.0))
		rings.append(ring)

	for i in steps:
		var r0 := rings[i]
		var r1 := rings[i + 1]
		var v0 := float(i) * (STEP * 0.25)
		var v1 := float(i + 1) * (STEP * 0.25)
		for j in profile.size() - 1:
			var u0 := u_coords[j]
			var u1 := u_coords[j + 1]
			st.set_uv(Vector2(u0, v0)); st.add_vertex(r0[j])
			st.set_uv(Vector2(u0, v1)); st.add_vertex(r1[j])
			st.set_uv(Vector2(u1, v0)); st.add_vertex(r0[j + 1])

			st.set_uv(Vector2(u1, v0)); st.add_vertex(r0[j + 1])
			st.set_uv(Vector2(u0, v1)); st.add_vertex(r1[j])
			st.set_uv(Vector2(u1, v1)); st.add_vertex(r1[j + 1])

	st.generate_normals()
	var mesh := st.commit()

	var sh := Shader.new()
	sh.code = TRACK_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mesh.surface_set_material(0, mat)

	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	add_child(mi)

	var body := StaticBody3D.new()
	body.name = "RoadBody"
	var col := CollisionShape3D.new()
	col.shape = mesh.create_trimesh_shape()
	body.add_child(col)
	add_child(body)

func _build_infield() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(1200, 1200)
	var noise := FastNoiseLite.new()
	noise.frequency = 0.04
	var ntex := NoiseTexture2D.new()
	ntex.noise = noise
	var gmat := StandardMaterial3D.new()
	gmat.albedo_color = Color(0.16, 0.34, 0.14)
	gmat.albedo_texture = ntex
	gmat.uv1_scale = Vector3(80, 80, 1)
	gmat.roughness = 0.95
	var ground := MeshInstance3D.new()
	ground.mesh = plane
	ground.material_override = gmat
	ground.position = Vector3(-160, -8.0, 40)
	add_child(ground)

func _build_checkpoints(curve: Curve3D) -> void:
	var box := BoxShape3D.new()
	box.size = Vector3(TRACK_HALF_WIDTH * 2.4, 6.0, 2.5)
	var arch_mesh := BoxMesh.new()
	arch_mesh.size = Vector3((TRACK_HALF_WIDTH + KERB_WIDTH) * 2.0, 0.6, 0.8)
	var length := curve.get_baked_length()

	for k in CP_FRACTIONS.size():
		var frac := CP_FRACTIONS[k]
		var offset := fmod(frac * length, length)
		var xform := curve.sample_baked_with_rotation(offset, true, true)

		var area := Area3D.new()
		area.name = "StartFinish" if k == 0 else "CP_%d" % k
		area.transform = xform

		var cs := CollisionShape3D.new()
		cs.position = Vector3(0, 3.0, 0)
		cs.shape = box
		area.add_child(cs)

		var banner := MeshInstance3D.new()
		banner.position = Vector3(0, 5.2, 0)
		banner.mesh = arch_mesh
		var bmat := StandardMaterial3D.new()
		bmat.albedo_color = Color(0.95, 0.95, 0.95) if k == 0 else Color(1.0, 0.72, 0.08)
		banner.material_override = bmat
		area.add_child(banner)

		add_child(area)
