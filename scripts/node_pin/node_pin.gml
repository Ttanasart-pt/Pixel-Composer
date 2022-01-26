function Node_create_Pin(_x, _y) {
	var node = new Node_Pin(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Pin(_x, _y) : Node(_x, _y) constructor {
	name = "";
	w = 32;
	h = 32;
	min_h = 0;
	auto_height = false;
	junction_shift_y = 16;
	previewable = false;
	
	bg_spr = s_node_pin_bg;
	bg_sel_spr = s_node_pin_bg_active;
	
	inputs[| 0] = nodeValue(0, "In", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0 )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static update = function() {
		inputs[| 0].type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		outputs[| 0].type = inputs[| 0].type;
		outputs[| 0].value_from = inputs[| 0].value_from;
	}
	doUpdate();
	
	static pointIn = function(_mx, _my) {
		return point_in_circle(_mx, _my, x, y, 24);
	}
	
	static preDraw = function(_x, _y, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		inputs[| 0].x = xx;
		inputs[| 0].y = yy;
		
		outputs[| 0].x = xx;
		outputs[| 0].y = yy;
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		var hover = noone;
		
		var jun = inputs[| 0].value_from == noone? inputs[| 0] : outputs[| 0];
		if(jun.drawJunction(_s, _mx, _my, false))
			hover = jun;
		
		return hover;
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		if(group != PANEL_GRAPH.getCurrentContext()) return;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		if(active_draw_index > -1) {
			draw_sprite_ext(bg_sel_spr, 0, xx, yy, _s, _s, 0, c_white, 1);
			active_draw_index = -1;
		}
		
		return drawJunctions(_x, _y, _mx, _my, _s);
	}
}