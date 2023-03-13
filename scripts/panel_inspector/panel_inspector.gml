function Inspector_Custom_Renderer(draw) : widget() constructor {
	h = 64;
	self.draw = draw;
}

function Panel_Inspector() : PanelContent() constructor {
	title = "Inspector";
	context_str = "Inspector";
	
	locked		= false;
	inspecting	= noone;
	top_bar_h	= ui(96);
	
	prop_hover = noone;
	prop_selecting = noone;
	
	function initSize() {
		content_w = w - ui(28);
		content_h = h - top_bar_h - ui(12);
	}
	initSize();
	
	keyframe_dragging = noone;
	keyframe_drag_st  = 0;
	
	anim_toggling = false;
	anim_hold     = noone;
	visi_hold     = noone;
	
	min_w = ui(160);
	lineBreak = true;
	
	tb_node_name	= new textBox(TEXTBOX_INPUT.text, function(txt) {
		if(inspecting) inspecting.display_name = txt;
	})
	
	tb_prop_filter	= new textBox(TEXTBOX_INPUT.text, function(txt) {
		filter_text = txt;
	})
	tb_prop_filter.no_empty		= false;
	tb_prop_filter.auto_update	= true;
	tb_prop_filter.font			= f_p0;
	tb_prop_filter.color		= COLORS._main_text_sub;
	tb_prop_filter.align		= fa_center;
	tb_prop_filter.hide			= true;
	filter_text = "";
	
	current_meta = -1;
	meta_tb[0] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.description	= str; });	
	meta_tb[1] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.author		= str; });
	meta_tb[2] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.contact		= str; });
	meta_tb[3] = new textArea(TEXTBOX_INPUT.text, function(str) { current_meta.alias		= str; });
	meta_tb[4] = new textArrayBox(noone, META_TAGS);
	for( var i = 0; i < array_length(meta_tb); i++ )
		meta_tb[i].hide = true;
	
	meta_display = [ [ "Metadata", false ], [ "Global variables", false ] ];
	
	var_editing = false;
	
	workshop_uploading = false;
	
	addHotkey("Inspector", "Copy property",		"C",   MOD_KEY.ctrl,	function() { propSelectCopy(); });
	addHotkey("Inspector", "Paste property",	"V",   MOD_KEY.ctrl,	function() { propSelectPaste(); });
	addHotkey("Inspector", "Toggle animation",	"I",   MOD_KEY.none,	function() { anim_toggling = true; });
	
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
			if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, con_w, yy + ui(32))) {
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, con_w, ui(32), COLORS.panel_inspector_group_hover, 1);
						
				if(mouse_press(mb_left, pFOCUS))
					meta_display[i][1] = !meta_display[i][1];
			} else
				draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, con_w, ui(32), COLORS.panel_inspector_group_bg, 1);
			
			draw_sprite_ui(THEME.arrow, meta_display[i][1]? 0 : 3, ui(16), yy + ui(32) / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);	
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(32), yy + ui(32) / 2, meta_display[i][0]);
			
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
					yy += line_height() + ui(6);
					hh += line_height() + ui(6);
				
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
				var lb_h    = line_height(f_p0) + ui(8);
				var padd    = ui(8);
				
				if(var_editing) {
					var del = noone;
					yy += ui(8);
					hh += ui(8);
					
					for( var j = 0; j < ds_list_size(GLOBAL.inputs); j++ ) {
						var _inpu = GLOBAL.inputs[| j];
						var _edit = _inpu.editor;
						var wd_x  = ui(16);
						var wd_w  = w - ui(16 + 48);
						var wd_h  = ui(32);
						
						if(j) {
							draw_set_color(merge_color(c_black, COLORS.panel_toolbar_separator, 0.75));
							draw_line_round(wd_x + ui(8), yy, wd_x + wd_w - ui(16), yy, 4);
							
							yy += ui(10);
							hh += ui(10);
						}
						
						_edit.tb_name.setActiveFocus(pFOCUS, _hover);
						_edit.sc_type.setActiveFocus(pFOCUS, _hover);
						_edit.sc_disp.setActiveFocus(pFOCUS, _hover);
						
						_edit.tb_name.draw(wd_x, yy, wd_w - ui(36), wd_h, _inpu.name, _m, TEXTBOX_INPUT.text);
						if(buttonInstant(THEME.button_hide, wd_w - ui(16), yy + ui(2), ui(32), ui(32), _m, pFOCUS, _hover,, THEME.icon_delete,, COLORS._main_value_negative) == 2) 
							del = j;
						yy += wd_h + ui(8);
						hh += wd_h + ui(8);
						
						_edit.sc_type.draw(wd_x, yy, wd_w / 2 - ui(2), wd_h, _edit.val_type_name[_edit.type_index], _m, ui(16) + x, top_bar_h + y);
						_edit.sc_disp.draw(wd_x + wd_w / 2 + ui(2), yy, wd_w / 2 - ui(2), wd_h, _edit.sc_disp.data_list[_edit.disp_index], _m, ui(16) + x, top_bar_h + y);
						
						yy += wd_h + ui(4);
						hh += wd_h + ui(4);
						
						var wd_h = _inpu.editor.draw(wd_x, yy, wd_w, _m, pFOCUS, _hover);
						
						yy += wd_h + ui(4);
						hh += wd_h + ui(4);
					}
					
					if(del != noone)
						ds_list_delete(GLOBAL.inputs, del);
				} else {
					for( var j = 0; j < ds_list_size(GLOBAL.inputs); j++ ) {
						var widg    = drawWidget(yy, _m, GLOBAL.inputs[| j], true);
						var widH    = widg[0];
						var mbRight = widg[1];
						
						yy += lb_h + widH + padd;
						hh += lb_h + widH + padd;
					}
				}
				
				var bh = ui(36);
				var bx = ui(4);
				var by = yy + ui(8);
				
				if(var_editing) {
					var bw = (con_w - ui(8)) / 2 - ui(4);
					
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
					var bw = con_w - ui(8);
					
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
	
	static drawWidget = function(yy, _m, jun, global_var = true) {
		var con_w	= contentPane.surface_w - ui(4);
		var _hover	= pHOVER && contentPane.hover;
		var xc		= con_w / 2;
		
		var lb_h = line_height(f_p0) + ui(8);
		var lb_y = yy + lb_h / 2;
			
		var butx = ui(16);
		if(jun.connect_type == JUNCTION_CONNECT.input && jun.isAnimable() && !jun.global_use && !global_var) {
			var index = jun.value_from == noone? jun.animator.is_anim : 2;
			draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, 1,, 0.8);
			if(_hover && point_in_circle(_m[0], _m[1], butx, lb_y, ui(10))) {
				if(anim_hold != noone)
					jun.animator.is_anim = anim_hold;
				
				draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, 1,, 1);
				TOOLTIP = jun.value_from == noone? get_text("panel_inspector_toggle_anim", "Toggle animation") : get_text("panel_inspector_remove_link", "Remove link");
					
				if(mouse_press(mb_left, pFOCUS)) {
					if(jun.value_from != noone)
						jun.removeFrom();
					else {
						recordAction(ACTION_TYPE.var_modify, jun.animator, [ jun.animator.is_anim, "is_anim", jun.name + " animation" ]);
						jun.animator.is_anim = !jun.animator.is_anim;
						anim_hold = jun.animator.is_anim;
					}
					PANEL_ANIMATION.updatePropertyList();
				}
			}
		}
		
		if(anim_hold != noone && mouse_release(mb_left))
			anim_hold = noone;
		
		butx += ui(20);
		if(!global_var) {			
			if(jun.global_use) {
				draw_sprite_ui_uniform(THEME.node_use_global, GLOBAL.inputGetable(jun, jun.global_key)? 0 : 2, butx, lb_y, 1,, 0.8);
			} else {
				index = jun.visible;
				draw_sprite_ui_uniform(THEME.junc_visible, index, butx, lb_y, 1,, 0.8);
				if(_hover && point_in_circle(_m[0], _m[1], butx, lb_y, ui(10))) {
					if(visi_hold != noone)
						jun.visible = visi_hold;
					
					draw_sprite_ui_uniform(THEME.junc_visible, index, butx, lb_y, 1,, 1);
					TOOLTIP = get_text("visibility", "Visibility");
				
					if(mouse_press(mb_left, pFOCUS)) {
						jun.visible = !jun.visible;
						visi_hold = jun.visible;
					}
				}
			}
		} else
			draw_sprite_ui_uniform(THEME.node_use_global, 0, butx, lb_y, 1,, 0.8);
		
		if(visi_hold != noone && mouse_release(mb_left))
			visi_hold = noone;
		
		var cc = COLORS._main_text;
		if(jun.global_use)
			cc = GLOBAL.inputGetable(jun, jun.global_key)? COLORS._main_value_positive : COLORS._main_value_negative;
		
		draw_set_text(f_p0, fa_left, fa_center, cc);
		draw_text_over(ui(56), lb_y - ui(2), jun.name);
		var lb_w = string_width(jun.name) + ui(32);
			
		#region tooltip
			if(jun.tooltip != "") {
				var tx = ui(56) + string_width(jun.name) + ui(16);
				var ty = lb_y - ui(1);
					
				if(point_in_circle(_m[0], _m[1], tx, ty, ui(10))) {
					if(is_string(jun.tooltip))
						TOOLTIP = jun.tooltip;
					else if(mouse_click(mb_left, pFOCUS))
						dialogCall(jun.tooltip);
					draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 1);
				} else 
					draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 0.75);
			}
		#endregion
			
		#region anim
			if(jun.connect_type == JUNCTION_CONNECT.input && lineBreak && jun.animator.is_anim && !global_var) {
				var bx = w - ui(64);
				var by = lb_y;
				if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, _hover, "", THEME.prop_keyframe, 2) == 2) {
					for(var j = 0; j < ds_list_size(jun.animator.values); j++) {
						var _key = jun.animator.values[| j];
						if(_key.time > ANIMATOR.current_frame) {
							ANIMATOR.setFrame(_key.time);
							break;
						}
					}
				}
						
				bx -= ui(26);
				var cc = COLORS.panel_animation_keyframe_unselected;
				var kfFocus = false;
				for(var j = 0; j < ds_list_size(jun.animator.values); j++) {
					if(jun.animator.values[| j].time == ANIMATOR.current_frame) {
						cc = COLORS.panel_animation_keyframe_selected;
						kfFocus = true;
						break;
					}
				}
						
				if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, _hover, kfFocus? get_text("panel_inspector_remove_key", "Remove keyframe") : 
					get_text("panel_inspector_add_key", "Add keyframe"), THEME.prop_keyframe, 1, cc) == 2) {
					var _add = false;
					for(var j = 0; j < ds_list_size(jun.animator.values); j++) {
						var _key = jun.animator.values[| j];
						if(_key.time == ANIMATOR.current_frame) {
							if(ds_list_size(jun.animator.values) > 1)
								ds_list_delete(jun.animator.values, j);
							_add = true;
							break;
						} else if(_key.time > ANIMATOR.current_frame) {
							ds_list_insert(jun.animator.values, j, new valueKey(ANIMATOR.current_frame, jun.showValue(), jun.animator));
							_add = true;
							break;	
						}
					}
					if(!_add) ds_list_add(jun.animator.values, new valueKey(ANIMATOR.current_frame, jun.showValue(), jun.animator));
				}
						
				bx -= ui(26);
				if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, _hover, "", THEME.prop_keyframe, 0) == 2) {
					var _t = -1;
					for(var j = 0; j < ds_list_size(jun.animator.values); j++) {
						var _key = jun.animator.values[| j];
						if(_key.time < ANIMATOR.current_frame) {
							_t = _key.time;
						}
					}
					if(_t > -1) ANIMATOR.setFrame(_t);
				}
						
				var lhf = lb_h / 2 - 4;
				draw_set_color(COLORS.panel_inspector_key_separator);
				draw_line(bx - ui(20), by - lhf, bx - ui(20), by + lhf);
					
				draw_set_color(COLORS.panel_inspector_key_separator);
				draw_line(bx - ui(20), by - lhf, bx - ui(20), by + lhf);
					
				bx -= ui(26 + 12);
				if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, _hover, get_text("panel_animation_looping_mode", "Looping mode") + " " + ON_END_NAME[jun.on_end], THEME.prop_on_end, jun.on_end) == 2)
					jun.on_end = safe_mod(jun.on_end + 1, sprite_get_number(THEME.prop_on_end));
			}
		#endregion
		
		#region use global
			if(jun.connect_type == JUNCTION_CONNECT.input && lineBreak && !jun.animator.is_anim && !global_var) {
				var bx = w - ui(64);
				var by = lb_y;
				var ic_b = jun.global_use? c_white : COLORS._main_icon;
				if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, _hover, "Use global variable", THEME.node_use_global, jun.global_use, ic_b) == 2) {
					jun.global_use = !jun.global_use;
				}
			}
		#endregion
		
		var _hsy = yy + lb_h;
		var padd = ui(8);
			
		var labelWidth = max(lb_w, min(ui(80) + w * 0.2, ui(200)));
		var editBoxW   = w - ui(16 + 48) - !lineBreak * labelWidth;
		var editBoxH   = lineBreak? TEXTBOX_HEIGHT : lb_h;
		var editBoxX   = ui(16)	+ !lineBreak * labelWidth;
		var editBoxY   = lineBreak? _hsy : yy;
			
		var widH	   = lineBreak? editBoxH : 0;
		var mbRight	   = true;
		
		if(jun.global_use) {
			jun.global_edit.boxColor = GLOBAL.inputGetable(jun, jun.global_key)? COLORS._main_value_positive : COLORS._main_value_negative;
			jun.global_edit.setActiveFocus(pFOCUS, _hover);
			jun.global_edit.setInteract(jun.value_from == noone);
			if(pFOCUS) jun.global_edit.register(contentPane);
			
			var wd_h = jun.global_edit.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.global_key, _m);
			widH = lineBreak? wd_h : 0;
		} else if(jun.editWidget) {
			jun.editWidget.setActiveFocus(pFOCUS, _hover);
			
			if(jun.connect_type == JUNCTION_CONNECT.input) {
				jun.editWidget.setInteract(jun.value_from == noone);
				if(pFOCUS) jun.editWidget.register(contentPane);
			} else {
				jun.editWidget.setInteract(false);
			}
			
			switch(jun.display_type) {
				case VALUE_DISPLAY.button :
					jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, _m);
					break;
				default :
					switch(jun.type) {
						case VALUE_TYPE.integer :
						case VALUE_TYPE.float :
							switch(jun.display_type) {
								case VALUE_DISPLAY._default :
								case VALUE_DISPLAY.range :
								case VALUE_DISPLAY.vector :
									jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
									break;
								case VALUE_DISPLAY.vector_range :
									var ebH = jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
									widH = lineBreak? ebH : ebH - lb_h;
									break;
								case VALUE_DISPLAY.enum_scroll :
									jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, array_safe_get(jun.display_data, jun.showValue()), _m, ui(16) + x, top_bar_h + y);
									break;
								case VALUE_DISPLAY.enum_button :
									jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m, ui(16) + x, top_bar_h + y);
									break;
								case VALUE_DISPLAY.padding :
									jun.editWidget.draw(xc, _hsy + ui(32), jun.showValue(), _m);
									widH = ui(192);
									break;
								case VALUE_DISPLAY.rotation :
								case VALUE_DISPLAY.rotation_range :
									jun.editWidget.draw(xc, _hsy, jun.showValue(), _m);
									widH = ui(96);
									break;
								case VALUE_DISPLAY.slider :
								case VALUE_DISPLAY.slider_range :
									jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
									break;
								case VALUE_DISPLAY.area :
									jun.editWidget.draw(xc, _hsy + ui(40), jun.showValue(), jun.extra_data, _m);
									widH = ui(204);
									break;
								case VALUE_DISPLAY.puppet_control :
									widH = jun.editWidget.draw(editBoxX, editBoxY, editBoxW, jun.showValue(), _m, ui(16) + x, top_bar_h + y);
									break;
								case VALUE_DISPLAY.kernel :
									var ebH = jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
									widH = lineBreak? ebH : ebH - lb_h;
									break;
							}
							break;
						case VALUE_TYPE.boolean :
							editBoxX = lineBreak? editBoxX : (labelWidth + con_w) / 2;
							jun.editWidget.draw(editBoxX, editBoxY, jun.showValue(), _m, editBoxH);
							break;
						case VALUE_TYPE.color :
							switch(jun.display_type) {
								case VALUE_DISPLAY.gradient :
									jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
									break;
								default :
									jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
									break;
							}
							break;
						case VALUE_TYPE.path :
							switch(jun.display_type) {
								case VALUE_DISPLAY.path_load :
								case VALUE_DISPLAY.path_save :
								case VALUE_DISPLAY.path_array :
									jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
									break;
								case VALUE_DISPLAY.path_font :
									var val = jun.showValue();
									if(file_exists(val))
										val = filename_name(val);
									jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, val, _m, ui(16) + x, top_bar_h + y);
									break;
							}
							break;
						case VALUE_TYPE.surface :
							editBoxH = ui(96);
							jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m, ui(16) + x, top_bar_h + y);
							widH = lineBreak? editBoxH : editBoxH - lb_h;
							break;
						case VALUE_TYPE.curve :
							editBoxH = ui(160);
							jun.editWidget.draw(ui(32), _hsy, w - ui(80), editBoxH, jun.showValue(), _m);
							if(point_in_rectangle(_m[0], _m[1], ui(32), _hsy, ui(32) + w - ui(80), _hsy + editBoxH))
								mbRight = false;
							widH = editBoxH;
							break;
						case VALUE_TYPE.text : 
							var _hh = 0;
							switch(instanceof(jun.editWidget)) {
								case "textBox":
									_hh = jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m, jun.display_type);
									break;
								case "textArea":
									_hh = jun.editWidget.draw(ui(16), _hsy, w - ui(16 + 48), editBoxH, jun.showValue(), _m, jun.display_type);
									break;
								case "textArrayBox":
									_hh = jun.editWidget.draw(ui(16), editBoxY, editBoxW, editBoxH, _m, ui(16) + x, top_bar_h + y);
									break;
							}
							
							widH = _hh;
							break;
					}
			}
		} else if(jun.display_type == VALUE_DISPLAY.label) {
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_over(ui(32), _hsy, jun.display_data);
				
			widH = string_height(jun.display_data);
		} else
			widH = 0;
			
		if(false) {
			var __hsy = yy;
			draw_set_alpha(0.5);
			draw_set_color(c_aqua);
			draw_rectangle(ui(8), __hsy, contentPane.w - ui(16), __hsy + lb_h, 0);	__hsy += lb_h;
			draw_set_color(c_red);
			draw_rectangle(ui(8), __hsy, contentPane.w - ui(16), __hsy + widH, 0);	__hsy += widH;
			draw_set_color(c_lime);
			draw_rectangle(ui(8), __hsy, contentPane.w - ui(16), __hsy + padd, 0);
			draw_set_alpha(1);
		}
		
		return [ widH, mbRight ];
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
		prop_hover = noone;
		var jun = noone;
		var amoIn  = inspecting.input_display_list == -1? ds_list_size(inspecting.inputs) : array_length(inspecting.input_display_list);
		var amoOut = ds_list_size(inspecting.outputs);
		var amo    = amoIn + 1 + amoOut;
		var hh = ui(40);
		
		tb_prop_filter.register(contentPane);
		tb_prop_filter.active = pFOCUS;
		tb_prop_filter.hover  = pHOVER;
		tb_prop_filter.draw(ui(32), _y + ui(4), con_w - ui(64), ui(28), filter_text, _m);
		draw_sprite_ui(THEME.search, 0, ui(32 + 16), _y + ui(4 + 14), 1, 1, 0, COLORS._main_icon, 1);
		
		var xc = con_w / 2;
		
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
								menuCall(, , group_menu);
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
			
			var lb_h    = line_height(f_p0) + ui(8);
			var padd    = ui(8);
			
			var widg    = drawWidget(yy, _m, jun, false);
			var widH    = widg[0];
			var mbRight = widg[1];
			
			hh += lb_h + widH + padd;
			
			var _selY  = yy - ui(0);
			var _selY1 = yy + lb_h + widH + ui(2);
			var _selH  = _selY1 - _selY;
			
			if(_hover && point_in_rectangle(_m[0], _m[1], 4, _selY, contentPane.surface_w - ui(4), _selY + _selH)) {
				draw_sprite_stretched_ext(THEME.prop_selecting, 0, 4, _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_accent, 1);
				if(anim_toggling) {
					jun.animator.is_anim = !jun.animator.is_anim;
					PANEL_ANIMATION.updatePropertyList();
					anim_toggling = false;
				}
				
				prop_hover = jun;
					
				if(mouse_press(mb_left, pFOCUS))
					prop_selecting = jun;
						
				if(mouse_press(mb_right, pFOCUS && mbRight)) {
					var _menuItem = [];
					
					if(i < amoIn) {
						array_push(_menuItem, menuItem(get_text("panel_inspector_reset", "Reset value"), function() { 
								__dialog_junction.setValue(__dialog_junction.def_val);
								}),
							menuItem(jun.animator.is_anim? get_text("panel_inspector_remove", "Remove animation") : get_text("panel_inspector_add", "Add animation"), function() { 
								__dialog_junction.animator.is_anim = !__dialog_junction.animator.is_anim; 
								PANEL_ANIMATION.updatePropertyList();
								}),
							-1,
						);
					}
						
					array_push(_menuItem, 
						menuItem(get_text("use_global_var", "Use global variable"), function() {
							__dialog_junction.global_use = !__dialog_junction.global_use;
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
					
					var dia = menuCall(,, _menuItem);
					__dialog_junction = jun;
				}
			}
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
		tb_node_name.active = pFOCUS;
		tb_node_name.hover  = pHOVER;
		tb_node_name.align = fa_center;
		var txt = inspecting.display_name == ""? inspecting.name : inspecting.display_name;
		tb_node_name.draw(ui(64), ui(14), w - ui(128), ui(32), txt, [mx, my], VALUE_DISPLAY.node_title);
		
		draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
		draw_text(w / 2, ui(56), inspecting.name);
		
		var lx = w / 2 - string_width(inspecting.name) / 2 - ui(18);
		var ly = ui(56 - 8);
		if(buttonInstant(THEME.button_hide, lx, ly, ui(16), ui(16), [mx, my], pFOCUS, pHOVER, "Lock", THEME.lock, !locked, locked? COLORS._main_icon_light : COLORS._main_icon,, 0.5) == 2)
			locked = !locked;
		
		var bx = ui(8);
		var by = ui(12);
			
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("presets", "Presets"), THEME.preset, 1) == 2)
			dialogCall(o_dialog_preset, x + bx, y + by + ui(36), { "node": inspecting });
		
		by += ui(36);
		if(struct_has(inspecting, "array_process")) {
			var txt = get_text("panel_inspector_array_processor", "Array processor: ");
			switch(inspecting.array_process) {
				case ARRAY_PROCESS.loop :		txt += "Loop"			break;
				case ARRAY_PROCESS.hold :		txt += "Hold"			break;
				case ARRAY_PROCESS.expand :		txt += "Expand"			break;
				case ARRAY_PROCESS.expand_inv : txt += "Expand inverse" break;
			}
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, txt, THEME.icon_array_processor, inspecting.array_process) == 2) {
				menuCall(x + bx, y + by + ui(36), [
					menuItem("Loop",			function(){ inspecting.array_process = ARRAY_PROCESS.loop;		 UPDATE |= RENDER_TYPE.full; }),
					menuItem("Hold",			function(){ inspecting.array_process = ARRAY_PROCESS.hold;		 UPDATE |= RENDER_TYPE.full; }),
					menuItem("Expand",			function(){ inspecting.array_process = ARRAY_PROCESS.expand;	 UPDATE |= RENDER_TYPE.full; }),
					menuItem("Expand inverse",  function(){ inspecting.array_process = ARRAY_PROCESS.expand_inv; UPDATE |= RENDER_TYPE.full; }),
				]);
			}
		} else if(ds_map_exists(inspecting.attributes, "Separator")) {
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Input management", THEME.view_group, 1) == 2) {
				var dia = dialogCall(o_dialog_group_input_order, x + bx, y + by + ui(36));
				dia.node = inspecting;
			}
		}
		
		var bx = w - ui(44);
		var by = ui(12);
		
		if(inspecting.hasInspectorUpdate(true)) {
			var icon = inspecting.inspUpdateIcon;
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, inspecting.inspUpdateTooltip, icon[0], icon[1], icon[2]) == 2)
				inspecting.inspectorUpdate();
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
		draw_clear(COLORS.panel_bg_clear);
		lineBreak = w < PREF_MAP[? "inspector_line_break_width"];
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), top_bar_h - ui(8), w - ui(16), h - top_bar_h);
		
		if(inspecting)
			drawInspectingNode();
		else {
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
					if(!METADATA.steam) {
						if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_inspector_workshop_upload", "Upload to Steam Workshop"), THEME.workshop_upload, 0, COLORS._main_icon) == 2) {
							METADATA.author_steam_id = STEAM_USER_ID;
							SAVE();
							steam_ugc_create_project();
							workshop_uploading = true;
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
		
		contentPane.active = pHOVER;
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