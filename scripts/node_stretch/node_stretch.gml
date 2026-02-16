function Node_Stretch(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Stretch";
	shader = sh_stretch;
	
	var i = shader_index;
	
	////- =Stretch
	newInput(i+2, nodeValue_Anchor(   "Anchor"           )).setShaderProp("anchor");
	newInput(i+0, nodeValue_Rotation( "Direction", 0     )).setShaderProp("direction");
	newInput(i+1, nodeValue_Vec2(     "Strength",  [1,1] )).setShaderProp("strength");
	
	array_append(input_display_list, [ 
		[ "Stretch", false ], i+2, i+0, i+1, 
	]);
	
	////- Node
	
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _anc = getInputData(shader_index+2);
		var _dim = getDimension();
		
		var cx = _x + _dim[0] * _anc[0] * _s;
		var cy = _y + _dim[1] * _anc[1] * _s;
		
		InputDrawOverlay(inputs[shader_index+2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, 1, _dim));
		InputDrawOverlay(inputs[shader_index+0].drawOverlay(hover, active, cx, cy, _s, _mx, _my));
	}
	
}