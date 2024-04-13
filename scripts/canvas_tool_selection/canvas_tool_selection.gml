function canvas_tool_selection(selector = noone) : canvas_tool() constructor {
	
	self.selector = selector;
	
	selection_surface	= surface_create_empty(1, 1);
	selection_mask		= surface_create_empty(1, 1);
	selection_position	= [ 0, 0 ];
	selection_size   	= [ 0, 0 ];
	
	is_selecting   = false;
	is_selected    = false;
	is_select_drag = false;
	
	selection_sx = 0;
	selection_sy = 0;
	selection_mx = 0;
	selection_my = 0;
		
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	
	function createSelection(_mask, sel_x0, sel_y0, sel_w, sel_h) { #region
		if(is_selected)
			apply();
			
		if(key_mod_press(SHIFT))
			modifySelection(_mask, sel_x0, sel_y0, sel_w, sel_h, true);
			
		else if(key_mod_press(ALT))
			modifySelection(_mask, sel_x0, sel_y0, sel_w, sel_h, false);
			
		else 
			createNewSelection(_mask, sel_x0, sel_y0, sel_w, sel_h);
	}
	
	function modifySelection(_mask, sel_x0, sel_y0, sel_w, sel_h, _add) { #region
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
		
		var _selection_surface = surface_create(_nw, _nh);
		var _selection_mask    = surface_create(_nw, _nh);
		
		surface_set_target(_selection_mask);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface_safe(selection_mask, _ox, _oy);
			
			if(_add) BLEND_ADD
			else     BLEND_SUBTRACT
			
			draw_surface_safe(_mask, _nx, _ny);
			
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(_selection_surface);
			DRAW_CLEAR
			draw_surface_safe(_canvas_surface, -_x0, -_y0);
			
			BLEND_MULTIPLY
				draw_surface_safe(_selection_mask, 0, 0);
			BLEND_NORMAL
		surface_reset_target();
		
		surface_free(selection_surface);
		surface_free(selection_mask);
		
		selection_surface = _selection_surface;
		selection_mask    = _selection_mask; 
		
		node.storeAction();
		surface_set_target(_canvas_surface);
			gpu_set_blendmode(bm_subtract);
			draw_surface_safe(selection_surface, _x0, _y0);
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
						
		node.surface_store_buffer();
						
		selection_position = [ _x0, _y0 ];
		selection_size     = [ _nw, _nh ];
		is_selected = true;
	} #endregion
	
	function createNewSelection(_mask, sel_x0, sel_y0, sel_w, sel_h) { #region
		if(sel_w == 1 && sel_h == 1) return;
		
		selection_surface = surface_verify(selection_surface, sel_w, sel_h);
		selection_mask    = surface_verify(selection_mask,    sel_w, sel_h);
		
		surface_set_target(selection_surface);
			DRAW_CLEAR
			draw_surface_safe(_canvas_surface, -sel_x0, -sel_y0);
							
			BLEND_MULTIPLY
				draw_surface_safe(_mask, 0, 0);
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(selection_mask);
			DRAW_CLEAR
			draw_surface_safe(_mask, 0, 0);
		surface_reset_target();
		
		node.storeAction();
		surface_set_target(_canvas_surface);
			gpu_set_blendmode(bm_subtract);
			draw_surface_safe(selection_surface, sel_x0, sel_y0);
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
						
		node.surface_store_buffer();
						
		selection_position = [ sel_x0, sel_y0 ];
		selection_size     = [ sel_w,  sel_h  ];
		is_selected = true;
	} #endregion
	
	function copySelection() { #region
		var s = surface_encode(selection_surface);
		clipboard_set_text(s);
	} #endregion
	
	function apply() { #region
		var _drawLay = node.tool_attribute.drawLayer;
		var _sw = surface_get_width(_canvas_surface);
		var _sh = surface_get_height(_canvas_surface);
		
		var _selectionSurf = surface_create(_sw, _sh);
		var _drawnSurface  = surface_create(_sw, _sh);
		
		surface_set_shader(_selectionSurf, noone);
			draw_surface(selection_surface, selection_position[0], selection_position[1]);
		surface_reset_shader();
		
		surface_set_shader(_drawnSurface, sh_canvas_apply_draw);
			shader_set_i("drawLayer", _drawLay);
			shader_set_i("eraser",    0);
			shader_set_f("channels",  node.tool_attribute.channel);
			shader_set_f("alpha",     1);
			
			shader_set_surface("back", _canvas_surface);
			shader_set_surface("fore", _selectionSurf);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _sw, _sh);
		surface_reset_shader();
		
		node.setCanvasSurface(_drawnSurface);
		surface_free(_canvas_surface);
		_canvas_surface = _drawnSurface;
		
		node.surface_store_buffer();
		
		is_selected = false;
	} #endregion
	
	function onSelected(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(!is_surface(selection_surface)) {
			is_selected = false;
			return;
		} 
		
		if(is_select_drag) {
			var px = selection_sx + (mouse_cur_x - selection_mx);
			var py = selection_sy + (mouse_cur_y - selection_my);
						
			selection_position[0] = px;
			selection_position[1] = py;
			
			if(mouse_release(mb_left))
				is_select_drag = false;
		}
		
		if(mouse_press(mb_left, active)) {
			var pos_x = selection_position[0];
			var pos_y = selection_position[1];
			var sel_w = surface_get_width_safe(selection_surface);
			var sel_h = surface_get_height_safe(selection_surface);
						
			if(point_in_rectangle(mouse_cur_x, mouse_cur_y, pos_x, pos_y, pos_x + sel_w, pos_y + sel_h)) {
				is_select_drag = true;
				selection_sx = pos_x;
				selection_sy = pos_y;
				selection_mx = mouse_cur_x;
				selection_my = mouse_cur_y;
			}
		}
		
		if(key_press(vk_delete)) {
			is_selected = false;
			surface_free(selection_surface);
		}
		
		if(key_press(ord("C"), MOD_KEY.ctrl)) copySelection();
	} #endregion
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		
		mouse_cur_x = round((_mx - _x) / _s - 0.5);
		mouse_cur_y = round((_my - _y) / _s - 0.5);
		
		if(is_selected) { onSelected(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); return; }
		else if(is_surface(selection_surface)) { apply(); }
	} #endregion
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(is_selected)
			draw_surface_safe(selection_surface, selection_position[0], selection_position[1]);
						
		else if(is_selecting) {
			var sel_x0 = min(selection_sx, mouse_cur_x);
			var sel_y0 = min(selection_sy, mouse_cur_y);
			draw_surface_safe(selection_mask, sel_x0, sel_y0);
		}
	} #endregion
	
	function drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(!is_selected) return;
		
		var pos_x = _x + selection_position[0] * _s;
		var pos_y = _y + selection_position[1] * _s;
		var sel_w = surface_get_width_safe(selection_surface)  * _s;
		var sel_h = surface_get_height_safe(selection_surface) * _s;
		
		draw_surface_ext_safe(selection_surface, pos_x, pos_y, _s, _s, 0, c_white, 1);
					
		draw_set_color(c_black);
		draw_rectangle(pos_x, pos_y, pos_x + sel_w, pos_y + sel_h, true);
						
		draw_set_color(c_white);
		draw_rectangle_dashed(pos_x, pos_y, pos_x + sel_w, pos_y + sel_h, true, 6, current_time / 100);
	} #endregion
		
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function rotate90cw() { #region
		var _sw = surface_get_width(selection_surface);
		var _sh = surface_get_height(selection_surface);
		
		var _newS = surface_create(_sh, _sw);
		surface_set_shader(_newS, noone);
			draw_surface_ext(selection_surface, _sh, 0, 1, 1, -90, c_white, 1);
		surface_reset_shader();
		
		surface_free(selection_surface);
		selection_surface = _newS;
	} #endregion
	
	function rotate90ccw() { #region
		var _sw = surface_get_width(selection_surface);
		var _sh = surface_get_height(selection_surface);
		
		var _newS = surface_create(_sh, _sw);
		surface_set_shader(_newS, noone);
			draw_surface_ext(selection_surface, 0, _sw, 1, 1, 90, c_white, 1);
		surface_reset_shader();
		
		surface_free(selection_surface);
		selection_surface = _newS;
	} #endregion
	
	function flipH() { #region
		var _sw = surface_get_width(selection_surface);
		var _sh = surface_get_height(selection_surface);
		
		var _newS = surface_create(_sw, _sh);
		surface_set_shader(_newS, noone);
			draw_surface_ext(selection_surface, _sw, 0, -1, 1, 0, c_white, 1);
		surface_reset_shader();
		
		surface_free(selection_surface);
		selection_surface = _newS;
	} #endregion
	
	function flipV() { #region
		var _sw = surface_get_width(selection_surface);
		var _sh = surface_get_height(selection_surface);
		
		var _newS = surface_create(_sw, _sh);
		surface_set_shader(_newS, noone);
			draw_surface_ext(selection_surface, 0, _sh, 1, -1, 0, c_white, 1);
		surface_reset_shader();
		
		surface_free(selection_surface);
		selection_surface = _newS;
	} #endregion
}