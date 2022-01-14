function Panel_Inspector(_panel) : PanelContent(_panel) constructor {
	context_str = "Inspector";
	
	inspecting = noone;
	top_bar_h  = 64;
	
	prop_hover = noone;
	prop_selecting = noone;
	
	content_w = w - 32;
	content_h = h - top_bar_h - 24;
	
	keyframe_dragging = noone;
	keyframe_drag_st  = 0;
	
	min_w = 160;
	
	tb_node_name	= new textBox(TEXTBOX_INPUT.text, function(txt) {
		if(inspecting) inspecting.name = txt;
	})
	
	addHotkey("Inspector", "Copy property",		"C",   MOD_KEY.ctrl,	function() {propSelectCopy(); });
	addHotkey("Inspector", "Paste property",	"V",   MOD_KEY.ctrl,	function() {propSelectPaste(); });
	
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		var hh = 0;
		var con_w = contentPane.surface_w;
		
		draw_clear_alpha(c_ui_blue_black, 0);
		
		if(FOCUS == panel) 
			if(point_in_rectangle(_m[0], _m[1], 0, 0, con_w, content_h) && mouse_check_button_pressed(mb_left))
				prop_selecting = noone;
		
		if(inspecting) {		
			inspecting.inspecting = true;
			prop_hover = noone;
			var jun;
			var amo = inspecting.input_display_list == -1? ds_list_size(inspecting.inputs) : max(ds_list_size(inspecting.inputs), array_length(inspecting.input_display_list));
			
			for(var i = 0; i < amo; i++) {
				var xc		= con_w / 2;
				var yy		= 16 + hh + _y;
				
				if(inspecting.input_display_list == -1) {
					jun = inspecting.inputs[| i];
				} else {
					var jun_list_arr = inspecting.input_display_list[i];
					if(is_array(jun_list_arr)) {
						var txt  = jun_list_arr[0];
						var coll = jun_list_arr[1];
						
						if(HOVER == panel && point_in_rectangle(_m[0], _m[1], 0, yy, con_w, yy + 32)) {
							draw_sprite_stretched_ext(s_node_name, 0, 0, yy, con_w, 32, c_ui_blue_white, 1);
							
							if(FOCUS == panel && mouse_check_button_pressed(mb_left)) {
								jun_list_arr[@ 1] = !coll;
							}
						} else
							draw_sprite_stretched_ext(s_node_name, 0, 0, yy, con_w, 32, c_ui_blue_ltgrey, 1);
						
						draw_sprite_ext(s_arrow_16, 0, 16, yy + 32 / 2, 1, 1, -90 + coll * 90, c_ui_blue_ltgrey, 1);
						draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_white);
						draw_text(32, yy + 32 / 2, txt);
						
						hh += 32 + 8 + 24 * !coll;
						
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
						} else
							continue;
					}
					jun = inspecting.inputs[| inspecting.input_display_list[i]];
				}
				
				if(!jun.show_in_inspector || jun.type == VALUE_TYPE.surface || jun.type == VALUE_TYPE.object) continue;
				
				var index = jun.value_from == noone? jun.value.is_anim : 2;
				draw_sprite_ext(s_animate_clock, index, 16, yy, 1, 1, 0, c_white, 0.8);
				if(HOVER == panel && point_in_circle(_m[0], _m[1], 16, yy, 12)) {
					draw_sprite_ext(s_animate_clock, index, 16, yy, 1, 1, 0, c_white, 1);
					TOOLTIP = "Toggle animation";
					
					if(mouse_check_button_pressed(mb_left)) {
						if(jun.value_from != noone)
							jun.removeFrom();
						else
							jun.value.is_anim = !jun.value.is_anim;
						PANEL_ANIMATION.updatePropertyList();
					}
				}
				
				index = jun.visible;
				draw_sprite_ext(s_junc_visible, index, 36, yy, 1, 1, 0, c_white, 0.8);
				if(HOVER == panel && point_in_circle(_m[0], _m[1], 36, yy, 12)) {
					draw_sprite_ext(s_junc_visible, index, 36, yy, 1, 1, 0, c_white, 1);
					TOOLTIP = "Visibility";
					
					if(mouse_check_button_pressed(mb_left)) {
						jun.visible = !jun.visible;
					}
				}
				
				draw_set_text(f_p0, fa_left, fa_center, c_white);
				draw_text(56, yy, jun.name);
				
				#region anim
					if(jun.value.is_anim) {
						var bx = w - 72;
						var by = yy - 12;
						if(buttonInstant(s_button_hide, bx, by, 24, 24, _m, FOCUS == panel, HOVER == panel, "", s_prop_keyframe, 2) == 2) {
							for(var j = 0; j < ds_list_size(jun.value.values); j++) {
								var _key = jun.value.values[| j];
								if(_key.time > ANIMATOR.current_frame) {
									ANIMATOR.real_frame = _key.time;
									ANIMATOR.is_scrubing = true;
									break;
								}
							}
						}
						
						bx -= 26;
						var cc = c_ui_blue_grey;
						for(var j = 0; j < ds_list_size(jun.value.values); j++) {
							if(jun.value.values[| j].time == ANIMATOR.current_frame) {
								cc = c_ui_orange;
								break;
							}
						}
						
						if(buttonInstant(s_button_hide, bx, by, 24, 24, _m, FOCUS == panel, HOVER == panel, cc == c_ui_blue_grey? "Add keyframe" : "Remove keyframe", s_prop_keyframe, 1, cc) == 2) {
							var _add = false;
							for(var j = 0; j < ds_list_size(jun.value.values); j++) {
								var _key = jun.value.values[| j];
								if(_key.time == ANIMATOR.current_frame) {
									if(ds_list_size(jun.value.values) > 1)
										ds_list_delete(jun.value.values, j);
									_add = true;
									break;
								} else if(_key.time > ANIMATOR.current_frame) {
									ds_list_insert(jun.value.values, j, new valueKey(ANIMATOR.current_frame, jun.getValue()));
									_add = true;
									break;	
								}
							}
							if(!_add) ds_list_add(jun.value.values, new valueKey(ANIMATOR.current_frame, jun.getValue()));
						}
						
						bx -= 26;
						if(buttonInstant(s_button_hide, bx, by, 24, 24, _m, FOCUS == panel, HOVER == panel, "", s_prop_keyframe, 0) == 2) {
							var _t = -1;
							for(var j = 0; j < ds_list_size(jun.value.values); j++) {
								var _key = jun.value.values[| j];
								if(_key.time < ANIMATOR.current_frame) {
									_t = _key.time;
								}
							}
							if(_t > -1) ANIMATOR.real_frame = _t;
							ANIMATOR.is_scrubing = true;
						}
						
						draw_set_color(c_ui_blue_dkgrey);
						draw_line(bx - 6, by + 4, bx - 6, by + 20);
						
						draw_set_color(c_ui_blue_dkgrey);
						draw_line(bx - 6, by + 4, bx - 6, by + 20);
						
						bx -= 26 + 12;
						if(buttonInstant(s_button_hide, bx, by, 24, 24, _m, FOCUS == panel, HOVER == panel, "Looping mode " + ON_END_NAME[jun.on_end], s_prop_on_end, jun.on_end) == 2)
							jun.on_end = safe_mod(jun.on_end + 1, sprite_get_number(s_prop_on_end));
					}
				#endregion
				
				var _hsx = 32;
				var _hsy = yy + 20;
				var _hex = _hsx + w - 80;
				var _hey = _hsy + 34;
				var padd = 48;
				
				if(jun.editWidget) {
					jun.editWidget.active = FOCUS == panel;
					jun.editWidget.hover  = HOVER == panel;
				
					switch(jun.display_type) {
						case VALUE_DISPLAY.button :
							jun.editWidget.draw(32, _hsy, w - 80, 34, _m);
							_hey = _hsy + 34;
							hh += 34 + padd;
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
											jun.editWidget.draw(32, _hsy, w - 80, 34, jun.showValue(), _m);
											_hey = _hsy + 34;
											hh += 34 + padd;
											break;
										case VALUE_DISPLAY.vector_range :
											jun.editWidget.draw(32, _hsy, w - 80, 34, jun.showValue(), _m);
											_hey = _hsy + 68;
											hh += 68 + padd;
											break;
										case VALUE_DISPLAY.enum_scroll :
											jun.editWidget.draw(32, _hsy, w - 80, 34, jun.display_data[jun.showValue()], _m, 16 + x, top_bar_h + y);
											_hey = _hsy + 34;
											hh += 34 + padd;
											break;
										case VALUE_DISPLAY.padding :
											jun.editWidget.draw(xc, _hsy + 50, jun.showValue(), jun.modifier, _m);
											_hey = _hsy + 216;
											hh += 216 + padd;
											break;
										case VALUE_DISPLAY.rotation :
										case VALUE_DISPLAY.rotation_range :
											jun.editWidget.draw(xc, _hsy, jun.showValue(), _m);
											_hey = _hsy + 94;
											hh += 94 + padd;
											break;
										case VALUE_DISPLAY.slider :
										case VALUE_DISPLAY.slider_range :
											jun.editWidget.draw(32, _hsy, w - 80, 34, jun.showValue(), _m);
											_hey = _hsy + 34;
											hh += 34 + padd;
											break;
										case VALUE_DISPLAY.area :
											jun.editWidget.draw(xc, _hsy + 40, jun.showValue(), _m);
											_hey = _hsy + 200;
											hh += 200 + padd;
											break;
										case VALUE_DISPLAY.puppet_control :
											jun.editWidget.draw(32, _hsy, w - 80, 34, jun.showValue()[4], _m);
											_hey = _hsy + 34;
											hh += 34 + padd;
											break;
									}
						
									break;
								case VALUE_TYPE.boolean :
									jun.editWidget.draw(32, _hsy, jun.showValue(), _m);
									_hey = _hsy + 26;
									hh += 26 + padd;
									break;
								case VALUE_TYPE.color :
									switch(jun.display_type) {
										case VALUE_DISPLAY.gradient :
											jun.editWidget.draw(32, _hsy, w - 80, 34, jun.showValue(), jun.extra_data, _m);
											break;
										default :
											jun.editWidget.draw(32, _hsy, w - 80, 34, jun.showValue(), _m);
											break;
									}
									_hey = _hsy + 34;
									hh += 34 + padd;
									break;
								case VALUE_TYPE.path :
									jun.editWidget.draw(32, _hsy, w - 80, 34, _m);
									
									draw_sprite_ext(s_button_path_icon, 0, w - 72, _hsy + 17, 1, 1, 0, c_white, 1);
									draw_set_text(f_p0, fa_left, fa_center, c_white);
								
									var val = jun.showValue(), txt;
									if(is_array(val)) {
										txt = "[" + string(array_length(val)) + "] " + val[0];
									} else 
										txt = val;
								
									draw_text_cut(40, _hsy + 17, txt, w - 140);
									_hey = _hsy + 34;
									hh += 34 + padd;
									break;
								case VALUE_TYPE.surface :
									draw_set_color(c_ui_blue_dkgrey);
									draw_rectangle(32, _hsy, w - 48, yy + 14 + 68, true);
									_hey = _hsy + 68;
									hh += 68 + padd;
									break;
								case VALUE_TYPE.curve :
									jun.editWidget.draw(32, _hsy, w - 80, 160, jun.showValue(), _m);
									_hey = _hsy + 136;
									hh += 136 + padd;
									break;
								case VALUE_TYPE.text :
									jun.editWidget.draw(32, _hsy, w - 80, 34, jun.showValue(), _m, jun.display_type);
									_hey = _hsy + 34;
									hh += 34 + padd;
									break;
								default:
									_hey = _hsy + 34;
									hh += 34 + padd;
									break;
							}
					}
				} else if(jun.display_type == VALUE_DISPLAY.label) {
					draw_set_text(f_p1, fa_left, fa_top, c_ui_blue_ltgrey);
					draw_text(32, _hsy, jun.display_data);
					
					_hey = _hsy + string_height(jun.display_data);
					hh += string_height(jun.display_data) + padd;
				} else {
					hh += 34 + padd;	
				}
				
				var _hy = _hsy - 36;
				var _hw = _hey - _hy + 8;
				
				if(prop_selecting == jun)
					draw_sprite_stretched(s_prop_selecting, 1, 4, _hy, contentPane.surface_w - 8, _hw);
				
				if(HOVER == panel && point_in_rectangle(_m[0], _m[1], 4, _hy, contentPane.surface_w - 4, _hy + _hw)) {
					draw_sprite_stretched(s_prop_selecting, 0, 4, _hy, contentPane.surface_w - 8, _hw);
					prop_hover = jun;
					
					if(FOCUS == panel) {
						if(mouse_check_button_pressed(mb_left))
							prop_selecting = jun;
						
						if(mouse_check_button_pressed(mb_right)) {
							__dialog_junction = jun;
							var dia = dialogCall(o_dialog_menubox, mouse_mx, mouse_my);
							dia.setMenu( [
								[ "Reset value", function() { 
									__dialog_junction.setValue(__dialog_junction.def_val);
									}],
								[ __dialog_junction.value.is_anim? "Remove animation" : "Add animation", function() { 
									__dialog_junction.value.is_anim = !__dialog_junction.value.is_anim; 
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
	
	function onResize(dw, dh) {
		content_w = w - 32;
		content_h = h - top_bar_h - 24;
		contentPane.resize(content_w, content_h);
	}
	
	function drawInspectingNode() {
		draw_set_text(f_h5, fa_center, fa_top, c_white);
		tb_node_name.font = f_h5;
		tb_node_name.hide = true;
		tb_node_name.active = FOCUS == panel;
		tb_node_name.hover  = HOVER == panel;
		tb_node_name.align = fa_center;
		tb_node_name.draw(64, 14, w - 128, 32, inspecting.name, [mx, my]);
		
		if(!inspecting.auto_update) {
			var bx = w - 44;
			var by = 12;
			
			if(buttonInstant(s_button_hide, bx, by, 32, 32, [mx, my], FOCUS == panel, HOVER == panel, "Update node", s_refresh_24) == 2)
				inspecting.doUpdate();
		}
		
		if(inspecting.use_cache) {
			var bx = 8;
			var by = 12;
			
			if(buttonInstant(s_button_hide, bx, by, 32, 32, [mx, my], FOCUS == panel, HOVER == panel, "This node cache output for performance.\nClick to clear all cached frames in this node.", s_cache) = 2)
				inspecting.clearCache();
		}
	}
	
	function drawContent() {
		draw_clear_alpha(c_ui_blue_black, 0);
		
		draw_sprite_stretched(s_ui_panel_bg, 1, 8, top_bar_h - 8, w - 16, h - top_bar_h);
		
		if(inspecting)
			drawInspectingNode();
		
		contentPane.active = HOVER == panel;
		contentPane.draw(16, top_bar_h, mx - 16, my - top_bar_h);
		
		if(PANEL_GRAPH.node_focus && inspecting != PANEL_GRAPH.node_focus) {
			inspecting = PANEL_GRAPH.node_focus;
			contentPane.scroll_y    = 0;
			contentPane.scroll_y_to = 0;
		}
	}
}