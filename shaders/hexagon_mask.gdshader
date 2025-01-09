shader_type canvas_item;

void fragment() {
    // Center UV coordinates
    vec2 uv = UV * 2.0 - 1.0;
    
    // Hexagon math
    float hex = abs(uv.x) * 0.866025 + abs(uv.y) * 0.5;
    
    // Create smooth hexagon mask
    float mask = 1.0 - smoothstep(0.95, 1.0, hex);
    
    // Apply mask
    COLOR.a *= mask;
} 