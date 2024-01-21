function Node_Image_Grid(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Image Grid";
	
	inputs[| 0] = nodeValue("Main Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Horizontal", "Vertical" ])
		.rejectArray();
	
	inputs[| 1] = nodeValue("Column", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.rejectArray();
	
	inputs[| 3] = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding)
		.rejectArray();
	
	setIsDynamicInput(1);
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, -1 )
			.setVisible(true, true);
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
	
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
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _axis = getInputData(0);
		var _col  = getInputData(1);
		var _spac = getInputData(2);
		var _padd = getInputData(3);
		
		var ww = 0;
		var hh = 0;
		var surfs = [];
		
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i++ ) {
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
		
		var _outSurf = outputs[| 0].getValue();
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
			
			array_push(atlas, new SurfaceAtlas(_surf[j], sx, sy));
			surface_set_shader(temp_surface[!ppind], sh_draw_surface);
				shader_set_f("dimension", ww, hh);
				
				shader_set_surface("fore", _surf[j]);
				shader_set_f("fdimension", sw, sh);
				shader_set_f("position",   sx + _padd[PADDING.left], sy + _padd[PADDING.top]);
					
				draw_surface(temp_surface[ppind], 0, 0);
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
			draw_surface(temp_surface[ppind], 0, 0);
		surface_reset_shader();
		
		outputs[| 0].setValue(_outSurf);
		outputs[| 1].setValue(atlas);
	} #endregion
}

