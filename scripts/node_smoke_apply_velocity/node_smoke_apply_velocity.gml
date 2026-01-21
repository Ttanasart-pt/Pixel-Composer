function Node_Smoke_Apply_Velocity(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name  = "Apply Velocity";
	setDimension(96, 96);
	
	manual_ungroupable	 = false;
	
	////- =Domain
	newActiveInput(4);
	newInput(0, nodeValue( "Domain", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone )).setVisible(true, true);
	
	////- =Brush
	newInput(5, nodeValue_Enum_Button( "Type", 0, [ "Shape", "Surface" ] ));
	newInput(1, nodeValue_Surface( "Brush" ));
	newInput(6, nodeValue_Vec2(    "Scale",    [ 8, 8 ] )).setHotkey("S");
	newInput(2, nodeValue_Vec2(    "Position", [ 0, 0 ] )).setHotkey("G");
	
	////- =Velocity
	newInput(3, nodeValue_Vec2(    "Velocity", [ 1, 0 ] ));
	newInput(7, nodeValue_Float(   "Strength", 1        ));
	// input 8
	
	input_display_list = [ 4, 0, 
		["Brush",	 false], 5, 1, 6, 2, 
		["Velocity", false], 3, 7, 
	];
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _typ = getInputData(5);
		var _mat = getInputData(1);
		var _pos = getInputData(2);
		var _sca = getInputData(6);
		
		var _px  = _x + _pos[0] * _s;
		var _py  = _y + _pos[1] * _s;
		
		if(_typ == 0) {
			var sw = _sca[0] * _s;
			var sh = _sca[1] * _s;
			
			draw_set_circle_precision(32);
			draw_set_color(c_white);
			draw_set_alpha(.5);
			draw_ellipse(_px - sw, _py - sh, _px + sw, _py + sh, false);
			draw_set_alpha(1);
			
			InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
			
		} else if(_typ == 1) {
			if(is_surface(_mat)) {
				var sw = surface_get_width_safe(_mat) * _s;
				var sh = surface_get_height_safe(_mat) * _s;
				var mx = _px - sw / 2;
				var my = _py - sh / 2;
				
				draw_surface_ext_safe(_mat, mx, my, _s, _s, 0, c_white, 0.5);
			}
		}
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny, 0, 4));
		
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _act = getInputData(4);
		var _dom = getInputData(0);
		
		var _typ = getInputData(5);
		var _mat = getInputData(1);
		var _sca = getInputData(6);
		var _pos = getInputData(2);
		var _vel = getInputData(3);
		var _str = getInputData(7);
		
		inputs[1].setVisible(_typ == 1, _typ == 1);
		inputs[6].setVisible(_typ == 0);
		
		SMOKE_DOMAIN_CHECK
		outputs[0].setValue(_dom);
		
		if(!_act) return;
		var sw, sh;
		
		if(_typ == 0) {
			sw = _sca[0] * 2;
			sh = _sca[1] * 2;
			
			temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
			surface_set_shader(temp_surface[0], noone);
				draw_ellipse_color(0, 0, sw - 1, sh - 1, c_white, c_white, false);
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
		
        _dom.addVelocity(temp_surface[0], _pos[0] - sw / 2, _pos[1] - sh / 2, 1, 1, _vel[0] * _str, _vel[1] * _str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var _mat = getInputData(1);
		if(!is_surface(_mat)) return;
		
		draw_surface_fit(_mat, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}