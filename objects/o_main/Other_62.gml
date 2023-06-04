/// @description network
//if (ds_map_find_value(async_load, "id") == version_check) {
//    if (ds_map_find_value(async_load, "status") == 0) {
//        var v = ds_map_find_value(async_load, "result");
//		version_latest = toNumber(v);
//    }
//}

if(ds_map_exists(global.FILE_LOAD_ASYNC, async_load[? "id"])) {
	var cb = global.FILE_LOAD_ASYNC[? async_load[? "id"]];
	var callback = cb[0];
	var arguments = cb[1];
	
	callback(arguments);
}

asyncLoad(async_load);