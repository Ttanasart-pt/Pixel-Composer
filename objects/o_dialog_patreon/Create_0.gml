/// @description init
event_inherited();

#region data
	dialog_w = ui(480);
	dialog_h = ui(200);
	title_height         = ui(28);
	destroy_on_click_out = false;
	
	req_sign_in = "";
	req_auth    = ""; 
	
	attmp = 0;
	do {
		port = irandom_range(7000, 20000);
		server = network_create_server_raw(network_socket_ws, port, 32);
	} until(server >= 0 || attmp++ >= 100);
	
	var _url = @"www.patreon.com/oauth2/authorize?response_type=code
&client_id=oZ1PNvUY61uH0FiA7ZPMBy77Xau3Ok9tfvsT_Y8DQwyKeMNjaVC35r1qsK09QJhY
&redirect_uri=https://pixel-composer.com/verify";
	_url += $"&state={port}";

	url_open(_url);
#endregion