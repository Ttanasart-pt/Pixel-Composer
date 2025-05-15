#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Corner", "Radius > Set", KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Corner(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Round Corner";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Int("Radius", self, 2))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	newInput(2, nodeValue_Surface("Mask", self));
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Bool("Active", self, true));
		active_index = 4;
	
	newInput(5, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(2); // inputs 6, 7
	
	newInput(8, nodeValue_Slider("Thershold", self, .5));
	
	input_display_list = [ 4, 5, 
		["Surfaces", true], 0, 2, 3, 6, 7, 
		["Corner",	false], 1, 8, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	
	temp_surface = array_create(2);
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _rad  = _data[1];
		var _thr  = _data[8];
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		var _dim = [ _sw, _sh ];
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh); 
			surface_clear(temp_surface[i]);
		}
		
		surface_set_shader(temp_surface[0], sh_corner_coord);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var _itr = max(_sw, _sh) / 4;
		var _bg  = 1;
		
		repeat(_itr) {
			surface_set_shader(temp_surface[_bg], sh_corner_iterate);
				shader_set_2("dimension", _dim);
				draw_surface_safe(temp_surface[!_bg]);
			surface_reset_shader();
			_bg = !_bg;
		}
		
		var _sam = getAttribute("oversample");
		
		surface_set_shader(_outSurf, sh_corner_apply);
			shader_set_2("dimension", _dim);
			shader_set_f("radius",    _rad);
			shader_set_f("thershold", _thr);
			shader_set_surface("original", _surf);
			shader_set_i("sampleMode", _sam);
			
			draw_surface_safe(temp_surface[!_bg]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_surf, _outSurf, _data[5]);
		
		return _outSurf;
	}
}