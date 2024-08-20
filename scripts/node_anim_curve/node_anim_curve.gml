function Node_Anim_Curve(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Evaluate Curve";
	update_on_frame = true;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue("Curve",   self, CONNECT_TYPE.input, VALUE_TYPE.curve, CURVE_DEF_01));
	newInput(1, nodeValue_Float("Progress", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(2, nodeValue_Float("Minimum", self, 0));
	newInput(3, nodeValue_Float("Maximum", self, 1));
	
	newInput(4, nodeValue_Bool("Animated", self, false));
	
	outputs[0] = nodeValue_Output("Curve", self, VALUE_TYPE.float, []);
	
	input_display_list = [ 0, 4, 1, 2, 3 ];
	
	static step = function() {
		var _anim = getSingleValue(4);
		
		inputs[1].setVisible(!_anim);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  		
		var curve = _data[0];
		var time  = _data[4]? CURRENT_FRAME / (TOTAL_FRAMES - 1) : _data[1];
		var _min  = _data[2];
		var _max  = _data[3];
		var val   = eval_curve_x(curve, time) * (_max - _min) + _min;
		
		inputs[0].editWidget.progress_draw = time;
		
		return val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_curve_eval, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}