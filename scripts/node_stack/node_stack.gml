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
	
	input_fix_len = ds_list_size(inputs);
	data_length = 1;
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1 )
			.setVisible(true, true);
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.atlas, []);
	
	attribute_surface_depth();
	
	static refreshDynamicInput = function() {
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
	
	static onValueFromUpdate = function(index) {
		if(index < input_fix_len) return;
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static step = function() {
		var _axis = inputs[| 0].getValue();
		
		inputs[| 1].setVisible(_axis != 2);
		inputs[| 2].setVisible(_axis != 2);
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _axis = inputs[| 0].getValue();
		var _alig = inputs[| 1].getValue();
		var _spac = inputs[| 2].getValue();
		
		var ww = 0;
		var hh = 0;
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
			var _surf = inputs[| i].getValue();
			if(!is_array(_surf)) _surf = [ _surf ];
			
			for( var j = 0; j < array_length(_surf); j++ ) {
				if(!is_surface(_surf[j])) continue;
				var sw = surface_get_width(_surf[j]);
				var sh = surface_get_height(_surf[j]);
				
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
		_outSurf = surface_verify(_outSurf, ww, hh, attrDepth());
		outputs[| 0].setValue(_outSurf);
		
		var atlas = [];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_ALPHA;
			
			var sx = 0, sy = 0;
			for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
				var _surf = inputs[| i].getValue();
				if(!is_array(_surf)) _surf = [ _surf ];
				
				for( var j = 0; j < array_length(_surf); j++ ) {
					if(!is_surface(_surf[j])) continue;
					var sw = surface_get_width(_surf[j]);
					var sh = surface_get_height(_surf[j]);
					
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
					
					array_push(atlas, new SurfaceAtlas(_surf[j], [ sx, sy ]));
					draw_surface_safe(_surf[j], sx, sy);
					
					if(_axis == 0)
						sx += sw + _spac;
					else if(_axis == 1)
						sy += sh + _spac;
				}
			}
			
			BLEND_NORMAL;
		surface_reset_target();
		
		outputs[| 1].setValue(atlas);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = input_fix_len; i < array_length(_inputs); i += data_length)
			createNewInput();
	}
}

