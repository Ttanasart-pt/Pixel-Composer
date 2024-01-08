function Node_Surface_From_Color(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name	= "Surface from Color";
	
	inputs[| 0] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	outputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _col = _data[0];
		
		if(!is_array(_col)) _col = [ _col ];
		
		var w = array_length(_col);
		
		_outSurf = surface_verify(_outSurf, w, 1);
		
		surface_set_target(_outSurf);
		for( var i = 0, n = array_length(_col); i < n; i++ ) {
			draw_set_alpha(_color_get_alpha(_col[i]));
			draw_point_color(i, 0, _col[i]);
		}
		draw_set_alpha(1);
		surface_reset_target();
		
		return _outSurf;
	}
}