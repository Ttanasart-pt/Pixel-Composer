/// @description 
var ev_id   = async_load[? "id"];
var ev_type = async_load[? "event_type"];

if(asyncLoad(async_load, "id", "steam")) exit;

var _fid = ds_map_try_get(async_load, "published_file_id", 0);

if(has(STEAM_SUBSCRIBING, _fid)) {
	if(ev_type == "ugc_item_subscribed") {
		STEAM_SUBS_IDS[$ _fid] = undefined;
	}
	
	if(ev_type == "ugc_item_installed") {
		var item_map = ds_map_create();
		steam_ugc_get_item_install_info(_fid, item_map)
		__loadSteamUGC(_fid, item_map);
		
		ds_map_destroy(item_map);
		struct_remove(STEAM_SUBSCRIBING, _fid);
	}
	exit;
}