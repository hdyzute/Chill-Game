shader_type canvas_item;

uniform bool is_evolved = false;
uniform vec4 evolve_tint : source_color = vec4(1.0, 0.3, 0.3, 1.0); // Màu đỏ rực

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    if (is_evolved && color.a > 0.0) {
        // Trộn màu gốc với màu đỏ để tạo cảm giác tiến hóa hệ Hỏa
        color.rgb = mix(color.rgb, evolve_tint.rgb, 0.6);
    }
    
    COLOR = color;
}
