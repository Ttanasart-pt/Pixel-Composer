/// @description 
event_inherited();

#region addon
	panels    = {}
	panelMain = Remote_Terminal_Settings;
#endregion

#region remote
	type = 2; // 0: TCP, 1: UDP, 2: Websocket
	
	active = true;
	port   = 22400;
	client = undefined;
	
	connected_device = 0;
	
	outputLog = [];
#endregion

function destroyClient() {
	if(client == undefined) return;
	network_destroy(client);
	log($"Terminated current client");
}

function refreshClient() {
	destroyClient();
	client = network_create_server_raw(network_socket_ws, port, 16);
	log($"Created new client at port {port}");
} 

function setPort(_port) { port = _port; refreshClient(); }

function log(txt) { array_push(outputLog, txt); return self; }

refreshClient();