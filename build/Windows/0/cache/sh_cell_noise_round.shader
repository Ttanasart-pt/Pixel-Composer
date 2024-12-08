//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 position;
uniform float scale;
uniform float time;
uniform float contrast;

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
	vec2 ntx   = v_vTexcoord * vec2(1., dimension.y / dimension.x);
    vec2 st    = ntx + position;
    vec3 color = vec3(.0);

    // Scale
    st *= scale;

    // Tile the space
    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 1.;  // minimum distance
	float tres = 1.;

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            // Neighbor place in the grid
            vec2 neighbor = vec2(float(x),float(y));
			
            // Random position from current + neighbor place in the grid
            vec2 point = random2(i_st + neighbor);
			point = 0.5 + 0.5 * sin(time + 6.2831 * point);
			
			vec2 px = neighbor + point;
            vec2 _diff = px - f_st;
			
            // Distance to the point
            float dist = length(_diff);
			
			if(dist < tres)
				m_dist = dist;
        }
    }

    // Draw the min distance (distance field)
    color += m_dist;

	vec3 c = 0.5 + (color - 0.5) * contrast;
    gl_FragColor = vec4(c, 1.0);
}

