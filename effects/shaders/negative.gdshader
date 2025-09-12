shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform vec3 color_factor : source_color = vec3(1.0, 0.85, 0.66);

void fragment() {
	vec4 screen = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = vec4((vec3(1.0) - screen.rgb) * color_factor, screen.a * texture(TEXTURE, UV).a);
}