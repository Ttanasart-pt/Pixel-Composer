#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Edge_Detect", "Algorithm > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 4); });
	});
#endregion

function Node_Edge_Detect(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Edge Detect";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface i" ));
	newInput(3, nodeValue_Surface( "Mask"      ));
	newInput(4, nodeValue_Slider(  "Mix",    1 ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	newInput(2, nodeValue_Enum_Scroll( "Oversample mode", 0, [ "Empty", "Clamp", "Repeat" ]));
		
	////- =Edge
	newInput(1, nodeValue_Enum_Scroll( "Algorithm", 0, ["Sobel", "Prewitt", "Laplacian", "Neighbor max diff"] ));
	// inputs 9
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 6, 
		["Surfaces",	 true],	0, 3, 4, 7, 8, 
		["Edge detect",	false],	1, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	attributes.filter = [ 1, 1, 0, 
	                      1, 0, 0, 
	                      0, 0, 0 ];
	filtering_vl      = false;
	
	filter_button = new buttonAnchor(noone, function(ind) {
		if(mouse_press(mb_left)) filtering_vl = !attributes.filter[ind];
		attributes.filter[ind] = filtering_vl;
		triggerRender();
	});
	
	static processData = function(_outSurf, _data, _array_index) {
		var surf  = _data[0];
		var filt  = _data[1];
		var over  = getAttribute("oversample");
		
		inputs[1].editWidget.setFrontButton(filt == 3? filter_button : noone);
		filter_button.index = attributes.filter;
		
		surface_set_shader(_outSurf, sh_edge_detect);
			shader_set_dim("dimension", surf);
			shader_set_i("filter",      filt);
			shader_set_i("sampleMode",  over);
			shader_set_i("sides",       attributes.filter);
			
			draw_surface_safe(surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}