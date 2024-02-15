/// @description 
var _id = async_load[? "id"];

if(_id == TCP_SERVER) {
	var t = async_load[? "type"];
	
    if (t == network_type_connect) {
        var sock = ds_map_find_value(async_load, "socket");
		array_push(TCP_CLIENTS, sock);
		log_console($"Client connected: {sock}");
		
	} else if (t == network_type_disconnect) {
        var sock = ds_map_find_value(async_load, "socket");
		array_remove(TCP_CLIENTS, sock);
		log_console($"Client disconnected: {sock}");
		
    } else if (t == network_type_data) {
		var _buffer  = ds_map_find_value(async_load, "buffer"); 
		var cmd_type = buffer_read(_buffer, buffer_string );
		cmd_submit(cmd_type);
	}
	
	exit;
}

if(!ds_map_exists(PORT_MAP, _id)) exit;
var nodeTarget = PORT_MAP[? _id];
nodeTarget.asyncPackets(async_load);