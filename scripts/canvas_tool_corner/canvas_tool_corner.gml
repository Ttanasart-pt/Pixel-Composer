function canvas_tool_corner() : canvas_tool_shader() constructor {
	
	mouse_sx = 0;
	mouse_sy = 0;
	
	modifying = false;
	amount    = 0;
	
	function init() { mouse_init = true; }
	
	function onInit(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_sx   = _mx;
		mouse_sy   = _my;
	}
	
	function stepEffect(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		modifying = true;
		var _dim = node.attributes.dimension;
		var _suf = node.getCanvasSurface();
		
		var _dx  = (_mx - mouse_sx) / _s / 4;
		amount   = clamp(round(_dx), 0, 3);
		
		surface_set_shader(preview_surface[1], sh_canvas_corner);
			
			shader_set_f("dimension",  _dim);
			shader_set_f("amount",     amount);
			shader_set_surface("base", _suf);
			
			draw_surface(preview_surface[0], 0, 0);
		surface_reset_shader();
		
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!modifying) return;
		
		var _x0 = mouse_sx;
		var _y0 = mouse_sy;
		
		var _x1 = _x0 + amount * _s * 4;
		
		draw_set_color(COLORS._main_accent);
		draw_line(_x0, _y0, _x1, _y0);
		
		draw_circle(_x1, _y0, 5, false);
		
	}
}