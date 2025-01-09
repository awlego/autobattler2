shader_type particles;

uniform vec3 direction = vec3(0.0, -1.0, 0.0);
uniform float spread = 45.0;
uniform float flatness = 0.0;
uniform float initial_linear_velocity_min = 0.0;
uniform float initial_linear_velocity_max = 0.0;
uniform float scale_min = 1.0;
uniform float scale_max = 1.0;

float rand_from_seed(inout uint seed) {
    seed = (seed * 1103515245 + 12345) & uint(0x7fffffff);
    return float(seed) / float(0x7fffffff);
}

void start() {
    uint seed = NUMBER + RANDOM_SEED;
    
    // Randomize velocity
    float velocity = mix(initial_linear_velocity_min, initial_linear_velocity_max, rand_from_seed(seed));
    
    // Calculate spread angle
    float angle_rand = rand_from_seed(seed) * spread - spread/2.0;
    float angle_rad = radians(angle_rand);
    
    // Apply velocity with spread
    VELOCITY = vec3(
        direction.x * cos(angle_rad) - direction.y * sin(angle_rad),
        direction.y * cos(angle_rad) + direction.x * sin(angle_rad),
        0.0
    ) * velocity;
    
    // Randomize scale
    float scale = mix(scale_min, scale_max, rand_from_seed(seed));
    TRANSFORM[0].xyz = vec3(scale, 0.0, 0.0);
    TRANSFORM[1].xyz = vec3(0.0, scale, 0.0);
    TRANSFORM[2].xyz = vec3(0.0, 0.0, scale);
}

void process() {
    // Rotate the hexagon particle
    float rotation_speed = TIME * 2.0;
    mat2 rotation = mat2(
        vec2(cos(rotation_speed), -sin(rotation_speed)),
        vec2(sin(rotation_speed), cos(rotation_speed))
    );
    
    TRANSFORM[0].xy = rotation * TRANSFORM[0].xy;
    TRANSFORM[1].xy = rotation * TRANSFORM[1].xy;
} 