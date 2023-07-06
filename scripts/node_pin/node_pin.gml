function Node_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Pin";
	w = 32;
	h = 32;
	
	auto_height = false;
	junction_shift_y = 16;
	previewable = false;
	
	isHovering  = false;
	hoverExpand = 0;
	
	bg_spr = THEME.node_pin_bg;
	bg_sel_spr = THEME.node_pin_bg_active;
	
	inputs[| 0] = nodeValue("In", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static update = function(frame = PROJECT.animator.current_frame) {
		inputs[| 0].type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		outputs[| 0].type = inputs[| 0].type;
		outputs[| 0].value_from = inputs[| 0].value_from;
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		inputs[| 0].x = xx - hoverExpand * 12 * _s;
		inputs[| 0].y = yy;
		
		outputs[| 0].x = xx + hoverExpand * 12 * _s;
		outputs[| 0].y = yy;
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		isHovering = false;
		var hover = noone;
		var xx	  = x * _s + _x;
		var yy	  = y * _s + _y;
		var hov   = PANEL_GRAPH.value_dragging; 
		
		if(hov == noone && point_in_rectangle(_mx, _my, xx - 16 * _s, yy - 12 * _s, xx + 16 * _s, yy + 12 * _s)) { 
			isHovering = true;
			
			draw_sprite_stretched(THEME.node_bg, 0, xx - 12 * _s, yy - 12 * _s, 24 * _s, 24 * _s);
			if(inputs[| 0].drawJunction(_s, _mx, _my))
				hover = inputs[| 0];
			if(outputs[| 0].drawJunction(_s, _mx, _my))
				hover = outputs[| 0];
		} else if(hoverExpand > 0) {
			inputs[| 0].drawJunction(_s, _mx, _my)
			outputs[| 0].drawJunction(_s, _mx, _my)
		} else {
			var jun;
			if(hov != noone) jun = hov.connect_type == JUNCTION_CONNECT.input? outputs[| 0] : inputs[| 0];
			else			 jun = inputs[| 0].value_from == noone? inputs[| 0] : outputs[| 0];
			
			if(jun.drawJunction(_s, _mx, _my,))
				hover = jun;
		}
		
		hoverExpand = lerp(hoverExpand, isHovering, 1 / 5);
		
		return hover;
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		if(group != PANEL_GRAPH.getCurrentContext()) return;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		if(active_draw_index > -1) {
			draw_sprite_ext(bg_sel_spr, 0, xx, yy, _s, _s, 0, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		if(display_name != "") {
			draw_set_text(f_p0, fa_center, fa_bottom, COLORS._main_text);
			draw_text_transformed(xx, yy - 12, display_name, _s, _s, 0);
		}
		
		return drawJunctions(_x, _y, _mx, _my, _s);
	}
}