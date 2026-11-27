shader_type spatial;
render_mode unshaded;

uniform vec3 deep_red : source_color = vec3(0.85, 0.08, 0.0);
uniform vec3 bright_orange : source_color = vec3(1.0, 0.35, 0.0);
uniform vec3 hot_yellow : source_color = vec3(1.0, 0.85, 0.2);
uniform float speed = 0.4;
uniform float scale = 3.0;
uniform float glow_strength = 2.5;

// Procedural 2D noise for smooth swirling liquid
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV * scale;
	float t = TIME * speed;

	// Warp UVs so the liquid swirls instead of scrolling flatly
	vec2 warp = vec2(
		fbm(uv + vec2(t, t * 0.6)),
		fbm(uv + vec2(-t * 0.7, t * 0.8))
	);
	float heat = fbm(uv + warp * 2.0);

	// Blend from deep red -> bright orange -> hot yellow core
	vec3 col = mix(deep_red, bright_orange, smoothstep(0.25, 0.6, heat));
	col = mix(col, hot_yellow, smoothstep(0.6, 0.88, heat));

	ALBEDO = col * glow_strength;
}


//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
