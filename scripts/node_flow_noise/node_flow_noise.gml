function Node_Flow_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Flow Noise";
	shader = sh_noise_flow;
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	inputs[| 3] = nodeValue("Progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		addShaderProp(SHADER_UNIFORM.float, "progress");
				
	inputs[| 4] = nodeValue("Detail", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 1, 8 ])
		.setDisplay(VALUE_DISPLAY.slider_range, { range: [ 1, 16, 0.1 ] });
		addShaderProp(SHADER_UNIFORM.float, "detail");
			
	inputs[| 5] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
			
	input_display_list = [
		["Output", 	 true],	0, 
		["Noise",	false],	1, 5, 2, 3, 4, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
}