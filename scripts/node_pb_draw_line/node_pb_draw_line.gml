function Node_PB_Draw_Line(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Line";
	
	newInput(3, nodeValue_Enum_Button("Direction", self,  0 , [ THEME.obj_draw_line, THEME.obj_draw_line, THEME.obj_draw_line, THEME.obj_draw_line ] ));
	
	newInput(4, nodeValue_Int("Thickness", self, 2 ))
	
	input_display_list = [
		["Draw",	false], 0, 1, 2, 
		["Shape",	false], 3, 4, 
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pbox = _data[0];
		var _fcol = _data[1];
		var _mask = _data[2];
		
		var _dirr = _data[3];
		var _thck = _data[4];
		
		if(_pbox == noone) return _pbox;
		
		var _nbox = _pbox.clone();
		_nbox.content = surface_verify(_nbox.content, _pbox.w, _pbox.h);
		
		surface_set_target(_nbox.content);
			DRAW_CLEAR
			
			var x0 = 0, y0 = 0;
			var x1 = 0, y1 = 0;
			
			     if(_dirr == 2 && (_pbox.mirror_h ^^ _pbox.mirror_v)) _dirr = 3;
			else if(_dirr == 3 && (_pbox.mirror_h ^^ _pbox.mirror_v)) _dirr = 2;
			
			switch(_dirr) {
				case 0 : 
					x0 = _pbox.w / 2;
					y0 = 0;
					
					x1 = _pbox.w / 2;
					y1 = _pbox.h;
					break;
				case 1 :
					x0 = 0;
					y0 = _pbox.h / 2;
					
					x1 = _pbox.w;
					y1 = _pbox.h / 2;
					break;
				case 2 :
					x0 = _pbox.w;
					y0 = 0;
					
					x1 = 0;
					y1 = _pbox.h;
					break;
				case 3 :
					x0 = 0;
					y0 = 0;
					
					x1 = _pbox.w;
					y1 = _pbox.h;
					break;
				
			}
			
			draw_set_color(_fcol);
			if(_thck == 1)		  draw_line(x0 - 1, y0 - 1, x1 - 1, y1 - 1);
			else			draw_line_width(x0 - 1, y0 - 1, x1 - 1, y1 - 1, _thck);
			
			PB_DRAW_APPLY_MASK
		surface_reset_target();
		
		PB_DRAW_CREATE_MASK
		
		return _nbox;
	}
}