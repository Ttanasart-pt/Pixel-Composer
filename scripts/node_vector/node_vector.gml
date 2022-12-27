function Node_Number(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Number";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 1;
	
	inputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Number", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_data(_output, _data, index = 0) { 
		return _data[0]; 
	}
	
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str	= string(inputs[| 0].getValue());
		var ss	= string_scale(str, (w - 16) * _s, (h - 16) * _s - 20);
		draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, ss, ss, 0);
	}
}

function Node_Vector2(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector2";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 2;
	
	inputs[| 0] = nodeValue(0, "x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ]);
	
	function process_data(_output, _data, index = 0) { 
		var vec = [ _data[0], _data[1] ];
		return vec;
	}
	
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var str	= string(inputs[| 0].getValue()) + "\n" + string(inputs[| 1].getValue());
		var ss	= string_scale(str, (w - 16) * _s, (h - 16) * _s - 20);
		draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, ss, ss, 0);
	}
}

function Node_Vector3(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector3";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 3;
	
	inputs[| 0] = nodeValue(0, "x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 2] = nodeValue(2, "z", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	function process_data(_output, _data, index = 0) { 
		var vec = [ _data[0], _data[1], _data[2] ];
		return vec; 
	}
	
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var str	= string(inputs[| 0].getValue()) + "\n" + string(inputs[| 1].getValue()) + "\n" + string(inputs[| 2].getValue());
		var ss	= string_scale(str, (w - 16) * _s, (h - 16) * _s - 20);
		draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, ss, ss, 0);
	}
}

function Node_Vector4(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector4";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 4;
	
	inputs[| 0] = nodeValue(0, "x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 2] = nodeValue(2, "z", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 3] = nodeValue(3, "w", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	function process_data(_output, _data, index = 0) { 
		var vec = [ _data[0], _data[1], _data[2], _data[3] ];
		return vec; 
	}
	
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var str	= string(inputs[| 0].getValue()) + "\n" + string(inputs[| 1].getValue()) 
			+ "\n" + string(inputs[| 2].getValue()) + "\n" + string(inputs[| 3].getValue());
		var ss	= string_scale(str, (w - 16) * _s, (h - 16) * _s - 20);
		draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, ss, ss, 0);
	}
}

function Node_Vector_Split(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector split";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 4;
	
	inputs[| 0] = nodeValue(0, "Vector", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "x", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 1] = nodeValue(1, "y", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 2] = nodeValue(2, "z", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 3] = nodeValue(3, "w", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_data(_output, _data, _index = 0) { 
		if(array_length(_data[0]) > _index)
			return _data[0][_index]; 
		return 0;
	}
	
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var str	= string(outputs[| 0].getValue()) + "\n" + string(outputs[| 1].getValue()) 
			+ "\n" + string(outputs[| 2].getValue()) + "\n" + string(outputs[| 3].getValue());
		var ss	= string_scale(str, (w - 16) * _s, (h - 16) * _s - 20);
		draw_text_transformed(xx + w / 2 * _s, yy + 10 + h / 2 * _s, str, ss, ss, 0);
	}
}