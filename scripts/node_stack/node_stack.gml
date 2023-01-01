function Node_Stack(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name		= "Stack";
	
	inputs[| 0] = nodeValue(0, "Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Horizontal", "Vertical", "On top" ]);
	
	inputs[| 1] = nodeValue(1, "Align", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Start", "Middle", "End"]);
	
	inputs[| 2] = nodeValue(2, "Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	input_fix_len	= ds_list_size(inputs);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue( index, "Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1 )
			.setVisible(true, true);
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static updateValueFrom = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		var _l = ds_list_create();
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].value_from)	
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static step = function() {
		var _axis = inputs[| 0].getValue();
		
		inputs[| 1].setVisible(_axis != 2);
		inputs[| 2].setVisible(_axis != 2);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _axis = _data[0];
		var _alig = _data[1];
		var _spac = _data[2];
		
		var ww = 0;
		var hh = 0;
		
		for( var i = input_fix_len; i < array_length(_data) - 1; i++ ) {
			if(!is_surface(_data[i])) continue;
			var sw = surface_get_width(_data[i]);
			var sh = surface_get_height(_data[i]);
			
			if(_axis == 0) {
				ww += sw + (i > input_fix_len) * _spac;
				hh = max(hh, sh);
			} else if(_axis == 1) {
				ww = max(ww, sw);
				hh += sh + (i > input_fix_len) * _spac;
			} else if(_axis == 2) {
				ww = max(ww, sw);
				hh = max(hh, sh);
			}
		}
		
		_outSurf = surface_verify(_outSurf, ww, hh);
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			//BLEND_OVERRIDE
			
			var sx = 0, sy = 0;
			for( var i = input_fix_len; i < array_length(_data) - 1; i++ ) {
				if(!is_surface(_data[i])) continue;
				var sw = surface_get_width(_data[i]);
				var sh = surface_get_height(_data[i]);
			
				if(_axis == 0) {
					switch(_alig) {
						case fa_left:	sy = 0;					break;
						case fa_center:	sy = hh / 2 - sh / 2;	break;
						case fa_right:	sy = hh - sh;			break;
					}
				} else if(_axis == 1) {
					switch(_alig) {
						case fa_left:	sx = 0;					break;
						case fa_center:	sx = ww / 2 - sw / 2;	break;
						case fa_right:	sx = ww - sw;			break;
					}
				} else if(_axis == 2) {
					sx = ww / 2 - sw / 2;
					sy = hh / 2 - sh / 2;
				}
				
				draw_surface_safe(_data[i], sx, sy);
				
				if(_axis == 0)
					sx += sw + _spac;
				else if(_axis == 1)
					sy += sh + _spac;
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = 0; i < ds_list_size(_inputs); i++)
			createNewInput();
	}
}

