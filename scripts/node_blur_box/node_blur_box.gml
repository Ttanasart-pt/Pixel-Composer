#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur_Box", "Size > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
	});
#endregion

function Node_Blur_Box(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Box Blur";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Int("Size", self, 3))
		.setUnitRef(function(index) /*=>*/ {return getDimension(index)});
	
	newInput(2, nodeValue_Surface("Mask", self));
	
	newInput(3, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Bool("Active", self, true));
		active_index = 4;
	
	newInput(5, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(2); // inputs 6, 7, 
	
	newInput(8, nodeValue_Bool("Separate Axis", self, false));
	
	newInput(9, nodeValue_Vec2("2D Size", self, [ 3, 3 ]));
	
	input_display_list = [ 4, 5, 
		["Surfaces", true], 0, 2, 3, 6, 7, 
		["Blur",	false], 8, 1, 9, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	temp_surface = [ surface_create(1, 1) ];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _mask = _data[2];
		var _mix  = _data[3];
		
		var _sepa = _data[8];
		var _siz2 = _data[9];
		var _size = _data[1];
		
		inputs[1].setVisible(!_sepa);
		inputs[9].setVisible( _sepa);
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], ww, hh, attrDepth());
		
		surface_set_shader(temp_surface[0], sh_blur_box);
			shader_set_interpolation(_data[0]);
			shader_set_i("sampleMode", getAttribute("oversample"));
			shader_set_2("dimension", [ ww, hh ]);
			shader_set_f("size",      max(0, round(_sepa? _siz2[0] : _size)));
			shader_set_i("axis",      0);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_blur_box);
			shader_set_interpolation(_data[0]);
			shader_set_f("size",      max(0, round(_sepa? _siz2[1] : _size)));
			shader_set_i("axis",      1);
			
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[5]);
		
		return _outSurf;
	}
}