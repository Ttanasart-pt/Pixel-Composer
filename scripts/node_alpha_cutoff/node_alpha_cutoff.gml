#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Alpha_Cutoff", "Minimum > Set", KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Alpha_Cutoff(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Alpha Cutoff";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Slider("Minimum", 0.2)).setTooltip("Any pixel with less alpha (more transparent) than this will be removed.");
	
	newInput(2, nodeValue_Surface("Mask"));
	
	newInput(3, nodeValue_Slider("Mix", 1));
	
	newActiveInput(4);
	
	__init_mask_modifier(2, 5); // inputs 5, 6, 
	
	input_display_list = [ 4, 
		["Surfaces", true], 0, 2, 3, 5, 6, 
		["Cutoff",	false], 1, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE
		
		shader_set(sh_alpha_cutoff);
			shader_set_uniform_f(shader_get_uniform(sh_alpha_cutoff, "cutoff"), _data[1]);
			draw_surface_safe(_data[0]);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		
		return _outSurf;
	}
}