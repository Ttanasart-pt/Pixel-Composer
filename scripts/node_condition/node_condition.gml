function Node_Condition(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Condition";
	previewable = false;
	
	w = 96;
	
	
	inputs[| 0] = nodeValue("Check value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue("Condition", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Equal", "Not equal", "Less", "Less or equal", "Greater", "Greater or equal"])
		.rejectArray();
		
	inputs[| 2] = nodeValue("Compare to", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.rejectArray();
	
	inputs[| 3] = nodeValue("True", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1 )
		.setVisible(true, true);
		
	inputs[| 4] = nodeValue("False", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1 )
		.setVisible(true, true);
	
	inputs[| 5] = nodeValue("Eval mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Boolean", "Comparison"])
		.rejectArray();
	
	inputs[| 6] = nodeValue("Boolean", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.setVisible(true, true)
		.rejectArray();
	
	input_display_list = [ 5,
		["Condition", false], 0, 1, 2, 6,
		["Result",	  true], 3, 4
	]
	
	outputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	outputs[| 1] = nodeValue("Bool", self, JUNCTION_CONNECT.output, VALUE_TYPE.boolean, false);
	
	static step = function() {
		var _mode = inputs[| 5].getValue();
		
		inputs[| 0].setVisible(_mode);
		inputs[| 1].setVisible(_mode);
		inputs[| 2].setVisible(_mode);
		inputs[| 6].setVisible(!_mode);
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _true = inputs[| 3].getValue();
		var _fals = inputs[| 4].getValue();
		
		var _mode = inputs[| 5].getValue();
		
		var _chck = inputs[| 0].getValue();
		var _cond = inputs[| 1].getValue();
		var _valu = inputs[| 2].getValue();
		var _bool = inputs[| 6].getValue();
		
		inputs[| 3].type = inputs[| 3].value_from == noone? VALUE_TYPE.any : inputs[| 3].value_from.type;
		inputs[| 4].type = inputs[| 4].value_from == noone? VALUE_TYPE.any : inputs[| 4].value_from.type;
		
		var res = false;
		
		if(_mode) {
			switch(_cond) {
				case 0 : res = _chck == _valu; break;
				case 1 : res = _chck != _valu; break;
				case 2 : res = _chck <  _valu; break;
				case 3 : res = _chck <= _valu; break;
				case 4 : res = _chck >  _valu; break;
				case 5 : res = _chck >= _valu; break;
			}
		} else
			res = _bool;
		
		if(res) {
			outputs[| 0].setValue(_true);
			outputs[| 0].type = inputs[| 3].type;
		} else {
			outputs[| 0].setValue(_fals);
			outputs[| 0].type = inputs[| 4].type;	
		}
		
		outputs[| 1].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var val = outputs[| 1].getValue();
		var frm = val? inputs[| 3] : inputs[| 4];
		var to  = outputs[| 0];
		var c0 = value_color(frm.type);
		
		draw_set_color(c0);
		draw_set_alpha(0.5);
		draw_line_width(frm.x, frm.y, to.x, to.y, _s * 4);
		draw_set_alpha(1);
	}
}