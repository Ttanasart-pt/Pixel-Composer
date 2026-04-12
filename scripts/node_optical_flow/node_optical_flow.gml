function Node_Optical_Flow(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Optical Flow";
	setCacheManual();
	
	newInput( 0, nodeValue_Surface("Surface In"));
	
	////- =Optical Flow
	newInput( 1, nodeValue_Float(  "Radius",    4 ));
	newInput( 2, nodeValue_Slider( "Threshold", 1 ));
	
	////- =Output
	newInput( 3, nodeValue_EScroll( "Color Format", 0, [ "8-bit unorm", "32-bit float" ] ));
	newInput( 4, nodeValue_Float(   "Intensity",    4 ));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Optical Flow", false ],  1,  2, 
		[ "Ouptut",       false ],  3,  4, 
	];
	
	////- Nodes
	
	temp_surface = [ noone, noone ];
	
	static update = function(_frame = CURRENT_FRAME) {  
		#region data
			var _surf = getInputData( 0);
			
			var _radi = getInputData( 1);
			var _thrs = getInputData( 2);
			
			var _form = getInputData( 3);
			var _ints = getInputData( 4);
			
			var _outSurf = outputs[0].getValue();
			if(!is_surface(_surf)) return;
		#endregion
		
		cached_output = array_verify(cached_output, TOTAL_FRAMES);
		surface_free_safe(array_safe_get_fast(cached_output, _frame));
		cached_output[_frame] = surface_clone(_surf);
		
		if(_frame <= 1) return;
		
		var _pref = cached_output[_frame - 1];
		if(!is_surface(_pref)) return;
		
		var _dim = surface_get_dimension(_surf);
		_outSurf        = surface_verify(_outSurf,        _dim[0], _dim[1], _form? surface_rgba32float : surface_rgba8unorm);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba32float);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], surface_rgba32float);
		
		surface_set_shader(temp_surface[0], sh_optical_flow_hash);
			shader_set_2( "dimension", _dim );
			shader_set_f( "radius",   _radi );
			
			draw_surface(_pref, 0, 0);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_optical_flow_hash);
			shader_set_2( "dimension", _dim );
			shader_set_f( "radius",   _radi );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_optical_flow_search);
			shader_set_s( "prevHash",  temp_surface[0] );
			shader_set_s( "currHash",  temp_surface[1] );
			shader_set_2( "dimension", _dim  );
			shader_set_f( "radius",    _radi );
			
			shader_set_f( "threshold", _thrs );
			
			shader_set_i( "cformat",   _form );
			shader_set_f( "intensity", _ints );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}
}