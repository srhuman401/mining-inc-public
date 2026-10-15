shader_type canvas_item;

uniform vec2 rect_center;   // screen coords (pixels)
uniform vec2 rect_size;     // size in pixels
uniform vec2 screen_size;   // viewport size in pixels

void fragment() {
    vec2 pixel = SCREEN_UV * screen_size;
    vec2 half_size = rect_size * 0.5;

    bool inside =
        pixel.x >= rect_center.x - half_size.x &&
        pixel.x <= rect_center.x + half_size.x &&
        pixel.y >= rect_center.y - half_size.y &&
        pixel.y <= rect_center.y + half_size.y;

    if (inside) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // transparent
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // fog
    }
}