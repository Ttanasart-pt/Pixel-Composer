function Node_WaveSim_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render";
	icon  = THEME.wavesim;
	color = COLORS.node_blend_ripple;
	update_on_frame = true;
	
	parameters.inline_draw_output = true;
	
	newInput( 0, nodeValue_Struct( "Wave",  noone )).setVisible(true, true).setCustomData(global.WAVE_JUNC);
	
	////- =Simulation
	newInput( 1, nodeValue_Bool(    "Simulate",   true ));
	newInput( 4, nodeValue_Int(     "Iteration",  1    ));
	newInput( 3, nodeValue_Slider(  "k",         .5    ));
	newInput( 2, nodeValue_Slider(  "Damping",   .5    ));
	
	////- =/Boundary
	newInput( 5, nodeValue_EButton( "Boundary",   0, [ "Free", "Wall", "Wrap" ] ));
	newInput( 8, nodeValue_Vec2(    "Edge Absorption", [.1,.2] ));
	
	////- =Rendering
	newInput( 6, nodeValue_Range(   "Range", [0,1]        ));
	newInput( 7, nodeValue_Curve(   "Curve", CURVE_DEF_01 ));
	// 9
	
	newOutput(0, nodeValue_Output( "Rendered", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Simulation",    false, 1 ],  4,  3,  2,
			[ "/Boundary", false    ],  5,  8, 
		[ "Rendering",     false    ],  6,  7, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	temp_surface = [noone, noone];
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_WaveSim_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static update = function() {
		#region data
			if(!is(inline_context, Node_WaveSim_Inline)) return;
			domain = inline_context.domain;
			if(!is_surface(domain)) return;
			
			var _dim = getDimension();
			
			var _simu = getInputData( 1);
			var _itr  = getInputData( 4);
			var _k    = getInputData( 3);
			var _damp = getInputData( 2);
			
			var _wall = getInputData( 5);
			var _edge = getInputData( 8);
			
			var _rang = getInputData( 6);
			var _curv = getInputData( 7);
		#endregion
		
		if(_simu && IS_PLAYING) {
			temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba32float);
			temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1], surface_rgba32float);
			
			surface_set_shader(temp_surface[1]);
				draw_surface(domain, 0, 0);
			surface_reset_shader();
			
			var bg = 0;
			
			repeat(_itr) {
				surface_set_shader(temp_surface[bg], sh_wavesim_source_step);
					shader_set_s( "domain",    temp_surface[!bg] );
					shader_set_2( "dimension", _dim   );
					
					shader_set_f( "k",         _k     );
					shader_set_f( "damping",   _damp  );
					shader_set_i( "boundary",  _wall  );
					
					shader_set_f( "edgeWidth",    _edge[0] );
					shader_set_f( "edgeStrength", _edge[1] );
					
					draw_empty();
				surface_reset_shader();
				bg = !bg;
			}
			
			surface_set_shader(domain);
				draw_surface(temp_surface[!bg], 0, 0);
			surface_reset_shader();
		}
		
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		outputs[0].setValue(_outSurf);
		
		surface_set_shader(_outSurf, sh_wavesim_render);
			shader_set_2(  "range", _rang );
			shader_set_cr( "curve", _curv );
					
			draw_surface(domain, 0, 0);
		surface_reset_shader();
		
	}
}
