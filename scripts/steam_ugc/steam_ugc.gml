function steam_ugc_create_collection(file) {
	if(STEAM_UGC_ITEM_UPLOADING) return;
	
	STEAM_UGC_UPDATE = false;
	STEAM_UGC_ITEM_UPLOADING = true;
	STEAM_UGC_ITEM_FILE = file;
	
	directory_destroy("steamUGC");
	directory_create("steamUGC");
	file_copy(file.path, "steamUGC/" + filename_name(file.path));
	file_copy(file.spr_path[0], "steamUGC/" + filename_name(file.spr_path[0]));
	
	STEAM_UGC_ITEM_ID = steam_ugc_create_item(STEAM_APP_ID, ugc_filetype_community);
}

function steam_ugc_update_collection(file) {
	if(STEAM_UGC_ITEM_UPLOADING) return;
	
	STEAM_UGC_UPDATE = true;
	STEAM_UGC_ITEM_UPLOADING = true;
	STEAM_UGC_ITEM_FILE = file;
	
	directory_destroy("steamUGC");
	directory_create("steamUGC");
	file_copy(file.path, "steamUGC/" + filename_name(file.path));
	file_copy(file.spr_path[0], "steamUGC/" + filename_name(file.spr_path[0]));
	
	STEAM_UGC_PUBLISH_ID = file.meta.file_id;
	STEAM_UGC_UPDATE_HANDLE = steam_ugc_start_item_update(STEAM_APP_ID, STEAM_UGC_PUBLISH_ID);
	
	steam_ugc_set_item_title(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.name);
	steam_ugc_set_item_description(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.description);
	steam_ugc_set_item_tags(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.tags);
	steam_ugc_set_item_content(STEAM_UGC_UPDATE_HANDLE, "steamUGC");
	
	STEAM_UGC_SUBMIT_ID = steam_ugc_submit_item_update(STEAM_UGC_UPDATE_HANDLE, "Updated");
}
