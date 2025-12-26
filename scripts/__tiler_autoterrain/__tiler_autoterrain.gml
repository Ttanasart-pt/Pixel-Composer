enum AUTOTERRAIN_TYPE {
	box9,
	box25,
	side15,
	top48,
	top55,
}

global.autoterrain_amount = [ 9, 16, 15, 48, 55, ];

function tiler_brush_autoterrain() constructor {
	name    = "autoterrain";
    type    = -1;
    index   = [];
    size    = [1,1];
    prevInd =  0;
    
    mask_surface      = noone;
    update_surface    = noone;
    draw_surface_mask = noone;
    target_surface    = noone;
    eraseMode         = false;
    
    preview_surface      = noone;
    preview_surface_tile = noone;
    
    open = false;
    
    sc_type = new scrollBox(["Simple box (3x3)", "Corner box (5x5)", "Side platform (5x3)", "Godot tile (12x4)", "Gamemaker tileset (11x5)"], function(ind) /*=>*/ { setType(ind); }, false)
    	.setFont(f_p3);
    
    static indexMap48 = [ 
    	 8, 10, 11,  0, /**/  1,  6,  5,  3, /**/  2, 34, 22,
    	20, 33, 35, 12, /**/ 28, 30, 29, 31, /**/ 46, 21, 22,    
    	44, 45, 47, 24, /**/ 16, 18, 17, 19, /**/  9, 43, 40, 
    	37, 38, 39, 36, /**/ 25, 42, 41, 27, /**/ 26,  7,  4, 
    	22, 22, 22, 22, /**/ 13, 23, 32, 15, /**/ 14, 22, 22 ];
    
    static indexMapOld = [
    	[ 0,  1,  2, 
    	 11, 12, 13, 
    	 22, 23, 24 ], 
    	 
    	[-1,  0,  1,  2, -1, 
    	  0, 28, 12, 27,  2, 
    	 11, 12, 12, 12, 13, 
    	 22, 17, 12, 16, 24, 
    	 -1, 22, 23, 24, -1 ], 
    	 
    	[ 0,  1,  2, 16, 17, 
    	 11, 12, 13, 27, 28, 
    	 22, 23, 24,  9, 20 ],
    	 
    	[ 3,  4,  8,  7, 43,  6,  5, 42,  0, 30,  1,  2,
    	 14, 48, 52, 51, 26, 28, 27, 29, 11, 20, -1, 49, 
    	 25, 37, 41, 40, 15, 17, 16, 18, 50, 12,  9, 13, 
    	 36, 33, 34, 35, 32, 39, 38, 31, 22, 23, 19, 24, ],
    	 
    	array_create_ext(55, function(i) /*=>*/ {return i}),
	];
    
    static init = function(_index, _type) {
    	index = _index;
    	type  = _type;
    	
    	switch(_type) {
    		case 0 : prevInd = 0; size = [ 3, 3]; break;
    		case 1 : prevInd = 1; size = [ 5, 5]; break;
    		case 2 : prevInd = 0; size = [ 5, 3]; break;
    		case 3 : prevInd = 8; size = [12, 4]; break;
    		case 4 : prevInd = 0; size = [11, 5]; break;
    	}
    	
    	return self;
    }
    
    static setType = function(_type) {
    	if(type == _type) return;
    	
    	if(type != -1) {
	    	var _idMap = array_create(55, -1);
	    	var _mapol = indexMapOld[ type];
	    	var _mapnw = indexMapOld[_type];
	    	
	    	for( var i = 0, n = array_length(index); i < n; i++ ) {
	    		if(_mapol[i] != -1) _idMap[_mapol[i]] = index[i];
	    	}
    	}
    	
    	switch(_type) {
    		case 0 : index = array_verify_ext(index,  9, function() /*=>*/ {return -1}); prevInd = 0; size = [ 3, 3]; break;
    		case 1 : index = array_verify_ext(index, 25, function() /*=>*/ {return -1}); prevInd = 1; size = [ 5, 5]; break;
    		case 2 : index = array_verify_ext(index, 15, function() /*=>*/ {return -1}); prevInd = 0; size = [ 5, 3]; break;
    		case 3 : index = array_verify_ext(index, 48, function() /*=>*/ {return -1}); prevInd = 8; size = [12, 4]; break;
    		case 4 : index = array_verify_ext(index, 55, function() /*=>*/ {return -1}); prevInd = 0; size = [11, 5]; break;
    	}
    	
    	if(type != -1) {
	    	for( var i = 0, n = array_length(index); i < n; i++ ) {
	    		if(_mapnw[i] != -1) index[i] = _idMap[_mapnw[i]];
	    		else index[i] = -1;
	    	}
    	}
    	
    	type = _type;
    } 
    
    static drawing_start = function(surface, _erase = false) {
        target_surface    = surface;
        eraseMode         = _erase;
        
        var _dim          = surface_get_dimension(surface);
        draw_surface_mask = surface_verify(draw_surface_mask, _dim[0], _dim[1], surface_r8unorm);
        mask_surface      = surface_verify(mask_surface,      _dim[0], _dim[1], surface_r8unorm);
        update_surface    = surface_verify(update_surface,    _dim[0], _dim[1], surface_rgba16float);
        
        surface_clear(draw_surface_mask);
        surface_clear(mask_surface);
        surface_clear(update_surface);
        
        draw_set_color(c_white);
        surface_set_target(draw_surface_mask);
        DRAW_CLEAR
    }
    
    static drawing_end = function() {
        surface_reset_target();
        
        // autoterrain mask
        // #000000 : not part of autoterrain
        // #808080 : part of autoterrain, read only
        // #FFFFFF : part of autoterrain, writable
        
        surface_set_shader(mask_surface, sh_tiler_autoterrain_mask); 
            shader_set_s("drawSurface", draw_surface_mask);
            shader_set_i("indexes",     index);
            shader_set_i("indexSize",   array_length(index));
            
            draw_surface(target_surface, 0, 0);
        surface_reset_shader();
        
        surface_set_shader(update_surface, sh_tiler_autoterrain_apply); 
            shader_set_2("dimension",    surface_get_dimension(update_surface));
            
            shader_set_s("maskSurface",   mask_surface);   
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
    
    ////- Serialize
    
    static serialize = function() {
    	var m = {
    		name, 
    		index, 
    		type, 
    	};
    	
    	return m;
    }
    
    static deserialize = function(m) {
    	name  = m[$ "name"]  ?? name;
    	index = m[$ "index"] ?? index;
    	type  = m[$ "type"]  ?? type;
    	
    	return self;
    }
}