function canvas_tool_outline() : canvas_tool_shader() constructor {
	
	mouse_sx = 0;
	
	////- Init
	
	static init = function() { mouse_init = true; }
	
	static onInit = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_sx = _mx;
	}
	
	////- Step
	
	static stepEffect = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _dim  = node.attributes.dimension;
		
		var _thck = abs(round((_mx - mouse_sx) / _s));
		var _side = _mx > mouse_sx;
		
		surface_set_shader(preview_surface[1], sh_canvas_outline);
			
			shader_set_f("dimension", _dim);
			shader_set_f("thick",     _thck);
			shader_set_i("side",      _side);
			shader_set_color("borderColor", CURRENT_COLOR);
			
			draw_surface_safe(preview_surface[0]);
		surface_reset_shader();
	}
	
	static stepMaskEffect = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _dim  = node.attributes.dimension;
		
		var _thck = abs(round((_mx - mouse_sx) / _s));
		var _side = _mx > mouse_sx;
		
		if(_side) {
			surface_set_shader(preview_surface[1], sh_canvas_outline);
			
				shader_set_f("dimension", _dim);
				shader_set_f("thick",     _thck);
				shader_set_i("side",      _side);
				shader_set_color("borderColor", c_white);
			
				draw_surface_safe(preview_surface[0]);
			surface_reset_shader();
			
			mask_boundary[0] = mask_boundary_init[0] - _thck;
			mask_boundary[1] = mask_boundary_init[1] - _thck;
			mask_boundary[2] = mask_boundary_init[2] + _thck * 2;
			mask_boundary[3] = mask_boundary_init[3] + _thck * 2;
			
		} else {
			surface_set_shader(preview_surface[1], sh_erode);
			
				shader_set_f("dimension", _dim);
				shader_set_f("size",      _thck, _thck);
				shader_set_i("border",     0);
				shader_set_i("alpha",      1);
				
				draw_surface_safe(preview_surface[0]);
			surface_reset_shader();
			
			mask_boundary[0] = mask_boundary_init[0] + _thck;
			mask_boundary[1] = mask_boundary_init[1] + _thck;
			mask_boundary[2] = mask_boundary_init[2] - _thck * 2;
			mask_boundary[3] = mask_boundary_init[3] - _thck * 2;
			
		}
		
	}
	
}