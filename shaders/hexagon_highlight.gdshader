shader_type canvas_item;

uniform float glow_intensity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);

void fragment() {
    // Center UV coordinates
    vec2 uv = UV * 2.0 - 1.0;
    
    // Hexagon math
    float hex = abs(uv.x) * 0.866025 + abs(uv.y) * 0.5;
    
    // Create glowing border effect
    float border = smoothstep(0.9, 1.0, hex) * smoothstep(1.1, 1.0, hex);
    
    // Apply glow
    COLOR = mix(vec4(0.0), glow_color, border * glow_intensity);
} 