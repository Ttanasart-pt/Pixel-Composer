function Node_PB_Crop_PBBOX(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Crop PBBOX";
	
	newInput(0, nodeValue_Surface("Surface"));
	
	newInput(1, nodeValue_Pbbox());
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pbbox = getSingleValue(1);
		if(is(_pbbox, __pbBox)) _pbbox.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf  = _data[0];
		var _pbbox = _data[1];
		var _bbox  = _pbbox.getBBOX();
		
		var _ww = _bbox[2] - _bbox[0];
		var _hh = _bbox[3] - _bbox[1];
		
		_outSurf = surface_verify(_outSurf, _ww, _hh);
		surface_set_shader(_outSurf);
		    draw_surface_safe(_surf, -_bbox[0], -_bbox[1])
		surface_reset_target();
		
		return _outSurf;
	}
}