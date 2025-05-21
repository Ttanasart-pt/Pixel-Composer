function Node_Flow_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Flow Noise";
	shader = sh_noise_flow;
	
	newInput(1, nodeValue_Vec2("Position", [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	newInput(2, nodeValue_Vec2("Scale", [ 2, 2 ]));
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(3, nodeValue_Float("Progress", 0))
		addShaderProp(SHADER_UNIFORM.float, "progress");
				
	newInput(4, nodeValue_Slider_Range("Detail", [ 1, 8 ], { range: [ 1, 16, 0.1 ] }));
		addShaderProp(SHADER_UNIFORM.float, "detail");
			
	newInput(5, nodeValue_Rotation("Rotation", 0));
		addShaderProp(SHADER_UNIFORM.float, "rotation");
			
	newInput(6, nodeValue_Surface("Mask"));
	
	input_display_list = [
		["Output", 	 true],	0, 6, 
		["Noise",	false],	1, 5, 2, 3, 4, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
}