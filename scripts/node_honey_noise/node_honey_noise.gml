function Node_Honeycomb_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Honeycomb Noise";
	shader = sh_noise_honey;
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	inputs[| 3] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
	inputs[| 4] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Hexagon", "Star" ]);
		addShaderProp(SHADER_UNIFORM.integer, "mode");
	
	inputs[| 5] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 5].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) })
		addShaderProp(SHADER_UNIFORM.float, "seed");
		
	inputs[| 6] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
		addShaderProp(SHADER_UNIFORM.integer, "iteration");
	
	input_display_list = [ 5, 
		["Output", 	 true],	0, 
		["Noise",	false],	1, 2, 3, 4, 6. 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
}