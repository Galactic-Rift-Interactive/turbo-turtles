// Water Shader
shader_type spatial;

// Parameters --- Can be accessed in "Shader Parameters".
uniform vec4 colour  = vec4(0.0, 0.2, 1.0, 1.0);
uniform float amount : hint_range(0.2, 1.5) = 0.8;
uniform float beer_factor: hint_range(0.0, 1.0, 0.1) = 0.2;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;

uniform float metallic: hint_range(0.0, 1.0, 0.1) = 0.6;
uniform float specular: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float roughness: hint_range(0.0, 1.0, 0.1) = 0.2;

float generateOffset(float x, float z, float val1, float val2, float time) {
	float speed = 1.0;

	float radianX = ((mod(x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radianZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;

	return amount * 0.5 * (sin(radianZ) + cos(radianX));
}

vec3 applyDistortion(vec3 vertex, float time){
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);

	return vertex + vec3(xd, yd, zd);
}

void vertex() {
	VERTEX = applyDistortion(VERTEX, TIME * 0.1);
}

void fragment() {
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	ALBEDO = colour.xyz;

	// For transparency
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;

	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;

	depth = exp(-depth * beer_factor);
	ALPHA = clamp(1.0 - depth, 0.0, 1.0);
}
