function Node_DynaSurf_Out_Height(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name  = "getHeight";
	color = COLORS.node_blend_dynaSurf;
	
	manual_deletable	 = false;
	destroy_when_upgroup = true;
	
	inputs[| 0] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	outputs[| 0] = nodeValue("PCX", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone)
		.setVisible(false);
	
	input_display_list = [ 0 ];
	
	static getNextNodes = method(self, dynaSurf_output_getNextNode);
	
	static setRenderStatus = function(result) {
		rendered = result;
		if(group) group.setRenderStatus(result);
	}
	
	static update = function() {
		var _h = getInputData(0);
		outputs[| 0].setValue(_h);
		
		if(group) group.setDynamicSurface();
	}
}