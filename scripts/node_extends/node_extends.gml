function Node_Extends(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Extends";
	
	newActiveInput(1);
	newInput(2, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface("Surface In"));
	newInput( 3, nodeValue_Surface( "Mask"        ));
	newInput( 4, nodeValue_Slider(  "Mix", 1      ));
	__init_mask_modifier(3, 5); // inputs 5, 6 
	
	////- =Extends
	
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 2,
		[ "Surfaces", false ],  3,  4,  5,  6, 
		[ "Extends",  false ], 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[0];
		#endregion
		
		
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[2]);
		return _outSurf; 
	}
}