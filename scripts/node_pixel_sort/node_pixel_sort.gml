#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Pixel_Sort", "Iteration > Set", KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
		addHotkey("Node_Pixel_Sort", "Direction > Rotate CCW", "R", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[3].setValue((_n.inputs[3].getValue() + 90) % 360);  });
	});
#endregion

function Node_Pixel_Sort(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Sort";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Int("Iteration", self, 2));
	
	newInput(2, nodeValue_Float("Threshold", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Int("Direction", self, 0))
		.setDisplay(VALUE_DISPLAY.rotation, { step: 90 });
	
	newInput(4, nodeValue_Surface("Mask", self));
	
	newInput(5, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(6, nodeValue_Bool("Active", self, true));
		active_index = 6;
	
	newInput(7, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(4); // inputs 8, 9
	
	input_display_list = [ 6, 7, 
		["Surfaces",	 true], 0, 4, 5, 8, 9, 
		["Pixel sort",	false], 1, 2, 3, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	temp_surface = [ 0, 0 ];
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		
		var _it = _data[1];
		var _tr = _data[2];
		var _dr = floor(_data[3] / 90) % 4;
		if(_dr < 0)  _dr = 4 + _dr;
		if(_it <= 0) {
			surface_set_target(_outSurf);
				BLEND_OVERRIDE
				draw_surface_safe(_surf);
				BLEND_NORMAL
			surface_reset_target();
		
			return _outSurf;
		}
		
		var sw = surface_get_width_safe(_surf);
		var sh = surface_get_height_safe(_surf);
		
		temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
		temp_surface[1] = surface_verify(temp_surface[1], sw, sh);
		
		var sBase, sDraw;
		
		surface_set_target(temp_surface[1]);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface_safe(_surf);
			BLEND_NORMAL
		surface_reset_target();
		
		shader_set(sh_pixel_sort);
		shader_set_2("dimension", [sw, sh]);
		shader_set_f("threshold", _tr);
		shader_set_i("direction", _dr);
		
		for( var i = 0; i < _it; i++ ) {
			var it = i % 2;
			sBase = temp_surface[it];
			sDraw = temp_surface[!it];
			
			surface_set_target(sBase);
			DRAW_CLEAR
			BLEND_OVERRIDE
				shader_set_f("iteration", i);
				draw_surface_safe(sDraw);
			BLEND_NORMAL
			surface_reset_target();
		}
		
		shader_reset();
		
		surface_set_target(_outSurf);
			BLEND_OVERRIDE
			draw_surface_safe(sBase);
			BLEND_NORMAL
		surface_reset_target();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	}
}