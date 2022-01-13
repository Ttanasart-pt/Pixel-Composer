function Node_create_Counter(_x, _y) {
	var node = new Node_Counter(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Counter(_x, _y) : Node_Value_Processor(_x, _y) constructor {
	name = "Counter";
	update_on_frame = true;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Start", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	inputs[| 1] = nodeValue(1, "Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	outputs[| 0] = nodeValue(0, "Counter", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_value_data(_data, index = 0) { 
		var time = ANIMATOR.current_frame;
		var spd  = _data[1];
		var val  = _data[0] + time * spd;
		
		return val;
	}
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, c_white);
		draw_text(xx + w / 2 * _s, yy + 10 + h / 2 * _s, outputs[| 0].getValue());
	}
}