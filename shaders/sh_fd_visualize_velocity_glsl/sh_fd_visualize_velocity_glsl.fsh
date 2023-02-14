// 2D vector field visualization by Morgan McGuire, @morgan3d, http://casual-effects.com.

#define FLOAT_16_OFFSET (128.0 / 255.0)
#define PI 3.1415927
#define ARROW_TILE_SIZE 16.0
#define ARROW_HEAD_ANGLE (45.0 * PI / 180.0)
#define ARROW_HEAD_LENGTH (ARROW_TILE_SIZE / 4.0)
#define ARROW_SHAFT_THICKNESS 1.0

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 texel_size;

vec2 unpack_uvec2_16(vec4 data) {return vec2(data.xy + (data.zw / 255.0));}
vec2 arrow_tile_center_coord(vec2 pos) {return (floor(pos / ARROW_TILE_SIZE) + 0.5) * ARROW_TILE_SIZE;}
vec2 field(vec2 pos) {return (unpack_uvec2_16(texture2D(gm_BaseTexture, pos * texel_size)) - FLOAT_16_OFFSET) * 2.0;}

float arrow(vec2 p, vec2 v) {
    p -= arrow_tile_center_coord(p);
    float mag_v = length(v), mag_p = length(p);

    if (mag_v > 0.0) {
        vec2 dir_p = p / mag_p, dir_v = v / mag_v;
        mag_v = clamp(mag_v, 5.0, ARROW_TILE_SIZE / 2.0); // We can't draw arrows larger than the tile radius, so clamp magnitude. Enforce a minimum length to help see direction.
        v = dir_v * mag_v;
        
        // Signed distance from a line segment based on https://www.shadertoy.com/view/ls2GWG by Matthias Reitinger, @mreitinger.
        float dist =  max(
            ARROW_SHAFT_THICKNESS / 4.0 - max(abs(dot(p, vec2(dir_v.y, -dir_v.x))), abs(dot(p, dir_v)) - mag_v + ARROW_HEAD_LENGTH / 2.0),
            min(0.0, dot(v - p, dir_v) - cos(ARROW_HEAD_ANGLE / 2.0) * length(v - p)) * 2.0 + min(0.0, dot(p, dir_v) + ARROW_HEAD_LENGTH - mag_v)
        );
            
        return clamp(1.0 + dist, 0.0, 1.0);
    } else {
        return max(0.0, 1.2 - mag_p);
    }
}

void main() {
    gl_FragColor = v_vColour * mix(
        vec4(vec3(length(unpack_uvec2_16(texture2D(gm_BaseTexture, v_vTexcoord)) - FLOAT_16_OFFSET)), 1.0),
        vec4(0.0, 1.0, 1.0, 1.0),
        arrow(v_vTexcoord / texel_size, field(arrow_tile_center_coord(v_vTexcoord / texel_size)) * ARROW_TILE_SIZE * 0.4) * 0.3
    );
}
