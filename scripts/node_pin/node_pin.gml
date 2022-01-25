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
	
	static drawNodeBase = function(xx, yy, _s) {
		if(w * _s > 32) {
			draw_sprite_stretched_ext(s_node_pin_bg, 0, xx, yy, w * _s, h * _s, color, 0.75);
			bg_sel_spr = s_node_pin_bg_active;
		} else {
			draw_sprite_stretched_ext(s_node_pin_bg_s, 0, xx, yy, w * _s, h * _s, color, 0.75);
			bg_sel_spr = s_node_pin_bg_active_s;
		}
	}
}