function Node_create_Wiggler(_x, _y) {
	var node = new Node_Wiggler(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Wiggler(_x, _y) : Node_Value_Processor(_x, _y) constructor {
	name			= "Wiggler";
	update_on_frame = true;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 1] = nodeValue(1, "Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 2] = nodeValue(2, "Frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 3, 5 ] )
		.setDisplay(VALUE_DISPLAY.range);
	
	inputs[| 3] = nodeValue(3, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(9999999) )
		.setVisible(false);
	
	outputs[| 0] = nodeValue(0, "Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_value_data(_data, index = 0) { 
		var time = ANIMATOR.current_frame;
		var _min = _data[1][0];
		var _max = _data[1][1];
		var _fmin = max(1, _data[2][0]);
		var _fmax = max(1, _data[2][1]);
		
		var _val = _data[0] + getWiggle(_min, _max, _fmin, _fmax, time, _data[3]);
		return _val;
	}
	
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, c_white);
		draw_text(xx + w / 2 * _s, yy + 10 + h / 2 * _s, outputs[| 0].getValue());
		
	}
}