/// @description init
event_inherited();

#region data
	dialog_w = ui(480);
	dialog_h = ui(200);
	title_height         = ui(28);
	destroy_on_click_out = false;
	
	req_sign_in = "";
	
	var port = 6510;
	// do {
		server = network_create_server_raw(network_socket_tcp, port, 32);
	// } until(server >= 0 || port >= 65535);
	
	// show_debug_message($"Create new server at {port}");
#endregion