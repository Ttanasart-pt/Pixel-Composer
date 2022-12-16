/// @description 
if(async_load[?"event_type"] == "file_drop") {
	dropping = async_load[?"filename"];
	array_push(drop_path, dropping);
}