function steam_ugc_create_collection(file) {
	if(STEAM_UGC_UPLOADING) return;
	STEAM_UGC_UPLOADING = true;
	
	asyncCallGroup("steam", steam_ugc_create_item(STEAM_APP_ID, ugc_filetype_community), function( _params, _data ) /*=>*/ {
		var _fid = _data[? "published_file_id"] ?? 0;
		var _dir = DIRECTORY + "steamUGC";
		var file = _params.file;
		directory_clear(_dir);
		
		var _mpath = file.meta_path;
		var _meta  = json_load_struct(_mpath);
		_meta.file_id = _fid;
		json_save_struct(_mpath, _meta);
		
		file_copy(file.path,      $"{_dir}/{filename_name(file.path     )}");
		file_copy(file.meta_path, $"{_dir}/{filename_name(file.meta_path)}");
		
		if(array_safe_get_fast(file.spr_data, 0) != 0)
			file_copy(file.spr_data[0], $"{_dir}/{filename_name(file.spr_data[0])}");
		
		steam_ugc_generate_thumbnail(array_safe_get_fast(file.spr_data, 0), UGC_TYPE.collection);
		
		var _han = steam_ugc_start_item_update(STEAM_APP_ID, _fid);
		steam_ugc_set_item_title(       _han, file.meta.name                    );
		steam_ugc_set_item_description( _han, file.meta.description             );
		steam_ugc_set_item_visibility(  _han, ugc_visibility_public             );
		steam_ugc_set_item_preview(     _han, TEMPDIR + "steamUGCthumbnail.png" );
		steam_ugc_set_item_content(     _han, _dir                              );
		
		var tgs = array_clone(file.meta.tags);
		array_insert_unique(tgs, 0, "Collection");
		array_push_unique(tgs, VERSION_STRING);
		steam_ugc_set_item_tags(_han, tgs);
		
		asyncCallGroup("steam", steam_ugc_submit_item_update(_han, "Initial upload"), function( _params, _data ) /*=>*/ {
			STEAM_UGC_UPLOADING = false;
			if(_data[? "result"] != ugc_result_success) { noti_warning($"Steam: {steam_ugc_get_error(_data[? "result"])}"); return; } 
			
			var _fid = _params.fileid;
			
			noti_status($"Steam Workshop: Collection uploaded [id: {_fid}]", THEME.workshop_upload, COLORS._main_value_positive)
				.setOnClick(function(fid) /*=>*/ { dialogPanelCall(new Panel_Steam_Workshop().navigate({ type: "fileid", fileid: fid })) },
					"View in Workshop...", THEME.steam_invert_24, _fid);
			PANEL_MENU.setNotiIcon(THEME.workshop_upload);
			UGC_subscribe_item(_fid);
			HUB_link_file_id(_fid);
			
		}, { fileid: _fid });
		
	}, { file });
}

function steam_ugc_update_collection(file, update_preview = false, update_note = "Updated") {
	if(STEAM_UGC_UPLOADING) return;
	STEAM_UGC_UPLOADING = true;
	
	var _dir = DIRECTORY + "steamUGC"
	directory_clear(_dir);
	
	file_copy(file.path,      $"{_dir}/{filename_name(file.path     )}");
	file_copy(file.meta_path, $"{_dir}/{filename_name(file.meta_path)}");
	
	if(array_safe_get_fast(file.spr_data, 0) != 0)
		file_copy(file.spr_data[0], $"{_dir}/{filename_name(file.spr_data[0])}");
	
	var _fid = file.meta.file_id;
	var _han = steam_ugc_start_item_update(STEAM_APP_ID, _fid);
	steam_ugc_set_item_title(       _han, file.meta.name        );
	steam_ugc_set_item_description( _han, file.meta.description );
	steam_ugc_set_item_content(     _han, _dir                  );
	
	var tgs = file.meta.tags;
	array_insert_unique(tgs, 0, "Collection");
	array_push_unique(tgs, VERSION_STRING);
	steam_ugc_set_item_tags(_han, tgs);
	
	if(update_preview) {
		steam_ugc_generate_thumbnail(array_safe_get_fast(file.spr_data, 0), UGC_TYPE.collection);
		if(file_exists_empty(TEMPDIR + "steamUGCthumbnail.png")) steam_ugc_set_item_preview(_han, TEMPDIR + "steamUGCthumbnail.png");
	}
	
	asyncCallGroup("steam", steam_ugc_submit_item_update(_han, "Initial upload"), function( _params, _data ) /*=>*/ {
		STEAM_UGC_UPLOADING = false;
		if(_data[? "result"] != ugc_result_success) { noti_warning($"Steam: {steam_ugc_get_error(_data[? "result"])}"); return; } 
		
		var _fid = _data[$ "fileid"] ?? 0;
		noti_status($"Steam Workshop: Collection updated", THEME.workshop_upload, COLORS._main_value_positive);
		PANEL_MENU.setNotiIcon(THEME.workshop_upload);
		
	}, { fileid: _fid });
		
}
