#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Image_Grid", "Main Axis > Toggle",  "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue(!_n.inputs[0].getValue()); });
	});
#endregion

function Node_Image_Grid(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Image Grid";
	
	var __axis = __enum_array_gen([ "Horizontal", "Vertical" ], s_node_alignment);
	
	////- =Grid
	newInput( 0, nodeValue_EScroll( "Main Axis",  0, __axis ));
	newInput( 1, nodeValue_Int(     "Column",     4         )).setValidator(VV_min(1));
	newInput( 2, nodeValue_Vec2(    "Spacing",   [0,0]      ));
	newInput( 3, nodeValue_Padding( "Padding",   [0,0,0,0]  ));
	
	////- =Fix Grid
	newInput( 5, nodeValue_Bool( "Fix Grid",   false ));
	newInput( 6, nodeValue_Int(  "Fix Amount", 1     ));
	newInput( 7, nodeValue_Vec2( "Empty Size", [1,1] )).setUnitSimple();
	
	////- =Grouping
	newInput( 4, nodeValue_Text(    "Group",     noone      )).setVisible(true, true).setArrayDepth(1);
	// 8
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Atlas data", VALUE_TYPE.atlas, []));
	
	array_foreach(inputs, function(v,i) /*=>*/ { if(i != 4) v.rejectArray(); });
	
	input_display_list = [
		[ "Grid",     false    ],  0,  1,  2,  3, 
		[ "Fix Grid", false, 5 ],  6,  7, 
		[ "Grouping", false    ],  4, 
		[ "Surfaces", false    ], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Surface("Input"))
			.setVisible(true, true);
			
		array_push(input_display_list, inAmo);
		return inputs[index];
	} 
	setDynamicInput(1, true, VALUE_TYPE.surface);
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone ];
	
	static getDimension = function() /*=>*/ {return PROJ_SURF};
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _axis = getInputData(0);
			var _col  = getInputData(1);
			var _spac = getInputData(2);
			var _padd = getInputData(3);
			
			var _fixg = getInputData(5);
			var _fixa = getInputData(6);
			var _fdim = getInputData(7);
			
			var _grup = getInputData(4);
		#endregion
		
		var ww = 0;
		var hh = 0;
		var surfs = [];
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			var _surf = getInputData(i);
			if(!is_array(_surf)) _surf = [ _surf ];
			
			array_append(surfs, _surf);
		}
		
		var _useG = is_array(_grup);
		var _curG = array_safe_get(_grup, 0);
		
		var _coli  = 0;
		var _mainw = 0, _subw  = 0;
		var _mains = 0, _subs  = 0;
		
		var _len = array_length(surfs);
		var _amo = _fixg? _fixa : _len;
		var sw, sh;
		
		for( var j = 0; j < _amo; j++ ) {
			var _s = array_safe_get(surfs, j, noone);
			
			if(is_surface(_s)) {
				sw = surface_get_width_safe(_s);
				sh = surface_get_height_safe(_s);
				
			} else {
				sw = _fdim[0];
				sh = _fdim[1];
			}
			
			if(_axis == 0) { _mains += sw + _spac[0]; _subs = max(_subs, sh + _spac[1]); }
			else           { _mains += sh + _spac[1]; _subs = max(_subs, sw + _spac[0]); }
			
			_coli++;
			var _newL = _coli >= _col;
			
			if(_useG) {
				var _g = array_safe_get(_grup, j + 1);
				if(_curG != _g) _newL = true;
				_curG = _g;
			}
			
			if(_newL) {
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
		var _curG  = array_safe_get(_grup, 0);
		
		for( var j = 0; j < min(_amo, _len); j++ ) {
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
			var _newL = _coli >= _col;
			
			if(_useG) {
				var _g = array_safe_get(_grup, j + 1);
				if(_curG != _g) _newL = true;
				_curG = _g;
			}
			
			if(_newL) {
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
	}
}

