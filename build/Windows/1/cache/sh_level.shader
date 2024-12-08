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
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 lwi;
uniform vec2 lri;
uniform vec2 lgi;
uniform vec2 lbi;
uniform vec2 lai;

uniform vec2 lwo;
uniform vec2 lro;
uniform vec2 lgo;
uniform vec2 lbo;
uniform vec2 lao;

void main() {
	vec4 col  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	col.r = (col.r - lri.x) / (lri.y - lri.x) * (lro.y - lro.x) + lro.x;
	col.g = (col.g - lgi.x) / (lgi.y - lgi.x) * (lgo.y - lgo.x) + lgo.x;
	col.b = (col.b - lbi.x) / (lbi.y - lbi.x) * (lbo.y - lbo.x) + lbo.x;
	col.a = (col.a - lai.x) / (lai.y - lai.x) * (lao.y - lao.x) + lao.x;
	
	col.rgb = (col.rgb - lwi.x) / (lwi.y - lwi.x) * (lwo.y - lwo.x) + lwo.x;
	
    gl_FragColor = col;
}

