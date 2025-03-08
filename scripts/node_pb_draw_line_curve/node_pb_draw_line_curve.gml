function Node_PB_Draw_Curve(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Curve";
	
	newInput(pbi+0, nodeValue_Enum_Button("Type", self, 0, array_create(6, THEME.inspector_pb_line)));
	
	newInput(pbi+1, nodeValue_Int("Thickness", self, 1));
	
	newInput(pbi+2, nodeValue_Bool("Overflow", self, true));
	
	newInput(pbi+3, nodeValue_s("Bend", self, .5, { range: [ -1, 1, 0.01 ] }));
	
	newInput(pbi+4, nodeValue_Int("Segments", self, 8));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0, pbi+1, pbi+2, pbi+3, pbi+4, 
	]);
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _type = _data[pbi+0];
		var _thck = _data[pbi+1];
		var _over = _data[pbi+2];
		var _bend = _data[pbi+3];
		var _segs = _data[pbi+4];
		
		var _sw = _x1 - _x0;
		var _sh = _y1 - _y0;
		
		var _px0 = _x0, _py0 = _y0;
		var _px1 = _x1, _py1 = _y1;
		
		var _thk2 = floor(_thck / 2);
		var _dirr = 0;
		
		switch(_type) {
			case 0 : _px0 = _x0; _py0 = _y1 - _thk2;
				     _px1 = _x1; _py1 = _y1 - _thk2; 
				     
				     _dirr  = 90;
				     _bend *= _sh;
				     break;
			
			case 1 : _px0 = _x0; _py0 = _y0 + _thck % 2 + _thk2;
				     _px1 = _x1; _py1 = _y0 + _thck % 2 + _thk2; 
				     
				     _dirr  = -90;
				     _bend *= _sh;
				     break;
			
			case 2 : _px0 = _x0 + _thck % 2 + _thk2; _py0 = _y0;
				     _px1 = _x0 + _thck % 2 + _thk2; _py1 = _y1; 
				     
				     _dirr  = 0;
				     _bend *= _sw;
				     break;
			
			case 3 : _px0 = _x1 - _thk2; _py0 = _y0;
				     _px1 = _x1 - _thk2; _py1 = _y1; 
				     
				     _dirr  = 180;
				     _bend *= _sw;
				     break;
			
			case 4 : _px0 = _x1; _py0 = _y0; 
				     _px1 = _x0; _py1 = _y1; 
			         
			         _dirr  = 135;
				     _bend *= sqrt(_sw * _sw + _sh * _sh) / 2;
			         break;
			
			case 5 : _px0 = _x0; _py0 = _y0; 
		    	     _px1 = _x1; _py1 = _y1; 
			         
			         _dirr  = 45;
				     _bend *= sqrt(_sw * _sw + _sh * _sh) / 2;
			         break;
			
		}
		
		var scr = gpu_get_scissor();
		if(!_over) gpu_set_scissor(_x0 + 1, _y0 + 1, _x1 - _x0, _y1 - _y0)
		
		var ox, oy, nx, ny;
		var cc;
		
		for( var i = 0; i <= _segs; i++ ) {
		    nx = lerp(_px0, _px1, i / _segs);
		    ny = lerp(_py0, _py1, i / _segs);
		    
		    cc  = sqrt(1 - power((i / _segs - .5) * 2, 2));
		    nx += lengthdir_x(cc * _bend, _dirr);
            ny += lengthdir_y(cc * _bend, _dirr);
		    
		    if(i) {
		        if(_thck == 1) draw_line(ox, oy, nx, ny);
		        else draw_line_round(ox, oy, nx, ny, _thck);
		    }
		    
		    ox = nx;
		    oy = ny;
		}
		
		gpu_set_scissor(scr);
	}
}