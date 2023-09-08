/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	
	dialog_w = ui(960);
	dialog_h = ui(600);
	
	pages = ["Sample projects"];
	if(STEAM_ENABLED) 
		array_push(pages, "Workshop");
	project_page = 0;
	
	thumbnail_retriever = 0;
	recent_thumbnail	= false;
	show_autosaves		= false;
	
	recent_width = PREF_MAP[? "splash_expand_recent"]? ui(576) : ui(288);
#endregion

#region content
	function resize() {
		var x0 = dialog_x + ui(16);
		var x1 = x0 + recent_width;
		var y0 = dialog_y + ui(128);
		var y1 = dialog_y + dialog_h - ui(16);
		
		sp_recent.resize(x1 - x0 - ui(12), y1 - y0);
		
		x0 = x1 + ui(16);
		x1 = dialog_x + dialog_w - ui(16);
	
		sp_sample.resize(x1 - x0 - ui(12), y1 - y0);
		sp_contest.resize(x1 - x0 - ui(12), y1 - y0 - 2);
	}
	
	var x0 = dialog_x + ui(16);
	var x1 = x0 + recent_width;
	var y0 = dialog_y + ui(128);
	var y1 = dialog_y + dialog_h - ui(16);
	
	sp_recent = new scrollPane(x1 - x0 - ui(12), y1 - y0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		var expand = PREF_MAP[? "splash_expand_recent"];
		var ww  = ui(264);
		var hh	= 0;
		var pad = ui(8);
		var hgt	= ui(16) + line_get_height(f_p0b) + line_get_height(f_p1);
		_y += pad;
		
		var col = expand? 2 : 1;
		var row = ceil(ds_list_size(RECENT_FILES) / col);
		
		for(var i = 0; i < row; i++) {
			for(var j = 0; j < col; j++) {
				var ind  = i * col + j;
				if(ind >= ds_list_size(RECENT_FILES)) break;
			
				var _rec = RECENT_FILES[| ind];
				var _dat = RECENT_FILE_DATA[| ind];
				if(!file_exists(_rec)) continue;
			
				var thmb = noone;
				var hg = hgt;
				if(recent_thumbnail) {
					hg = ui(100);
					thmb = _dat.getThumbnail();
				}
				
				var fx = j * (ww + ui(8));
			
				draw_sprite_stretched(THEME.ui_panel_bg, 1, fx, _y, ww, hg);
				if(thmb && _y + hg > 0 && _y < sp_recent.h) {
					var sw = surface_get_width_safe(thmb);
					var sh = surface_get_height_safe(thmb);
					
					var ss = (ww - ui(8)) / sw;
					var sy = (((sh * ss) - hg) * clamp((_y + hg) / (sp_recent.h + hg), 0, 1)) / ss;
					
					draw_surface_part_ext(thmb, 0, sy, sw, (hg - ui(8)) / ss, fx + ui(4), _y + ui(4), ss, ss, COLORS._main_icon_light, 0.9);
					draw_sprite_stretched_ext(s_fade_up, 0, fx + ui(4), _y + hg - ui(64), ww - ui(8), ui(64), COLORS._main_icon_dark, 1);
				}
			
				if(sHOVER && sp_recent.hover && point_in_rectangle(_m[0], _m[1], fx, _y, fx + ww, _y + hg)) {
					TOOLTIP = [ _dat.getThumbnail(), VALUE_TYPE.surface ];
				
					draw_sprite_stretched_ext(THEME.node_active, 0, fx, _y, ww, hg, COLORS._main_accent, 1);
				
					if(mouse_press(mb_left, sFOCUS)) {
						LOAD_PATH(_rec);
						instance_destroy();
					}
				}
			
				var ly = recent_thumbnail? _y + hg - (line_get_height(f_p0b) + line_get_height(f_p1)) - ui(8) : _y + ui(8);
				draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_inner);
				draw_text(fx + ui(12), ly, filename_name(_rec));
			
				ly += line_get_height(, ui(4));
				draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_cut(fx + ui(12), ly, _rec, ww - ui(24));
			}
			
			hh += hg + pad;
			_y += hg + pad;
		}
		
		return hh;
	});
	
	x0 = x1 + ui(16);
	x1 = dialog_x + dialog_w - ui(16);
	
	sp_sample = new scrollPane(x1 - x0 - ui(12), y1 - y0, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		
		var txt = pages[project_page];
		var list;
		
		switch(txt) {
			case "Sample projects" : list = SAMPLE_PROJECTS; break;
			case "Workshop" :		 list = STEAM_PROJECTS;  break;
		}
		
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
						var _meta = _project.getMetadata();
						if(txt == "Workshop")
							TOOLTIP = _meta;
						
						draw_sprite_stretched_ext(THEME.node_active, 0, _boxx, yy, grid_width, grid_heigh, COLORS._main_accent, 1);
						if(mouse_press(mb_left, sFOCUS)) {
							LOAD_PATH(_project.path, true);
							METADATA.steam = txt == "Workshop";
							if(txt == "Workshop")
								METADATA.file_id = _meta.file_id;
							instance_destroy();
						}
					}
					
					var spr = _project.getSpr();
					if(spr) {
						var gw = grid_width - ui(8);
						var gh = grid_heigh - ui(8);
						
						var sw = sprite_get_width(spr);
						var sh = sprite_get_height(spr);
						
						var s = min(1, gw / sw, gh / sh);
						
						var ox = (sprite_get_xoffset(spr) - sw / 2) * s;
						var oy = (sprite_get_yoffset(spr) - sh / 2) * s;
						
						var _sx = _boxx + grid_width / 2 + ox;
						var _sy = yy + grid_heigh / 2 + ox;
						
						draw_sprite_ui_uniform(spr, 0, _sx, _sy, s);
					}
					
					var tx = _boxx + grid_width / 2;
					var ty = yy + grid_heigh + ui(4);
					draw_set_text(f_p2, fa_center, fa_top);
					if(txt == "Sample projects") {
						var _tw = string_width(_project.tag);
						var _th = string_height(_project.tag);
					
						draw_set_color(COLORS.dialog_splash_badge);
						draw_roundrect_ext(tx - _tw / 2 - ui(6), ty - ui(2), tx + _tw / 2 + ui(6), ty + _th, THEME_VALUE.selection_corner_radius, THEME_VALUE.selection_corner_radius, 0);
						draw_set_color(_project.tag == "Getting started"? COLORS._main_text_accent : COLORS._main_text_sub);
						draw_text(tx, ty - ui(2), _project.tag);						
						
						ty += line_get_height(, ui(4));
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

#region contest
	discord_map = ds_map_create();
	discord_map[? "Authorization"] = "Bot " + get_discord_bot_token();
	
	contest_req = noone;
	contest_message_req = [];
	
	if(os_is_network_connected()) {
		var url = "https://discord.com/api/v10/guilds/953634069646835773/threads/active";
		contest_req = http_request(url, "GET", discord_map, "");
	}
	
	nicknames  = ds_map_create();
	attachment = ds_map_create();
	contests   = [];
	
	grid_surface = surface_create(1, 1);
	banner       = noone;
	banner_alpha = 0;
	
	contest_viewing = noone;
	
	sp_contest = new scrollPane(x1 - x0 - ui(12), y1 - y0 - 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		var hh = 0;
		
		if(contest_viewing == noone) {
			var amo = array_length(contests);
		
			var bx = sp_contest.surface_w / 2;
			var sy = ui(16);
		
			var spr_w = sprite_get_width(s_contest_banner);
			var spr_h = sprite_get_height(s_contest_banner);
			var ss = (sp_contest.surface_w - 40) / spr_w;
		
			draw_sprite_ext(s_contest_banner, 0, bx, _y + sy, ss, ss, 0, c_white, 1);
		
			spr_w *= ss;
			spr_h *= ss;
		
			if(sHOVER && sp_contest.hover && point_in_rectangle(_m[0], _m[1], bx - spr_w / 2, _y + sy, bx + spr_w / 2, _y + sy + spr_h)) {
				TOOLTIP = "Go to Pixel Composer Discord server";
			
				if(mouse_press(mb_left, sFOCUS))
					url_open("https://discord.gg/aHGbYjQh63");
			}
		
			sy += spr_h - ui(4);
		
			var tx, ty, _col, _row;
			var grid_heigh = ui(128);
			var grid_width = ui(276);
			var grid_space = ui(20);
			var grid_hspac = ui(40);
			var col        = floor(sp_contest.surface_w / (grid_width + grid_space));
		
			grid_surface = surface_verify(grid_surface, grid_width, grid_heigh);
		
			for( var i = 0; i < amo; i++ ) {
				var contest = contests[i];
				_col = i % col;
				_row = floor(i / col);
				tx = grid_space + (grid_width + grid_space) * _col;
				ty = sy + grid_space + (grid_heigh + grid_hspac + grid_space) * _row;
				hh = max(hh, ty + grid_heigh + grid_hspac + grid_space + ui(32));
				ty = _y + ty;
			
				draw_sprite_stretched(THEME.node_bg, 0, tx, ty, grid_width, grid_heigh);
			
				var att = contest.title.attachments;
				if(att != noone) {
					var attSurf = attachment[? att.id];
				
					if(!is_array(attSurf) && sprite_exists(attSurf)) {
						var _sw = sprite_get_width(attSurf);
						var _sh = sprite_get_height(attSurf);
						var  ss = max(grid_width / _sw, grid_heigh / _sh);
					
						surface_set_target(grid_surface);
							DRAW_CLEAR
							draw_sprite_stretched(THEME.node_bg, 0, 0, 0, grid_width, grid_heigh);
						
							gpu_set_colorwriteenable(1, 1, 1, 0);
							draw_sprite_ext(attSurf, 0, grid_width / 2, grid_heigh / 2, ss, ss, 0, c_white, 1);
							gpu_set_colorwriteenable(1, 1, 1, 1);
						surface_reset_target();
					
						draw_surface_ext(grid_surface, tx, ty, 1, 1, 0, c_white, 0.85);
					}
				}
			
				if(sHOVER && sp_contest.hover && point_in_rectangle(_m[0], _m[1], tx, ty, tx + grid_width, ty + grid_heigh)) {
					draw_sprite_stretched_ext(THEME.node_active, 0, tx, ty, grid_width, grid_heigh, COLORS._main_accent, 1);
					
					if(mouse_press(mb_left, sFOCUS))
						contest_viewing = contest;
				} else 
					draw_sprite_stretched_ext(THEME.node_active, 0, tx, ty, grid_width, grid_heigh, COLORS._main_icon, 0.75);
			
				//draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
				//draw_text_ext_add(tx + ui(12), ty + ui(8), contest.name, -1, grid_width - ui(24));
			
				var ch_x = tx + grid_width - ui(8);
				var ch_y = ty + grid_heigh + ui(4);
			
				draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text);
				draw_text_ext_add(tx + ui(8), ch_y, contest.name, -1, grid_width - ui(8));
				var nm_h = string_height_ext(contest.name, -1, grid_width - ui(8));
			
				draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text);
				draw_text_add(ch_x, ch_y, contest.message_count);
			
				var _w = string_width(contest.message_count);
				draw_sprite_ui(THEME.chat, 0, ch_x - _w - ui(16), ch_y + ui(12), 0.75, 0.75,, COLORS._main_icon);
			
				var auth_msg = contest.title;
				var auth_nam = ds_map_try_get(nicknames, auth_msg.author.id, auth_msg.author.username);
			
				draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_add(tx + ui(8), ch_y + nm_h - ui(0), auth_nam);
			
				if(!struct_has(contest.title.meta, "theme")) continue;
				
				var _thm = __txt("Theme") + ": ";
				var txt  = _thm + contest.title.meta.theme;
				
				draw_set_text(f_p1, fa_left, fa_bottom, COLORS._main_text);
				var ww = string_width(txt);
				var thx = tx + grid_width - ui(12) - ww;
				var thy = ty + grid_heigh - ui(8);
					
				draw_set_color(COLORS._main_text_sub);
				draw_text_ext_add(thx, thy, _thm, -1, grid_width - ui(12 + 8));
				
				draw_set_color(COLORS._main_text);
				draw_text_ext_add(thx + string_width(_thm), thy, contest.title.meta.theme, -1, grid_width - ui(12 + 8));
			}
		} else {
			var con_name   = contest_viewing.name;
			var con_title  = contest_viewing.title;
			var con_author = ds_map_try_get(nicknames, con_title.author.id, con_title.author.username);
			
			var con_thumb  = con_title.attachments;
			if(con_thumb != noone) 
				con_thumb = attachment[? con_thumb.id];
			
			var tx = ui(8);
			var ty = _y + ui(68);
			hh = ui(68);
			
			var tw = sp_contest.surface_w - ui(16);
			var th = 0;
			var pad = ui(12);
			
			draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
			th = string_height_ext(con_title.content, -1, tw - pad * 2) + pad * 2;
			
			if(sprite_exists(con_thumb)) {
				var spr_w = sprite_get_width(con_thumb);
				var spr_h = sprite_get_height(con_thumb);
				ss = (tw - pad * 2) / spr_w;
				
				spr_w *= ss;
				spr_h *= ss;
				
				th += pad + spr_h;
			}
			
			var txt_y = ty + pad;
			draw_sprite_stretched_ext(THEME.node_bg, 0, tx, ty, tw, th, c_white, 0.8);
			draw_text_ext_add(tx + pad, txt_y, con_title.content, -1, tw - pad * 2);
			txt_y += string_height_ext(con_title.content, -1, tw - pad * 2) + pad;
			
			if(sprite_exists(con_thumb))
				draw_sprite_ext(con_thumb, 0, sp_contest.surface_w / 2, txt_y + spr_h / 2, ss, ss, 0, c_white, 1);
			
			hh += th + pad;
			
			var submissions = contest_viewing.messages;
			var amo = 0, col = 0;
			var grid_space = ui(20);
			var grid_width = (sp_contest.surface_w - grid_space - ui(16)) / 2;
			
			var _yy = txt_y + spr_h + pad * 2;
			var cx  = sp_contest.surface_w / 2;
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
			draw_text(cx, _yy + ui(8), __txt("Submissions"));
			var txt_w = string_width(__txt("Submissions"));
			draw_line(cx - txt_w / 2 - ui(8), _yy + ui(8), cx - ui(200), _yy + ui(8));
			draw_line(cx + txt_w / 2 + ui(8), _yy + ui(8), cx + ui(200), _yy + ui(8));
			
			_yy += ui(32);
			
			var grid_ys = [ _yy, _yy ];
			
			for( var i = 0, n = array_length(submissions) - 1; i < n; i++ ) {
				var _sub = submissions[i];
				var _att = _sub.attachments;
				
				if(array_length(_att) == 0) continue;
				amo++;
				
				var _att_first = _att[0];
				if(!ds_map_exists(attachment, _att_first.id)) {
					var path = DIRECTORY + "temp/" + _att_first.id + ".png";
					attachment[? _att_first.id] = [ http_get_file(_att_first.url, path), path ];
				} else if(!is_array(attachment[? _att_first.id]) && sprite_exists(attachment[? _att_first.id])) {
					var sub   = attachment[? _att_first.id];
					var spr_w = sprite_get_width(sub);
					var spr_h = sprite_get_height(sub);
					
					var ss = (grid_width - ui(16)) / spr_w;
					if(ss > 1) ss = floor(ss);
					
					spr_w *= ss;
					spr_h *= ss;
					
					var _col = grid_ys[0] > grid_ys[1];
					var grid_x = ui(8) + (grid_width + grid_space) * _col;
					var grid_y = grid_ys[_col];
					var grid_h = spr_h + ui(8) * 2;
					
					draw_sprite_stretched_ext(THEME.node_bg, 0, grid_x, grid_y, grid_width, grid_h, c_white, 0.8);
					draw_sprite_ext(sub, 0, grid_x + grid_width / 2, grid_y + grid_h / 2, ss, ss, 0, c_white, 1);
					
					var label_h = ui(32);
					var sub_author = ds_map_try_get(nicknames, _sub.author.id, _sub.author.username);
					draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
					draw_text_add(grid_x + ui(8), grid_y + grid_h + ui(4), sub_author);
					
					var react  = _sub.reactions;
					var hearts = 0;
					for( var j = 0; j < array_length(react); j++ ) {
						if(react[i].emoji.name != "💖") return;
						hearts = react[i].count_details.normal;
					}
					
					var ch_x = grid_x + grid_width - ui(8);
					var ch_y = grid_y + grid_h + ui(4);
					draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text);
					draw_text_add(ch_x, ch_y, hearts);
			
					var _w = string_width(hearts);
					draw_sprite_ui(THEME.heart, 0, ch_x - _w - ui(16), ch_y + ui(10),,,, COLORS._main_icon_light);
					
					grid_ys[_col] += grid_h + label_h + ui(8);
				}
			}
			
			hh = max(grid_ys[0] - _y, grid_ys[1] - _y);
			
			//banner
			
			banner_alpha = lerp_float(banner_alpha, _y < 0, 3);
			draw_sprite_stretched_ext(THEME.shadow_drop_down_24, 0, 0, ui(56), sp_contest.surface_w, ui(20), c_white, banner_alpha);
			draw_set_color(COLORS.panel_bg_clear);
			draw_rectangle(0, 0, sp_contest.surface_w, ui(64), false);
			
			draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
			draw_text_add(ui(32 + 8), ui(8 + 4), con_name);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(ui(32 + 8), ui(8 + 30), __txt("By") + " " + con_author);
			
			draw_set_text(f_p0b, fa_right, fa_top, COLORS._main_text_accent);
			draw_text_add(sp_contest.surface_w - ui(44), ui(8 + 8), amo);
			
			draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text_sub);
			draw_text_add(sp_contest.surface_w - ui(44), ui(8 + 28), __txt("Submissions"));
			
			if(sHOVER && sp_contest.hover && point_in_rectangle(_m[0], _m[1], ui(20 - 16), ui(36 - 16), ui(20 + 16), ui(36 + 16))) {
				draw_sprite_ui(THEME.arrow_back_32, 0, ui(20), ui(36),,,, c_white);
				if(mouse_press(mb_left, sFOCUS))
					contest_viewing = noone;
			} else
				draw_sprite_ui(THEME.arrow_back_32, 0, ui(20), ui(36),,,, COLORS._main_icon);
			
			var bx = sp_contest.surface_w - ui(20);
			var by = ui(36);
			
			if(sHOVER && sp_contest.hover && point_in_rectangle(_m[0], _m[1], bx - ui(16), by - ui(16), bx + ui(16), by + ui(16))) {
				TOOLTIP = __txtx("contest_open_discord", "Open in Discord");
				
				draw_sprite_ui(THEME.discord, 0, bx, by,,,, c_white);
				if(mouse_press(mb_left, sFOCUS))
					url_open($"https://discord.com/channels/953634069646835773/{contest_viewing.id}");
			} else
				draw_sprite_ui(THEME.discord, 0, bx, by,,,, COLORS._main_icon);
		}
		
		return hh;
	});
#endregion