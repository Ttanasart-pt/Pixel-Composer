function Node_Atlas_Get(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Atlas Get";
	previewable = true;
	dimension_index = -1;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Atlas())
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, []))
		.setArrayDepth(1);
	
	newOutput(1, nodeValue_Output("Position", VALUE_TYPE.float, []))
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
	
	newOutput(2, nodeValue_Output("Rotation", VALUE_TYPE.float, []))
		.setArrayDepth(1);
	
	newOutput(3, nodeValue_Output("Scale", VALUE_TYPE.float, []))
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
		
	newOutput(4, nodeValue_Output("Blend", VALUE_TYPE.color, []))
		.setArrayDepth(1);
		
	newOutput(5, nodeValue_Output("Alpha", VALUE_TYPE.float, []))
		.setArrayDepth(1);
	
	static processData = function(_outData, _data, _array_index = 0) {
		var atl = _data[0];
		
		if(!is(atl, Atlas)) return _outData;

		_outData[0] = atl.getSurface();
		_outData[1] = [ atl.x, atl.y ];
		_outData[2] = atl.rotation;
		_outData[3] = [ atl.sx, atl.sy ];
		_outData[4] = atl.blend;
		_outData[5] = atl.alpha;
		
		return _outData;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_atlas_get, 0, bbox);
	}
}