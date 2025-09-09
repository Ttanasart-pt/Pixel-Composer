function steam_ugc_create_collection(file) {
	if(STEAM_UGC_ITEM_UPLOADING) return;
	
	STEAM_UGC_UPDATE		 = false;
	STEAM_UGC_ITEM_UPLOADING = true;
	STEAM_UGC_ITEM_FILE		 = file;
	STEAM_UGC_TYPE			 = STEAM_UGC_FILE_TYPE.collection;
	
	var _dir = DIRECTORY + "steamUGC"
	directory_destroy(_dir);
	directory_create(_dir);
	
	file_copy(file.path,      $"{_dir}/{filename_name(file.path     )}");
	file_copy(file.meta_path, $"{_dir}/{filename_name(file.meta_path)}");
	
	if(array_safe_get_fast(file.spr_path, 0) != 0)
		file_copy(file.spr_path[0], $"{_dir}/{filename_name(file.spr_path[0])}");
	steam_ugc_collection_generate(array_safe_get_fast(file.spr_path, 0));
	
	STEAM_UGC_ITEM_ID = steam_ugc_create_item(STEAM_APP_ID, ugc_filetype_community);
}

function steam_ugc_update_collection(file, update_preview = false, update_note = "Updated") {
	if(STEAM_UGC_ITEM_UPLOADING) return;
	
	STEAM_UGC_UPDATE		 = true;
	STEAM_UGC_ITEM_UPLOADING = true;
	STEAM_UGC_ITEM_FILE		 = file;
	STEAM_UGC_TYPE			 = STEAM_UGC_FILE_TYPE.collection;
	
	var _dir = DIRECTORY + "steamUGC"
	directory_destroy(_dir);
	directory_create(_dir);
	
	file_copy(file.path,      $"{_dir}/{filename_name(file.path     )}");
	file_copy(file.meta_path, $"{_dir}/{filename_name(file.meta_path)}");
	
	if(array_safe_get_fast(file.spr_path, 0) != 0)
		file_copy(file.spr_path[0], $"{_dir}/{filename_name(file.spr_path[0])}");
	
	STEAM_UGC_PUBLISH_ID    = file.meta.file_id;
	STEAM_UGC_UPDATE_HANDLE = steam_ugc_start_item_update(STEAM_APP_ID, STEAM_UGC_PUBLISH_ID);
	
	steam_ugc_set_item_title(STEAM_UGC_UPDATE_HANDLE,       STEAM_UGC_ITEM_FILE.meta.name);
	steam_ugc_set_item_description(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.description);
	
	var tgs = STEAM_UGC_ITEM_FILE.meta.tags;
	
	array_insert_unique(tgs, 0, "Collection");
	array_push_unique(tgs, VERSION_STRING);
	
	steam_ugc_collection_generate(array_safe_get_fast(file.spr_path, 0));
	
	steam_ugc_set_item_tags(STEAM_UGC_UPDATE_HANDLE, tgs);
	steam_ugc_set_item_content(STEAM_UGC_UPDATE_HANDLE, _dir);
	if(file_exists_empty(TEMPDIR + "steamUGCthumbnail.png"))
		steam_ugc_set_item_preview(STEAM_UGC_UPDATE_HANDLE, TEMPDIR + "steamUGCthumbnail.png");
	
	STEAM_UGC_SUBMIT_ID = steam_ugc_submit_item_update(STEAM_UGC_UPDATE_HANDLE, update_note);
}

function steam_ugc_collection_generate(file, dest_path = TEMPDIR + "steamUGCthumbnail.png") {
	file_delete(dest_path);
	
	var prev_size = 512;
	var spr = sprite_add(file, 0, false, false, 0, 0);
	var _s  = surface_create(prev_size, prev_size);
	
	var avar_size = 80;
	var avartar   = surface_create(avar_size, avar_size);
	
	if(sprite_exists(STEAM_AVATAR)) {
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
		
		if(spr == -1) spr = THEME.workshop_collection;
		var ss = (prev_size - 160) / max(sprite_get_width(spr), sprite_get_height(spr));
		var ox = (sprite_get_xoffset(spr) - sprite_get_width(spr) / 2) * ss;
		var oy = (sprite_get_yoffset(spr) - sprite_get_height(spr) / 2) * ss;
		draw_sprite_ext(spr, 0, prev_size / 2 + ox, prev_size / 2 + oy, ss, ss, 0, c_white, 1);
		
		draw_sprite_stretched_ext(s_workshop_badge, 0, 8, 8, 88, 88, COLORS._main_accent);
		draw_sprite_ui(THEME.workshop_collection, 0, 40, 40, 1, 1, 0, COLORS._main_icon_dark, 1);
		
		draw_set_text(f_h2, fa_right, fa_bottom, COLORS._main_icon_dark);
		var _bw = 48 + string_width(VERSION_STRING);
		var _bh = 80;
		draw_sprite_stretched_ext(s_workshop_badge_version, 0, prev_size - 8 - _bw, prev_size - 8 - _bh, _bw, _bh, COLORS._main_accent);
		draw_text(prev_size - 16, prev_size - 4, VERSION_STRING);
		
		if(sprite_exists(STEAM_AVATAR) && STEAM_UGC_ITEM_AVATAR) draw_surface(avartar, prev_size - 24 - avar_size, 24);
	surface_reset_target();
	surface_save_safe(_s, dest_path);
	
	surface_free(_s);
	surface_free(avartar);
}