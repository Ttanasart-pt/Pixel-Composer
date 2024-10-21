#define _0(x) (x==0)
#define _1(x) (x==1)
#define _A(x) (true)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D maskSurface;

uniform vec2  dimension;
uniform int   bitmask[1024];
uniform int   bitmaskSize;
uniform int   bitmaskType;

uniform int   indexes[1024];
uniform int   indexSize;
uniform int   erase;

vec2 tx = 1. / dimension;

float msk(float x, float y) { return texture2D( maskSurface, v_vTexcoord + vec2(x, y) * tx )[0]; }

void main() {
    
    float m0 = msk(-1., -1.);
    float m1 = msk( 0., -1.);
    float m2 = msk( 1., -1.);
    
    float m3 = msk(-1.,  0.);
    float m4 = msk( 0.,  0.);
    float m5 = msk( 1.,  0.);
    
    float m6 = msk(-1.,  1.);
    float m7 = msk( 0.,  1.);
    float m8 = msk( 1.,  1.);
    
    float mm = max(m8, max(max(max(m0, m1), 
                               max(m2, m3)), 
                           max(max(m4, m5), 
                               max(m6, m7))
                          ));
    
    vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = base; 
    
    if(m4 == 0.)      return;
    if(mm <  1.)      return;
    if(base[0] <= 0.) return;
    
    int i0 = m0 == 1. && erase == 1? 0 : int(ceil(m0));
    int i1 = m1 == 1. && erase == 1? 0 : int(ceil(m1));
    int i2 = m2 == 1. && erase == 1? 0 : int(ceil(m2));
    
    int i3 = m3 == 1. && erase == 1? 0 : int(ceil(m3));
    int i4 = m4 == 1. && erase == 1? 0 : int(ceil(m4));
    int i5 = m5 == 1. && erase == 1? 0 : int(ceil(m5));
    
    int i6 = m6 == 1. && erase == 1? 0 : int(ceil(m6));
    int i7 = m7 == 1. && erase == 1? 0 : int(ceil(m7));
    int i8 = m8 == 1. && erase == 1? 0 : int(ceil(m8));
    
    int index = 0;
    
    // 0 1 2 
    // 3   5
    // 6 7 8
    
    if(bitmaskType == 0) {
        int _bitIndex = i1 * 1 + i3 * 2 + i5 * 4 + i7 * 8;
        index = bitmask[_bitIndex];
        
    } else if(bitmaskType == 1) {
        int _bitIndex = i1 * 1 + i3 * 2 + i5 * 4 + i7 * 8;
        index = 6;
        
        if(_0(i1) && _0(i3) && _1(i5) && _1(i7)) index =  0;
        if(_0(i1) && _0(i5) && _1(i3) && _1(i7)) index =  2;
        if(_0(i3) && _0(i7) && _1(i1) && _1(i5)) index = 10;
        if(_0(i5) && _0(i7) && _1(i1) && _1(i3)) index = 12;
        
        if(_0(i1) && _1(i3) && _1(i5) && _1(i7)) index =  1; 
        if(_0(i3) && _1(i1) && _1(i5) && _1(i7)) index =  5; 
        if(_0(i5) && _1(i3) && _1(i1) && _1(i7)) index =  7; 
        if(_0(i7) && _1(i3) && _1(i5) && _1(i1)) index = 11; 
        
        if(_1(i0) && _1(i1) && _1(i3) && _1(i5) && _1(i7) && _1(i8)) {
            if(_1(i2) && _0(i6)) index =  4;
            if(_0(i2) && _1(i6)) index =  8;
            if(_0(i2) && _0(i6)) index = 13;
        }
        
        if(_1(i1) && _1(i2) && _1(i3) && _1(i5) && _1(i6) && _1(i7)) {
            if(_1(i0) && _0(i8)) index =  3;
            if(_0(i0) && _1(i8)) index =  9;
            if(_0(i0) && _0(i8)) index = 14;
        }
        
    } else if(bitmaskType == 2) {
        index = 12;
        
        if(_0(i0) && _0(i1) && _0(i3) && _1(i5) && _1(i7) && _1(i8)) index =  0;
        if(_0(i1) && _0(i2) && _1(i3) && _0(i5) && _1(i6) && _1(i7)) index =  2;
        if(_1(i1) && _1(i2) && _0(i3) && _1(i5) && _0(i7) && _0(i8)) index = 22;
        if(_1(i0) && _1(i1) && _1(i3) && _0(i5) && _0(i6) && _0(i7)) index = 24;
        
        /////////////////
           
        if(_0(i0) && _0(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _1(i8)) index =  1;
           
        if(_0(i0) && _1(i1) && _1(i2) &&
           _0(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _1(i8)) index =  11;
           
        if(_1(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _0(i5) &&
           _1(i6) && _1(i7) && _0(i8)) index =  13;
           
        if(_1(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _0(i7) && _0(i8)) index =  23;
          
        /////////////////
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _0(i3) &&           _0(i5) &&
           _A(i6) && _1(i7) && _A(i8)) index =   3;
           
        if(_A(i0) && _1(i1) && _A(i2) &&
           _0(i3) &&           _0(i5) &&
           _A(i6) && _1(i7) && _A(i8)) index =  14;
           
        if(_A(i0) && _1(i1) && _A(i2) &&
           _0(i3) &&           _0(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index =  25;
           
        /////////////////
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _0(i3) &&           _1(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index =  33;
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _1(i3) &&           _1(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index =  34;
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _1(i3) &&           _0(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index =  35;
           
        /////////////////
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _0(i3) &&           _0(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index =  36;
           
        /////////////////
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _0(i3) &&           _1(i5) &&
           _A(i6) && _1(i7) && _0(i8)) index =  4;
        
        if(_A(i0) && _0(i1) && _A(i2) &&
           _1(i3) &&           _0(i5) &&
           _0(i6) && _1(i7) && _A(i8)) index =  7;
        
        if(_A(i0) && _1(i1) && _0(i2) &&
           _0(i3) &&           _1(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index = 37;
        
        if(_0(i0) && _1(i1) && _A(i2) &&
           _1(i3) &&           _0(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index = 40;
                   
        /////////////////
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _0(i8)) index =  5;
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _1(i8)) index =  6;
                   
        if(_A(i0) && _1(i1) && _1(i2) &&
           _0(i3) &&           _1(i5) &&
           _A(i6) && _1(i7) && _0(i8)) index = 15;
                   
        if(_A(i0) && _1(i1) && _0(i2) &&
           _0(i3) &&           _1(i5) &&
           _A(i6) && _1(i7) && _1(i8)) index = 26;
                   
        if(_1(i0) && _1(i1) && _A(i2) &&
           _1(i3) &&           _0(i5) &&
           _0(i6) && _1(i7) && _A(i8)) index = 18;
                   
        if(_0(i0) && _1(i1) && _A(i2) &&
           _1(i3) &&           _0(i5) &&
           _1(i6) && _1(i7) && _A(i8)) index = 29;
                   
        if(_1(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index = 38;
                   
        if(_0(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _A(i6) && _0(i7) && _A(i8)) index = 39;
                   
        /////////////////
           
        if(_1(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _0(i8)) index = 16;
                   
        if(_1(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _1(i8)) index = 17;
                   
        if(_1(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _1(i8)) index = 27;
                   
        if(_0(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _1(i8)) index = 28;
              
        /////////////////
           
        if(_A(i0) && _1(i1) && _0(i2) &&
           _0(i3) &&           _1(i5) &&
           _A(i6) && _1(i7) && _0(i8)) index = 48;
                   
        if(_1(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _0(i8)) index = 49;
                   
        if(_0(i0) && _1(i1) && _A(i2) &&
           _1(i3) &&           _0(i5) &&
           _0(i6) && _0(i7) && _A(i8)) index = 50;
                       
        if(_0(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _0(i7) && _1(i8)) index = 51;
                
        /////////////////
           
        if(_A(i0) && _0(i1) && _A(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _0(i8)) index = 8;
            
        if(_1(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _0(i8)) index = 8;
            
        if(_0(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _1(i8)) index = 30;
                   
        if(_0(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _0(i7) && _0(i8)) index = 41;
                   
        /////////////////
           
        if(_1(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _1(i8)) index = 9;
                   
        if(_0(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _0(i8)) index = 20;
           
        /////////////////
           
        if(_0(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _1(i8)) index = 31;
                   
        if(_0(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _1(i6) && _1(i7) && _0(i8)) index = 32;
           
        if(_0(i0) && _1(i1) && _1(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _0(i8)) index = 42;
                   
        if(_1(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _0(i8)) index = 43;
           
        /////////////////
           
        if(_0(i0) && _1(i1) && _0(i2) &&
           _1(i3) &&           _1(i5) &&
           _0(i6) && _1(i7) && _0(i8)) index = 52;
       
    }
    
    float res = float(indexes[index]);
    gl_FragColor = vec4(res + 1., 0., 0., 0.);
    
}
