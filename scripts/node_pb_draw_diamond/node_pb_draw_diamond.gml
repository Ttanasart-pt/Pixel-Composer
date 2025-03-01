function Node_PB_Draw_Diamond(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Diamond";
	
	newInput(pbi+0, nodeValue_Enum_Scroll("Corner", self, 0, [ "Scale", "Minimum" ]));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0, 
	]);
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0];
		var _y0 = _bbox[1];
		var _x1 = _bbox[2];
		var _y1 = _bbox[3];
		
		var _ww = _x1 - _x0;
		var _hh = _y1 - _y0;
		
		var _cor = _data[pbi+0];
		
		shader_set(sh_pb_diamond);
			shader_set_2("dimension",  [ _ww, _hh ]);
			shader_set_i("cornerType", _cor);
			
			draw_sprite_stretched(s_fx_pixel, 0, _x0, _y0, _ww, _hh);
		shader_reset();
	}
}