/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	
	dialog_w = 960;
	dialog_h = 600;
#endregion

#region content
	var x0 = dialog_x + 16;
	var x1 = x0 + 288;
	var y0 = dialog_y + 128;
	var y1 = dialog_y + dialog_h - 16;
	
	sp_recent = new scrollPane(x1 - x0 - 12, y1 - y0, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_dkblack, 0);
		var hh	= 0;
		var pad = 8;
		var hg	= 64;
		_y += pad;
		
		for(var i = 0; i < ds_list_size(RECENT_FILES); i++)  {
			var _rec = RECENT_FILES[| i];
			draw_sprite_stretched(s_ui_panel_bg, 1, 0, _y, sp_recent.surface_w, hg);
			
			if(HOVER == self && point_in_rectangle(_m[0], _m[1], 0, _y, sp_recent.surface_w, _y + hg)) {
				draw_sprite_stretched(s_node_active, 0, 0, _y, sp_recent.surface_w, hg);
				
				if(FOCUS == self && mouse_check_button_pressed(mb_left)) {
					LOAD_PATH(_rec);
					instance_destroy();
				}
			}
			
			draw_set_text(f_p0b, fa_left, fa_top, c_white);
			draw_text(12, _y + 12, filename_name(_rec));
			
			draw_set_text(f_p1, fa_left, fa_top, c_ui_blue_grey);
			draw_text_cut(12, _y + 32, _rec, sp_recent.surface_w - 24);
			
			hh += hg + pad;
			_y += hg + pad;
		}
		
		return hh;
	});
	
	x0 = x1 + 16;
	x1 = dialog_x + dialog_w - 16;
	
	sp_sample = new scrollPane(x1 - x0 - 12, y1 - y0, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_dkblack, 0);
		var hh = 0;
		var grid_heigh = 96;
		var grid_width = 128;
		var grid_space = 20;
		var node_count = ds_list_size(SAMPLE_PROJECTS);
		var col        = floor(sp_sample.surface_w / (grid_width + grid_space));
		var row        = ceil(node_count / col);
		var hh         = grid_space;
		var yy         = _y + grid_space;
		var name_height = 0;
		
		for(var i = 0; i < row; i++) {
			name_height = 0;
			for(var j = 0; j < col; j++) {
				var index = i * col + j;
				if(index < node_count) {
					var _node = SAMPLE_PROJECTS[| index];
					var _nx   = grid_space + (grid_width + grid_space) * j;
					var _boxx = _nx;
					
					draw_sprite_stretched(s_node_bg, 0, _boxx, yy, grid_width, grid_heigh);
					if(HOVER == self && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_heigh)) {
						draw_sprite_stretched(s_node_active, 0, _boxx, yy, grid_width, grid_heigh);	
						if(FOCUS == self && mouse_check_button_pressed(mb_left)) {
							LOAD_PATH(_node.path, true);
							instance_destroy();
						}
					}
					
					if(_node.spr) 
						draw_sprite(_node.spr, 0, _boxx + grid_width / 2, yy + grid_heigh / 2);
					
					var tx = _boxx + grid_width / 2;
					var ty = yy + grid_heigh + 6;
					draw_set_text(f_p2, fa_center, fa_top, c_ui_blue_dkgrey);
					var _tw = string_width(_node.tag);
					var _th = string_height(_node.tag);
					
					draw_set_color(c_ui_blue_mdblack);
					draw_roundrect_ext(tx - _tw / 2 - 6, ty - 2, tx + _tw / 2 + 6, ty + _th, 8, 8, 0);
					draw_set_color(_node.tag == "Getting started"? c_ui_orange_light : c_ui_blue_grey);
					draw_text(tx, ty, _node.tag);
					
					draw_set_text(f_p1, fa_center, fa_top, c_white);
					name_height = max(name_height, string_height_ext(_node.name, -1, grid_width) + 8);
					draw_text_ext(tx, ty + 20, _node.name, -1, grid_width);
				}
			}
			var hght = grid_heigh + grid_space + name_height + 20;
			hh += hght;
			yy += hght;
		}
		
		return hh;
	});
#endregion