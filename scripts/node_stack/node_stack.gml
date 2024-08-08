function Node_Stack(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Stack";
	
	inputs[0] = nodeValue_Enum_Scroll("Axis", self,  0, [ new scrollItem("Horizontal", s_node_alignment, 0), 
												 new scrollItem("Vertical",   s_node_alignment, 1), 
												 new scrollItem("On top",     s_node_alignment, 3), ])
		.rejectArray();
	
	inputs[1] = nodeValue_Enum_Button("Align", self,  1, [ "Start", "Middle", "End"])
		.rejectArray();
	
	inputs[2] = nodeValue_Int("Spacing", self, 0)
		.rejectArray();
	
	inputs[3] = nodeValue_Padding("Padding", self, [ 0, 0, 0, 0 ])
		.rejectArray();
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	outputs[1] = nodeValue_Output("Atlas data", self, VALUE_TYPE.surface, []);
	
	temp_surface = [ noone, noone ];
	
	static createNewInput = function() {
		var index = array_length(inputs);
		inputs[index] = nodeValue_Surface("Input", self)
			.setVisible(true, true);
			
		return inputs[index];
	} setDynamicInput(1, true, VALUE_TYPE.surface);
	
	attribute_surface_depth();
	
	static step = function() { #region
		var _axis = getInputData(0);
		
		inputs[1].setVisible(_axis != 2);
		inputs[2].setVisible(_axis != 2);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _axis = getInputData(0);
		var _alig = getInputData(1);
		var _spac = getInputData(2);
		var _padd = getInputData(3);
		
		var ww = 0;
		var hh = 0;
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			var _surf = getInputData(i);
			if(!is_array(_surf)) _surf = [ _surf ];
			
			for( var j = 0; j < array_length(_surf); j++ ) {
				if(!is_surface(_surf[j])) continue;
				var sw = surface_get_width_safe(_surf[j]);
				var sh = surface_get_height_safe(_surf[j]);
				
				if(_axis == 0) {
					ww += sw + _spac;
					hh = max(hh, sh + _spac);
				} else if(_axis == 1) {
					ww = max(ww, sw + _spac);
					hh += sh + _spac;
				} else if(_axis == 2) {
					ww = max(ww, sw);
					hh = max(hh, sh);
				}
			}
		}
		
		ww -= _spac;
		hh -= _spac;
		
		var ow = ww + _padd[PADDING.left] + _padd[PADDING.right]; 
		var oh = hh + _padd[PADDING.top] + _padd[PADDING.bottom]; 
		
		var _outSurf = outputs[0].getValue();
		_outSurf     = surface_verify(_outSurf, ow, oh, attrDepth());
		
		temp_surface[0] = surface_verify(temp_surface[0], ow, oh, attrDepth());
		temp_surface[1] = surface_verify(temp_surface[1], ow, oh, attrDepth());
		
		surface_clear(temp_surface[0]);
		surface_clear(temp_surface[1]);
		
		var atlas = [];
		var ppind = 0;
		var sx = 0, sy = 0;
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
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
					shader_set_f("dimension", ow, oh);
					
					shader_set_surface("fore", _surf[j]);
					shader_set_f("fdimension", sw, sh);
					shader_set_f("position",   sx + _padd[PADDING.left], sy + _padd[PADDING.top]);
					
					draw_surface_safe(temp_surface[ppind]);
					
					BLEND_NORMAL
				surface_reset_shader();
					
				ppind = !ppind;
					
				if(_axis == 0)      sx += sw + _spac;
				else if(_axis == 1) sy += sh + _spac;
			}
		}
		
		surface_set_target(_outSurf);
			DRAW_CLEAR 
			BLEND_OVERRIDE
			
			draw_surface_safe(temp_surface[ppind]);
			
			BLEND_NORMAL
		surface_reset_target();
		
		outputs[0].setValue(_outSurf);
		outputs[1].setValue(atlas);
	} #endregion
}

