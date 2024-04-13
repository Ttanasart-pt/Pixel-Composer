function canvas_tool_outline() : canvas_tool_shader() constructor {
	
	mouse_sx   = 0;
	
	function init() { mouse_init = true; }
	
	function onInit(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_sx   = _mx;
	}
	
	function stepEffect(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _dim  = node.attributes.dimension;
		
		var _thck = abs(round((_mx - mouse_sx) / _s));
		var _side = _mx > mouse_sx;
		
		surface_set_shader(preview_surface[1], sh_outline);
			
			shader_set_f("dimension",      _dim);
			shader_set_f("borderSize",     _thck, _thck);
			shader_set_f("borderStart",    0, 0);
			shader_set_i("side",           _side);
			shader_set_color("borderColor", node.tool_attribute.color);
			
			draw_surface(preview_surface[0], 0, 0);
		surface_reset_shader();
	}
	
}