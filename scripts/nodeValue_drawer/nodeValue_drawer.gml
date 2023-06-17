function drawWidgetInit() {
	anim_toggling = false;
	anim_hold     = noone;
	visi_hold     = noone;
	
	min_w = ui(160);
	lineBreak = true;
}

function drawWidget(xx, yy, ww, _m, jun, global_var = true, _hover = false, _focus = false, _scrollPane = noone, rx = 0, ry = 0) { 
	var con_w	= ww - ui(4);
	var xc		= xx + ww / 2;
		
	var lb_h = line_get_height(f_p0) + ui(8);
	var lb_y = yy + lb_h / 2;
			
	var butx = xx;
	if(jun.connect_type == JUNCTION_CONNECT.input && jun.isAnimable() && !jun.expUse) {
		var index = jun.value_from == noone? jun.is_anim : 2;
		draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, 1, index == 2? COLORS._main_accent : c_white, 0.8);
		if(_hover && point_in_circle(_m[0], _m[1], butx, lb_y, ui(10))) {
			if(anim_hold != noone)
				jun.setAnim(anim_hold);
				
			draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, 1, index == 2? COLORS._main_accent : c_white, 1);
			TOOLTIP = jun.value_from == noone? __txtx("panel_inspector_toggle_anim", "Toggle animation") : __txtx("panel_inspector_remove_link", "Remove link");
					
			if(mouse_press(mb_left, _focus)) {
				if(jun.value_from != noone)
					jun.removeFrom();
				else {
					recordAction(ACTION_TYPE.var_modify, jun.animator, [ jun.is_anim, "is_anim", jun.name + " animation" ]);
					jun.setAnim(!jun.is_anim);
					anim_hold = jun.is_anim;
				}
				PANEL_ANIMATION.updatePropertyList();
			}
		}
	}
		
	if(anim_hold != noone && mouse_release(mb_left))
		anim_hold = noone;
		
	butx += ui(20);
	if(!global_var) {			
		index = jun.visible;
		draw_sprite_ui_uniform(THEME.junc_visible, index, butx, lb_y, 1,, 0.8);
		if(_hover && point_in_circle(_m[0], _m[1], butx, lb_y, ui(10))) {
			if(visi_hold != noone)
				jun.visible = visi_hold;
					
			draw_sprite_ui_uniform(THEME.junc_visible, index, butx, lb_y, 1,, 1);
			TOOLTIP = __txt("Visibility");
				
			if(mouse_press(mb_left, _focus)) {
				jun.visible = !jun.visible;
				visi_hold = jun.visible;
			}
		}
	} else
		draw_sprite_ui_uniform(THEME.node_use_expression, 0, butx, lb_y, 1,, 0.8);
		
	if(visi_hold != noone && mouse_release(mb_left))
		visi_hold = noone;
		
	var cc = COLORS._main_text_inner;
	if(jun.expUse) {
		var expValid = jun.expTree != noone && jun.expTree.validate();
		cc = expValid? COLORS._main_value_positive : COLORS._main_value_negative;
	}
	
	if(global_var)
		if(string_pos(" ", jun.name)) cc = COLORS._main_value_negative;
	
	draw_set_text(f_p0, fa_left, fa_center, cc);
	draw_text_add(xx + ui(40), lb_y - ui(2), jun.name);
	var lb_w = string_width(jun.name) + ui(32);
			
	#region tooltip
		if(jun.tooltip != "") {
			var tx = xx + ui(40) + string_width(jun.name) + ui(16);
			var ty = lb_y - ui(1);
					
			if(point_in_circle(_m[0], _m[1], tx, ty, ui(10))) {
				if(is_string(jun.tooltip))
					TOOLTIP = jun.tooltip;
				else if(mouse_click(mb_left, _focus))
					dialogCall(jun.tooltip);
				draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 1);
			} else 
				draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 0.75);
		}
	#endregion
			
	#region anim
		if(jun.connect_type == JUNCTION_CONNECT.input && lineBreak && jun.is_anim) {
			var bx = xx + ww - ui(12);
			var by = lb_y;
			if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, "", THEME.prop_keyframe, 2) == 2) {
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
						
			if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, kfFocus? __txtx("panel_inspector_remove_key", "Remove keyframe") : 
				__txtx("panel_inspector_add_key", "Add keyframe"), THEME.prop_keyframe, 1, cc) == 2) {
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
			if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, "", THEME.prop_keyframe, 0) == 2) {
				var _t = -1;
				for(var j = 0; j < ds_list_size(jun.animator.values); j++) {
					var _key = jun.animator.values[| j];
					if(_key.time < ANIMATOR.current_frame)
						_t = _key.time;
				}
				if(_t > -1) ANIMATOR.setFrame(_t);
			}
						
			var lhf = lb_h / 2 - 4;
			draw_set_color(COLORS.panel_inspector_key_separator);
			draw_line(bx - ui(20), by - lhf, bx - ui(20), by + lhf);
					
			draw_set_color(COLORS.panel_inspector_key_separator);
			draw_line(bx - ui(20), by - lhf, bx - ui(20), by + lhf);
					
			bx -= ui(26 + 12);
			if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, __txtx("panel_animation_looping_mode", "Looping mode") + " " + ON_END_NAME[jun.on_end], THEME.prop_on_end, jun.on_end) == 2)
				jun.on_end = safe_mod(jun.on_end + 1, sprite_get_number(THEME.prop_on_end));
		}
	#endregion
		
	#region use expression
		if(jun.connect_type == JUNCTION_CONNECT.input && lineBreak && !jun.is_anim && !global_var) {
			var bx = xx + ww - ui(12);
			var by = lb_y;
			var ic_b = jun.expUse? c_white : COLORS._main_icon;
			if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, __txtx("panel_inspector_use_expression", "Use expression"), THEME.node_use_expression, jun.expUse, ic_b) == 2)
				jun.expUse = !jun.expUse;
				
			if(jun.expUse) {
				bx -= ui(28);
				var cc = NODE_DROPPER_TARGET == jun? COLORS._main_value_positive : COLORS._main_icon;
				if(buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, __txtx("panel_inspector_dropper", "Node dropper"), THEME.node_dropper, 0, cc) == 2)
					NODE_DROPPER_TARGET = NODE_DROPPER_TARGET == jun? noone : jun;
			}
		}
	#endregion
	
	var _hsy = yy + lb_h;
	var padd = ui(8);
			
	var labelWidth = max(lb_w, min(ui(80) + ww * 0.2, ui(200)));
	var editBoxX   = xx	+ !lineBreak * labelWidth;
	var editBoxY   = lineBreak? _hsy : yy;
	
	var editBoxW   = (xx + ww) - editBoxX;
	var editBoxH   = lineBreak? TEXTBOX_HEIGHT : lb_h;
			
	var widH	   = lineBreak? editBoxH : 0;
	var mbRight	   = true;
		
	if(jun.expUse) {
		var expValid = jun.expTree != noone && jun.expTree.validate();
		jun.express_edit.boxColor = expValid? COLORS._main_value_positive : COLORS._main_value_negative;
		
		jun.express_edit.setActiveFocus(_focus, _hover);
		if(_focus) jun.express_edit.register(_scrollPane);
			
		var wd_h = jun.express_edit.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.expression, _m);
		widH = lineBreak? wd_h : 0;
	} else if(jun.editWidget) {
		jun.editWidget.setActiveFocus(_focus, _hover);
			
		if(jun.connect_type == JUNCTION_CONNECT.input) {
			jun.editWidget.setInteract(jun.value_from == noone);
			if(_focus) jun.editWidget.register(_scrollPane);
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
								jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, array_safe_get(jun.display_data, jun.showValue()), _m, rx, ry);
								break;
							case VALUE_DISPLAY.enum_button :
								jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m, rx, ry);
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
								widH = jun.editWidget.draw(editBoxX, editBoxY, editBoxW, jun.showValue(), _m, rx, ry);
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
						jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
						break;
					case VALUE_TYPE.gradient :
						jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m);
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
								jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, val, _m, rx, ry);
								break;
						}
						break;
					case VALUE_TYPE.surface :
						editBoxH = ui(96);
						jun.editWidget.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.showValue(), _m, rx, ry);
						widH = lineBreak? editBoxH : editBoxH - lb_h;
						break;
					case VALUE_TYPE.curve :
						editBoxH = ui(160);
						jun.editWidget.draw(ui(32), _hsy, ww - ui(16), editBoxH, jun.showValue(), _m);
						if(point_in_rectangle(_m[0], _m[1], ui(32), _hsy, ui(32) + ww - ui(16), _hsy + editBoxH))
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
								_hh = jun.editWidget.draw(ui(16), _hsy, ww, editBoxH, jun.showValue(), _m, jun.display_type);
								break;
							case "textArrayBox":
								_hh = jun.editWidget.draw(ui(16), editBoxY, editBoxW, editBoxH, _m, rx, ry);
								break;
						}
							
						widH = _hh;
						break;
				}
		}
	} else if(jun.display_type == VALUE_DISPLAY.label) {
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_add(xx + ui(16), _hsy, jun.display_data);
				
		widH = string_height(jun.display_data);
	} else
		widH = 0;
	
	//draw_set_color(c_white);
	//draw_rectangle(xx, yy, xx + ww, yy + widH, true);
	//draw_set_color(c_red);
	//draw_line(xx + ww / 2, yy, xx + ww / 2, yy + widH);
	
	return [ widH, mbRight ];
}	