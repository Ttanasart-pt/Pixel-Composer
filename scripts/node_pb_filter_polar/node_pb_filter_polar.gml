function Node_PB_Filter_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "PB Polar";
	
	newInput(0, nodeValue_Pbbox());
	
	newInput(1, nodeValue_Surface("Surface"));
	
	newInput(2, nodeValue_Int("Copies", 4));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Layout", false], 0, 1, 
		["Polar",  false], 2, 
	]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pbase = getInputSingle(0);
		
		if(is(_pbase, __pbBox)) {
			draw_set_color(COLORS._main_icon);
			_pbase.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, self);
		}
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim   = group.dimension;
		var _pbase = _data[0];
		var _surf  = _data[1];
		var _amou  = _data[2];
		
		if(inputs[0].value_from == noone) _pbase.base_bbox = [ 0, 0, _dim[0], _dim[1] ];
		var _bbox = _pbase.getBBOX();
		var _dim  = surface_get_dimension(_surf);
		var _dw   = _dim[0] / 2;
		var _dh   = _dim[1] / 2;
		
		var _mx = (_bbox[0] + _bbox[2]) / 2;
		var _my = (_bbox[1] + _bbox[3]) / 2;
		
		var _st = 360 / _amou;
		var _p  = [ 0, 0 ];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		surface_set_shader(_outSurf);
		    for( var i = 0, n = _amou; i < n; i++ ) {
		        var _a = i * _st;
		        _p = point_rotate(0, 0, _mx, _my, _a, _p);
		        draw_surface_ext_safe(_surf, _p[0], _p[1], 1, 1, _a);
		    }
		    
    	surface_reset_shader();
		
		return _outSurf;
	}
	
}