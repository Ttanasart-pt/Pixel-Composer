function Node_WaveSim_Source(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Add Source";
	icon  = THEME.wavesim;
	color = COLORS.node_blend_ripple;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newActiveInput(5);
	newInput(10, nodeValue_Struct( "Wave",  noone )).setVisible(true, true).setCustomData(global.WAVE_JUNC);
	
	////- =Source
	newInput( 7, nodeValue_EButton( "Shape", 0, ["Circle", "Surface"] ));
	newInput( 0, nodeValue_Vec2(    "Position", [.5,.5] )).setUnitSimple();
	newInput( 3, nodeValue_Float(   "Radius",   2       )).setUnitSimple(false);
	newInput( 8, nodeValue_Surface( "Mask"              ));
	
	////- =Wave
	newInput(11, nodeValue_Bool(  "Wave",      true  ));
	newInput( 9, nodeValue_Rot(   "Phase",     0     ));
	newInput( 2, nodeValue_Float( "Period",    6     ));
	newInput( 1, nodeValue_Float( "Intensity", 16    ));
	newInput( 4, nodeValue_Float( "Velocity",  1     )).setUnitSimple();
	newInput( 6, nodeValue_Range( "Range",    [-1,1] ));
	// 12
	
	newOutput(0, nodeValue_Output("Wave", VALUE_TYPE.struct, noone)).setCustomData(global.WAVE_JUNC);
	
	input_display_list = [  5, 10, 
		[ "Source", false     ],  7,  0,  3,  8,  
		[ "Wave",   false, 11 ],  9,  2,  1,  6, 
	];
	
	////- Nodes
	
	temp_surface = [noone];
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_WaveSim_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[ 0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static update = function() {
		#region data
			if(!is(inline_context, Node_WaveSim_Inline)) return;
			domain = inline_context.domain;
			if(!is_surface(domain)) return;
			
			var _act  = getInputData( 5);
			
			var _dim  = getDimension();
			var _shp  = getInputData( 7);
			var _pos  = getInputData( 0);
			var _sur  = getInputData( 8);
			
			var _wave = getInputData(11);
			var _phas = getInputData( 9);
			var _freq = getInputData( 2);
			var _rad  = getInputData( 3);
			var _intn = getInputData( 1);
			var _velo = getInputData( 4);
			var _rng  = getInputData( 6);
			
			inputs[ 8].setVisible(_shp == 1, _shp == 1);
			inputs[ 3].setVisible(_shp == 0);
		#endregion
		
		if(!_act) return;
		if(_shp == 1 && !is_surface(_sur)) return;
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba32float);
		
		var _wav = 1;
		
		if(_wave) {
			var _wav = dsin(CURRENT_FRAME / _freq * 360 + _phas);
			_wav  = lerp(_rng[0], _rng[1], _wav * .5 + .5);
			_wav *= _intn;
		}
		
		surface_set_shader(temp_surface[0], sh_wavesim_source_add);
			shader_set_s( "domain",    domain );
			shader_set_2( "dimension", _dim   );
			
			shader_set_i( "shape",     _shp   );
			shader_set_s( "mask",      _sur   );
			
			shader_set_2( "position",  _pos   );
			shader_set_f( "radius",    _rad   );
			shader_set_f( "intensity", _wav   );
			shader_set_f( "velocity",  _velo  );
			
			draw_empty();			
		surface_reset_shader();
		
		surface_set_shader(domain, noone, true, BLEND.over);
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		outputs[0].setValue(domain);
	}
}
