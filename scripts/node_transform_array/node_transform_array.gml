function Node_Transform_Array(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Transform Array";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Postion", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.rotation)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Transform", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0, 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 0].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 0].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 1].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		return [_data[0][0], _data[0][1], _data[1], _data[2][0], _data[2][0]];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_transform_array, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}