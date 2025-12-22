/// @description network
if(asyncLoad(async_load, "id", "http")) exit;

var _id  = async_load[? "id"];

if(ds_map_exists(global.FILE_LOAD_ASYNC, async_load[? "id"])) {
	var cb = global.FILE_LOAD_ASYNC[? async_load[? "id"]];
	var callback = cb[0];
	var arguments = cb[1];
	
	callback(arguments);
}