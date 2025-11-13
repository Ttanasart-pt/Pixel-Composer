function Node_Vector_Cart_To_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Cart. to Polar";
	color = COLORS.node_blend_number;
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2("Cartesian Coord", [ 0, 0 ]))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Enum_Button("Angle Unit", 0, [ "Degrees", "Radians" ]))
	
	newOutput(0, nodeValue_Output("Polar Coord", VALUE_TYPE.float, [ 0, 0 ] ))
		.setDisplay(VALUE_DISPLAY.vector);
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _car = _data[0];
		var _rad = _data[1];
		var _len = point_distance(0, 0, _car[0], _car[1]);
		var _ang = arctan2(_car[1], _car[0]);
		if(!_rad) _ang = radtodeg(_ang);
		return [ _len, _ang ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = "Cart2Pol";
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}