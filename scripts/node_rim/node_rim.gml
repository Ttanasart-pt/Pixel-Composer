function Node_Rim(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name = "Rim";
	shader = sh_rim;
	
	inputs[| 1] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.rotation);
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
}