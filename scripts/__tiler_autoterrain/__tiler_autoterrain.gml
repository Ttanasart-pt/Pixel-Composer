enum AUTOTERRAIN_TYPE {
	box9,
	box25,
	side15,
	top48,
	top55,
}

global.autoterrain_amount = [ 9, 16, 15, 48, 55, ];

function tiler_brush_autoterrain(_type, _index) constructor {
	name  = "autoterrain";
    index = _index;
    
    mask_surface    = noone;
    update_surface  = noone;
    drawing_surface = noone;
    target_surface  = noone;
    eraseMode       = false;
    
    preview_surface      = noone;
    preview_surface_tile = noone;
    
    open = false;
    
    sc_type = new scrollBox(["Simple box (3x3)", "Corner box (5x5)", "Side platform (5x3)", "Godot tile (12x4)", "Gamemaker tileset (11x5)"], function(ind) /*=>*/ { setType(ind); });
    sc_type.font = f_p3;
    
    static indexMap48 = [ 8, 10, 11, 0, 1, 6, 5, 3, 2, 34, 12, 20, 33, 35, 12, 28, 30, 29, 31, 46, 21, 12, 44, 45, 47, 24, 16, 18, 17, 19, 9, 43, 40, 37, 38, 39, 36, 25, 42, 41, 27, 26, 7, 4, 13, 23, 32, 15, 14, 12 ];
    
    static setType = function(_type) {
    	type  = _type;
    	
    	switch(type) {
    		case 0 : index = array_verify_ext(index,  9, function() /*=>*/ {return -1}); break;
    		case 1 : index = array_verify_ext(index, 25, function() /*=>*/ {return -1}); break;
    		case 2 : index = array_verify_ext(index, 15, function() /*=>*/ {return -1}); break;
    		case 3 : index = array_verify_ext(index, 48, function() /*=>*/ {return -1}); break;
    		case 4 : index = array_verify_ext(index, 55, function() /*=>*/ {return -1}); break;
    	}
    	
    } setType(_type);
    
    static drawing_start = function(surface, _erase = false) {
        target_surface  = surface;
        eraseMode       = _erase;
        
        var _dim        = surface_get_dimension(surface);
        drawing_surface = surface_verify(drawing_surface, _dim[0], _dim[1], surface_r8unorm);
        
        //print($"Drawing start {surface} | {drawing_surface}");
        
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
        update_surface = surface_verify(update_surface, _dim[0], _dim[1], surface_rgba16float);
        
        // autoterrain mask
        // #000000 : not part of autoterrain
        // #808080 : part of autoterrain, read only
        // #FFFFFF : part of autoterrain, writable
        
        surface_set_shader(mask_surface, sh_tiler_autoterrain_mask); 
            shader_set_surface("drawSurface", drawing_surface);
            shader_set_i("indexes",   index);
            shader_set_i("indexSize", array_length(index));
            
            draw_surface(target_surface, 0, 0);
        surface_reset_shader();
        
        surface_set_shader(update_surface, sh_tiler_autoterrain_apply); 
            shader_set_2("dimension",    _dim);
            
            shader_set_surface("maskSurface", mask_surface);   
            shader_set_i("bitmaskType",   type);
            shader_set_i("indexMapper48", indexMap48);
            
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