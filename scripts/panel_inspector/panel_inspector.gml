#region funtion calls
	function __fnInit_Inspector() {
		__registerFunction("inspector_copy_prop",				panel_inspector_copy_prop);
		__registerFunction("inspector_paste_prop",				panel_inspector_paste_prop);
		__registerFunction("inspector_toggle_animation",		panel_inspector_toggle_animation);
		
		__registerFunction("inspector_color_pick",				panel_inspector_color_pick);
	}
	
	function panel_inspector_copy_prop()				{ CALL("inspector_copy_prop");			PANEL_INSPECTOR.propSelectCopy();		}
	function panel_inspector_paste_prop()				{ CALL("inspector_paste_prop");			PANEL_INSPECTOR.propSelectPaste();		}
	function panel_inspector_toggle_animation()			{ CALL("inspector_toggle_animation");	PANEL_INSPECTOR.anim_toggling = true;	}
	
	function panel_inspector_color_pick()				{ CALL("inspector_color_pick");			if(!PREFERENCES.alt_picker) return; PANEL_INSPECTOR.color_picking = true;	}
#endregion

function Inspector_Custom_Renderer(drawFn, registerFn = noone) : widget() constructor { #region
	h = 64;
	self.draw = drawFn;
	
	if(registerFn != noone) register = registerFn;
	else {
		register = function(parent = noone) { 
			if(!interactable) return;
			self.parent = parent;
		}
	}
} #endregion

function Inspector_Sprite(spr) constructor { self.spr = spr; }

function Panel_Inspector() : PanelContent() constructor {
	#region ---- main ----
		title = __txt("Inspector");
		context_str = "Inspector";
		icon  = THEME.panel_inspector;
	
		w = ui(400);
		h = ui(640);
		min_w = ui(160);
	
		locked		 = false;
		inspecting	 = noone;
		inspectings  = [];
		inspectGroup = false;
		top_bar_h	 = ui(100);
		
		static initSize = function() {
			content_w = w - ui(32);
			content_h = h - top_bar_h - ui(12);
		}
		initSize();
		
		view_mode_tooltip = new tooltipSelector("View", [ "Compact", "Spacious" ])
	#endregion
	
	#region ---- properties ----
		prop_hover		= noone;
		prop_selecting  = noone;
		
		prop_highlight      = noone;
		prop_highlight_time = 0;
	
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
			[ __txtx("panel_globalvar", "Global variables"), true, button(function() { panelAdd("Panel_Globalvar", true); }, THEME.node_goto).setIcon(THEME.node_goto, 0, COLORS._main_icon) ], 
			[ __txt("Group Properties"), true ], 
		];
	#endregion
	
	#region ---- workshop ----
		workshop_uploading = false;
	#endregion
	
	#region ++++ hotkeys ++++
		addHotkey("Inspector", "Copy property",		"C",   MOD_KEY.ctrl,	panel_inspector_copy_prop);
		addHotkey("Inspector", "Paste property",	"V",   MOD_KEY.ctrl,	panel_inspector_paste_prop);
		addHotkey("Inspector", "Toggle animation",	"I",   MOD_KEY.none,	panel_inspector_toggle_animation);
		
		addHotkey("", "Color picker",				"",	   MOD_KEY.alt,		panel_inspector_color_pick);
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
		
		__dialog_junction = noone;
		menu_junc_reset_value	 = menuItem(__txtx("panel_inspector_reset", "Reset value"),						function() { __dialog_junction.resetValue();		});
		menu_junc_add_anim		 = menuItem(__txtx("panel_inspector_add", "Add animation"),						function() { __dialog_junction.setAnim(true);		});
		menu_junc_rem_anim		 = menuItem(__txtx("panel_inspector_remove", "Remove animation"),				function() { __dialog_junction.setAnim(false);		});
		menu_junc_combine_axis	 = menuItem(__txtx("panel_inspector_axis_combine", "Combine axis"),				function() { __dialog_junction.sep_axis = false;	});
		menu_junc_separate_axis	 = menuItem(__txtx("panel_inspector_axis_separate", "Separate axis"),			function() { __dialog_junction.sep_axis = true;		});
		menu_junc_expression_ena = menuItem(__txtx("panel_inspector_use_expression", "Use expression"),			function() { __dialog_junction.expUse = true;		});
		menu_junc_expression_dis = menuItem(__txtx("panel_inspector_disable_expression", "Disable expression"), function() { __dialog_junction.expUse = false;		});
		menu_junc_extract		 = menuItem(__txtx("panel_inspector_extract_single", "Extract to node"),		function() { __dialog_junction.extractNode();		});
		
		menu_junc_copy	= menuItem(__txt("Copy"),	function() { clipboard_set_text(__dialog_junction.getShowString()); },	THEME.copy,  ["Inspector", "Copy property"]);
		menu_junc_paste	= menuItem(__txt("Paste"),	function() { __dialog_junction.setString(clipboard_get_text()); },		THEME.paste, ["Inspector", "Paste property"]);
		
		function setSelectingItemColor(color) { 
			if(__dialog_junction == noone) return; 
			
			__dialog_junction.setColor(color);
			
			var _val_to = __dialog_junction.getJunctionTo();
			for( var i = 0, n = array_length(_val_to); i < n; i++ ) 
				_val_to[i].setColor(color);
		}
		
		var _clrs = COLORS.labels;
		var _item = array_create(array_length(_clrs));
	
		for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
			_item[i] = [ 
				[ THEME.timeline_color, i > 0, _clrs[i] ], 
				function(_data) { 
					setSelectingItemColor(_data.color);
				}, "", { color: i == 0? -1 : _clrs[i] }
			];
		}
	
		array_push(_item, [ 
			[ THEME.timeline_color, 2 ], 
			function(_data) { 
				colorSelectorCall(__dialog_junction? __dialog_junction.color : c_white, setSelectingItemColor);
			}
		]);
	
		menu_junc_color = menuItemGroup(__txt("Color"), _item);
		menu_junc_color.spacing = ui(24);
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
		var con_w  = contentPane.surface_w - ui(4);
		var _hover = pHOVER && contentPane.hover;
		
		var context = PANEL_GRAPH.getCurrentContext();
		var meta = context == noone? PROJECT.meta : context.metadata;
		if(meta == noone) return 0;
		current_meta = meta;
		
		var hh = ui(8);
		var yy = _y + ui(8);
		
		var rx = x + ui(16);
		var ry = y + top_bar_h;
		
		attribute_hovering = noone;
		
		for( var i = 0, n = array_length(meta_display); i < n; i++ ) {
			if(i == 3) {
				var context = PANEL_GRAPH.getCurrentContext();
				if(context == noone) continue;
			}
			
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
			
			switch(i) {
				case 0 :
					var _edt = PROJECT.attributeEditor;
					for( var j = 0; j < array_length(_edt); j++ ) {
						var title = _edt[j][0];
						var param = _edt[j][1];
						var editW = _edt[j][2];
						var drpFn = _edt[j][3];
					
						var widx = ui(8);
						var widy = yy;
						
						draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_inner);
						draw_text_add(ui(16), yy, __txt(title));
						yy += line_get_height() + ui(6);
						hh += line_get_height() + ui(6);
					
						editW.setFocusHover(pFOCUS, _hover);
						if(pFOCUS) editW.register(contentPane);
						
						var wh = 0;
						var _data  = PROJECT.attributes[$ param];
						var _param = new widgetParam(ui(16), yy, w - ui(16 + 48), TEXTBOX_HEIGHT, _data, {}, _m, rx, ry);
						
						wh = editW.drawParam(_param);
						
						var jun  = PANEL_GRAPH.value_dragging;
						var widw = con_w - ui(16);
						var widh = line_get_height() + ui(6) + wh + ui(4);
						
						if(jun != noone && _hover && point_in_rectangle(_m[0], _m[1], widx, widy, widx + widw, widy + widh)) {
							draw_sprite_stretched_ext(THEME.ui_panel_active, 0, widx, widy, widw, widh, COLORS._main_value_positive, 1);
							attribute_hovering = drpFn;
						}
						
						yy += wh + ui(8);
						hh += wh + ui(8);
					}
					break;
				case 1 :
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
					break;
				case 2 :
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
					break;
				case 3 :
					var context = PANEL_GRAPH.getCurrentContext();
					var _h = drawNodeProperties(yy, _m, context);
					
					yy += _h;
					hh += _h;
					break;
			}
			
			yy += ui(8);
			hh += ui(8);
		}
		
		return hh;
	} #endregion
	
	static highlightProp = function(prop) { #region
		prop_highlight      = prop;
		prop_highlight_time = 60;
	} #endregion
	
	static drawNodeProperties = function(_y, _m, _inspecting = inspecting) { #region
		var con_w  = contentPane.surface_w - ui(4); 
		var _hover = pHOVER && contentPane.hover;
		
		_inspecting.inspecting = true;
		prop_hover	= noone;
		var jun		= noone;
		var amoIn	= _inspecting.input_display_list == -1? ds_list_size(_inspecting.inputs) : array_length(_inspecting.input_display_list);
		var amoOut	= ds_list_size(_inspecting.outputs);
		var amo		= inspectGroup == 0? amoIn + 1 + amoOut : amoIn;
		var hh		= 0;
		
		//tb_prop_filter.register(contentPane);
		//tb_prop_filter.setFocusHover(pHOVER, pFOCUS);
		//tb_prop_filter.draw(ui(32), _y + ui(4), con_w - ui(64), ui(28), filter_text, _m);
		//draw_sprite_ui(THEME.search, 0, ui(32 + 16), _y + ui(4 + 14), 1, 1, 0, COLORS._main_icon, 1);
		
		var xc = con_w / 2;
		
		if(prop_page == 1) { #region attribute/settings editor
			hh += ui(8);
			var hg  = ui(32);
			var yy  = _y + hh;
			var wx1 = con_w - ui(8);
			var ww  = max(ui(180), con_w / 3);
			var wx0 = wx1 - ww;
			
			for( var i = 0, n = array_length(_inspecting.attributeEditors); i < n; i++ ) {
				var edt = _inspecting.attributeEditors[i];
				
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
				
				var _param = new widgetParam(wx0, yy, ww, hg, val, {}, _m, x + contentPane.x, y + contentPane.y);
				    _param.s = hg;
				edt[2].drawParam(_param);
				
				yy += hg + ui(8);
				hh += hg + ui(8);
			}
			return hh;
		} #endregion
		
		var color_picker_selecting = noone;
		var color_picker_index     = 0;
		var pickers = [];
		var _colsp  = false;
		
		for(var i = 0; i < amo; i++) {
			var yy = hh + _y;
			
			if(i < amoIn) { #region inputs
				if(_inspecting.input_display_list == -1) {
					jun = _inspecting.inputs[| i];
				} else {
					if(i >= array_length(_inspecting.input_display_list)) break;
					var jun_disp = _inspecting.input_display_list[i];
					if(is_instanceof(jun_disp, Inspector_Sprite)) {					// SPRITE
						var _spr = jun_disp.spr;
						var _sh  = sprite_get_height(_spr);
						
						draw_sprite(_spr, 0, xc, yy);
						
						hh += _sh + ui(8);
						continue;
						
					} if(is_array(jun_disp)) {										// LABEL
						var pad = i && _colsp == false? ui(4) : 0
						_colsp  = false;
						yy += pad;
						
						var txt  = __txt(jun_disp[0]);
						var coll = jun_disp[1] && filter_text == "";
						var lbh  = lineBreak? ui(32) : ui(26);
						var togl = array_safe_get(jun_disp, 2, noone);
						if(togl != noone) var toging = _inspecting.getInputData(togl);
						
						var lbx = (togl != noone) * ui(40);
						var lbw = con_w - lbx;
						var ltx = lbx + ui(32);
						
						if(_hover && point_in_rectangle(_m[0], _m[1], lbx, yy, con_w, yy + lbh)) {
							draw_sprite_stretched_ext(THEME.group_label, 0, lbx, yy, lbw, lbh, COLORS.panel_inspector_group_hover, 1);
						
							if(mouse_press(mb_left, pFOCUS))
								jun_disp[@ 1] = !coll;
							if(mouse_press(mb_right, pFOCUS))
								menuCall("inspector_group_menu",,, group_menu,, _inspecting);
						} else
							draw_sprite_stretched_ext(THEME.group_label, 0, lbx, yy, lbw, lbh, COLORS.panel_inspector_group_bg, 1);
					
						if(filter_text == "") 
							draw_sprite_ui(THEME.arrow, 0, lbx + ui(16), yy + lbh / 2, 1, 1, -90 + coll * 90, COLORS.panel_inspector_group_bg, 1);
						
						var cc, aa = 1;
						
						if(togl != noone) {
							if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, ui(32), yy + lbh)) {
								draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, ui(32), lbh, COLORS.panel_inspector_group_hover, 1);
								
								if(mouse_press(mb_left, pFOCUS))
									_inspecting.inputs[| togl].setValue(!toging);
							} else 
								draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, ui(32), lbh, COLORS.panel_inspector_group_bg, 1);
							
							cc = toging? COLORS._main_accent : COLORS.panel_inspector_group_bg;
							aa = 0.5 + toging * 0.5;
							
							draw_sprite_ui(THEME.inspector_checkbox, 0, ui(16), yy + lbh / 2, 1, 1, 0, cc, 1);
							if(toging) 
								draw_sprite_ui(THEME.inspector_checkbox, 1, ui(16), yy + lbh / 2, 1, 1, 0, cc, 1);
						}
						
						draw_set_alpha(aa);
						draw_set_text(lineBreak? f_p0 : f_p1, fa_left, fa_center, COLORS._main_text);
						draw_text_add(ltx, yy + lbh / 2, txt);
						draw_set_alpha(1);
						
						hh += lbh + ui(lineBreak? 8 : 6) + pad;
						
						if(coll) { // skip 
							_colsp   = true;
							var j    = i + 1;
							var _len = array_length(_inspecting.input_display_list);
							
							while(j < _len) {
								var j_jun = _inspecting.input_display_list[j];
								if(is_array(j_jun))
									break;
								j++;
							}
							
							i = j - 1;
						}
						
						continue;
						
					} else if(is_struct(jun_disp) && instanceof(jun_disp) == "Inspector_Custom_Renderer") {
						jun_disp.register(contentPane);
						jun_disp.rx = ui(16) + x;
						jun_disp.ry = top_bar_h + y;
						
						hh += jun_disp.draw(ui(6), yy, con_w - ui(12), _m, _hover, pFOCUS) + ui(8);
						continue;
					}
					jun = _inspecting.inputs[| _inspecting.input_display_list[i]];
				}
			#endregion
			} else if(i == amoIn) { #region output label
				hh += ui(8 + 32 + 8);
				
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy + ui(8), con_w, ui(32), COLORS.panel_inspector_output_label, 0.8);
				draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
				draw_text_add(xc, yy + ui(8 + 16), __txt("Outputs"));
				continue;
			#endregion
			} else { #region outputs
				var outInd = i - amoIn - 1;
				jun = _inspecting.outputs[| outInd];
			#endregion
			} 
			
			if(!is_struct(jun)) continue;
			if(instanceof(jun) != "NodeValue") continue;
			
			if(!jun.show_in_inspector || jun.type == VALUE_TYPE.object) continue;
			if(filter_text != "") {
				var pos = string_pos(filter_text, string_lower(jun.getName()));
				if(pos == 0) continue;
			}
			
			#region ++++ draw widget ++++
				var _font = lineBreak? f_p0 : f_p1;
				
				var lb_h = line_get_height(_font) + ui(8);
				var lb_w = line_get_width(jun.getName(), _font) + ui(16);
				var lb_x = ui(48) + (ui(24) * (jun.color != -1));
				var padd = ui(8);
			
				var _selY = yy;
				var lbHov = point_in_rectangle(_m[0], _m[1], lb_x, _selY, lb_x + lb_w, _selY + lb_h);
				if(lbHov) draw_sprite_stretched_ext(THEME.group_label, 0, lb_x, _selY + ui(2), lb_w, lb_h - ui(4), COLORS._main_icon_dark, 0.85);
				
				var widg    = drawWidget(ui(16), yy, contentPane.surface_w - ui(24), _m, jun, false, pHOVER && contentPane.hover, pFOCUS, contentPane, ui(16) + x, top_bar_h + y);
				var widH    = widg[0];
				var mbRight = widg[1];
				
				hh += lb_h + widH + padd;
			
				var _selY1 = yy + lb_h + widH + ui(2);
				var _selH  = _selY1 - _selY + (lineBreak * ui(4));
				
				if(jun == prop_highlight && prop_highlight_time) {
					if(prop_highlight_time == 60)
						contentPane.setScroll(_y - yy);
					var aa = min(1, prop_highlight_time / 30);
					draw_sprite_stretched_ext(THEME.ui_panel_active, 0, ui(4), yy, contentPane.surface_w - ui(4), _selH, COLORS._main_accent, aa);
				}
				
				if(_hover && lbHov && prop_dragging == noone && mouse_press(mb_left, pFOCUS)) {
					prop_dragging = jun;
						
					prop_sel_drag_x = mouse_mx;
		  			prop_sel_drag_y = mouse_my;
				}
			#endregion
			
			if(jun.connect_type == JUNCTION_CONNECT.input && jun.type == VALUE_TYPE.color && jun.display_type == VALUE_DISPLAY._default) { #region color picker
				pickers[color_picker_index] = jun;
				color_picker_index++;
			} #endregion
			
			if(_hover && point_in_rectangle(_m[0], _m[1], ui(4), _selY, contentPane.surface_w - ui(4), _selY + _selH)) { #region mouse in widget
				_HOVERING_ELEMENT = jun;
				
				var hov = PANEL_GRAPH.value_dragging != noone || (NODE_DROPPER_TARGET != noone && NODE_DROPPER_TARGET != jun);
				
				if(hov) {
					draw_sprite_stretched_ext(THEME.ui_panel_active, 0, ui(4), _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_value_positive, 1);
					if(mouse_press(mb_left, NODE_DROPPER_TARGET_CAN)) {
						NODE_DROPPER_TARGET.expression += $"{jun.node.internalName}.{jun.connect_type == JUNCTION_CONNECT.input? "inputs" : "outputs"}.{jun.internalName}";
						NODE_DROPPER_TARGET.expressionUpdate(); 
					}
				} else 
					draw_sprite_stretched_ext(THEME.prop_selecting, 0, ui(4), _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_accent, 1);
				
				if(anim_toggling) {
					jun.setAnim(!jun.is_anim);
					anim_toggling = false;
				}
				
				prop_hover = jun;
					
				if(mouse_press(mb_left, pFOCUS))
					prop_selecting = jun;
						
				if(mouse_press(mb_right, pFOCUS && mbRight)) { #region right click menu
					var _menuItem = [ menu_junc_color, -1 ];
					
					if(i < amoIn) {
						array_push(_menuItem, menu_junc_reset_value, jun.is_anim? menu_junc_rem_anim : menu_junc_add_anim);
						if(jun.sepable) array_push(_menuItem, jun.sep_axis? menu_junc_combine_axis : menu_junc_separate_axis);
						array_push(_menuItem, -1);
					}
					
					array_push(_menuItem, jun.expUse? menu_junc_expression_dis : menu_junc_expression_ena, -1, menu_junc_copy);
					if(jun.connect_type == JUNCTION_CONNECT.input)
						array_push(_menuItem, menu_junc_paste);
					
					if(jun.connect_type == JUNCTION_CONNECT.input && jun.extract_node != "") {
						if(is_array(jun.extract_node)) {
							var ext = menuItem(__txtx("panel_inspector_extract_multiple", "Extract to..."),	function(_dat) { 
								var arr = [];
								for(var i = 0; i < array_length(__dialog_junction.extract_node); i++)  {
									var _rec = __dialog_junction.extract_node[i];
									array_push(arr, menuItem(_rec, function(_dat) { __dialog_junction.extractNode(_dat.name); }));
								}
									
								return submenuCall(_dat, arr);
							}).setIsShelf();
							array_push(_menuItem, ext);
						} else
							array_push(_menuItem, menu_junc_extract);
					}
					
					var dia = menuCall("inspector_value_menu",,, _menuItem,, jun);
					__dialog_junction = jun;
				} #endregion
			} #endregion
		}
		
		#region color picker
			if(key_mod_press(ALT) && color_picker_index && textBox_slider.tb == noone) {
				pickers[picker_index].editWidget.onColorPick();
			}
			
			if(MESSAGE != noone && MESSAGE.type == "Color") {
				var inp = array_safe_get(pickers, picker_index, 0);
				if(is_struct(inp)) {
					inp.setValue(MESSAGE.data);
					MESSAGE = noone;
				}
			}
			
			color_picking = false;
		#endregion
		
		#region drag
			if(prop_dragging) {
				if(DRAGGING == noone && point_distance(prop_sel_drag_x, prop_sel_drag_y, mouse_mx, mouse_my) > 16) {
					prop_dragging.dragValue();
					prop_dragging = noone;
				}
				
				if(mouse_release(mb_left))
					prop_dragging = noone;
			}
		#endregion
		
		if(prop_highlight_time) {
			prop_highlight_time--;
			if(prop_highlight_time == 0)
				prop_highlight = noone;
		}
		
		return hh;
	} #endregion
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) { #region
		var con_w  = contentPane.surface_w - ui(4);
		
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		if(point_in_rectangle(_m[0], _m[1], 0, 0, con_w, content_h) && mouse_press(mb_left, pFOCUS))
			prop_selecting = noone;
		
		if(inspecting == noone) return drawMeta(_y, _m);
		
		prop_page_button.setFocusHover(pFOCUS, pHOVER);
		prop_page_button.draw(ui(32), _y + ui(4), contentPane.w - ui(76), ui(28), prop_page, _m, x + contentPane.x, y + contentPane.y);
		
		var _hh = ui(40);
		_y += _hh;
		
		if(inspectGroup >= 0) return drawNodeProperties(_y, _m, inspecting);
		
		for( var i = 0, n = min(10, array_length(inspectings)); i < n; i++ ) {
			if(i) {
				_y  += ui(8);
				_hh += ui(8);
			}
			
			if(n > 1) {
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, _y, con_w, ui(32), COLORS.panel_inspector_output_label, 0.9);
				draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
				
				var _tx = inspectings[i].getFullName();
				draw_text_add(con_w / 2, _y + ui(16), _tx);
				
				_y  += ui(32 + 8);
				_hh += ui(32 + 8);
			}
			
			var _h = drawNodeProperties(_y, _m, inspectings[i]);
			_y  += _h;
			_hh += _h;
		}
		
		return _hh;
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
		tb_node_name.font   = f_h5;
		tb_node_name.hide   = true;
		tb_node_name.align  = fa_center;
		tb_node_name.format = TEXT_AREA_FORMAT.node_title;
		tb_node_name.setFocusHover(pFOCUS, pHOVER);
		
		var txt = inspecting.renamed? inspecting.display_name : inspecting.name;
		     if(inspectGroup == 1)  txt = $"[{array_length(PANEL_GRAPH.nodes_selecting)}] {txt}"; 
		else if(inspectGroup == -1) txt = $"[{array_length(PANEL_GRAPH.nodes_selecting)}] Multiple nodes"; 
		
		tb_node_name.draw(ui(64), ui(14), w - ui(128), ui(32), txt, [mx, my]);
		
		if(inspectGroup >= 0) {
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(w / 2 + ui(8), ui(56), inspecting.name);
		
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_set_alpha(0.65);
			draw_text_add(w / 2, ui(76), inspecting.internalName);
			draw_set_alpha(1);
		}
		
		var bx = ui(8);
		var by = ui(12);
			
		if(inspectGroup == 0) {
			draw_set_font(f_p1);
			var lx = w / 2 - string_width(inspecting.name) / 2 - ui(10);
			var ly = ui(56 - 8);
			if(buttonInstant(THEME.button_hide, lx, ly, ui(16), ui(16), [mx, my], pFOCUS, pHOVER, __txt("Lock"), THEME.lock, !locked, locked? COLORS._main_icon_light : COLORS._main_icon,, 0.5) == 2)
				locked = !locked;
		
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txt("Presets"), THEME.preset, 1) == 2)
				dialogCall(o_dialog_preset, x + bx, y + by + ui(36), { "node": inspecting });
		} else {
			draw_sprite_ui_uniform(THEME.preset, 1, bx + ui(32) / 2, by + ui(32) / 2, 1, COLORS._main_icon_dark);
		}
		
		by += ui(36);
		view_mode_tooltip.index = lineBreak;
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, view_mode_tooltip, THEME.inspector_view, lineBreak) == 2) {
			lineBreak = !lineBreak;
			PREFERENCES.inspector_view_default = lineBreak;
		}
		
		//////////////////////////////////////////////////////////////////// INSPECTOR ACTIONS ////////////////////////////////////////////////////////////////////
		
		var bx = w - ui(44);
		var by = ui(12);
		
		if(inspecting.hasInspector1Update(true)) {
			var icon = inspecting.insp1UpdateIcon;
			var ac = inspecting.insp1UpdateActive;
			var cc = ac? icon[2] : COLORS._main_icon_dark;
			var tt = inspecting.insp1UpdateTooltip;
			if(inspectGroup) tt += " [All]";
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS && ac, pHOVER && ac, tt, icon[0], icon[1], cc) == 2) {
				if(inspectGroup == 1) {
					for( var i = 0, n = array_length(inspectings); i < n; i++ ) inspectings[i].inspector1Update();
				} else 
					inspecting.inspector1Update();
			}
		} else 
			draw_sprite_ui(THEME.sequence_control, 1, bx + ui(16), by + ui(16),,,, COLORS._main_icon_dark);
		
		if(inspecting.hasInspector2Update()) {
			by += ui(36);
			var icon = inspecting.insp2UpdateIcon;
			var ac = inspecting.insp2UpdateActive;
			var cc = ac? icon[2] : COLORS._main_icon_dark;
			var tt = inspecting.insp2UpdateTooltip;
			if(inspectGroup) tt += " [All]";
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS && ac, pHOVER && ac, tt, icon[0], icon[1], cc) = 2) {
				if(inspectGroup) {
					for( var i = 0, n = array_length(inspectings); i < n; i++ ) inspectings[i].inspector2Update();
				} else 
					inspecting.inspector2Update();
			}
		}
	} #endregion
	
	function drawContent(panel) { #region					>>>>>>>>>>>>>>>>>>>> MAIN DRAW <<<<<<<<<<<<<<<<<<<<
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), top_bar_h - ui(8), w - ui(16), h - top_bar_h);
		
		if(inspecting && !inspecting.active)
			inspecting = noone;
		
		if(inspecting) {
			var _ins     = instanceof(inspecting);
			var _nodes   = PANEL_GRAPH.nodes_selecting;
			
			inspectGroup = array_length(_nodes) > 1;
			inspectings  = array_empty(_nodes)? [ inspecting ] : _nodes;
			
			for( var i = 0, n = array_length(_nodes); i < n; i++ )
				if(instanceof(_nodes[i]) != _ins) { inspectGroup = -1; break; }
			
			title = inspecting.renamed? inspecting.display_name : inspecting.name;
			inspecting.inspectorStep();
			drawInspectingNode();
		} else {
			title = __txt("Inspector");
			
			var txt = "Untitled";
			var context = PANEL_GRAPH.getCurrentContext();
			
			if(context == noone && file_exists_empty(PROJECT.path))
				txt = string_replace(filename_name(PROJECT.path), filename_ext(PROJECT.path), "");
			else if(context != noone)
				txt = context.name;
			
			draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
			draw_text_add(w / 2, ui(30), txt);
			
			if(PROJECT.meta.steam == FILE_STEAM_TYPE.steamOpen) {
				var _tw = string_width(txt) / 2;
				draw_sprite_ui(THEME.steam, 0, w / 2 - _tw - ui(16), ui(32),,,, COLORS._main_icon);
			}
			
			var bx = w - ui(44);
			var by = ui(12);
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_inspector_set_default", "Set Metadata as default"), THEME.save, 0, COLORS._main_icon) == 2) {
				var path = DIRECTORY + "meta.json";
				json_save_struct(path, PROJECT.meta.serialize());
			}
			
			by += ui(36);
			if(STEAM_ENABLED && !workshop_uploading) {
				if(PROJECT.path == "") {
					buttonInstant(noone, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_inspector_workshop_save", "Save file before upload"), THEME.workshop_upload, 0, COLORS._main_icon, 0.5);
				} else {
					if(PROJECT.meta.steam == FILE_STEAM_TYPE.local) { //project made locally
						if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_inspector_workshop_upload", "Upload to Steam Workshop"), THEME.workshop_upload, 0, COLORS._main_icon) == 2) {
							var s = PANEL_PREVIEW.getNodePreviewSurface();
							if(is_surface(s)) {
								PROJECT.meta.author_steam_id = STEAM_USER_ID;
								PROJECT.meta.steam = FILE_STEAM_TYPE.steamUpload;
								SAVE_AT(PROJECT, PROJECT.path);
								
								steam_ugc_create_project();
								workshop_uploading = true;
							} else 
								noti_warning("Please send any node to preview panel to use as a thumbnail.")
						}
					}
					
					if(PROJECT.meta.steam && PROJECT.meta.author_steam_id == STEAM_USER_ID) {
						if(PROJECT.meta.steam == FILE_STEAM_TYPE.steamUpload) {
							buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], false, pHOVER, __txtx("panel_inspector_workshop_restart", "Open project from the workshop tab to update."), THEME.workshop_update, 0, COLORS._main_icon);
						} else if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_inspector_workshop_update", "Update Steam Workshop content"), THEME.workshop_update, 0, COLORS._main_icon) == 2) {
							SAVE_AT(PROJECT, PROJECT.path);
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
		
		if(!locked && PANEL_GRAPH.getFocusingNode() && inspecting != PANEL_GRAPH.getFocusingNode())
			setInspecting(PANEL_GRAPH.getFocusingNode());
	} #endregion
}