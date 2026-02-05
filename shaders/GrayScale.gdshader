shader_type canvas_item;

// --- Uniforms --- //
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool weighted = true;	// Determines whether to use normal or weighted averages

void fragment() {
	vec3 finalColor = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

	finalColor.rgb = mix(vec3((finalColor.r + finalColor.g + finalColor.b) / 3.0),  vec3(0.299 * finalColor.r + 0.587 * finalColor.g + 0.114 * finalColor.b), float(weighted));

	COLOR.rgb = finalColor;
}