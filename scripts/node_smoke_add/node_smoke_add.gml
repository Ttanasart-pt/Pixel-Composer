function Node_Smoke_Add(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Add Emitter";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	manual_ungroupable	 = false;
	
	newInput( 3, nodeValue_Active());
	newInput( 0, nodeValue(      "Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone)).setVisible(true, true);
	
	////- =Brush
	newInput( 8, nodeValue_Enum_Button(  "Type",        0, [ "Shape", "Surface" ]));
	newInput( 1, nodeValue_Surface(      "Fluid brush" ));
	newInput(11, nodeValue_Enum_Scroll(  "Shape",       0, [ "Disk", "Ring" ]));
	newInput(12, nodeValue_Slider_Range( "Level",      [0,1] ));
	newInput( 2, nodeValue_Vec2(         "Position",   [0,0] ));
	newInput( 9, nodeValue_Vec2(         "Scale",      [8,8] ));
	
	////- =Smoke
	newInput( 5, nodeValue_Slider( "Density", 1 ));
	
	////- =Push
	newInput( 6, nodeValue_Int(    "Expand velocity mask", 1    ));
	newInput( 7, nodeValue_Vec2(   "Velocity",            [0,0] ));
	newInput( 4, nodeValue_Slider( "Inherit velocity",     0, [ -1, 1, 0.01 ] ));
	
	////- =Repulse
	newInput(10, nodeValue_Float(    "Repulse", 0 ));
	newInput(13, nodeValue_Float(    "Spokes",  0 ));
	newInput(14, nodeValue_Rotation( "Twist",   0 ));
	// input 15
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	input_display_list = [ 3, 0, 
		["Brush",	 false], 8, 1, 11, 12, 2, 9, 
		["Smoke",	 false], 5, 
		["Push",	 false], 6, 7, 4, 
		["Repulse",  false], 10, 13, 14, 
	];
	
	_prevPos     = noone;
	temp_surface = array_create(4);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _typ = getInputData(8);
		var _mat = getInputData(1);
		var _pos = getInputData(2);
		var _sca = getInputData(9);
		
		var _px  = _x + _pos[0] * _s;
		var _py  = _y + _pos[1] * _s;
		
		if(_typ == 0) {
			var sw = _sca[0] * _s;
			var sh = _sca[1] * _s;
			
			draw_set_color(c_white);
			draw_set_alpha(.5);
			draw_set_circle_precision(32);
			draw_ellipse(_px - sw, _py - sh, _px + sw, _py + sh, false);
			draw_set_alpha(1);
			
			InputDrawOverlay(inputs[9].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
			
		} else if(_typ == 1) {
			if(is_surface(_mat)) {
				var sw = surface_get_width_safe(_mat) * _s;
				var sh = surface_get_height_safe(_mat) * _s;
				var mx = _px - sw / 2;
				var my = _py - sh / 2;
				
				draw_surface_ext_safe(_mat, mx, my, _s, _s, 0, c_white, 0.5);
			}
		}
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _act = getInputData(3);
		var _dom = getInputData(0);
		
		var _typ = getInputData( 8);
		var _mat = getInputData( 1);
		var _den = getInputData( 5);
		var _pos = getInputData( 2);
		var _sca = getInputData( 9);
		var _shp = getInputData(11);
		var _lev = getInputData(12);
		
		var _msk   = getInputData( 6);
		var _vel   = getInputData( 7);
		var _inh   = getInputData( 4);
		var _rep   = getInputData(10);
		var _spk   = getInputData(13);
		var _spk_r = getInputData(14);
		
		inputs[ 1].setVisible(_typ == 1, _typ == 1);
		inputs[ 9].setVisible(_typ == 0);
		inputs[11].setVisible(_typ == 0);
		inputs[12].setVisible(_typ == 0);
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		if(!_act) return;
		
		var dx = _vel[0];
		var dy = _vel[1];
		var sw = 0;
		var sh = 0;
		
		if(_prevPos != noone && _inh != 0) {
			dx += (_pos[0] - _prevPos[0]) * _inh;
			dy += (_pos[1] - _prevPos[1]) * _inh;
		}
		
		_prevPos[0] = _pos[0];
		_prevPos[1] = _pos[1];
		
		if(_typ == 0) {
			sw = _sca[0] * 2;
			sh = _sca[1] * 2;
			
			temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
			surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
				shader_set_f("smooth", _lev);
				draw_set_circle_precision(32);
				
				switch(_shp) {
					case 0 : draw_ellipse_color(0, 0, sw - 1, sh - 1, c_white, c_white, false); break;
					case 1 : draw_ellipse_color(0, 0, sw - 1, sh - 1, c_black, c_white, false); break;
				}
			surface_reset_shader();
			
		} else if(_typ == 1) {
			if(!is_surface(_mat)) return;
			
			sw = surface_get_width_safe(_mat);
			sh = surface_get_height_safe(_mat);
			
			temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
			surface_set_shader(temp_surface[0], sh_fd_visualize);
				draw_surface_safe(_mat);
			surface_reset_shader();
		}
		
		_dom.addMaterial(temp_surface[0], _pos[0] - sw / 2, _pos[1] - sh / 2, 1, 1, c_white, _den);
		
		////////////////////////////////////////////////////////// VELOCITY //////////////////////////////////////////////////////////
		
		var _vw = sw + max(0, _msk * 2);
		var _vh = sh + max(0, _msk * 2);
		
		temp_surface[1] = surface_verify(temp_surface[1], _vw, _vh);
		surface_set_shader(temp_surface[1],,, BLEND.over);
			draw_surface_safe(temp_surface[0], max(0, _msk), max(0, _msk));
		surface_reset_shader();
		
		temp_surface[2] = surface_verify(temp_surface[2], _vw, _vh);
		surface_set_shader(temp_surface[2], sh_mask_expand);
			shader_set_f("dimension", _vw, _vh);
			shader_set_f("amount",    _msk);
			draw_surface_safe(temp_surface[1]);
		surface_reset_shader();
		
		if(dx != 0 || dy != 0) _dom.addVelocity(temp_surface[2], _pos[0] - _vw / 2, _pos[1] - _vh / 2, 1, 1, dx, dy);
		
		if(_rep != 0) {
			temp_surface[3] = surface_verify(temp_surface[3], _dom.width, _dom.height, surface_rgba32float);
			surface_set_shader(temp_surface[3], sh_fd_repulse);
				shader_set_f("strength", _rep);
				shader_set_f("spokes",   _spk);
				shader_set_f("rotate",   degtorad(_spk_r));
				shader_set_f("radius",   max(_vw /_dom.width, _vh / _dom.height));
				shader_set_f("center",   _pos[0] / _dom.width, _pos[1] / _dom.height);
				draw_empty();
			surface_reset_shader();
			
			_dom.addVelocity(temp_surface[3]);
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var _typ = getInputData(8);
		
		if(_typ == 0) {
			draw_circle_ui(bbox.xc, bbox.yc, min(bbox.w, bbox.h) * .25, 0);
			
		} else {
			var _mat = getInputData(1);
			if(!is_surface(_mat)) return;
			draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
		}
	}
}