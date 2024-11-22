enum FD_TARGET_TYPE {
    REPLACE_MATERIAL,
    ADD_MATERIAL,
    REPLACE_VELOCITY,
    ADD_VELOCITY,
}

enum FD_BOUNDARY_TYPE {
	empty,
	wall,
	wrap
}

function smokeSim_Domain(_width, _height) constructor {
    sf_world        = noone;
	sf_world_update = true;

    material_surface_was_created = false;
    
    acceleration_type = 0;
    acceleration_a    = 0;
    acceleration_b    = 0;
    acceleration_x    = 0;
    acceleration_y    = 0;
    
    time_step         = 1;
    
    initial_value_pressure     = 0.5;
    material_dissipation_type  = 0;
    material_dissipation_value = 1;
    
    velocity_dissipation_type  = 1;
    velocity_dissipation_value = 0;
    velocity_maccormack_weight = 0.5;
    material_maccormack_weight = 0;
    
    pressure_type  = -3;
    pressure_relax =  0;
    
    texture_repeat = false;
    texture_wall   = false;
    
    sf_world    = 0;
    sf_pressure = 0; sf_pressure_t = 0;
    sf_velocity = 0; sf_velocity_t = 0;
    sf_material = 0; sf_material_t = 0;
	
	max_force = 10;
	
    static setSize = function(_width, _height) {
        width     = _width;
    	height    = _height;
    	tx_width  = 1 / width;
        tx_height = 1 / height;
        verify();
        
        return self;
    } 
    
    static resetSize = function(_width, _height) {
        free();
        setSize(_width, _height);
        
        return self;
    }
    
    static verify = function() {
    	var _f = surface_rgba32float;
        if(!surface_valid(sf_pressure,   width, height, _f)) { sf_pressure   = surface_verify(sf_pressure,   width, height, _f); surface_clear(sf_pressure);   }
        if(!surface_valid(sf_pressure_t, width, height, _f)) { sf_pressure_t = surface_verify(sf_pressure_t, width, height, _f); surface_clear(sf_pressure_t); }
        
        if(!surface_valid(sf_velocity,   width, height, _f)) { sf_velocity   = surface_verify(sf_velocity,   width, height, _f); surface_clear(sf_velocity);   }
        if(!surface_valid(sf_velocity_t, width, height, _f)) { sf_velocity_t = surface_verify(sf_velocity_t, width, height, _f); surface_clear(sf_velocity_t); }
        
        if(!surface_valid(sf_material,   width, height, _f)) { sf_material   = surface_verify(sf_material,   width, height, _f); surface_clear(sf_material);   }
        if(!surface_valid(sf_material_t, width, height, _f)) { sf_material_t = surface_verify(sf_material_t, width, height, _f); surface_clear(sf_material_t); }
        
    	sf_world = surface_verify(sf_world, width, height, _f); 
	    if (sf_world_update) {
        	surface_set_target(sf_world);
                draw_clear_alpha(0, 0);
            surface_reset_target();
	        sf_world_update = false;
	    }
    }
    
    static setAcceleration = function(xacc, yacc, a = 0, b = 0) {
		acceleration_x = xacc;
		acceleration_y = yacc;

	    acceleration_a = a;
	    acceleration_b = b;
    	
        acceleration_type = 1;
	    if ((xacc == 0 && yacc == 0) || (acceleration_a == 0 && acceleration_b == 0))
	        acceleration_type = 0;
        
        return self;
    }
    
    static setMaterial = function(type, value) {
        material_dissipation_type  = type;
        material_dissipation_value = value;
        
        return self;
    }
    
    static setVelocity = function(type, value) {
        velocity_dissipation_type  = type;
        velocity_dissipation_value = value;
        
        return self;
    }
    
    static setMaccormack = function(vel, mat) {
        velocity_maccormack_weight = vel;
        material_maccormack_weight = mat;
        
        return self;
    }
    
    static setPressure = function(iteration) {
        pressure_type  = iteration;
        pressure_relax = 0;
        
	    if (iteration >= 0) return;
	    
        var i = 0, j = 0;
        
        switch (iteration) {
            case -1:
                for (j = 0; j <  1; ++j)  pressure_relax[i++] = j == 0? 32.6   : -1;  
                for (j = 0; j < 15; ++j)  pressure_relax[i++] = j == 0? 0.8630 : -1;
                break;
            
            case -2:
                for (j = 0; j <  1; ++j)  pressure_relax[i++] = j == 0? 81.22  : -1; 
                for (j = 0; j < 30; ++j)  pressure_relax[i++] = j == 0? 0.9178 : -1;
                break;
            
            case -3:
                for (j = 0; j <  1; ++j)  pressure_relax[i++] = j == 0? 190.2  : -1; 
                for (j = 0; j < 63; ++j)  pressure_relax[i++] = j == 0? 0.9532 : -1;
                break;
            
            case -4:
                for (j = 0; j <   1; ++j) pressure_relax[i++] = j == 0? 425.8  : -1; 
                for (j = 0; j < 130; ++j) pressure_relax[i++] = j == 0? 0.9742 : -1;
                break;
        }
    }
    
    static setBoundary = function(boundary) {
    	switch(boundary) {
    		case FD_BOUNDARY_TYPE.empty : 
    			texture_repeat = false;
    			texture_wall   = false;
    			break;
    			
    		case FD_BOUNDARY_TYPE.wall : 
    			texture_repeat = false;
    			texture_wall   = true;
    			break;
    			
    		case FD_BOUNDARY_TYPE.wrap : 
    			texture_repeat = true;
    			texture_wall   = false;
    			break;
    	}
    	
    	return self;
    }
    
    static addMaterial = function(surface, _x, _y, xscale, yscale, color, alpha) {
    	setTarget(FD_TARGET_TYPE.ADD_MATERIAL);
	        draw_surface_ext_safe(surface, _x, _y, xscale, yscale, 0, color, alpha);
	    resetTarget();
    }
    
    static addVelocity = function(surface, _x = 0, _y = 0, xscale = 1, yscale = 1, xvelo = 1, yvelo = 1) {
	    setTarget(FD_TARGET_TYPE.ADD_VELOCITY);
	    	shader_set(sh_fd_add_velocity);
	    	shader_set_f("velo", xvelo, yvelo);
	        draw_surface_ext_safe(surface, _x, _y, xscale, yscale);
	        shader_reset();
	    resetTarget();
    }
    
    static update = function() {
        updateVelocity();
	    updateMaterial();
    }
    
    static updateVelocity = function() {
        var temporary = noone;
		
	    gpu_set_texrepeat(texture_repeat);
	    gpu_set_texfilter(true);
	    gpu_set_blendenable(false);
        verify();
    	
        surface_set_target(sf_velocity_t);
            shader_set(sh_fd_advect_velocity);
            shader_set_surface("texture_world",    sf_world);
            shader_set_surface("texture_material", sf_material);
            shader_set_f("max_force",              max_force);
            shader_set_i("mode",                   acceleration_type);
            shader_set_i("repeat",                 texture_repeat);
            shader_set_i("wall",                   texture_wall);
            shader_set_f("precalculated",          time_step * tx_width, time_step * tx_height, tx_width, tx_height);
            shader_set_f("precalculated_1",        velocity_dissipation_type, velocity_dissipation_value, velocity_maccormack_weight * 0.5);
            shader_set_f("acceleration",           acceleration_x, acceleration_y, acceleration_a, acceleration_b);
            shader_set_f("texel_size",             tx_width, tx_height);
            
            draw_surface_safe(sf_velocity);
            shader_reset();
        surface_reset_target();
        
        temporary     = sf_velocity; 
        sf_velocity   = sf_velocity_t;
        sf_velocity_t = temporary;
        
        // Calculates divergence of velocity.
        surface_set_target(sf_pressure);
            shader_set(sh_fd_velocity_divergence);
            	shader_set_f("max_force",              max_force);
	            shader_set_i("repeat",                 texture_repeat);
	            shader_set_i("wall",                   texture_wall);
                shader_set_f("initial_value_pressure", initial_value_pressure);
                shader_set_f("texel_size",             tx_width, tx_height);
                draw_surface_safe(sf_velocity);
            shader_reset();
        surface_reset_target();
    
        shader_set(sh_fd_pressure_srj);
            shader_set_f("texel_size",       tx_width, tx_height);
            shader_set_f("max_force",        max_force);
            shader_set_i("repeat",           texture_repeat);
            shader_set_i("wall",             texture_wall);
            
            var length = array_length(pressure_relax);
            for (var i = 0; i < length; ++i) {
                if (pressure_relax[i] != -1) shader_set_f("precalculated", 1 - pressure_relax[i], 0.25 * pressure_relax[i]);
                surface_set_target(sf_pressure_t);
                    draw_surface_safe(sf_pressure);
                surface_reset_target();
                
                temporary     = sf_pressure; 
                sf_pressure   = sf_pressure_t; 
                sf_pressure_t = temporary;
            }
        shader_reset();
    	
        // Calculates the gradient of pressure and subtracts it from the velocity.
        surface_set_target(sf_velocity_t);
            shader_set(sh_fd_subtract_pressure_gradient);
                shader_set_surface("texture_pressure", sf_pressure);
                shader_set_f("texel_size",             tx_width, tx_height);
                shader_set_f("max_force",              max_force);
	            shader_set_i("repeat",                 texture_repeat);
	            shader_set_i("wall",                   texture_wall);
                draw_surface_safe(sf_velocity);
            shader_reset();
        surface_reset_target();
        
        temporary     = sf_velocity; 
        sf_velocity   = sf_velocity_t; 
        sf_velocity_t = temporary;
        
        gpu_set_blendenable(true);
    }
    
    static updateMaterial = function() {
        var temporary = noone;
        
	    gpu_set_texrepeat(texture_repeat);
	    gpu_set_texfilter(true);
	    gpu_set_blendenable(false);
        verify();
    
    	var _scale = .5;
    	
        surface_set_target(sf_material_t);
        shader_set(sh_fd_advect_material);
            shader_set_surface("texture_velocity", sf_velocity);
            shader_set_surface("texture_world",    sf_world);
            shader_set_i("repeat",                 texture_repeat);
            shader_set_i("wall",                   texture_wall);
            shader_set_f("max_force",              max_force);
            shader_set_f("texel_size",             tx_width, tx_height);
            shader_set_f("precalculated",          time_step * tx_width, time_step * tx_height);
            shader_set_f("precalculated_1",        tx_width * _scale, tx_height * _scale, -tx_width * _scale, -tx_height * _scale);
            shader_set_f("precalculated_2",        material_dissipation_type, material_dissipation_value, material_maccormack_weight * 0.5);
            draw_surface_safe(sf_material);
        shader_reset();
        surface_reset_target();
        
        temporary     = sf_material; 
        sf_material   = sf_material_t; 
        sf_material_t = temporary;
        
	    gpu_set_blendenable(true);
    }
    
    target_type = noone;
    static setTarget = function(type) {
        target_type = type;
        verify();
        
	    switch (type) {
	        case FD_TARGET_TYPE.REPLACE_MATERIAL: 
	            surface_set_target(sf_material); 
	            break;
            
	        case FD_TARGET_TYPE.ADD_MATERIAL:
	            surface_set_target(sf_material);
	            gpu_set_blendmode_ext(bm_one, bm_one);
	            break;
        
	        case FD_TARGET_TYPE.REPLACE_VELOCITY: 
	            surface_set_target(sf_velocity); 
	            break;
            
	        case FD_TARGET_TYPE.ADD_VELOCITY:
	            surface_set_target(sf_velocity);
	            gpu_set_blendmode_ext(bm_one, bm_one);
	            break;
	    }
    }
    
    static resetTarget = function() {
	    surface_reset_target();    
        BLEND_NORMAL 
    }
    
    static free = function() {
        surface_free_safe(sf_world);
        surface_free_safe(sf_pressure);
        surface_free_safe(sf_pressure_t);
        surface_free_safe(sf_velocity);
        surface_free_safe(sf_velocity_t);
        surface_free_safe(sf_material);
        surface_free_safe(sf_material_t);
    }
    
    setSize(_width, _height);
    setPressure(-3);
}