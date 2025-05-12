#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Flip", "Axis > Toggle", "A", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
	});
#endregion

function Node_Flip(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flip";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Enum_Button("Axis", self,  0, [ "x", "y" ]));
	
	newInput(2, nodeValue_Bool("Active", self, true));
		active_index = 2;
		
	input_display_list = [ 2, 
		["Surfaces", true],	0, 
		["Flip",	false],	1,
	]
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _axis = _data[1];
		
		surface_set_shader(_outSurf, sh_flip);
			shader_set_i("axis", _axis);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}