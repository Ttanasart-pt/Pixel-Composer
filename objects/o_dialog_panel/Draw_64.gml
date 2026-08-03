/// @description 
if !ready exit;

panel.preDraw();
var _cnt = panel.getContent();

#region dialog	
	DIALOG_DRAW_BG
	
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
	
	if(title_height) {
		cnx += 3;
		cny += 3;
		cnw -= 6;
		cnh -= 6;
	}
	
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
	panel.drawFrame();
	
	panel.drawGUI();
	
	// draw_set_color(sHOVER? c_lime : c_red); draw_rectangle(cnx, cny, cnx + cnw, cny + cnh, true);
#endregion

#region header
	var hov = sHOVER;
	var foc = sFOCUS;
	
	if(title_height) {
		var dx = _dialog_x + 3;
		var dy = _dialog_y + 3;
		var dw =  dialog_w - 6;
		var dh = title_height + 2;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, dx, dy, dw, dh, COLORS._main_icon_light, 1);
		
		var _bx = _dialog_x + dialog_w - ui(8);
		var _by = _dialog_y + ui(6);
		var _bs = ui(20);
		var overBut = content.title_actions_override && !array_empty(content.title_actions);
		
		if(instanceof(content) != "Panel_Menu" && !overBut) {
			var bb = THEME.button_hide_fill;
			
			if(buttonInstant(bb, _bx-_bs, _by, _bs, _bs, mouse_ui, hov, foc, "", THEME.window_exit_icon, 0, CARRAY.button_negative) == 2) {
				onDestroy();
				instance_destroy();
			} _bx -= _bs + ui(2);
			
		    if(is(_cnt, PanelContent)) {
				if(buttonInstant(bb, _bx-_bs, _by, _bs, _bs, mouse_ui, hov, foc, "", THEME.window_pan_icon) == 2) {
					_cnt.dragSurface = undefined;
					o_main.panel_dragging = _cnt;
					instance_destroy();
				} _bx -= _bs + ui(4);
		    }
		}
		
		for (var i = 0, n = array_length(content.title_actions); i < n; i++) {
			var _b   = content.title_actions[i];
			var _txt = array_safe_get(_b, 0);
			var _spr = array_safe_get(_b, 1);
			var _act = array_safe_get(_b, 2);
			var _par = array_safe_get(_b, 3);
			
			if(buttonInstant(THEME.button_hide_fill, _bx - _bs, _by, _bs, _bs, mouse_ui, hov, foc, _txt, _spr[0], _spr[1], _spr[2]) == 2)
				_act(_par);
			
			_bx -= _bs + ui(4);
		}
		
		var _tx   = _dialog_x + ui(32);
		var _scis = gpu_get_scissor();
		gpu_set_scissor(_tx, _dialog_y, _bx - _tx, title_height);
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_tx, _dialog_y + ui(8), title);
		gpu_set_scissor(_scis);
		
		var bx  = _dialog_x + ui(8);
		var by  = _dialog_y + ui(6);
		var txt = destroy_on_click_out? __txt("Pin") : __txt("Unpin");
		var cc  = destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light;
		var ind = !destroy_on_click_out;
		var ss  = ui(20);
		var sc  = 0.75;
		
		if(instanceof(content) != "Panel_Menu") {
			var b = buttonInstant(THEME.button_hide_fill, bx, by, ss, ss, mouse_ui, hov, foc, txt, THEME.pin, ind, cc, 1, sc);
			if(b == 2) destroy_on_click_out = !destroy_on_click_out;
		}
	}
#endregion

DIALOG_DRAW_FOCUS_UNEND

if(sFOCUS && !m_in && m_ot) {
	var p  = DIALOG_PAD;
	var p2 = DIALOG_PAD * 2;
	draw_sprite_stretched_ext(THEME.dialog, 1, _dialog_x - p, _dialog_y - p, dialog_w + p2, dialog_h + p2, c_white, 0.4);
	
	if(is(_cnt, PanelContent)) {
		if(DOUBLE_CLICK) {
			_cnt.dragSurface = undefined;
			o_main.panel_dragging = _cnt;
		
			instance_destroy();
			
		} else if(mouse_rpress()) {
			menuCall("panel_window_menu", [
				menuItem(__txt("Move"), function() /*=>*/ { 
					var _cnt = panel.getContent();
					if(!is(_cnt, PanelContent)) return;
			
					_cnt.dragSurface      = undefined;
					o_main.panel_dragging = _cnt;
					panel_mouse           = 1;
					
					instance_destroy();
				}),
			]);
		}
	}
}

if(is_winwin(window)) winwin_end();