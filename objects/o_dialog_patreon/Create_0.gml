/// @description init
event_inherited();

#region data
	dialog_w = ui(480);
	dialog_h = ui(240);
	title_height         = ui(28);
	destroy_on_click_out = false;
	
	campaign_id  = "2263128";
	req_patreon  = "";
	req_user     = "";
	req_member   = {};
	access_token = "";
	
	page   = 0;
	status = 0;
	
	tb_code = new textBox(TEXTBOX_INPUT.text, function(t) /*=>*/ { submit_code(t); });
	
	if(IS_PATREON) {
		txt       = "Patreon verified, thank you for supporting Pixel Composer!";
		server    = 0;
		
	} else {
		if(!os_is_network_connected()) {
			status = -1;
			txt = "No internet connection, please try again.";
			
		} else {
			txt = "Sign-in to Patreon on browser";
			var attmp = 0;
			do {
				port   = irandom_range(7000, 20000);
				server = network_create_server_raw(network_socket_ws, port, 32);
				
			} until(server >= 0 || attmp++ >= 100);
			
			if(server >= 0) {
				var _url  = "www.patreon.com/oauth2/authorize";
				    _url += "?response_type=code";
				    _url += "&client_id=oZ1PNvUY61uH0FiA7ZPMBy77Xau3Ok9tfvsT_Y8DQwyKeMNjaVC35r1qsK09QJhY";
				    _url += "&redirect_uri=https://pixel-composer.com/verify";
				    _url += "&scope=identity campaigns.members";
				    _url += "&state=" + string(port);
				
				url_open(_url);
				
			} else {
				status = -1;
				txt = "Cannot connect to Patreon, please try again.";
			}
		}
	}
	
	function submit_code(code) {
		code = string_trim(code);
		
		var _header = ds_map_create();
    	_header[? "User-Agent"]   = "pixelcomposer";
    	_header[? "Content-Type"] = "application/x-www-form-urlencoded";
    	
    	var _content  = $"code={code}";
			_content += $"&grant_type=authorization_code";
			_content += $"&client_id=oZ1PNvUY61uH0FiA7ZPMBy77Xau3Ok9tfvsT_Y8DQwyKeMNjaVC35r1qsK09QJhY";
			_content += $"&client_secret=winWb1rAgSGUn9JBXxCjWqIb7EYkfYWO9j4nK_Stmg4W_wtKbdE30ckqvcwcCn2o";
			_content += $"&redirect_uri=https://pixel-composer.com/verify";
		
    	req_patreon = http_request("https://www.patreon.com/api/oauth2/token", "POST", _header, _content);
    	ds_map_destroy(_header);
    	
    	page = 1;
	}
#endregion