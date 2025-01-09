shader_type canvas_item;

uniform float time_offset;

void fragment() {
    // Center UV coordinates
    vec2 uv = UV * 2.0 - 1.0;
    
    // Hexagon math
    float hex = abs(uv.x) * 0.866025 + abs(uv.y) * 0.5;
    
    // Animated border effect
    float border = smoothstep(0.9, 1.0, hex) * smoothstep(1.1, 1.0, hex);
    float pulse = sin(TIME * 3.0 + time_offset) * 0.5 + 0.5;
    
    // Apply pulsing border
    COLOR = vec4(1.0, 1.0, 0.0, border * pulse);
} 