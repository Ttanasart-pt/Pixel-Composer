function Node_GrainSim_Spawn(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Spawn";
	color = COLORS.node_blend_grain;
	icon  = THEME.grain_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	newInput( 6, nodeValue_Bool(    "Active",      true  ));
	
	////- =Domain
	newInput( 0, nodeValue_Struct( "Domain" )).setCustomData(global.GRAINSIM_JUNC).setVisible(true, true);
	
	////- =Spawn
	newInput( 7, nodeValue_EScroll( "Type",   0, [ "Stream", "Trigger" ] ));
	newInput(11, nodeValue_Int(     "Period", 2 ));
	newInput( 8, nodeValue_Trigger( "Trigger"   ));
	
	newInput( 1, nodeValue_EScroll( "Shape",      0, [ "Rectangle", "Circle", "Surface" ] ));
	newInput( 2, nodeValue_Vec2(    "Center",   [.5,.5] )).setUnitSimple();
	newInput( 3, nodeValue_Vec2(    "Size",     [.1,.1] )).setUnitSimple();
	newInput( 4, nodeValue_Float(   "Spacing",    2     ));
	newInput( 5, nodeValue_Surface( "Surface"           ));
	
	////- =Grain
	newInput(10, nodeValue_Color( "Color", ca_white     ));
	
	////- =Simulation
	newInput( 9, nodeValue_Bool( "Sleep on Spawn", false ));
	// 12
	
	newOutput( 0, nodeValue_Output("Domain", VALUE_TYPE.struct, {} )).setCustomData(global.GRAINSIM_JUNC);
	
	input_display_list = [ 6, 
		[ "Domain",     false ],  0, 
		[ "Spawn",      false ],  7, 11,  8, -2,  1,  2,  3,  4,  5,  
		[ "Grain",      false ], 10, 
		[ "Simulation", false ],  9, 
	];
	
	////- Node
	
	temp_surface = [ noone ];
	surfBuff     = buffer_create(1, buffer_grow, 1);
	
	static getDimension = function() /*=>*/ {
		var _domain = inputs[0].getValue();
		return is(_domain, GrainSim_Domain)? [_domain.size, _domain.size] : PROJ_SURF;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _shape  = inputs[ 1].getValue();
		var _cen    = inputs[ 2].getValue();
		var _siz    = inputs[ 3].getValue();
			
		var cx = _x + _cen[0] * _s;
		var cy = _y + _cen[1] * _s;
		
		var sx = _siz[0] * _s;
		var sy = _siz[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		
		switch(_shape) {
			case 0 : draw_rectangle( cx - sx, cy - sy, cx + sx, cy + sy, true ); break;
			case 1 : draw_ellipse(   cx - sx, cy - sy, cx + sx, cy + sy, true ); break;
		}
		
		switch(_shape) {
			case 0 :
			case 1 :
				drawOverlayInput(inputs[ 2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				drawOverlayInput(inputs[ 3].drawOverlay(w_hoverable, active, cx, cy, _s, _mx, _my, 1));
				break;
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _spawn  = inputs[ 6].getValue();
			var _domain = inputs[ 0].getValue();
			
			var _type   = inputs[ 7].getValue();
			var _perd   = inputs[11].getValue();
			var _trigg  = inputs[ 8].getValue();
			
			var _shape  = inputs[ 1].getValue();
			var _cen    = inputs[ 2].getValue();
			var _siz    = inputs[ 3].getValue();
			var _spac   = inputs[ 4].getValue();
			var _surf   = inputs[ 5].getValue();
			
			var _color  = inputs[10].getValue();
			
			var _sleep  = inputs[ 9].getValue();
			
			inputs[11].setVisible(_type  == 0);
			inputs[ 8].setVisible(_type  == 1);
			
			inputs[ 2].setVisible(_shape != 2);
			inputs[ 3].setVisible(_shape != 2);
			inputs[ 4].setVisible(_shape != 2);
			inputs[ 5].setVisible(_shape == 2, _shape == 2);
		#endregion
		
		if(!is(_domain, GrainSim_Domain)) return;
		
		outputs[0].setValue(_domain);
		
		if(!_spawn) return;
		
		switch(_type) {
			case 0 : if(safe_mod(CURRENT_FRAME, _perd) != 0) return; break;
			case 1 : if(!_trigg) return; break;
		}
		
		grainSim_setSpawnParam(_color, _sleep);
			
		switch(_shape) {
			case 0 : grainSim_Particle_Add_Rectangle(_domain.index, _cen[0], _cen[1], _siz[0], _siz[1], _spac); break;
			case 1 : grainSim_Particle_Add_Circle(_domain.index, _cen[0], _cen[1], _siz[0], _siz[1], _spac); break;
			
			case 2 : 
				if(!is_surface(_surf)) break;
				
				var _size = _domain.size;
				temp_surface[0] = surface_verify(temp_surface[0], _size, _size, surface_rgba8unorm);
				surface_set_target(temp_surface[0]);
					DRAW_CLEAR
					BLEND_OVERRIDE
					draw_surface_ext(_surf, 0, 0, 1, 1, 0, _color, _color_get_a(_color));
					BLEND_NORMAL
				surface_reset_target();
				
				buffer_get_surface(surfBuff, temp_surface[0], 0);
				grainSim_Particle_Add_Buffer(_domain.index, buffer_get_address(surfBuff));
				break;
		}
		
	}

}