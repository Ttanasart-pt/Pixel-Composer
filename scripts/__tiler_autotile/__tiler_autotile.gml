enum AUTOTILE_TYPE {
	box9,
	side15,
	top48,
}

function tiler_brush_autotile(_type, _index) constructor {
    type  = _type;
    index = _index;
    
    mask_surface    = noone;
    update_surface  = noone;
    drawing_surface = noone;
    target_surface  = noone;
    eraseMode       = false;
    bitmask = [];
    
    switch(type) {
        case AUTOTILE_TYPE.box9 : 
            // - 1 - | 0 1 2 
            // 2 x 4 | 3 4 5 
            // - 8 - | 6 7 8
            
            bitmask      = [ 4, 
                /* 1 */ 7, 
                /* 2 */ 5, 8, 
                /* 4 */ 3, 6, 4, 7, 
                /* 8 */ 1, 4, 2, 5, 0, 3, 1, 4, 
            ];
            break;
    }
    
    static drawing_start = function(surface, _erase = false) {
        target_surface  = surface;
        eraseMode       = _erase;
        
        var _dim        = surface_get_dimension(surface);
        drawing_surface = surface_verify(drawing_surface, _dim[0], _dim[1], surface_r8unorm);
        
        draw_set_color(c_white);
        surface_set_target(drawing_surface);
        DRAW_CLEAR
    }
    
    static drawing_end = function() {
        surface_reset_target();
        apply_drawing();
    }
    
    static apply_drawing = function() {
        var _dim = surface_get_dimension(target_surface);
        mask_surface   = surface_verify(mask_surface,   _dim[0], _dim[1], surface_r8unorm);
        update_surface = surface_verify(update_surface, _dim[0], _dim[1], surface_r16float);
        
        // autotile mask
        // #000000 : not part of autotile
        // #808080 : part of autotile, read only
        // #FFFFFF : part of autotile, writable
        
        surface_set_shader(mask_surface, sh_tiler_autotile_mask); 
            shader_set_surface("drawSurface", drawing_surface);
            shader_set_i("indexes",   index);
            shader_set_i("indexSize", array_length(index));
            
            draw_surface(target_surface, 0, 0);
        surface_reset_shader();
        
        surface_set_shader(update_surface, sh_tiler_autotile_apply); 
            shader_set_2("dimension",    _dim);
            
            shader_set_surface("maskSurface", mask_surface);   
            shader_set_i("bitmask",      bitmask);
            shader_set_i("bitmaskSize",  array_length(bitmask));
            shader_set_i("bitmaskType",  type);
            
            shader_set_i("indexes",   index);
            shader_set_i("indexSize", array_length(index));
            shader_set_i("erase",     eraseMode);
            
            draw_surface(target_surface, 0, 0);
        surface_reset_shader();
        
        surface_set_target(target_surface);
            DRAW_CLEAR
            
            BLEND_OVERRIDE
            draw_surface(update_surface, 0, 0);
            BLEND_NORMAL
        surface_reset_target();
    }
}