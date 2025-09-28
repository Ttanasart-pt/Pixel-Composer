function steam_ugc_create_project() {
	if(STEAM_UGC_UPLOADING) return;
	STEAM_UGC_UPLOADING = true;
	
	asyncCallGroup("steam", steam_ugc_create_item(STEAM_APP_ID, ugc_filetype_community), function( _params, _data ) /*=>*/ {
		var _fid = _data[? "published_file_id"] ?? 0;
		var _dir = DIRECTORY + "steamUGC";
		directory_clear(_dir);
		
		var _fname = filename_name_only(PROJECT.path);
		var _fpath = $"{_dir}/{filename_name(PROJECT.path)}";
		var _mpath = $"{_dir}/{_fname}.meta";
		
		PROJECT.meta.author_steam_id = STEAM_USER_ID;
		PROJECT.meta.file_id         = _fid;
	    SAVE_AT(PROJECT, _fpath, new save_param(true, "Save UGC", false));
		json_save_struct(_mpath, PROJECT.meta);
		
		steam_ugc_generate_thumbnail(PANEL_PREVIEW.getNodePreviewSurface(), UGC_TYPE.project);
		
		var _han = steam_ugc_start_item_update(STEAM_APP_ID, _fid);
		steam_ugc_set_item_title(       _han, _fname                            );
		steam_ugc_set_item_description( _han, PROJECT.meta.description          );
		steam_ugc_set_item_visibility(  _han, ugc_visibility_public             );
		steam_ugc_set_item_preview(     _han, TEMPDIR + "steamUGCthumbnail.png" );
		steam_ugc_set_item_content(     _han, _dir                              );
		
		var tgs = array_clone(PROJECT.meta.tags);
		array_insert_unique(tgs, 0, "Project");
		array_push_unique(tgs, VERSION_STRING);
		steam_ugc_set_item_tags(_han, tgs);
		
		asyncCallGroup("steam", steam_ugc_submit_item_update(_han, "Initial upload"), function( _params, _data ) /*=>*/ {
			STEAM_UGC_UPLOADING = false;
			if(_data[? "result"] != ugc_result_success) { noti_warning($"Steam: {steam_ugc_get_error(_data[? "result"])}"); return; } 
			
			var _fid = _params.fileid;
			
			noti_status($"Steam Workshop: Project uploaded [id: {_fid}]", THEME.workshop_upload, true);
			PANEL_MENU.setNotiIcon(THEME.workshop_upload);
			UGC_subscribe_item(_fid);
			HUB_link_file_id(_fid);
			
		}, { fileid: _fid });
		
	});
}

function steam_ugc_update_project(update_preview = false, update_note = "Updated") {
	if(STEAM_UGC_UPLOADING) return;
	STEAM_UGC_UPLOADING = true;
	
	var _fid = PROJECT.meta.file_id;
	var _dir = DIRECTORY + "steamUGC"
	directory_clear(_dir);
	
	var _fname = filename_name_only(PROJECT.path);
	var _fpath = $"{_dir}/{filename_name(PROJECT.path)}";
	var _mpath = $"{_dir}/{_fname}.meta";
	
	SAVE_AT(PROJECT, _fpath, new save_param(true, "Save UGC", false));
	if(file_exists_empty(PROJECT.thumbnail))
		file_copy(PROJECT.thumbnail, $"{_dir}/thumbnail.png");
	json_save_struct(_mpath, PROJECT.meta);
	
	var _han = steam_ugc_start_item_update(STEAM_APP_ID, _fid);
	steam_ugc_set_item_title(       _han, _fname                   );
	steam_ugc_set_item_description( _han, PROJECT.meta.description );
	steam_ugc_set_item_content(     _han, _dir                     );
	
	var tgs = PROJECT.meta.tags;
	array_insert_unique(tgs, 0, "Project");
	array_push_unique(tgs, VERSION_STRING);
	steam_ugc_set_item_tags(_han, tgs);
	
	if(update_preview) {
		steam_ugc_generate_thumbnail(PANEL_PREVIEW.getNodePreviewSurface(), UGC_TYPE.project);
		if(file_exists_empty(TEMPDIR + "steamUGCthumbnail.png")) steam_ugc_set_item_preview(_han, TEMPDIR + "steamUGCthumbnail.png");
	}
		
	asyncCallGroup("steam", steam_ugc_submit_item_update(_han, update_note), function( _params, _data ) /*=>*/ {
		STEAM_UGC_UPLOADING = false;
		if(_data[? "result"] != ugc_result_success) { noti_warning($"Steam: {steam_ugc_get_error(_data[? "result"])}"); return; } 
		
		var _fid = _data[$ "fileid"] ?? 0;
		noti_status($"Steam Workshop: Project updated", THEME.workshop_upload, true);
		PANEL_MENU.setNotiIcon(THEME.workshop_upload);
		
	}, { fileid: _fid });
}