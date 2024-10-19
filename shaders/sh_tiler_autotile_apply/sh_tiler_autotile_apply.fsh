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
    
    int bitIndex;
    
         if(bitmaskType == 4) bitIndex = i1 *  1 + i3 *  2 + i5 *   4 + i7 * 8;
    else if(bitmaskType == 8) bitIndex = i0 *  1 + i1 *  2 + i2 *   4
                                       + i3 *  8           + i5 *  16
                                       + i6 * 32 + i7 * 64 + i8 * 128;
    
    float res = float(indexes[bitmask[bitIndex]]);
    gl_FragColor = vec4(res + 1., 0., 0., 0.);
    
}
