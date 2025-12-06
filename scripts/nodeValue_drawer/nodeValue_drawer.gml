enum INSP_VIEW_MODE {
	compact,
	spacious
}

function drawWidgetInit() {
	anim_toggling = false;
	anim_hold     = noone;
	visi_hold     = noone;
	
	min_w = ui(160);
	viewMode = PREFERENCES.inspector_view_default;
	
	tooltip_loop_type = new tooltipSelector(__txtx("panel_animation_looping_mode", "Looping mode"), global.junctionEndName);
}

function drawWidget(xx, yy, ww, _m, jun, global_var = true, _hover = false, _focus = false, _scrollPane = noone, rx = 0, ry = 0, _ID = undefined) { 
	#region data
		var _font     = viewMode == INSP_VIEW_MODE.spacious? f_p2 : f_p3;
		var breakLine = viewMode == INSP_VIEW_MODE.spacious || jun.expUse;
		
		var con_w = ww - ui(4);
		var xc	  = xx + ww / 2;
		var lb_h  = line_get_height(_font, 4 + viewMode * 2);
		var lb_y  = yy + lb_h / 2;
		var cHov  = false;
		
		var _name     = jun.getName();
		var dispName  = _name;
		var wid       = jun.editWidget;
		
		if(_ID != undefined) {
			var _map = jun.editWidgetMap;
			if(!struct_has(_map, _ID)) 
				_map[$ _ID] = wid.clone();
			wid = _map[$ _ID];
		}
		
		if(global_var) dispName = string_title(string_replace_all(_name, "_", " "));
		
		if(is(wid, widget)) {
			breakLine = breakLine || wid.always_break_line;
		
			switch(instanceof(wid)) {
				case "matrixGrid"      : breakLine = breakLine || wid.size[0] > 5; break;
				case "outputStructBox" : breakLine = breakLine || wid.expand;      break;
			}
		}
	#endregion
	
	#region left buttons
		var bs   = viewMode == INSP_VIEW_MODE.spacious? ui(20) : ui(16);
		var ics  = viewMode == INSP_VIEW_MODE.spacious? 1 : .85;
		var butx = xx;
		var lb_x = xx + bs;
		
		if(jun.connect_type == CONNECT_TYPE.input && jun.isAnimable() && !jun.expUse) { 							// Animation
			var index = jun.hasJunctionFrom()? 2 : jun.is_anim;
			
			var cc = c_white;
			if(jun.is_anim) cc = COLORS._main_value_positive;
			if(index == 2)  cc = COLORS._main_accent;
			
			var _hov = _hover && point_in_circle(_m[0], _m[1], butx, lb_y, bs / 2);
			draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, ics, cc, .8 + .2 * _hov);
			
			if(_hov) {
				cHov  = true;
				
				if(anim_hold != noone)
					jun.setAnim(anim_hold, true);
					
				draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, ics, index == 2? COLORS._main_accent : c_white, 1);
				TOOLTIP = jun.hasJunctionFrom()? __txtx("panel_inspector_remove_link", "Remove link") : __txtx("panel_inspector_toggle_anim", "Toggle animation");
						
				if(mouse_press(mb_left, _focus)) {
					if(jun.value_from != noone)
						jun.removeFrom();
					else {
						jun.setAnim(!jun.is_anim, true);
						anim_hold = jun.is_anim;
					}
				}
			}
		}
		
		if(anim_hold != noone && mouse_release(mb_left)) anim_hold = noone;
			
		if(!global_var) {																							// Visibility
			butx += bs;
			lb_x += bs;
			var _visi = jun.isVisible();
			
			draw_sprite_ui_uniform(THEME.junc_visible, _visi, butx, lb_y, ics, c_white, .8);
			if(_hover && point_in_circle(_m[0], _m[1], butx, lb_y, bs / 2)) {
				cHov  = true;
				
				if(visi_hold != noone && jun.visible_manual != visi_hold) {
					jun.setVisibleManual(visi_hold);
					jun.node.refreshNodeDisplay();
				}
				
				draw_sprite_ui_uniform(THEME.junc_visible, _visi, butx, lb_y, ics,, 1);
				TOOLTIP = __txt("Visibility");
				
				if(mouse_press(mb_left, _focus)) {
					jun.setVisibleManual(_visi? -1 : 1);
					visi_hold = jun.visible_manual;
				}
			}
		}
			
		if(visi_hold != noone && mouse_release(mb_left)) visi_hold = noone;
			
		var cc = COLORS._main_text;
		if(jun.expUse) {
			var expValid = jun.expTree != noone && jun.expTree.validate();
			cc = expValid? COLORS._main_value_positive : COLORS._main_value_negative;
		}
		
		if(global_var) {
			if(string_pos(" ", _name))	cc = COLORS._main_value_negative;
		} else {
			if(jun.is_anim)				cc = COLORS._main_value_positive;
			if(jun.hasJunctionFrom())	cc = COLORS._main_accent;
		}
		
		draw_set_text(_font, fa_left, fa_center, cc);
		var lb_w = !global_var * bs + bs + ui(16) + string_width(dispName);
		
		if(jun.color != -1) {
			draw_sprite_ui(THEME.timeline_color, 1, lb_x + ui(8), lb_y, 1, 1, 0, jun.color, 1);
			lb_x += ui(24);
			lb_w += ui(24);
		}
		
		if(!jun.active) {
			draw_set_text(_font, fa_left, fa_center, COLORS._main_text_sub_inner);
			draw_text_add(lb_x, lb_y - ui(2), dispName);
			
			if(jun.active_tooltip != "") {
				var tx = xx + ui(40) + string_width(dispName) + ui(16);
				var ty = lb_y - ui(1);
				
				if(_hover && point_in_circle(_m[0], _m[1], tx, ty, ui(10))) {
					cHov  = true;
					
					TOOLTIP = jun.active_tooltip;
					draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 1);
				} else 
					draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 0.75);
			}
			
			return [ 0, true, cHov ];
		}
	#endregion
	
	#region draw name
		draw_text_add(lb_x, lb_y, dispName);
		if(jun.connect_type == CONNECT_TYPE.input && jun.is_modified) {
			draw_set_color(COLORS._main_accent);
			draw_text_add(lb_x + string_width(dispName), lb_y, "*");
		}
		
		var _tip = jun.tooltip;
				
		if(_tip != "") { // Tooltip
			var ics = viewMode == INSP_VIEW_MODE.spacious? 1 : .75;
			var tx  = lb_x + string_width(dispName) + ui(16) * ics;
			var ty  = lb_y;
			var aa  = .75;
			
			if(_hover && point_in_circle(_m[0], _m[1], tx, ty, ui(10))) {
				cHov  = true;
				
			    if(is_string(_tip)) {
			    	TOOLTIP = _tip;
			    	
				} else if(mouse_click(mb_left, _focus)) {
					if(is_callable(_tip))
						_tip();
					else 
						dialogCall(_tip);
				}
				
				aa = 1;
			} 
			
			draw_sprite_ui(THEME.info_light, 0, tx, ty, ics, ics, 0, COLORS._main_icon_light, aa);
			
			lb_w += ui(16) * ics;
		}
	#endregion
	
	#region right buttons
		if(jun.connect_type == CONNECT_TYPE.input && breakLine && jun.is_anim) { // Animation
			var _anim = jun.animator;
			var bx = xx + ww - ui(12);
			var by = lb_y;
			var b  = buttonInstant(THEME.button_hide_fill, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _hover, _focus, "", THEME.prop_keyframe, 2)
			
			if(b) cHov = true;
			if(b == 2) {
				for(var j = 0; j < array_length(_anim.values); j++) {
					var _key = _anim.values[j];
					if(_key.time > GLOBAL_CURRENT_FRAME) {
						PROJECT.animator.setFrame(_key.time);
						break;
					}
				}
			}
						
			bx -= ui(26);
			var cc = COLORS.panel_animation_keyframe_unselected;
			var kfFocus = false;
			
			for(var j = 0; j < array_length(_anim.values); j++) {
				if(_anim.values[j].time == GLOBAL_CURRENT_FRAME) {
					cc = COLORS.panel_animation_keyframe_selected;
					kfFocus = true;
					break;
				}
			}
			
			var _tlp = kfFocus? __txtx("panel_inspector_remove_key", "Remove keyframe") : __txtx("panel_inspector_add_key", "Add keyframe");
			var b    = buttonInstant(THEME.button_hide_fill, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _hover, _focus, _tlp, THEME.prop_keyframe, 1, cc)
			
			if(b) cHov = true;
			if(b == 2) {
				var _remv = false;
				for(var j = 0; j < array_length(_anim.values); j++) {
					var _key = _anim.values[j];
					
					if(_key.time == GLOBAL_CURRENT_FRAME) {
						_anim.removeKey(_key);
						_remv = true;
						break;
					}
				}
				
				if(!_remv) _anim.setValue(jun.showValue(), true, GLOBAL_CURRENT_FRAME);
			}
						
			bx -= ui(26);
			var b = buttonInstant(THEME.button_hide_fill, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _hover, _focus, "", THEME.prop_keyframe, 0)
			
			if(b) cHov = true;
			if(b == 2) {
				var _t = -1;
				for(var j = 0; j < array_length(_anim.values); j++) {
					var _key = _anim.values[j];
					if(_key.time < GLOBAL_CURRENT_FRAME)
						_t = _key.time;
				}
				
				if(_t > -1) PROJECT.animator.setFrame(_t);
			}
						
			var lhf = lb_h / 2 - 4;
			draw_set_color(COLORS.panel_inspector_key_separator);
			draw_line(bx - ui(20), by - lhf, bx - ui(20), by + lhf);
					
			draw_set_color(COLORS.panel_inspector_key_separator);
			draw_line(bx - ui(20), by - lhf, bx - ui(20), by + lhf);
					
			bx -= ui(26 + 12);
			tooltip_loop_type.index = jun.on_end;
			
			var b = buttonInstant(THEME.button_hide_fill, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _hover, _focus, tooltip_loop_type, THEME.prop_on_end, jun.on_end)
			if(b) cHov = true;
			
			if(b == 1 && key_mod_press(SHIFT) && MOUSE_WHEEL != 0)   
				jun.on_end = (jun.on_end + sign(MOUSE_WHEEL) + sprite_get_number(THEME.prop_on_end)) % sprite_get_number(THEME.prop_on_end);
			if(b == 2) mod_inc_mf0 jun.on_end mod_inc_mf1 jun.on_end mod_inc_mf2  sprite_get_number(THEME.prop_on_end) mod_inc_mf3;
		}
		
		if(jun.connect_type == CONNECT_TYPE.input && breakLine && !jun.is_anim && !global_var) { // Right buttons
			var bx  = xx + ww + ui(16);
			var by  = lb_y;
			var bs  = ui(24);
			var bsh = bs / 2;
			var bsp = THEME.button_hide_fill;
			
			bx -= bs + ui(4);
			if(jun.is_modified) {
				var b = buttonInstant(bsp, bx - bsh, by - bsh, bs, bs, _m, _hover, _focus, __txtx("panel_inspector_reset", "Reset value"), THEME.refresh_16, 0, COLORS._main_icon)
				if(b)      cHov = true;
				if(b == 2) jun.resetValue();
				
			} else 
				draw_sprite_ui(THEME.refresh_16, 0, bx, by,,,, COLORS._main_icon, 0.5);
			
			bx -= bs + ui(4);
			var ic_b = jun.expUse? c_white : COLORS._main_icon;
			var b = buttonInstant(bsp, bx - bsh, by - bsh, bs, bs, _m, _hover, _focus, __txtx("panel_inspector_use_expression", "Use expression"), THEME.node_use_expression, jun.expUse, ic_b)
			
			if(b) cHov = true;
			if(b == 2) {
				jun.setUseExpression(!jun.expUse);
				
				if(!jun.expUse) WIDGET_CURRENT = undefined;
			}
				
			if(jun.expUse) {
				bx -= bs + ui(4);
				var cc = NODE_DROPPER_TARGET == jun? COLORS._main_value_positive : COLORS._main_icon;
				var t  = __txtx("panel_inspector_dropper", "Node Dropper");
				var b  = buttonInstant(bsp, bx - bsh, by - bsh, bs, bs, _m, _hover, _focus, t, THEME.node_dropper, 0, cc);
				
				if(b) cHov = true;
				if(b == 2) NODE_DROPPER_TARGET = NODE_DROPPER_TARGET == jun? noone : jun;
			}
			
			if(jun.expUse || is(jun.editWidget, textArea)) {
				bx -= bs + ui(4);
				var cc = jun.popup_dialog == noone? COLORS._main_icon : COLORS._main_value_positive;
				var t  = __txtx("panel_inspector_pop_text", "Pop up Editor");
				var b  = buttonInstant_Pad(bsp, bx - bsh, by - bsh, bs, bs, _m, _hover, _focus, t, THEME.text_popup, 0, cc, 1, ui(8));
				
				if(b) cHov = true;
				if(b == 2) {
					if(jun.expUse)	jun.popup_dialog = dialogPanelCall(new Panel_Text_Editor(jun.express_edit, function() /*=>*/ {return context.expression},  jun));
					else			jun.popup_dialog = dialogPanelCall(new Panel_Text_Editor(jun.editWidget,   function() /*=>*/ {return context.showValue()}, jun));
					jun.popup_dialog.content.title = $"{jun.node.name} - {_name}";
				}
			}
			
			if(jun.bypass_junc) {
				bx -= bs + ui(4);
				var ic_b = jun.bypass_junc.visible? COLORS._main_icon_light : COLORS._main_icon;
				var t  = __txt("Bypass");
				var si = jun.bypass_junc.visible;
				var b  = buttonInstant_Pad(bsp, bx - bsh, by - bsh, bs, bs, _m, _hover, _focus, t, THEME.junction_bypass, si, ic_b)
				
				if(b) cHov = true;
				if(b == 2) {
					jun.bypass_junc.visible = !jun.bypass_junc.visible; 
					jun.node.refreshNodeDisplay();
				}
			}
		}
	#endregion
	
	if(!is(wid, widget)) return [ 0, true, cHov ];
	
	#region draw widget
		var labelWidth = max(lb_w, min(ww * 0.4, ui(200)));
		
		var editBoxX   = xx	+ !breakLine * labelWidth;
		var editBoxY   = breakLine? yy + lb_h + ui(4) : yy;
		var editBoxW   = (xx + ww) - editBoxX;
		var editBoxH   = breakLine? TEXTBOX_HEIGHT : lb_h;
		
		var _widH	   = breakLine? editBoxH : 0;
		var mbRight	   = true;
		
		if(jun.expUse) {
			var expValid = jun.expTree != noone && jun.expTree.validate();
			jun.express_edit.boxColor = expValid? COLORS._main_value_positive : COLORS._main_value_negative;
			jun.express_edit.rx = rx;
			jun.express_edit.ry = ry;
			
			jun.express_edit.setFocusHover(_focus, _hover);
			if(_focus) jun.express_edit.register(_scrollPane);
				
			var wd_h = jun.express_edit.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.expression, _m);
			_widH = wd_h - (TEXTBOX_HEIGHT * !breakLine);
			cHov  = cHov || jun.express_edit.inBBOX(_m);
			
			var un = jun.unit;
			if(un.reference != noone) {
				un.triggerButton.icon_index    = un.mode;
				un.triggerButton.tooltip.index = un.mode;
			}
		
		} else if(wid && jun.display_type != VALUE_DISPLAY.none) {
			wid.setFocusHover(_focus, _hover);
			
			if(jun.connect_type == CONNECT_TYPE.input) {
				wid.setInteract(jun.editable && !jun.hasJunctionFrom());
				if(_focus) wid.register(_scrollPane);
				
				if(is_instanceof(jun, __NodeValue_Dimension)) {
					var _proj = jun.attributes.use_project_dimension;
					
					wid.side_button.icon_index = _proj;
					wid.side_button.icon_blend = _proj? c_white : COLORS._main_icon;
				}
			} else {
				wid.setInteract(false);
			}
			
			var _show = jun.showValue();
			var param = new widgetParam(editBoxX, editBoxY, editBoxW, editBoxH, _show, jun.display_data, _m, rx, ry);
			    param.font = viewMode == INSP_VIEW_MODE.spacious? f_p2 : f_p3;
			    param.sep_axis = jun.sep_axis;
			
			switch(jun.type) {
				case VALUE_TYPE.float : 
				case VALUE_TYPE.integer : 
					switch(jun.display_type) {
						case VALUE_DISPLAY.puppet_control : 
						case VALUE_DISPLAY.transform : 
							param.h = viewMode == INSP_VIEW_MODE.spacious? param.h : lb_h;
							break;
					}
					break;
				
				case VALUE_TYPE.boolean : 
					if(is_instanceof(wid, checkBoxActive)) break;
					
					param.halign = breakLine? fa_left : fa_center;
					param.s      = editBoxH;
					
					if(!breakLine) {
						param.w = ww - min(ui(80) + ww * 0.2, ui(200));
						param.x = editBoxX + editBoxW - param.w;
					}
					break;
					
				case VALUE_TYPE.surface : 
				case VALUE_TYPE.d3Material : 
				case VALUE_TYPE.dynaSurface : 
					param.h = breakLine? ui(96) : ui(48);
					break;
				
			}
			
			_widH = wid.drawParam(param) ?? 0;
			if(breakLine) _widH += ui(4);
			else          _widH -= lb_h;
			
			_widH = max(0, _widH);
			cHov  = cHov || wid.inBBOX(_m);
			
			mbRight = mbRight && wid.right_click_block;
		}
	#endregion
	
	return [ _widH, mbRight, cHov ];
}	