function canvas_tool_shader() : canvas_tool() constructor {
	
	override   = true;
	mouse_init = false;
	
	preview_surface = [ noone, noone ];
	
	function init() { mouse_init = true; }
	
	function onInit(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	function stepEffect(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _dim  = node.attributes.dimension;
		var _sel  = node.tool_selection;
		
		var _surf = _sel.selection_surface;
		var _pos  = _sel.selection_position;
		
		preview_surface[0] = surface_verify(preview_surface[0], _dim[0], _dim[1]);
		preview_surface[1] = surface_verify(preview_surface[1], _dim[0], _dim[1]);
		
		if(mouse_init) {
			onInit(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			mouse_init = false;
			return;
		}
		
		surface_set_shader(preview_surface[0], noone);
			draw_surface(_surf, _pos[0], _pos[1]);
		surface_reset_shader();
		
		stepEffect(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_surface_ext(preview_surface[1], _x, _y, _s, _s, 0, c_white, 1);
		
		if(mouse_press(mb_right)) {
			PANEL_PREVIEW.tool_current = noone;
			
		} else if(mouse_release(mb_left)) {
			
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