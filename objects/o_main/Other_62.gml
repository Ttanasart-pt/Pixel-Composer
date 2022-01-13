/// @description init
if (ds_map_find_value(async_load, "id") == version_check) {
    if (ds_map_find_value(async_load, "status") == 0) {
        var v = ds_map_find_value(async_load, "result");
		version_latest = toNumber(v);
    }
}