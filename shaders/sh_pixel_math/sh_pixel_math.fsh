varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int   operator;
uniform vec4  operand;
uniform float mixAmount;

uniform int operandType;
uniform sampler2D operandSurf;

float round(float i) { return floor(i + .5); }

void main() {
    vec4 res = texture2D( gm_BaseTexture, v_vTexcoord );
    vec4 op  = operandType == 1? texture2D( operandSurf, v_vTexcoord ) : operand;
    
         if(operator == 0) { res = res + op; }
    else if(operator == 1) { res = res - op; }
    else if(operator == 2) { res = res * op; }
    else if(operator == 3) { res = res / op; }
    else if(operator == 4) { 
        res.r = pow(res.r, op.r);
        res.g = pow(res.g, op.g);
        res.b = pow(res.b, op.b);
        res.a = pow(res.a, op.a);
        
    } else if(operator == 5) { 
        res.r = pow(res.r, 1. / op.r);
        res.g = pow(res.g, 1. / op.g);
        res.b = pow(res.b, 1. / op.b);
        res.a = pow(res.a, 1. / op.a);
        
    } else if(operator == 6) { 
        res.r = sin(res.r);
        res.g = sin(res.g);
        res.b = sin(res.b);
        res.a = sin(res.a);
        
    } else if(operator == 7) { 
        res.r = cos(res.r);
        res.g = cos(res.g);
        res.b = cos(res.b);
        res.a = cos(res.a);
        
    } else if(operator == 8) { 
        res.r = tan(res.r);
        res.g = tan(res.g);
        res.b = tan(res.b);
        res.a = tan(res.a);
        
    } else if(operator == 9) { 
        res.r = mod(res.r, op.r);
        res.g = mod(res.g, op.g);
        res.b = mod(res.b, op.b);
        res.a = mod(res.a, op.a);
        
    } else if(operator == 10) { 
        res.r = floor(res.r);
        res.g = floor(res.g);
        res.b = floor(res.b);
        res.a = floor(res.a);
        
    } else if(operator == 11) { 
        res.r = ceil(res.r);
        res.g = ceil(res.g);
        res.b = ceil(res.b);
        res.a = ceil(res.a);
        
    } else if(operator == 12) { 
        res.r = round(res.r);
        res.g = round(res.g);
        res.b = round(res.b);
        res.a = round(res.a);
        
    } else if(operator == 13) { 
        res.r = mix(res.r, op.r, mixAmount);
        res.g = mix(res.g, op.g, mixAmount);
        res.b = mix(res.b, op.b, mixAmount);
        res.a = mix(res.a, op.a, mixAmount);
        
    } else if(operator == 14) { 
        res.r = abs(res.r);
        res.g = abs(res.g);
        res.b = abs(res.b);
        res.a = abs(res.a);
        
    } else if(operator == 15) { 
        res.r = clamp(res.r, op.x, op.y);
        res.g = clamp(res.g, op.x, op.y);
        res.b = clamp(res.b, op.x, op.y);
        res.a = clamp(res.a, op.x, op.y);
        
    } else if(operator == 16) { 
        res.r = floor(res.r / op.r) * op.r;
        res.g = floor(res.g / op.g) * op.g;
        res.b = floor(res.b / op.b) * op.b;
        res.a = floor(res.a / op.a) * op.a;
        
    } else if(operator == 17) { 
        res.r = fract(res.r);
        res.g = fract(res.g);
        res.b = fract(res.b);
        res.a = fract(res.a);
        
    } else if(operator == 18) { 
        res.r = res.r < op.r? 1. : 0.;
        res.g = res.g < op.g? 1. : 0.;
        res.b = res.b < op.b? 1. : 0.;
        res.a = 1.;
        
    } else if(operator == 19) { 
        res.r = res.r > op.r? 1. : 0.;
        res.g = res.g > op.g? 1. : 0.;
        res.b = res.b > op.b? 1. : 0.;
        res.a = 1.;
        
    }
    
    gl_FragColor = res;
}
