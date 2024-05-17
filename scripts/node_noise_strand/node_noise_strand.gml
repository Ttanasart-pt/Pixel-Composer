function Node_Noise_Strand(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Strand Noise";
	shader = sh_noise_strand;
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "density");
		
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	inputs[| 4] = nodeValue("Slope", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "slope");
				
	inputs[| 5] = nodeValue("Curve", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.slider_range, { range: [ 0, 4, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "curve");
				
	inputs[| 6] = nodeValue("Curve scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 );
		addShaderProp(SHADER_UNIFORM.float, "curveDetail");
		
	inputs[| 7] = nodeValue("Thickness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "thickness");
		
	inputs[| 8] = nodeValue("Curve shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
		addShaderProp(SHADER_UNIFORM.float, "curveShift");
		
	inputs[| 9] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )	
		.setDisplay(VALUE_DISPLAY.enum_button, [ "x", "y" ] );
		addShaderProp(SHADER_UNIFORM.integer, "axis");
		
	inputs[| 10] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )	
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Line", "Area" ] );
		addShaderProp(SHADER_UNIFORM.integer, "mode");
		
	inputs[| 11] = nodeValue("Opacity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0., 1. ] )
		.setDisplay(VALUE_DISPLAY.slider_range);
		addShaderProp(SHADER_UNIFORM.float, "alpha");
		
	input_display_list = [ 3, 
		["Output", 	 true],	0, 
		["Noise",	false],	9, 1, 2, 4, 
		["Curve",	false],	5, 6, 8, 
		["Render",	false], 10, 7, 11, 
	];
}