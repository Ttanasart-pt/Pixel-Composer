function Node_Mirror_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar Mirror";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Rotation("Angle", self, 0));
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	newInput(4, nodeValue_Float("Spokes", self, 4));
	
	newInput(5, nodeValue_Bool("Reflective", self, false));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3,
		["Surfaces", false], 0, 
		["Mirror",	 false], 1, 2, 
		["Spokes",	 false], 4, 5, 
	]
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _pos   = current_data[1];
		var _ang   = current_data[2];
		var _posx = _pos[0] * _s + _x;
		var _posy = _pos[1] * _s + _y;
		
		var dx0 = _posx + lengthdir_x(1000, _ang);
		var dx1 = _posx + lengthdir_x(1000, _ang + 180);
		var dy0 = _posy + lengthdir_y(1000, _ang);
		var dy1 = _posy + lengthdir_y(1000, _ang + 180);
		
		draw_set_color(COLORS._main_accent);
		draw_line(dx0, dy0, dx1, dy1);
		
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);		active &= !hv; _hov |= hv;
		var  hv  = inputs[2].drawOverlay(hover, active, _posx, _posy, _s, _mx, _my, _snx, _sny);  active &= !hv; _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _suf = _data[0];
		var _pos = _data[1];
		var _ang = _data[2];
		var _spk = _data[4];
		var _ref = _data[5];
		
		var _dim = surface_get_dimension(_suf);
		
		surface_set_shader(_outSurf, sh_mirror_polar);
			shader_set_f("dimension", _dim);
			shader_set_2("position",  _pos);
			shader_set_f("angle",     degtorad(_ang));
			shader_set_f("spokes",    _spk);
			shader_set_i("reflecc",   _ref);
			
			draw_surface_safe(_suf);
		surface_reset_shader();
		
		return _outSurf;
	}
}