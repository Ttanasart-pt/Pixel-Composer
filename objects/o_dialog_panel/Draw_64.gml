/// @description 
if !ready exit;

panel.preDraw();
var _cnt = panel.getContent();

#region dialog	
	// DIALOG_DRAW_BG
	DIALOG_WINDOW_START
	
	if(!auto_hide || sFOCUS) {
		var dpd = THEME_VALUE.dialog_padding;
		if(!is_winwin(window)) draw_sprite_stretched( THEME.dialog_shadow, 0, _dialog_x-dpd, _dialog_y-dpd, dialog_w+dpd*2, dialog_h+dpd*2 );
		draw_sprite_stretched( THEME.dialog, 0, _dialog_x, _dialog_y, dialog_w, dialog_h );
	}
	
	var p = ui(8);
	var m_in = point_in_rectangle(mouse_mx, mouse_my, _dialog_x + p, _dialog_y + p, _dialog_x + dialog_w - p, _dialog_y + dialog_h - p);
	var m_ot = point_in_rectangle(mouse_mx, mouse_my, _dialog_x, _dialog_y, _dialog_x + dialog_w, _dialog_y + dialog_h);
	var m_task = mouse_mys <= _dialog_y + title_height;
#endregion

#region content
	var cnx = _dialog_x + padding;
	var cny = _dialog_y + padding + title_height;
	var cnw =  dialog_w -  padding * 2;
	var cnh =  dialog_h - (padding * 2 + title_height);
	
	panel.x = cnx;
	panel.y = cny;
	
	if(_dialog_w != dialog_w || _dialog_h != dialog_h) {
		_dialog_w = dialog_w;
		_dialog_h = dialog_h;
		panel_toRefresh = true;
	}
	
	if(panel_toRefresh) {
		panel.w = cnw;
		panel.h = cnh;
		
		panel.refreshSize(true);
		panel_toRefresh = false;
	}
	
	panel.verify(cnw, cnh);
	
	panel.step();
	
	panel.draw();
	panel.drawFrame(true);
	
	panel.drawGUI();
	
	// draw_set_color(sHOVER? c_lime : c_red); draw_rectangle(cnx, cny, cnx + cnw, cny + cnh, true);
#endregion

#region header
	var hov = sHOVER;
	var foc = sFOCUS;
	var x1 = _dialog_x + dialog_w - ui(6);
	
	if((!auto_hide || sFOCUS) && title_height) {
		var dh = title_height;
		draw_sprite_stretched_ext( THEME.dialog, 3, _dialog_x, _dialog_y, _dialog_w, dh, COLORS._main_icon_light, 1);
		
		var bb = MAC? noone : THEME.button_hide_fill;
		var bs = ui(20);
		var bp = MAC? bs + 1 : bs + ui(2);
		
		var bx = MAC? _dialog_x + ui(6) : _dialog_x + dialog_w - ui(6) - bs;
		var by = _dialog_y + dh / 2 - bs / 2;
		var overBut = content.title_actions_override && !array_empty(content.title_actions);
		
		if(instanceof(content) != "Panel_Menu" && !overBut) {
			var bc = MAC? c_white : CARRAY.button_negative;
			var bi = MAC? [action_button_hovering,1] : 0;
			if(buttonInstant(bb, bx, by, bs, bs, mouse_ui, hov, foc, "", THEME.window_exit_icon, bi, bc) == 2) {
				onDestroy();
				instance_destroy();
			}
			bx -= bp * (MAC? -1 : 1);
			
		    if(is(_cnt, PanelContent)) {
		    	var bc = [ COLORS._main_icon, COLORS._main_icon_light ];
				if(buttonInstant(bb, bx, by, bs, bs, mouse_ui, hov, foc, "", THEME.window_pan_icon, 0, bc) == 2) {
					_cnt.dragSurface = undefined;
					PANEL_DRAGGING = _cnt;
					instance_destroy();
				} 
				bx -= bp * (MAC? -1 : 1);
		    }
		}
		
		for (var i = 0, n = array_length(content.title_actions); i < n; i++) {
			var _b   = content.title_actions[i];
			var _txt = array_safe_get(_b, 0);
			var _spr = array_safe_get(_b, 1);
			var _act = array_safe_get(_b, 2);
			var _par = array_safe_get(_b, 3);
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, hov, foc, _txt, _spr[0], _spr[1], _spr[2]) == 2)
				_act(_par);
			
			bx -= bp * (MAC? -1 : 1);
		}
		
		if(instanceof(content) != "Panel_Menu") {
			if(!MAC) bx = _dialog_x + ui(6);
			
			var txt = "";//destroy_on_click_out? __txt("Pin") : __txt("Unpin");
			var bc  = [ COLORS._main_icon, COLORS._main_icon_light ];
			var ind = !destroy_on_click_out;
			
			var b  = buttonInstant(bb, bx, by, bs, bs, mouse_ui, hov, foc, txt, THEME.window_pin_icon, ind, bc, 1, .75);
			bx += bs + ui(2);
			if(b == 2) destroy_on_click_out = !destroy_on_click_out;
		}
		
		action_button_hovering = hov && point_in_rectangle(mouse_mx, mouse_my, _dialog_x, _dialog_y, bx, _dialog_y + dh);
		
		var _tx   = bx + ui(2);
		var _scis = gpu_get_scissor();
		gpu_set_scissor(_tx, _dialog_y, x1 - _tx, title_height);
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(_tx, _dialog_y + dh / 2, title);
		gpu_set_scissor(_scis);
		
	}
#endregion

if(!auto_hide || sFOCUS) {
	DIALOG_DRAW_FOCUS_UNEND
}

if(sFOCUS && !m_in && m_ot) {
	draw_sprite_stretched_ext(THEME.dialog, 1, _dialog_x, _dialog_y, dialog_w, dialog_h, c_white, .4);
	
	if(is(_cnt, PanelContent)) {
		if(DOUBLE_CLICK) {
			_cnt.dragSurface = undefined;
			PANEL_DRAGGING = _cnt;
		
			instance_destroy();
			
		} else if(mouse_rpress()) {
			menuCall("panel_window_menu", [
				menuItem(__txt("Move"), function() /*=>*/ { 
					var _cnt = panel.getContent();
					if(!is(_cnt, PanelContent)) return;
			
					_cnt.dragSurface = undefined;
					PANEL_DRAGGING   = _cnt;
					PANEL_DRAG_MOUSE      = 1;
					
					instance_destroy();
				}),
			]);
		}
	}
}

if(HOVER_WINDOW == window)
	PANEL_DRAW_DRAG();

if(is_winwin(window)) winwin_end();