/// @description init
if (ds_map_find_value(async_load, "id") == note_get) {
    if (ds_map_find_value(async_load, "status") == 0) {
        note = ds_map_find_value(async_load, "result");
		alarm[0] = 1;
	}
}