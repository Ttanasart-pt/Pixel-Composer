function Node_Heightmap_Shadow(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Heightmap Shadow";
	shader = sh_heightmap_shadow;
	
	var i = shader_index;
	
	////- =Heightmap
	newInput(i+2, nodeValue_Float(    "Height", 1 )).setUnitSimple().setShaderProp("height");
	
	////- =Cast
	newInput(i+0, nodeValue_Rotation( "Direction",    315 )).setShaderProp("direction");
	newInput(i+1, nodeValue_Float(    "Max Distance", .5  )).setUnitSimple().setShaderProp("maxDistance");
	
	////- =Rendering
	newInput(i+3, nodeValue_Color(    "Shadow Color",   ca_black )).setShaderProp("shadowColor");
	newInput(i+4, nodeValue_Slider(   "Intensity",      .5       )).setShaderProp("shadowIntensity");
	newInput(i+5, nodeValue_Slider(   "Shade",           0       )).setShaderProp("shadowShade");
	newInput(i+6, nodeValue_Slider(   "Height Modulate", 0       )).setShaderProp("shadowHeightMod");
	// i+5
	
	array_append(input_display_list, [ 
		[ "Heightmap", false ], i+2, 
		[ "Cast",      false ], i+0, i+1,  
		[ "Rendering", false ], i+3, i+4, i+5, i+6, 
	]);
	
	////- Node
	
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var i = shader_index;
		var _dim = getDimension();
		var _rot = getInputSingle(i+0);
		var cx = _x + _dim[0] / 2 * _s;
		var cy = _y + _dim[1] / 2 * _s;
		
		drawOverlayInput(inputs[i+0].drawOverlay(w_hoverable, active,  cx,  cy, _s, _mx, _my));
		drawOverlayInput(inputs[i+1].drawOverlay(w_hoverable, active,  cx,  cy, _s, _mx, _my, _rot));
		
		return w_hovering;
	}
	
}