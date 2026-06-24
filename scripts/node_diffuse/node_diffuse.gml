function Node_Diffuse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Diffuse";
	
	newInput( 0, nodeValue_Surface( "Density Field" ));
	newInput( 6, nodeValueSeed());
	
	////- =Diffuse
	newInput( 1, nodeValue_Slider( "Dissipation", .05, [-.2,.2,.001] )).setMappable(12);
	newInput(17, nodeValue_Int(    "Iteration",    1                 ));
	
	////- =Flow
	newInput( 2, nodeValue_Float(   "Scale",       1                 )).setMappable(13);
	newInput( 9, nodeValue_Int(     "Detail",      1                 ));
	newInput( 3, nodeValue_Float(   "Randomness",  1                 ));
	newInput( 4, nodeValue_Slider(  "Flow rate",  .5, [0,1,.01]      )).setMappable(14);
	newInput(18, nodeValue_Surface( "Flow Map"                       ));
	
	////- =Forces
	newInput(10, nodeValue_EScroll(  "External Type",   0, [ "Point", "Vector" ] ));
	newInput( 7, nodeValue_Surface(  "External Force"                            ));
	newInput(19, nodeValue_Vec2(     "Position", [.5,.5]                         )).setUnitSimple();
	newInput(20, nodeValue_Float(    "Radius",          1                        ));
	newInput( 8, nodeValue_Slider(   "Strength",       .1, [ -0.25, 0.25, 0.01]  )).setMappable(15);
	newInput(11, nodeValue_Rotation( "Direction",       0                        )).setMappable(16);
	
	////- =Rendering
	newInput( 5, nodeValue_Slider_Range( "Threshold", [.5,.7] ));
	// input 21
	
	newOutput(0, nodeValue_Output("Result", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 6, 
		[ "Diffuse",   false ],  1, 12, 17, 
		[ "Flow",      false ],  2, 13,  9,  3,  4, 14, 18, 
		[ "Forces",    false ], 10, 19, 20,  8, 15, 11, 16, 
		[ "Rendering", false ],  5, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_oversample();
	
	temp_surface = [ noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _ftyp = getInputData(10);
		
		if(_ftyp == 0) drawOverlayInput(inputs[19].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static update = function() {
		#region data
			var _surf = getInputData( 0);
			var _seed = getInputData( 6);
			
			var _diss = getInputData( 1), _dissM = getInputData(12);
			var _iitr = getInputData(17);
			
			var _scal = getInputData( 2), _scalM = getInputData(13);
			var _detl = getInputData( 9);
			var _rand = getInputData( 3);
			var _flow = getInputData( 4), _flowM = getInputData(14);
			var _fmap = getInputData(18);
			
			var _ftyp = getInputData(10);
			var _fpos = getInputData(19);
			var _frad = getInputData(20);
			var _fstr = getInputData( 8), _fstrM = getInputData(15);
			var _fdir = getInputData(11), _fdirM = getInputData(16);
			
			var _thre = getInputData( 5);
			
			inputs[19].setVisible(_ftyp == 0);
			inputs[20].setVisible(_ftyp == 0);
			
			inputs[11].setVisible(_ftyp == 1);
		#endregion
		
		if(!is_surface(_surf)) return;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		
		temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh, attrDepth());
		temp_surface[1] = surface_verify(temp_surface[1], _sw, _sh, attrDepth());
		
		surface_set_shader(temp_surface[1]);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var bg = 0;
		var it = 0;
		
		repeat(_iitr) {
			surface_set_shader(temp_surface[bg], sh_diffuse_dissipate);
				shader_set_interpolation(_outSurf);
			
				shader_set_f( "dimension",   _sw, _sh);
				shader_set_m( "dissipation", _diss, _dissM, inputs[1]);
				shader_set_f( "iteration",   _iitr);
				
				draw_surface_safe(temp_surface[!bg]);
			surface_reset_shader();
			bg = !bg;
			
			surface_set_shader(temp_surface[bg], sh_diffuse_flow);
				shader_set_interpolation(_outSurf);
			
				shader_set_f( "dimension",  _sw, _sh );
				shader_set_f( "seed",       _seed + CURRENT_FRAME * _rand / 100 + it * pi);
				shader_set_f( "iter",       _iitr    );
				
				shader_set_i( "flowmapUse",        is_surface(_fmap)         );
				shader_set_s( "flowmap",           _fmap                     );
				
				shader_set_i( "iteration",         _detl                     );
				shader_set_m( "scale",             _scal, _scalM, inputs[13] );
				shader_set_m( "flowRate",          _flow, _flowM, inputs[14] );
				
				shader_set_i( "externalForceType", _ftyp                     );
				shader_set_m( "externalForce",     _fstr, _fstrM, inputs[15] );
				shader_set_m( "externalForceDir",  _fdir, _fdirM, inputs[16] );
				shader_set_2( "externalForcePos",  _fpos                     );
				shader_set_f( "externalForceRad",  _frad                     );
				
				draw_surface_safe(temp_surface[!bg]);
			surface_reset_shader();
			bg = !bg;
			
			it++;
		}
		
		surface_set_shader(_outSurf, sh_diffuse_post);
			shader_set_f( "dimension", _sw, _sh );
			shader_set_f( "threshold", _thre    );
			
			draw_surface_safe(temp_surface[!bg]);
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}
}