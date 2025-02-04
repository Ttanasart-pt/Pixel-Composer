#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Directional", "Strength > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key)) / 10); });
	});
#endregion

function Node_Blur_Directional(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Directional Blur";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Float("Strength", self, 0.2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] })
		.setMappable(9);
	
	newInput(2, nodeValue_Rotation("Direction", self, 0))
		.setMappable(10);
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput( 9, nodeValueMap("Strength map", self));
	
	newInput(10, nodeValueMap("Direction map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValue_Bool("Single direction",   self, false));
	
	newInput(12, nodeValue_Bool("Gamma Correction", self, false));
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Blur",	false], 1, 9, 2, 10, 11, 12, 
	]
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return;
			_surf = _surf[preview_index];
		}
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		var _hov = false;
		
		var hv = inputs[2].drawOverlay(hover, active, _x + ww / 2 * _s, _y + hh / 2 * _s, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	} #endregion
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[ 1].mappableStep();
		inputs[ 2].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_blur_directional);
			shader_set_f("size",          max(surface_get_width_safe(_data[0]), surface_get_height_safe( _data[0])));
			shader_set_f_map("strength",  _data[ 1], _data[ 9], inputs[ 1]);
			shader_set_f_map("direction", _data[ 2], _data[10], inputs[ 2]);
			shader_set_i("scale",         _data[11]);
			shader_set_i("gamma",         _data[12]);
			shader_set_i("sampleMode",	  getAttribute("oversample"));
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	} #endregion
}