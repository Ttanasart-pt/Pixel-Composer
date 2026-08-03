function canvas_s_tool_curve() : canvas_s_tool() constructor {
	icon     = THEME.canvas_tools_curve;
	tooltip  = "Curve";
	hotkey   = new KeyCombination("L", MOD_KEY.shift);
	isDrawer = true;
	
	mouse_drawing = false;
	shape_x = undefined;
	shape_y = undefined;
	
	brush = new canvas_s_brush();
	
	settings = [
		brush.settings,
			
		-1, 
		
		new __Simple_Editor( "", button(function() /*=>*/ {return apply()}).setTooltip("Apply")
			.setBaseSprite(THEME.button_hide_fill).setIcon(THEME.accept, 0, COLORS._main_value_positive, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} ),
			
		new __Simple_Editor( "", button(function() /*=>*/ { canvas.resetTool(); anchors = []; }).setTooltip("Cancel")
			.setBaseSprite(THEME.button_hide_fill).setIcon(THEME.cross,  0, COLORS._main_value_negative, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} ),
	];
	
	anchors = [];
	editing = [ noone, 0 ];
	
	mouse_edit_mx = 0;
	mouse_edit_my = 0;
	
	mouse_hovering = [ noone, 0 ];
	doApply = false;
	
	////- Functions
	
	function drawing(_drawingSurface) {
		var mpx = round((mx - preview_x) / preview_s - .5);
		var mpy = round((my - preview_y) / preview_s - .5);
		var dim = surface_get_dimension(_drawingSurface);
		
		brush.step(canvas, dim);
		
		if(mouse_drawing) {
			#region preview
				var _prc = 32;
				var _st  = 1 / _prc;
				
				surface_set_target(_drawingSurface);
					DRAW_CLEAR
					BLEND_MAX
					draw_set_color(c_white);
					
					var ox, oy, nx, ny;
					var oax1, oay1, nax0, nay0;
					
					for (var i = 0, n = array_length(anchors); i < n; i++) {
						nx = anchors[i][2];
						ny = anchors[i][3];
						
						nax0 = nx + anchors[i][0];
						nay0 = ny + anchors[i][1];
						
						if(i) {
							var _ox, _oy, _nx, _ny;
							
							var _x0  = ox;
							var _y0  = oy;
							var _cx0 = oax1;
							var _cy0 = oay1;
							var _cx1 = nax0;
							var _cy1 = nay0;
							var _x1  = nx;
							var _y1  = ny;
							
							_ox  = ox;
							_oy  = oy;
							
							for (var j = 1; j <= _prc; j++) {
								var _t  = _st * j;
								var _t1 = 1 - _t;
								
								_nx =     _t1 * _t1 * _t1 *  _x0 + 
								      3 * _t1 * _t1 * _t  * _cx0 + 
								      3 * _t1 * _t  * _t  * _cx1 + 
								          _t  * _t  * _t  *  _x1;
								     
								_ny =     _t1 * _t1 * _t1 *  _y0 + 
								      3 * _t1 * _t1 * _t  * _cy0 + 
								      3 * _t1 * _t  * _t  * _cy1 + 
								          _t  * _t  * _t  *  _y1;
								
								var dist = point_distance(_ox, _oy, _nx, _ny);
								
								if(dist > 3 || j == _prc) {
									if(brush.size == 1) brush.drawLinePx(round(_ox), round(_oy), round(_nx), round(_ny));
									else brush.drawLine(_ox, _oy, _nx, _ny);
										
									_ox = _nx;
									_oy = _ny;
									
								}
							}	
						}
						
						oax1 = nx + anchors[i][4];
						oay1 = ny + anchors[i][5];
						
						ox = nx;
						oy = ny;
					}
					BLEND_NORMAL
				surface_reset_target();
				
			#endregion
			
			#region mouse
				var ox, oy, nx, ny, ax0, ay0, ax1, ay1;
				var oax1, oay1, nax0, nay0;
				
				draw_set_color(COLORS._main_icon);
				for (var i = 0, n = array_length(anchors); i < n; i++) {
					nx = preview_x + anchors[i][2]  * preview_s;
					ny = preview_y + anchors[i][3]  * preview_s;
					
					nax0 = nx + anchors[i][0] * preview_s;
					nay0 = ny + anchors[i][1] * preview_s;
					
					oax1 = nx + anchors[i][4] * preview_s;
					oay1 = ny + anchors[i][5] * preview_s;
					
					draw_line(nx, ny, nax0, nay0);
					draw_line(nx, ny, oax1, oay1);
				}
				
				var _hovInd = mouse_hovering[0];
				var _hovTyp = mouse_hovering[1];
				mouse_hovering = [ noone, 0 ];
				
				for (var i = 0, n = array_length(anchors); i < n; i++) {
					nx = preview_x + anchors[i][2] * preview_s;
					ny = preview_y + anchors[i][3] * preview_s;
					
					ax0 = nx + anchors[i][0] * preview_s;
					ay0 = ny + anchors[i][1] * preview_s;
					
					ax1 = nx + anchors[i][4] * preview_s;
					ay1 = ny + anchors[i][5] * preview_s;
					
					draw_anchor( 0,  nx,  ny, ui(7 + 2 * (_hovInd == i && _hovTyp ==  0))    );
					draw_anchor( 0, ax0, ay0, ui(5 + 2 * (_hovInd == i && _hovTyp == -1)), 2 );
					draw_anchor( 0, ax1, ay1, ui(5 + 2 * (_hovInd == i && _hovTyp ==  1)), 2 );
					
					     if(point_in_circle(mx, my, nx, ny,   ui(10))) mouse_hovering = [ i,  0 ];
					else if(point_in_circle(mx, my, ax0, ay0, ui(10))) mouse_hovering = [ i, -1 ];
					else if(point_in_circle(mx, my, ax1, ay1, ui(10))) mouse_hovering = [ i,  1 ];
				}
				
				var index = mouse_hovering[0] != noone? mouse_hovering[0] * 3 + mouse_hovering[1] + 1 : noone;
				if(mouse_hovering[0] == noone && editing[0] == noone) draw_anchor(0, mx, my, ui(7));
				
				if(mouse_lpress(focus)) {
					if(mouse_hovering[0] == noone) {
						array_push(anchors, [ 0, 0, mpx, mpy, 0, 0 ]);
						editing[0] = array_length(anchors) - 1;
						editing[1] = 1;
						
					} else {
						if(key_mod_press(SHIFT))
							array_delete(anchors, mouse_hovering[0], 1);
						else {
							editing[0] = mouse_hovering[0];
							editing[1] = mouse_hovering[1];
						}
					}
					
					mouse_edit_mx = mpx;
					mouse_edit_my = mpy;
				} 
						
				if(editing[0] != noone) {
					var _a  = anchors[editing[0]];
					var _dx = mpx - mouse_edit_mx;
					var _dy = mpy - mouse_edit_my;
					
					if(editing[1] == 0) {
						_a[2] += _dx;
						_a[3] += _dy;
						
					} else if(editing[1] == -1) {
						_a[0] += _dx;
						_a[1] += _dy;
						
						_a[4] -= _dx;
						_a[5] -= _dy;
						
					} else if(editing[1] == 1) {
						_a[0] -= _dx;
						_a[1] -= _dy;
						
						_a[4] += _dx;
						_a[5] += _dy;
						
					}
					
					mouse_edit_mx = mpx;
					mouse_edit_my = mpy;
					
					if(mouse_lrelease())
						editing[0] = noone;
				}
			
			#endregion
			
			
			
			if(doApply || (focus && (DOUBLE_CLICK || key_press(vk_enter)))) {
				mouse_drawing = false;
				canvas.applySurface(_drawingSurface);
				
			} 
			
			if(focus && (mouse_rpress() || key_press(vk_escape))) {
				mouse_drawing = false;
				anchors = [];
			}
			
		} else {
			surface_set_target(_drawingSurface);
				DRAW_CLEAR
				draw_set_color(c_white);
				brush.drawPixel(mpx, mpy);
			surface_reset_target();
				
			if(hover && mouse_lpress(focus)) {
				mouse_drawing = true;
				
				anchors = [ [ 0, 0, mpx, mpy, 0, 0 ] ];
				editing = [ 0, 1 ];
				
				mouse_edit_mx = mpx;
				mouse_edit_my = mpy;
			}
		}
		
		doApply = false;
	}
	
	function apply() { doApply = true; }
}