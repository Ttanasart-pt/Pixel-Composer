function canvas_tool_skew() : canvas_tool_shader() constructor {
	
	mouse_sx = 0;
	mouse_sy = 0;
	
	skew_bbox = [ 0, 0, 0, 0 ];
	skew_ax  = 0;
	skew_inv = 0;
	skew_x   = 0;
	skew_y   = 0;
	skew_w   = 1;
	skew_h   = 1;
	
	__overlay_hover = [ 0, 0, 0, 0 ];
	
	function init() { mouse_init = true; }
	
	function onInit(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _sel = node.tool_selection;
		if(!_sel.is_selected) {
			PANEL_PREVIEW.tool_current = noone;
			return;
		}
		
		skew_bbox = [
			_sel.selection_position[0],
			_sel.selection_position[1],
			_sel.selection_position[0] + _sel.selection_size[0],
			_sel.selection_position[1] + _sel.selection_size[1],	
		];
		
		skew_w   = _sel.selection_size[0];
		skew_h   = _sel.selection_size[1];
		
		doForceStep = true;
	}
	
	function forceStep(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var x0 = _x + skew_bbox[0] * _s;
		var y0 = _y + skew_bbox[1] * _s;
		var x1 = _x + skew_bbox[2] * _s;
		var y1 = _y + skew_bbox[3] * _s;
		
		var xc = (x0 + x1) / 2;
		var yc = (y0 + y1) / 2;
		
		draw_surface_ext(preview_surface[0], _x, _y, _s, _s, 0, c_white, 1);
		
		draw_set_color(COLORS._main_accent);
		draw_rectangle_border(x0, y0, x1, y1, 1);
		
		var _hov_ax = noone;
		
		if(hover) {
				 if(distance_to_line(_mx, _my, x0, y0, x1, y0) < 16) _hov_ax = 0;
			else if(distance_to_line(_mx, _my, x0, y1, x1, y1) < 16) _hov_ax = 1;
			else if(distance_to_line(_mx, _my, x0, y0, x0, y1) < 16) _hov_ax = 2;
			else if(distance_to_line(_mx, _my, x1, y0, x1, y1) < 16) _hov_ax = 3;
		}
		
		switch(_hov_ax) {
			case 0 : draw_line_width(x0, y0, x1, y0, 4); break;
			case 1 : draw_line_width(x0, y1, x1, y1, 4); break;
			case 2 : draw_line_width(x0, y0, x0, y1, 4); break;
			case 3 : draw_line_width(x1, y0, x1, y1, 4); break;
		}
		
		for(var i = 0; i < 4; i++) __overlay_hover[i] = lerp_float(__overlay_hover[i], i == _hov_ax, 3);
		
		draw_anchor_line(__overlay_hover[0], xc, y0, 16,  0);
		draw_anchor_line(__overlay_hover[1], xc, y1, 16,  0);
		draw_anchor_line(__overlay_hover[2], x0, yc, 16, 90);
		draw_anchor_line(__overlay_hover[3], x1, yc, 16, 90);
		
		if(_hov_ax != noone && mouse_press(mb_left, active)) {
			doForceStep = false;
			
			mouse_sx  = _mx;
			mouse_sy  = _my;
			skew_inv  = 0;
			skew_x    = 0;
			skew_y    = 0;
			
			switch(_hov_ax) {
				case 0 : skew_ax = 0; skew_y = skew_bbox[3]; skew_inv = 1; break;
				case 1 : skew_ax = 0; skew_y = skew_bbox[1]; skew_inv = 0; break;
				case 2 : skew_ax = 1; skew_x = skew_bbox[2]; skew_inv = 1; break;
				case 3 : skew_ax = 1; skew_x = skew_bbox[0]; skew_inv = 0; break;
			}
		}
	}
	
	function stepEffect(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _dim  = node.attributes.dimension;
		
		var _dx  = (_mx - mouse_sx) / _s;
		var _dy  = (_my - mouse_sy) / _s;
		var _amo = skew_ax? _dy / skew_h : _dx / skew_w;
		
		if(abs(_amo) > 1)  _amo = round(_amo);
		else if(_amo != 0) _amo = 1 / ceil(1 / abs(_amo)) * sign(_amo);
		if(skew_inv) _amo = -_amo;
		
		surface_set_shader(preview_surface[1], sh_canvas_skew);
			
			shader_set_f("dimension", _dim);
			shader_set_f("origin",    skew_x, skew_y);
			shader_set_i("axis",      skew_ax);
			shader_set_f("amount",    _amo);
			
			shader_set_color("color", CURRENT_COLOR);
			
			draw_surface_safe(preview_surface[0]);
		surface_reset_shader();
		
	}
}