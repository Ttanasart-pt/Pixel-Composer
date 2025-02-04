#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Image_Grid", "Main Axis > Toggle",  "A", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[0].setValue(!_n.inputs[0].getValue()); });
	});
#endregion

function Node_Image_Grid(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Image Grid";
	
	newInput(0, nodeValue_Enum_Scroll("Main Axis", self,  0, [ new scrollItem("Horizontal", s_node_alignment, 0), 
												               new scrollItem("Vertical",   s_node_alignment, 1) ]))
		.rejectArray();
	
	newInput(1, nodeValue_Int("Column", self, 4))
		.setValidator(VV_min(1))
		.rejectArray();
	
	newInput(2, nodeValue_Vec2("Spacing", self, [ 0, 0 ]))
		.rejectArray();
	
	newInput(3, nodeValue_Padding("Padding", self, [ 0, 0, 0, 0 ]))
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Atlas data", self, VALUE_TYPE.atlas, []));
	
	temp_surface = [ noone, noone ];
	
	static createNewInput = function() {
		var index = array_length(inputs);
		newInput(index, nodeValue_Surface("Input", self))
			.setVisible(true, true);
			
		return inputs[index];
	} setDynamicInput(1, true, VALUE_TYPE.surface);
	
	attribute_surface_depth();
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _axis = getInputData(0);
		var _col  = getInputData(1);
		var _spac = getInputData(2);
		var _padd = getInputData(3);
		
		var ww = 0;
		var hh = 0;
		var surfs = [];
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			var _surf = getInputData(i);
			if(!is_array(_surf)) _surf = [ _surf ];
			
			array_append(surfs, _surf);
		}
		
		var _coli  = 0;
		
		var _mainw = 0;
		var _subw  = 0;
		
		var _mains = 0;
		var _subs  = 0;
		
		for( var j = 0; j < array_length(surfs); j++ ) {
			var _s = surfs[j];
			if(!is_surface(_s)) continue;
			
			var sw = surface_get_width_safe(_s);
			var sh = surface_get_height_safe(_s);
			
			if(_axis == 0) { _mains += sw + _spac[0]; _subs = max(_subs, sh + _spac[1]); }
			else           { _mains += sh + _spac[1]; _subs = max(_subs, sw + _spac[0]); }
			
			_coli++;
			if(_coli >= _col) {
				_coli  = 0;
				
				_mainw = max(_mainw, _mains);
				_subw += _subs;
				
				_mains = 0;
				_subs  = 0;
			}
		}
		
		_mainw = max(_mainw, _mains);
		_subw += _subs;
		
		if(_axis == 0) { ww = _mainw - _spac[0]; hh = _subw - _spac[1]; }
		else           { hh = _mainw - _spac[1]; ww = _subw - _spac[0]; }
		
		ww += _padd[PADDING.left] + _padd[PADDING.right]; 
		hh += _padd[PADDING.top] + _padd[PADDING.bottom]; 
		
		var _outSurf = outputs[0].getValue();
		_outSurf     = surface_verify(_outSurf, ww, hh, attrDepth());
		
		temp_surface[0] = surface_verify(temp_surface[0], ww, hh, attrDepth());
		temp_surface[1] = surface_verify(temp_surface[1], ww, hh, attrDepth());
		
		surface_clear(temp_surface[0]);
		surface_clear(temp_surface[1]);
		
		var atlas = [];
		var ppind = 0;
		var sx = 0;
		var sy = 0;
		
		var _mains = 0;
		var _subs  = 0;
		var _coli  = 0;
		
		for( var j = 0; j < array_length(surfs); j++ ) {
			var _s = surfs[j];
			if(!is_surface(_s)) continue;
			
			var sw = surface_get_width_safe(_s);
			var sh = surface_get_height_safe(_s);
			
			array_push(atlas, new SurfaceAtlas(_s, sx, sy));
			surface_set_shader(temp_surface[!ppind], sh_draw_surface);
				shader_set_f("dimension", ww, hh);
				
				shader_set_surface("fore", _s);
				shader_set_f("fdimension", sw, sh);
				shader_set_f("position",   sx + _padd[PADDING.left], sy + _padd[PADDING.top]);
					
				draw_surface_safe(temp_surface[ppind]);
			surface_reset_shader();
			ppind = !ppind;
			
			if(_axis == 0) { sx += sw + _spac[0]; _subs = max(_subs, sh); }
			else           { sy += sh + _spac[1]; _subs = max(_subs, sw); }
			
			_coli++;
			if(_coli >= _col) {
				_coli = 0;
				
				if(_axis == 0) { sy += _subs + _spac[1]; sx = 0; } 
				else		   { sx += _subs + _spac[0]; sy = 0; } 
			}
		}
		
		surface_set_shader(_outSurf, noone);
			draw_surface_safe(temp_surface[ppind]);
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
		outputs[1].setValue(atlas);
	} #endregion
}

