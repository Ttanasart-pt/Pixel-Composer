function Node_GrainSim_Solid(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Solid";
	color = COLORS.node_blend_grain;
	icon  = THEME.grain_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	update_on_frame    = true;
	
	newInput( 5, nodeValue_Bool(    "Active",    true  ));
	
	////- =Domain
	newInput( 0, nodeValue_Struct( "Domain" )).setCustomData(global.GRAINSIM_JUNC).setVisible(true, true);
	
	////- =Solid
	newInput( 1, nodeValue_EScroll( "Shape",      0, [ "Rectangle", "Circle", "Surface" ] ));
	newInput( 2, nodeValue_Vec2(    "Center",   [.5,.5] )).setUnitSimple();
	newInput( 3, nodeValue_Vec2(    "Size",     [.5,.5] )).setUnitSimple();
	newInput( 4, nodeValue_Surface( "Surface"           ));
	// 6
	
	newOutput( 0, nodeValue_Output("Domain", VALUE_TYPE.struct, {} )).setCustomData(global.GRAINSIM_JUNC);
	
	input_display_list = [ 5, 
		[ "Domain", false ],  0, 
		[ "Solid",  false ],  1,  2,  3,  4,  
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
			var _active = inputs[ 5].getValue();
			var _domain = inputs[ 0].getValue();
			
			var _shape  = inputs[ 1].getValue();
			var _cen    = inputs[ 2].getValue();
			var _siz    = inputs[ 3].getValue();
			var _surf   = inputs[ 4].getValue();
			
			inputs[ 2].setVisible(_shape != 2);
			inputs[ 3].setVisible(_shape != 2);
			inputs[ 4].setVisible(_shape == 2, _shape == 2);
		#endregion
		
		if(!is(_domain, GrainSim_Domain)) return;
		
		outputs[0].setValue(_domain);
		if(!_active) return;
		
		switch(_shape) {
			case 0 : grainSim_Solid_Rectangle(_domain.index, _cen[0], _cen[1], _siz[0], _siz[1]); break;
			case 1 : grainSim_Solid_Circle(_domain.index, _cen[0], _cen[1], _siz[0], _siz[1]); break;
			
			case 2 : 
				if(!is_surface(_surf)) break;
				
				var _size = _domain.size;
				temp_surface[0] = surface_verify(temp_surface[0], _size, _size, surface_r8unorm);
				surface_set_target(temp_surface[0]);
					DRAW_CLEAR
					draw_surface(_surf, 0, 0);
				surface_reset_target();
				
				buffer_get_surface(surfBuff, temp_surface[0], 0);
				grainSim_Solid_Buffer(_domain.index, buffer_get_address(surfBuff));
				break;
		}
		
	}

}