function Node_Feedback_Inline_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Feedback Output";
	color = COLORS.node_blend_feedback;
	loop  = noone;
	parameters.inline_draw_output = true;
	setDimension(96, 48);
	
	loopable = false;
	clonable = false;
	
	inline_output        = false;
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Output", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Feedback Output", VALUE_TYPE.any, 0 ));
	
	static update = function(frame = CURRENT_FRAME) {
		var _vfrom = inputs[0].value_from;
		var _type  = _vfrom? _vfrom.type : VALUE_TYPE.any;
		
		inputs[0].setType(_type);
		outputs[0].setType(_type);
		
		var val  = getInputData(0);
		var outp = outputs[0].getValue();
		
		if(_type == VALUE_TYPE.surface) {
			surface_array_free(outp);
			val = surface_array_clone(val);
		}
		
		outputs[0].setValue(val);
	}
	
	////- Action
	
	static onDestroy = function() { if(loop) loop.destroy(); }
}