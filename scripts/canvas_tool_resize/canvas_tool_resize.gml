function canvas_tool_resize(_node) : canvas_tool() constructor {
	node = _node;
	
	override  = true;
	points    = [ 0, 0, 0, 0 ];
	dimension = [ 1, 1 ];
	
	drag_points = [ 0, 0, 0, 0 ];
	dragging = -1;
	drag_mx  = 0;
	drag_my  = 0;
	drag_sw  = 0;
	drag_sh  = 0;
	
	__hover_anim = array_create(4);
	overlay_surface = noone;
	
	function init()   { 
		if(node.attributes.useBGDim) {
			noti_warning($"Canvas: Cannot resize canvas with 'Use Background Dimension' on.")
			cancel();
			return;
		}
		
		var _sw = node.attributes.dimension[0];
		var _sh = node.attributes.dimension[1];
		
		points    = [ 0, 0, _sw, _sh ];
		dimension = [ _sw, _sh ];
	}
	
	function apply()  { 
		applySize(); 
		disable(); 
		
		var p = PANEL_PREVIEW;
		p.canvas_x += points[0] * p.canvas_s;
		p.canvas_y += points[1] * p.canvas_s;
	}
	
	function cancel() { disable(); }
	
	function applySize() {
		var x0 = points[0];
		var y0 = points[1];
		var x1 = points[2];
		var y1 = points[3];
		
		var _sw = x1 - x0;
		var _sh = y1 - y0;
		if(_sw <= 0 || _sh <= 0) return;
		
		node.storeAction();
		node.attributes.dimension = [ _sw, _sh ];
		
		for( var i = 0; i < node.attributes.frames; i++ ) {
			var _canvas_surface = node.getCanvasSurface(i);
			
			var _cbuff = array_safe_get_fast(node.canvas_buffer, i);
			if(buffer_exists(_cbuff)) buffer_delete(_cbuff);

			node.canvas_buffer[i] = buffer_create(_sw * _sh * 4, buffer_fixed, 4);
			
			var _newCanvas = surface_create(_sw, _sh);
			
			surface_set_shader(_newCanvas, noone, true, BLEND.over);
				draw_surface(_canvas_surface, -x0, -y0);
			surface_reset_shader();
			
			node.setCanvasSurface(_newCanvas, i);
			surface_free(_canvas_surface);
		}
		
		node.inputs[0].setValue([_sw, _sh]);
		node.triggerRender();
	}
	
	function setAnchor(a) {
		var _r = floor(a / 3);
		var _c =      (a % 3);
		
		var x0 = points[0];
		var y0 = points[1];
		var x1 = points[2];
		var y1 = points[3];
		
		var _sw = x1 - x0;
		var _sh = y1 - y0;
		
		var _ow = node.attributes.dimension[0];
		var _oh = node.attributes.dimension[1];
		
		switch(_r) {
			case 0 : 
				var _dy = -y0;
				points[1] += _dy;
				points[3] += _dy;
				break;
			
			case 1 : 
				var _dy = round((_oh / 2) - (y0 + y1) / 2);
				points[1] += _dy;
				points[3] += _dy;
				break;
			
			case 2 : 
				var _dy = _oh - y1;
				points[1] += _dy;
				points[3] += _dy;
				break;
			
		}
		
		switch(_c) {
			case 0 : 
				var _dx = -x0;
				points[0] += _dx;
				points[2] += _dx;
				break;
			
			case 1 : 
				var _dx = round((_ow / 2) - (x0 + x1) / 2);
				points[0] += _dx;
				points[2] += _dx;
				break;
			
			case 2 : 
				var _dx = _ow - x1;
				points[0] += _dx;
				points[2] += _dx;
				break;
			
		}
	}
	
	function setSize(_s, i) {
		dimension[i] = _s;
		
		points[2] = points[0] + dimension[0];
		points[3] = points[1] + dimension[1];
	}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _sw = points[2] - points[0];
		var _sh = points[3] - points[1];
		var x0, y0, x1, y1;
		
		x0 = _x + points[0] * _s;
		y0 = _y + points[1] * _s;
		x1 = _x + points[2] * _s;
		y1 = _y + points[3] * _s;
		
		var _r = ui(10);
		
		var _sr  = surface_get_target();
		var _srw = surface_get_width(_sr);
		var _srh = surface_get_height(_sr);
		
		overlay_surface = surface_verify(overlay_surface, _srw, _srh);
		surface_set_target(overlay_surface);
			draw_clear_alpha(0, 0.3);
			
			BLEND_SUBTRACT
				draw_set_color(c_white);
				draw_rectangle(x0, y0, x1, y1, false);
			BLEND_NORMAL
		surface_reset_target();
		
		draw_surface_safe(overlay_surface);
		
		draw_set_color(c_black);
		draw_rectangle(x0, y0, x1, y1, true);
		
		var _hovering = -1;
		
		     if(point_in_circle(_mx, _my, x0, y0, _r))        _hovering = 0;
		else if(point_in_circle(_mx, _my, x1, y0, _r))        _hovering = 1;
		else if(point_in_circle(_mx, _my, x0, y1, _r))        _hovering = 2;
		else if(point_in_circle(_mx, _my, x1, y1, _r))        _hovering = 3;
		else if(point_in_rectangle(_mx, _my, x0, y0, x1, y1)) _hovering = 9;
		
		for( var i = 0; i < 4; i++ ) __hover_anim[i] = lerp_float(__hover_anim[i], i == _hovering, 4);
		
		if(_hovering == 9 || dragging == 9) {
			draw_set_color(COLORS._main_accent);
			draw_rectangle(x0, y0, x1, y1, true);
			
		} else {
			draw_set_color(c_white);
			draw_rectangle_dashed(x0, y0, x1, y1, true, 6, current_time / 100);
		}
		
		draw_anchor(__hover_anim[0], x0, y0, _r);
		draw_anchor(__hover_anim[1], x1, y0, _r);
		draw_anchor(__hover_anim[2], x0, y1, _r);
		draw_anchor(__hover_anim[3], x1, y1, _r);
		
		if(dragging >= 0) {
			var _dx = (_mx - drag_mx) / _s;
			var _dy = (_my - drag_my) / _s;
			
			if(key_mod_press(SHIFT)) _dy = _dx * (drag_sh / drag_sw);
			
			_dx = round(_dx);
			_dy = round(_dy);
			
			switch(dragging) {
				case 0 : 
					points[0] = drag_points[0] + _dx;
					points[1] = drag_points[1] + _dy;
					break;
					
				case 1 : 
					points[2] = drag_points[2] + _dx;
					points[1] = drag_points[1] + _dy;
					break;
					
				case 2 : 
					points[0] = drag_points[0] + _dx;
					points[3] = drag_points[3] + _dy; 
					break;
					
				case 3 : 
					points[2] = drag_points[2] + _dx;
					points[3] = drag_points[3] + _dy;
					break;
					
				case 9 : 
					points[0] = drag_points[0] + _dx;
					points[1] = drag_points[1] + _dy;
					points[2] = drag_points[2] + _dx;
					points[3] = drag_points[3] + _dy;
					break;
			}
			
			if(mouse_release(mb_left))
				dragging = -1;
			
		} else if(_hovering >= 0 && mouse_click(mb_left, active)) {
			drag_points = array_clone(points);
			dragging    = _hovering;
			
			drag_mx = _mx;
			drag_my = _my;
			drag_sw = _sw;
			drag_sh = _sh;
		}
		
		dimension[0] = _sw;
		dimension[1] = _sh;
		
		     if(KEYBOARD_ENTER)  apply();
		else if(keyboard_check_pressed(vk_escape)) cancel();
	}
	
}