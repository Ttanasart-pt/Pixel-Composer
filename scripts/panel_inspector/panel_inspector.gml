function Inspector_Custom_Renderer(draw) constructor {
	h = 64;
	self.draw = draw;
}

function Panel_Inspector() : PanelContent() constructor {
	context_str = "Inspector";
	
	inspecting = noone;
	top_bar_h  = ui(64);
	
	prop_hover = noone;
	prop_selecting = noone;
	
	function initSize() {
		content_w = w - ui(32);
		content_h = h - top_bar_h - ui(24);
	}
	initSize();
	
	keyframe_dragging = noone;
	keyframe_drag_st  = 0;
	
	min_w = ui(160);
	lineBreak = true;
	
	tb_node_name	= new textBox(TEXTBOX_INPUT.text, function(txt) {
		if(inspecting) inspecting.name = txt;
	})
	
	addHotkey("Inspector", "Copy property",		"C",   MOD_KEY.ctrl,	function() { propSelectCopy(); });
	addHotkey("Inspector", "Paste property",	"V",   MOD_KEY.ctrl,	function() { propSelectPaste(); });
	
	function onResize() {
		content_w = w - ui(32);
		content_h = h - top_bar_h - ui(24);
		contentPane.resize(content_w, content_h);
	}
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		var con_w = contentPane.surface_w;
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		if(pFOCUS) 
			if(point_in_rectangle(_m[0], _m[1], 0, 0, con_w, content_h) && mouse_check_button_pressed(mb_left))
				prop_selecting = noone;
		
		if(inspecting == noone) 
			return 0;
		
		inspecting.inspecting = true;
		prop_hover = noone;
		var jun;
		var amo = inspecting.input_display_list == -1? ds_list_size(inspecting.inputs) : array_length(inspecting.input_display_list);
		var hh = ui(8);
		
		for(var i = 0; i < amo; i++) {
			var xc = con_w / 2;
			var yy = hh + _y;
			
			if(inspecting.input_display_list == -1) {
				jun = inspecting.inputs[| i];
			} else {
				var jun_disp = inspecting.input_display_list[i];
				if(is_array(jun_disp)) {
					var txt  = jun_disp[0];
					var coll = jun_disp[1];
					
					if(pHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, con_w, yy + ui(32))) {
						draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, con_w, ui(32), COLORS.panel_inspector_group_hover, 1);
						
						if(pFOCUS && mouse_check_button_pressed(mb_left)) {
							jun_disp[@ 1] = !coll;
						}
					} else
						draw_sprite_stretched_ext(THEME.group_label, 0, 0, yy, con_w, ui(32), COLORS.panel_inspector_group_bg, 1);
					
					draw_sprite_ui(THEME.arrow, 0, ui(16), yy + ui(32) / 2, 1, 1, -90 + coll * 90, COLORS.panel_inspector_group_bg, 1);
					draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
					draw_text(ui(32), yy + ui(32) / 2, txt);
					
					hh += ui(32 + 8);
					
					if(coll) {
						var j = i + 1;
						while(j < amo) {
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
					var hov = pHOVER;
					var foc = pFOCUS;
					jun_disp.draw(ui(6), yy, con_w - ui(12), _m, hov, foc);
					hh += jun_disp.h + ui(20);
					continue;
				}
				jun = inspecting.inputs[| inspecting.input_display_list[i]];
			}
				
			if(!jun.show_in_inspector || jun.type == VALUE_TYPE.object) continue;
			
			var lb_h = line_height(f_p0) + ui(8);
			var lb_y = yy + lb_h / 2;
			
			var butx = ui(16);
			var index = jun.value_from == noone? jun.animator.is_anim : 2;
			draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, 1,, 0.8);
			if(pHOVER && point_in_circle(_m[0], _m[1], butx, lb_y, ui(10))) {
				draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, 1,, 1);
				TOOLTIP = "Toggle animation";
					
				if(mouse_check_button_pressed(mb_left)) {
					if(jun.value_from != noone)
						jun.removeFrom();
					else
						jun.animator.is_anim = !jun.animator.is_anim;
					PANEL_ANIMATION.updatePropertyList();
				}
			}
			
			butx += ui(20);
			index = jun.visible;
			draw_sprite_ui_uniform(THEME.junc_visible, index, butx, lb_y, 1,, 0.8);
			if(pHOVER && point_in_circle(_m[0], _m[1], butx, lb_y, ui(10))) {
				draw_sprite_ui_uniform(THEME.junc_visible, index, butx, lb_y, 1,, 1);
				TOOLTIP = "Visibility";
					
				if(mouse_check_button_pressed(mb_left)) {
					jun.visible = !jun.visible;
				}
			}
				
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(56), lb_y - ui(2), jun.name);
			var lb_w = string_width(jun.name) + ui(32);
				
			#region anim
				if(lineBreak && jun.animator.is_anim) {
					var bx = w - ui(64);
					var by = lb_y;
					if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, pHOVER, "", THEME.prop_keyframe, 2) == 2) {
						for(var j = 0; j < ds_list_size(jun.animator.values); j++) {
							var _key = jun.animator.values[| j];
							if(_key.time > ANIMATOR.current_frame) {
								ANIMATOR.real_frame = _key.time;
								ANIMATOR.is_scrubing = true;
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
						
					if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, pHOVER, kfFocus? "Remove keyframe" : "Add keyframe", THEME.prop_keyframe, 1, cc) == 2) {
						var _add = false;
						for(var j = 0; j < ds_list_size(jun.animator.values); j++) {
							var _key = jun.animator.values[| j];
							if(_key.time == ANIMATOR.current_frame) {
								if(ds_list_size(jun.animator.values) > 1)
									ds_list_delete(jun.animator.values, j);
								_add = true;
								break;
							} else if(_key.time > ANIMATOR.current_frame) {
								ds_list_insert(jun.animator.values, j, new valueKey(ANIMATOR.current_frame, jun.getValue(), jun.animator));
								_add = true;
								break;	
							}
						}
						if(!_add) ds_list_add(jun.animator.values, new valueKey(ANIMATOR.current_frame, jun.getValue(), jun.animator));
					}
						
					bx -= ui(26);
					if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, pHOVER, "", THEME.prop_keyframe, 0) == 2) {
						var _t = -1;
						for(var j = 0; j < ds_list_size(jun.animator.values); j++) {
							var _key = jun.animator.values[| j];
							if(_key.time < ANIMATOR.current_frame) {
								_t = _key.time;
							}
						}
						if(_t > -1) ANIMATOR.real_frame = _t;
						ANIMATOR.is_scrubing = true;
					}
						
					var lhf = lb_h / 2 - 4;
					draw_set_color(COLORS.panel_inspector_key_separator);
					draw_line(bx - ui(20), by - lhf, bx - ui(20), by + lhf);
					
					draw_set_color(COLORS.panel_inspector_key_separator);
					draw_line(bx - ui(20), by - lhf, bx - ui(20), by + lhf);
					
					bx -= ui(26 + 12);
					if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, pFOCUS, pHOVER, "Looping mode " + ON_END_NAME[jun.on_end], THEME.prop_on_end, jun.on_end) == 2)
						jun.on_end = safe_mod(jun.on_end + 1, sprite_get_number(THEME.prop_on_end));
				}
			#endregion
			
			//TODO: Fix padding to be consistant to every widget
			var _hsx = ui(32);
			var _hsy = yy + lb_h;
			var padd = ui(8);
			
			var labelWidth = max(lb_w, min(ui(80) + w * 0.2, ui(200)));
			var editBoxW   = w - ui(80)		- !lineBreak * labelWidth;
			var editBoxH   = lineBreak? TEXTBOX_HEIGHT : lb_h;
			var editBoxX   = ui(32)			+ !lineBreak * labelWidth;
			var editBoxY   = lineBreak? _hsy : yy;
			
			var widH	   = lineBreak? editBoxH : 0;
			
			if(jun.editWidget) {
				jun.editWidget.active = pFOCUS;
				jun.editWidget.hover  = pHOVER;
				
				switch(jun.display_type) {
					case VALUE_DISPLAY.button :
						jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, _m);
						break;
					default :
						switch(jun.type) {
							case VALUE_TYPE.float :
							case VALUE_TYPE.integer :
								switch(jun.display_type) {
									case VALUE_DISPLAY.enum_button :
									case VALUE_DISPLAY._default :
									case VALUE_DISPLAY.range :
									case VALUE_DISPLAY.vector :
										jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
										break;
									case VALUE_DISPLAY.vector_range :
										widH = jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
										break;
									case VALUE_DISPLAY.enum_scroll :
										jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.display_data[jun.showValue()], _m, ui(16) + x, top_bar_h + y);
										break;
									case VALUE_DISPLAY.padding :
										jun.editWidget.draw(xc, _hsy + ui(32), jun.showValue(), jun.modifier, _m);
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
										jun.editWidget.draw(xc, _hsy + ui(40), jun.showValue(), _m);
										widH = ui(204);
										break;
									case VALUE_DISPLAY.puppet_control :
										widH = jun.editWidget.draw(editBoxX, editBoxY, editBoxW, jun.showValue(), _m, ui(16) + x, top_bar_h + y);
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
										jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), jun.extra_data, _m);
										break;
									default :
										jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
										break;
								}
								break;
							case VALUE_TYPE.path :
								var val = jun.showValue(), txt = "";
								var pathExist = jun.value_validation == VALIDATION.pass;
									
								if(is_array(val))
									txt = "[" + string(array_length(val)) + "] " + val[0];
								else
									txt = val;
									
								jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, _m,, pathExist? COLORS._main_text : COLORS._main_value_negative);
								var icx = editBoxX + editBoxW - ui(16);
								var icy = editBoxY + editBoxH / 2;
								draw_sprite_ui_uniform(pathExist? THEME.button_path_icon : THEME.button_path_not_found_icon, 0, icx, icy, 1,, 1);
								draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
								draw_text_cut(editBoxX + ui(8), editBoxY + editBoxH / 2, txt, editBoxW - ui(60));
									
								if(!pathExist && point_in_rectangle(_m[0], _m[1], icx - ui(17), icy - ui(17), icx + ui(17), icy + ui(17)))
									TOOLTIP = "File not exist";
								break;
							case VALUE_TYPE.surface :
								editBoxH = ui(96);
								jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m, ui(16) + x, top_bar_h + y);
								widH = lineBreak? editBoxH : editBoxH - lb_h;
								break;
							case VALUE_TYPE.curve :
								editBoxH = ui(132);
								jun.editWidget.draw(ui(32), _hsy, w - ui(80), editBoxH, jun.showValue(), _m);
								widH = editBoxH;
								break;
							case VALUE_TYPE.text :
								var _hh = jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m, jun.display_type);
								widH = _hh;
								break;
						}
				}
			} else if(jun.display_type == VALUE_DISPLAY.label) {
				draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
				draw_text(ui(32), _hsy, jun.display_data);
				
				widH = string_height(jun.display_data);
			}
			
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
			
			hh += lb_h + widH + padd;
			
			var _selY  = yy - ui(0);
			var _selY1 = yy + lb_h + widH + ui(2);
			var _selH  = _selY1 - _selY;
			
			if(pHOVER && point_in_rectangle(_m[0], _m[1], 4, _selY, contentPane.surface_w - ui(4), _selY + _selH)) {
				draw_sprite_stretched_ext(THEME.prop_selecting, 0, 4, _selY, contentPane.surface_w - ui(8), _selH, COLORS._main_accent, 1);
				prop_hover = jun;
					
				if(pFOCUS) {
					if(mouse_check_button_pressed(mb_left))
						prop_selecting = jun;
						
					if(mouse_check_button_pressed(mb_right)) {
						__dialog_junction = jun;
						var dia = dialogCall(o_dialog_menubox, mouse_mx, mouse_my);
						dia.setMenu( [
							[ "Reset value", function() { 
								__dialog_junction.setValue(__dialog_junction.def_val);
								}],
							[ __dialog_junction.animator.is_anim? "Remove animation" : "Add animation", function() { 
								__dialog_junction.animator.is_anim = !__dialog_junction.animator.is_anim; 
								PANEL_ANIMATION.updatePropertyList();
								}],
							-1,
							[ "Copy", function() {
								clipboard_set_text(__dialog_junction.getShowString());
								}, ["Inspector", "Copy property"]],
							[ "Paste", function() {
								__dialog_junction.setString(clipboard_get_text());
								}, ["Inspector", "Paste property"]],
						] );
					}
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
		tb_node_name.draw(ui(64), ui(14), w - ui(128), ui(32), inspecting.name, [mx, my]);
		
		if(!inspecting.auto_update) {
			var bx = w - ui(44);
			var by = ui(12);
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Run node", THEME.sequence_control, 1) == 2)
				inspecting.doUpdate();
		}
		
		if(inspecting.use_cache) {
			var bx = ui(8);
			var by = ui(12);
			
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "This node cache output for performance.\nClick to clear all cached frames in this node.", THEME.cache) = 2)
				inspecting.clearCache();
		}
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		lineBreak = w < PREF_MAP[? "inspector_line_break_width"];
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), top_bar_h - ui(8), w - ui(16), h - top_bar_h);
		
		if(inspecting)
			drawInspectingNode();
		
		contentPane.active = pHOVER;
		contentPane.draw(ui(16), top_bar_h, mx - ui(16), my - top_bar_h);
		
		if(PANEL_GRAPH.node_focus && inspecting != PANEL_GRAPH.node_focus) {
			inspecting = PANEL_GRAPH.node_focus;
			if(inspecting != noone)
				inspecting.onInspect();
			contentPane.scroll_y    = 0;
			contentPane.scroll_y_to = 0;
		}
	}
}