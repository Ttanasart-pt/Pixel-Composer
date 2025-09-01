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
    
    static free = function() /*=>*/ { buffer_delete_safe(buffer); }
}

function Surface_Sampler_Grey(s = noone, _rng = [0,1]) constructor {
    active = false;
    buffer = noone;
    range  = _rng;
    
    sw = 1;
    sh = 1;
        
    static setSurface = function(s) {
        if(buffer != noone) buffer_delete(buffer);
        
        buffer  = noone;
        active  = is_surface(s);
        if(!active) return;
        
        sw = surface_get_width(s);
        sh = surface_get_height(s);
        var _surf = surface_create(sw, sh, surface_r16float);
        
        surface_set_shader(_surf, sh_greyscale);
            shader_set_2("brightness",        [0,0]);
            shader_set_i("brightnessUseSurf",  0);
            
            shader_set_2("contrast",          [1,1]);
            shader_set_i("contrastUseSurf",    0);
            
            draw_surface(s,0,0);
        surface_reset_shader();
        
        buffer = buffer_create(sw * sh * 2, buffer_fixed, 1);
        buffer_get_surface(buffer, _surf, 0);
        
        surface_free(_surf);
    }
    
    setSurface(s);
    
    static getPixel = function(_u,_v) /*=>*/ {
        if(!active) return range[0];
        var _x = round(clamp(_u, 0, 1) * (sw - 1));
        var _y = round(clamp(_v, 0, 1) * (sh - 1));
        
        return lerp(range[0], range[1], buffer_read_at(buffer, (_y * sw + _x) * 2, buffer_f16));
    }
    
    static free = function() /*=>*/ { buffer_delete_safe(buffer); }
}