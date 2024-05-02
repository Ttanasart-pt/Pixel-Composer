function Node_Anim_Curve(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Evaluate Curve";
	update_on_frame = true;
	
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Curve",   self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	inputs[| 1] = nodeValue("Progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 2] = nodeValue("Minimum", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	inputs[| 3] = nodeValue("Maximum", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 4] = nodeValue("Animated", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Curve", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	input_display_list = [ 0, 4, 1, 2, 3 ];
	
	static step = function() {
		var _anim = getSingleValue(4);
		
		inputs[| 1].setVisible(!_anim);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  		
		var curve = _data[0];
		var time  = _data[4]? CURRENT_FRAME / (TOTAL_FRAMES - 1) : _data[1];
		var _min  = _data[2];
		var _max  = _data[3];
		var val   = eval_curve_x(curve, time) * (_max - _min) + _min;
		
		inputs[| 0].editWidget.progress_draw = time;
		
		return val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_curve_eval, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}