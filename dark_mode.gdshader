shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec3 color_factor : source_color = vec3(1.0, 0.85, 0.66);

void fragment() {
	vec3 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
	COLOR.rgb = mix(vec3(0.0), screen_color, color_factor);
}