function steam_ugc_create_project() { #region
	if(STEAM_UGC_ITEM_UPLOADING) return;
	
	var file         = new FileObject(string_replace(filename_name(PROJECT.path), filename_ext(PROJECT.path), ""), PROJECT.path);
	file.meta        = PROJECT.meta;
	file.spr_path[0] = DIRECTORY + "steamUGC/thumbnail.png";
	
	STEAM_UGC_UPDATE		 = false;
	STEAM_UGC_ITEM_UPLOADING = true;
	STEAM_UGC_ITEM_FILE		 = file;
	STEAM_UGC_TYPE			 = STEAM_UGC_FILE_TYPE.project;
	
	directory_destroy(DIRECTORY + "steamUGC");
	directory_create(DIRECTORY + "steamUGC");
	
	file_copy(file.path, DIRECTORY + "steamUGC/" + filename_name(file.path));
	
	var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
	surface_save_safe(preview_surface, DIRECTORY + "steamUGC/thumbnail.png");
	steam_ugc_project_generate(DIRECTORY + "steamUGC/thumbnail.png");
	
	STEAM_UGC_ITEM_ID = steam_ugc_create_item(STEAM_APP_ID, ugc_filetype_community);
} #endregion

function steam_ugc_update_project(update_preview = false, update_note = "Updated") { #region
	if(STEAM_UGC_ITEM_UPLOADING) return;
	
	var file	= new FileObject(filename_name_only(PROJECT.path), PROJECT.path);
	file.meta   = PROJECT.meta;
	
	STEAM_UGC_UPDATE		 = true;
	STEAM_UGC_ITEM_UPLOADING = true;
	STEAM_UGC_ITEM_FILE		 = file;
	STEAM_UGC_TYPE			 = STEAM_UGC_FILE_TYPE.project;
	
	directory_destroy(DIRECTORY + "steamUGC");
	directory_create(DIRECTORY + "steamUGC");
	
	file_copy(file.path, DIRECTORY + "steamUGC/" + filename_name(file.path));
	if(file_exists(PROJECT.thumbnail))
		file_copy(PROJECT.thumbnail, DIRECTORY + "steamUGC/thumbnail.png");
	
	STEAM_UGC_PUBLISH_ID = file.meta.file_id;
	STEAM_UGC_UPDATE_HANDLE = steam_ugc_start_item_update(STEAM_APP_ID, STEAM_UGC_PUBLISH_ID);
	
	steam_ugc_set_item_title(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.name);
	steam_ugc_set_item_description(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.description);
	
	var tgs = STEAM_UGC_ITEM_FILE.meta.tags;
	
	array_insert_unique(tgs, 0, "Project");
	array_push_unique(tgs, VERSION_STRING);
	
	steam_ugc_project_generate(PROJECT.thumbnail);
	
	steam_ugc_set_item_tags(STEAM_UGC_UPDATE_HANDLE, tgs);
	steam_ugc_set_item_content(STEAM_UGC_UPDATE_HANDLE, DIRECTORY + "steamUGC");
	if(file_exists(TEMPDIR + "steamUGCthumbnail.png"))
		steam_ugc_set_item_preview(STEAM_UGC_UPDATE_HANDLE, TEMPDIR + "steamUGCthumbnail.png");
		
	STEAM_UGC_SUBMIT_ID = steam_ugc_submit_item_update(STEAM_UGC_UPDATE_HANDLE, update_note);
} #endregion

function steam_ugc_project_generate(file, dest_path = TEMPDIR + "steamUGCthumbnail.png") { #region
	file_delete(dest_path);
	
	var prev_size = 512;
	var spr = sprite_add(file, 0, false, false, 0, 0);
	var _s  = surface_create(prev_size, prev_size);
	
	surface_set_target(_s);
		draw_clear(COLORS._main_icon_dark);
		draw_sprite_tiled(s_workshop_bg, 0, -64, -64);
		draw_sprite_stretched(s_workshop_frame, 0, 0, 0, prev_size, prev_size);
		
		if(spr == -1) spr = THEME.workshop_collection;
		var ss = (prev_size - 160) / max(sprite_get_width(spr), sprite_get_height(spr));
		var ox = (sprite_get_xoffset(spr) - sprite_get_width(spr) / 2) * ss;
		var oy = (sprite_get_yoffset(spr) - sprite_get_height(spr) / 2) * ss;
		draw_sprite_ext(spr, 0, prev_size / 2 + ox, prev_size / 2 + oy, ss, ss, 0, c_white, 1);
		
		draw_sprite_stretched(s_workshop_badge, 0, 8, 8, 88, 88);
		draw_sprite_ext(THEME.workshop_project, 0, 40, 40, 1, 1, 0, COLORS._main_icon_dark, 1);
		
		draw_set_text(f_h2, fa_right, fa_bottom, COLORS._main_icon_dark);
		var _bw = 48 + string_width(VERSION_STRING);
		var _bh = 80;
		draw_sprite_stretched(s_workshop_badge_version, 0, prev_size - 8 - _bw, prev_size - 8 - _bh, _bw, _bh);
		draw_text(prev_size - 16, prev_size - 8, VERSION_STRING);
	surface_reset_target();
	surface_save_safe(_s, dest_path);
	surface_free(_s);
} #endregion