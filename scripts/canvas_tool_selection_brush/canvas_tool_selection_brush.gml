function canvas_tool_selection_brush(_selector) : canvas_tool_selection(_selector) constructor {
	brush_resizable = true;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	mouse_pre_draw_x = undefined;
	mouse_pre_draw_y = undefined;
	
	function onStep(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		attributes = node.attributes;
		var _dim   = attributes.dimension;
		
		if(!selector.selection_hovering && mouse_press(mb_left, active)) {
			selection_mask = surface_verify(selection_mask, _dim[0], _dim[1]);
			
			surface_set_shader(selection_mask, noone);
				brush.drawPoint(mouse_cur_x, mouse_cur_y, true);
			surface_reset_shader();
				
			is_selecting = true;
			
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
		}
			
		if(is_selecting) {
			var _move = mouse_pre_draw_x != mouse_cur_x || mouse_pre_draw_y != mouse_cur_y;
			var _1stp = brush.dist_min == brush.dist_max && brush.dist_min == 1;
				
			if(_move || !_1stp) {
				surface_set_target(selection_mask);
					BLEND_ADD
					if(_1stp) brush.drawPoint(mouse_cur_x, mouse_cur_y, true);
					brush.drawLine(mouse_pre_draw_x, mouse_pre_draw_y, mouse_cur_x, mouse_cur_y, true);
					BLEND_NORMAL
				surface_reset_target();
			}
				
			mouse_pre_draw_x = mouse_cur_x;
			mouse_pre_draw_y = mouse_cur_y;	
			
			if(mouse_release(mb_left)) {
				var _bbox = surface_get_bbox(selection_mask);
				var sel_x = _bbox[0];
				var sel_y = _bbox[1];
				var sel_w = _bbox[2];
				var sel_h = _bbox[3];
				
				var _sel = surface_create(sel_w, sel_h);
				surface_set_shader(_sel);
					draw_surface(selection_mask, -sel_x, -sel_y);
				surface_reset_shader();
				
				is_selecting   = false;
				
				selector.createSelection(_sel, sel_x, sel_y, sel_w, sel_h);
				surface_free_safe(selection_mask);
			}
		}
			
		BLEND_NORMAL
			
		mouse_pre_x = mouse_cur_x;
		mouse_pre_y = mouse_cur_y;
			
	}
		
	function onDrawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(selector.selection_hovering) return;
		
		var _dx = _x + mouse_cur_x * _s;
		var _dy = _y + mouse_cur_y * _s;
		
		brush.drawPointExt(_dx, _dy, _s);
	}
	
	function drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
}