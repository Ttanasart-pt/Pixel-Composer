function Node_Vignette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Vignette";
	
	newActiveInput(1);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput(11, nodeValue_Surface( "Mask"       ));
	newInput(12, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(11, 13); // inputs 13, 14
	
	////- =Vignette
	newInput(15, nodeValue_Vec2(   "Center",     [.5,.5] )).setUnitSimple();
	newInput( 5, nodeValue_Slider( "Roundness",  0  )).setHotkey("R").setMappable(7).setPieMenu();
	newInput( 2, nodeValue_Float(  "Exposure",   15 )).setHotkey("E").setMappable(8).setPieMenu();
	newInput( 3, nodeValue_Slider( "Strength",   1, [ 0, 2, 0.01 ] )).setHotkey("S").setMappable(9).setCurvable(10, CURVE_DEF_01).setPieMenu();
	newInput( 4, nodeValue_Slider( "Exponent",  .25 )).setPieMenu();
	
	////- =Render
	newInput( 6, nodeValue_Bool( "Lighten", false )).setPieMenu();
	// input 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		[ "Surfaces", false ],  0, 11, 12, 13, 14, 
		[ "Vignette", false ],  5,  7,  2,  8,  3,  9, 10, 
		[ "Render",   false ],  6, 
	]
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		drawOverlayInput(inputs[3].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my,  90, _dim[0]/4 ));
		drawOverlayInput(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my,   0            ));
		drawOverlayInput(inputs[5].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, -90, _dim[0]   ));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			
			var _cent = _data[15];
			var _smot = _data[ 5];
			var _expo = _data[ 2];
			var _strn = _data[ 3];
			
			var _ligh = _data[ 6];
		#endregion
		
		surface_set_shader(_outSurf, sh_vignette);
			shader_set_f_map("smoothness", _smot, _data[7], inputs[5] );
			shader_set_f_map("exposure",   _expo, _data[8], inputs[2] );
			shader_set_f_map("strength",   _strn, _data[9], inputs[3], _data[10] );
			
			shader_set_2( "dimension", surface_get_dimension(_outSurf) );
			shader_set_2( "center",    _cent );
			shader_set_i( "light",     _ligh );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[11], _data[12], inputs[11]);
		
		return _outSurf;
	}
}