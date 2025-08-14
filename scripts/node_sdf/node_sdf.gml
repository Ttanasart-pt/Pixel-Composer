#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_SDF", "Side > Toggle",       "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
		addHotkey("Node_SDF", "Keep Alpha > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue(!_n.inputs[4].getValue()); });
		addHotkey("Node_SDF", "Invert > Toggle",     "I", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[5].setValue(!_n.inputs[5].getValue()); });
	});
#endregion

function Node_SDF(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "SDF";
	
	newActiveInput(1);
	
	////- Surface
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- SDF
	
	newInput(2, nodeValue_Enum_Button( "Side",         2, [ "Inside", "Outside", "Both" ]));
	newInput(3, nodeValue_Slider(      "Max distance", 1, [ 0, 2, 0.01 ]));
	newInput(6, nodeValue_Bool(        "Angle",        false));
	
	////- Render
	
	newInput(4, nodeValue_Bool( "Keep Alpha", false));
	newInput(5, nodeValue_Bool( "Invert",     false));
	
	//// input 6
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1,
		["Surfaces", false], 0, 
		["SDF",		 false], 2, 3, 
		["Render",	 false], 4, 5, 6, 
	]
	
	attribute_surface_depth();
	attribute_oversample();
	
	temp_surface = [ noone, noone ];
	
	static processData = function(_outSurf, _data, _array_index) {
		var inSurf = _data[0];
		var _side  = _data[2];
		var _dist  = _data[3];
		var _alph  = _data[4];
		var _invt  = _data[5];
		var _angl  = _data[6];
		
		var sw	   = surface_get_width_safe(inSurf);
		var sh	   = surface_get_height_safe(inSurf);
		var _n	   = max(sw, sh);
		var cDep   = attrDepth();
		
		temp_surface[0] = surface_verify(temp_surface[0], _n, _n, cDep);
		temp_surface[1] = surface_verify(temp_surface[1], _n, _n, cDep);
		_outSurf = surface_verify(_outSurf, sw, sh, cDep);
		
		surface_set_shader(temp_surface[0], sh_sdf_tex);
			draw_surface_safe(inSurf);
		surface_reset_shader();
		
		var _step    = ceil(log2(_n));
		var stepSize = power(2, _step);
		var bg       = 0;
		
		repeat(_step) {
			stepSize /= 2;
			bg = !bg;
			
			surface_set_shader(temp_surface[bg], sh_sdf);
				shader_set_i("sampleMode", getAttribute("oversample"));
				shader_set_f("dimension", _n, _n);
				shader_set_f("stepSize",  stepSize);
				shader_set_i("side",     _side);
				
				draw_surface_safe(temp_surface[!bg]);
			surface_reset_shader();
		}
		
		surface_set_shader(_outSurf, sh_sdf_dist);
			shader_set_surface("original", inSurf);
			shader_set_i("side",         _side);
			shader_set_f("max_distance", _dist);
			shader_set_i("alpha",        _alph);
			shader_set_i("invert",       _invt);
			shader_set_i("angle",        _angl);
			
			draw_surface_safe(temp_surface[bg]);
		surface_reset_shader();
		
		return _outSurf;
	}
}