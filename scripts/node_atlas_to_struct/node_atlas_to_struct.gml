function Node_Atlas_Struct(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Atlas to Struct";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Atlas())
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Struct", VALUE_TYPE.struct, []))
		.setArrayDepth(1);
		
	static processData = function(_outData, _data, _array_index = 0) {
		var atl = _data[0];
		if(!is(atl, Atlas)) return _outData;
		
		var str = {
			surface :  atl.surface,
			size :     surface_get_dimension(atl.getSurface()),
			position : [ atl.x, atl.y ],
			rotation : atl.rotation,
			scale :    [ atl.sx, atl.sy ],
			blend :    atl.blend,
			alpha :    atl.alpha,
		}
		
		return str;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_atlas_struct, 0, bbox);
	}
}