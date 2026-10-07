function Node_GrainSim_Force(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Apply Force";
	color = COLORS.node_blend_grain;
	icon  = THEME.grain_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	newInput( 5, nodeValue_Bool( "Active", true ));
	
	////- =Domain
	newInput( 0, nodeValue_Struct( "Domain" )).setCustomData(global.GRAINSIM_JUNC).setVisible(true, true);
	
	////- =Area
	newInput( 1, nodeValue_EScroll( "Shape",      0, [ "Rectangle", "Circle", "Surface" ] ));
	newInput( 2, nodeValue_Vec2(    "Center",   [.5,.5] )).setUnitSimple();
	newInput( 3, nodeValue_Vec2(    "Size",     [.5,.5] )).setUnitSimple();
	newInput( 7, nodeValue_Surface( "Surface"           ));
	
	////- =Force
	newInput( 4, nodeValue_Vec2(    "Force",    [4,.0] )).setUnitSimple(false);
	newInput( 8, nodeValue_Float(   "Strength",     1  ));
	newInput( 6, nodeValue_Float(   "Positional Velocity", 0  ));
	// 9
	
	newOutput( 0, nodeValue_Output("Domain", VALUE_TYPE.struct, {} )).setCustomData(global.GRAINSIM_JUNC);
	
	input_display_list = [ 5, 
		[ "Domain", false ],  0, 
		[ "Spawn",  false ],  1,  2,  3,  7, 
		[ "Force",  false ],  4,  8,  6, 
	];
	
	////- Node
	
	temp_surface = [ noone ];
	
	prev_x = 0;
	prev_y = 0;
	surfBuff = buffer_create(1, buffer_grow, 1);
	
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
			var _apply  = inputs[ 5].getValue();
			var _domain = inputs[ 0].getValue();
			
			var _shape  = inputs[ 1].getValue();
			var _cen    = inputs[ 2].getValue();
			var _siz    = inputs[ 3].getValue();
			var _surf   = inputs[ 7].getValue();
			
			var _force  = inputs[ 4].getValue();
			var _strn   = inputs[ 8].getValue();
			var _velo   = inputs[ 6].getValue();
			
			inputs[ 2].setVisible(_shape != 2);
			inputs[ 3].setVisible(_shape != 2);
			inputs[ 7].setVisible(_shape == 2, _shape == 2);
		#endregion
		
		if(!is(_domain, GrainSim_Domain)) return;
		
		outputs[0].setValue(_domain);
		if(!_apply) return;
		
		var cx = _cen[0];
		var cy = _cen[1];
		
		var sx = _siz[0];
		var sy = _siz[1];
		
		var fx = _force[0];
		var fy = _force[1];
		
		if(!IS_FIRST_FRAME) {
			fx += (cx - prev_x) * _velo;
			fy += (cy - prev_y) * _velo;
		}
		
		fx =  fx * _strn * 10000;
		fy = -fy * _strn * 10000;
		
		grainSim_setForceParam(fx, fy);
		
		switch(_shape) {
			case 0 : grainSim_Force_Apply_Rectangle(_domain.index, cx, cy, sx, sy); break;
			case 1 : grainSim_Force_Apply_Circle(_domain.index, cx, cy, sx, sy);    break;
			
			case 2 : 
				if(!is_surface(_surf)) break;
				
				var _size = _domain.size;
				temp_surface[0] = surface_verify(temp_surface[0], _size, _size, surface_r8unorm);
				surface_set_target(temp_surface[0]);
					DRAW_CLEAR
					BLEND_OVERRIDE
					draw_surface(_surf, 0, 0);
					BLEND_NORMAL
				surface_reset_target();
				
				buffer_get_surface(surfBuff, temp_surface[0], 0);
				grainSim_Force_Apply_Buffer(_domain.index, buffer_get_address(surfBuff));
				break;
		}
		
		prev_x = cx;
		prev_y = cy;

	}

}