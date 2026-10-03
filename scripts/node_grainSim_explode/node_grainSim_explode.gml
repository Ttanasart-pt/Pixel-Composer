function Node_GrainSim_Explode(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Explode";
	color = COLORS.node_blend_grain;
	icon  = THEME.grain_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	newInput( 1, nodeValue_Bool( "Active", true ));
	
	////- =Domain
	newInput( 0, nodeValue_Struct(  "Domain"  )).setCustomData(global.GRAINSIM_JUNC).setVisible(true, true);
	newInput( 5, nodeValue_Trigger( "Trigger" ));
	
	////- =Area
	newInput( 2, nodeValue_Vec2(  "Center",   [.5,.5] )).setUnitSimple();
	newInput( 3, nodeValue_Vec2(  "Size",     [.5,.5] )).setUnitSimple();
	newInput( 4, nodeValue_Float( "Strength",  100    ));
	// 6
	
	newOutput( 0, nodeValue_Output("Domain", VALUE_TYPE.struct, {} )).setCustomData(global.GRAINSIM_JUNC);
	
	input_display_list = [ 1, 
		[ "Domain", false ],  0,  5, 
		[ "Area",   false ],  2,  3,  4, 
	];
	
	////- Node
	
	temp_surface = [ noone ];
	surfBuff = buffer_create(1, buffer_grow, 1);
	
	static getDimension = function() /*=>*/ {
		var _domain = inputs[0].getValue();
		return is(_domain, GrainSim_Domain)? [_domain.size, _domain.size] : PROJ_SURF;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _cen = inputs[ 2].getValue();
		var _siz = inputs[ 3].getValue();
		
		var cx = _x + _cen[0] * _s;
		var cy = _y + _cen[1] * _s;
		
		var sx = _siz[0] * _s;
		var sy = _siz[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_ellipse( cx - sx, cy - sy, cx + sx, cy + sy, true );
		
		drawOverlayInput(inputs[ 2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		drawOverlayInput(inputs[ 3].drawOverlay(w_hoverable, active, cx, cy, _s, _mx, _my, 1));
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _active = inputs[ 1].getValue();
			
			var _domain = inputs[ 0].getValue();
			var _trig   = inputs[ 5].getValue();
			
			var _cen    = inputs[ 2].getValue();
			var _siz    = inputs[ 3].getValue();
			var _strn   = inputs[ 4].getValue();
		#endregion
		
		if(!is(_domain, GrainSim_Domain)) return;
		
		outputs[0].setValue(_domain);
		if(!_active) return;
		if(!_trig)   return;
		
		var _size = _domain.size;
		temp_surface[0] = surface_verify(temp_surface[0], _size, _size, surface_rgba8unorm);
		surface_set_shader(temp_surface[0], sh_grainsim_explode);
			shader_set_2( "dimension", [_size,_size] );
			shader_set_2( "center",     _cen );
			shader_set_2( "size",       _siz );
			
			draw_empty();
		surface_reset_shader();
		
		buffer_get_surface(surfBuff, temp_surface[0], 0);
		
		grainSim_Force_Apply_Surface(_domain.index, _strn * 10000, buffer_get_address(surfBuff));
		
	}

}