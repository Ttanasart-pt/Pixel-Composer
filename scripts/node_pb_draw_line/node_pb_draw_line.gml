function Node_PB_Draw_Line(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Line";
	
	////- Shape
	newInput(pbi+0, nodeValue_Toggle( "Type",      0, array_create(6, THEME.inspector_pb_line) ));
	newInput(pbi+1, nodeValue_Int(    "Thickness", 1     ));
	newInput(pbi+2, nodeValue_Bool(   "Overflow",  false ));
	newInput(pbi+3, nodeValue_Toggle( "Corner",    0, [ "Start", "End" ] ));
	// pbi+4
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+0, pbi+1, pbi+3, pbi+2, 
	]);
	
	////- Nodes
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _type = _data[pbi+0];
		var _thck = _data[pbi+1];
		var _over = _data[pbi+2];
		var _corn = _data[pbi+3];
		
		var _px0 = _x0, _py0 = _y0;
		var _px1 = _x1, _py1 = _y1;
		
		var _thk2 = floor(_thck / 2);
		
		var scr = gpu_get_scissor();
		if(!_over) gpu_set_scissor(_x0 + 1, _y0 + 1, _x1 - _x0, _y1 - _y0)
		
		if(_type & 1 << 0) {
			_px0 = _x0; _py0 = _y1 - _thk2;
			_px1 = _x1; _py1 = _y1 - _thk2; 
			
			if(_thck == 1) draw_line(_px0, _py0, _px1, _py1); 
			else draw_line_width(_px0, _py0, _px1, _py1, _thck);
			
		}
		
		if(_type & 1 << 1) {
			_px0 = _x0; _py0 = _y0 + _thck % 2 + _thk2;
			_px1 = _x1; _py1 = _y0 + _thck % 2 + _thk2; 
			
			if(_thck == 1) draw_line(_px0, _py0, _px1, _py1); 
			else draw_line_width(_px0, _py0, _px1, _py1, _thck);
			
		}
		
		if(_type & 1 << 2) {
			_px0 = _x0 + _thck % 2 + _thk2; _py0 = _y0;
			_px1 = _x0 + _thck % 2 + _thk2; _py1 = _y1; 
			
			if(_thck == 1) draw_line(_px0, _py0, _px1, _py1); 
			else draw_line_width(_px0, _py0, _px1, _py1, _thck);
			
		}
		
		if(_type & 1 << 3) {
			_px0 = _x1 - _thk2; _py0 = _y0;
			_px1 = _x1 - _thk2; _py1 = _y1; 
			
			if(_thck == 1) draw_line(_px0, _py0, _px1, _py1); 
			else draw_line_width(_px0, _py0, _px1, _py1, _thck);
			
		}
		
		if(_type & 1 << 4) {
			_px0 = _x1 + _thk2 * bool(_corn & 01); 
			_py0 = _y0 + _thk2 * bool(_corn & 01); 
			_px1 = _x0 - _thk2 * bool(_corn & 10); 
			_py1 = _y1 - _thk2 * bool(_corn & 10); 
			
			if(_thck == 1) draw_line(_px0, _py0, _px1, _py1); 
			else draw_line_width(_px0, _py0, _px1, _py1, _thck);
			
		}
		
		if(_type & 1 << 5) {
			_px0 = _x0 + _thk2 * bool(_corn & 01); 
			_py0 = _y0 + _thk2 * bool(_corn & 01); 
	    	_px1 = _x1 - _thk2 * bool(_corn & 10); 
	    	_py1 = _y1 - _thk2 * bool(_corn & 10); 
			
			if(_thck == 1) draw_line(_px0, _py0, _px1, _py1); 
			else draw_line_width(_px0, _py0, _px1, _py1, _thck);
		}
			
		gpu_set_scissor(scr);
	}
}