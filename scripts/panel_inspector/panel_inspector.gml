function Inspector_Custom_Renderer(drawFn) : widget() constructor {
	h = 64;
	self.draw = drawFn;
}

function Panel_Inspector() : PanelContent() constructor {
	#region ---- main ----
		title = __txt("Inspector");
		context_str = "Inspector";
		icon  = THEME.panel_inspector;
	
		w = ui(400);
		h = ui(640);
		min_w = ui(160);
	
		locked		= false;
		inspecting	= noone;
		top_bar_h	= ui(100);
		
		static initSize = function() {
			content_w = w - ui(32);
			content_h = h - top_bar_h - ui(12);
		}
		initSize();
	#endregion
	
	#region ---- properties ----
		prop_hover		= noone;
		prop_selecting  = noone;
	
		prop_dragging   = noone;
		prop_sel_drag_x = 0;
		prop_sel_drag_y = 0;
	
		color_picking	= false;
		
		picker_index  = 0;
		picker_change = false;
	#endregion
	
	globalvar_viewer_init();
	drawWidgetInit();
	
	#region ---- header labels ----
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
	
		prop_page_button = new buttonGroup([ "Properties", "Settings" ], function(val) { prop_page = val; });
		prop_page_button.buttonSpr	= [ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ];
		prop_page_button.font		= f_p1;
		prop_page_button.fColor		= COLORS._main_text_sub;
		prop_page = 0;
	#endregion
	
	#region ---- metadata ----
		current_meta = -1;
		meta_tb[0] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.description	= str; });	
		meta_tb[1] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.author		= str; });
		meta_tb[2] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.contact		= str; });
		meta_tb[3] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.alias		= str; });
		meta_tb[4] = new textArrayBox(noone, META_TAGS);
		for( var i = 0, n = array_length(meta_tb); i < n; i++ )
			meta_tb[i].hide = true;
	
		meta_display = [ 
			[ __txt("Project Settings"), false ], 
			[ __txt("Metadata"), true ], 
			[ __txtx("panel_globalvar", "Global variables"), true, button(function() { panelAdd("Panel_Globalvar", true); }, THEME.node_goto).setIcon(THEME.node_goto, 0, COLORS._main_icon) ] 
		];
	#endregion
	
	#region ---- workshop ----
		workshop_uploading = false;
	#endregion
	
	#region ++++ hotkeys ++++
		addHotkey("Inspector", "Copy property",		"C",   MOD_KEY.ctrl,	function() { PANEL_INSPECTOR.propSelectCopy(); });
		addHotkey("Inspector", "Paste property",	"V",   MOD_KEY.ctrl,	function() { PANEL_INSPECTOR.propSelectPaste(); });
		addHotkey("Inspector", "Toggle animation",	"I",   MOD_KEY.none,	function() { PANEL_INSPECTOR.anim_toggling = true; });
	
		addHotkey("", "Color picker",		"",   MOD_KEY.alt,		function() { 
																		if(!PREF_MAP[? "alt_picker"]) return; 
																		PANEL_INSPECTOR.color_picking = true; 
																	});
	#endregion
	
	#region ++++ menus ++++
		group_menu = [
			menuItem(__txt("Expand all"), function() {
				if(inspecting == noone) return;
				if(inspecting.input_display_list == -1) return;
			
				var dlist = inspecting.input_display_list;
				for( var i = 0, n = array_length(dlist); i < n; i++ ) {
					if(!is_array(dlist[i])) continue;
					dlist[i][@ 1] = false;
				}
			}),
			menuItem(__txt("Collapse all"), function() {
				if(inspecting == noone) return;
				if(inspecting.input_display_list == -1) return;
			
				var dlist = inspecting.input_display_list;
				for( var i = 0, n = array_length(dlist); i < n; i++ ) {
					if(!is_array(dlist[i])) continue;
					dlist[i][@ 1] = true;
				}
			}),
		]
	#endregion
	
	function setInspecting(inspecting) { #region
		if(locked) return;
		
		self.inspecting = inspecting;
		
		if(inspecting != noone)
			inspecting.onInspect();
		contentPane.scroll_y    = 0;
		contentPane.scroll_y_to = 0;
			
		picker_index = 0;
	} #endregion
	
	function getInspecting() { #region
		if(inspecting == noone) return noone;
		return inspecting.active? inspecting : noone;
	} #endregion
	
	function onFocusBegin() { PANEL_INSPECTOR = self; }
	
	function onResize() { #region
		initSize();
		contentPane.resize(content_w, content_h);
	} #endregion
	
	static drawMeta = function(_y, _m) { #region
		var con_w = contentPane.surface_w - ui(4);
		var _hover = pHOVER && contentPane.hover;
		
		var context = PANEL_GRAPH.getCurrentContext();
		var meta = context == noone? METADATA : context.metadata;
		if(meta == noone) return 0;
		current_meta = meta;
		
		var hh = ui(8);
		var yy = _y + ui(8);
		
		var rx = x + ui(16);
		var ry = y + top_bar_h;
		
		for( var i = 0, n = array_length(meta_display); i < n; i++ ) {
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
				_b.setFocusHover(pFOCUS, _hover);
				_b.draw(_x1, yy + ui(2), ui(28), ui(28), _m, THEME.button_hide_fill);
			}
			
			draw_sprite_ui(THEME.arrow, meta_display[i][1]? 0 : 3, ui(16), yy + ui(32) / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);	
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
			draw_text_add(ui(32), yy + ui(32) / 2, _txt);
			
			yy += ui(32 + 8);
			hh += ui(32 + 8);
			
			if(meta_display[i][1]) {
				yy += ui(4);
				hh += ui(4);
				continue;
			}
			
			if(i == 0) {
				var _edt = PROJECT.attributeEditor;
				for( var j = 0; j < array_length(_edt); j++ ) {
					var title = _edt[j][0];
					var param = _edt[j][1];
					var editW = _edt[j][2];
					
					draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_inner);
					draw_text_add(ui(16), yy, __txt(title));
					yy += line_get_height() + ui(6);
					hh += line_get_height() + ui(6);
					
					editW.setFocusHover(pFOCUS, _hover);
					if(pFOCUS) editW.register(contentPane);
					
					var wh = 0;
					var _data = PROJECT.attributes[$ param];
					
					wh = editW.drawParam(new widgetParam(
						ui(16),
						yy,
						w - ui(16 + 48),
						TEXTBOX_HEIGHT, 
						_data,
						{},
						_m,
						rx,
						ry,
					));
					
					yy += wh + ui(8);
					hh += wh + ui(8);
				}
			} else if(i == 1) {				
				for( var j = 0; j < array_length(meta.displays); j++ ) {
					var display = meta.displays[j];
					
					draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_inner);
					draw_text_add(ui(16), yy, __txt(display[0]));
					yy += line_get_height() + ui(6);
					hh += line_get_height() + ui(6);
				
					meta_tb[j].setFocusHover(pFOCUS, _hover);
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
							wh = meta_tb[j].draw(ui(16), yy, w - ui(16 + 48), display[2], _m, rx, ry);
							break;
					}
					
					yy += wh + ui(8);
					hh += wh + ui(8);
				}
			} else if (i == 2) {
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
		
					var txt  = __txt("Apply");
					var icon = THEME.accept;
					var colr = COLORS._main_value_positive;
					
					draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_icon)
					var bxc = bx + bw / 2 - (string_width(txt) + ui(48)) / 2;
					var byc = by + bh / 2;
					draw_sprite_ui(icon, 0, bxc + ui(24), byc,,,, colr);
					draw_text_add(bxc + ui(48), byc, txt);
				
					bx += bw + ui(4);
				
					if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, pFOCUS, _hover) == 2)
						PROJECT.globalNode.createValue();
					
					var txt  = __txt("Add");
					var icon = THEME.add;
				
					draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_icon)
					var bxc = bx + bw / 2 - (string_width(txt) + ui(48)) / 2;
					var byc = by + bh / 2;
					draw_sprite_ui(icon, 0, bxc + ui(24), byc,,,, colr);
					draw_text_add(bxc + ui(48), byc, txt);
				} else {
					var bw = bbw;
					
					if(buttonInstant(THEME.button_hide, bx, by, bw, bh, _m, pFOCUS, _hover) == 2)
						var_editing = !var_editing;
		
					var txt  = __txt("Edit");
					var icon = THEME.gear;
					var colr = COLORS._main_icon;
					
					draw_set_text(f_p0b, fa_left, fa_center, colr)
					var bxc = bx + bw / 2 - (string_width(txt) + ui(48)) / 2;
					var byc = by + bh / 2;
					draw_sprite_ui(icon, 0, bxc + ui(24), byc,,,, colr);
					draw_text_add(bxc + ui(48), byc, txt);
				}
				
				yy += bh + ui(16);
				hh += bh + ui(16);
			}
			
			yy += ui(8);
			hh += ui(8);
		}
			
		return hh;
	} #endregion
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) { #region
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
		//tb_prop_filter.setFocusHover(pHOVER, pFOCUS);
		//tb_prop_filter.draw(ui(32), _y + ui(4), con_w - ui(64), ui(28), filter_text, _m);
		//draw_sprite_ui(THEME.search, 0, ui(32 + 16), _y + ui(4 + 14), 1, 1, 0, COLORS._main_icon, 1);
		
		prop_page_button.setFocusHover(pFOCUS, pHOVER);
		prop_page_button.draw(ui(32), _y + ui(4), contentPane.w - ui(76), ui(28), prop_page, _m);
		
		var xc = con_w / 2;
		
		if(prop_page == 1) { #region attribute/settings editor
			hh += ui(8);
			var hg  = ui(32);
			var yy  = hh;
			var wx1 = con_w - ui(8);
			var ww  = max(ui(180), con_w / 3);
			var wx0 = wx1 - ww;
			
			for( var i = 0, n = array_length(inspecting.attributeEditors); i < n; i++ ) {
				var edt = inspecting.attributeEditors[i];
				
				if(is_string(edt)) {
					var lby = yy + ui(12);
					draw_set_alpha(0.5);
					draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
					draw_text_add(xc, lby, edt);
					
					var lbw = string_width(edt) / 2;
					draw_set_color(COLORS._main_text_sub);
					draw_line_round(xc + lbw + ui(16), lby,   wx1, lby, 2);
					draw_line_round(xc - lbw - ui(16), lby, ui(8), lby, 2);
					draw_set_alpha(1.0);
					
					yy += ui(32);
					hh += ui(32);
					continue;
				}
				
				var val = edt[1]();
				edt[2].setFocusHover(pFOCUS, pHOVER);
				
				if(instanceof(edt[2]) == "buttonClass") {
					edt[2].text = edt[0];
					edt[2].draw(ui(8), yy, con_w - ui(16), hg, _m); 
					
					yy += hg + ui(8);
					hh += hg + ui(8);
					continue;
				} 
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(8), yy + hg / 2, edt[0]);
				
				edt[2].drawParam(new widgetParam(wx0, yy, ww, hg, val, {}, _m, x + contentPane.x, y + contentPane.y));
				
				yy += hg + ui(8);
				hh += hg + ui(8);
			}
			return hh;
		} #endregion
		
		var color_picker_selecting = noone;
		var color_picker_index = 0;
		var pickers = [];
		
		for(var i = 0; i < amo; i++) {
			var yy = hh + _y;
			
			if(i < amoIn) { #region inputs
				if(inspecting.input_display_list == -1) {
					jun = inspecting.inputs[| i];
				} else {
					if(i >= array_length(inspecting.input_display_list)) break;
					var jun_disp = inspecting.input_display_list[i];
					if(is_array(jun_disp)) {
						var txt  = __txt(jun_disp[0]);
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
						draw_text_add(ui(32), yy + ui(32) / 2, txt);
					
						hh += ui(32 + 8);
						
						if(coll) {
							var j    = i + 1;
							var _len = array_length(inspecting.input_display_list);
							
							while(j < _len) {
								var j_jun = inspecting.input_display_list[j];
								if(is_array(j_jun))
									break;
								j++;
							}
							
							i = j - 1;
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
			#endregion
			} else if(i == amoIn) { #region output label
				hh += ui(8 + 32 + 8);
				
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy + ui(8), con_w, ui(32), COLORS.panel_inspector_output_label, 0.85);
				draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
				draw_text_add(xc, yy + ui(8 + 16), __txt("Outputs"));
				continue;
			#endregion
			} else { #region outputs
				var outInd = i - amoIn - 1;
				jun = inspecting.outputs[| outInd];
			#endregion
			} 
			
			if(!is_struct(jun)) continue;
			if(instanceof(jun) != "NodeValue") continue;
			
			if(!jun.show_in_inspector || jun.type == VALUE_TYPE.object) continue;
			if(filter_text != "") {
				var pos = string_pos(filter_text, string_lower(jun.name));
				if(pos == 0) continue;
			}
			
			#region ++++ draw widget ++++
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
			#endregion
			
			if(jun.connect_type == JUNCTION_CONNECT.input && jun.type == VALUE_TYPE.color && jun.display_type == VALUE_DISPLAY._default) { #region color picker
				pickers[color_picker_index] = jun;
				if(color_picker_index == picker_index) {
					if(color_picking && WIDGET_CURRENT == noone && !instance_exists(_p_dialog))
						jun.editWidget.onColorPick();
					color_picker_selecting = jun;
				}
				
				color_picker_index++;
			} #endregion
			
			if(_hover && point_in_rectangle(_m[0], _m[1], ui(4), _selY, contentPane.surface_w - ui(4), _selY + _selH)) { #region mouse in widget
				_HOVERING_ELEMENT = jun;
				
				if(NODE_DROPPER_TARGET != noone && NODE_DROPPER_TARGET != jun) {
					draw_sprite_stretched_ext(THEME.ui_panel_active, 0, ui(4), _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_value_positive, 1);
					if(mouse_press(mb_left, NODE_DROPPER_TARGET_CAN)) {
						NODE_DROPPER_TARGET.expression += $"{jun.node.internalName}.{jun.connect_type == JUNCTION_CONNECT.input? "inputs" : "outputs"}.{jun.internalName}";
						NODE_DROPPER_TARGET.expressionUpdate(); 
					}
				} else 
					draw_sprite_stretched_ext(THEME.prop_selecting, 0, 4, _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_accent, 1);
				
				if(anim_toggling) {
					jun.setAnim(!jun.is_anim);
					PANEL_ANIMATION.updatePropertyList();
					anim_toggling = false;
				}
				
				prop_hover = jun;
					
				if(mouse_press(mb_left, pFOCUS))
					prop_selecting = jun;
						
				if(mouse_press(mb_right, pFOCUS && mbRight)) { #region right click menu
					var _menuItem = [];
					
					if(i < amoIn) {
						array_push(_menuItem, 
							menuItem(__txtx("panel_inspector_reset", "Reset value"), function() { 
								__dialog_junction.resetValue();
								}),
							menuItem(jun.is_anim? __txtx("panel_inspector_remove", "Remove animation") : __txtx("panel_inspector_add", "Add animation"), function() { 
								__dialog_junction.setAnim(!__dialog_junction.is_anim); 
								PANEL_ANIMATION.updatePropertyList();
								}),
						);
						
						if(jun.sepable) {
							array_push(_menuItem, 
								menuItem(jun.sep_axis? __txtx("panel_inspector_axis_combine", "Combine axis") : __txtx("panel_inspector_axis_separate", "Separate axis"), function() { 
									__dialog_junction.sep_axis = !__dialog_junction.sep_axis; 
									PANEL_ANIMATION.updatePropertyList();
									}),
							);
						}
						
						array_push(_menuItem, -1);
					}
						
					array_push(_menuItem, 
						menuItem(__txtx("panel_inspector_use_expression", "Use expression"), function() {
							__dialog_junction.expUse = !__dialog_junction.expUse;
							}),
						-1,
						menuItem(__txt("Copy"), function() {
							clipboard_set_text(__dialog_junction.getShowString());
							}, THEME.copy, ["Inspector", "Copy property"]),
						menuItem(__txt("Paste"), function() {
							__dialog_junction.setString(clipboard_get_text());
							}, THEME.paste, ["Inspector", "Paste property"]),
					);
					
					if(jun.extract_node != "") {
						if(is_array(jun.extract_node)) {
							var ext = menuItem(__txtx("panel_inspector_extract_multiple", "Extract to..."),	function(_dat) { 
								var arr = [];
								for(var i = 0; i < array_length(__dialog_junction.extract_node); i++)  {
									var _rec = __dialog_junction.extract_node[i];
									array_push(arr, menuItem(_rec, function(_dat) { __dialog_junction.extractNode(_dat.name); }));
								}
									
								return submenuCall(_dat, arr);
							}).setIsShelf();
							array_insert(_menuItem, 2, ext);
						} else {
							array_insert(_menuItem, 2, menuItem(__txtx("panel_inspector_extract_single", "Extract to node"), function() { 
								__dialog_junction.extractNode();
							}));
						}
					}
					
					var dia = menuCall("inspector_value_menu",,, _menuItem,, jun);
					__dialog_junction = jun;
				} #endregion
			} #endregion
		}
		
		if(color_picker_selecting == noone)
			picker_selecting = 0;
		
		if(key_mod_press(ALT) && color_picker_index) {
			var _p = picker_index;
			
			if(mouse_wheel_down()) picker_index = safe_mod(picker_index + 1 + color_picker_index, color_picker_index);
			if(mouse_wheel_up())   picker_index = safe_mod(picker_index - 1 + color_picker_index, color_picker_index);
			
			if(_p != picker_index) {
				instance_destroy(o_dialog_color_selector);
				pickers[picker_index].editWidget.onColorPick();
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
		
		color_picking = false;
		
		return hh;
	}); #endregion
	
	function propSelectCopy() { #region
		if(!prop_selecting) return;
		clipboard_set_text(prop_selecting.getShowString());
	} #endregion
	
	function propSelectPaste() { #region
		if(!prop_selecting) return;
		prop_selecting.setString(clipboard_get_text());
	} #endregion
	
	function drawInspectingNode() { #region
		tb_node_name.font = f_h5;
		tb_node_name.hide = true;
		tb_node_name.setFocusHover(pFOCUS, pHOVER);
		tb_node_name.align  = fa_center;
		tb_node_name.format = TEXT_AREA_FORMAT.node_title;
		var txt = inspecting.display_name == ""? inspecting.name : inspecting.display_name;
		tb_node_name.draw(ui(64), ui(14), w - ui(128), ui(32), txt, [mx, my]);
		
		draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
		draw_text_add(w / 2 + ui(8), ui(56), inspecting.name);
		
		draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
		draw_set_alpha(0.65);
		draw_text_add(w / 2, ui(76), inspecting.internalName);
		draw_set_alpha(1);
		
		draw_set_font(f_p1);
		var lx = w / 2 - string_width(inspecting.name) / 2 - ui(10);
		var ly = ui(56 - 8);
		if(buttonInstant(THEME.button_hide, lx, ly, ui(16), ui(16), [mx, my], pFOCUS, pHOVER, __txt("Lock"), THEME.lock, !locked, locked? COLORS._main_icon_light : COLORS._main_icon,, 0.5) == 2)
			locked = !locked;
		
		var bx = ui(8);
		var by = ui(12);
			
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txt("Presets"), THEME.preset, 1) == 2)
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
	} #endregion
	
	function drawContent(panel) { #region					>>>>>>>>>>>>>>>>>>>> MAIN DRAW <<<<<<<<<<<<<<<<<<<<
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		lineBreak = w < PREF_MAP[? "inspector_line_break_width"];
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), top_bar_h - ui(8), w - ui(16), h - top_bar_h);
		
		if(inspecting && !inspecting.active)
			inspecting = noone;
		
		if(inspecting) {
			title = inspecting.display_name == ""? inspecting.name : inspecting.display_name;
			inspecting.inspectorStep();
			drawInspectingNode();
		} else {
			title = __txt("Inspector");
			
			var txt = "Untitled";
			var context = PANEL_GRAPH.getCurrentContext();
			
			if(context == noone && file_exists(PROJECT.path))
				txt = string_replace(filename_name(PROJECT.path), filename_ext(PROJECT.path), "");
			else if(context != noone)
				txt = context.name;
			
			draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
			draw_text_add(w / 2, ui(30), txt);
			
			var bx = w - ui(44);
			var by = ui(12);
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_inspector_set_default", "Set Metadata as default"), THEME.save, 0, COLORS._main_icon) == 2) {
				var path = DIRECTORY + "meta.json";
				json_save_struct(path, METADATA.serialize());
			}
			
			by += ui(36);
			if(STEAM_ENABLED && !workshop_uploading) {
				if(PROJECT.path == "") {
					buttonInstant(noone, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_inspector_workshop_save", "Save file before upload"), THEME.workshop_upload, 0, COLORS._main_icon, 0.5);
				} else {
					if(!METADATA.steam) { //project made locally
						if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_inspector_workshop_upload", "Upload to Steam Workshop"), THEME.workshop_upload, 0, COLORS._main_icon) == 2) {
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
						if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_inspector_workshop_update", "Update Steam Workshop"), THEME.workshop_update, 0, COLORS._main_icon) == 2) {
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
		
		contentPane.setFocusHover(pFOCUS, pHOVER);
		contentPane.draw(ui(16), top_bar_h, mx - ui(16), my - top_bar_h);
		
		if(!locked && PANEL_GRAPH.node_focus && inspecting != PANEL_GRAPH.node_focus)
			setInspecting(PANEL_GRAPH.node_focus);
	} #endregion
}