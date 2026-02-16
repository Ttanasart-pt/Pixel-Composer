function canvas_tool_shader() : canvas_tool() constructor {
	
	mask       = false;
	override   = true;
	mouse_init = false;
	
	mask_boundary_init = [ 0, 0, 1, 1 ];
	mask_boundary      = [ 0, 0, 1, 1 ];
	
	preview_surface = [ noone, noone ];
	
	////- Init
	
	static init = function() { mouse_init = true; }
	
	static onInit = function(hover, active, _x, _y, _s, _mx, _my) {}
	
	////- Step
	
	static stepEffect = function(     hover, active, _x, _y, _s, _mx, _my ) {}
	static stepMaskEffect = function( hover, active, _x, _y, _s, _mx, _my ) {}
	
	static step = function(hover, active, _x, _y, _s, _mx, _my) {
		if(mouse_press(mb_right)) { PANEL_PREVIEW.tool_current = noone; return; }
				
		var _dim  = node.attributes.dimension;
		var _sel  = node.selection;
		
		preview_surface[0] = surface_verify(preview_surface[0], _dim[0], _dim[1]);
		preview_surface[1] = surface_verify(preview_surface[1], _dim[0], _dim[1]);
		
		if(mouse_init) {
			mask = key_mod_press(SHIFT);
			mask_boundary_init = [ _sel.selection_position[0], _sel.selection_position[1], _sel.selection_size[0], _sel.selection_size[1] ];
			mask_boundary      = [ _sel.selection_position[0], _sel.selection_position[1], _sel.selection_size[0], _sel.selection_size[1] ];
			if(mask) _sel.apply();
			
			onInit(hover, active, _x, _y, _s, _mx, _my);
			mouse_init = false;
			return;
		}
		
		var _surf = mask? _sel.selection_mask : _sel.selection_surface;
		var _pos  = _sel.selection_position;
		
		surface_set_shader(preview_surface[0], noone);
			draw_surface(_surf, _pos[0], _pos[1]);
		surface_reset_shader();
		
		if(mask) {
			stepMaskEffect(hover, active, _x, _y, _s, _mx, _my);
			
			if(mouse_lrelease()) {
				var _newSurf = surface_create(mask_boundary[2], mask_boundary[3]);
				surface_set_shader(_newSurf, noone);
					draw_surface(preview_surface[1], -mask_boundary[0], -mask_boundary[1]);
				surface_reset_shader();
				
				_sel.createNewSelection(_newSurf, mask_boundary[0], mask_boundary[1], mask_boundary[2], mask_boundary[3]);
				
				PANEL_PREVIEW.tool_current = noone;
				MOUSE_BLOCK = true;
			}
			
		} else {
			stepEffect(hover, active, _x, _y, _s, _mx, _my);
			draw_surface_ext(preview_surface[1], _x, _y, _s, _s, 0, c_white, 1);
			
			if(mouse_lrelease()) {
				var _newSurf = surface_create(_dim[0], _dim[1]);
				surface_set_shader(_newSurf, noone);
					draw_surface(preview_surface[1], 0, 0);
				surface_reset_shader();
			
				surface_free(_sel.selection_surface);
				_sel.selection_surface  = _newSurf;
				_sel.selection_position = [ 0, 0 ];
				_sel.apply();
			
				surface_free(_surf);
			
				PANEL_PREVIEW.tool_current = noone;
				MOUSE_BLOCK = true;
			}
		}
	}
	
	////- Draw
	
	static drawMask = function(hover, active, _x, _y, _s, _mx, _my) {
		if(!mask) return;
		draw_surface_ext_safe(preview_surface[1], _x, _y, _s, _s);
	}
}