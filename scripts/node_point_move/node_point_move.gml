function Node_Move_Point(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Translate Point";
	color		= COLORS.node_blend_number;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Point", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "XY Shift", "Direction + Distance" ]);
	
	inputs[| 2] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 4] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 );
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static step = function() {
		var _mode = getInputData(1);
		
		inputs[| 2].setVisible(_mode == 0);
		inputs[| 3].setVisible(_mode == 1);
		inputs[| 4].setVisible(_mode == 1);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _pnt  = _data[0];
		var _mode = _data[1];
		var _shf  = _data[2];
		var _dirr = _data[3];
		var _diss = _data[4];
		
		if(_mode == 0)
			return [ _pnt[0] + _shf[0], _pnt[1] + _shf[1] ];
		else if(_mode == 1)
			return [ _pnt[0] + lengthdir_x(_diss, _dirr), _pnt[1] + lengthdir_y(_diss, _dirr) ];
	}
}