function Node_create_Pin(_x, _y) {
	var node = new Node_Pin(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Pin(_x, _y) : Node(_x, _y) constructor {
	name = "";
	w = 64;
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
	
	function update() {
		if(inputs[| 0].value_from != noone) {
			outputs[| 0].value_from = inputs[| 0].value_from;
		}
	}
	update();
}