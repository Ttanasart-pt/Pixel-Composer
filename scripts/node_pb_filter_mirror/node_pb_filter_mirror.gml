function Node_PB_Filter_Mirror(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "PB Mirror";
	
	newInput(0, nodeValue_Pbbox());
	
	newInput(1, nodeValue_Surface("Surface"));
	
	newInput(2, nodeValue_Toggle("Axis", 0, { data: [ "X", "Y" ] }));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Layout", false], 0, 1, 
		["Mirror", false], 2, 
	]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pbase = getSingleValue(0);
		var _axis  = getSingleValue(2);
		
		if(is(_pbase, __pbBox)) {
			draw_set_color(COLORS._main_icon);
			_pbase.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
			
			var _basebox = _pbase.getBBOX();
			if(_axis & 0b01) {
				var _mr = (_basebox[0] + _basebox[2]) / 2;
				draw_line_dashed(
					_x + _s * _mr, 
					_y + _s * _basebox[1],
					_x + _s * _mr, 
					_y + _s * _basebox[3],
				);
			}
			
			if(_axis & 0b10) {
				var _mr = (_basebox[1] + _basebox[3]) / 2;
				draw_line_dashed(
					_x + _s * _basebox[0],
					_y + _s * _mr, 
					_x + _s * _basebox[2],
					_y + _s * _mr, 
				);
			}
			
		}
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim   = group.dimension;
		var _pbase = _data[0];
		var _surf  = _data[1];
		var _axis  = _data[2];
		
		if(inputs[0].value_from == noone) _pbase.base_bbox = [ 0, 0, _dim[0], _dim[1] ];
		var _bbox = _pbase.getBBOX();
		var _dim  = surface_get_dimension(_surf);
		
		var _mx = (_bbox[0] + _bbox[2]) - _dim[0];
		var _my = (_bbox[1] + _bbox[3]) - _dim[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_shader(_outSurf);
		    draw_surface_ext_safe(_surf);
		    
    		if(_axis  & 0b01) draw_surface_ext_safe(_surf, _dim[0] + _mx,             0, -1,  1);
    		if(_axis  & 0b10) draw_surface_ext_safe(_surf,             0, _dim[1] + _my,  1, -1);
    		if(_axis == 0b11) draw_surface_ext_safe(_surf, _dim[0] + _mx, _dim[1] + _my, -1, -1);
    		
    	surface_reset_shader();
		
		return _outSurf;
	}
	
}