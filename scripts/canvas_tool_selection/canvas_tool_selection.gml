function canvas_selection() : canvas_tool() constructor {
	selection_surface	= noone;
	selection_mask		= noone;
	selection_position	= [ 0, 0 ];
	selection_size   	= [ 0, 0 ];
	selection_hovering  = false;
	selection_sampler   = new Surface_Sampler_Grey();
	
	is_selected    = false;
	is_select_drag = false;
	
	selection_sx = 0; selection_sy = 0;
	selection_mx = 0; selection_my = 0;
	
	mouse_cur_x  = 0; mouse_cur_y  = 0;
	
	function init() {
		is_select_drag = false;
	}
	
	////- Create Selection
	
	function createSelection(_mask, sel_x0, sel_y0, sel_w, sel_h) {
		if(!is_selected) { 
			createNewSelection(_mask, sel_x0, sel_y0, sel_w, sel_h); 
			selection_sampler.setSurface(selection_mask);
			return; 
		}
		
		apply();
		
		     if(key_mod_press(SHIFT)) modifySelection(_mask, sel_x0, sel_y0, sel_w, sel_h, true);
		else if(key_mod_press(ALT))   modifySelection(_mask, sel_x0, sel_y0, sel_w, sel_h, false);
		else                          createNewSelection(_mask, sel_x0, sel_y0, sel_w, sel_h);
		
		selection_sampler.setSurface(selection_mask);
	}
	
	function createSelectionFromSurface(surface, sel_x0 = 0, sel_y0 = 0) {
		if(!surface_exists(surface)) return;
		
		var sel_w = surface_get_width(surface);
		var sel_h = surface_get_height(surface);
		
		selection_surface = surface_verify(selection_surface, sel_w, sel_h);
		selection_mask    = surface_verify(selection_mask,    sel_w, sel_h);
		
		surface_set_shader(selection_surface, noone, true, BLEND.over);
			draw_surface_safe(surface);
		surface_reset_shader();
		
		surface_set_shader(selection_mask, noone, true, BLEND.over);
			draw_clear(c_white)
			// draw_surface_safe(surface);
		surface_reset_shader();
		
		selection_position = [ sel_x0, sel_y0 ];
		selection_size     = [ sel_w,  sel_h  ];
		is_selected        = true;
	}
	
	function createNewSelection(_mask, sel_x0, sel_y0, sel_w, sel_h) {
		if(sel_w == 1 && sel_h == 1) return;
		
		selection_surface = surface_verify(selection_surface, sel_w, sel_h);
		selection_mask    = surface_verify(selection_mask,    sel_w, sel_h);
		
		surface_set_shader(selection_surface, noone, true, BLEND.over);
			draw_surface_safe(canvas_surface, -sel_x0, -sel_y0);
			BLEND_MULTIPLY
			draw_surface_safe(_mask);
		surface_reset_shader();
		
		surface_set_shader(selection_mask, noone, true, BLEND.normal);
			draw_surface_safe(_mask);
		surface_reset_shader();
		
		node.storeAction();
		surface_set_target(canvas_surface);
			BLEND_SUBTRACT
			draw_surface_safe(_mask, sel_x0, sel_y0);
			BLEND_NORMAL
		surface_reset_target();
		node.surface_store_buffer();
						
		selection_position = [ sel_x0, sel_y0 ];
		selection_size     = [ sel_w,  sel_h  ];
		is_selected = true;
	}
	
	function modifySelection(_mask, sel_x0, sel_y0, sel_w, sel_h, _add) {
		if(sel_w == 1 && sel_h == 1) return;
		
		var _x0, _y0, _x1, _y1;
		
		if(_add) {
			_x0 = min(sel_x0,         selection_position[0]);
			_y0 = min(sel_y0,         selection_position[1]);
			_x1 = max(sel_x0 + sel_w, selection_position[0] + selection_size[0]);
			_y1 = max(sel_y0 + sel_h, selection_position[1] + selection_size[1]);
			
		} else {
			var __nx0 = sel_x0;
			var __ny0 = sel_y0;
			var __nx1 = sel_x0 + sel_w;
			var __ny1 = sel_y0 + sel_h;
			
			_x0 = selection_position[0];
			_y0 = selection_position[1];
			_x1 = selection_position[0] + selection_size[0];
			_y1 = selection_position[1] + selection_size[1];
			
			if(__nx0 <= _x0 && __nx1 >= _x1) {
				if(__ny0 <= _y0) _y0 = max(_y0, __ny1);
				if(__ny1 >= _y1) _y1 = min(_y1, __ny0);
			}
			
			if(__ny0 <= _y0 && __ny1 >= _y1) {
				if(__nx0 <= _x0) _x0 = max(_x0, __nx1);
				if(__nx1 >= _x1) _x1 = min(_x1, __nx0);
			}
		}
		
		if(_x1 - _x0 <= 0 || _y1 - _y0 <= 0) return;
		
		var _ox = selection_position[0] - _x0;
		var _oy = selection_position[1] - _y0;
		
		var _nx = sel_x0 - _x0;
		var _ny = sel_y0 - _y0;
		
		var _nw = _x1 - _x0;
		var _nh = _y1 - _y0;
		
		var _selection_mask = surface_create(_nw, _nh);
		
		surface_set_shader(_selection_mask, noone, true, BLEND.over);
			draw_surface_safe(selection_mask, _ox, _oy);
			
			if(_add) BLEND_ADD
			else     BLEND_SUBTRACT
			
			draw_surface_safe(_mask, _nx, _ny);
		surface_reset_shader();
		
		createNewSelection(_selection_mask, _x0, _y0, _nw, _nh);
		surface_free(_selection_mask);
	}
	
	function selectAll() {
		var sel_w = surface_get_width(canvas_surface);
		var sel_h = surface_get_height(canvas_surface);
		
		selection_surface = surface_verify(selection_surface, sel_w, sel_h);
		selection_mask    = surface_verify(selection_mask,    sel_w, sel_h);
		
		surface_set_shader(selection_surface, noone, true, BLEND.over);
			draw_surface_safe(canvas_surface);
		surface_reset_shader();
		
		surface_clear(selection_mask, c_white, 1);
		
		node.storeAction();
		surface_clear(canvas_surface);
						
		node.surface_store_buffer();
						
		selection_position = [ 0, 0 ];
		selection_size     = [ sel_w,  sel_h  ];
		is_selected = true;
	}
	
	////- Step
	
	function apply(targetSurface = canvas_surface) {
		var _drawLay = node.tool_attribute.drawLayer;
		var _sw = surface_get_width(targetSurface);
		var _sh = surface_get_height(targetSurface);
		
		var _selectionSurf = surface_create(_sw, _sh);
		var _drawnSurface  = surface_create(_sw, _sh);
		
		surface_set_shader(_selectionSurf, noone, true, BLEND.over);
			draw_surface(selection_surface, selection_position[0], selection_position[1]);
		surface_reset_shader();
		
		surface_set_shader(_drawnSurface, sh_canvas_apply_draw, false, BLEND.over);
			shader_set_i("drawLayer", _drawLay);
			shader_set_i("eraser",    0);
			shader_set_f("channels",  1, 1, 1, 1);
			shader_set_f("alpha",     1);
			
			shader_set_surface("back", targetSurface);
			shader_set_surface("fore", _selectionSurf);
			
			draw_empty();
		surface_reset_shader();
		
		if(targetSurface == canvas_surface) {
			node.setCanvasSurface(_drawnSurface);
			canvas_surface = _drawnSurface;
			node.surface_store_buffer();
			is_selected = false;
		}
		
		surface_free(targetSurface);
		return _drawnSurface;
	}
	
	function onSelected(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		selection_hovering = false;
		if(!is_surface(selection_surface)) { is_selected = false; return; } 
		
		if(key_mod_press(SHIFT)) { CURSOR_SPRITE = THEME.cursor_path_add;    return; }
		if(key_mod_press(ALT))   { CURSOR_SPRITE = THEME.cursor_path_remove; return; }
		
		if(is_select_drag) {
			var px = selection_sx + (mouse_cur_x - selection_mx);
			var py = selection_sy + (mouse_cur_y - selection_my);
						
			selection_position[0] = px;
			selection_position[1] = py;
			
			if(mouse_release(mb_left))
				is_select_drag = false;
		}
		
		var pos_x = selection_position[0];
		var pos_y = selection_position[1];
		var sel_w = selection_size[0];
		var sel_h = selection_size[1];
		
		selection_hovering = false;
		
		if(point_in_rectangle(mouse_cur_x, mouse_cur_y, pos_x, pos_y, pos_x + sel_w - 1, pos_y + sel_h - 1)) {
			var _msx  = mouse_cur_x - pos_x;
			var _msy  = mouse_cur_y - pos_y;
			var _mask = selection_sampler.getPixelDirect(_msx, _msy);
			selection_hovering = _mask > 0;
		}
		
		if(selection_hovering) CURSOR_SPRITE = THEME.cursor_path_move;
		
		if(mouse_press(mb_left, active)) {
			if(selection_hovering) {
				is_select_drag = true;
				selection_sx = pos_x;
				selection_sy = pos_y;
				selection_mx = mouse_cur_x;
				selection_my = mouse_cur_y;
				
			} else if(PANEL_PREVIEW.tool_current == noone)
				apply();
		}
	}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		if(!is_selected && is_surface(selection_surface))
			apply();
		
		if(key_press(vk_delete)) {
			is_selected = false;
			surface_free_safe(selection_surface);
			
		} else if(key_press(vk_escape) || key_press(vk_enter))
			apply();
	}
	
	////- Draws
	
	function drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var sel_x0 = selection_position[0];
		var sel_y0 = selection_position[1];
		
		var _dx = _x + sel_x0 * _s;
		var _dy = _y + sel_y0 * _s;
		
		draw_surface_ext_safe(selection_mask, _dx, _dy, _s, _s);
	}
	
	function drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos_x = _x + selection_position[0] * _s;
		var pos_y = _y + selection_position[1] * _s;
		var sel_w = selection_size[0] * _s;
		var sel_h = selection_size[1] * _s;
		
		draw_rectangle_dashed_bg(pos_x - 1, pos_y - 1, pos_x + sel_w, pos_y + sel_h, true, 6, current_time / 100, c_black, c_white);
	}
	
	////- Actions
	
	function copySelection() {
		var s = surface_encode(selection_surface, false);
	    s.position = selection_position;
		clipboard_set_text(json_stringify(s));
	}
	
	function rotate90cw() {
		var _sw = surface_get_width(selection_surface);
		var _sh = surface_get_height(selection_surface);
		
		var _newS = surface_create(_sh, _sw);
		surface_set_shader(_newS, noone);
			draw_surface_ext(selection_surface, _sh, 0, 1, 1, -90, c_white, 1);
		surface_reset_shader();
		
		surface_free(selection_surface);
		selection_surface = _newS;
	}
	
	function rotate90ccw() {
		var _sw = surface_get_width(selection_surface);
		var _sh = surface_get_height(selection_surface);
		
		var _newS = surface_create(_sh, _sw);
		surface_set_shader(_newS, noone);
			draw_surface_ext(selection_surface, 0, _sw, 1, 1, 90, c_white, 1);
		surface_reset_shader();
		
		surface_free(selection_surface);
		selection_surface = _newS;
	}
	
	function flipH() {
		var _sw = surface_get_width(selection_surface);
		var _sh = surface_get_height(selection_surface);
		
		var _newS = surface_create(_sw, _sh);
		surface_set_shader(_newS, noone);
			draw_surface_ext(selection_surface, _sw, 0, -1, 1, 0, c_white, 1);
		surface_reset_shader();
		
		surface_free(selection_surface);
		selection_surface = _newS;
	}
	
	function flipV() {
		var _sw = surface_get_width(selection_surface);
		var _sh = surface_get_height(selection_surface);
		
		var _newS = surface_create(_sw, _sh);
		surface_set_shader(_newS, noone);
			draw_surface_ext(selection_surface, 0, _sh, 1, -1, 0, c_white, 1);
		surface_reset_shader();
		
		surface_free(selection_surface);
		selection_surface = _newS;
	}
	
}

function canvas_tool_selection(_selector) : canvas_tool() constructor {
	selector = _selector;
	
	selection_mask		= noone;
	selection_position	= [ 0, 0 ];
	selection_size   	= [ 0, 0 ];
	
	is_selecting = false;
	
	selection_sx = 0; selection_sy = 0;
	selection_mx = 0; selection_my = 0;
	
	mouse_cur_x  = 0; mouse_cur_y  = 0;
	mouse_pre_x  = 0; mouse_pre_y  = 0;
	
	function init() {}
	
	////- Step
	
	function onStep(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		onStep(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	////- Draws
	
	function onDrawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	function drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		onDrawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		if(!is_selecting) return;
		
		var sel_x0 = min(selection_sx, mouse_cur_x);
		var sel_y0 = min(selection_sy, mouse_cur_y);
		
		var _dx = _x + sel_x0 * _s;
		var _dy = _y + sel_y0 * _s;
		
		draw_surface_ext_safe(selection_mask, _dx, _dy, _s, _s);
	}
	
	function drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
}