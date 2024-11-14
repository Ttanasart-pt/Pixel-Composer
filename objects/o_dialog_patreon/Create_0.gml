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
	
#endregion