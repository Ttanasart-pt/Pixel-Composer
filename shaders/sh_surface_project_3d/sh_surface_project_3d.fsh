varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

// based on IQ voxel shader
// the axis is actually wrong, but I'm too lazy so just use offseted surface

uniform sampler2D surTop;    // Front
uniform sampler2D surFront;  // Side
uniform sampler2D surSide;   // Top

uniform sampler2D surTopB;   // -Front
uniform sampler2D surFrontB; // -Side
uniform sampler2D surSideB;  // -Top

uniform int surTopB_use;
uniform int surFrontB_use;
uniform int surSideB_use;

uniform int blend;

uniform float scale;

uniform vec3 angle;

#region ////========== Transform ============
    mat3 rotateX(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3(1, 0,  0),
            vec3(0, c, -s),
            vec3(0, s,  c)
        );
    }
    
    mat3 rotateY(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3( c, 0, s),
            vec3( 0, 1, 0),
            vec3(-s, 0, c)
        );
    }
    
    mat3 rotateZ(float dg) {
        float c = cos(radians(dg));
        float s = sin(radians(dg));
        return mat3(
            vec3(c, -s, 0),
            vec3(s,  c, 0),
            vec3(0,  0, 1)
        );
    }
    
    mat3 inverse(mat3 m) {
        float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
        float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
        float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];
        
        float b01 = a22 * a11 - a12 * a21;
        float b11 = -a22 * a10 + a12 * a20;
        float b21 = a21 * a10 - a11 * a20;
        
        float det = a00 * b01 + a01 * b11 + a02 * b21;
        
        return mat3(b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
                  b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
                  b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)) / det;
    }
#endregion

void main() {
	mat3 rx = rotateX(angle.x);
    mat3 ry = rotateY(angle.y);
    mat3 rz = rotateZ(angle.z);
    mat3 rotMatrix  = rx * ry * rz;
    mat3 irotMatrix = inverse(rotMatrix);
	
	vec2 uv  = (v_vTexcoord - .5) * scale; 
	vec3 dir = vec3(0., 0., -1.);
    vec3 eye = vec3(uv, sqrt(3.));
	
	dir = irotMatrix * dir;
	dir = normalize(dir);
	eye = irotMatrix * eye;
	
	float size    = max(dimension.x, dimension.y);
	float voxSize = 2.0 / size;
    
    if(abs(dir.x) < .001) dir.x = .001; // prevent divided by zero. TODO: implement proper code when dealing with 2d projection
    if(abs(dir.y) < .001) dir.y = .001;
    if(abs(dir.z) < .001) dir.z = .001;
	
    vec3 ro  = eye / voxSize;
    vec3 rd  = dir;
    vec3 pos = floor(ro);
    vec3 ri  = 1.0 / rd;
    vec3 rs  = sign(rd);
    vec3 dis = (pos - ro + 0.5 + rs * 0.5) * ri;
    
	vec4 samTop   = vec4(0.);
	vec4 samFront = vec4(0.);
	vec4 samSide  = vec4(0.);
    vec3 mm  = vec3(0.);
	bool hit = false;

	float maxVoxels = sqrt(3.) * size * 2.;
	
    for (float i = 0.; i < maxVoxels; i++) {
        vec3 wc = (pos + 0.5) * voxSize;
        vec3 sc = wc * .5 + .5;
        
        if (sc.x >= 0. && sc.x < 1. && sc.y >= 0. && sc.y < 1. && sc.z >= 0. && sc.z < 1.) {
            // samTop   = surTopB_use   == 1 && pos.z < 0.? texture2D(surTopB,   sc.xy) : texture2D(surTop,   sc.xy);
            // samFront = surFrontB_use == 1 && pos.x < 0.? texture2D(surFrontB, sc.zy) : texture2D(surFront, sc.zy);
            // samSide  = surSideB_use  == 1 && pos.y < 0.? texture2D(surSideB,  sc.xz) : texture2D(surSide,  sc.xz);
            
            samTop   = texture2D(surTop,   sc.xy);
            samFront = texture2D(surFront, sc.zy);
            samSide  = texture2D(surSide,  sc.xz);
            
            if (blend == 0 && (samTop.a > 0. && samFront.a > 0. && samSide.a > 0.)) { hit = true; break; }
            if (blend == 1 && (samTop.a > 0. || samFront.a > 0. || samSide.a > 0.)) { hit = true; break; }
        }
        
        mm   = step(dis.xyz, dis.yzx) * step(dis.xyz, dis.zxy);
        dis += mm * rs * ri;
        pos += mm * rs;
    }
	
	if (!hit) { gl_FragColor = vec4(0.); return; }
    
    vec3 fmini  = (pos - ro + 0.5 - 0.5 * vec3(rs)) * ri;
    float ft    = max(fmini.x, max(fmini.y, fmini.z));
    vec3 hitPos = (ro + rd * ft) * voxSize;
    vec3 samPos = hitPos * .5 + .5;
    
         if (mm.z > 0.5) gl_FragColor = surTopB_use   == 1 && rs.z >= 0.? texture2D(surTopB,   samPos.xy) : texture2D(surTop,   samPos.xy);
    else if (mm.x > 0.5) gl_FragColor = surFrontB_use == 1 && rs.x >= 0.? texture2D(surFrontB, samPos.zy) : texture2D(surFront, samPos.zy);
    else                 gl_FragColor = surSideB_use  == 1 && rs.y >= 0.? texture2D(surSideB,  samPos.xz) : texture2D(surSide,  samPos.xz);
}