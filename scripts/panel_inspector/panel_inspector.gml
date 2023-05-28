function Inspector_Custom_Renderer(draw) : widget() constructor {
	h = 64;
	self.draw = draw;
}

function Panel_Inspector() : PanelContent() constructor {
	title = "Inspector";
	context_str = "Inspector";
	icon  = THEME.panel_inspector;
	
	w = ui(400);
	h = ui(640);
	
	locked		= false;
	inspecting	= noone;
	top_bar_h	= ui(100);
	
	prop_hover		= noone;
	prop_selecting  = noone;
	
	prop_dragging   = noone;
	prop_sel_drag_x = 0;
	prop_sel_drag_y = 0;
	
	function initSize() {
		content_w = w - ui(32);
		content_h = h - top_bar_h - ui(12);
	}
	initSize();
	
	keyframe_dragging = noone;
	keyframe_drag_st  = 0;
	
	globalvar_viewer_init();
	drawWidgetInit();
	
	min_w = ui(160);
	
	tb_node_name	= new textBox(TEXTBOX_INPUT.text, function(txt) {
		if(inspecting) inspecting.setDisplayName(txt);
	})
	
	tb_prop_filter	= new textBox(TEXTBOX_INPUT.text, function(txt) { filter_text = txt; })
	tb_prop_filter.no_empty		= false;
	tb_prop_filter.auto_update	= true;
	tb_prop_filter.font			= f_p0;
	tb_prop_filter.color		= COLORS._main_text_sub;
	tb_prop_filter.align		= fa_center;
	tb_prop_filter.hide			= true;
	filter_text = "";
	
	prop_page_button = buttonGroup([ "Properties", "Settings" ], function(val) { prop_page = val; });
	prop_page_button.buttonSpr	= [ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ];
	prop_page_button.font		= f_p1;
	prop_page_button.fColor		= COLORS._main_text_sub;
	prop_page = 0;
	
	current_meta = -1;
	meta_tb[0] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.description	= str; });	
	meta_tb[1] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.author		= str; });
	meta_tb[2] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.contact		= str; });
	meta_tb[3] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.alias		= str; });
	meta_tb[4] = new textArrayBox(noone, META_TAGS);
	for( var i = 0; i < array_length(meta_tb); i++ )
		meta_tb[i].hide = true;
	
	meta_display = [ 
		[ "Metadata", false ], 
		[ "Global variables", false, button(function() { panelAdd("Panel_Globalvar", true); }, THEME.node_goto).setIcon(THEME.node_goto, 0, COLORS._main_icon) ] 
	];
	
	workshop_uploading = false;
	
	addHotkey("Inspector", "Copy property",		"C",   MOD_KEY.ctrl,	function() { PANEL_INSPECTOR.propSelectCopy(); });
	addHotkey("Inspector", "Paste property",	"V",   MOD_KEY.ctrl,	function() { PANEL_INSPECTOR.propSelectPaste(); });
	addHotkey("Inspector", "Toggle animation",	"I",   MOD_KEY.none,	function() { PANEL_INSPECTOR.anim_toggling = true; });
	
	group_menu = [
		menuItem("Expand all", function() {
			if(inspecting == noone) return;
			if(inspecting.input_display_list == -1) return;
			
			var dlist = inspecting.input_display_list;
			for( var i = 0; i < array_length(dlist); i++ ) {
				if(!is_array(dlist[i])) continue;
				dlist[i][@ 1] = false;
			}
		}),
		menuItem("Collapse all", function() {
			if(inspecting == noone) return;
			if(inspecting.input_display_list == -1) return;
			
			var dlist = inspecting.input_display_list;
			for( var i = 0; i < array_length(dlist); i++ ) {
				if(!is_array(dlist[i])) continue;
				dlist[i][@ 1] = true;
			}
		}),
	]
	
	function onFocusBegin() { PANEL_INSPECTOR = self; }
	
	function onResize() {
		initSize();
		contentPane.resize(content_w, content_h);
	}
	
	static drawMeta = function(_y, _m) {
		var con_w = contentPane.surface_w - ui(4);
		var _hover = pHOVER && contentPane.hover;
		
		var context = PANEL_GRAPH.getCurrentContext();
		var meta = context == noone? METADATA : context.metadata;
		if(meta == noone) return 0;
		current_meta = meta;
		
		var hh = ui(8);
		var yy = _y + ui(8);
		
		for( var i = 0; i < 2; i++ ) {
			var _meta = meta_display[i];
			var _txt  = array_safe_get(_meta, 0);
			var _b	  = array_safe_get(_meta, 2, noone);
			var _x1   = con_w - (_b != noone) * ui(30);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, _x1, yy + ui(32))) {
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, con_w, ui(32), COLORS.panel_inspector_group_hover, 1);
						
				if(mouse_press(mb_left, pFOCUS))
					meta_display[i][1] = !meta_display[i][1];
			} else
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, con_w, ui(32), COLORS.panel_inspector_group_bg, 1);
			
			if(_b != noone) {
				_b.setActiveFocus(pFOCUS, _hover);
				_b.draw(_x1, yy + ui(2), ui(28), ui(28), _m, THEME.button_hide_fill);
			}
			
			draw_sprite_ui(THEME.arrow, meta_display[i][1]? 0 : 3, ui(16), yy + ui(32) / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);	
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(32), yy + ui(32) / 2, _txt);
			
			yy += ui(32 + 8);
			hh += ui(32 + 8);
			
			if(meta_display[i][1]) {
				yy += ui(4);
				hh += ui(4);
				continue;
			}
			
			if(i == 0) {				
				for( var j = 0; j < array_length(meta.displays); j++ ) {
					var display = meta.displays[j];
					
					draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
					draw_text_add(ui(16), yy, display[0]);
					yy += line_get_height() + ui(6);
					hh += line_get_height() + ui(6);
				
					meta_tb[j].setActiveFocus(pFOCUS, _hover);
					if(pFOCUS) meta_tb[j].register(contentPane);
					
					var wh = 0;
					var _dataFunc = display[1];
					var _data     = _dataFunc(meta);
					
					switch(instanceof(meta_tb[j])) {
						case "textArea" :	
							wh = meta_tb[j].draw(ui(16), yy, w - ui(16 + 48), display[2], _data, _m);
							break;
						case "textArrayBox" :	
							meta_tb[j].arraySet = current_meta.tags;
							var rx = x + ui(16);
							var ry = y + top_bar_h;
							wh = meta_tb[j].draw(ui(16), yy, w - ui(16 + 48), display[2], _m, rx, ry);
							break;
					}
					
					yy += wh + ui(8);
					hh += wh + ui(8);
				}
			} else if (i == 1) {
				if(findPanel("Panel_Globalvar")) {
					yy += ui(4);
					hh += ui(4);
					continue;
				}
				
				var gvh = globalvar_viewer_draw(ui(16), yy, contentPane.surface_w - ui(24), _m, pFOCUS, _hover, contentPane, ui(16) + x, top_bar_h + y);
				yy += gvh + ui(8);
				hh += gvh + ui(8);
				
				var bh = ui(36);
				var bx = ui(16);
				var by = yy;
				var bbw = contentPane.surface_w - ui(24);
				
				if(var_editing) {
					var bw = bbw / 2 - ui(4);
					
					if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, pFOCUS, _hover) == 2)
						var_editing = !var_editing;
		
					var txt  = get_text("apply", "Apply");
					var icon = THEME.accept;
					var colr = COLORS._main_value_positive;
					
					draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_icon)
					var bxc = bx + bw / 2 - (string_width(txt) + ui(48)) / 2;
					var byc = by + bh / 2;
					draw_sprite_ui(icon, 0, bxc + ui(24), byc,,,, colr);
					draw_text(bxc + ui(48), byc, txt);
				
					bx += bw + ui(4);
				
					if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, pFOCUS, _hover) == 2)
						GLOBAL.createValue();
					
					var txt  = get_text("add", "Add");
					var icon = THEME.add;
				
					draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_icon)
					var bxc = bx + bw / 2 - (string_width(txt) + ui(48)) / 2;
					var byc = by + bh / 2;
					draw_sprite_ui(icon, 0, bxc + ui(24), byc,,,, colr);
					draw_text(bxc + ui(48), byc, txt);
				} else {
					var bw = bbw;
					
					if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, pFOCUS, _hover) == 2)
						var_editing = !var_editing;
		
					var txt  = get_text("edit", "Edit");
					var icon = THEME.gear;
					var colr = COLORS._main_icon;
					
					draw_set_text(f_p0b, fa_left, fa_center, colr)
					var bxc = bx + bw / 2 - (string_width(txt) + ui(48)) / 2;
					var byc = by + bh / 2;
					draw_sprite_ui(icon, 0, bxc + ui(24), byc,,,, colr);
					draw_text(bxc + ui(48), byc, txt);
				}
				
				yy += bh + ui(16);
				hh += bh + ui(16);
			}
			
			yy += ui(8);
			hh += ui(8);
		}
			
		return hh;
	}
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		var con_w = contentPane.surface_w - ui(4);
		var _hover = pHOVER && contentPane.hover;
		
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		if(point_in_rectangle(_m[0], _m[1], 0, 0, con_w, content_h) && mouse_press(mb_left, pFOCUS))
			prop_selecting = noone;
		
		if(inspecting == noone) // metadata
			return drawMeta(_y, _m);
		
		inspecting.inspecting = true;
		prop_hover	= noone;
		var jun		= noone;
		var amoIn	= inspecting.input_display_list == -1? ds_list_size(inspecting.inputs) : array_length(inspecting.input_display_list);
		var amoOut	= ds_list_size(inspecting.outputs);
		var amo		= amoIn + 1 + amoOut;
		var hh		= ui(40);
		
		//tb_prop_filter.register(contentPane);
		//tb_prop_filter.setActiveFocus(pHOVER, pFOCUS);
		//tb_prop_filter.draw(ui(32), _y + ui(4), con_w - ui(64), ui(28), filter_text, _m);
		//draw_sprite_ui(THEME.search, 0, ui(32 + 16), _y + ui(4 + 14), 1, 1, 0, COLORS._main_icon, 1);
		
		prop_page_button.setActiveFocus(pFOCUS, pHOVER);
		prop_page_button.draw(ui(32), _y + ui(4), contentPane.w - ui(76), ui(28), prop_page, _m);
		
		var xc = con_w / 2;
		
		if(prop_page == 1) {
			hh += ui(8);
			var hg  = ui(32);
			var yy  = hh;
			var wx1 = con_w - ui(8);
			var ww  = max(ui(180), con_w / 3);
			var wx0 = wx1 - ww;
			
			for( var i = 0; i < array_length(inspecting.attributeEditors); i++ ) {
				var edt = inspecting.attributeEditors[i];
				
				if(is_string(edt)) {
					var lby = yy + ui(12);
					draw_set_alpha(0.5);
					draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
					draw_text_over(xc, lby, edt);
					
					var lbw = string_width(edt) / 2;
					draw_set_color(COLORS._main_text_sub);
					draw_line_round(xc + lbw + ui(16), lby,   wx1, lby, 2);
					draw_line_round(xc - lbw - ui(16), lby, ui(8), lby, 2);
					draw_set_alpha(1.0);
					
					yy += ui(32);
					hh += ui(32);
					continue;
				}
				
				var val = inspecting.attributes[? edt[1]];
				edt[2].setActiveFocus(pFOCUS, pHOVER);
				
				if(instanceof(edt[2]) == "buttonClass") {
					edt[2].text = edt[0];
					edt[2].draw(ui(8), yy, con_w - ui(16), hg, _m); 
					
					yy += hg + ui(8);
					hh += hg + ui(8);
					continue;
				} 
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text_over(ui(8), yy + hg / 2, edt[0]);
				
				switch(instanceof(edt[2])) {
					case "textBox" :	edt[2].draw(wx0, yy, ww, hg, val, _m); break;
					case "checkBox" :	edt[2].draw(wx0 + ww / 2 - ui(28) / 2, yy + ui(2), val, _m, ui(28)); break;
					case "scrollBox" :	edt[2].draw(wx0, yy, ww, hg, edt[2].data_list[val], _m, x + contentPane.x, y + contentPane.y); break;
				}
				
				yy += hg + ui(8);
				hh += hg + ui(8);
			}
			return hh;
		}
		
		for(var i = 0; i < amo; i++) {
			var yy = hh + _y;
			
			if(i < amoIn) {
				if(inspecting.input_display_list == -1) {
					jun = inspecting.inputs[| i];
				} else {
					if(i >= array_length(inspecting.input_display_list)) break;
					var jun_disp = inspecting.input_display_list[i];
					if(is_array(jun_disp)) {
						var txt  = jun_disp[0];
						var coll = jun_disp[1] && filter_text == "";
					
						if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, con_w, yy + ui(32))) {
							draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, con_w, ui(32), COLORS.panel_inspector_group_hover, 1);
						
							if(mouse_press(mb_left, pFOCUS))
								jun_disp[@ 1] = !coll;
							if(mouse_press(mb_right, pFOCUS))
								menuCall("inspector_group_menu",,, group_menu,, inspecting);
						} else
							draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, con_w, ui(32), COLORS.panel_inspector_group_bg, 1);
					
						if(filter_text == "") {
							draw_sprite_ui(THEME.arrow, 0, ui(16), yy + ui(32) / 2, 1, 1, -90 + coll * 90, COLORS.panel_inspector_group_bg, 1);	
						}
					
						draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
						draw_text(ui(32), yy + ui(32) / 2, txt);
					
						hh += ui(32 + 8);
					
						if(coll) {
							var j = i + 1;
							while(j < amo) {
								if(j >= array_length(inspecting.input_display_list)) break;
								var j_jun = inspecting.input_display_list[j];
								if(is_array(j_jun))
									break;
								else
									j++;
							}
							i = j - 1;
							continue;
						}
						continue;
					} else if(is_struct(jun_disp) && instanceof(jun_disp) == "Inspector_Custom_Renderer") {
						if(pFOCUS) jun_disp.register(contentPane);
						jun_disp.rx = ui(16) + x;
						jun_disp.ry = top_bar_h + y;
					
						hh += jun_disp.draw(ui(6), yy, con_w - ui(12), _m, _hover, pFOCUS) + ui(8);
						continue;
					}
					jun = inspecting.inputs[| inspecting.input_display_list[i]];
				}
			} else if(i == amoIn) { 
				hh += ui(8 + 32 + 8);
				
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy + ui(8), con_w, ui(32), COLORS._main_icon_dark, 0.85);
				draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
				draw_text(xc, yy + ui(8 + 16), "Outputs");
				continue;
			} else {
				var outInd = i - amoIn - 1;
				jun = inspecting.outputs[| outInd];
			}
			
			if(!is_struct(jun)) continue;
			if(instanceof(jun) != "NodeValue") continue;
			
			if(!jun.show_in_inspector || jun.type == VALUE_TYPE.object) continue;
			if(filter_text != "") {
				var pos = string_pos(filter_text, string_lower(jun.name));
				if(pos == 0) continue;
			}
			
			var lb_h    = line_get_height(f_p0) + ui(8);
			var lb_w    = line_get_width(jun.name, f_p0) + ui(16);
			var padd    = ui(8);
			
			var _selY	= yy - ui(0);
			var lbHov   = point_in_rectangle(_m[0], _m[1], ui(48), _selY, ui(48) + lb_w, _selY + lb_h);
			if(lbHov) 
				draw_sprite_stretched_ext(THEME.group_label, 0, ui(48), _selY + ui(2), lb_w, lb_h - ui(4), COLORS._main_icon_dark, 0.85);
				
			var widg    = drawWidget(ui(16), yy, contentPane.surface_w - ui(24), _m, jun, false, pHOVER && contentPane.hover, pFOCUS, contentPane, ui(16) + x, top_bar_h + y);
			var widH    = widg[0];
			var mbRight = widg[1];
			
			hh += lb_h + widH + padd;
			
			var _selY1 = yy + lb_h + widH + ui(2);
			var _selH  = _selY1 - _selY;
			
			if(_hover && lbHov) {
				if(prop_dragging == noone && mouse_press(mb_left, pFOCUS)) {
					prop_dragging = jun;
					
					prop_sel_drag_x = mouse_mx;
	  				prop_sel_drag_y = mouse_my;
				}
			}
			
			if(_hover && point_in_rectangle(_m[0], _m[1], 4, _selY, contentPane.surface_w - ui(4), _selY + _selH)) {
				_HOVERING_ELEMENT = jun;
				
				draw_sprite_stretched_ext(THEME.prop_selecting, 0, 4, _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_accent, 1);
				if(anim_toggling) {
					jun.setAnim(!jun.is_anim);
					PANEL_ANIMATION.updatePropertyList();
					anim_toggling = false;
				}
				
				prop_hover = jun;
					
				if(mouse_press(mb_left, pFOCUS))
					prop_selecting = jun;
						
				if(mouse_press(mb_right, pFOCUS && mbRight)) {
					var _menuItem = [];
					
					if(i < amoIn) {
						array_push(_menuItem, 
							menuItem(get_text("panel_inspector_reset", "Reset value"), function() { 
								__dialog_junction.resetValue();
								}),
							menuItem(jun.is_anim? get_text("panel_inspector_remove", "Remove animation") : get_text("panel_inspector_add", "Add animation"), function() { 
								__dialog_junction.setAnim(!__dialog_junction.is_anim); 
								PANEL_ANIMATION.updatePropertyList();
								}),
						);
						
						if(jun.sepable) {
							array_push(_menuItem, 
								menuItem(jun.sep_axis? get_text("panel_inspector_axis_combine", "Combine axis") : get_text("panel_inspector_axis_separate", "Separate axis"), function() { 
									__dialog_junction.sep_axis = !__dialog_junction.sep_axis; 
									PANEL_ANIMATION.updatePropertyList();
									}),
							);
						}
						
						array_push(_menuItem, -1);
					}
						
					array_push(_menuItem, 
						menuItem(get_text("use_global_var", "Use expression"), function() {
							__dialog_junction.expUse = !__dialog_junction.expUse;
							}),
						-1,
						menuItem(get_text("copy", "Copy"), function() {
							clipboard_set_text(__dialog_junction.getShowString());
							}, THEME.copy, ["Inspector", "Copy property"]),
						menuItem(get_text("paste", "Paste"), function() {
							__dialog_junction.setString(clipboard_get_text());
							}, THEME.paste, ["Inspector", "Paste property"]),
					);
					
					if(jun.extract_node != "") {
						array_insert(_menuItem, 2, menuItem(get_text("panel_inspector_extract", "Extract to node"), function() { 
							__dialog_junction.extractNode();
						}));
					}
					
					var dia = menuCall("inspector_value_menu",,, _menuItem,, jun);
					__dialog_junction = jun;
				}
			}
		}
		
		if(prop_dragging) {
			if(DRAGGING == noone && point_distance(prop_sel_drag_x, prop_sel_drag_y, mouse_mx, mouse_my) > 16) {
				prop_dragging.dragValue();
				prop_dragging = noone;
			}
			
			if(mouse_release(mb_left))
				prop_dragging = noone;
		}
		
		return hh;
	});
	
	function propSelectCopy() {
		if(!prop_selecting) return;
		clipboard_set_text(prop_selecting.getShowString());
	}
	function propSelectPaste() {
		if(!prop_selecting) return;
		prop_selecting.setString(clipboard_get_text());
	}
	
	function drawInspectingNode() {
		tb_node_name.font = f_h5;
		tb_node_name.hide = true;
		tb_node_name.setActiveFocus(pFOCUS, pHOVER);
		tb_node_name.align = fa_center;
		var txt = inspecting.display_name == ""? inspecting.name : inspecting.display_name;
		tb_node_name.draw(ui(64), ui(14), w - ui(128), ui(32), txt, [mx, my], VALUE_DISPLAY.node_title);
		
		draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
		draw_text(w / 2 + ui(8), ui(56), inspecting.name);
		
		draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
		draw_set_alpha(0.65);
		draw_text_add(w / 2, ui(76), inspecting.internalName);
		draw_set_alpha(1);
		
		var lx = w / 2 - string_width(inspecting.name) / 2 - ui(16);
		var ly = ui(56 - 8);
		if(buttonInstant(THEME.button_hide, lx, ly, ui(16), ui(16), [mx, my], pFOCUS, pHOVER, "Lock", THEME.lock, !locked, locked? COLORS._main_icon_light : COLORS._main_icon,, 0.5) == 2)
			locked = !locked;
		
		var bx = ui(8);
		var by = ui(12);
			
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("presets", "Presets"), THEME.preset, 1) == 2)
			dialogCall(o_dialog_preset, x + bx, y + by + ui(36), { "node": inspecting });
		
		var bx = w - ui(44);
		var by = ui(12);
		
		if(inspecting.hasInspector1Update(true)) {
			var icon = inspecting.insp1UpdateIcon;
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, inspecting.insp1UpdateTooltip, icon[0], icon[1], icon[2]) == 2)
				inspecting.inspector1Update();
		} else 
			draw_sprite_ui(THEME.sequence_control, 1, bx + ui(16), by + ui(16),,,, COLORS._main_icon_dark);
		
		if(inspecting.hasInspector2Update()) {
			by += ui(36);
			var icon = inspecting.insp2UpdateIcon;
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, inspecting.insp2UpdateTooltip, icon[0], icon[1], icon[2]) = 2)
				inspecting.inspector2Update();
		}
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		lineBreak = w < PREF_MAP[? "inspector_line_break_width"];
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), top_bar_h - ui(8), w - ui(16), h - top_bar_h);
		
		if(inspecting) {
			title = inspecting.display_name == ""? inspecting.name : inspecting.display_name;
			drawInspectingNode();
		} else {
			title = "Inspector";
			
			var txt = "Untitled";
			var context = PANEL_GRAPH.getCurrentContext();
			
			if(context == noone && file_exists(CURRENT_PATH))
				txt = string_replace(filename_name(CURRENT_PATH), filename_ext(CURRENT_PATH), "");
			else if(context != noone)
				txt = context.name;
			
			draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
			draw_text_add(w / 2, ui(30), txt);
			
			var bx = w - ui(44);
			var by = ui(12);
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_inspector_set_default", "Set as default"), THEME.save, 0, COLORS._main_icon) == 2) {
				var path = DIRECTORY + "meta.json";
				var f = file_text_open_write(path);
				file_text_write_string(f, json_encode_minify(METADATA.serialize()));
				file_text_close(f);
			}
			
			by += ui(36);
			if(STEAM_ENABLED && !workshop_uploading) {
				if(CURRENT_PATH == "") {
					buttonInstant(noone, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_inspector_workshop_save", "Save file before upload"), THEME.workshop_upload, 0, COLORS._main_icon, 0.5);
				} else {
					if(!METADATA.steam) { //project made locally
						if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_inspector_workshop_upload", "Upload to Steam Workshop"), THEME.workshop_upload, 0, COLORS._main_icon) == 2) {
							var s = PANEL_PREVIEW.getNodePreviewSurface();
							if(is_surface(s)) {
								METADATA.author_steam_id = STEAM_USER_ID;
								SAVE();
								steam_ugc_create_project();
								workshop_uploading = true;
							} else 
								noti_warning("Please send any node to preview panel to use as a thumbnail.")
						}
					}
				
					if(METADATA.steam && METADATA.author_steam_id == STEAM_USER_ID && METADATA.file_id != 0) {
						if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_inspector_workshop_update", "Update Steam Workshop"), THEME.workshop_update, 0, COLORS._main_icon) == 2) {
							SAVE();
							steam_ugc_update_project();
							workshop_uploading = true;
						}
					}
				}
			}
			
			if(workshop_uploading) {
				draw_sprite_ui(THEME.loading_s, 0, bx + ui(16), by + ui(16),,, current_time / 5, COLORS._main_icon);
				if(STEAM_UGC_ITEM_UPLOADING == false)
					workshop_uploading = false;
			}
		}
		
		contentPane.setActiveFocus(pFOCUS, pHOVER);
		contentPane.draw(ui(16), top_bar_h, mx - ui(16), my - top_bar_h);
		
		if(!locked && PANEL_GRAPH.node_focus && inspecting != PANEL_GRAPH.node_focus) {
			inspecting = PANEL_GRAPH.node_focus;
			if(inspecting != noone)
				inspecting.onInspect();
			contentPane.scroll_y    = 0;
			contentPane.scroll_y_to = 0;
		}
	}
}