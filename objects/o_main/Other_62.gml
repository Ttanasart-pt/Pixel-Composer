/// @description network
if(ds_map_exists(global.FILE_LOAD_ASYNC, async_load[? "id"])) {
	var cb = global.FILE_LOAD_ASYNC[? async_load[? "id"]];
	var callback = cb[0];
	var arguments = cb[1];
	
	callback(arguments);
}

asyncLoad(async_load);