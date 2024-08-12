function Node_MK_Cable(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Cable";
	
	inputs[0] = nodeValue_Dimension(self);
	
	inputs[1] = nodeValue_Vec2("Point 1", self, [ 0, 0 ]);
	
	inputs[2] = nodeValue_Vec2("Point 2", self, [ 16, 16 ]);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		["Saber",		false], 1, 2, 
	];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= hv; _hov |= hv;
		var  hv  = inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); active &= hv; _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pnt1 = _data[1];
		var _pnt2 = _data[2];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
		surface_reset_target();
		
		return _outSurf;
	}
}