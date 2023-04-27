shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
//Noise Texture
uniform sampler2D Noise;

//Settings
uniform float Transparency = 1.0;
uniform float Slow = 2.0;

//Shader Code
void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV) * texture(Noise, texture(Noise, UV).xy + cos(TIME) / Slow) / Transparency;
}