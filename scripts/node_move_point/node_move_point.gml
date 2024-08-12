function Node_Move_Point(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name		= "Translate Point";
	color		= COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	inputs[0] = nodeValue_Vec2("Point", self, [ 0, 0, ])
		.setVisible(true, true);
	
	inputs[1] = nodeValue_Enum_Scroll("Mode", self,  0, [ "XY Shift", "Direction + Distance" ]);
	
	inputs[2] = nodeValue_Vec2("Shift", self, [ 0, 0 ]);
	
	inputs[3] = nodeValue_Rotation("Direction", self, 0);
	
	inputs[4] = nodeValue_Float("Distance", self, 4 );
	
	outputs[0] = nodeValue_Output("Result", self, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static step = function() {
		var _mode = getInputData(1);
		
		inputs[2].setVisible(_mode == 0);
		inputs[3].setVisible(_mode == 1);
		inputs[4].setVisible(_mode == 1);
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