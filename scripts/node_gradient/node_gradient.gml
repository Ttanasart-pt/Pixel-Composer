#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Gradient", "Type > Toggle",     "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() +  1) % 3  ); });
		addHotkey("Node_Gradient", "Angle > Rotate CCW","R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 90) % 360); });
		addHotkey("Node_Gradient", "Gradient > Invert", "I", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS 
			var _grad = _n.inputs[1].getValue();
			var _k = [];
			for( var i = 0, n = array_length(_grad.keys); i < n; i++ ) {
				_k[i] = _grad.keys[n - i - 1];
				_k[i].time = 1 - _k[i].time;
			}
			_grad.keys = _k;
			_grad.refresh();
			_n.inputs[1].setValue(_grad);
		});
	});
#endregion

function Node_Gradient(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Gradient";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput(18, nodeValue_Surface(  "UV Map"     ));
	newInput(19, nodeValue_Slider(   "UV Mix", 1  ));
	newInput( 8, nodeValue_Surface(  "Mask"       ));
	
	////- =Gradient
	newInput( 1, nodeValue_Gradient( "Gradient", gra_black_white )).setHotkeyAuto("C").setMappable(15).setPieMenu();
	newInput( 5, nodeValue_Slider(   "Shift",    0, [-2,2,.01]   )).setMappable(12).setPieMenu();
	newInput( 9, nodeValue_Slider(   "Scale",    1, [ 0,5,.01]   )).setHotkey("S").setMappable(13).setPieMenu();
	newInput( 7, nodeValue_EButton(  "Loop",     0, [ "None", "Loop", "Pingpong" ] ));
	
	////- =Remap
	newInput(20, nodeValue_Curve(    "Progress Remap", CURVE_DEF_01 ));
	newInput(21, nodeValue_Float(    "Inverse Axis",   0 ));
	newInput(22, nodeValue_Curve(    "Inverse Curve",  CURVE_DEF_00 ));
	
	////- =Shape
	__gradTypes = __enum_array_gen(["Linear", "Circular", "Radial", "Diamond"], s_node_gradient_type);
	newInput( 2, nodeValue_EScroll(  "Type",           0, __gradTypes )).setTopbar();
	newInput( 3, nodeValue_Rotation( "Angle",          0      )).setHotkey("R").setMappable(10).hideLabel().setPieMenu();
	newInput( 4, nodeValue_Float(    "Radius",        .5      )).setMappable(11);
	newInput( 6, nodeValue_Vec2(     "Center",        [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput(17, nodeValue_Vec2(     "Shape",         [1,1]   )).setPieMenu();
	newInput(14, nodeValue_Bool(     "Uniform ratio",  true   ));
	
	////- =Rendering
	newInput(23, nodeValue_Range( "Level In",  [0,1]     ));
	newInput(25, nodeValue_Range( "Level Out", [0,1]     ));
	newInput(24, nodeValue_Curve( "Curve",  CURVE_DEF_01 ));
	// 26
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output",    true  ],  0, 18, 19,  8, 
		[ "Gradient",  false ],  1, 15,  5, 12,  9, 13,  7, 
		[ "Remapper",  true  ], 20, 21, 22, 
		[ "Shape",     false ],  2,  3, 10,  4, 11,  6, 17, 14, 
		[ "Rendering", false ], 23, 25, 24, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	#region tools
		tool_line = new NodeTool("Draw Line", THEME.line_tool, "Node_Gradient");
		tool_area = new NodeTool("Draw Area", THEME.area_tool, "Node_Gradient");
		tools = [];
		
		dragging = false;
		drag_mx  = 0;
		drag_my  = 0;
	#endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var  dim = getInputSingle(0);
		var  typ = getInputSingle(2);
		var  rot = getInputSingle(3);
		var  pos = getInputSingle(6);
		
		var _px = _x + pos[0] * _s;
		var _py = _y + pos[1] * _s;
		var _pa = typ == 0? rot : 0;
		var _ps = dim[0] / 2;
		
		switch(PANEL_PREVIEW.tool_current) {
			case tool_line :
				w_hovering = true;
				
				draw_set_color_alpha(COLORS._main_icon, .5);
				draw_line(_mx, 0, _mx, 9999);
				draw_line(0, _my, 9999, _my);
				draw_set_alpha(1);
				
				if(dragging) {
					var _dpx = (drag_mx - _x) / _s;
					var _dpy = (drag_my - _y) / _s;
					
					var _mpx = (_mx - _x) / _s;
					var _mpy = (_my - _y) / _s;
					
					var _ang = point_direction( _dpx, _dpy, _mpx, _mpy );
					var _dis = point_distance(  _dpx, _dpy, _mpx, _mpy );
					var _sca = _dis / _ps;
					if(typ == 0) _sca /= 2;
					
					if(key_mod_press(SHIFT)) _ang = value_snap(_ang, 15);
					
					var _cx = (_dpx + _mpx) / 2;
					var _cy = (_dpy + _mpy) / 2;
					
					var _edt = false;
					if(inputs[3].setValue(_ang))      _edt = true;
					if(inputs[9].setValue(_sca))      _edt = true;
					
					if(typ == 0 && inputs[6].setValue([_cx,_cy]))   _edt = true;
					if(typ == 2 && inputs[6].setValue([_dpx,_dpy])) _edt = true;
					
					if(_edt) UNDO_HOLDING = true;
					
					draw_set_color(COLORS._main_accent);
					draw_line_width(drag_mx, drag_my, _mx, _my, ui(2));
					draw_anchor(1, drag_mx, drag_my);
					draw_anchor(0, _mx, _my);
					
					if(mouse_lrelease()) {
						dragging     = false;
						UNDO_HOLDING = false;
					}
					
				} else {
					if(hover && mouse_lpress(active)) {
						dragging = true;
						drag_mx  = _mx;
						drag_my  = _my;
					}
				}
				break;
			
			case tool_area :
				w_hovering = true;
				
				draw_set_color_alpha(COLORS._main_icon, .5);
				draw_line(_mx, 0, _mx, 9999);
				draw_line(0, _my, 9999, _my);
				draw_set_alpha(1);
				
				if(dragging) {
					var _dpx = (drag_mx - _x) / _s;
					var _dpy = (drag_my - _y) / _s;
					
					var _mpx = (_mx - _x) / _s;
					var _mpy = (_my - _y) / _s;
					
					if(key_mod_press(SHIFT)) {
						var _dx = (_mpx - _dpx);
						var _dy = (_mpy - _dpy);
						var _dd = max(abs(_dx), abs(_dy));
						
						_dx = sign(_dx) * _dd;
						_dy = sign(_dy) * _dd;
						
						_mpx = _dpx + _dx;
						_mpy = _dpy + _dy;
					}
					
					if(key_mod_press(ALT)) {
						_dpx -= _mpx - _dpx;
						_dpy -= _mpy - _dpy;
							
					}
					
					var _dx = (_mpx - _dpx) / dim[0];
					var _dy = (_mpy - _dpy) / dim[1];
					
					var _cx = (_dpx + _mpx) / 2;
					var _cy = (_dpy + _mpy) / 2;
					
					var _edt = false;
					if(inputs[ 6].setValue([_cx,_cy]))   _edt = true;
					if(inputs[17].setValue([_dx,_dy]))   _edt = true;
					
					if(_edt) UNDO_HOLDING = true;
					
					draw_set_color(COLORS._main_accent);
					draw_rectangle(_x+_mpx*_s, _y+_mpy*_s, _x+_dpx*_s, _y+_dpy*_s, true);
					
					if(mouse_lrelease()) {
						dragging     = false;
						UNDO_HOLDING = false;
					}
					
				} else {
					if(hover && mouse_lpress(active)) {
						dragging = true;
						drag_mx  = _mx;
						drag_my  = _my;
					}
				}
				break;
				
			default :
				drawOverlayInput(inputs[ 6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				drawOverlayInput(inputs[16].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, current_data[0]));
				drawOverlayInput(inputs[ 9].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _pa, _ps, 1));
				
				if(typ != 1) drawOverlayInput(inputs[ 3].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my));
				else         drawOverlayInput(inputs[17].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, 0, [ dim[0] / 2, dim[1] / 2 ]));
				break;
			
		}
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim  = _data[ 0];
			var _msk  = _data[ 8];
			
			var _lop  = _data[ 7];
			
			var _crv  = _data[20];
			var _inv  = _data[21];
			var _invC = _data[22];
			
			var _typ  = _data[ 2];
			var _cnt  = _data[ 6];
			var _csca = _data[17];
			var _uni  = _data[14];
			
			var _lvl  = _data[23];
			var _lvo  = _data[25];
			var _curv = _data[24];
			
			inputs[ 3].setVisible(_typ != 1);
			inputs[ 4].setVisible(_typ == 1);
			
			inputs[14].setVisible(_typ);
			inputs[17].setVisible(_typ == 1 || _typ == 3);
		#endregion
		
		switch(_typ) {
			case 0 : 
			case 2 : 
				tools = [ tool_line ];
				break;
				
			case 1 : 
			case 3 : 
				tools = [ tool_area ];
				break;
		}
		
		var _sw = toNumber(_dim[0]);
		var _sh = toNumber(_dim[1]);
		
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		surface_set_shader(_outSurf, sh_gradient);
			shader_set_uv(_data[18], _data[19]);
			shader_set_gradient(_data[1], _data[15], _data[16], inputs[1]);
			
			shader_set_2(  "dimension",     _dim  );
			
			shader_set_cr( "pCurve",        _crv  );
			shader_set_f(  "useAxis",       _inv  );
			shader_set_cr( "iCurve",        _invC );
			
			shader_set_i(  "gradient_loop", _lop  );
			shader_set_2(  "center",        _cnt  );
			shader_set_i(  "type",          _typ  );
			shader_set_i(  "uniAsp",        _uni  );
			shader_set_2(  "cirScale",      _csca );
			
			shader_set_2(  "levelIn",       _lvl  );
			shader_set_2(  "levelOut",      _lvo  );
			shader_set_cr( "wcurve",        _curv );
			
			shader_set_m(  "angle",  _data[3], _data[10], inputs[3] );
			shader_set_m(  "radius", _data[4], _data[11], inputs[4] );
			shader_set_m(  "shift",  _data[5], _data[12], inputs[5] );
			shader_set_m(  "scale",  _data[9], _data[13], inputs[9] );
			
			if(is_surface(_msk)) draw_surface_stretched_safe(_msk, 0, 0, _sw, _sh, c_white, 1);
			else                 draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}