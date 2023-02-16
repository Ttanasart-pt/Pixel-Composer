/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	
	dialog_w = ui(960);
	dialog_h = ui(600);
	
	pages = ["Sample projects"];
	if(STEAM_ENABLED) 
		array_push(pages, "Steam Workshop");
	project_page = 0;
#endregion

#region content
	var x0 = dialog_x + ui(16);
	var x1 = x0 + ui(288);
	var y0 = dialog_y + ui(128);
	var y1 = dialog_y + dialog_h - ui(16);
	
	sp_recent = new scrollPane(x1 - x0 - ui(8), y1 - y0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		var ww  = sp_recent.surface_w - ui(2);
		var hh	= 0;
		var pad = ui(8);
		var hg	= ui(16) + line_height(f_p0b) + line_height(f_p1);
		_y += pad;
		
		for(var i = 0; i < ds_list_size(RECENT_FILES); i++)  {
			var _rec = RECENT_FILES[| i];
			if(!file_exists(_rec)) continue;
			draw_sprite_stretched(THEME.ui_panel_bg, 1, 0, _y, ww, hg);
			
			if(sHOVER && sp_recent.hover && point_in_rectangle(_m[0], _m[1], 0, _y, ww, _y + hg)) {
				draw_sprite_stretched_ext(THEME.node_active, 0, 0, _y, ww, hg, COLORS._main_accent, 1);
				
				if(mouse_press(mb_left, sFOCUS)) {
					LOAD_PATH(_rec);
					instance_destroy();
				}
			}
			
			var ly = _y + ui(8);
			draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text);
			draw_text(ui(12), ly, filename_name(_rec));
			
			ly += line_height();
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_cut(ui(12), ly, _rec, ww - ui(24));
			
			hh += hg + pad;
			_y += hg + pad;
		}
		
		return hh;
	});
	
	x0 = x1 + ui(16);
	x1 = dialog_x + dialog_w - ui(16);
	
	sp_sample = new scrollPane(x1 - x0 - ui(8), y1 - y0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		var list = project_page? STEAM_PROJECTS : SAMPLE_PROJECTS;
		
		var hh = 0;
		var grid_heigh = ui(96);
		var grid_width = ui(128);
		var grid_space = ui(20);
		var node_count = ds_list_size(list);
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
					var _project = list[| index];
					var _nx      = grid_space + (grid_width + grid_space) * j;
					var _boxx    = _nx;
					
					draw_sprite_stretched(THEME.node_bg, 0, _boxx, yy, grid_width, grid_heigh);
					if(sHOVER && sp_sample.hover && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_heigh)) {
						draw_sprite_stretched_ext(THEME.node_active, 0, _boxx, yy, grid_width, grid_heigh, COLORS._main_accent, 1);
						if(mouse_press(mb_left, sFOCUS)) {
							LOAD_PATH(_project.path, true);
							METADATA.steam = project_page;
							if(project_page == 1)
								METADATA.file_id = _project.getMetadata().file_id;
							instance_destroy();
						}
					}
					
					var spr = _project.getSpr();
					if(spr) {
						var gw = grid_width - ui(4);
						var gh = grid_heigh - ui(4);
						
						var sw = sprite_get_width(spr);
						var sh = sprite_get_height(spr);
						
						var s = min(gw / sw, gh / sh) * 2;
						
						var ox = (sprite_get_xoffset(spr) - sw / 2) * s / 2;
						var oy = (sprite_get_yoffset(spr) - sh / 2) * s / 2;
						
						draw_sprite_ui_uniform(spr, 0, _boxx + grid_width / 2 + ox, yy + grid_heigh / 2 + ox, s);
					}
					
					var tx = _boxx + grid_width / 2;
					var ty = yy + grid_heigh + ui(4);
					draw_set_text(f_p2, fa_center, fa_top);
					if(project_page == 0) {
						var _tw = string_width(_project.tag);
						var _th = string_height(_project.tag);
					
						draw_set_color(COLORS.dialog_splash_badge);
						draw_roundrect_ext(tx - _tw / 2 - ui(6), ty - ui(2), tx + _tw / 2 + ui(6), ty + _th, ui(8), ui(8), 0);
						draw_set_color(_project.tag == "Getting started"? COLORS._main_text_accent : COLORS._main_text_sub);
						draw_text(tx, ty - ui(2), _project.tag);						
						
						ty += line_height();
					} 
					
					draw_set_text(f_p1, fa_center, fa_top, COLORS._main_text);
					name_height = max(name_height, string_height_ext(_project.name, -1, grid_width) + ui(8));
					draw_text_ext_add(tx, ty - ui(2), _project.name, -1, grid_width);
				}
			}
			var hght = grid_heigh + grid_space + name_height + ui(20);
			hh += hght;
			yy += hght;
		}
		
		return hh;
	});
#endregion