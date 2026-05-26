if(!active) return;

var _port  = async_load[? "port"];
if(port != _port) exit;

var type = async_load[? "type"];
switch(type) {
	case network_type_connect :    log($"Remote terminal connected",    noone, self); connected_device++; break;
	case network_type_disconnect : log($"Remote terminal disconnected", noone, self); connected_device--; break;
		
	case network_type_non_blocking_connect :
	case network_type_data :
		var _buffer = async_load[? "buffer"];
		var data    = buffer_get_string(_buffer);
		
		submitCommand(data);
		break;
}