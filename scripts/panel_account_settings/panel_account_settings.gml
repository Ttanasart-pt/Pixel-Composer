function Panel_Account_Settings() : PanelContent() constructor {
	title     = "Account Settings";
	auto_pin  = true;
	
	page = 0;
	
	w = ui(320);
	h = ui(320);
	
	#region account
		account_display_name = ACCOUNT_DATA.displayName; 
		tb_account_display_name = textBox_Text(function(t) /*=>*/ { 
			ACCOUNT_DATA.displayName = t;
			account_display_name = t; 
			FirebaseAuthentication_ChangeDisplayName(t);
		}).setVAlign(fa_center).setEmpty();
		
		account_email = ACCOUNT_DATA.email;
		tb_account_email = textBox_Text(function(t) /*=>*/ { account_email = t; FirebaseAuthentication_ChangeEmail(t); }).setVAlign(fa_center).setEmpty();
		
		account_delete_step = 0;
		
		sc_account = new scrollPane(1, 1, function(_y, _m) {
			draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
			
			var _hover = sc_account.hover;
			var _focus = sc_account.active;
			
			var _w  = sc_account.surface_w;
			var _h  = sc_account.surface_h;
			var _yy = _y;
			
			var _cx = _w / 2;
			var _cy = _h / 2;
			
			var _cnw = min(ui(240), _w - ui(32));
			var _x0  = _cx - _cnw / 2;
			
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x0, _y, "Display Name");
			_y += line_get_height() + ui(2);
			
			var _param = new widgetParam(_x0, _y, _cnw, TEXTBOX_HEIGHT, account_display_name, {}, _m).setFont(f_p2).setFocusHover(_focus, _hover);
			tb_account_display_name.drawParam(_param);
			_y += TEXTBOX_HEIGHT + ui(8);
			
			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x0, _y, "Email");
			_y += line_get_height() + ui(2);
			
			var _param = new widgetParam(_x0, _y, _cnw, TEXTBOX_HEIGHT, account_email, {}, _m).setFont(f_p2).setFocusHover(_focus, _hover);
			tb_account_email.drawParam(_param);
			_y += TEXTBOX_HEIGHT + ui(8);
			
			if(STEAM_ENABLED) {
				var _linked = ACCOUNT_DATA.steamid == STEAM_ID;
				var _txt = _linked? "Unlink Steam ID" : "Link Steam ID";
				var _cc  = _linked? COLORS._main_value_negative : COLORS._main_value_positive;
				
				if(buttonInstantGlass(_hover, _focus, _m[0], _m[1], _x0, _y, _cnw, TEXTBOX_HEIGHT, _txt, .3, _cc) == 2) {
					var _sdata = json_stringify({ steamid: STEAM_ID });
					ACCOUNT_DATA.steamid = STEAM_ID;
					
					asyncCallGroup("social", FirebaseFirestore($"users/{ACCOUNT_ID}").Update(_sdata), function(_params, _data) /*=>*/ {
						if (_data[? "status"] != 200) { print(_data[? "errorMessage"]); return; }
					});
				}
			}
			_y += TEXTBOX_HEIGHT + ui(8);
			
			var _txt = account_delete_step == 0? "Delete Account" : "Click again to confirm";
			if(buttonInstantGlass(_hover, _focus, _m[0], _m[1], _x0, _y, _cnw, TEXTBOX_HEIGHT, _txt, .3, COLORS._main_value_negative) == 2) {
				if(account_delete_step == 0) {
					account_delete_step = 1; 
					
				} else {
					FirebaseAuthentication_DeleteAccount();
					close();
					PXC_Logout();
				}
			}
			_y += TEXTBOX_HEIGHT + ui(8);
			
			return _y - _yy;
		});
	#endregion
	
	function drawContent(panel) {
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		var _sc = sc_account;
		
		_sc.verify(pw, ph);
		_sc.setFocusHover(pFOCUS, pHOVER);
		_sc.drawOffset(px, py, mx, my);
	}
}