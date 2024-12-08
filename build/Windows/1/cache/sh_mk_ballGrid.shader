attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)

varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform vec2  ballPos;
uniform float ballRad;
uniform vec3  ballShift;

void main() {
	vec3 ballPosition = in_Position + ballShift;
    vec4 object_space_pos = vec4( ballPosition, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour   = in_Colour;
	v_vPosition = (in_Position.xy - ballPos) / ballRad;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform sampler2D texture;
uniform vec2  dimension;
uniform vec2  samplePos;
uniform vec3  lightPos;
uniform float lightInt;

void main() {
	vec4 col = texture2D( texture, samplePos );
	
	vec2 tx = 1. / dimension;
	float x = v_vPosition.x - tx.x;
	float y = v_vPosition.y - tx.y;
	float mag = sqrt(x * x + y * y);
	if(mag >= 1.) {
		x /= (mag + tx.x);
		y /= (mag + tx.y);
	}
	
	float z = sqrt(1.0 - (pow(x, 2.0) + pow(y, 2.0)));
	
    vec3 position = vec3(x, y, z);
	vec3 normal   = normalize(position);
	vec3 light    = normalize(lightPos);
	
	float lightInf = 1. - dot(normal, light);
	col.rgb -= col.rgb * lightInf * lightInt;
	
	gl_FragColor = col;
}

