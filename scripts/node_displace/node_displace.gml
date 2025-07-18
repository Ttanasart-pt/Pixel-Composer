#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Displace", "Mode > Toggle",            "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 5].setValue((_n.inputs[ 5].getValue() + 1) % 4); });
		addHotkey("Node_Displace", "Oversample Mode > Toggle", "O", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 7].setValue((_n.inputs[ 7].getValue() + 1) % 3); });
		addHotkey("Node_Displace", "Blend Mode > Toggle",      "B", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[11].setValue((_n.inputs[11].getValue() + 1) % 3); });
		
		addHotkey("Node_Displace", "Iterate > Toggle",         "I", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[ 6].setValue((_n.inputs[ 6].getValue() + 1) % 2); });
		addHotkey("Node_Displace", "Fade Distance > Toggle",   "F", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[19].setValue((_n.inputs[19].getValue() + 1) % 2); });
	});
#endregion

function Node_Displace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Displace";
	
	newActiveInput(10);
	newInput(12, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(8, nodeValue_Surface( "Mask"       ));
	newInput(9, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(8, 13); // inputs 13, 14
	newInput(7, nodeValue_Enum_Scroll("Oversample Mode",  0, [ "Empty", "Clamp", "Repeat" ]));
	
	////- Strength
	
	newInput( 1, nodeValue_Surface( "Displace map"   ));
	newInput(17, nodeValue_Surface( "Displace map 2" ));
	newInput( 3, nodeValue_Float(   "Strength",   1  )).setMappable(15);
	newInput( 4, nodeValue_Slider(  "Mid value", .5  )).setTooltip("Brightness value to be use as a basis for 'no displacement'.");
	
	////- Displacement
	
	newInput( 5, nodeValue_Enum_Button("Mode", 0, [ "Linear", "Vector", "Angle", "Gradient" ]))
		.setTooltip(@"Use color data for extra information.
    - Linear: Displace along a single line (defined by the position value).
    - Vector: Use red as X displacement, green as Y displacement.
    - Angle: Use red as angle, green as distance.
    - Gradient: Displace down the brightness value defined by the Displace map.");
    
	newInput(16, nodeValue_Bool( "Separate axis", false ));
	newInput( 2, nodeValue_Vec2( "Position",      [1,0] )).setTooltip("Vector to displace the pixel by.").setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	
	////- Iterate
	
	newInput( 6, nodeValue_Bool(        "Iterate",       false ));
	newInput(11, nodeValue_Enum_Scroll( "Blend Mode",    0, [ "Overwrite", "Min", "Max" ]));
	newInput(18, nodeValue_Int(         "Iteration",     16    ));
	newInput(19, nodeValue_Bool(        "Fade Distance", false ));
	newInput(20, nodeValue_Bool(        "Reposition",    false ));
	newInput(21, nodeValue_Int(         "Repeat",        1     ));
	
	// inputs 22
	
	input_display_list = [ 10, 12, 
		["Surfaces",	  true], 0, 8, 9, 13, 14, 
		["Strength",	 false], 1, 17, 3, 15, 4,
		["Displacement", false], 5, 16, 2, 
		["Iterate",	      true, 6], 11, 18, 19, 20, 21, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	temp_surface = [ noone, noone ];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static step = function() {
		var _mode = getInputData(5);
		var _sep  = getInputData(16);
		
		var _dsp2 = (_mode == 1 || _mode == 2) && _sep;
		
		inputs[ 2].setVisible(_mode == 0);
		inputs[16].setVisible(_mode == 1 || _mode == 2);
		inputs[17].setVisible(_dsp2, _dsp2);
		
		if(_mode == 1 && _sep) {
			inputs[ 1].setName("Displace X");
			inputs[17].setName("Displace Y");
			
		} else if(_mode == 2 && _sep) {
			inputs[ 1].setName("Displace angle");
			inputs[17].setName("Displace amount");
			
		} else {
			inputs[ 1].setName("Displace map");
		}
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[ 0];
		var _map  = _data[ 1];
		var _sep  = _data[16];
		var _map2 = _data[17];
		var _rept = _data[21]; _rept = max(1, _rept);
		
		var _mode = _data[5];
		if(!is_surface(_map) || (_sep && !is_surface(_map2))) {
			surface_set_shader(_outSurf); 
				draw_surface_safe(_surf);
			surface_reset_shader()
			return _outSurf;
		}
		
		var ww = surface_get_width_safe(  _surf );
		var hh = surface_get_height_safe( _surf );
		var mw = surface_get_width_safe(  _map  );
		var mh = surface_get_height_safe( _map  );
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], ww, hh);
			surface_set_shader(temp_surface[i]); 
				draw_surface_safe(_surf);
			surface_reset_shader();
		}
		
		var bg = 0;
		repeat(_rept) {
			surface_set_shader(temp_surface[bg], sh_displace);
			shader_set_interpolation(_surf);
				shader_set_surface("map",  _map);
				shader_set_surface("map2", _data[17]);
				
				shader_set_f("dimension",     [ww, hh]);
				shader_set_f("map_dimension", [mw, mh]);
				shader_set_f("displace",      _data[ 2]);
				shader_set_f_map("strength",  _data[ 3], _data[15], inputs[3]);
				shader_set_f("middle",        _data[ 4]);
				shader_set_i("mode",          _data[ 5]);
				shader_set_i("sepAxis",       _data[16]);
				
				shader_set_i("iterate",       _data[ 6]);
				shader_set_f("iteration",     _data[18]);
				shader_set_i("blendMode",     _data[11]);
				shader_set_i("fadeDist",      _data[19]);
				shader_set_i("reposition",    _data[20]);
				draw_surface_safe(temp_surface[!bg]);
			surface_reset_shader();
			
			bg = !bg;
		}
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[!bg]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[8], _data[9]);
		_outSurf = channel_apply(_surf, _outSurf, _data[12]);
		
		return _outSurf;
	}
}