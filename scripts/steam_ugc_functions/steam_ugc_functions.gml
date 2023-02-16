function __initSteamUGC() {
	globalvar STEAM_SUBS, STEAM_COLLECTION, STEAM_PROJECTS;
	STEAM_SUBS = ds_list_create();
	STEAM_COLLECTION = ds_list_create();
	STEAM_PROJECTS   = ds_list_create();
	
	if(DEMO) return;
	if(!STEAM_ENABLED) return;
	
	steam_ugc_get_subscribed_items(STEAM_SUBS);
	
	for( var i = 0; i < ds_list_size(STEAM_SUBS); i++ ) {
		var item_map = ds_map_create();
		//print("Querying item ID " + string(STEAM_SUBS[| i]));
		
		if (steam_ugc_get_item_install_info(STEAM_SUBS[| i], item_map)) {
			var info_map = ds_map_create();
			var _update  = false;
			
			if (steam_ugc_get_item_update_info(STEAM_SUBS[| i], info_map))
			    _update = info_map[? "needs_update"];
			
			ds_map_destroy(info_map);
			
			if(_update) {
				steam_ugc_subscribe_item(STEAM_SUBS[| i]);
				//print("Item need update");
			} else {
				__loadSteamUGC(STEAM_SUBS[| i], item_map);
			}
		} else {
			steam_ugc_subscribe_item(STEAM_SUBS[| i]);
			//print("Item not downloaded");
		}
		
		ds_map_destroy(item_map);
	}
}

function __loadSteamUGC(file_id, item_map) {
	var _path = item_map[? "folder"];
	
	var f = file_find_first(_path + "\\*.pxcc", 0);
	file_find_close();
	if(f != "") {
		__loadSteamUGCCollection(file_id, f, _path);
		return;
	}
	
	var p = file_find_first(_path + "\\*.pxc", 0);
	file_find_close();
	if(p != "") {
		__loadSteamUGCProject(file_id, p, _path);
		return;
	}
}

function __loadSteamUGCCollection(file_id, f, path) {
	var name = string_replace(filename_name(f), ".pxc", "");
	var file = new FileObject(name, path + "\\" + f);
	var icon_path = string_replace(path + "\\" + f, ".pxcc", ".png");
	if(file_exists(icon_path)) {
		var _temp = sprite_add(icon_path, 0, false, false, 0, 0);
		var ww = sprite_get_width(_temp);
		var hh = sprite_get_height(_temp);
		var amo = ww % hh == 0? ww / hh : 1;
		sprite_delete(_temp);
		file.spr_path = [icon_path, amo, false];
	}
	
	ds_list_add(STEAM_COLLECTION, file);
				
	var meta = file.getMetadata();
	meta.steam = true;
	meta.file_id = file_id;
}

function __loadSteamUGCProject(file_id, f, path) {
	var name = string_replace(filename_name(f), ".pxc", "");
	var file = new FileObject(name, path + "\\" + f);
	var icon_path = path + "\\thumbnail.png";
	file.spr_path = [icon_path, 1, false];
	
	ds_list_add(STEAM_PROJECTS, file);
	
	var meta = file.getMetadata();
	meta.steam = true;
	meta.file_id = file_id;
}
