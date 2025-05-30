function Node_Flow_Noise(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Flow Noise";
	shader = sh_noise_flow;
	
	newInput(6, nodeValue_Surface("Mask"));
	
	////- =Noise
	
	newInput(3, nodeValue_Float(        "Progress",    0    )).setShaderProp("progress");
	newInput(4, nodeValue_Slider_Range( "Detail",     [1,8], [ 1, 16, 0.1 ])).setShaderProp("detail");
	
	////- =Transform
	
	newInput(1, nodeValue_Vec2(         "Position",   [0,0] )).setShaderProp("position").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput(5, nodeValue_Rotation(     "Rotation",    0    )).setShaderProp("rotation");
	newInput(2, nodeValue_Vec2(         "Scale",      [2,2] )).setShaderProp("scale");
	
	input_display_list = [
		["Output",     true], 0, 6, 
		["Noise",     false], 3, 4, 
		["Transform", false], 1, 5, 2, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
}