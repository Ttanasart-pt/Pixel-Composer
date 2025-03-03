function Surface_sampler(s = noone) constructor {
    active  = false;
    surface = noone;
    buffer  = noone;
    
    sw = 1;
    sh = 1;
    format = surface_rgba8unorm;
        
    static setSurface = function(s) {
        if(buffer != noone) buffer_delete(buffer);
        
        surface = s;
        buffer  = noone;
        active  = is_surface(surface);
        if(!active) return;
        
        sw      = surface_get_width(surface);
        sh      = surface_get_height(surface);
        format  = surface_get_format(surface);
        buffer  = buffer_create(sw * sh * 4, buffer_fixed, 1);
        buffer_get_surface(buffer, surface, 0);
        
        switch(format) {
            case surface_r16float   : getPixel = getPixelF16; break;
            case surface_r32float   : getPixel = getPixelF32; break;
            
            case surface_rgba8unorm : getPixel = getPixelU32; break;
        }
    }
    
    setSurface(s);
    
    static getPixelF16 = function(_x,_y) /*=>*/ {return buffer_read_at(buffer, (clamp(round(_y), 0, sh - 1) * sw + clamp(round(_x), 0, sw - 1)) * 2, buffer_f16)};
    static getPixelF32 = function(_x,_y) /*=>*/ {return buffer_read_at(buffer, (clamp(round(_y), 0, sh - 1) * sw + clamp(round(_x), 0, sw - 1)) * 4, buffer_f32)};
    
    static getPixelU8  = function(_x,_y) /*=>*/ {return buffer_read_at(buffer, (clamp(round(_y), 0, sh - 1) * sw + clamp(round(_x), 0, sw - 1)) * 1, buffer_u8)};
    static getPixelU16 = function(_x,_y) /*=>*/ {return buffer_read_at(buffer, (clamp(round(_y), 0, sh - 1) * sw + clamp(round(_x), 0, sw - 1)) * 2, buffer_u16)};
    static getPixelU32 = function(_x,_y) /*=>*/ {return buffer_read_at(buffer, (clamp(round(_y), 0, sh - 1) * sw + clamp(round(_x), 0, sw - 1)) * 4, buffer_u32)};
    
    getPixel = getPixelU32;
    
    static free = function() {
        buffer_delete_safe(buffer);
    }
}