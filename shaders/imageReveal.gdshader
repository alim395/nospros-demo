shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int line_count = 60;
uniform bool show_scan_edge = true;

void fragment() {
	float row = floor(UV.y * float(line_count));
	float revealed_rows = floor(progress * float(line_count));
	vec4 tex_color = texture(TEXTURE, UV);

	if (row < revealed_rows) {
        COLOR = tex_color;
    } else if (show_scan_edge && progress > 0.0 && row == revealed_rows) {
        float flicker = 0.6 + 0.4 * sin(TIME * 30.0);
        COLOR = vec4(vec3(flicker), 1.0);
    } else {
        COLOR = vec4(0.0);
    }
}
