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

uniform sampler2D mask;
uniform int useMask;
uniform int invMask;

uniform sampler2D original;
uniform sampler2D edited;
uniform float mixRatio;

void main() {
	vec4 msk = texture2D( mask, v_vTexcoord );
	vec4 ori = texture2D( original, v_vTexcoord );
	vec4 edt = texture2D( edited, v_vTexcoord );
	
	float mskAmo = (msk.r + msk.g + msk.b) / 3. * msk.a;
	if(invMask == 1) mskAmo = 1. - mskAmo;
	
	float rat = (useMask == 1? mskAmo : 1.) * mixRatio;
	      rat = clamp(rat, 0., 1.);
		  
	gl_FragColor = mix(ori, edt, rat);
	if(ori.a == 0.) gl_FragColor.rgb = edt.rgb;
	if(edt.a == 0.) gl_FragColor.rgb = ori.rgb;
}

