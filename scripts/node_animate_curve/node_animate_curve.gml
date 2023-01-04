function Node_Anim_Curve(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Anim Curve";
	update_on_frame = true;
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Curve",   self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, [0, 0, 1, 1]);
	inputs[| 1] = nodeValue(1, "Progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 2] = nodeValue(2, "Minimum", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	inputs[| 3] = nodeValue(3, "Maximum", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	outputs[| 0] = nodeValue(0, "Curve", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, []);
	
	function process_data(_output, _data, index = 0) { 		
		var curve = _data[0];
		var time  = _data[1];
		var _min  = _data[2];
		var _max  = _data[3];
		var val   = eval_curve_bezier_cubic(curve, time) * (_max - _min) + _min;
		
		return val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_curve, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}