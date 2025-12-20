/// Colorblind Simulation Shader by jcdickinson 
/// Color Blind Godot shader by Riko 

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int type;

void main() {
	vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	
	// // RGB to LMS matrix conversion
	// float L = (17.8824   * base.r) + (43.5161  * base.g) + (4.11935 * base.b);
	// float M = (3.45565   * base.r) + (27.1554  * base.g) + (3.86714 * base.b);
	// float S = (0.0299566 * base.r) + (0.184309 * base.g) + (1.46709 * base.b);
 //   float l,m,s;
    
	// // Simulate color blindness
	// if ( type == 0 ) { // Protanope - reds are greatly reduced (1% men)
	// 	l = 0.0 * L + 2.02344 * M + -2.52581 * S;
	// 	m = 0.0 * L + 1.0     * M + 0.0      * S;
	// 	s = 0.0 * L + 0.0     * M + 1.0      * S;
		
	// } else if ( type == 1 ) { // Deuteranope - greens are greatly reduced (1% men)
	// 	l = 1.0      * L + 0.0 * M + 0.0     * S;
	// 	m = 0.494207 * L + 0.0 * M + 1.24827 * S;
	// 	s = 0.0      * L + 0.0 * M + 1.0     * S;
		
	// } else if ( type == 2 ) { // Tritanope - blues are greatly reduced (0.003% population)
	// 	l =  1.0      * L + 0.0      * M + 0.0 * S;
	// 	m =  0.0      * L + 1.0      * M + 0.0 * S;
	// 	s = -0.395913 * L + 0.801109 * M + 0.0 * S;
		
	// }
	
	// // LMS to RGB matrix conversion
	// vec4 error;
	// error.r = ( 0.0809444479   * l) + (-0.130504409   * m) + ( 0.116721066 * s);
	// error.g = (-0.0102485335   * l) + ( 0.0540193266  * m) + (-0.113614708 * s);
	// error.b = (-0.000365296938 * l) + (-0.00412161469 * m) + ( 0.693511405 * s);
	// error.a = base.a;
	
	// gl_FragColor = error;
	
	// // Isolate invisible colors to color vision deficiency (calculate error matrix)
	// error = (base - error);
	
	// // Shift colors towards visible spectrum (apply error modifications)
	// vec4 correction;
	// correction.r = 0.; // (error.r * 0.0) + (error.g * 0.0) + (error.b * 0.0);
	// correction.g = (error.r * 0.7) + (error.g * 1.0); // + (error.b * 0.0);
	// correction.b = (error.r * 0.7) + (error.b * 1.0); // + (error.g * 0.0);
	
	// // Add compensation to original values
	// correction   = base + correction;
	// correction.a = base.a;
	
	// gl_FragColor = correction;
	
	mat3 selected_matrix;
	
    if(type == 0) selected_matrix = mat3( // 0: Normal vision
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, 1.0, 0.0),
        vec3(0.0, 0.0, 1.0)
	);
	
    if(type == 1) selected_matrix = mat3( // 1: Protanopia
        vec3(0.152, 1.053, -0.205),
        vec3(0.115, 0.786, 0.099),
        vec3(-0.004, -0.048, 1.052)
    );
    
    if(type == 2) selected_matrix = mat3( // 2: Protonomaly
        vec3(0.817, 0.333, -0.150),
        vec3(0.333, 0.667,  0.000),
        vec3(-0.017, 0.000, 1.017)
    );
    
    if(type == 3) selected_matrix = mat3( // 3: Deuteranopia
        vec3(0.367, 0.861, -0.228),
        vec3(0.280, 0.673,  0.047),
        vec3(-0.012, 0.043, 0.969)
    );
    
    if(type == 4) selected_matrix = mat3( // 4: Deuteranomaly
        vec3(0.800, 0.200, 0.000),
        vec3(0.258, 0.742, 0.000),
        vec3(0.000, 0.142, 0.858)
    );
    
    if(type == 5) selected_matrix = mat3( // 5: Tritanopia
        vec3(1.256, -0.077, -0.179),
        vec3(-0.078, 0.931, 0.148),
        vec3(0.005, 0.691, 0.304)
    );
    
    if(type == 6) selected_matrix = mat3( // 6: Tritanomaly
        vec3(0.967, 0.033, 0.000),
        vec3(0.000, 0.733, 0.267),
        vec3(0.000, 0.183, 0.817)
    );
    
    if(type == 7) selected_matrix = mat3( // 7: Achromatopsia
        vec3(0.299, 0.299, 0.299),
        vec3(0.587, 0.587, 0.587),
        vec3(0.114, 0.114, 0.114)
    );
    
    if(type == 8) selected_matrix = mat3( // 8: Achromatomaly
        vec3(0.618, 0.320, 0.062),
        vec3(0.163, 0.775, 0.062),
        vec3(0.163, 0.320, 0.516)
    );
    
    gl_FragColor = vec4(selected_matrix * base.rgb, base.a);
}
