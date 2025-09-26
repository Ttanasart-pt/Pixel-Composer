function __initSteamUGC() {
	
	globalvar STEAM_SUBS;        STEAM_SUBS        = ds_list_create();
	globalvar STEAM_COLLECTION;  STEAM_COLLECTION  = [];
	globalvar STEAM_PROJECTS;    STEAM_PROJECTS    = [];
	globalvar STEAM_TAGS;        STEAM_TAGS        = [];
	globalvar STEAM_SUBS_IDS;    STEAM_SUBS_IDS    = {};
	globalvar STEAM_SUBSCRIBING; STEAM_SUBSCRIBING = {};
	
	if(DEMO) return;
	if(!STEAM_ENABLED) return;
	
	directory_verify(DIRECTORY + "steamUGC");
	try { steamUCGload(); } catch(e) { log_message("SESSION", $"> init SteamUGC      | error {e}"); }
}

function steamUCGload() {
	ds_list_clear(STEAM_SUBS);
	STEAM_COLLECTION = [];
	STEAM_PROJECTS = [];
	STEAM_TAGS     = [];
	
	steam_ugc_get_subscribed_items(STEAM_SUBS);
	
	for( var i = 0; i < ds_list_size(STEAM_SUBS); i++ ) {
		var item_map = ds_map_create();
		
		if (steam_ugc_get_item_install_info(STEAM_SUBS[| i], item_map)) {
			var info_map = ds_map_create();
			var _update  = false;
			
			if (steam_ugc_get_item_update_info(STEAM_SUBS[| i], info_map))
			    _update = info_map[? "needs_update"];
			
			ds_map_destroy(info_map);
			
			if(_update) steam_ugc_subscribe_item(STEAM_SUBS[| i]);
			else        __loadSteamUGC(STEAM_SUBS[| i], item_map);
		} else
			steam_ugc_subscribe_item(STEAM_SUBS[| i]);
		
		ds_map_destroy(item_map);
	}
}

function __loadSteamUGC(file_id, item_map) {
	var _path = item_map[? "folder"];
	
	var f = file_find_first(_path + "/*.pxcc", 0); file_find_close();
	if(f != "") { __loadSteamUGCCollection(file_id, f, _path); return; }
	
	var p = file_find_first(_path + "/*.pxc", 0); file_find_close();
	if(p != "") { __loadSteamUGCProject(file_id, p, _path); return; }
}

function __loadSteamUGCCollection(file_id, f, path) {
	if(filename_ext_raw(f) != "pxcc") return;
	
	var fullPath  = $"{path}/{f}";
	var name      = filename_name_only(f);
	var file      = new FileObject(fullPath);
	var icon_path = string_replace(fullPath, ".pxcc", ".png");
	
	if(file_exists_empty(icon_path)) {
		var _temp = sprite_add(icon_path, 0, false, false, 0, 0);
		if(sprite_exists(_temp)) {
			var ww    = sprite_get_width(_temp);
			var hh    = sprite_get_height(_temp);
			var amo   = safe_mod(ww, hh) == 0? ww / hh : 1;
			sprite_delete(_temp);
			file.spr_path = [ icon_path, amo, false ];
		}
	}
	
	array_push(STEAM_COLLECTION, file);
		
	var meta = file.getMetadata(true);
	meta.file_id = file_id;
	
	STEAM_SUBS_IDS[$ file_id] = file;
}

function __loadSteamUGCProject(file_id, f, path) {
	if(!path_is_project(f, false)) return;
	
	var fullPath  = $"{path}/{f}";
	var name      = filename_name_only(f);
	var file      = new FileObject(fullPath);
	var icon_path = path + "/thumbnail.png";
	
	if(file_exists_empty(icon_path)) {
		var _temp = sprite_add(icon_path, 0, false, false, 0, 0);
		if(sprite_exists(_temp)) {
			var ww    = sprite_get_width(_temp);
			var hh    = sprite_get_height(_temp);
			var amo   = safe_mod(ww, hh) == 0? ww / hh : 1;
			sprite_delete(_temp);
			
			file.spr_path = [ icon_path, amo, false ];
		}
	}
	
	array_push(STEAM_PROJECTS, file);
	
	var meta     = file.getMetadata(true);
	meta.file_id = file_id;
	
	for (var i = 0, n = array_length(meta.tags); i < n; i++)
		array_push_unique(STEAM_TAGS, meta.tags[i]);
		
	STEAM_SUBS_IDS[$ file_id] = file;
}

function UGC_subscribe_item(file_id) {
	var _id = steam_ugc_subscribe_item(file_id);
	STEAM_SUBSCRIBING[$ file_id] = _id;
	
	asyncCall(_id, function(_params, _data) /*=>*/ {
		var _result = _data[? "result"];
			
		if(_result != ugc_result_success) {
			var errStr = steam_ugc_get_error(_result);
			noti_warning($"UGC subscribe error {_result}: {errStr}");
			return;
		}
	});
	
}

function UGC_unsubscribe_item(file_id) {
	var _id = steam_ugc_unsubscribe_item(file_id);
	struct_remove(STEAM_SUBS_IDS, file_id);
	// STEAM_SUBSCRIBING[$ file_id] = _id;
	
	asyncCall(_id, function(_params, _data) /*=>*/ {
		var _result = _data[? "result"];
			
		if(_result != ugc_result_success) {
			var errStr = steam_ugc_get_error(_result);
			noti_warning($"UGC unsubscribe error {_result}: {errStr}");
			return;
		}
	});
	
}