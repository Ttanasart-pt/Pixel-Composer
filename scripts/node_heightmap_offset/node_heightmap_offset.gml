function Node_Heightmap_Offset(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Offset Heightmap";
	shader = sh_heightmap_offset;
	
	var i = shader_index;
	
	////- =Offset
	newInput(i+0, nodeValue_Vec2("Offset", [.5,.5] )).setUnitSimple().setShaderProp("offset");
	
	array_append(input_display_list, [ 
		[ "Offset", false ], i+0 
	]);
	
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		drawOverlayInput(inputs[shader_index+0].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
		return w_hovering;
	}
	
}