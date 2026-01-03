function Panel_Custom_Editor(_data = undefined) : PanelContent() constructor {
	title    = "Custom";
	data     = _data;
	auto_pin = true;
	w = min(WIN_W - ui(64), ui(1400));
	h = min(WIN_H - ui(64), ui(800));
	
	data_surface = undefined;
	
	#region ---- elements ----
		elements = [
			[ "Frames", false ], 
			{
				name: "Frame", 
				fn:   Panel_Custom_Frame, 
				spr:  THEME.panel_icon_element_frame,  
				prevsize: [64,64], 
			}, 
			{
				name: "Split Frame", 
				fn:   Panel_Custom_Frame_Split, 
				spr:  THEME.panel_icon_element_frame_split,  
				prevsize: [64,64], 
			}, 
			
			[ "Basics", false ], 
			{
				name: "Text", 
				fn:   Panel_Custom_Text, 
				spr:  THEME.panel_icon_element_text, 
				prevsize: [80,32], 
			}, 
			[ "Nodes", false ], 
			{
				name: "Node Input", 
				fn:   Panel_Custom_Node_Input, 
				spr:  THEME.panel_icon_element_node_input, 
				prevsize: [80,32], 
			}, 
			{
				name: "Node Ouput", 
				fn:   Panel_Custom_Node_Output, 
				spr:  THEME.panel_icon_element_node_output, 
				prevsize: [64,64], 
			}, 
		];
		
		element_adding    = undefined;
		hovering_frame    = undefined;
		_hovering_frame   = undefined;
		hovering_element  = undefined;
		_hovering_element = undefined;
	#endregion
	
	#region ---- selection ----
		element_selecting = undefined;
		
		element_drag = undefined;
		drag_type = 0;
		drag_sx   = 0;
		drag_sy   = 0;
		drag_mx   = 0;
		drag_my   = 0;
		
		outline_drag       = undefined;
		outline_drag_side  = 0;
		outline_drag_frame = undefined;
	#endregion
	
	#region ---- editor ----
		editor_toolbar_width_l = ui(240);
		editor_toolbar_width_r = ui(360);
		
		minw = editor_toolbar_width_l + editor_toolbar_width_r + ui(320);
		minh = ui(320);
		
		globalEditors = [
			[ "Global", false ], 
			new Panel_Custom_Element_Editor("Panel Name", textBox_Text( function(t) /*=>*/ { data.name = t; } ), function() /*=>*/ {return data.name}, function(t) /*=>*/ { data.name = t; }),
			
			new Panel_Custom_Element_Editor("Prefered Size", new vectorBox( 2, function(v,i) /*=>*/ { 
				if(i == 0) data.prew = v; 
				else       data.preh = v; 
			} ), function() /*=>*/ {return [data.prew,data.preh]}, function(v) /*=>*/ { data.prew = v[0]; data.preh = v[1] }),
			
			new Panel_Custom_Element_Editor("Minimum Size", new vectorBox( 2, function(v,i) /*=>*/ { 
				if(i == 0) data.minw = v; 
				else       data.minh = v; 
			} ), function() /*=>*/ {return [data.minw,data.minh]}, function(v) /*=>*/ { data.minw = v[0]; data.minh = v[1] }), 
			
			new Panel_Custom_Element_Editor("Auto Pin", new checkBox( function() /*=>*/ { 
				data.auto_pin = !data.auto_pin;
			} ), function() /*=>*/ {return data.auto_pin}, function(v) /*=>*/ { data.auto_pin = v; }), 
			
			new Panel_Custom_Element_Editor("Open on Load", new checkBox( function() /*=>*/ { 
				data.open_start = !data.open_start;
			} ), function() /*=>*/ {return data.open_start}, function(v) /*=>*/ { data.open_start = v; }), 
		];
	#endregion

	sc_add_elements = new scrollPane(1,1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _h = 0;
		var ww = sc_add_elements.surface_w;
		
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
			var spr = ele.spr;
			
			var xx = (grs + ui(4)) * col;
			var hv = hov && point_in_rectangle(_m[0], _m[1], xx, yy, xx + grs, yy + grs);
			
			var sx = xx + grs / 2;
			var sy = yy + grs / 2 - ui(8);
			draw_sprite_ui(spr, 0, sx, sy);
			
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
		
		if(_cAll ==  1) for( var i = 0, n = array_length(elements); i < n; i++ ) if(is_array(elements[i])) elements[i][1] = false; 
		if(_cAll == -1) for( var i = 0, n = array_length(elements); i < n; i++ ) if(is_array(elements[i])) elements[i][1] =  true; 
		
		return _h;
	});
	
	sc_outline = new scrollPane(1,1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var ww = sc_outline.surface_w;
		
		outline_drag_frame = undefined;
		var _h = data.root.drawOutline(0, self, ui(4), _y, ww - ui(4), _m);
		
		if(outline_drag && mouse_lrelease()) {
			if(hovering_element && outline_drag != hovering_element) {
				var _ind = array_find(hovering_element.parent.contents, hovering_element) + outline_drag_side;
			    if(outline_drag.parent == hovering_element.parent) {
			    	var _cind = array_find(hovering_element.parent.contents, outline_drag);
			    	if(_cind < _ind) _ind--;
			    }
			    
				array_remove(outline_drag.parent.contents, outline_drag);
				array_insert(hovering_element.parent.contents, _ind, outline_drag);
			}
			
			outline_drag = undefined;
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
		var wdw = ww * .6;
		
		var _cAll = 0;
		
		for( var i = 0, n = array_length(_editors); i < n; i++ ) {
			var _edt = _editors[i];
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
				
				_y += ui(2);
				_h += ui(2);
				
				var cc = COLORS.panel_inspector_group_bg;
	            if(hov && point_in_rectangle(_m[0], _m[1], 0, _y, ww, _y + lbh)) {
	            	cc = COLORS.panel_inspector_group_hover;
	                
	                if(foc) {
	                    	 if(DOUBLE_CLICK) _cAll = _edt[1]? -1 : 1;
	                    else if(mouse_press(mb_left)) _edt[1] = !_edt[1];
	                }
	            }
	                
	            draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, _y, ww, lbh, cc, 1);
	            draw_sprite_ui(THEME.arrow, _edt[1]? 0 : 3, ui(16), _y + lbh / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);    
	            draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
	            
	            draw_text_add(ui(32), _y + lbh / 2, _txt);
				
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
			var _widg = _edt.editWidget;
			var _gett = _edt.getter;
			var _sett = _edt.setter;
			var _wpd  = ui(4);
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(8), _y + wdh / 2, _name);
			
			if(_name == "Position") {
				if(element_selecting && !element_selecting.draggable) {
					var _tx = ui(8) + string_width(_name) + ui(4);
					draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
					draw_text_add(_tx, _y + wdh / 2, "[locked]");
					
					_widg.setInteract(false);
				} else 
					_widg.setInteract(true);
				
				_y += ui(24);
				_h += ui(24);
				_wpd = ui(0);
				
				var _param = new widgetParam(ui(8), _y, ww - ui(16), wdh, _gett(), {}, _m, rx, ry)
					.setFont(f_p3);
					
			} else {
				var wdx = ww - wdw;
				var wdy = _y;
				var _param = new widgetParam(wdx, wdy, wdw, wdh, _gett(), {}, _m, rx, ry)
					.setFont(f_p3);
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
		
		var pd = ui(8);
		var edt_l = editor_toolbar_width_l;
		var edt_r = editor_toolbar_width_r;
		var edt_h = h - pd - pd;
		
		var bx = pd;
		var by = pd;
		var bw = edt_l;
		var bh = edt_h / 2;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, bx, by, bw, bh);
		sc_add_elements.setFocusHover(pFOCUS, pHOVER);
		sc_add_elements.verify(bw - ui(8), bh - ui(8));
		sc_add_elements.drawOffset(bx + ui(4), by + ui(4), mx, my);
		
		var bx = pd;
		var by = pd + edt_h / 2 + pd;
		var bw = edt_l;
		var bh = edt_h / 2 - pd;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, bx, by, bw, bh);
		sc_outline.setFocusHover(pFOCUS, pHOVER);
		sc_outline.verify(bw - ui(8), bh - ui(8));
		sc_outline.drawOffset(bx + ui(4), by + ui(4), mx, my);
		
		var bx = w - edt_r - pd;
		var by = pd;
		var bw = edt_r;
		var bh = edt_h;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, bx, by, bw, bh);
		sc_properties.setFocusHover(pFOCUS, pHOVER);
		sc_properties.verify(bw - ui(8), bh - ui(8));
		sc_properties.drawOffset(bx + ui(4), by + ui(4), mx, my);
		
		#region display content
			var _con_x0 = pd + edt_l + pd ;
			var _con_x1 = w - pd - edt_r - pd;
			var _con_xc = (_con_x0 + _con_x1) / 2;
			var _con_y0 = pd;
			var _con_y1 = h - pd;
			var _con_yc = (_con_y0 + _con_y1) / 2;
			
			var _con_w  = _con_x1 - _con_x0;
			var _con_h  = _con_y1 - _con_y0;
			
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _con_x0, _con_y0, _con_w, _con_h, COLORS._main_icon_light);
			hover_preview = point_in_rectangle(mx, my, _con_x0, _con_y0, _con_x0 + _con_w, _con_y0 + _con_h);
			
			var pw = data.prew;
			var ph = data.preh;
			
			var ss = min(1, (_con_w - ui(16)) / pw, (_con_h - ui(16)) / ph);
			var dw = ss * pw;
			var dh = ss * ph;
			
			var dx0 = _con_xc - dw / 2;
			var dy0 = _con_yc - dh / 2;
			var dx1 = _con_xc + dw / 2;
			var dy1 = _con_yc + dh / 2;
			
			data_surface = surface_verify(data_surface, dw, dh);
			surface_set_target(data_surface);
				draw_clear_alpha(COLORS.panel_bg_clear, 0);
				data.setSize(dw, dh);
				data.setFocusHover(pFOCUS, pHOVER);
				data.draw(self, [mx - dx0, my - dy0]);
				data.root.drawBox(self);
			surface_reset_target();
			
			draw_surface_ext(data_surface, dx0, dy0, 1, 1, 0, c_white, 1);
			draw_sprite_stretched_add(THEME.ui_panel, 1, dx0, dy0, dw, dh, COLORS._main_icon, .25);
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text);
			draw_text_add(dx0, dy0 - ui(2), __txt("Home"));
			
			draw_set_text(f_p4, fa_right, fa_bottom, COLORS._main_text_sub);
			draw_text_add(dx1, dy0 - ui(2), $"{dw}x{dh} [{ss * 100}%]");
		#endregion
		
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
					var _item = new element_adding.fn();
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