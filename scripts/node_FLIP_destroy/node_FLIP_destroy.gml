function Node_FLIP_Destroy(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Destroy Fluid";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDrawIcon();
	setDimension(96, 48);
	
	manual_ungroupable = false;
	
	newInput( 0, nodeValue_Fdomain("Domain")).setVisible(true, true);
	
	////- =Mask
	newInput( 2, nodeValue_EScroll( "Shape",    0 , [ 
		new scrollItem( "Circle",    s_node_shape_circle    ), 
		new scrollItem( "Rectangle", s_node_shape_rectangle ),
		new scrollItem( "Surface"                           ),
	]));
	
	newInput( 1, nodeValue_Vec2(    "Position", [0,0]         )).setHotkey("G").setUnitSimple();
	newInput( 3, nodeValue_Slider(  "Radius",    4, [1,16,.1] ));
	newInput( 4, nodeValue_Vec2(    "Size",     [4,4]         ));
	newInput( 6, nodeValue_Surface( "Mask"                    ));
	newInput( 7, nodeValue_Slider(  "Threshold", .1           ));
	newInput( 8, nodeValue_Int(     "Expands",    0           ));
	
	////- =Destroy
	newInput( 5, nodeValue_Slider( "Ratio",    1      ));
	// 9
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	input_display_list = [ 0, 
		[ "Mask",    false ],  2,  1,  3,  4,  6,  7,  8, 
		[ "Destroy", false ],  5, 
	];
	
	////- Node
	
	temp_surface = [ noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _pos = getInputData(1);
		var _shp = getInputData(2);
		var _rad = getInputData(3);
		var _siz = getInputData(4);
		
		var _px = _x + _pos[0] * _s;
		var _py = _y + _pos[1] * _s;
		
		var _r = _rad * _s;
		var _w = _siz[0] * _s;
		var _h = _siz[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		     if(_shp == 0) draw_circle(_px, _py, _r, true);
		else if(_shp == 1) draw_rectangle(_px - _w, _py - _h, _px + _w, _py + _h, true);
		
		drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static update = function() { 
		#region data
			var domain = getInputData(0);
			
			var _shp   = getInputData( 2);
			
			var _pos   = getInputData( 1);
			var _shp   = getInputData( 2);
			var _rad   = getInputData( 3);
			var _siz   = getInputData( 4);
			
			var _surf  = getInputData( 6);
			var _thrs  = getInputData( 7);
			var _expn  = getInputData( 8);
			
			var _rat   = getInputData( 5);
			
			inputs[ 1].setVisible(_shp != 2);
			inputs[ 3].setVisible(_shp == 0);
			inputs[ 4].setVisible(_shp == 1);
			
			inputs[ 6].setVisible(_shp == 2, _shp == 2);
			inputs[ 7].setVisible(_shp == 2);
			inputs[ 8].setVisible(_shp == 2);
			
			if(!instance_exists(domain)) return;
			
			outputs[0].setValue(domain);
		#endregion
		
		switch(_shp) {
			case 0: FLIP_deleteParticle_circle(domain.domain, _pos[0], _pos[1], _rad, _rat);                break;
			case 1: FLIP_deleteParticle_rectangle(domain.domain, _pos[0], _pos[1], _siz[0], _siz[1], _rat); break;
			
			case 2:
				if(!is_just_surface(_surf)) break;
				
				var ww = domain.cellX;
				var hh = domain.cellY;
				
				temp_surface[0] = surface_verify(temp_surface[0], ww, hh, surface_r8unorm);
				temp_surface[1] = surface_verify(temp_surface[1], ww, hh, surface_r8unorm);
				
				surface_set_shader(temp_surface[0], sh_flip_solid_surface_cvt);
					shader_set_f( "threshold", _thrs   );
					draw_surface_stretched(_surf, 0, 0, ww, hh);
				surface_reset_shader();
				
				surface_set_shader(temp_surface[1], sh_flip_solid_surface_expand);
					shader_set_2( "dimension", [ww,hh] );
					shader_set_f( "expands",   _expn   );
					
					draw_surface_stretched(temp_surface[0], 0, 0, ww, hh);
				surface_reset_shader();
				
				var _buff = buffer_create(ww * hh, buffer_fixed, 1);
				buffer_get_surface(_buff, temp_surface[1], 0);
				
				FLIP_deleteParticle_surface(domain.domain, buffer_get_address(_buff), _rat);
				buffer_delete(_buff);
				break;
		}
		
	}
	
	static getPreviewValues = function() { 
		var domain = getInputData(0); 
		var _shp   = getInputData(2);
		
		if(_shp == 2) return temp_surface[1];
		return instance_exists(domain)? domain.domain_preview : noone; 
	}
	
}