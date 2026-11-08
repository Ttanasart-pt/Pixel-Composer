function Node_WaveSim_Solid(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Solid";
	icon  = THEME.wavesim;
	color = COLORS.node_blend_ripple;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newActiveInput(0);
	newInput( 1, nodeValue_Struct( "Wave",  noone )).setVisible(true, true).setCustomData(global.WAVE_JUNC);
	
	////- =Source
	newInput( 2, nodeValue_EButton( "Shape", 0, ["Circle", "Surface"] ));
	newInput( 3, nodeValue_Vec2(    "Position", [.5,.5] )).setUnitSimple();
	newInput( 4, nodeValue_Float(   "Radius",   .25     )).setUnitSimple();
	newInput( 5, nodeValue_Surface( "Mask" ));
	
	////- =Solid
	newInput( 6, nodeValue_EButton( "Type", 0, ["Reflect", "Absorb"] ));
	// 7
	
	newOutput(0, nodeValue_Output("Wave", VALUE_TYPE.struct, noone)).setCustomData(global.WAVE_JUNC);
	
	input_display_list = [  0,  1, 
		[ "Source", false ],  2,  3,  4,  5, 
		[ "Solid",  false ],  6, 
	];
	
	////- Nodes
	
	temp_surface = [noone];
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_WaveSim_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[ 3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
	}
	
	static update = function() {
		#region data
			if(!is(inline_context, Node_WaveSim_Inline)) return;
			domain = inline_context.domain;
			if(!is_surface(domain)) return;
			
			var _act  = getInputData( 0);
			
			var _dim  = getDimension();
			var _shp  = getInputData( 2);
			var _pos  = getInputData( 3);
			var _rad  = getInputData( 4);
			var _sur  = getInputData( 5);
			
			var _type = getInputData( 6);
			
			inputs[ 4].setVisible(_shp == 0);
			inputs[ 5].setVisible(_shp == 1, _shp == 1);
		#endregion
		
		if(!_act) return;
		if(_shp == 1 && !is_surface(_sur)) return;
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba32float);
		
		surface_set_shader(temp_surface[0], sh_wavesim_solid);
			shader_set_s( "domain",    domain );
			shader_set_2( "dimension", _dim   );
			
			shader_set_i( "type",      _type  );
			shader_set_i( "shape",     _shp   );
			shader_set_s( "mask",      _sur   );
			
			shader_set_2( "position",  _pos   );
			shader_set_f( "radius",    _rad   );
			
			draw_empty();			
		surface_reset_shader();
		
		surface_set_shader(domain, noone, true, BLEND.over);
			draw_surface(temp_surface[0], 0, 0);
		surface_reset_shader();
		
		outputs[0].setValue(domain);
	}
}
