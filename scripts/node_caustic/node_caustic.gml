function Node_Caustic(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Caustic";
	shader = sh_water_caustic;
	
	////- =Output
	
	newInput(7, nodeValue_Surface("Mask"));
	
	////- =Noise
	
	newInput(3, nodeValueSeed()).setShaderProp("seed");
	newInput(4, nodeValue_Float(  "Progress",     0    )).setShaderProp("progress");
	newInput(5, nodeValue_Slider( "Detail",       1.24, [ 0, 2, 0.01 ] )).setShaderProp("detail");
	newInput(6, nodeValue_Slider( "Intensity",    1,    [ 0, 4, 0.01 ] )).setShaderProp("intensity");
	
	////- =Transform
	
	newInput(1, nodeValue_Vec2(   "Position",    [0,0] )).setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(2, nodeValue_Vec2(   "Scale",       [4,4] )).setShaderProp("scale");
	
	input_display_list = [
		["Output",     true], 0, 7, 
		["Noise",     false], 6, 4, 5, 
		["Transform", false], 1, 2, 
	];
}