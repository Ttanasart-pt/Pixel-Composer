function canvas_tool_selection(selector = noone) : canvas_tool() constructor {
	
	self.selector = selector;
	
	selection_surface	= surface_create_empty(1, 1);
	selection_mask		= surface_create_empty(1, 1);
	selection_position	= [ 0, 0 ];
	
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
		
		is_selecting = false;
		
		if(sel_w == 1 && sel_h == 1) return;
		is_selected  = true;
		
		selection_surface = surface_create(sel_w, sel_h);
		selection_mask    = surface_create(sel_w, sel_h);
		
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
	} #endregion
	
	function copySelection() { #region
		var s = surface_encode(selection_surface);
		clipboard_set_text(s);
	} #endregion
	
	function apply() { #region
		var _drawLay = node.tool_attribute.drawLayer;
		var _sw = surface_get_width(_canvas_surface);
		var _sh = surface_get_height(_canvas_surface);
		
		var _drawnSurface = surface_create(_sw, _sh);
		
		surface_set_target(_drawnSurface);
			DRAW_CLEAR
			
			if(_drawLay == 0 || _drawLay == 2) {
				BLEND_OVERRIDE
					draw_surface(_canvas_surface, 0, 0);
				BLEND_ALPHA
					draw_surface_safe(selection_surface, selection_position[0], selection_position[1]);
				BLEND_NORMAL
				
			} else if(_drawLay == 1) {
				BLEND_OVERRIDE
					draw_surface_safe(selection_surface, selection_position[0], selection_position[1]);
				BLEND_ALPHA
					draw_surface(_canvas_surface, 0, 0);
				BLEND_NORMAL
			}
			
		surface_reset_target();
		
		node.setCanvasSurface(_drawnSurface);
		surface_free(_canvas_surface);
		
		node.surface_store_buffer();
		surface_free(selection_surface);
		
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
			} else {
				is_selected = false;
				apply();
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