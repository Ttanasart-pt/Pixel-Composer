#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blend_Edge", "Width > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue(toNumber(chr(keyboard_key)) / 10);  });
		addHotkey("Node_Blend_Edge", "Types > Toggle",            "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 3); });
	});
#endregion

function Node_Blend_Edge(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend Edge";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Float("Width", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(5);
	
	newInput(2, nodeValue_Enum_Button("Types",self,  0, [ "Both", "Horizontal", "Vertical" ]));
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(5, nodeValue_Surface("Width map", self))
		.setVisible(false, false);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(6, nodeValue_Float("Blending", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(7, nodeValue_Float("Smoothness", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
		
	input_display_list = [ 3, 4, 
		["Surfaces", true], 0, 
		["Blend",	false], 2, 1, 5, 6, 7, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	temp_surface = array_create(1);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _sw = surface_get_width_safe(_data[0]);
		var _sh = surface_get_height_safe(_data[0]);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		var _edg = _data[2];
		
		if(_edg == 0) {
			surface_set_shader(temp_surface[0], sh_blend_edge);
				shader_set_f("dimension", _sw, _sh);
				shader_set_f_map("width", _data[1], _data[5], inputs[1]);
				shader_set_i("edge"     , 0);
				shader_set_f("blend"    , clamp(_data[6], 0.001, 0.999));
				shader_set_f("smooth"   , _data[7]);
				
				draw_surface_safe(_data[0]);
			surface_reset_shader();
			
			surface_set_shader(_outSurf, sh_blend_edge);
				shader_set_i("edge"     , 1);
				
				draw_surface_safe(temp_surface[0]);
			surface_reset_shader();
			
		} else {
			surface_set_shader(_outSurf, sh_blend_edge);
				shader_set_f("dimension", _sw, _sh);
				shader_set_f_map("width", _data[1], _data[5], inputs[1]);
				shader_set_i("edge"     , _edg - 1);
				shader_set_f("blend"    , clamp(_data[6], 0.001, 0.999));
				
				draw_surface_safe(_data[0]);
			surface_reset_shader();
			
		}
		
		return _outSurf;
	}
}