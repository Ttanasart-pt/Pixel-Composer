/// @description 
if(asyncLoad(async_load)) exit;

var ev_id   = async_load[? "id"];
var ev_type = async_load[? "event_type"];
var _fid    = ds_map_try_get(async_load, "published_file_id", 0);

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

if(string(ev_id) == string(STEAM_UGC_ITEM_ID) && ev_type == "ugc_create_item") {
	STEAM_UGC_PUBLISH_ID    = _fid;
	STEAM_UGC_UPDATE_HANDLE = steam_ugc_start_item_update(STEAM_APP_ID, STEAM_UGC_PUBLISH_ID);
	
	steam_ugc_set_item_title(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.name);
	steam_ugc_set_item_description(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.description);
	steam_ugc_set_item_visibility(STEAM_UGC_UPDATE_HANDLE, ugc_visibility_public);
	
	var tgs = array_clone(STEAM_UGC_ITEM_FILE.meta.tags);
	switch(STEAM_UGC_TYPE) {
		case STEAM_UGC_FILE_TYPE.collection :	array_insert_unique(tgs, 0, "Collection");	break;
		
		case STEAM_UGC_FILE_TYPE.project :		
			array_insert_unique(tgs, 0, "Project");
			PROJECT.meta.file_id = STEAM_UGC_PUBLISH_ID;
			SAVE_AT(PROJECT, PROJECT.path);
			break;
			
		case STEAM_UGC_FILE_TYPE.node_preset :	array_insert_unique(tgs, 0, "Node preset");	break;
	}
	
	array_push_unique(tgs, VERSION_STRING);
	
	steam_ugc_set_item_tags(STEAM_UGC_UPDATE_HANDLE, tgs);
	steam_ugc_set_item_preview(STEAM_UGC_UPDATE_HANDLE, TEMPDIR + "steamUGCthumbnail.png");
	steam_ugc_set_item_content(STEAM_UGC_UPDATE_HANDLE, DIRECTORY + "steamUGC");
	
	STEAM_UGC_SUBMIT_ID = steam_ugc_submit_item_update(STEAM_UGC_UPDATE_HANDLE, "Initial upload");
	exit;
}

if(string(ev_id) == string(STEAM_UGC_SUBMIT_ID)) {
	STEAM_UGC_ITEM_UPLOADING = false;
	
	var type = "";
	switch(STEAM_UGC_TYPE) {
		case STEAM_UGC_FILE_TYPE.collection :	type = "Collection";	break;
		case STEAM_UGC_FILE_TYPE.project :		type = "Project";		break;
		case STEAM_UGC_FILE_TYPE.node_preset :	type = "Node preset";	break;
	}
	
	if(async_load[? "result"] == ugc_result_success) {
		if(STEAM_UGC_UPDATE) {
			noti_status($"Steam Workshop: {type} updated", THEME.workshop_update, true);
			PANEL_MENU.setNotiIcon(THEME.workshop_update);
			
		} else {
			noti_status($"Steam Workshop: {type} updated", THEME.workshop_upload, true);
			PANEL_MENU.setNotiIcon(THEME.workshop_upload);
		}
		
		STEAM_SUB_ID = steam_ugc_subscribe_item(STEAM_UGC_PUBLISH_ID);
		exit;
	} 
	
	var errStr = steam_ugc_get_error(async_load[? "result"]);
	if(errStr != "") noti_warning($"Steam: {errStr}");
}