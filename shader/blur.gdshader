shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;  // Sử dụng hint_screen_texture

uniform float blur_radius : hint_range(0.0, 20.0) = 1.0;

void fragment() {
    vec2 uv = SCREEN_UV;  // Tọa độ UV màn hình
    vec4 blur_color = vec4(0.0);
    float total_weight = 0.0;

    // Kích thước mẫu mờ
    float radius = blur_radius / 100.0;

    // Lấy các mẫu xung quanh
    for (float x = -2.0; x <= 2.0; x++) {
        for (float y = -2.0; y <= 2.0; y++) {
            vec2 offset = vec2(x, y) * radius;
            blur_color += texture(SCREEN_TEXTURE, uv + offset);
            total_weight += 1.0;
        }
    }

    // Trung bình hóa màu để tạo mờ
    blur_color /= total_weight;

    COLOR = blur_color;
}
