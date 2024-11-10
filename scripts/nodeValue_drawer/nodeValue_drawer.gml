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

function drawWidget(xx, yy, ww, _m, jun, global_var = true, _hover = false, _focus = false, _scrollPane = noone, rx = 0, ry = 0) { 
	var con_w     = ww - ui(4);
	var xc	      = xx + ww / 2;
	var _font     = viewMode == INSP_VIEW_MODE.spacious? f_p1 : f_p2;
	var breakLine = viewMode == INSP_VIEW_MODE.spacious || jun.expUse;
	var lb_h      = line_get_height(_font, 6);
	var lb_y      = yy + lb_h / 2;
	
	var _name     = jun.getName();
	var wid       = jun.editWidget;
	var cHov      = false;
	
	switch(instanceof(wid)) {
		case "textArea"        : 
		case "controlPointBox" : 
		case "transformBox"    : 
			breakLine = true;
			break;
			
		case "matrixGrid" :
			breakLine |= wid.size > 5;
			break;
	}
	
	var butx = xx;
	if(jun.connect_type == CONNECT_TYPE.input && jun.isAnimable() && !jun.expUse) { // animation
		var index = jun.hasJunctionFrom()? 2 : jun.is_anim;
		
		var cc = c_white;
		if(jun.is_anim) cc = COLORS._main_value_positive;
		if(index == 2)  cc = COLORS._main_accent;
		
		draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, 1, cc, 0.8);
		if(_hover && point_in_circle(_m[0], _m[1], butx, lb_y, ui(10))) {
			cHov  = true;
			
			if(anim_hold != noone)
				jun.setAnim(anim_hold, true);
				
			draw_sprite_ui_uniform(THEME.animate_clock, index, butx, lb_y, 1, index == 2? COLORS._main_accent : c_white, 1);
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
		
	butx += ui(20);
	if(!global_var) { // visibility
		var _visi = jun.isVisible();
		
		draw_sprite_ui_uniform(THEME.junc_visible, _visi, butx, lb_y, 1,, 0.8);
		if(_hover && point_in_circle(_m[0], _m[1], butx, lb_y, ui(10))) {
			cHov  = true;
			
			if(visi_hold != noone && jun.visible_manual != visi_hold) {
				jun.visible_manual = visi_hold;
				jun.node.refreshNodeDisplay();
			}
			
			draw_sprite_ui_uniform(THEME.junc_visible, _visi, butx, lb_y, 1,, 1);
			TOOLTIP = __txt("Visibility");
				
			if(mouse_press(mb_left, _focus)) {
				jun.visible_manual = _visi? -1 : 1;
				
				visi_hold = jun.visible_manual;
				jun.node.refreshNodeDisplay();
			}
		}
	
	} else
		draw_sprite_ui_uniform(THEME.node_use_expression, 0, butx, lb_y, 1,, 0.8);
		
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
	var lb_w = ui(40 + 16) + string_width(_name);
	var lb_x = ui(40)      + xx;
	
	if(jun.color != -1) {
		draw_sprite_ext(THEME.timeline_color, 1, lb_x + ui(8), lb_y, 1, 1, 0, jun.color, 1);
		lb_x += ui(24);
		lb_w += ui(24);
	}
	
	if(!jun.active) {
		draw_set_text(_font, fa_left, fa_center, COLORS._main_text_sub_inner);
		draw_text_add(lb_x, lb_y - ui(2), _name);
		
		if(jun.active_tooltip != "") {
			var tx = xx + ui(40) + string_width(_name) + ui(16);
			var ty = lb_y - ui(1);
			
			if(point_in_circle(_m[0], _m[1], tx, ty, ui(10))) {
				cHov  = true;
				
				TOOLTIP = jun.active_tooltip;
				draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 1);
			} else 
				draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 0.75);
		}
		
		return [ 0, true, cHov ];
	}
	
	draw_text_add(lb_x, lb_y, _name);
			
	#region tooltip
		if(jun.tooltip != "") {
			var tx = xx + ui(40) + string_width(_name) + ui(16);
			var ty = lb_y - ui(1);
					
			if(point_in_circle(_m[0], _m[1], tx, ty, ui(10))) {
				cHov  = true;
				
				if(is_string(jun.tooltip))
					TOOLTIP = jun.tooltip;
				else if(mouse_click(mb_left, _focus))
					dialogCall(jun.tooltip);
				draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 1);
			} else 
				draw_sprite_ui(THEME.info, 0, tx, ty,,,, COLORS._main_icon_light, 0.75);
			
			lb_w += ui(32);
		}
	#endregion
			
	#region anim
		if(jun.connect_type == CONNECT_TYPE.input && breakLine && jun.is_anim) {
			var _anim = jun.animator;
			
			var bx = xx + ww - ui(12);
			var by = lb_y;
			var b  = buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, "", THEME.prop_keyframe, 2)
			
			if(b) cHov = true;
			if(b == 2) {
				for(var j = 0; j < array_length(_anim.values); j++) {
					var _key = _anim.values[j];
					if(_key.time > CURRENT_FRAME) {
						PROJECT.animator.setFrame(_key.time);
						break;
					}
				}
			}
						
			bx -= ui(26);
			var cc = COLORS.panel_animation_keyframe_unselected;
			var kfFocus = false;
			
			for(var j = 0; j < array_length(_anim.values); j++) {
				if(_anim.values[j].time == CURRENT_FRAME) {
					cc = COLORS.panel_animation_keyframe_selected;
					kfFocus = true;
					break;
				}
			}
			
			var _tlp = kfFocus? __txtx("panel_inspector_remove_key", "Remove keyframe") : __txtx("panel_inspector_add_key", "Add keyframe");
			var b    = buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, _tlp, THEME.prop_keyframe, 1, cc)
			
			if(b) cHov = true;
			if(b == 2) {
				var _remv = false;
				for(var j = 0; j < array_length(_anim.values); j++) {
					var _key = _anim.values[j];
					
					if(_key.time == CURRENT_FRAME) {
						_anim.removeKey(_key);
						_remv = true;
						break;
					}
				}
				
				if(!_remv) _anim.setValue(jun.showValue(), true, CURRENT_FRAME);
			}
						
			bx -= ui(26);
			var b = buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, "", THEME.prop_keyframe, 0)
			
			if(b) cHov = true;
			if(b == 2) {
				var _t = -1;
				for(var j = 0; j < array_length(_anim.values); j++) {
					var _key = _anim.values[j];
					if(_key.time < CURRENT_FRAME)
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
			
			var b = buttonInstant(THEME.button_hide, bx - ui(12), by - ui(12), ui(24), ui(24), _m, _focus, _hover, tooltip_loop_type, THEME.prop_on_end, jun.on_end)
			
			if(b)      cHov = true;
			if(b == 2) jun.on_end = safe_mod(jun.on_end + 1, sprite_get_number(THEME.prop_on_end));
		}
	#endregion
		
	#region right buttons
		if(jun.connect_type == CONNECT_TYPE.input && breakLine && !jun.is_anim && !global_var) {
			var bx  = xx + ww + ui(16);
			var by  = lb_y;
			var bs  = ui(24);
			var bsh = bs / 2;
			
			bx -= bs + ui(4);
			if(jun.is_modified) {
				var b = buttonInstant(THEME.button_hide, bx - bsh, by - bsh, bs, bs, _m, _focus, _hover, __txtx("panel_inspector_reset", "Reset value"), THEME.refresh_16, 0, COLORS._main_icon)
				if(b)      cHov = true;
				if(b == 2) jun.resetValue();
				
			} else 
				draw_sprite_ui(THEME.refresh_16, 0, bx, by,,,, COLORS._main_icon, 0.5);
			
			bx -= bs + ui(4);
			var ic_b = jun.expUse? c_white : COLORS._main_icon;
			var b = buttonInstant(THEME.button_hide, bx - bsh, by - bsh, bs, bs, _m, _focus, _hover, __txtx("panel_inspector_use_expression", "Use expression"), THEME.node_use_expression, jun.expUse, ic_b)
			
			if(b) cHov = true;
			if(b == 2) {
				jun.setUseExpression(!jun.expUse);
				
				if(!jun.expUse) WIDGET_CURRENT = noone;
			}
				
			if(jun.expUse) {
				bx -= bs + ui(4);
				var cc = NODE_DROPPER_TARGET == jun? COLORS._main_value_positive : COLORS._main_icon;
				var b  = buttonInstant(THEME.button_hide, bx - bsh, by - bsh, bs, bs, _m, _focus, _hover, __txtx("panel_inspector_dropper", "Node Dropper"), THEME.node_dropper, 0, cc)
				
				if(b) cHov = true;
				if(b == 2) NODE_DROPPER_TARGET = NODE_DROPPER_TARGET == jun? noone : jun;
			}
			
			if(jun.expUse || jun.type == VALUE_TYPE.text) {
				bx -= bs + ui(4);
				var cc = jun.popup_dialog == noone? COLORS._main_icon : COLORS._main_value_positive;
				var b  = buttonInstant(THEME.button_hide, bx - bsh, by - bsh, bs, bs, _m, _focus, _hover, __txtx("panel_inspector_pop_text", "Pop up Editor"), THEME.text_popup, 0, cc)
				
				if(b) cHov = true;
				if(b == 2) {
					if(jun.expUse)	jun.popup_dialog = dialogPanelCall(new Panel_Text_Editor(jun.express_edit, function() { return context.expression;  }, jun));
					else			jun.popup_dialog = dialogPanelCall(new Panel_Text_Editor(jun.editWidget,   function() { return context.showValue(); }, jun));
					jun.popup_dialog.content.title = $"{jun.node.name} - {_name}";
				}
			}
			
			if(jun.bypass_junc) {
				bx -= bs + ui(4);
				var ic_b = jun.bypass_junc.visible? COLORS._main_icon_light : COLORS._main_icon;
				var b = buttonInstant(THEME.button_hide, bx - bsh, by - bsh, bs, bs, _m, _focus, _hover, __txt("Bypass"), THEME.junction_bypass, jun.bypass_junc.visible, ic_b)
				
				if(b) cHov = true;
				if(b == 2) {
					jun.bypass_junc.visible = !jun.bypass_junc.visible; 
					jun.node.setHeight();
				}
			}
		}
	#endregion
	
	var _hsy       = yy + lb_h;
	var padd       = ui(8);
	var labelWidth = max(lb_w, min(ww * 0.4, ui(200)));
	var widExtend  = breakLine || jun.type == VALUE_TYPE.curve;
	
	var editBoxX   = xx	+ !widExtend * labelWidth;
	var editBoxY   = widExtend? _hsy : yy;
	var editBoxW   = (xx + ww) - editBoxX;
	var editBoxH   = widExtend? TEXTBOX_HEIGHT : lb_h;
	
	var widH	   = widExtend? editBoxH : 0;
	var mbRight	   = true;
		
	if(jun.expUse) { // expression editor
		var expValid = jun.expTree != noone && jun.expTree.validate();
		jun.express_edit.boxColor = expValid? COLORS._main_value_positive : COLORS._main_value_negative;
		jun.express_edit.rx = rx;
		jun.express_edit.ry = ry;
		
		jun.express_edit.setFocusHover(_focus, _hover);
		if(_focus) jun.express_edit.register(_scrollPane);
			
		var wd_h = jun.express_edit.draw(editBoxX, editBoxY, editBoxW, editBoxH, jun.expression, _m);
		widH  = wd_h - (TEXTBOX_HEIGHT * !widExtend);
		cHov |= jun.express_edit.inBBOX(_m);
		
		var un = jun.unit;
		if(un.reference != noone) {
			un.triggerButton.icon_index    = un.mode;
			un.triggerButton.tooltip.index = un.mode;
		}
	
	} else if(wid && jun.display_type != VALUE_DISPLAY.none) { // edit widget
		wid.setFocusHover(_focus, _hover);
		
		if(jun.connect_type == CONNECT_TYPE.input) {
			wid.setInteract(!jun.hasJunctionFrom());
			if(_focus) wid.register(_scrollPane);
			
			if(is_instanceof(jun, __NodeValue_Dimension)) {
				var _proj = jun.node.attributes.use_project_dimension;
				
				wid.side_button.icon_index = _proj;
				wid.side_button.icon_blend = _proj? c_white : COLORS._main_icon;
			}
		} else {
			wid.setInteract(false);
		}
		
		var _show = jun.showValue();
		var param = new widgetParam(editBoxX, editBoxY, editBoxW, editBoxH, _show, jun.display_data, _m, rx, ry);
		    param.font = viewMode == INSP_VIEW_MODE.spacious? f_p1 : f_p2;
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
				
				param.halign = widExtend? fa_left : fa_center;
				param.s      = editBoxH;
				
				if(!widExtend) {
					param.w = ww - min(ui(80) + ww * 0.2, ui(200));
					param.x = editBoxX + editBoxW - param.w;
				}
				break;
				
			case VALUE_TYPE.surface : 
			case VALUE_TYPE.d3Material : 
			case VALUE_TYPE.dynaSurface : 
				param.h = widExtend? ui(96) : ui(48);
				break;
			
			case VALUE_TYPE.curve :   
				if(point_in_rectangle(_m[0], _m[1], ui(32), _hsy, ui(32) + ww - ui(16), _hsy + wid.h))
					mbRight = false;
				break;
		}
		
		var _widH = wid.drawParam(param) ?? 0;
		widH  = _widH - (TEXTBOX_HEIGHT * !widExtend);
		cHov |= wid.inBBOX(_m)
		
		mbRight &= wid.right_click_block;
		
	} 
	
	return [ widH, mbRight, cHov ];
}	