#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Zoom", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key)) / 10); });
	});
#endregion

function Node_Blur_Zoom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Zoom Blur";
	
	newActiveInput(8);
	newInput(9, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- Surface
	
	newInput(0, nodeValue_Surface( "Surface In", self));
	newInput(6, nodeValue_Surface( "Mask",       self));
	newInput(7, nodeValue_Slider(  "Mix",        self, 1));
	__init_mask_modifier(6, 10);
	newInput(5, nodeValue_Surface("Blur mask", self));
	
	////- Blur
	
	newInput( 4, nodeValue_Enum_Scroll( "Zoom origin",  self, 1, [ "Start", "Middle", "End" ]));
	newInput(15, nodeValue_Enum_Button( "Mode",         self, 0, [ "Blur", "Step" ]));
	newInput( 1, nodeValue_Float(       "Strength",     self, 0.2)).setMappable(12);
	newInput(12, nodeValueMap(          "Strength map", self));
	newInput( 2, nodeValue_Vec2(        "Center",       self, [ 0.5, 0.5 ])).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	////- Render
		
	newInput( 3, nodeValue_es(   "Oversample mode",  self, 0, [ "Empty", "Clamp", "Repeat" ]));
	newInput(14, nodeValue_Int(  "Samples",          self, 64));
	newInput(13, nodeValue_Bool( "Gamma Correction", self, false));
	newInput(16, nodeValue_Bool( "Fade",             self, false));
	
	// inputs 17
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 8, 9,
		["Surfaces", true],	0, 6, 7, 10, 11, 5, 
		["Blur",	false],	15, 4, 1, 12, 2, 
		["Render",	false],	14, 13, 16, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos  = getInputData(2);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny, 0, 64));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _sam = getAttribute("oversample");
		
		var _cen = array_clone(_data[2]);
		_cen[0] /= surface_get_width_safe(_outSurf);
		_cen[1] /= surface_get_height_safe(_outSurf);
		
		surface_set_shader(_outSurf, _data[15]? sh_blur_zoom_step : sh_blur_zoom);
			shader_set_2("center",       _cen);
			shader_set_f_map("strength", _data[1], _data[12], inputs[1]);
			shader_set_i("blurMode",     _data[4]);
			shader_set_i("sampleMode",   _sam);
			shader_set_i("gamma",        _data[13]);
			shader_set_i("samples",      _data[14]);
			shader_set_i("fadeDistance", _data[16]);
			
			shader_set_i("useMask", is_surface(_data[5]));
			shader_set_surface("mask", _data[5]);
				
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[6], _data[7]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	}
}