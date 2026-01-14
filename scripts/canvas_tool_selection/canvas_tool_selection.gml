function canvas_selection() : canvas_tool() constructor {
	selection_surface	   = noone;
	selection_mask		   = noone;
	selection_surface_base = noone;
	selection_mask_base    = noone;
	
	selection_position	= [ 0, 0 ];
	selection_size   	= [ 0, 0 ];
	selection_hovering  = false;
	selection_sampler   = new Surface_Sampler_Grey();
	
	is_selected    = false;
	was_selected   = false;
	hover_index    = noone;
	is_select_drag = 0;
	is_select_scal = 0; is_select_scal_anchor = 0;
	is_select_rota = 0;
	
	selection_sx = 0; selection_sy = 0;
	selection_ex = 0; selection_ey = 0;
	selection_mx = 0; selection_my = 0;
	selection_aa = 0;
	
	mouse_cur_x  = 0; mouse_cur_y  = 0;
	
	function init() {
		is_select_drag = false;
	}
	
	////- Create Selection
	
	function createSelection(_mask, sel_x0, sel_y0, sel_w, sel_h) {
		if(!is_selected) { createNewSelection(_mask, sel_x0, sel_y0, sel_w, sel_h); updateSelection(); return; }
		
		apply();
		
		     if(key_mod_press(SHIFT)) modifySelection(_mask, sel_x0, sel_y0, sel_w, sel_h, true);
		else if(key_mod_press(ALT))   modifySelection(_mask, sel_x0, sel_y0, sel_w, sel_h, false);
		else                          createNewSelection(_mask, sel_x0, sel_y0, sel_w, sel_h);
		
		updateSelection();
	}
	
	function trimSelection() {
		if(!is_surface(selection_mask)) return;
		
		var _bbox = surface_get_bbox(selection_mask);
		
		selection_position[0] += _bbox[0];
		selection_position[1] += _bbox[1];
		selection_size[0]      = _bbox[2];
		selection_size[1]      = _bbox[3];
		
		var _temp_surface = surface_create(_bbox[2], _bbox[3]);
		var _temp_mask    = surface_create(_bbox[2], _bbox[3]);
		
		surface_set_shader(_temp_surface);
			draw_surface(selection_surface, -_bbox[0], -_bbox[1]);
		surface_reset_shader();
		
		surface_set_shader(_temp_mask);
			draw_surface(selection_mask, -_bbox[0], -_bbox[1]);
		surface_reset_shader();
		
		surface_free(selection_surface);
		surface_free(selection_mask);
		
		selection_surface = _temp_surface;
		selection_mask    = _temp_mask;
	}
	
	function updateSelection() {
		selection_aa = 0;
		selection_sampler.setSurface(selection_mask);
		
		if(!is_surface(selection_surface)) return;
		if(!is_surface(selection_mask))    return;
		
		selection_surface_base = surface_verify(selection_surface_base, selection_size[0], selection_size[1]); 
		surface_copy(selection_surface_base, 0, 0, selection_surface);
		
		selection_mask_base    = surface_verify(selection_mask_base,    selection_size[0], selection_size[1]); 
		surface_copy(selection_mask_base,    0, 0, selection_mask);
		
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
			draw_clear(c_white);
		surface_reset_shader();
		
		selection_position = [ sel_x0, sel_y0 ];
		selection_size     = [ sel_w,  sel_h  ];
		is_selected        = true;
		
		updateSelection();
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
		if(is_selected) apply();
		
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
		
		updateSelection();
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
		if(!is_surface(selection_surface)) { is_selected = false; return; } 
		if(key_mod_press(SHIFT)) { CURSOR_SPRITE = THEME.cursor_add;    return; }
		if(key_mod_press(ALT))   { CURSOR_SPRITE = THEME.cursor_remove; return; }
		
		var _smx = (_mx - _x) / _s;
		var _smy = (_my - _y) / _s;
			
		var pos_x0  = selection_position[0];
		var pos_y0  = selection_position[1];
		var pos_x1  = pos_x0 + selection_size[0];
		var pos_y1  = pos_y0 + selection_size[1];
		var pos_xc  = (pos_x0 + pos_x1) / 2;
		var pos_yc  = (pos_y0 + pos_y1) / 2;
		hover_index = noone;
		
		if(is_select_drag) {
			var px = selection_sx + (mouse_cur_x - selection_mx);
			var py = selection_sy + (mouse_cur_y - selection_my);
						
			selection_position[0] = px;
			selection_position[1] = py;
			
			if((is_select_drag == 1 && mouse_release(mb_left)) || (is_select_drag == 2 && mouse_press(mb_left)))
				is_select_drag = 0;
			
			selection_hovering = true;
			
		} else if(is_select_scal) {
			var _dx = mouse_cur_x - selection_mx;
			var _dy = mouse_cur_y - selection_my;
			
			var px = selection_sx;
			var py = selection_sy;
			
			var pw = selection_ex - selection_sx;
			var ph = selection_ey - selection_sy;
					
			switch(is_select_scal_anchor) {
				case 1 : px += _dx; py += _dy;
					     pw -= _dx; ph -= _dy; break;
				
				case 2 : py += _dy;
					     pw += _dx; ph -= _dy; break;
				
				case 3 : px += _dx;
				         pw -= _dx; ph += _dy; break;
					
				case 4 : pw += _dx; ph += _dy; break;
					
			}
			
			selection_surface = surface_verify(selection_surface, pw, ph);
			selection_mask    = surface_verify(selection_mask,    pw, ph);
			
			surface_set_shader(selection_surface, noone);
				draw_surface_stretched(selection_surface_base, 0, 0, pw, ph);
			surface_reset_shader();
			
			surface_set_shader(selection_mask, noone);
				draw_surface_stretched(selection_mask_base, 0, 0, pw, ph);
			surface_reset_shader();
			
			selection_position[0] = px;
			selection_position[1] = py;
			
			selection_size[0] = pw;
			selection_size[1] = ph;
			
			if((is_select_scal == 1 && mouse_release(mb_left)) || (is_select_scal == 2 && mouse_press(mb_left))) {
				selection_sampler.setSurface(selection_mask);
				is_select_scal = 0;
			}
			
			selection_hovering = true;
			
		} else if(is_select_rota) {
			var a0 = point_direction(selection_sx, selection_sy, selection_mx, selection_my);
			var a1 = point_direction(selection_sx, selection_sy, _smx, _smy);
			
			selection_mx = _smx;
			selection_my = _smy;
			
			var _dd = angle_difference(a1, a0);
			selection_aa += _dd;
			
			var aa = selection_aa;
			if(key_mod_press(CTRL)) aa = value_snap(aa, 45);
			
			var sw = surface_get_width(selection_surface_base);
			var sh = surface_get_height(selection_surface_base);
			var pd = floor(sqrt(sw * sw + sh * sh)) - min(sw, sh);
			var pw = sw + pd * 2;
			var ph = sh + pd * 2;
			
			var _p = point_rotate(pw / 2 - sw / 2, ph / 2 - sh / 2, pw / 2, ph / 2, aa);
			
			selection_surface = surface_verify(selection_surface, pw, ph);
			selection_mask    = surface_verify(selection_mask,    pw, ph);
			
			surface_set_shader(selection_surface, noone);
				draw_surface_ext(selection_surface_base, _p[0], _p[1], 1, 1, aa, c_white, 1);
			surface_reset_shader();
			
			surface_set_shader(selection_mask, noone);
				draw_surface_ext(selection_mask_base, _p[0], _p[1], 1, 1, aa, c_white, 1);
			surface_reset_shader();
			
			selection_position[0] = selection_sx - pw / 2;
			selection_position[1] = selection_sy - ph / 2;
			
			selection_size[0] = pw;
			selection_size[1] = ph;
			
			if((is_select_rota == 1 && mouse_release(mb_left)) || (is_select_rota == 2 && mouse_press(mb_left))) {
				selection_aa = aa;
				
				trimSelection();
				updateSelection();
				is_select_rota = 0;
			}
			
			selection_hovering = true;
			
		} else {
			if(point_in_rectangle(mouse_cur_x, mouse_cur_y, pos_x0, pos_y0, pos_x1 - 1, pos_y1 - 1)) {
				var _msx  = mouse_cur_x - pos_x0;
				var _msy  = mouse_cur_y - pos_y0;
				var _mask = selection_sampler.active? selection_sampler.getPixelDirect(_msx, _msy) : 0;
				selection_hovering = _mask > 0;
				
				hover_index = 0;
			}
			
			if(point_in_circle(_smx, _smy, pos_x0, pos_y0, 8 / _s)) hover_index = 1;
			if(point_in_circle(_smx, _smy, pos_x1, pos_y0, 8 / _s)) hover_index = 2;
			if(point_in_circle(_smx, _smy, pos_x0, pos_y1, 8 / _s)) hover_index = 3;
			if(point_in_circle(_smx, _smy, pos_x1, pos_y1, 8 / _s)) hover_index = 4;
			if(point_in_circle(_smx, _smy, pos_xc, pos_y0 - 24 / _s, 8 / _s)) hover_index = 5;
			
			if(hover_index) selection_hovering = true;
		}
		
		if(hover_index == noone) {
			if(PANEL_PREVIEW.tool_current == noone && mouse_press(mb_left, active)) 
				apply();
			return;
		}
		
		if(mouse_press(mb_left, active)) {
			switch(hover_index) {
				case 0 : 
					is_select_drag = 1;
					selection_sx = pos_x0;
					selection_sy = pos_y0;
					selection_mx = mouse_cur_x;
					selection_my = mouse_cur_y;
					break;
				
				case 5 : 
					is_select_rota = 1;
					selection_sx = pos_xc;
					selection_sy = pos_yc;
					selection_mx = _smx;
					selection_my = _smy;
					break;
					
				default :
					is_select_scal = 1;
					is_select_scal_anchor = hover_index;
					
					selection_sx = pos_x0;
					selection_sy = pos_y0;
					selection_ex = pos_x1;
					selection_ey = pos_y1;
					selection_mx = mouse_cur_x;
					selection_my = mouse_cur_y;
					break;
					
			}
		}
	}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		mouse_cur_x  = round((_mx - _x) / _s - 0.5);
		mouse_cur_y  = round((_my - _y) / _s - 0.5);
		
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
		if(is_select_drag || is_select_rota || is_select_scal) return;
		
		var pos_x = _x + selection_position[0] * _s;
		var pos_y = _y + selection_position[1] * _s;
		var sel_w = selection_size[0] * _s;
		var sel_h = selection_size[1] * _s;
		
		draw_rectangle_dashed_bg(pos_x - 1, pos_y - 1, pos_x + sel_w, pos_y + sel_h, true, 6, current_time / 100, c_black, c_white);
		
		draw_anchor(hover_index == 1, pos_x,         pos_y,         ui(8), 1);
		draw_anchor(hover_index == 2, pos_x + sel_w, pos_y,         ui(8), 1);
		draw_anchor(hover_index == 3, pos_x,         pos_y + sel_h, ui(8), 1);
		draw_anchor(hover_index == 4, pos_x + sel_w, pos_y + sel_h, ui(8), 1);
		
		draw_set_color(c_white)
		draw_line(pos_x + sel_w / 2, pos_y, pos_x + sel_w / 2, pos_y - 24);
		draw_anchor(hover_index == 5, pos_x + sel_w / 2, pos_y - 24, ui(8), 1);
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

	static escapable = function() /*=>*/ {return !selector.was_selected};
}