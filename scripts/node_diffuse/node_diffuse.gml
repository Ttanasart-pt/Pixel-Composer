function Node_Diffuse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Diffuse";
	
	newInput( 0, nodeValue_Surface( "Density field" ));
	newInput( 6, nodeValueSeed());
	
	////- =Diffuse
	newInput( 1, nodeValue_Slider( "Dissipation", 0.05, [ -0.2, 0.2, 0.001] )).setMappable(12);
	
	////- =Flow
	newInput( 2, nodeValue_Float(  "Scale",       1 )).setMappable(13);
	newInput( 9, nodeValue_Int(    "Detail",      1 ));
	newInput( 3, nodeValue_Float(  "Randomness",  1 ));
	newInput( 4, nodeValue_Slider( "Flow rate",  .5, [ 0, 1, 0.01] )).setMappable(14);
	
	////- =Forces
	newInput(10, nodeValue_Enum_Scroll( "External Type",  0, [ "Point", "Vector" ]));
	newInput( 7, nodeValue_Surface(     "External" ));
	newInput( 8, nodeValue_Slider(      "External Strength",  .1, [ -0.25, 0.25, 0.01] )).setMappable(15);
	newInput(11, nodeValue_Rotation(    "External Direction",  0 )).setMappable(16);
	
	////- =Rendering
	newInput( 5, nodeValue_Slider_Range( "Threshold", [.5,.7] ));
	// input 17
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 6, 
		["Diffuse",		false], 1, 12, 
		["Flow",		false], 2, 13, 9, 3, 4, 14, 
		["Forces",		false], 10, 8, 15, 11, 16, 
		["Rendering",	false], 5, 
	]
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	static update = function() {
		#region data
			var _surf = getInputData( 0);
			var _seed = getInputData( 6);
			
			var _diss = getInputData( 1), _dissM = getInputData(12);
			
			var _scal = getInputData( 2), _scalM = getInputData(13);
			var _detl = getInputData( 9);
			var _rand = getInputData( 3);
			var _flow = getInputData( 4), _flowM = getInputData(14);
			
			var _ftyp = getInputData(10);
			var _fstr = getInputData( 8), _fstrM = getInputData(15);
			var _fdir = getInputData(11), _fdirM = getInputData(16);
			
			var _thre = getInputData( 5);
			
			inputs[11].setVisible(_ftyp == 1);
		#endregion
		
		if(!is_surface(_surf)) return;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _sw, _sh);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
		
		surface_set_shader(temp_surface[0], sh_diffuse_dissipate);
			shader_set_f("dimension",   _sw, _sh);
			shader_set_f_map("dissipation", _diss, _dissM, inputs[1]);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_diffuse_flow);
			shader_set_f("dimension", _sw, _sh);
			shader_set_f("seed",      _seed + CURRENT_FRAME * _rand / 100);
			
			shader_set_i("iteration",         _detl);
			shader_set_f_map("scale",         _scal, _scalM, inputs[13]);
			shader_set_f_map("flowRate",      _flow, _flowM, inputs[14]);
			
			shader_set_i(    "externalForceType", _ftyp);
			shader_set_f_map("externalForce",     _fstr, _fstrM, inputs[15]);
			shader_set_f_map("externalForceDir",  _fdir, _fdirM, inputs[16]);
			
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_diffuse_post);
			shader_set_f("dimension", _sw, _sh);
			shader_set_f("threshold", _thre);
			
			draw_surface_safe(temp_surface[1]);
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}
}