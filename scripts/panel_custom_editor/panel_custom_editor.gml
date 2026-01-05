function Panel_Custom_Editor(_data = undefined) : PanelContent() constructor {
	title    = "Custom";
	data     = _data;
	auto_pin = true;
	w = min(WIN_W - ui(64), ui(1400));
	h = min(WIN_H - ui(64), ui(800));
	
	b_redir_new = button(function() /*=>*/ { array_push(data.io_redirect, new IO_Redirect(data)) })
		.setIcon(THEME.add_16, 0, COLORS._main_value_positive).iconPad();
	
	globalEditors = [
		[ "Global", false ], 
		Simple_Editor("Panel Name", textBox_Text( function(t) /*=>*/ { data.name = t; } ), function() /*=>*/ {return data.name}, function(t) /*=>*/ { data.name = t; }),
		
		Simple_Editor("Prefered Size", new vectorBox( 2, function(v,i) /*=>*/ { 
			if(i == 0) data.prew = v; 
			else       data.preh = v; 
		} ), function() /*=>*/ {return [data.prew,data.preh]}, function(v) /*=>*/ { data.prew = v[0]; data.preh = v[1] }),
		
		Simple_Editor("Minimum Size", new vectorBox( 2, function(v,i) /*=>*/ { 
			if(i == 0) data.minw = v; 
			else       data.minh = v; 
		} ), function() /*=>*/ {return [data.minw,data.minh]}, function(v) /*=>*/ { data.minw = v[0]; data.minh = v[1] }), 
		
		Simple_Editor("Auto Pin", new checkBox( function() /*=>*/ { 
			data.auto_pin = !data.auto_pin;
		} ), function() /*=>*/ {return data.auto_pin}, function(v) /*=>*/ { data.auto_pin = v; }), 
		
		Simple_Editor("Open on Load", new checkBox( function() /*=>*/ { 
			data.open_start = !data.open_start;
		} ), function() /*=>*/ {return data.open_start}, function(v) /*=>*/ { data.open_start = v; }), 
		
		[ "IO Redirect", false, b_redir_new ], 
		"redir", 
		
	];
	
	#region ---- selection ----
		element_adding    = undefined;
		element_selecting = undefined;
		
		element_drag = undefined;
		drag_type = 0;
		drag_sx   = 0;
		drag_sy   = 0;
		drag_mx   = 0;
		drag_my   = 0;
		
		hovering_frame    = undefined;
		_hovering_frame   = undefined;
		hovering_element  = undefined;
		_hovering_element = undefined;
		
		_HOVER_WIDGET = undefined;
		 HOVER_WIDGET = undefined;
	#endregion
	
	#region ---- outline ----
		outline_drag         = undefined;
		outline_drag_side    = 0;
		outline_drag_frame   = undefined;
		
		outline_hover        = undefined;
		
		outline_height       = h / 3;
		outline_height_drag  = false;
	    outline_height_start = 0;
	    outline_height_my    = 0;
	#endregion
	
	#region ---- editor ----
		editor_toolbar_width_l = ui(240);
		editor_toolbar_width_r = ui(360);
		
		minw = editor_toolbar_width_l + editor_toolbar_width_r + ui(320);
		minh = ui(320);
	#endregion
	
	#region ---- preview ----
		preview_surface = undefined;
		preview_mode    = false;
	
		topbar_height = ui(24);
		
		topbar_buttons = [
			[
				/*0*/ __txt("Preview Mode"), 
				/*1*/ function() /*=>*/ {return THEME.sequence_control},
				/*2*/ function() /*=>*/ {return preview_mode? 0 : 1}, 
				/*3*/ function() /*=>*/ {return preview_mode? COLORS._main_value_positive : COLORS._main_icon},
				/*4*/ function() /*=>*/ { preview_mode = !preview_mode; }, 
			]
		];
		
		panel_deleting = false;
	#endregion
	
	sc_add_elements = new scrollPane(1,1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _h = 0;
		var ww = sc_add_elements.surface_w;
		
		var elements = PANEL_ELEMENT;
		var hov = sc_add_elements.hover;
		var foc = sc_add_elements.active;
		
		var yy = _y;
		var grs = ui(64);
		var lbh = ui(20);
		var col = 0;
		var maxCol = floor(ww / (grs + ui(4)));
		
		var _cAll = 0;
		
		for( var i = 0, n = array_length(elements); i < n; i++ ) {
			var ele = elements[i];
			if(is_array(ele)) {
				if(col) {
					yy += grs + ui(4);
					_h += grs + ui(4);
				}
				
				var _txt = ele[0];
				
				var cc = COLORS.panel_inspector_group_bg;
	            if(hov && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + lbh)) {
	            	cc = COLORS.panel_inspector_group_hover;
	                
	                if(foc) {
	                    	 if(DOUBLE_CLICK) _cAll = ele[1]? -1 : 1;
	                    else if(mouse_press(mb_left)) ele[1] = !ele[1];
	                }
	            }
	                
	            draw_sprite_stretched_ext(THEME.box_r2_clr, 0, 0, yy, ww, lbh, cc, 1);
	            draw_sprite_ui(THEME.arrow, ele[1]? 0 : 3, ui(12), yy + lbh / 2, .75, .75, 0, COLORS.panel_inspector_group_bg, 1);    
	            draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
	            
	            draw_text_add(ui(24), yy + lbh / 2, _txt);
				
				yy += lbh + ui(4);
				_h += lbh + ui(4);
				col = 0;
				
                if(ele[1]) { // skip 
                    var j = i + 1;
                    while(j < n) { if(is_array(elements[j])) break; j++; }
                    i = j - 1;
                }
                
				continue;
			}
			
			var nam = ele.name;
			var spr = ele.spr();
			
			var xx = (grs + ui(4)) * col;
			var hv = hov && point_in_rectangle(_m[0], _m[1], xx, yy, xx + grs, yy + grs);
			
			var sx = xx + grs / 2;
			var sy = yy + grs / 2 - ui(8);
			draw_sprite_ui_uniform(spr, 0, sx, sy, .5);
			
			draw_set_text(f_p4, fa_center, fa_bottom, COLORS._main_text);
			draw_text_add(xx + grs / 2, yy + grs - ui(2), nam);
			
			if(hv) {
				draw_sprite_stretched_add(THEME.box_r2, 1, xx, yy, grs, grs, c_white, .25);
				
				if(mouse_lpress(foc)) {
					element_adding = ele;
				}
			}
			
			col++;
			if(col >= maxCol) {
				col = 0;
				yy += grs + ui(4);
				_h += grs + ui(4);
			}
		}
		
		if(col) _h += grs + ui(4);
		
		if(_cAll ==  1) for( var i = 0, n = array_length(elements); i < n; i++ ) if(is_array(elements[i])) elements[i][1] = false; 
		if(_cAll == -1) for( var i = 0, n = array_length(elements); i < n; i++ ) if(is_array(elements[i])) elements[i][1] =  true; 
		
		return _h;
	});
	
	sc_outline = new scrollPane(1,1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var ww  = sc_outline.surface_w;
		var hov = sc_outline.hover;
		var foc = sc_outline.active;
		
		outline_drag_frame = undefined;
		outline_hover      = undefined;
		var _h = data.root.drawOutline(0, self, ui(4), _y, ww - ui(4), _m);
		
		if(outline_drag && mouse_lrelease()) {
			if(hovering_element && outline_drag != hovering_element) {
				if(outline_drag_frame) {
					array_remove(outline_drag.parent.contents, outline_drag);
					array_push(outline_drag_frame.contents, outline_drag);
					
					outline_drag.parent = outline_drag_frame;
					
				} else {
					var _ind = array_find(hovering_element.parent.contents, hovering_element) + outline_drag_side;
				    if(outline_drag.parent == hovering_element.parent) {
				    	var _cind = array_find(hovering_element.parent.contents, outline_drag);
				    	if(_cind < _ind) _ind--;
				    }
				    
					array_remove(outline_drag.parent.contents, outline_drag);
					array_insert(hovering_element.parent.contents, _ind, outline_drag);
					
					outline_drag.parent = hovering_element.parent;
				}
			}
			
			outline_drag = undefined;
		}
		
		if(hov && outline_hover == undefined) {
			if(mouse_lpress(foc)) 
				element_selecting = undefined;
		}
		
		return _h;
	});
	
	sc_properties = new scrollPane(1,1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var ww = sc_properties.surface_w;
		var rx = x + sc_properties.x;
		var ry = y + sc_properties.y;
		var _h = ui(4);
		_y += ui(4)
		
		var hov = sc_properties.hover;
		var foc = sc_properties.active;
		
		var _editors = element_selecting? element_selecting.editors : globalEditors;
		
		var lbh = ui(22);
		var wdh = ui(24);
		var bs  = wdh-ui(4);
		var wdw = ww * .6;
		
		var _cAll = 0;
		
		for( var i = 0, n = array_length(_editors); i < n; i++ ) {
			var _edt = _editors[i];
			
			if(_edt == "redir") {
				for( var j = 0, m = array_length(data.io_redirect); j < m; j++ ) {
					var io = data.io_redirect[j];
					var hh = io.drawProp(ui(8), _y, ww - ui(16), _m, hov, foc, rx, ry);
					
					_y += hh + ui(4);
					_h += hh + ui(4);
				}
				
				_y += ui(4);
				_h += ui(4);
				continue;
			}
			
			if(_edt == -1) {
				_y += ui(2);
				_h += ui(2);
				
				draw_set_color_alpha(COLORS._main_icon, .5);
				draw_line(ui(8), _y, ww - ui(16), _y);
				draw_set_alpha(1);
				
				_y += ui(6);
				_h += ui(6);
				continue;
			}
			
			if(is_array(_edt)) {
				var _txt = _edt[0];
				var _but = array_safe_get_fast(_edt, 2);
				
				_y += ui(2);
				_h += ui(2);
				
				var cc = COLORS.panel_inspector_group_bg;
				var lw = ww - (_but != 0) * ui(28);
				
	            if(hov && point_in_rectangle(_m[0], _m[1], 0, _y, lw, _y + lbh)) {
	            	cc = COLORS.panel_inspector_group_hover;
	                if(foc) {
	                    	 if(DOUBLE_CLICK) _cAll = _edt[1]? -1 : 1;
	                    else if(mouse_press(mb_left)) _edt[1] = !_edt[1];
	                }
	            }
	                
	            draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, _y, lw, lbh, cc, 1);
	            draw_sprite_ui(THEME.arrow, _edt[1]? 0 : 3, ui(16), _y + lbh / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);    
	            draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
	            draw_text_add(ui(32), _y + lbh / 2, _txt);
	            
	            if(_but) {
	            	var _bw = ui(24);
	            	var _bh = lbh;
	            	var _bx = ww - _bw;
	            	var _by = _y;
	            	
	            	draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _bx, _by, _bw, _bh, COLORS.panel_inspector_group_bg, 1);
	            	
	            	_bx += ui(2);
	            	_by += ui(2);
	            	_bw -= ui(4);
	            	_bh -= ui(4);
	            	
	            	_but.setFocusHover(foc, hov);
	            	_but.draw(_bx, _by, _bw, _bh, _m, THEME.button_hide_fill);
	            }
				
				_y += lbh + ui(4 + 2 * !_edt[1]);
				_h += lbh + ui(4 + 2 * !_edt[1]);
				
                if(_edt[1]) { // skip 
                    var j = i + 1;
                    while(j < n) { if(is_array(_editors[j])) break; j++; }
                    i = j - 1;
                }
                
				continue;
			}
			
			var _name = _edt.name;
			var _wpd  = ui(4);
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(8), _y + wdh / 2, _name);
			
			if(is(_edt, JuncLister)) {
				var wdx = ww - wdw;
				var wdy = _y;
				
				var _hh = _edt.draw(wdx, wdy, wdw, wdh, _m, foc, hov, rx, ry);
				
				_y += _hh + ui(4);
				_h += _hh + ui(4);
				continue;
			}
			
			var _widg = _edt.editWidget;
			var _data = _edt.getter();
			
			if(is(_data, __pbBox)) {
				if(element_selecting && !element_selecting.draggable) {
					var _tx = ui(8) + string_width(_name) + ui(4);
					draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
					draw_text_add(_tx, _y + wdh / 2, "[locked]");
					
					_widg.setInteract(false);
					
				} else {
					var bx = ww - bs;
					var by = _y + ui(2);
					
					if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, hov, foc, "Pad mode", THEME.fill, 0,,, .75) == 2) {
						_widg.linked = true;
						_data.anchor_x_type = PB_AXIS_ANCHOR.bounded;
						_data.anchor_y_type = PB_AXIS_ANCHOR.bounded;
						
						_data.anchor_l = 0; _data.anchor_t = 0;
						_data.anchor_r = 0; _data.anchor_b = 0;
					}
					
					_widg.setInteract(true);
				}
				
				_y += ui(24);
				_h += ui(24);
				_wpd = ui(0);
				
				var _param = new widgetParam(ui(8), _y, ww - ui(16), wdh, _data, {}, _m, rx, ry).setFont(f_p3);
					
			} else {
				var wdx = ww - wdw;
				var wdy = _y;
				var _param = new widgetParam(wdx, wdy, wdw, wdh, _data, {}, _m, rx, ry).setFont(f_p3);
			}
			
			_widg.register(sc_properties);
			_widg.setFocusHover(foc, hov);
			var _hh = _widg.drawParam(_param);
			
			_y += max(_hh, wdh) + _wpd;
			_h += max(_hh, wdh) + _wpd;
		}
		
		if(_cAll ==  1) for( var i = 0, n = array_length(_editors); i < n; i++ ) if(is_array(_editors[i])) _editors[i][1] = false; 
		if(_cAll == -1) for( var i = 0, n = array_length(_editors); i < n; i++ ) if(is_array(_editors[i])) _editors[i][1] =  true; 
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		if(!data) return;
		title = $"{data.name} [Edit]";
		
		_hovering_frame    = hovering_frame;
		_hovering_element  = hovering_element;
		
		hovering_frame   = undefined;
		hovering_element = undefined;
		hover_preview    = false;
		
		#region panels
			var pd = ui(8);
			var edt_l = editor_toolbar_width_l;
			var edt_r = editor_toolbar_width_r;
			var edt_h = h - pd - pd;
			
			var add_x = pd;
			var add_y = pd;
			var add_w = edt_l;
			var add_h = edt_h - outline_height - pd;
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, add_x, add_y, add_w, add_h);
			sc_add_elements.setFocusHover(pFOCUS, pHOVER);
			sc_add_elements.verify(add_w - ui(8), add_h - ui(8));
			sc_add_elements.drawOffset(add_x + ui(4), add_y + ui(4), mx, my);
			
			var out_x = pd;
			var out_y = pd + add_h + pd;
			var out_w = edt_l;
			var out_h = outline_height;
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, out_x, out_y, out_w, out_h);
			sc_outline.setFocusHover(pFOCUS, pHOVER);
			sc_outline.verify(out_w - ui(8), out_h - ui(8));
			sc_outline.drawOffset(out_x + ui(4), out_y + ui(4), mx, my);
			
			var prp_x = w - edt_r - pd;
			var prp_y = pd;
			var prp_w = edt_r;
			var prp_h = edt_h;
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, prp_x, prp_y, prp_w, prp_h);
			sc_properties.setFocusHover(pFOCUS, pHOVER);
			sc_properties.verify(prp_w - ui(8), prp_h - ui(8));
			sc_properties.drawOffset(prp_x + ui(4), prp_y + ui(4), mx, my);
			
			// resize
			
			var cc = COLORS._main_icon;
    		var aa = .5;
    		
			var _hov_res_out = pHOVER && point_in_rectangle(mx, my, out_x, out_y - pd, out_x + out_w, out_y);
			
	    	if(outline_height_drag) {
	            CURSOR = cr_size_we;
	            cc = COLORS._main_icon_light;
				aa = 1;
				
	            outline_height = outline_height_start - (my - outline_height_my);
	            outline_height = clamp(outline_height, ui(224), h - ui(128));
	            if(mouse_release(mb_left)) outline_height_drag = false;
	        }
	        
	        if(_hov_res_out) {
	            CURSOR = cr_size_ns;
	            aa = 1;
	            
	            if(mouse_press(mb_left, pFOCUS)) {
	                outline_height_drag  = true;
	                outline_height_start = outline_height;
	                outline_height_my    = my;
	            }
	            
	        } 
	        
	        draw_set_alpha(aa);
            draw_set_color(cc);
            draw_line_round(out_x + out_w / 2 - ui(12), out_y - pd / 2, out_x + out_w / 2 + ui(12), out_y - pd / 2, ui(3));
            draw_set_alpha(1);
		#endregion
		
		#region topbar
			var _top_x0 = pd + edt_l + pd ;
			var _top_x1 = w - pd - edt_r - pd;
			var _top_xc = (_top_x0 + _top_x1) / 2;
			
			var _top_y0 = pd;
			var _top_y1 = pd + topbar_height;
			var _top_yc = (_top_y0 + _top_y1) / 2;
			
			var bs = THEME.button_hide_fill;
			var ts = topbar_height;
			var tx = _top_xc - (array_length(topbar_buttons) * (ts + ui(2) - ui(2))) / ui(2);
			var ty = _top_y0;
			
			for( var i = 0, n = array_length(topbar_buttons); i < n; i++ ) {
				var tb = topbar_buttons[i];
				var _tooltip = tb[0];
				var _spr     = tb[1]();
				var _sind    = tb[2]();
				var _color   = tb[3]();
				var _onClick = tb[4];
				
				if(buttonInstant_Pad(bs, tx, ty, ts, ts, [mx,my], pHOVER, pFOCUS, _tooltip, _spr, _sind, _color, 1, ui(6)) == 2)
					_onClick();
					
				tx += ts + ui(2);
			}
			
			var tx = _top_x1 - ts;
			var ty = _top_y0;
			
			if(panel_deleting) {
				var _tooltip = __txt("Cancel");
				var _spr     = THEME.cross;
				var _sind    = 0;
				var _color   = COLORS._main_icon;
				
				if(buttonInstant_Pad(bs, tx, ty, ts, ts, [mx,my], pHOVER, pFOCUS, _tooltip, _spr, _sind, _color, 1, ui(6)) == 2)
					panel_deleting = false;
				tx -= ts + ui(2);
				
				var _tooltip = __txt("Confirm Deletion");
				var _spr     = THEME.icon_delete;
				var _sind    = 0;
				var _color   = COLORS._main_value_negative;
				
				if(buttonInstant_Pad(bs, tx, ty, ts, ts, [mx,my], pHOVER, pFOCUS, _tooltip, _spr, _sind, _color, 1, ui(6)) == 2) {
					array_remove(PROJECT.customPanels, data);
					close();
				}
				
			} else {
				var _tooltip = __txt("Delete Panel");
				var _spr     = THEME.icon_delete;
				var _sind    = 0;
				var _color   = [COLORS._main_icon, COLORS._main_value_negative];
				
				if(buttonInstant_Pad(bs, tx, ty, ts, ts, [mx,my], pHOVER, pFOCUS, _tooltip, _spr, _sind, _color, 1, ui(6)) == 2)
					panel_deleting = true;
			}
		#endregion
		
		#region display content
			var _con_x0 = pd + edt_l + pd ;
			var _con_x1 = w - pd - edt_r - pd;
			var _con_xc = (_con_x0 + _con_x1) / 2;
			
			var _con_y0 = pd + topbar_height + pd;
			var _con_y1 = h - pd;
			var _con_yc = (_con_y0 + _con_y1) / 2;
			
			var _con_w  = _con_x1 - _con_x0;
			var _con_h  = _con_y1 - _con_y0;
			
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _con_x0, _con_y0, _con_w, _con_h, COLORS._main_icon_light);
			hover_preview = point_in_rectangle(mx, my, _con_x0, _con_y0, _con_x0 + _con_w, _con_y0 + _con_h);
			
			var pw = data.prew;
			var ph = data.preh;
			
			var ss = min(1, (_con_w - ui(16)) / pw, (_con_h - ui(16)) / ph);
			var dw = round(ss * pw);
			var dh = round(ss * ph);
			
			var dx0 = round(_con_xc - dw / 2);
			var dy0 = round(_con_yc - dh / 2);
			var dx1 = dx0 + dw;
			var dy1 = dy0 + dh;
			
			preview_surface = surface_verify(preview_surface, dw, dh);
			surface_set_target(preview_surface);
				draw_clear_alpha(COLORS.panel_bg_clear, 0);
				data.setSize(x, y, dw, dh);
				
				if(preview_mode) {
					data.setFocusHover(pFOCUS, pHOVER);
					data.root.checkMouse(self, [mx - dx0, my - dy0]);
					data.draw(self, [mx - dx0, my - dy0]);
					
				} else {
					data.setFocusHover(false, pHOVER);
					data.root.checkMouse(self, [mx - dx0, my - dy0]);
					data.draw(self, [mx - dx0, my - dy0]);
					data.root.drawBox(self);
				}
			surface_reset_target();
			
			draw_surface_ext(preview_surface, dx0, dy0, 1, 1, 0, c_white, 1);
			draw_sprite_stretched_add(THEME.ui_panel, 1, dx0, dy0, dw, dh, COLORS._main_icon, .25);
			if(preview_mode) draw_sprite_stretched_ext(THEME.ui_panel, 1, dx0, dy0, dw, dh, COLORS._main_value_positive, 1);
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text);
			draw_text_add(dx0, dy0 - ui(2), data.root.name);
			
			draw_set_text(f_p4, fa_right, fa_bottom, COLORS._main_text_sub);
			draw_text_add(dx1, dy0 - ui(2), $"{dw}x{dh} [{ss * 100}%]");
		#endregion
		
		if(preview_mode) return;
		
		if(hover_preview && element_selecting == undefined && mouse_lpress(pFOCUS)) {
			if(hovering_frame)   element_selecting = hovering_frame;
			if(hovering_element) element_selecting = hovering_element;
		}
		
		if(element_selecting != undefined) {
			var ex = dx0 + element_selecting.x;
			var ey = dy0 + element_selecting.y;
			var ew = element_selecting.w;
			var eh = element_selecting.h;
			
			draw_set_color(COLORS._main_accent);
			
			if(element_selecting.draggable) {
				var _hv = element_selecting.pbBox.drawOverlay(pHOVER, pFOCUS, dx0, dy0, 1, mx, my);
				if(_hv) hovering_element = element_selecting;
			} else 
				draw_sprite_stretched_ext(THEME.box_r2, 1, ex, ey, ew, eh, COLORS._main_accent);
			
			var _hv = pHOVER && point_in_rectangle(mx, my, ex, ey, ex + ew, ey + eh);
			if(mouse_lpress(pFOCUS)) {
				if(!_hv && hover_preview)
					element_selecting = undefined;
			}
			
			if(key_press(vk_delete)) {
				element_selecting.remove();
				element_selecting = undefined;
			}
		} 
		
		if(hover_preview && mouse_lpress(pFOCUS)) {
			if(hovering_frame)   element_selecting = hovering_frame;
			if(hovering_element) element_selecting = hovering_element;
		}
		
		if(element_drag != undefined) {
			var _dx = drag_sx + (mx - drag_mx);
			var _dy = drag_sy + (my - drag_my);
			
			element_drag.x = _dx;
			element_drag.y = _dy;
			
			if(mouse_lrelease())
				element_drag = undefined;
		}
		
		if(element_adding) {
			var siz = element_adding.prevsize;
				
			if(hovering_frame != undefined) {
				var _hvx = dx0 + hovering_frame.x;
				var _hvy = dy0 + hovering_frame.y;
				var _hvw =       hovering_frame.w;
				var _hvh =       hovering_frame.h;
				
				draw_set_color(COLORS._main_accent);
				draw_rectangle_border(_hvx, _hvy, _hvx + _hvw, _hvy + _hvh, 3);
				
				draw_set_color(COLORS._main_icon);
				draw_rectangle_border(mx, my, mx + ui(siz[0]), my + ui(siz[1]), 1);
				
			} else {
				draw_set_color(COLORS._main_icon);
				draw_set_alpha(.5);
				draw_rectangle_border(mx, my, mx + ui(siz[0]), my + ui(siz[1]), 1);
				draw_set_alpha(1);
				
			}
			
			if(mouse_lrelease()) {
				if(hovering_frame != undefined) {
					var _item = new element_adding.fn(data);
					if(hover_preview) {
						_item.pbBox.anchor_l = mx - dx0 - hovering_frame.x;
						_item.pbBox.anchor_t = my - dy0 - hovering_frame.y;
						
					} else {
						_item.pbBox.anchor_l = hovering_frame.x;
						_item.pbBox.anchor_t = hovering_frame.y;
					}
					
					_item.pbBox.anchor_w = ui(siz[0]);
					_item.pbBox.anchor_h = ui(siz[1]);
					
					hovering_frame.addContent(_item);
					element_selecting = _item;
					
					_item.postBuild();
				}
					
				element_adding = undefined;
			}
		}
		
	}
	
}