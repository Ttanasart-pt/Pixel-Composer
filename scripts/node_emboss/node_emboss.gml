function Node_Emboss(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Emboss";
	shader = sh_emboss;
	
	var i = shader_index;
	
	newInput(i+5, nodeValue_Surface(  "Heightmap"         )).setShaderProp("heightMap");
	
	////- =Emboss
	newInput(i+6, nodeValue_Int(      "Height",         1 )).setShaderProp("height");
	newInput(i+0, nodeValue_Rotation( "Direction",    135 )).setShaderProp("direction");
	/**/ newInput(i+2, nodeValue_Bool(     "Deboss",     false )).setShaderProp("deboss");
	/**/ newInput(i+9, nodeValue_Bool(     "Deboss",     false )).setShaderProp("deboss");
	
	////- =Rendering
	newInput(i+4, nodeValue_Color(    "Color",   ca_white )).setShaderProp("color");
	newInput(i+1, nodeValue_Float(    "Intensity",      1 )).setMappable(i+3).setShaderProp("intensity");
	newInput(i+8, nodeValue_Bool(     "Normalize",   true )).setShaderProp("doNormal");
	newInput(i+7, nodeValue_Bool(     "High-res",   false )).setShaderProp("hires");
	// i+10
	
	array_insert_after(input_display_list, 0, [i+5]);
	
	array_append(input_display_list, [ 
		[ "Emboss",    false ], i+6, i+0, 
		[ "Rendering", false ], i+4, i+1, i+3, i+8, i+7, 
	]);
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _dim = getDimension();
	    var _cx  = _x + _dim[0] / 2 * _s;
	    var _cy  = _y + _dim[1] / 2 * _s;
	    
	    drawOverlayInput(inputs[ 0].drawOverlay(w_hoverable, active,  _cx,  _cy, _s, _mx, _my));
	    
	    return w_hovering;
	}
	
}