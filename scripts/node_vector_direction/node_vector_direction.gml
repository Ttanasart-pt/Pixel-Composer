function Node_Vector_Direction(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Vector Direction";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2(        "Vector", [ 0, 0 ])).setVisible(true, true);
	newInput(1, nodeValue_Enum_Button( "Unit", 0, [ "Degree", "Radians" ]));
	
	newOutput(0, nodeValue_Output("Direction", VALUE_TYPE.float, 0));
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		var _vec  = _data[0];
		var _unit = _data[1];
		if(!is_array(_vec) || array_empty(_vec)) return 0;
		
		var _ang = point_direction(0, 0, _vec[0], _vec[1]);
		if(_unit) _ang = degtorad(_ang);
		
		return _ang;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var val  = outputs[0].getValue();
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(val));
	}
}