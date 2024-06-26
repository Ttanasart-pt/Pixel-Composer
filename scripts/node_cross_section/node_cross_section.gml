function Node_Cross_Section(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Cross Section";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y" ]);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Anti Aliasing", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 4] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "BW", "Colored" ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone );
	
	input_display_list = [
		["Surfaces", false], 0, 
		["Axis",	 false], 1, 2, 
		["Output",	 false], 4, 3, 
	];
	
	attribute_surface_depth();
		
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, params) { #region
		PROCESSOR_OVERLAY_CHECK
		
		var _surf = getSingleValue(0);
		var _iaxs = getSingleValue(1);
		var _posi = getSingleValue(2);
		
		var _dim  = surface_get_dimension(_surf);
		
		if(_iaxs == 0) {
			var _x0 = _x;
			var _y0 = _y + _posi * _dim[1] * _s;
			var _x1 = _x + _dim[0] * _s;
			var _y1 = _y0;
			
		} else {
			var _x0 = _x + _posi * _dim[0] * _s;
			var _y0 = _y;
			var _x1 = _x0;
			var _y1 = _y + _dim[1] * _s;
		}
		
		draw_set_color(COLORS._main_accent);
		draw_line(_x0, _y0, _x1, _y1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _iaxs = _data[1];
		var _posi = _data[2];
		var _aa   = _data[3];
		var _mode = _data[4];
		
		var _dim  = surface_get_dimension(_surf);
		_outSurf  = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_shader(_outSurf, sh_cross_section);
			shader_set_f("dimension", _dim);
			shader_set_i("iAxis",	  _iaxs);
			shader_set_f("position",  _posi);
			shader_set_i("aa",		  _aa);
			shader_set_i("mode",	  _mode);
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
}