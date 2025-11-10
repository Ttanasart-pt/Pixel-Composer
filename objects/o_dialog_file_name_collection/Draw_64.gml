/// @description init
#region base UI
	// DIALOG_DRAW_BG
	// if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
	
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.textbox, 2, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent);
	else       draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(4), dialog_y + ui(4), dialog_w - ui(8), dialog_h - ui(8));
	
	tb_name.interactable  = !STEAM_UGC_UPLOADING; tb_name.setFont(font);
	t_update.interactable = !STEAM_UGC_UPLOADING; t_update.setFont(font);
	
	t_desc.interactable  = !STEAM_UGC_UPLOADING; t_desc.setFont(font);
	t_auth.interactable  = !STEAM_UGC_UPLOADING; t_auth.setFont(font);
	t_cont.interactable  = !STEAM_UGC_UPLOADING; t_cont.setFont(font);
	t_tags.interactable  = !STEAM_UGC_UPLOADING; t_tags.setFont(font);
	t_alias.interactable = !STEAM_UGC_UPLOADING; t_alias.setFont(font);
#endregion

#region draw TB
	var th = ui(24);
	var tx = ui(64);
	var tw = dialog_w - tx - padding - (th + ui(4)) * (3 - meta_expand);
	
	draw_set_text(font, fa_left, fa_center, COLORS._main_icon);
	draw_text_add(dialog_x + ui(12), dialog_y + padding + th / 2, __txt("Name"));
	
	tb_name.setFocusHover(sFOCUS, sHOVER);
	tb_name.register();
	tb_name.draw(dialog_x + tx, dialog_y + padding, tw, th, meta.name, mouse_ui);
	
	var bs = th;
	var bx = dialog_x + dialog_w - padding - bs;
	var by = dialog_y + padding;
	
	if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Close"), THEME.cross_16, 0, COLORS._main_value_negative) == 2)
		instance_destroy();
	bx -= bs + ui(4);
		
	var txt  = __txtx("new_collection_create", "Create collection");
	var icon = THEME.accept_16;
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
		destroy_on_click_out = false;
		draw_sprite_ui(THEME.loading_s, 0, bx + bs/2, by + bs/2, 1, 1, current_time / 5, COLORS._main_icon);
		if(STEAM_UGC_UPLOADING == false) instance_destroy();
			
	} else {
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, txt, icon, 0, clr) == 2) {
			if(meta.author_steam_id == 0)
				meta.author_steam_id = STEAM_USER_ID;
			
			if(updating == noone && node != noone) {
				saveCollection(node, filename_combine(data_path, meta.name), true, meta);
				
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
					if(file_exists_empty(_oldSpr)) file_rename(_oldSpr, _newSpr);
				}
				
				updating.path        = _newPath;
				updating.meta_path   = _newMeta;
				updating.spr_data[0] = _newSpr;
				updating.meta        = meta;
				
				PANEL_COLLECTION.refreshContext();
			}
			
			if(ugc == 1) {
				steam_ugc_create_collection(updating);
				ugc_loading = true;
				
			} else if(ugc == 2) {
				saveCollection(node, updating.path, false, updating.meta);
				steam_ugc_update_collection(updating, false, update_note);
				ugc_loading = true;
				
			} else 
				instance_destroy();
		}
	}
	
	if(!meta_expand) {
		bx -= bs + ui(4);
		var txt = __txtx("new_collection_meta_edit", "Edit metadata");
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, txt, THEME.arrow, meta_expand? 3 : 0) == 2)
			doExpand();
	}
#endregion

#region display
	dialog_h = th + padding * 2;
	
	var spc_h = ui(4);
	
	if(meta_expand) {
		var dx = dialog_x + padding;
		var dw = dialog_w - padding * 2;
		var yy = dialog_y + th + padding * 2;
		
		if(ugc == 2) {
			draw_set_text(font, fa_left, fa_top, COLORS._main_icon);
			draw_text(dx, yy, __txt("Update note"));
			yy		 += line_get_height() + ui(4);
			dialog_h += line_get_height() + ui(4);
			
			var wd_h = ui(80);
			t_update.setFocusHover(sFOCUS, sHOVER);
			t_update.register();
			t_update.draw(dx, yy, dw, wd_h, update_note, mouse_ui);
			yy		 += wd_h + spc_h;
			dialog_h += wd_h + spc_h;
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(font, fa_left, fa_top, COLORS._main_icon);
		draw_text(dx, yy, __txt("Description"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = ugc == 2? ui(100) : ui(200);
		t_desc.setFocusHover(sFOCUS, sHOVER);
		t_desc.register();
		t_desc.draw(dx, yy, dw, wd_h, meta.description, mouse_ui);
		yy		 += wd_h + spc_h;
		dialog_h += wd_h + spc_h;
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(font, fa_left, fa_top, COLORS._main_icon);
		draw_text(dx, yy, __txt("Author"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_w = dw;
		var wd_h = th;
		
		if(STEAM_ENABLED) {
			var st_s = ui(28);
			var st_x = dx + wd_w - st_s;
			wd_w -= st_s + ui(4);
			
			if(buttonInstant(THEME.button_hide, st_x, yy, st_s, wd_h, mouse_ui, sHOVER, sFOCUS, "Use Steam username", THEME.steam) == 2)
				meta.author = STEAM_USERNAME;
		}
		
		t_auth.setFocusHover(sFOCUS, sHOVER);
		t_auth.register();
		t_auth.draw(dx, yy, wd_w, wd_h, meta.author, mouse_ui);
		yy		 += wd_h + spc_h;
		dialog_h += wd_h + spc_h;
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(font, fa_left, fa_top, COLORS._main_icon);
		draw_text(dx, yy, __txt("Contact info"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = th;
		t_cont.setFocusHover(sFOCUS, sHOVER);
		t_cont.register();
		t_cont.draw(dx, yy, dw, wd_h, meta.contact, mouse_ui);
		yy		 += wd_h + spc_h;
		dialog_h += wd_h + spc_h;
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(font, fa_left, fa_top, COLORS._main_icon);
		draw_text(dx, yy, __txt("Alias"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = th;
		t_alias.setFocusHover(sFOCUS, sHOVER);
		t_alias.register();
		t_alias.draw(dx, yy, dw, wd_h, meta.alias, mouse_ui);
		yy		 += wd_h + spc_h;
		dialog_h += wd_h + spc_h;
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////
		draw_set_text(font, fa_left, fa_top, COLORS._main_icon);
		draw_text(dx, yy, __txt("Tags"));
		yy		 += line_get_height() + ui(4);
		dialog_h += line_get_height() + ui(4);
		
		var wd_h = th;
		t_tags.setFocusHover(sFOCUS, sHOVER);
		t_tags.register();
		var hh = t_tags.draw(dx, yy, dw, wd_h, mouse_ui);
		yy		 += hh + spc_h;
		dialog_h += hh + spc_h;
		
		dialog_h -= spc_h;
		dialog_h += padding;
	}
	
	dialog_y = clamp(dialog_y, padding * 2, WIN_H - padding - dialog_h);
#endregion