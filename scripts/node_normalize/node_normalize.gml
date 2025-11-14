#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Normalize", "Channels > Toggle", "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue(!_n.inputs[1].getValue()); });
		addHotkey("Node_Normalize", "Modes > Toggle",    "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue(!_n.inputs[2].getValue()); });
	});
#endregion

function Node_Normalize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normalize";
	
	newInput(0, nodeValue_Surface( "Surface In"  ));
	newInput(1, nodeValue_EButton( "Channels", 0, [ "BW", "RGB" ]       ));
	
	////- =Normalize
	newInput(2, nodeValue_EButton( "Modes",    0, [ "Global", "Local" ] ));
	newInput(3, nodeValue_Int(     "Radius",   4 ));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Normalize", false], 2, 3, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone, noone, noone ];
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _mode = _data[2];
		var _lrad = _data[3];
		
		inputs[3].setVisible(_mode == 1);
		
		var _sw  = surface_get_width(_surf);
		var _sh  = surface_get_height(_surf);
		
		if(_mode == 0) {
			var _range = surface_get_range(_surf);
			
			surface_set_shader(_outSurf, sh_normalize);
				shader_set_2("range", _range);
				
				draw_surface_safe(_surf);
			surface_reset_shader();
			
		} else if(_mode == 1) {
			surface_set_shader(_outSurf, sh_normalize_local);
				shader_set_2("dimension", [_sw, _sh]);
				shader_set_i("radius",    _lrad);
				shader_set_i("channels",  0);
				
				draw_surface_safe(_surf);
			surface_reset_shader();
		}
		
		return _outSurf;
	}
}