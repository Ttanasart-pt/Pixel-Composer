/// @description init
#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS)
		DIALOG_DRAW_FOCUS
#endregion

#region draw TB
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_icon);
	draw_text_add(dialog_x + ui(16), dialog_y + ui(32), __txt("Name"));
		
	t_desc.interactable  = !STEAM_UGC_ITEM_UPLOADING;
	t_auth.interactable  = !STEAM_UGC_ITEM_UPLOADING;
	t_cont.interactable  = !STEAM_UGC_ITEM_UPLOADING;
	t_tags.interactable  = !STEAM_UGC_ITEM_UPLOADING;
	t_alias.interactable = !STEAM_UGC_ITEM_UPLOADING;
	tb_name.interactable = !STEAM_UGC_ITEM_UPLOADING;
	
	tb_name.setFocusHover(sFOCUS, sHOVER);
	tb_name.register();
	tb_name.draw(dialog_x + ui(72), dialog_y + ui(16), dialog_w - ui(164), ui(32), meta.name, mouse_ui);
	
	var bx = dialog_x + dialog_w - ui(84);
	var by = dialog_y + ui(16);
	var bw = ui(32);
	var bh = ui(32);
	
	var txt  = __txtx("new_collection_create", "Create collection");
	var icon = THEME.accept;
	var clr  = COLORS._main_value_positive;
	if(updating != noone)
		txt  = __txtx("new_collection_update", "Update collection");
	
	if(ugc == 1) {
		txt  = __txtx("panel_inspector_workshop_upload", "Upload to Steam Workshop");
		icon = THEME.workshop_upload;
		clr  = c_white;
	} else if(ugc == 2) {
		txt  = __txtx("panel_inspector_workshop_update", "Update Steam Workshop");
		icon = THEME.workshop_update;
		clr  = c_white;
	}
	
	if(ugc_loading) {
		steam_ugc_get_item_update_progress(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_UPDATE_MAP);
		
		destroy_on_click_out = false;
		draw_sprite_ui(THEME.loading_s, 0, bx + ui(16), by + ui(16),,, current_time / 5, COLORS._main_icon);
		if(STEAM_UGC_ITEM_UPLOADING == false)
			instance_destroy();
	} else {
		if(buttonInstant(THEME.button_hide, bx, by, bw, bh, mouse_ui, sFOCUS, sHOVER, txt, icon, 0, clr) == 2) {
			if(meta.author_steam_id == 0)
				meta.author_steam_id = STEAM_USER_ID;
			
			if(updating == noone && node != noone) {
				saveCollection(node, data_path, meta.name, true, meta);
			} else {
				var _map     = json_load_struct(updating.path);
				var _meta    = meta.serialize();
				_map.metadata = _meta;
				json_save_struct(updating.path,		 _map);
				json_save_struct(updating.meta_path, _meta);
				
				var _newPath = $"{filename_dir(updating.path)}/{meta.name}.pxcc";
				var _newMeta = $"{filename_dir(updating.meta_path)}/{meta.name}.meta";
				var _oldSpr  = $"{filename_dir(updating.path)}/{filename_name_only(updating.path)}.png";
				var _newSpr  = $"{filename_dir(updating.path)}/{meta.name}.png";
				
				if(_newPath != updating.path) {
					file_rename(updating.path,		_newPath);
					file_rename(updating.meta_path, _newMeta);
					if(file_exists(_oldSpr)) file_rename(_oldSpr, _newSpr);
				}
				
				updating.path        = _newPath;
				updating.meta_path   = _newMeta;
				updating.spr_path[0] = _newSpr;
				updating.meta        = meta;
				
				PANEL_COLLECTION.refreshContext();
			}
			
			if(ugc == 1) {
				steam_ugc_create_collection(updating);
				ugc_loading = true;
			} else if(ugc == 2) {
				saveCollection(node, data_path, updating.path, false, updating.meta);
				steam_ugc_update_collection(updating, false, update_note);
				ugc_loading = true;
			} else 
				instance_destroy();
		}
	}
	
	bx += bw + ui(4);
	var txt = __txtx("new_collection_meta_edit", "Edit metadata");
	if(buttonInstant(THEME.button_hide, bx, by, bw, bh, mouse_ui, sFOCUS, sHOVER, txt, THEME.hamburger) == 2)
		doExpand();
#endregion

#region display
	dialog_h = ui(64);
	
	if(meta_expand) {
		var yy = dialog_y + ui(56);
	
		if(ugc == 2) {
			draw_set_text(f_p0, fa_left, fa_top, COLORS._main_icon);
			draw_text(dialog_x + ui(16), yy, __txt("Update note"));
			yy		 += line_get_height() + ui(4);
			dialog_h += line_get_height() + ui(4);
			
			var wd_h = ui(160);
			t_update.setFocusHover(sFOCUS, sHOVER);
			t_update.register();
			t_update.draw(dialog_x + ui(16), yy, dialog_w - ui(32), wd_h, update_note, mouse_ui);
			yy		 += wd_h + ui(8);
			dialog_h += wd_h + ui(8);
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_icon);
		draw_text(dialog_x + ui(16), yy, __txt("Description"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = ugc == 2? ui(100) : ui(200);
		t_desc.setFocusHover(sFOCUS, sHOVER);
		t_desc.register();
		t_desc.draw(dialog_x + ui(16), yy, dialog_w - ui(32), wd_h, meta.description, mouse_ui);
		yy		 += wd_h + ui(8);
		dialog_h += wd_h + ui(8);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_icon);
		draw_text(dialog_x + ui(16), yy, __txt("Author"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = TEXTBOX_HEIGHT;
		t_auth.setFocusHover(sFOCUS, sHOVER);
		t_auth.register();
		t_auth.draw(dialog_x + ui(16), yy, dialog_w - ui(32), wd_h, meta.author, mouse_ui);
		yy		 += wd_h + ui(8);
		dialog_h += wd_h + ui(8);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_icon);
		draw_text(dialog_x + ui(16), yy, __txt("Contact info"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = TEXTBOX_HEIGHT;
		t_cont.setFocusHover(sFOCUS, sHOVER);
		t_cont.register();
		t_cont.draw(dialog_x + ui(16), yy, dialog_w - ui(32), wd_h, meta.contact, mouse_ui);
		yy		 += wd_h + ui(8);
		dialog_h += wd_h + ui(8);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_icon);
		draw_text(dialog_x + ui(16), yy, __txt("Alias"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = TEXTBOX_HEIGHT;
		t_alias.setFocusHover(sFOCUS, sHOVER);
		t_alias.register();
		t_alias.draw(dialog_x + ui(16), yy, dialog_w - ui(32), wd_h, meta.alias, mouse_ui);
		yy		 += wd_h + ui(8);
		dialog_h += wd_h + ui(8);
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_icon);
		draw_text(dialog_x + ui(16), yy, __txt("Tags"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = TEXTBOX_HEIGHT;
		t_tags.setFocusHover(sFOCUS, sHOVER);
		t_tags.register();
		var hh = t_tags.draw(dialog_x + ui(16), yy, dialog_w - ui(32), wd_h, mouse_ui);
		yy		 += hh + ui(8);
		dialog_h += hh + ui(8);
	}
	
	dialog_y = clamp(dialog_y, ui(16), WIN_H - ui(16) - dialog_h);
#endregion