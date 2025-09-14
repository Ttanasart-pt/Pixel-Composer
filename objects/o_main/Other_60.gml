/// @description 
if(asyncLoad(async_load, "id", "image")) exit;

if(!ds_map_exists(IMAGE_FETCH_MAP, async_load[? "id"])) exit;

var _callback = IMAGE_FETCH_MAP[? async_load[? "id"]];
_callback(async_load);