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

function destroyServer() {
	if(client == undefined) return;
	network_destroy(client);
	client = undefined;
	log($"Terminated current server");
}

function refreshServer() {
	destroyServer();
	client = network_create_server_raw(network_socket_ws, port, 16);
	log($"Created new server at port {port}");
} 

function setPort(_port) { if(port == _port) return; port = _port; refreshServer(); }

function log(txt) { array_push(outputLog, txt); return self; }

function submitCommand(data) {
	var dataLines = string_split(data, "\n", true);
	
	for( var i = 0, n = array_length(dataLines); i < n; i++ ) {
		var _cmd = dataLines[i];
		
		log($"> {_cmd}");
		var res = cmd_submit(_cmd);
		if(is_string(res) && res != "") log(res);
	}
}

function activate()   { if( active) return; refreshServer(); active =  true; }
function deactivate() { if(!active) return; destroyServer(); active = false; }

function serialize() { return { type, active, port }; }
function deserialize(_m) {
	type   = _m[$ "type"]   ?? type;
	active = _m[$ "active"] ?? active;
	port   = _m[$ "port"]   ?? port;
	
	if(active) refreshServer();
	else destroyServer();
	return self;
}

refreshServer();