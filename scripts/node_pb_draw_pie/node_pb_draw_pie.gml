function Node_PB_Draw_Pie(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Pie";
	
	newInput(pbi+0, nodeValue_Enum_Button("Corner", 0, array_create(4, s_node_pb_draw_pie_corner)));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0, 
	]);
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _corn = _data[pbi+0];
		var _cx = _x0;
		var _cy = _y0;
		var _cw = _x1 - _x0;
		var _ch = _y1 - _y0;
		
		switch(_corn) {
		    case 0 : _cx = _x0; _cy = _y0; break;
		    case 1 : _cx = _x1; _cy = _y0; break;
		    case 2 : _cx = _x0; _cy = _y1; break;
		    case 3 : _cx = _x1; _cy = _y1; break;
		}
		
		var scr = gpu_get_scissor();
		gpu_set_scissor(_x0 + 1, _y0 + 1, _x1 - _x0, _y1 - _y0)
		
		draw_ellipse(_cx - _cw, _cy - _ch, _cx + _cw, _cy + _ch, false);
		
		gpu_set_scissor(scr);
	}
}