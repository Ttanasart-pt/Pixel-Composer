function Surface_sampler(s = noone) constructor {
    active  = false;
    surface = noone;
    buffer  = noone;
    
    sw = 1;
    sh = 1;
        
    static setSurface = function(s) {
        if(buffer != noone) buffer_delete(buffer);
        
        surface = s;
        buffer  = noone;
        active  = is_surface(surface);
        if(!active) return;
        
        sw      = surface_get_width(surface);
        sh      = surface_get_height(surface);
        buffer  = buffer_create(sw * sh * 4, buffer_fixed, 1);
        buffer_get_surface(buffer, surface, 0);
    }
    
    setSurface(s);
    
    static getPixel = function(_x, _y) { return buffer_read_at(buffer, (clamp(round(_y), 0, sh - 1) * sw + clamp(round(_x), 0, sw - 1)) * 4, buffer_u32); }
    
    static free = function() {
        buffer_delete_safe(buffer);
    }
}