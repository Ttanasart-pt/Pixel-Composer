function Node_Normal_Light(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal Light";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	
	inputs[1] = nodeValue_Surface("Normal map", self);
	
	inputs[2] = nodeValue_Float("Normal intensity", self, 1);
	
	inputs[3] = nodeValue_Color("Ambient", self, c_black);
	
	inputs[4] = nodeValue_Vector("Light position", self, [ 0, 0 ])
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[5] = nodeValue_Float("Light range", self, 16);
	
	inputs[6] = nodeValue_Float("Light intensity", self, 32);
	
	inputs[7] = nodeValue_Color("Light color", self, c_white);
	
	inputs[8] = nodeValue_Enum_Button("Light type", self,  0, ["Point", "Sun"]);
	
	inputs[9] = nodeValue_Bool("Active", self, true);
		active_index = 9;
		
	inputs[10] = nodeValue_Float("Light height", self, 1);
	
	input_display_list = [ 9, 0, 
		["Normal",	false], 1, 2, 
		["Light",	false], 3, 8, 4, 10, 5, 6, 7
	];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[4];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var  hv  = inputs[4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		var  hv  = inputs[5].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _map = _data[1];
		var _hei = _data[2];
		var _amb = _data[3];
		
		var _light_pos = _data[ 4];
		var _light_ran = _data[ 5];
		var _light_int = _data[ 6];
		var _light_col = _data[ 7];
		var _light_typ = _data[ 8];
		var _light_hei = _data[10];
		
		var _dim = surface_get_dimension(_data[0]);
		
		surface_set_shader(_outSurf, sh_normal_light);
			shader_set_surface("normalMap", _map);
			shader_set_f("normalHeight",    _hei);
			shader_set_f("dimension",       _dim);
			shader_set_color("ambiance",    _amb);
			
			shader_set_f("lightPosition",  _light_pos[0], _light_pos[1], -_light_hei / 100, _light_ran );
			shader_set_color("lightColor", _light_col);
			shader_set_f("lightIntensity", _light_int);
			shader_set_i("lightType",      _light_typ);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}