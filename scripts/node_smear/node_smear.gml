#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Smear", "Strength > Set",         KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Smear", "Direction > Rotate CCW", "R", MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 90) % 360); });
		addHotkey("Node_Smear", "Mode > Toggle",          "M", MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS _n.inputs[11].setValue(!_n.inputs[11].getValue()); });
		addHotkey("Node_Smear", "Blend Mode > Toggle",    "B", MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS _n.inputs[15].setValue(!_n.inputs[15].getValue()); });
		addHotkey("Node_Smear", "Normalize > Toggle",     "N", MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS _n.inputs[16].setValue(!_n.inputs[16].getValue()); });
	});
#endregion

function Node_Smear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Smear";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(18, nodeValue_Surface( "UV Map"     ));
	newInput(19, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 4, nodeValue_Slider(  "Mix",    1  ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- Smear
	newInput(11, nodeValue_Enum_Button( "Mode",       0, [ "Greyscale", "Alpha" ] ));
	newInput(14, nodeValue_Bool(        "Invert",     false          ));
	newInput( 1, nodeValue_Slider(      "Strength",  .2, [0,.5,.001] )).setHotkey("S").setMappable( 9);
	newInput( 2, nodeValue_Rotation(    "Direction",  0              )).setHotkey("R").setMappable(10).hideLabel();
	newInput(13, nodeValue_Slider(      "Spread",     0, [0,30,1 ]   ));
	newInput(12, nodeValue_Enum_Button( "Modulate strength", 0, [ "Distance", "Color", "None" ] ));
	
	////- Render
	newInput(16, nodeValue_Enum_Scroll( "Render Mode", 0, [ "Distance", "Distance Normalized", "Base Color" ] ));
	newInput(15, nodeValue_Enum_Scroll( "Blend Mode",  0, [ "Maximum", "Additive" ]));
	newInput(17, nodeValue_Color(       "Blend Side",  ca_white));
	//// Inputs 20
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 18, 19, 3, 4, 7, 8, 
		["Smear",	false], 11, 14, 1, 9, 2, 10, 13, 12, 
		["Render",  false], 16, 15, 17, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _dim  = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_smear);
			shader_set_uv(_data[18], _data[19]);
			
			shader_set_f("dimension",     _dim);
			shader_set_f("size",          max(_dim[0], _dim[1]));
			
			shader_set_f_map("strength",  _data[ 1], _data[ 9], inputs[ 1]);
			shader_set_f_map("direction", _data[ 2], _data[10], inputs[ 2]);
			shader_set_i("sampleMode",	  getAttribute("oversample"));
			shader_set_i("alpha",	      _data[11]);
			shader_set_i("inv",	    	  _data[14]);
			shader_set_i("blend",    	  _data[15]);
			shader_set_i("modulateStr",   _data[12]);
			shader_set_f("spread",        _data[13]);
			shader_set_i("rMode",         _data[16]);
			shader_set_c("blendSide",     _data[17]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}