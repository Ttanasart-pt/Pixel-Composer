/// @description 
var ev_id = async_load[? "id"];
var ev_type = async_load[? "event_type"];

if(ev_type == "file_drop") {
	dropping = async_load[?"filename"];
	array_push(drop_path, dropping);
}