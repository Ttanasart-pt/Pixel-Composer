function Node_Rim(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name = "Rim";
	shader = sh_rim;
	
	newInput(1, nodeValue_Rotation("Angle", self, 0));
		addShaderProp(SHADER_UNIFORM.float, "rotation");
		
}