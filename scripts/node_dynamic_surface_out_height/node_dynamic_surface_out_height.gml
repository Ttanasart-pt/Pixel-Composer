function Node_DynaSurf_Out_Height(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "getHeight";
	
	manual_deletable	 = false;
	destroy_when_upgroup = true;
	
	inputs[| 0] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	outputs[| 0] = nodeValue("PCX", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone);
	
	input_display_list = [ 0 ];
	
	static update = function() {
		var _h = inputs[| 0].getValue();
		outputs[| 0].setValue(_h);
	}
}