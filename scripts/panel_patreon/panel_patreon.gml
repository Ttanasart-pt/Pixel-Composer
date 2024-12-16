global.PATREON_VERIFY_CODE = undefined;

function Panel_Patreon() : PanelContent() constructor {
	w = ui(480);
	h = ui(264);
	title = "Connect to Patreon";
	resizable = false;
	auto_pin  = true;
	
	mail = "";
	code = "";
	
	result = "";
	result_color = COLORS._main_text;
	
	page = 0;
	tb_email = new textBox(TEXTBOX_INPUT.text, function(_email) { mail = _email; });
	tb_code  = new textBox(TEXTBOX_INPUT.text, function(_code)  { code = _code;  });
	
	mail_checking = false;
	
	function mailCallback(response) {
		mail_checking = false;
		
		if (response[? "status"] != 200) {
			result = "Request error";
			result_color = COLORS._main_value_negative;
			return;
		}
		
		var val = response[? "value"];
		var map = json_try_parse(val);
		
		var keys = struct_get_names(map);
		if(array_empty(keys)) {
			result = "Patreon email not found";
			result_color = COLORS._main_value_negative;
			return;
		}
		
		var key    = keys[0];
		var member = map[$ key];
		var stat   = string_replace_all(string_lower(member.status), " ", "_");
		
		if(string_pos("active", stat) > 0) {
			var _mail   = member.email;
			var _code   = patreon_generate_activation_key(_mail); //yea we doing this on client now. 
			global.PATREON_VERIFY_CODE = _code;
			
			var _map = ds_map_create();
			
			_map[? "Api-Token"]    = patreon_get_email_token();
			_map[? "Content-Type"] = "application/json";
			
			var _body = {
				from: {
				    email: "verify@pixel-composer.com",
				    name: "Pixel Composer"
				},
				to: [ { email: _mail } ],
				template_uuid: "82b77e89-0343-4a20-a63d-063f4f8dcdfe",
				template_variables: { verification_code: _code }
			};
			
			http_request("https://send.api.mailtrap.io/api/send", "POST", _map, json_stringify(_body));
			page = 1;
			
			result = "Verification code has been send to your email.";
			result_color = COLORS._main_value_positive;
		} else {
			result = "Patreon membership not active";
			result_color = COLORS._main_value_negative;
		}
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var _yy = 16;
		draw_sprite(s_patreon_banner, 0, w / 2, _yy);
		_yy += 100 + 16;
		
		if(IS_PATREON) {
			var _y = (_yy + h) / 2;
			
			draw_set_text(f_p0, fa_center, fa_bottom, COLORS._main_value_positive);
			draw_text(w / 2, _y - 16, "Patreon verified, thank you for supporting Pixel Composer.\nRestart to enable extra contents.");
			
			var _bw = 200;
			var _bh = TEXTBOX_HEIGHT + ui(8);
			var _bx = w / 2 - _bw / 2;
		
			if(buttonInstant(THEME.button_def, _bx, _y, _bw, _bh, [ mx, my ], pHOVER, pFOCUS) == 2) {
				var path = DIRECTORY + "patreon";
				file_delete(path);
				IS_PATREON = false;
			}
			
			draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
			draw_text(_bx + _bw / 2, _y + _bh / 2, "Remove verification");
			return;
		}
		
		var _bw = 100;
		var _bh = TEXTBOX_HEIGHT;
		var _bx = w / 2 - _bw / 2;
		
		switch(page) {
			case 0 :
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text_inner);
				draw_text(w / 2, _yy, "Enter your Patreon email:");
				
				tb_email.setInteract(!mail_checking);
				tb_email.setFocusHover(pFOCUS, pHOVER);
				
				_yy += line_get_height();
				var _tb_param = new widgetParam(16, _yy, w - 32, TEXTBOX_HEIGHT, mail,, [ mx, my ]);
				tb_email.drawParam(_tb_param);
				
				_yy += TEXTBOX_HEIGHT + 12;
				if(!mail_checking) {
					if(buttonInstant(THEME.button_def, _bx, _yy, _bw, _bh, [ mx, my ], pHOVER, pFOCUS) == 2) {
						patreon_email_check(mail, mailCallback);
						mail_checking = true;
						result = "";
					}
				
					draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
					draw_text(_bx + _bw / 2, _yy + _bh / 2, "Submit");
				} else 
					draw_sprite_ext(THEME.loading_s, 0, w / 2, _yy + _bh / 2, 1, 1, current_time, COLORS._main_icon, 1);
				break;
				
			case 1 :
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text_inner);
				draw_text(w / 2, _yy, "Enter verification code:");
				
				tb_code.setInteract(true);
				tb_code.setFocusHover(pFOCUS, pHOVER);
				
				_yy += line_get_height();
				var _tb_param = new widgetParam(16, _yy, w - 32, TEXTBOX_HEIGHT, code,, [ mx, my ]);
				tb_code.drawParam(_tb_param);
				
				_yy += TEXTBOX_HEIGHT + 12;
				if(buttonInstant(THEME.button_def, _bx, _yy, _bw, _bh, [ mx, my ], pHOVER, pFOCUS) == 2) {
					if(code == global.PATREON_VERIFY_CODE) {
						result = "Patreon verified, thank you for suporting Pixel Composer!";
						result_color = COLORS._main_value_positive;
						
						patreon_create_verification_code($"pxc_legacy");
				    	IS_PATREON = true;
				    	
					} else {
						result = "Incorrect code.";
						result_color = COLORS._main_value_negative;
					}
				}
				
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
				draw_text(_bx + _bw / 2, _yy + _bh / 2, "Submit");
				break;
		}
		
		_yy += _bh + 4;
		draw_set_text(f_p0, fa_center, fa_top, result_color);
		draw_text(w / 2, _yy, result);
	}
}

