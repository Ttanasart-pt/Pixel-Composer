function Node_Stack(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Stack";
	
	inputs[| 0] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Horizontal", "Vertical", "On top" ])
		.rejectArray();
	
	inputs[| 1] = nodeValue("Align", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Start", "Middle", "End"])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.rejectArray();
	
	setIsDynamicInput(1);
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1 )
			.setVisible(true, true);
	} #endregion
	if(!LOADING && !APPENDING) createNewInput();
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, []);
	
	temp_surface = [ noone, noone ];
	
	attribute_surface_depth();
	
	static refreshDynamicInput = function() { #region
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
	} #endregion
	
	static onValueFromUpdate = function(index) { #region
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	} #endregion
	
	static step = function() { #region
		var _axis = getInputData(0);
		
		inputs[| 1].setVisible(_axis != 2);
		inputs[| 2].setVisible(_axis != 2);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _axis = getInputData(0);
		var _alig = getInputData(1);
		var _spac = getInputData(2);
		
		var ww = 0;
		var hh = 0;
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var _surf = getInputData(i);
			if(!is_array(_surf)) _surf = [ _surf ];
			
			for( var j = 0; j < array_length(_surf); j++ ) {
				if(!is_surface(_surf[j])) continue;
				var sw = surface_get_width_safe(_surf[j]);
				var sh = surface_get_height_safe(_surf[j]);
				
				if(_axis == 0) {
					ww += sw + (i > input_fix_len && j == array_length(_surf) - 1) * _spac;
					hh = max(hh, sh);
				} else if(_axis == 1) {
					ww = max(ww, sw);
					hh += sh + (i > input_fix_len && j == array_length(_surf) - 1) * _spac;
				} else if(_axis == 2) {
					ww = max(ww, sw);
					hh = max(hh, sh);
				}
			}
		}
		
		var _outSurf = outputs[| 0].getValue();
		_outSurf     = surface_verify(_outSurf,        ww, hh, attrDepth());
		
		temp_surface[0] = surface_verify(temp_surface[0], ww, hh, attrDepth());
		temp_surface[1] = surface_verify(temp_surface[1], ww, hh, attrDepth());
		
		surface_set_target(temp_surface[0]); DRAW_CLEAR surface_reset_target();
		surface_set_target(temp_surface[1]); DRAW_CLEAR surface_reset_target();
		
		var atlas = [];
		var ppind = 0;
		var sx = 0, sy = 0;
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var _surf = getInputData(i);
			if(!is_array(_surf)) _surf = [ _surf ];
				
			for( var j = 0; j < array_length(_surf); j++ ) {
				if(!is_surface(_surf[j])) continue;
				var sw = surface_get_width_safe(_surf[j]);
				var sh = surface_get_height_safe(_surf[j]);
					
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
					
				array_push(atlas, new SurfaceAtlas(_surf[j], sx, sy));
				surface_set_shader(temp_surface[!ppind], sh_draw_surface);
					DRAW_CLEAR
					BLEND_OVERRIDE
					shader_set_f("dimension", ww, hh);
					
					shader_set_surface("fore", _surf[j]);
					shader_set_f("fdimension", sw, sh);
					shader_set_f("position", sx, sy);
					
					draw_surface(temp_surface[ppind], 0, 0);
					
					BLEND_NORMAL
				surface_reset_shader();
					
				ppind = !ppind;
					
				if(_axis == 0)
					sx += sw + _spac;
				else if(_axis == 1)
					sy += sh + _spac;
			}
		}
		
		surface_set_target(_outSurf);
			DRAW_CLEAR 
			BLEND_OVERRIDE
			
			draw_surface(temp_surface[ppind], 0, 0);
			
			BLEND_NORMAL
		surface_reset_target();
		
		outputs[| 0].setValue(_outSurf);
		outputs[| 1].setValue(atlas);
	} #endregion
}

