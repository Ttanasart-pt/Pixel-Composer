function steam_ugc_create_project() {
	if(STEAM_UGC_UPLOADING) return;
	STEAM_UGC_UPLOADING = true;
	
	asyncCallGroup("steam", steam_ugc_create_item(STEAM_APP_ID, ugc_filetype_community), function( _params, _data ) /*=>*/ {
		var _fid = _data[? "published_file_id"] ?? 0;
		var _dir = DIRECTORY + "steamUGC";
		directory_clear(_dir);
		
		PROJECT.meta.author_steam_id = STEAM_USER_ID;
		PROJECT.meta.file_id         = _fid;
	    SAVE_AT(PROJECT, PROJECT.path);
		
		file_copy(PROJECT.path, $"{_dir}/{filename_name(PROJECT.path)}");
		json_save_struct($"{_dir}/{filename_name_only(PROJECT.path)}.meta", PROJECT.meta);
		
		steam_ugc_project_generate_thumbnail(PANEL_PREVIEW.getNodePreviewSurface());
		
		var _han = steam_ugc_start_item_update(STEAM_APP_ID, _fid);
		steam_ugc_set_item_title(       _han, filename_name_only(PROJECT.path)  );
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
			
			noti_status($"Steam Workshop: Project uploaded {_fid}", THEME.workshop_upload, true);
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
	
	file_copy(PROJECT.path, $"{_dir}/{filename_name(PROJECT.path)}");
	if(file_exists_empty(PROJECT.thumbnail))
		file_copy(PROJECT.thumbnail, $"{_dir}/thumbnail.png");
	json_save_struct($"{_dir}/{filename_name_only(PROJECT.path)}.meta", PROJECT.meta);
	
	var _han = steam_ugc_start_item_update(STEAM_APP_ID, _fid);
	steam_ugc_set_item_title(       _han, filename_name_only(PROJECT.path) );
	steam_ugc_set_item_description( _han, PROJECT.meta.description         );
	steam_ugc_set_item_content(     _han, _dir                             );
	
	var tgs = PROJECT.meta.tags;
	array_insert_unique(tgs, 0, "Project");
	array_push_unique(tgs, VERSION_STRING);
	steam_ugc_set_item_tags(_han, tgs);
	
	if(update_preview) {
		steam_ugc_project_generate_thumbnail(PANEL_PREVIEW.getNodePreviewSurface());
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

function steam_ugc_project_generate_thumbnail(_surface, dest_path = TEMPDIR + "steamUGCthumbnail.png") {
	file_delete(dest_path);
	
	var prev_size = 512;
	var _surf = surface_exists(_surface);
	var _s    = surface_create(prev_size, prev_size);
	
	var avar_size = 80;
	var avartar   = surface_create(avar_size, avar_size);
	
	if(STEAM_UGC_ITEM_AVATAR && sprite_exists(STEAM_AVATAR)) {
		var spw = sprite_get_width(STEAM_AVATAR);
		var sph = sprite_get_height(STEAM_AVATAR);
		var ss  = avar_size / max(spw, sph);
		
	    surface_set_target(avartar);
	    	DRAW_CLEAR
	    	
	    	var avw = spw * ss;
	    	var avh = sph * ss;
	    	var avx = avar_size / 2 - avw / 2;
	    	var avy = avar_size / 2 - avh / 2;
	    	
	    	BLEND_NORMAL
	    		draw_sprite_ext(STEAM_AVATAR, 0, avx, avy, ss, ss, 0, c_white, 1);
	    	BLEND_MULTIPLY
	    		draw_sprite_stretched(THEME.ui_panel, 0, avx, avy, avw, avh);
	    	BLEND_NORMAL
	    	
	    	draw_sprite_stretched_add(THEME.ui_panel, 1, avx, avy, avw, avh, c_white, 0.3);
	    	
	    surface_reset_target();
	}
	
	surface_set_target(_s);
		draw_clear(COLORS._main_icon_dark);
		draw_sprite_tiled(s_workshop_bg, 0, -64, -64);
		draw_sprite_stretched_ext(s_workshop_frame, 0, 0, 0, prev_size, prev_size, COLORS._main_accent);
		
		if(!_surf) {
			var spr = THEME.workshop_collection;
			var ss  = (prev_size - 160) / max(sprite_get_width(spr), sprite_get_height(spr));
			draw_sprite_ext(spr, 0, prev_size / 2, prev_size / 2, ss, ss, 0, c_white, 1);
			
		} else {
			var sw = surface_get_width(_surface);
			var sh = surface_get_height(_surface);
			var ss = (prev_size - 160) / max(sw, sh);
			
			draw_surface_ext(_surface, prev_size / 2 - sw / 2 * ss, prev_size / 2 - sh / 2 * ss, ss, ss, 0, c_white, 1);
		}
		
		draw_sprite_stretched_ext(s_workshop_badge, 0, 8, 8, 88, 88, COLORS._main_accent);
		draw_sprite_ext(THEME.workshop_project, 0, 40, 40, 1 / THEME_SCALE, 1 / THEME_SCALE, 0, COLORS._main_icon_dark, 1);
		
		draw_set_text(f_h2, fa_right, fa_bottom, COLORS._main_icon_dark);
		var _bw = 48 + string_width(VERSION_STRING) / UI_SCALE;
		var _bh = 22 + string_height(VERSION_STRING) / UI_SCALE;
		draw_sprite_stretched_ext(s_workshop_badge_version, 0, prev_size - 8 - _bw, prev_size - 8 - _bh, _bw, _bh, COLORS._main_accent);
		
		gpu_set_tex_filter(true);
		draw_text_transformed(prev_size - 16, prev_size - 8, VERSION_STRING, 1 / UI_SCALE, 1 / UI_SCALE, 0);
		gpu_set_tex_filter(false);
		
		if(STEAM_UGC_ITEM_AVATAR && sprite_exists(STEAM_AVATAR)) draw_surface(avartar, prev_size - 24 - avar_size, 24);
	surface_reset_target();
	surface_save_safe(_s, dest_path);
	
	surface_free(_s);
	surface_free(avartar);
}