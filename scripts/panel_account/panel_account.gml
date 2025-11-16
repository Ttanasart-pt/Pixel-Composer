function Panel_Account_Sign_In() : PanelContent() constructor {
	title     = "Log-in";
	auto_pin  = true;
	
	page = 0;
	
	w = ui(320);
	h = ui(320);
	
	#region login
		login_email    = ""; tb_login_email    = textBox_Text(function(t) /*=>*/ { login_email    = t; }).setAutoUpdate().setVAlign(fa_center).setEmpty();
		login_password = ""; tb_login_password = textBox_Text(function(t) /*=>*/ { login_password = t; }).setAutoUpdate().setVAlign(fa_center).setFormat(TEXT_AREA_FORMAT.password).setEmpty();
		
		logging_in = false;
		
		function doLogin() {
			logging_in = true;
			
			asyncCallGroup("social", FirebaseAuthentication_SignIn_Email(login_email, login_password), function(_params, _data) /*=>*/ {
				logging_in = false;
				
				if (_data[? "status"] == 200) {
			        noti_status("Login successfully!", noone, COLORS._main_value_positive);
			        loginAccount(login_email, login_password);
			        close();
			        
			    } else
			        noti_warning(_data[? "errorMessage"]);
			    
			} );
		}
		
		sc_login = new scrollPane(1, 1, function(_y, _m) {
			draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
			
			tb_login_email.register(sc_login);
			tb_login_password.register(sc_login);
			
			var _hover = sc_login.hover;
			var _focus = sc_login.active;
			
			var _w  = sc_login.surface_w;
			var _h  = sc_login.surface_h;
			var _yy = _y;
			
			var _cx = _w / 2;
			var _cy = _h / 2;
			
			var _cnw = min(ui(240), _w - ui(32));
			var _cnh = (TEXTBOX_HEIGHT + ui(18)) * 2 + TEXTBOX_HEIGHT * 2 - ui(16);
			
			var _x0 = _cx - _cnw / 2;
			var _y0 = _cy - _cnh / 2;
			
			var _email_valid    = login_email != "";
			var _password_valid = login_password != "";
			
			draw_sprite_ui_uniform(s_title, 0, _cx - ui(256 * .4), _y0 - ui(48), .4 * THEME_SCALE);
			
			_y0 += ui(16);
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text_add(_x0, _y0, "Email");
			_y0 += ui(2);
			
			var _param = new widgetParam(_x0, _y0, _cnw, TEXTBOX_HEIGHT, login_email, {}, _m).setFont(f_p2).setFocusHover(_focus, _hover, !logging_in);
			tb_login_email.drawParam(_param);
			_y0 += TEXTBOX_HEIGHT + ui(24);
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text_add(_x0, _y0, "Password");
			_y0 += ui(2);
			
			var _param = new widgetParam(_x0, _y0, _cnw, TEXTBOX_HEIGHT, login_password, {}, _m).setFont(f_code).setFocusHover(_focus, _hover, !logging_in);
			tb_login_password.drawParam(_param);
			_y0 += TEXTBOX_HEIGHT + ui(16);
			
			if(logging_in) {
				draw_sprite_ui(THEME.loading_s, 0, _cx, _y0+TEXTBOX_HEIGHT/2, 1, 1, current_time / 2, COLORS._main_icon, 1);
				
			} else if(buttonInstantGlass(_hover, _focus, _m[0], _m[1], _x0, _y0, _cnw, TEXTBOX_HEIGHT, "Login") == 2) {
				if(_email_valid && _password_valid)
					doLogin();
			}
			
			_y0 += TEXTBOX_HEIGHT + ui(8);
			if(buttonTextInstant(true, THEME.button_hide, _x0, _y0, _cnw, TEXTBOX_HEIGHT, _m, _focus, _hover, "", "Sign-up") == 2) {
				page = 1;
			}
			
			return _y - _yy;
		});
	#endregion
	
	#region sign up	
		signup_email     = ""; tb_signup_email     = textBox_Text(function(t) /*=>*/ { signup_email     = t; }).setAutoUpdate().setVAlign(fa_center).setEmpty();
		signup_password  = ""; tb_signup_password  = textBox_Text(function(t) /*=>*/ { signup_password  = t; }).setAutoUpdate().setVAlign(fa_center).setFormat(TEXT_AREA_FORMAT.password).setEmpty();
		signup_password2 = ""; tb_signup_password2 = textBox_Text(function(t) /*=>*/ { signup_password2 = t; }).setAutoUpdate().setVAlign(fa_center).setFormat(TEXT_AREA_FORMAT.password).setEmpty();
		
		signing_up = false;
		
		function doSignup() {
			signing_up = true;
			
			asyncCallGroup("social", FirebaseAuthentication_SignUp_Email(signup_email, signup_password), function(_params, _data) /*=>*/ {
				signing_up = false;
				
				if (_data[? "status"] == 200) {
			        noti_status("Signed up successfully!", COLORS._main_value_positive);
			        createAccount(_data[? "value"], signup_email);
			        page = 0;
			        
			    } else
			        noti_warning(_data[? "errorMessage"]);
			    
			} );
		}
		
		sc_signup = new scrollPane(1, 1, function(_y, _m) {
			draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
			
			tb_signup_email.register(sc_signup);
			tb_signup_password.register(sc_signup);
			tb_signup_password2.register(sc_signup);
			
			var _hover = sc_signup.hover;
			var _focus = sc_signup.active;
			
			var _w  = sc_signup.surface_w;
			var _h  = sc_signup.surface_h;
			var _yy = _y;
			
			var _cx = _w / 2;
			var _cy = _h / 2;
			
			var _cnw = min(ui(240), _w - ui(32));
			var _cnh = (TEXTBOX_HEIGHT + ui(18)) * 3 + TEXTBOX_HEIGHT * 2 - ui(16);
			
			var _x0 = _cx - _cnw / 2;
			var _y0 = _cy - _cnh / 2;
			
			var _email_valid     = signup_email != "";
			var _password_valid  = string_length(signup_password) >= 8;
			var _password2_valid = signup_password == signup_password2;
			
			tb_signup_password.setBoxColor(_password_valid?   c_white : COLORS._main_value_negative);
			tb_signup_password2.setBoxColor(_password2_valid? c_white : COLORS._main_value_negative);
			
			draw_sprite_ui_uniform(s_title, 0, _cx - ui(256 * .4), _y0 - ui(48), .4 * THEME_SCALE);
			
			_y0 += ui(16);
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text_add(_x0, _y0, "Email");
			_y0 += ui(2);
			
			var _param = new widgetParam(_x0, _y0, _cnw, TEXTBOX_HEIGHT, signup_email, {}, _m).setFont(f_p2).setFocusHover(_focus, _hover, !signing_up);
			tb_signup_email.drawParam(_param);
			_y0 += TEXTBOX_HEIGHT + ui(24);
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text_add(_x0, _y0, "Password");
			_y0 += ui(2);
			
			var _param = new widgetParam(_x0, _y0, _cnw, TEXTBOX_HEIGHT, signup_password, {}, _m).setFont(f_code).setFocusHover(_focus, _hover, !signing_up);
			tb_signup_password.drawParam(_param);
			_y0 += TEXTBOX_HEIGHT + ui(24);
			
			draw_set_text(f_p3, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text_add(_x0, _y0, "Re-entry Password");
			_y0 += ui(2);
			
			var _param = new widgetParam(_x0, _y0, _cnw, TEXTBOX_HEIGHT, signup_password2, {}, _m).setFont(f_code).setFocusHover(_focus, _hover, !signing_up);
			tb_signup_password2.drawParam(_param);
			_y0 += TEXTBOX_HEIGHT + ui(16);
			
			if(signing_up) {
				draw_sprite_ui(THEME.loading_s, 0, _cx, _y0+TEXTBOX_HEIGHT/2, 1, 1, current_time / 2, COLORS._main_icon, 1);
				
			} else if(buttonInstantGlass(_hover, _focus, _m[0], _m[1], _x0, _y0, _cnw, TEXTBOX_HEIGHT, "Sign up") == 2) {
				if(_email_valid && _password_valid)
					doSignup();
			}
			
			_y0 += TEXTBOX_HEIGHT + ui(8);
			if(buttonTextInstant(true, THEME.button_hide, _x0, _y0, _cnw, TEXTBOX_HEIGHT, _m, _focus, _hover, "", "Back") == 2) {
				page = 0;
			}
			
			return _yy - _y;
		});
	#endregion
		
	function drawContent(panel) {
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		var _sc = sc_login;
		
		switch(page) {
			case 0 :	
				title = "Login";
				_sc = sc_login;
				break;
				
			case 1 :	
				title = "Sign up";
				_sc = sc_signup;
				break;
				
		}
		
		_sc.verify(pw, ph);
		_sc.setFocusHover(pFOCUS, pHOVER);
		_sc.drawOffset(px, py, mx, my);
	}
}