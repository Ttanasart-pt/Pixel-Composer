function Node_Transform_Array(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Transform Array";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_transform_array);
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2("Postion", [ 0, 0 ] ))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Rotation("Rotation", 0))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Vec2("Scale", [ 1, 1 ] ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Transform", VALUE_TYPE.float, [ 0, 0, 0, 1, 1 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var pos = current_data[0];
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		return [_data[0][0], _data[0][1], _data[1], _data[2][0], _data[2][0]];
	}
	
}