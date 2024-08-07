function Node_Noise_Strand(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Strand Noise";
	shader = sh_noise_strand;
	
	inputs[| 1] = nodeValue_Vector("Position", self, [ 0, 0 ])
		.setUnitRef(function(index) { return getDimension(index); });
		addShaderProp(SHADER_UNIFORM.float, "position");
		
	inputs[| 2] = nodeValue_Float("Density", self, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "density");
		
	inputs[| 3] = nodeValue_Float("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	inputs[| 4] = nodeValue_Float("Slope", self, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "slope");
				
	inputs[| 5] = nodeValue_Slider_Range("Curve", self, [ 0, 0 ] , { range: [ 0, 4, 0.01 ] });
		addShaderProp(SHADER_UNIFORM.float, "curve");
				
	inputs[| 6] = nodeValue_Float("Curve scale", self, 1 );
		addShaderProp(SHADER_UNIFORM.float, "curveDetail");
		
	inputs[| 7] = nodeValue_Float("Thickness", self, 0 )
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "thickness");
		
	inputs[| 8] = nodeValue_Float("Curve shift", self, 0 );
		addShaderProp(SHADER_UNIFORM.float, "curveShift");
		
	inputs[| 9] = nodeValue_Enum_Button("Axis", self,  0 , [ "x", "y" ] );
		addShaderProp(SHADER_UNIFORM.integer, "axis");
		
	inputs[| 10] = nodeValue_Enum_Button("Mode", self,  0 , [ "Line", "Area" ] );
		addShaderProp(SHADER_UNIFORM.integer, "mode");
		
	inputs[| 11] = nodeValue_Slider_Range("Opacity", self, [ 0., 1. ] );
		addShaderProp(SHADER_UNIFORM.float, "alpha");
		
	input_display_list = [ 3, 
		["Output", 	 true],	0, 
		["Noise",	false],	9, 1, 2, 4, 
		["Curve",	false],	5, 6, 8, 
		["Render",	false], 10, 7, 11, 
	];
}