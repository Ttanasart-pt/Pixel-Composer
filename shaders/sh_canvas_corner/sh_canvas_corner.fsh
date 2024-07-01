varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D base;
uniform vec2  dimension;
uniform float amount;

vec4 s( float x, float y ) { return texture2D( base, v_vTexcoord + vec2(x, y)); }
bool e( float x, float y ) { return texture2D( gm_BaseTexture, v_vTexcoord + vec2(x, y)).a == 0.; }

void main() {
	vec4 c  = texture2D( gm_BaseTexture, v_vTexcoord);
	gl_FragColor = c;
	
	if(c.a == 0.) return;
	if(amount == 0.) return;
	
	float x = 1. / dimension.x;
	float y = 1. / dimension.y;
	
	bool a1, a2, a3, a4, a5, a6, a7, a8, a9;
	
	if(amount >= 1.) {
		a1 = e(-x, -y);
		a2 = e(0., -y);
		a3 = e( x, -y);
		
		a4 = e(-x,  0.);
		a5 = e(0.,  0.);
		a6 = e( x,  0.);
		
		a7 = e(-x,  y);
		a8 = e(0.,  y);
		a9 = e( x,  y);
		
		     if( a1 &&  a2 &&  a3 && 
		         a4 && !a5 && !a6 && 
		         a7 && !a8           ) gl_FragColor = s(-x, -y);
		
		else if( a1 && !a2 &&    
		         a4 && !a5 && !a6 && 
		         a7 &&  a8 &&  a9    ) gl_FragColor = s(-x,  y);
		         
		else if(       !a2 &&  a3 && 
		        !a4 && !a5 &&  a6 && 
		         a7 &&  a8 &&  a9    ) gl_FragColor = s( x,  y);
		         
		else if( a1 &&  a2 &&  a3 && 
		        !a4 && !a5 &&  a6 && 
		               !a8 &&  a9    ) gl_FragColor = s( x, -y);
		
		/////////////////////////////////////////////////////////////////////////////////////////////
		
		else if( a1 &&  a2 &&  a3 && 
		         a4 && !a5 &&  a6 && 
		               !a8           ) gl_FragColor = s(0., -y);
		         
		else if(       !a2 &&  
		         a4 && !a5 &&  a6 && 
		         a7 &&  a8 &&  a9    ) gl_FragColor = s(0.,  y);
		         
		else if(        a2 &&  a3 && 
		        !a4 && !a5 &&  a6 && 
		                a8 &&  a9    ) gl_FragColor = s( x, 0.);
		         
		else if( a1 &&  a2 &&
		         a4 && !a5 && !a6 && 
		         a7 &&  a8           ) gl_FragColor = s(-x, 0.);
	}
	
	bool a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25;
	
	if(amount >= 2.) {
		// a10 = e(-x * 2., -y * 2.);
		a11 = e(-x     , -y * 2.);
		a12 = e(0.     , -y * 2.);
		a13 = e( x     , -y * 2.);
		// a14 = e( x * 2., -y * 2.);
		
		a15 = e(-x * 2., -y     );
		a16 = e( x * 2., -y     );
		a17 = e(-x * 2., 0.     );
		a18 = e( x * 2., 0.     );
		a19 = e(-x * 2.,  y     );
		a20 = e( x * 2.,  y     );
		
		// a21 = e(-x * 2.,  y * 2.);
		a22 = e(-x     ,  y * 2.);
		a23 = e(0.     ,  y * 2.);
		a24 = e( x     ,  y * 2.);
		// a25 = e( x * 2.,  y * 2.);
		
		// a10 &&  a11 &&  a12 &&  a13 &&  a14 && 
		// a15 &&  a1  &&  a2  &&  a3  &&  a16 && 
		// a17 &&  a4  &&  a5  &&  a6  &&  a18 && 
		// a19 &&  a7  &&  a8  &&  a9  &&  a20 &&
		// a21 &&  a22 &&  a23 &&  a24 &&  a25 &&

		     if( a15 &&  a1  &&  a2  &&  a3  && 
		         a17 && !a4  && !a5  && !a6  && 
		         a19 && !a7  && !a8  && !a9     ) gl_FragColor = s(-x * 2., -y     );
		
		else if( a15 && !a1  && !a2  && !a3  && 
		         a17 && !a4  && !a5  && !a6  && 
		         a19 &&  a7  &&  a8  &&  a9     ) gl_FragColor = s(-x * 2.,  y     );
		         
		else if(!a1  && !a2  && !a3  &&  a16 && 
				!a4  && !a5  && !a6  &&  a18 && 
				 a7  &&  a8  &&  a9  &&  a20    ) gl_FragColor = s( x * 2.,  y     );
		
		else if( a1  &&  a2  &&  a3  &&  a16 && 
				!a4  && !a5  && !a6  &&  a18 && 
				!a7  && !a8  && !a9  &&  a20    ) gl_FragColor = s( x * 2., -y     );
				 
		else if( a11 &&  a12 &&  a13 && 
		     	 a1  && !a2  && !a3  && 
		         a4  && !a5  && !a6  && 
		         a7  && !a8  && !a9     ) gl_FragColor = s(-x     , -y * 2.);
		         
		else if( a11 &&  a12 &&  a13 && 
		     	!a1  && !a2  &&  a3  && 
		        !a4  && !a5  &&  a6  && 
		        !a7  && !a8  &&  a9     ) gl_FragColor = s( x     , -y * 2.);
		         
		else if( a1  && !a2  && !a3  && 
		         a4  && !a5  && !a6  && 
		         a7  && !a8  && !a9  &&
		         a22 &&  a23 &&  a24    ) gl_FragColor = s(-x     ,  y * 2.);
		         
		else if(!a1  && !a2  &&  a3  && 
		        !a4  && !a5  &&  a6  && 
		        !a7  && !a8  &&  a9  &&
		         a22 &&  a23 &&  a24    ) gl_FragColor = s( x     ,  y * 2.);
		      
		/////////////////////////////////////////////////////////////////////////////////////////////
		   
	}
	
	bool a26, a27, a28, a29;
	bool a30, a31, a32, a33;
	bool a34, a35, a36, a37;
	
	if(amount >= 3.) {
		a26 = e(-x * 3., 0.);
		a27 = e( x * 3., 0.);
		a28 = e(0., -y * 3.);
		a29 = e(0.,  y * 3.);
		
		a30 = e(-x * 3.,  y);
		a31 = e(-x * 3., -y);
		a32 = e( x * 3., -y);
		a33 = e( x * 3.,  y);
		
		a34 = e( x, -y * 3.);
		a35 = e(-x, -y * 3.);
		a36 = e( x,  y * 3.);
		a37 = e(-x,  y * 3.);
		
		     if(         a15 &&  a1  &&  a2  && 
		         a26 && !a17 && !a4  && !a5  && 
		         a30 && !a19 && !a7  && !a8     ) gl_FragColor = s(-x * 2., -y     );
		
		else if( a31 && !a15 && !a1  && !a2  && 
		         a26 && !a17 && !a4  && !a5  && 
		                 a19 &&  a7  &&  a8     ) gl_FragColor = s(-x * 2.,  y     );
	
		else if(!a2  && !a3  && !a16 && a32 && 
		        !a5  && !a6  && !a18 && a27 && 
		         a8  &&  a9  &&  a20           ) gl_FragColor = s( x * 2.,  y     );
	
		else if( a2  &&  a3  &&  a16 &&  
		        !a5  && !a6  && !a18 && a27 &&
		        !a8  && !a9  && !a20 && a33    ) gl_FragColor = s( x * 2., -y     );
		
		else if(         a28 &&  a34 && 
			     a11 && !a12 && !a13 &&  
		         a1  && !a2  && !a3  &&
		         a4  && !a5  && !a6     ) gl_FragColor = s(-x     , -y * 2.);
		
		else if( a35 &&  a28 &&
			    !a11 && !a12 &&  a13 &&  
		        !a1  && !a2  &&  a3  &&
		        !a4  && !a5  &&  a6     ) gl_FragColor = s( x     , -y * 2.);
		
		else if( a4  && !a5  && !a6  &&
				 a7  && !a8  && !a9  &&
				 a22 && !a23 && !a24 && 
				         a29 &&  a36     ) gl_FragColor = s(-x     ,  y * 2.);
				         
		else if(!a4  && !a5  &&  a6  &&
				!a7  && !a8  &&  a9  &&
				!a22 && !a23 &&  a24 && 
				 a37 &&  a29            ) gl_FragColor = s( x     ,  y * 2.);
		        
		        
	}
}
