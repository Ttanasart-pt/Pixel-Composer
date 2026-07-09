function Node_Iterate_Inline_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	loop  = noone;
	parameters.inline_draw_input = true;
	setDimension(96, 48);
	
	loopable = false;
	clonable = false;
	
	inline_input         = false;
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Init Input", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Init value", VALUE_TYPE.any, 0 ));
	
	////- Rendering
	
	static update = function() {
		var _vto  = outputs[0].getJunctionTo();
		var _type = array_empty(_vto)? VALUE_TYPE.any : _vto[0].type;
		
		inputs[0].setType(_type);
		outputs[0].setType(_type);
		
		var itr  = loop.iterated - 1;
		var val  = itr == 0? inputs[0].getValue() : loop.output_node.inputs[0].getValue();
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