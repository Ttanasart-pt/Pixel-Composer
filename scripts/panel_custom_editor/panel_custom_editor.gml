function Panel_Custom_Editor(_data = undefined) : PanelContent() constructor {
	title    = "Custom";
	data     = _data;
	auto_pin = true;
	w = min(WIN_W - ui(64), ui(1400));
	h = min(WIN_H - ui(64), ui(800));
	padding = ui(8);
	
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
		element_adding     = undefined;
		element_selecting  = undefined;
		element_selectings = [];
		element_selectingm = {};
		
		element_drag = undefined;
		drag_type = 0;
		drag_sx   = 0;
		drag_sy   = 0;
		drag_mx   = 0;
		drag_my   = 0;
		
		_hovering_frame   = undefined; hovering_frame   = undefined; 
	    _hovering_scroll  = undefined; hovering_scroll  = undefined;
		_hovering_element = undefined; hovering_element = undefined; 
		
		_HOVER_WIDGET = undefined; HOVER_WIDGET = undefined;
		
		selection_modifying = false;
		selection_boxing = 0;
		selection_box_x  = 0;
		selection_box_y  = 0;
		
		select_box_x0 = 0; select_box_y0 = 0;
		select_box_x1 = 0; select_box_y1 = 0;
		
		select_multi_dragging  = 0;
		select_multi_drag_mx   = 0;
		select_multi_drag_my   = 0;
		select_multi_drag_init = [0,0,0,0];
		select_multi_drag_data = undefined;
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
	    
	    outline_hold_lock = undefined;
	    outline_hold_snap = undefined;
	#endregion
	
	#region ---- editor ----
		editor_toolbar_width_l  = ui(232);
		editor_toolbar_l_resize = false;
		editor_toolbar_l_sx     = 0;
		editor_toolbar_l_mx     = 0;
		
		editor_toolbar_width_r = ui(360);
		editor_toolbar_r_resize = false;
		editor_toolbar_r_sx     = 0;
		editor_toolbar_r_mx     = 0;
		
		minw = editor_toolbar_width_l + editor_toolbar_width_r + ui(320);
		minh = ui(320);
		
		snapPoints = [];
	#endregion
	
	#region ---- preview ----
		preview_surface = undefined;
		preview_mode    = false;
		preview_x0      = 0;
		preview_y0      = 0;
		preview_x1      = 0;
		preview_y1      = 0;
		
		topbar_height = ui(24);
		
		topbar_button_center = [
			[ /*0*/ __txt("Preview Mode"), 
			  /*1*/ function() /*=>*/ {return THEME.sequence_control},
			  /*2*/ function() /*=>*/ {return preview_mode? 0 : 1}, 
			  /*3*/ function() /*=>*/ {return preview_mode? COLORS._main_value_positive : COLORS._main_icon},
			  /*4*/ function() /*=>*/ { preview_mode = !preview_mode; }, ]
		];
		
		topbar_button_left_no_selection  = [];
		topbar_button_left_select_single = [];
		topbar_button_left_select_multi  = [
			[ __txt("Align Left"),   THEME.object_halign, 0, COLORS._main_icon_light, function() /*=>*/ {return sel_align_left()},   ], 
			[ __txt("Align Middle"), THEME.object_halign, 1, COLORS._main_icon_light, function() /*=>*/ {return sel_align_middle()}, ], 
			[ __txt("Align Right"),  THEME.object_halign, 2, COLORS._main_icon_light, function() /*=>*/ {return sel_align_right()},  ], 
			-1, 
			[ __txt("Align Top"),    THEME.object_valign, 0, COLORS._main_icon_light, function() /*=>*/ {return sel_align_top()},    ], 
			[ __txt("Align Center"), THEME.object_valign, 1, COLORS._main_icon_light, function() /*=>*/ {return sel_align_center()}, ], 
			[ __txt("Align Bottom"), THEME.object_valign, 2, COLORS._main_icon_light, function() /*=>*/ {return sel_align_bottom()}, ], 
			-1, 
			[ __txt("Distribute X"), THEME.obj_distribute_h, 0, COLORS._main_icon_light, function() /*=>*/ {return sel_dist_h()}, ], 
			[ __txt("Distribute Y"), THEME.obj_distribute_v, 0, COLORS._main_icon_light, function() /*=>*/ {return sel_dist_v()}, ], 
		];
		
		panel_deleting = false;
	#endregion
	
	#region actions
		function sel_align_left() {
			if(array_empty(element_selectings)) return;
			
			var _x = select_box_x0 - preview_x0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				var box = ele.pbBox.getBBOX();
				ele.pbBox.setBBOX([ _x, box[1], _x + box[2] - box[0], box[3] ]);
			}
		} 
		
		function sel_align_middle() {
			if(array_empty(element_selectings)) return;
			
			var _x = (select_box_x0 + select_box_x1) / 2 - preview_x0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				var box = ele.pbBox.getBBOX();
				var bw  = box[2] - box[0];
				ele.pbBox.setBBOX([ _x - bw/2, box[1], _x + bw/2, box[3] ]);
			}
		} 
		
		function sel_align_right() {
			if(array_empty(element_selectings)) return;
			
			var _x = select_box_x1 - preview_x0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				var box = ele.pbBox.getBBOX();
				ele.pbBox.setBBOX([ _x - (box[2] - box[0]), box[1], _x, box[3] ]);
			}
		} 
		
		function sel_align_top() {
			if(array_empty(element_selectings)) return;
			
			var _y = select_box_y0 - preview_y0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				var box = ele.pbBox.getBBOX();
				var bh  = box[3] - box[1];
				ele.pbBox.setBBOX([ box[0], _y, box[2], _y + bh ]);
			}
		} 
		
		function sel_align_center() {
			if(array_empty(element_selectings)) return;
			
			var _y = (select_box_y0 + select_box_y1) / 2 - preview_y0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				var box = ele.pbBox.getBBOX();
				var bh  = box[3] - box[1];
				ele.pbBox.setBBOX([ box[0], _y - bh / 2, box[2], _y + bh + 2 ]);
			}
		} 
		
		function sel_align_bottom() {
			if(array_empty(element_selectings)) return;
			
			var _y = select_box_y1 - preview_y0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				var box = ele.pbBox.getBBOX();
				var bh  = box[3] - box[1];
				ele.pbBox.setBBOX([ box[0], _y - bh, box[2], _y ]);
			}
		} 
		
		function sel_dist_h() {
			if(array_empty(element_selectings)) return;
			array_sort(element_selectings, function(a,b) /*=>*/ {return a.x-b.x});
			
			var ww = select_box_x1 - select_box_x0;
			var ow = 0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ )
				ow += element_selectings[i].w;
			
			var sp = (ww - ow) / (array_length(element_selectings) - 1);
			var xx = select_box_x0 - preview_x0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				var box = ele.pbBox.getBBOX()
				ele.pbBox.setBBOX([ xx, box[1], xx + box[2] - box[0], box[3] ]);
				xx += ele.w + sp;
			}
				
		}
		
		function sel_dist_v() {
			if(array_empty(element_selectings)) return;
			array_sort(element_selectings, function(a,b) /*=>*/ {return a.y-b.y});
			
			var hh = select_box_y1 - select_box_y0;
			var oh = 0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ )
				oh += element_selectings[i].h;
			
			var sp = (hh - oh) / (array_length(element_selectings) - 1);
			var yy = select_box_y0 - preview_y0;
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				var box = ele.pbBox.getBBOX()
				ele.pbBox.setBBOX([ box[0], yy, box[2], yy + box[3] - box[1] ]);
				yy += ele.h + sp;
			}
				
		}
	#endregion
	
	sc_add_elements = new scrollPane(1,1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _h = 0;
		var ww = sc_add_elements.surface_w;
		
		var elements = PANEL_ELEMENT;
		var hov = sc_add_elements.hover;
		var foc = sc_add_elements.active;
		
		var yy = _y;
		var grw = ui(64);
		var grh = ui(64);
		var lbh = ui(20);
		var col = 0;
		var maxCol = floor(ww / (grw + ui(4)));
		grw = ww / maxCol - ui(4);
		
		var _cAll = 0;
		
		for( var i = 0, n = array_length(elements); i < n; i++ ) {
			var ele = elements[i];
			if(is_array(ele)) {
				if(col) {
					yy += grh + ui(4);
					_h += grh + ui(4);
				}
				
				var _txt = ele[0];
				
				var cc = COLORS.section_bg;
	            if(hov && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + lbh)) {
	            	cc = COLORS.section_hover;
	                
	                if(foc) {
	                    	 if(DOUBLE_CLICK) _cAll = ele[1]? -1 : 1;
	                    else if(mouse_lpress()) ele[1] = !ele[1];
	                }
	            }
	                
	            draw_sprite_stretched_ext(THEME.box_r2_clr, 0, 0, yy, ww, lbh, cc, 1);
	            draw_sprite_ui(THEME.arrow, ele[1]? 0 : 3, ui(12), yy + lbh / 2, .75, .75, 0, COLORS.section_bg, 1);    
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
			
			var xx = (grw + ui(4)) * col;
			var hv = hov && point_in_rectangle(_m[0], _m[1], xx, yy, xx + grw, yy + grh);
			
			var sx = xx + grw / 2;
			var sy = yy + grh / 2 - ui(8);
			draw_sprite_ui_uniform(spr, 0, sx, sy, .5);
			
			draw_set_text(f_p4, fa_center, fa_bottom, COLORS._main_text);
			draw_text_add(xx + grw / 2, yy + grh - ui(2), nam);
			
			if(hv) {
				draw_sprite_stretched_add(THEME.box_r2, 1, xx, yy, grw, grh, c_white, .25);
				
				if(mouse_lpress(foc)) {
					element_adding = ele;
				}
			}
			
			col++;
			if(col >= maxCol) {
				col = 0;
				yy += grh + ui(4);
				_h += grh + ui(4);
			}
		}
		
		if(col) _h += grh + ui(4);
		
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
				var _marr = array_empty(element_selectings)? [outline_drag] : element_selectings;
				
				if(outline_drag_frame) {
					for( var i = 0, n = array_length(_marr); i < n; i++ ) {
						var ele = _marr[i];
						array_remove(ele.parent.contents, ele);
						array_push(outline_drag_frame.contents, ele);
						ele.parent = outline_drag_frame;
					}
					
				} else if(hovering_element.parent) {
					for( var i = 0, n = array_length(_marr); i < n; i++ ) {
						var ele = _marr[i];
						var _ind = array_find(hovering_element.parent.contents, hovering_element) + outline_drag_side;
					    if(ele.parent == hovering_element.parent) {
					    	var _cind = array_find(hovering_element.parent.contents, ele);
					    	if(_cind < _ind) _ind--;
					    }
					    
						array_remove(ele.parent.contents, ele);
						array_insert(hovering_element.parent.contents, _ind, outline_drag);
						
						ele.parent = hovering_element.parent;
					}
				}
			}
			
			outline_drag = undefined;
		}
		
		if(hov && outline_hover == undefined) {
			if(mouse_lpress(foc)) 
				element_selecting = undefined;
		}
		
		if(mouse_lrelease()) {
			outline_hold_lock = undefined;
	    	outline_hold_snap = undefined;
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
				var toDel = undefined;
				for( var j = 0, m = array_length(data.io_redirect); j < m; j++ ) {
					var io = data.io_redirect[j];
					var hh = io.drawProp(ui(8), _y, ww - ui(16), _m, hov, foc, rx, ry);
					if(io.deleteMe) toDel = j;
					
					_y += hh + ui(4);
					_h += hh + ui(4);
				}
				
				if(toDel) array_delete(data.io_redirect, toDel, 1);
				
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
				
				var cc = COLORS.section_bg;
				var lw = ww - (_but != 0) * ui(28);
				
	            if(hov && point_in_rectangle(_m[0], _m[1], 0, _y, lw, _y + lbh)) {
	            	cc = COLORS.section_hover;
	                if(foc) {
	                    	 if(DOUBLE_CLICK) _cAll = _edt[1]? -1 : 1;
	                    else if(mouse_lpress()) _edt[1] = !_edt[1];
	                }
	            }
	                
	            draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, _y, lw, lbh, cc, 1);
	            draw_sprite_ui(THEME.arrow, _edt[1]? 0 : 3, ui(16), _y + lbh / 2, 1, 1, 0, COLORS.section_bg, 1);    
	            draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
	            draw_text_add(ui(32), _y + lbh / 2, _txt);
	            
	            if(_but) {
	            	var _bw = ui(24);
	            	var _bh = lbh;
	            	var _bx = ww - _bw;
	            	var _by = _y;
	            	
	            	draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _bx, _by, _bw, _bh, COLORS.section_bg, 1);
	            	
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
			var  tx   = ui(8);
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
			draw_text_add(tx, _y + wdh / 2, _name);
			
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
				if(!element_selecting.draggable) {
					var _tx = tx + string_width(_name) + ui(4);
					draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
					draw_text_add(_tx, _y + wdh / 2, "[fixed]");
					
					_widg.setInteract(false);
					
				} else {
					var bs = ui(24);
					var bx = tx + string_width(_name);
					var by = _y + wdh / 2 - bs / 2;
					var bp = THEME.lock_12;
					var bi = element_selecting.selectable;
					var bc = element_selecting.selectable? COLORS._main_icon : COLORS._main_icon_light;
					var ba = element_selecting.selectable? .75 : 1;
					if(buttonInstant(noone, bx, by, bs, bs, _m, hov, foc, "", bp, bi, bc, ba) == 2)
						element_selecting.selectable = !element_selecting.selectable;
					
					var bb = THEME.button_hide;
					var bc = COLORS._main_icon_light;
					var bx = ww - ui(2);
					var by = _y + ui(2);
					
					var bt = __txt("Fill and Pad");
					var bp = THEME.inspector_fill_type;
					bx -= bs;
					if(buttonInstant(bb, bx, by, bs, bs, _m, hov, foc, bt, bp, 2, bc, 1, .75) == 2) {
						_widg.linked = true;
						_data.anchor_x_type = PB_AXIS_ANCHOR.bounded;
						_data.anchor_y_type = PB_AXIS_ANCHOR.bounded;
						_data.anchor_l = 0; 
						_data.anchor_r = 0; 
						_data.anchor_t = 0;
						_data.anchor_b = 0;
					} bx -= ui(2);
					
					var bt = __txt("Fill Y");
					var bp = THEME.inspector_fill_type;
					bx -= bs;
					if(buttonInstant(bb, bx, by, bs, bs, _m, hov, foc, bt, bp, 1, bc, 1, .75) == 2) {
						_data.anchor_y_type = PB_AXIS_ANCHOR.bounded;
						_data.anchor_t = 0; 
						_data.anchor_b = 0;
					} bx -= ui(2);
					
					var bt = __txt("Fill X");
					var bp = THEME.inspector_fill_type;
					bx -= bs;
					if(buttonInstant(bb, bx, by, bs, bs, _m, hov, foc, bt, bp, 0, bc, 1, .75) == 2) {
						_data.anchor_x_type = PB_AXIS_ANCHOR.bounded;
						_data.anchor_l = 0; 
						_data.anchor_r = 0; 
					} bx -= ui(2);
					
					bx -= ui(2); 
					draw_set_color(CDEF.main_dkgrey); 
					draw_line_width(bx,by+ui(2),bx,by+bs-ui(2),ui(1)); 
					bx -= ui(3);
					
					var bt = __txt("Center");
					var bp = THEME.object_align_center;
					bx -= bs;
					if(buttonInstant(bb, bx, by, bs, bs, _m, hov, foc, bt, bp, 0, bc, 1, .75) == 2) {
						_data.anchor_x_type = PB_AXIS_ANCHOR.center;
						_data.anchor_y_type = PB_AXIS_ANCHOR.center;
						_data.anchor_l = 0;
						_data.anchor_r = 0;
						_data.anchor_t = 0;
						_data.anchor_b = 0;
					} bx -= ui(2);
					
					var bt = __txt("Center Horizontal");
					var bp = THEME.inspector_surface_halign;
					bx -= bs;
					if(buttonInstant(bb, bx, by, bs, bs, _m, hov, foc, bt, bp, 1, bc, 1, .75) == 2) {
						_data.anchor_x_type = PB_AXIS_ANCHOR.center;
						_data.anchor_l = 0;
						_data.anchor_r = 0;
					} bx -= ui(2);
					
					var bt = __txt("Center Vertical");
					var bp = THEME.inspector_surface_valign;
					bx -= bs;
					if(buttonInstant(bb, bx, by, bs, bs, _m, hov, foc, bt, bp, 1, bc, 1, .75) == 2) {
						_data.anchor_y_type = PB_AXIS_ANCHOR.center;
						_data.anchor_t = 0;
						_data.anchor_b = 0;
					} bx -= ui(2);
					
					bx -= ui(2); 
					draw_set_color(CDEF.main_dkgrey); 
					draw_line_width(bx,by+ui(2),bx,by+bs-ui(2),ui(1)); 
					bx -= ui(3);
					
					var bt = __txt("Position + Size mode");
					var bp = THEME.inspector_area_type;
					bx -= bs;
					if(buttonInstant(bb, bx, by, bs, bs, _m, hov, foc, bt, bp, 0, bc, 1, .75) == 2) {
						var bbox = _data.getBBOX();
						_data.anchor_x_type = PB_AXIS_ANCHOR.minimum;
						_data.anchor_y_type = PB_AXIS_ANCHOR.minimum;
						_data.setBBOX(bbox);
					} bx -= ui(2);
					
					_widg.setInteract(true);
				}
				
				_y += ui(24);
				_h += ui(24);
				_wpd = ui(0);
				
				var _param = new widgetParam(ui(8), _y, ww - ui(16), wdh, _data, undefined, _m, rx, ry).setFont(f_p3);
					
			} else {
				var wdx = ww - wdw;
				var wdy = _y;
				var _param = new widgetParam(wdx, wdy, wdw, wdh, _data, undefined, _m, rx, ry).setFont(f_p3);
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
	
	function drawLeftPanel() {
		var pd = padding;
		var edt_l = editor_toolbar_width_l;
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
		
		// Left
		var lx = pd + editor_toolbar_width_l;
		var cc = COLORS._main_icon, aa = .5;
    	if(editor_toolbar_l_resize) {
            CURSOR = cr_size_we;
            cc = COLORS._main_icon_light;
			aa = 1;
			
            editor_toolbar_width_l = editor_toolbar_l_sx + (mx - editor_toolbar_l_mx);
            editor_toolbar_width_l = clamp(editor_toolbar_width_l, ui(160), w * .4);
            if(mouse_lrelease()) editor_toolbar_l_resize = false;
        }
        
        if(pHOVER && point_in_rectangle(mx, my, lx, h/2 - ui(24), lx + pd, h/2 + ui(24))) {
            CURSOR = cr_size_we;
            aa = 1;
            
            if(mouse_lpress(pFOCUS)) {
                editor_toolbar_l_resize = true;
				editor_toolbar_l_sx     = editor_toolbar_width_l;
				editor_toolbar_l_mx     = mx;
				
            }
        } 
        
        draw_set_color_alpha(cc, aa);
        draw_line_round(lx + pd / 2, h/2 - ui(12), lx + pd / 2, h/2 + ui(12), ui(3));
        draw_set_alpha(1);
        
		// Outline
		var cc = COLORS._main_icon, aa = .5;
    	if(outline_height_drag) {
            CURSOR = cr_size_ns;
            cc = COLORS._main_icon_light;
			aa = 1;
			
            outline_height = outline_height_start - (my - outline_height_my);
            outline_height = clamp(outline_height, ui(224), h - ui(128));
            if(mouse_lrelease()) outline_height_drag = false;
        }
        
        if(pHOVER && point_in_rectangle(mx, my, out_x, out_y - pd, out_x + out_w, out_y)) {
            CURSOR = cr_size_ns;
            aa = 1;
            
            if(mouse_lpress(pFOCUS)) {
                outline_height_drag  = true;
                outline_height_start = outline_height;
                outline_height_my    = my;
            }
        } 
        
        draw_set_color_alpha(cc, aa);
        draw_line_round(out_x + out_w / 2 - ui(12), out_y - pd / 2, out_x + out_w / 2 + ui(12), out_y - pd / 2, ui(3));
        draw_set_alpha(1);
	}
	
	function drawRightPanel() {
		var pd = padding;
		var edt_r = editor_toolbar_width_r;
		var edt_h = h - pd - pd;
		
		var prp_x = w - edt_r - pd;
		var prp_y = pd;
		var prp_w = edt_r;
		var prp_h = edt_h;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, prp_x, prp_y, prp_w, prp_h);
		sc_properties.setFocusHover(pFOCUS, pHOVER);
		sc_properties.verify(prp_w - ui(8), prp_h - ui(8));
		sc_properties.drawOffset(prp_x + ui(4), prp_y + ui(4), mx, my);
		
		// Right
		var lx = w - pd - editor_toolbar_width_r;
		var cc = COLORS._main_icon, aa = .5;
    	if(editor_toolbar_r_resize) {
            CURSOR = cr_size_we;
            cc = COLORS._main_icon_light;
			aa = 1;
			
            editor_toolbar_width_r = editor_toolbar_r_sx - (mx - editor_toolbar_r_mx);
            editor_toolbar_width_r = clamp(editor_toolbar_width_r, ui(240), w * .4);
            if(mouse_lrelease()) editor_toolbar_r_resize = false;
        }
        
        if(pHOVER && point_in_rectangle(mx, my, lx - pd, h/2 - ui(24), lx, h/2 + ui(24))) {
            CURSOR = cr_size_we;
            aa = 1;
            
            if(mouse_lpress(pFOCUS)) {
                editor_toolbar_r_resize = true;
				editor_toolbar_r_sx     = editor_toolbar_width_r;
				editor_toolbar_r_mx     = mx;
				
            }
        } 
        
        draw_set_color_alpha(cc, aa);
        draw_line_round(lx - pd / 2, h/2 - ui(12), lx - pd / 2, h/2 + ui(12), ui(3));
        draw_set_alpha(1);
	}
	
	function drawTopbar() {
		var pd = padding;
		var edt_l = editor_toolbar_width_l;
		var edt_r = editor_toolbar_width_r;
		
		var _top_x0 = pd + edt_l + pd ;
		var _top_x1 = w - pd - edt_r - pd;
		var _top_xc = (_top_x0 + _top_x1) / 2;
		
		var _top_y0 = pd;
		var _top_y1 = pd + topbar_height;
		var _top_yc = (_top_y0 + _top_y1) / 2;
		
		var bs = THEME.button_hide_fill;
		var ts = topbar_height;
		
		// Left buttons
		var tx = _top_x0;
		var ty = _top_y0;
		var lb = topbar_button_left_no_selection;
		if(!array_empty(element_selectings))
			lb = topbar_button_left_select_multi;
		else if(element_selecting != undefined)
			lb = topbar_button_left_select_single;
		
		for( var i = 0, n = array_length(lb); i < n; i++ ) {
			var tb = lb[i];
			if(tb == -1) {
				tx += ui(1);
				draw_set_color(COLORS._main_icon_dark);
				draw_line_round(tx, ty, tx, ty + ts, ui(2));
				tx += ui(3);
				continue;
			}
			
			var _tooltip = tb[0];
			var _spr     = tb[1] if(is_method(_spr))   _spr   = _spr();
			var _sind    = tb[2] if(is_method(_sind))  _sind  = _sind();
			var _color   = tb[3] if(is_method(_color)) _color = _color();
			var _onClick = tb[4];
			
			if(buttonInstant_Pad(bs, tx, ty, ts, ts, [mx,my], pHOVER, pFOCUS, _tooltip, _spr, _sind, _color, 1, ui(6)) == 2)
				_onClick();
				
			tx += ts + ui(2);
		}
		
		// Center buttons
		var tx = _top_xc - (array_length(topbar_button_center) * (ts + ui(2) - ui(2))) / ui(2);
		var ty = _top_y0;
		
		for( var i = 0, n = array_length(topbar_button_center); i < n; i++ ) {
			var tb = topbar_button_center[i];
			var _tooltip = tb[0];
			var _spr     = tb[1]();
			var _sind    = tb[2]();
			var _color   = tb[3]();
			var _onClick = tb[4];
			
			if(buttonInstant_Pad(bs, tx, ty, ts, ts, [mx,my], pHOVER, pFOCUS, _tooltip, _spr, _sind, _color, 1, ui(6)) == 2)
				_onClick();
				
			tx += ts + ui(2);
		}
		
		// Right buttons
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
	}
	
	function drawPanel() {
		var pd = padding;
		var edt_l = editor_toolbar_width_l;
		var edt_r = editor_toolbar_width_r;
		
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
		
		preview_x0      = dx0;
		preview_y0      = dy0;
		preview_x1      = dx1;
		preview_y1      = dy1;
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
				data.root.getSnapPoint(self);
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
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		if(!data) return;
		title = $"{data.name} [Edit]";
		
		_hovering_frame   = hovering_frame;
		_hovering_scroll  = hovering_scroll;
		_hovering_element = hovering_element;
		
		hovering_frame    = undefined;
		hovering_scroll   = undefined;
		hovering_element  = undefined;
		hover_preview     = false;
		snapPoints        = [];
		
		drawLeftPanel();
		drawRightPanel();
		drawTopbar();
		drawPanel();
		
		if(preview_mode) return;
		
		var dx0 = preview_x0;
		var dy0 = preview_y0;
		var dx1 = preview_x1;
		var dy1 = preview_y1;
		
		if(array_empty(element_selectings) && hover_preview && !selection_modifying && mouse_lpress(pFOCUS)) { // Select element
			if(hovering_frame)   element_selecting = hovering_frame;
			if(hovering_element) element_selecting = hovering_element;
		} // Select element
		selection_modifying = false;
		
		if(!array_empty(element_selectings)) { // Selecting multiple
			select_box_x0 =  infinity; select_box_y0 =  infinity;
			select_box_x1 = -infinity; select_box_y1 = -infinity;
		
			for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
				var ele = element_selectings[i];
				
				var ex = dx0 + ele.x;
				var ey = dy0 + ele.y;
				var ew = ele.w;
				var eh = ele.h;
				
				draw_sprite_stretched_ext(THEME.box_r2, 1, ex, ey, ew, eh, COLORS._main_accent, .5);
				
				select_box_x0 = min(select_box_x0, ex);
				select_box_y0 = min(select_box_y0, ey);
				select_box_x1 = max(select_box_x1, ex + ew);
				select_box_y1 = max(select_box_y1, ey + eh);
			}
			
			draw_sprite_stretched_ext(THEME.box_r2, 1, select_box_x0, select_box_y0, 
				select_box_x1 - select_box_x0, select_box_y1 - select_box_y0, COLORS._main_accent);
			 
		} else if(element_selecting != undefined) { // Selecting object
			var ex = dx0 + element_selecting.x;
			var ey = dy0 + element_selecting.y;
			var ew = element_selecting.w;
			var eh = element_selecting.h;
			var hv = pHOVER && point_in_rectangle(mx, my, ex, ey, ex + ew, ey + eh);
			
			draw_set_color(COLORS._main_accent);
			
			if(element_selecting.draggable && element_selecting.selectable) {
				var _boxHv = element_selecting.pbBox.drawOverlay(pHOVER, pFOCUS, dx0, dy0, 1, mx, my, undefined, snapPoints);
				if(_boxHv) {
					selection_modifying = true;
					hovering_element    = element_selecting;
					hv = true;
				}
				
			} else draw_sprite_stretched_ext(THEME.box_r2, 1, ex, ey, ew, eh, COLORS._main_accent);
			
			if(mouse_lpress(pFOCUS)) {
				if(!hv && hover_preview) element_selecting = undefined;
			}
			
			if(key_press(vk_delete)) {
				element_selecting.remove();
				element_selecting = undefined;
			}
		}  // Selecting object
		
		if(hover_preview && mouse_lpress(pFOCUS)) { // Select element
			if(hovering_frame)   element_selecting = hovering_frame;
			if(hovering_element) element_selecting = hovering_element;
		} // Select element
		
		if(element_drag != undefined) { // Moving element
			var _dx = drag_sx + (mx - drag_mx);
			var _dy = drag_sy + (my - drag_my);
			
			element_drag.x = _dx;
			element_drag.y = _dy;
			
			if(mouse_lrelease())
				element_drag = undefined;
		} // Moving element
		
		if(element_adding) { // Adding Element
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
		} // Adding Element
		
		////- =Multiple dragging
		if(!array_empty(element_selectings)) { // Selecting multiple
			var hovBox = pHOVER && point_in_rectangle(mx, my, select_box_x0, select_box_y0, select_box_x1, select_box_y1);
			
			if(hovBox && mouse_lpress(pFOCUS)) {
				select_multi_dragging  = 1;
				select_multi_drag_mx   = mx;
				select_multi_drag_my   = my;
				select_multi_drag_init = [select_box_x0, select_box_y0, select_box_x1, select_box_y1];
				select_multi_drag_data = [];
				for( var i = 0, n = array_length(element_selectings); i < n; i++ )
					select_multi_drag_data[i] = element_selectings[i].pbBox.getBBOX();
			}
			
			if(select_multi_dragging == 1) {
				if(point_distance(mx, my, select_multi_drag_mx, select_multi_drag_my) > ui(4))
					select_multi_dragging = 2;
			}
			
			if(select_multi_dragging == 2) {
				var dx = round(mx - select_multi_drag_mx);
				var dy = round(my - select_multi_drag_my);
				
				var ix0 = select_multi_drag_init[0] - dx0;
				var iy0 = select_multi_drag_init[1] - dy0;
				var ix1 = select_multi_drag_init[2] - dx0;
				var iy1 = select_multi_drag_init[3] - dy0;
				
				var bx0 = ix0 + dx;
				var by0 = iy0 + dy;
				var bx1 = ix1 + dx;
				var by1 = iy1 + dy;
				var bxc = (bx0 + bx1) / 2;
				var byc = (by0 + by1) / 2;
				
				var sx0, sy0, sx1, sy1, sxc, syc;
				
				if(dx != 0 || dy != 0) {
					var sd = ui(6);
					
					draw_set_alpha(.75);
					for( var i = 0, n = array_length(snapPoints); i < n; i++ ) {
						var sn    = snapPoints[i];
						if(has(element_selectingm, sn[2].ID)) continue;
						
						sx0 = sn[1][0]; sy0 = sn[1][1];
						sx1 = sn[1][2]; sy1 = sn[1][3];
						sxc = (sx0 + sx1) / 2;
						syc = (sy0 + sy1) / 2;
						
						draw_set_color(COLORS._main_icon);
						if(abs(bx0 - sx0) < sd) { dx = sx0 - ix0; draw_line_width(dx0 + sx0, dy0, dx0 + sx0, dy1, 1); }
						if(abs(bx0 - sx1) < sd) { dx = sx1 - ix0; draw_line_width(dx0 + sx1, dy0, dx0 + sx1, dy1, 1); }
						if(abs(bx1 - sx0) < sd) { dx = sx0 - ix1; draw_line_width(dx0 + sx0, dy0, dx0 + sx0, dy1, 1); }
						if(abs(bx1 - sx1) < sd) { dx = sx1 - ix1; draw_line_width(dx0 + sx1, dy0, dx0 + sx1, dy1, 1); }
						
						if(abs(by0 - sy0) < sd) { dy = sy0 - iy0; draw_line_width(dx0, dy0 + sy0, dx1, dy0 + sy0, 1); }
						if(abs(by0 - sy1) < sd) { dy = sy1 - iy0; draw_line_width(dx0, dy0 + sy1, dx1, dy0 + sy1, 1); }
						if(abs(by1 - sy0) < sd) { dy = sy0 - iy1; draw_line_width(dx0, dy0 + sy0, dx1, dy0 + sy0, 1); }
						if(abs(by1 - sy1) < sd) { dy = sy1 - iy1; draw_line_width(dx0, dy0 + sy1, dx1, dy0 + sy1, 1); }
						
						draw_set_color(COLORS._main_accent);
						if(abs(bx0 - sxc) < sd) { dx = sxc - ix0;         draw_line_width(dx0 + sxc, dy0, dx0 + sxc, dy1, 1); }
						if(abs(bx1 - sxc) < sd) { dx = sxc - ix1;         draw_line_width(dx0 + sxc, dy0, dx0 + sxc, dy1, 1); }
						if(abs(bxc - sxc) < sd) { dx = sxc - (ix0+ix1)/2; draw_line_width(dx0 + sxc, dy0, dx0 + sxc, dy1, 1); }
						
						if(abs(by0 - syc) < sd) { dy = syc - iy0;         draw_line_width(dx0, dy0 + syc, dx1, dy0 + syc, 1); }
						if(abs(by1 - syc) < sd) { dy = syc - iy1;         draw_line_width(dx0, dy0 + syc, dx1, dy0 + syc, 1); }
						if(abs(byc - syc) < sd) { dy = syc - (iy0+iy1)/2; draw_line_width(dx0, dy0 + syc, dx1, dy0 + syc, 1); }
					}
					
					draw_set_alpha(1);
					
					for( var i = 0, n = array_length(element_selectings); i < n; i++ ) {
						var ele = element_selectings[i];
						var box = select_multi_drag_data[i];
						ele.pbBox.setBBOX([ box[0] + dx, box[1] + dy, box[2] + dx, box[3] + dy ]);
					}
				}
				
			}
			
			if(select_multi_dragging && mouse_lrelease()) select_multi_dragging = 0;
		}
		
		////- =Box select
		var boxable = hovering_element == undefined;
		if(!array_empty(element_selectings))
			boxable = !point_in_rectangle(mx, my, select_box_x0, select_box_y0, select_box_x1, select_box_y1);
		else if(hovering_element != undefined)
			boxable = !hovering_element.draggable || !hovering_element.selectable;
		boxable &= point_in_rectangle(mx, my, dx0, dy0, dx1, dy1);
		
		if(boxable && mouse_lpress(pFOCUS)) {
			element_selectings = [];
			element_selectingm = {};
			
			selection_boxing = 1;
			selection_box_x  = mx;
			selection_box_y  = my;
		}
		
		if(selection_boxing == 1) {
			if(abs(mx - selection_box_x) > ui(4) || abs(my - selection_box_y) > ui(4))
				selection_boxing = 2;
		}
		
		if(selection_boxing == 2) {
			var x0 = min(mx, selection_box_x);
			var y0 = min(my, selection_box_y);
			var x1 = max(mx, selection_box_x);
			var y1 = max(my, selection_box_y);
			
			element_selectings = [];
			draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, x0, y0, x1, y1, COLORS._main_accent);
			data.root.boxSelect(element_selectings, x0 - dx0, y0 - dy0, x1 - dx0, y1 - dy0);
			
			if(mouse_lrelease()) {
				if(array_length(element_selectings) == 1) {
					element_selecting  = element_selectings[0];
					element_selectings = [];
					
				} else {
					element_selectingm = {};
					for( var i = 0, n = array_length(element_selectings); i < n; i++ )
						element_selectingm[$ element_selectings[i].ID] = element_selectings[i];
				}
			}
		}
		
		if(selection_boxing && mouse_lrelease()) selection_boxing = 0;
	}
	
}