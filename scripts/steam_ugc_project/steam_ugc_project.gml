function steam_ugc_create_project() {
	if(STEAM_UGC_ITEM_UPLOADING) return;
	
	var file = new FileObject(string_replace(filename_name(PROJECT.path), filename_ext(PROJECT.path), ""), PROJECT.path);
	file.getMetadata();
	file.spr_path = DIRECTORY + "steamUGC/thumbnail.png";
	
	STEAM_UGC_UPDATE = false;
	STEAM_UGC_ITEM_UPLOADING = true;
	STEAM_UGC_ITEM_FILE = file;
	STEAM_UGC_TYPE = STEAM_UGC_FILE_TYPE.project;
	
	directory_destroy(DIRECTORY + "steamUGC");
	directory_create(DIRECTORY + "steamUGC");
	file_copy(file.path, DIRECTORY + "steamUGC/" + filename_name(file.path));
	
	steam_ugc_project_generate();
	var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
	surface_save_safe(preview_surface, DIRECTORY + "steamUGC/thumbnail.png");
	
	print(filename_dir(DIRECTORY + "steamUGCthumbnail.png"))
	
	STEAM_UGC_ITEM_ID = steam_ugc_create_item(STEAM_APP_ID, ugc_filetype_community);
}

function steam_ugc_update_project(update_preview = false, update_note = "Updated") {
	if(STEAM_UGC_ITEM_UPLOADING) return;
	
	var file = new FileObject(string_replace(filename_name(PROJECT.path), filename_ext(PROJECT.path), ""), PROJECT.path);
	file.getMetadata();
	file.spr_path = DIRECTORY + "steamUGC/thumbnail.png";
	
	STEAM_UGC_UPDATE = true;
	STEAM_UGC_ITEM_UPLOADING = true;
	STEAM_UGC_ITEM_FILE = file;
	STEAM_UGC_TYPE = STEAM_UGC_FILE_TYPE.project;
	
	directory_destroy(DIRECTORY + "steamUGC");
	directory_create(DIRECTORY + "steamUGC");
	file_copy(file.path, DIRECTORY + "steamUGC/" + filename_name(file.path));
	file_copy(file.spr_path[0], DIRECTORY + "steamUGC/thumbnail.png");
	
	STEAM_UGC_PUBLISH_ID = file.meta.file_id;
	STEAM_UGC_UPDATE_HANDLE = steam_ugc_start_item_update(STEAM_APP_ID, STEAM_UGC_PUBLISH_ID);
	
	steam_ugc_set_item_title(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.name);
	steam_ugc_set_item_description(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.description);
	
	array_insert(STEAM_UGC_ITEM_FILE.meta.tags, 0, "Project");
	steam_ugc_set_item_tags(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.tags);
	steam_ugc_set_item_content(STEAM_UGC_UPDATE_HANDLE, DIRECTORY + "steamUGC");
	
	STEAM_UGC_SUBMIT_ID = steam_ugc_submit_item_update(STEAM_UGC_UPDATE_HANDLE, update_note);
}

function steam_ugc_project_generate(dest_path = DIRECTORY + "steamUGCthumbnail.png") {
	file_delete(dest_path);
	
	var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
	var prev_size = 512;
	var _s = surface_create(prev_size, prev_size);
	surface_set_target(_s);
		draw_clear(COLORS._main_icon_dark);
		draw_sprite_tiled(s_workshop_bg, 0, -64, -64);
		draw_sprite_stretched(s_workshop_frame, 0, 0, 0, prev_size, prev_size);
		
		if(is_surface(preview_surface)) {
			var ss = (prev_size - 160) / max(surface_get_width_safe(preview_surface), surface_get_height_safe(preview_surface));
			var ox = surface_get_width_safe(preview_surface) / 2 * ss;
			var oy = surface_get_height_safe(preview_surface) / 2 * ss;
			draw_surface_ext_safe(preview_surface, prev_size / 2 - ox, prev_size / 2 - oy, ss, ss, 0, c_white, 1);
		}
		
		draw_sprite_stretched(s_workshop_badge, 0, 8, 8, 88, 88);
		draw_sprite_ext(THEME.workshop_project, 0, 40, 40, 1, 1, 0, COLORS._main_icon_dark, 1);
	surface_reset_target();
	surface_save_safe(_s, dest_path);
	surface_free(_s);
}