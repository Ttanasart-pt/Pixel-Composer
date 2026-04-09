function Node_Blobify(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blobify";
	
	newActiveInput(1);
	newInput(9, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 5, nodeValue_Surface( "Mask"       ));
	newInput( 6, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(5, 7); // inputs 7, 8
	
	////- =Blobify
	newInput(2, nodeValue_Int(    "Radius",     3 )).setMappable(4).setValidator(VV_min(0));
	newInput(3, nodeValue_Slider( "Threshold", .5 ));
	// input 10
	
	input_display_list = [ 1, 9, 
		[ "Surface", false ], 0, 5, 6, 7, 8, 
		[ "Blobify", false ], 2, 4, 3, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, -90, _dim[1] / 2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {	
		#region data
			var _rad = _data[2];
			var _thr = _data[3];
		#endregion
		
		surface_set_shader(_outSurf, sh_blobify);
			shader_set_f("dimension", surface_get_dimension(_data[0]));
			shader_set_f_map("radius", _rad, _data[4], inputs[2]);
			shader_set_f("threshold",  _thr);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	}
}