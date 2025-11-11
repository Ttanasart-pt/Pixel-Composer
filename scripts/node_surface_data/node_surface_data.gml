function Node_Surface_data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "Surface data";
	
	newInput(0, nodeValue_Surface("Surface"));
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Dimension", VALUE_TYPE.integer, [ 1, 1 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	newOutput(1, nodeValue_Output("Width", VALUE_TYPE.integer, 1));
	
	newOutput(2, nodeValue_Output("Height", VALUE_TYPE.integer, 1));
	
	newOutput(3, nodeValue_Output("Format String", VALUE_TYPE.text, ""))
		.setVisible(false);
	
	newOutput(4, nodeValue_Output("Bit Depth", VALUE_TYPE.integer, 8))
		.setVisible(false);
	
	newOutput(5, nodeValue_Output("Channels", VALUE_TYPE.integer, 4))
		.setVisible(false);
	
	setDimension(96, 48);
	
	static processData = function(_outData, _data, _array_index = 0) { 
		var _surf = _data[0];
		if(!is_surface(_surf)) return _outData; 
		
		var _dim = surface_get_dimension(_surf);
		_outData[0] = _dim;
		_outData[1] = _dim[0];
		_outData[2] = _dim[1];
		
		var _frm = surface_get_format(_surf);
		_outData[3] = surface_format_string(_frm);
		_outData[4] = surface_format_get_depth(_frm);
		_outData[5] = surface_format_get_channel(_frm);
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_surface_data, 0, bbox);
	}
}