function Node_Color_Blind(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Color Blind";
	shader = sh_color_blind;
	
	var i = shader_index;
	
	////- =Type
	newInput(i+0, nodeValue_EScroll("Type", 0, [ "Normal vision", "Protanopia", "Protonomaly", "Deuteranopia", "Deuteranomaly", 
		"Tritanopia", "Tritanomaly", "Achromatopsia", "Achromatomaly", ])).setShaderProp("type");
	
	array_append(input_display_list, [ [ "Color Blind", false ], i+0 ]);
	
}