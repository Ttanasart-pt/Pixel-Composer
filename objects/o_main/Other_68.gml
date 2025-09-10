/// @description 
if(asyncLoad(async_load)) exit;

var _id = async_load[? "id"];
var _nid = $"net_{struct_names_count(NETWORK_LOG_DATA)}";

NETWORK_LOG_DATA[$ _nid] = ds_map_print(async_load);
array_push(NETWORK_LOG, new notification(NOTI_TYPE.internal, $"Received network event {_nid}"));

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