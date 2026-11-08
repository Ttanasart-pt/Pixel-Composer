function Node_Filter_Direction(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Filter Direction";
	shader = sh_filter_direction;
	
	var i = shader_index;
	
	////- =Direction
	newInput(i+0, nodeValue_Rot(   "Direction", 90 )).setShaderProp("direction").setHotkey("R");
	newInput(i+1, nodeValue_Float( "Range",      0 )).setShaderProp("sweep");
	
	////- =Range
	newInput(i+2, nodeValue_Float( "Radius",    .1 )).setUnitSimple().setShaderProp("radius").setHotkey("S");
	
	////- =Rendering
	newInput(i+3, nodeValue_Bool( "Shaded",       true )).setShaderProp("shade");
	newInput(i+4, nodeValue_Bool( "Transparent", false )).setShaderProp("transparent");
	// i+5
	
	array_append(input_display_list, [ 
		[ "Direction", false ], i+0, i+1, 
		[ "Range",     false ], i+2, 
		[ "Rendering", false ], i+3, i+4, 
	]);
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		var i = shader_index;
		drawOverlayInput(inputs[i+0].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		drawOverlayInput(inputs[i+2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		
		return w_hovering;
	}
	
}