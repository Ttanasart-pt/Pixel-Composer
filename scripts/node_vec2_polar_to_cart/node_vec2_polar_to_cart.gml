function Node_Vector_Polar_To_Cart(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Polar to Cart.";
	color = COLORS.node_blend_number;
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2("Polar Coord", [ 0, 0 ]))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Enum_Button("Angle Unit", 0, [ "Degrees", "Radians" ]))
	
	newOutput(0, nodeValue_Output("Cartesian Coord", VALUE_TYPE.float, [ 0, 0 ] ))
		.setDisplay(VALUE_DISPLAY.vector);
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _pol = _data[0];
		var _rad = _data[1];
		var _len = _pol[0];
		var _ang = _rad? radtodeg(_pol[1]) : _pol[1];
		return [ lengthdir_x(_len, _ang), lengthdir_y(_len, _ang) ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = "Pol2Cart";
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}