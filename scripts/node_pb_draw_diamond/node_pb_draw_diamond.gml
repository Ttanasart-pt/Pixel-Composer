function Node_PB_Draw_Diamond(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Diamond";
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		
		if(_pbox == noone) return _pbox;
		
		var _nbox = _pbox.clone();
		_nbox.content = surface_verify(_nbox.content, _pbox.w, _pbox.h);
		
		var x0 = 0;
		var y0 = 0;
		
		var x1 = _pbox.w;
		var y1 = _pbox.h;
		
		var xc = _pbox.w / 2;
		var yc = _pbox.h / 2;
		
		surface_set_target(_nbox.content);
			DRAW_CLEAR
			
			draw_set_color(_fcol);
			draw_primitive_begin(pr_trianglelist);
				draw_vertex(xc, y0);
				draw_vertex(x0, yc);
				draw_vertex(x1, yc);
				
				draw_vertex(x0, yc);
				draw_vertex(x1, yc);
				draw_vertex(xc, y1);
			draw_primitive_end();
			
			PB_DRAW_APPLY_MASK
		surface_reset_target();
		
		PB_DRAW_CREATE_MASK
		
		return _nbox;
	}
}