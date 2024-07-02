function Node_Normal_Light(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal Light";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Normal map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Normal intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 3] = nodeValue("Ambient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 4] = nodeValue("Light position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, -1 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 5] = nodeValue("Light range", self,	JUNCTION_CONNECT.input, VALUE_TYPE.float, 16);
	
	inputs[| 6] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 32);
	
	inputs[| 7] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 8] = nodeValue("Light type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["Point", "Sun"]);
	
	inputs[| 9] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 9;
		
	input_display_list = [ 9, 0, 
		["Normal",	false], 1, 2, 
		["Light",	false], 3, 8, 4, 5, 6, 7
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[4];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var  hv  = inputs[| 4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		var  hv  = inputs[| 5].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _map = _data[1];
		var _hei = _data[2];
		var _amb = _data[3];
		
		var _light_pos = _data[4];
		var _light_ran = _data[5];
		var _light_int = _data[6];
		var _light_col = _data[7];
		var _light_typ = _data[8];
		
		surface_set_shader(_outSurf, sh_normal_light);
			shader_set_surface("normalMap", _map);
			shader_set_f("normalHeight", _hei);
			shader_set_f("dimension",    surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_color("ambiance", _amb);
			
			shader_set_f("lightPosition",  _light_pos[0], _light_pos[1], _light_pos[2] / 100, _light_ran );
			shader_set_color("lightColor", _light_col);
			shader_set_f("lightIntensity", _light_int);
			shader_set_i("lightType",      _light_typ);
			
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
}