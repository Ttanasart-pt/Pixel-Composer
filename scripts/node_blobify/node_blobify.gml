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
	newInput(11, nodeValue_EScroll( "Shape",      0, [ 
		new scrollItem("Circle",  s_node_shape_circle), 
		new scrollItem("Diamond", s_node_shape_misc, 0), 
		new scrollItem("Square",  s_node_shape_rectangle),
	] )).setPieMenu();
	
	newInput( 2, nodeValue_Int(     "Radius",     3 )).setMappable(4).setValidator(VV_min(0)).setPieMenu();
	newInput( 3, nodeValue_Slider(  "Threshold", .5 )).setPieMenu();
	newInput(12, nodeValue_Bool(    "Distance",   false ));
	newInput(13, nodeValue_Bool(    "Keep Alpha", false ));
	
	////- =Rendering
	newInput(10, nodeValue_Slider( "Smoothness", 0 ));
	// input 14
	
	input_display_list = [ 1, 9, 
		[ "Surface",   false ],  0,  5,  6,  7,  8, 
		[ "Blobify",   false ], 11,  2,  4,  3, 12, 13, 
		[ "Rendering", false ], 10, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
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
			var _surf = _data[ 0];
			
			var _shap = _data[11];
			var _rad  = _data[ 2];
			var _thr  = _data[ 3];
			var _fade = _data[12];
			var _kepa = _data[13];
			
			var _smth = _data[10];
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_blobify);
			shader_set_interpolation(_surf);
			
			shader_set_2( "dimension",  _dim  );
			shader_set_m( "radius",     _rad, _data[4], inputs[2] );
			shader_set_i( "shape",      _shap );
			shader_set_i( "fade",       _fade );
			shader_set_i( "keepAlpha",  _kepa );
			
			shader_set_f( "threshold",  _thr  );
			shader_set_f( "smoothness", _smth );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_surf, _outSurf, _data[9]);
		
		return _outSurf;
	}
}