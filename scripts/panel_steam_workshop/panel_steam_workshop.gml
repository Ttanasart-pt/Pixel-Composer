function Steam_workshop_item(_qData) constructor {
	title               = _qData[? "title"];
	description         = _qData[? "description"];
	time_created        = _qData[? "time_created"];
	time_uploaded       = _qData[? "time_uploaded"];
	
	creator_app_id      = _qData[? "creator_app_id"];
	consume_app_id      = _qData[? "consumer_app_id"];
	owner_steam_id      = _qData[? "steam_id_owner"];
	owner_account_id    = _qData[? "account_id_owner"];
	
	visibility          = _qData[? "visibility"];
	banned              = _qData[? "banned"];
	accepted            = _qData[? "accepted_for_use"];
	
	tags                = _qData[? "tags"];
	tag_version         = "";
	handle_file         = int64(_qData[? "handle_file"]);
	handle_preview_file = int64(_qData[? "handle_preview_file"]);
	
	file_id             = int64(_qData[? "published_file_id"]);
	file_type           = _qData[? "file_type"];
	
	filename            = _qData[? "filename"];
	filesize            = _qData[? "file_size"];
	preview_file_size   = _qData[? "preview_file_size"];
	url                 = _qData[? "url"];
	
	votes_up            = _qData[? "votes_up"]   ?? 0;
	votes_down          = _qData[? "votes_down"] ?? 0;
	vote_score          = _qData[? "score"]      ?? 0;
	
	preview_path   = $"ugc\\{file_id}.png"
	preview_fpath  = ROAMING_DIRECTORY + preview_path;
	preview_sprite = undefined;
	author         = undefined;
	
	type = FILE_TYPE.assets;
	
	for( var i = 0, n = array_length(tags); i < n; i++ ) {
		var _tag = tags[i];
		if(string_starts_with(_tag, "1."))
			tag_version = _tag;
			
		if(_tag == "Project")    type = FILE_TYPE.project;
		if(_tag == "Collection") type = FILE_TYPE.collection;
	}
	
	static fetchPreviewSprite = function() {
		if(file_exists_empty(preview_fpath)) {
			preview_sprite = sprite_add(preview_fpath);
			return;
		}
		
		directory_verify(filename_dir(preview_fpath));
		
		preview_sprite = -1;
		asyncCall(steam_ugc_download(handle_preview_file, preview_path), function(_params, _data) /*=>*/ {
			var _result = _data[? "result"];
			var _type   = _data[? "event_type"];
			preview_sprite = -2;
		
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_warning($"UGC get thumbnail error {_result}: {errStr}");
				return;
			}
			
			if(file_exists_empty(preview_fpath))
				preview_sprite = sprite_add(preview_fpath);
			else 
				noti_warning($"UGC get thumbnail error: File not found {preview_fpath}");
		});
	}
	static getPreviewSprite = function() {
		if(preview_sprite == undefined) 
			fetchPreviewSprite();
		return preview_sprite;
	}
	
	static fetchAuthorData = function() {
		author = "";
		asyncCall(steam_get_user_persona_name(int64(owner_steam_id)), function(_params, _data) /*=>*/ {
			author = _data[? "persona_name"];
		});
	}
	static getAuthorName = function() {
		if(author == undefined) 
			fetchAuthorData();
		return author;
	}
	
	static drawTooltip = function() {
		var _pd = ui(10);
		var ww  = ui(320);
		var _w  = 0;
		var _h  = 0;
		
		var _aut = getAuthorName();
		
		draw_set_font(f_h5);
		_h += string_height_ext(title, -1, ww) - ui(4);
		_w = max(_w, string_width_ext(title, -1, ww));
		
		draw_set_font(f_p1);
		_h += string_height_ext(_aut, -1, ww);
		_w = max(_w, string_width_ext(_aut, -1, ww));
		
		if(description != "") {
			draw_set_font(f_p1);
			_h += ui(8);
			_h += string_height_ext(description, -1, ww);
			_w = max(_w, string_width_ext(description, -1, ww));
		}
		
		if(array_length(tags)) {
			draw_set_font(f_p1);
			_h += ui(8);
			var tx = 0;
			var hh = line_get_height(f_p1, ui(4));
			var th = hh;
			for( var i = 0, n = array_length(tags); i < n; i++ ) {
				var _ww = string_width(tags[i]) + ui(16);
				_w = max(_w, _ww);
				
				if(tx + _ww + ui(2) > _w - ui(16)) {
					tx = 0;
					th += hh + ui(2);
				}
				tx += _ww + ui(2);
			}
			_h += th;
		}
		
		////////////////////////////////////////////////////////////
		
		var mx = min(mouse_mxs + _pd, WIN_W - (_w + _pd * 2));
		var my = min(mouse_mys + _pd, WIN_H - (_h + _pd * 2));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, _w + _pd * 2, _h + _pd * 2);
		draw_sprite_stretched(THEME.textbox, 0, mx, my, _w + _pd * 2, _h + _pd * 2);
		
		////////////////////////////////////////////////////////////
		
		var tx = mx + _pd;
		var ty = my + ui(8);
		
		draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
		draw_text_line(tx, ty, title, -1, _w);
		ty += string_height_ext(title, -1, _w) - ui(4);
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_line(tx, ty, _aut, -1, _w);
		ty += string_height_ext(_aut, -1, _w);
		
		if(description != "") {
			ty += ui(8);
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
			draw_text_line(tx, ty, description, -1, _w);
			ty += string_height_ext(description, -1, _w);
		}
		
		if(array_length(tags)) {
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
			ty += ui(8);
			var tx = 0;
			var hh = line_get_height(f_p1, ui(4));
			
			for( var i = 0, n = array_length(tags); i < n; i++ ) {
				var ww = string_width(tags[i]) + ui(16);
				if(tx + ww + ui(2) > _w - ui(16)) {
					tx = 0;
					ty += hh + ui(2);
				}
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, mx + ui(8) + tx, ty, ww, hh, COLORS._main_icon, 1);
				draw_text(mx + ui(8) + tx + ui(8), ty + hh / 2, tags[i]);
			
				tx += ww + ui(2);
			}
		}
		
	}

	static refresh = function() {
		if(sprite_exists(preview_sprite)) sprite_delete(preview_sprite);
		preview_sprite = undefined;
	}
}

function Panel_Steam_Workshop() : PanelContent() constructor {
	title     = "Steam Workshop";
	auto_pin  = true;
	
	w       = ui(960);
	h       = ui(640);
	min_w   = ui(640);
	min_h   = ui(480);
	padding = ui(6);
	
	sort_type      = 1;
	sort_trend_day = 0;
	match_type     = 0;
	
	querying   = false;
	
	item_per_page = 30;
	page       = 1;
	pageTotal  = 1;
	pageIndex  = [];
	
	own_filter   = true;
	tag_filter   = [];
	ver_filter   = [];
	type_filter  = [];
	hold_filter  = 0;
	
	fileCache    = {};
	allFiles     = [];
	displayFiles = [];
	
	search_string = "";
	type_strings  = [ "Project", "Collection" ];
	
	sc_sort = new scrollBox([ "Vote", "Trending", "Publication Date" ], 
		function(i) /*=>*/ { if(sort_type == i) return; sort_type = i; queryFiles(); }, false).setAlign(fa_left);
	
	sc_trend_days = new scrollBox([ "Today",  "This Week",  "This Month",  "This Year" ], 
		function(i) /*=>*/ { if(sort_trend_day == i) return; sort_trend_day = i; queryFiles(); }, false).setAlign(fa_left);
	
	tb_search = textBox_Text(function(s) /*=>*/ { search_string = s; filterFiles(); })
				.setAutoUpdate()
				.setEmpty()
				.setAlign(fa_right)
				.setVAlign(fa_center);
	page_goto = undefined;
	
	ds_map_info = ds_map_create();
	
	function setPage(_page = 1) {
		page = _page;
		setPageIndices();
	}
	
	function setPageIndices() {
		pageIndex = [];
		if(pageTotal == 0) return;
		
		for( var i = 1; i <= min(3, pageTotal); i++ ) 
			array_push(pageIndex, i);
		
		for( var i = max(1, page - 1); i <= min(page + 1, pageTotal); i++ ) 
			array_push(pageIndex, i);
		
		for( var i = max(1, pageTotal - 3); i <= pageTotal; i++ ) 
			array_push(pageIndex, i);
		
		pageIndex = array_unique(pageIndex);
		array_sort(pageIndex, true);
		
		for( var i = 1, n = array_length(pageIndex); i < n; i++ ) {
			if(pageIndex[i] - pageIndex[i-1] > 1) {
				array_insert(pageIndex, i, -1);
				i++;
			}
		}
	}
	
	function filterFiles(_reset = true, _offset = 0) {
		if(_reset) {
			sc_content.setScroll(0);
			displayFiles = [];
			page = 1;
		}
		
		var _tag_use  = !array_empty(tag_filter);
		var _type_use = !array_empty(type_filter);
		var _ver_use  = !array_empty(ver_filter);
		var _search   = string_lower(search_string);
		
		for( var i = _offset, n = array_length(allFiles); i < n; i++ ) {
			var _file = allFiles[i];
			
			if(_tag_use) {
				var _match = array_overlap(tag_filter, _file.tags);
				if(!_match) continue;
			}
			
			if(_type_use) {
				var _match = array_overlap(type_filter, _file.tags);
				if(!_match) continue;
			}
			
			if(_ver_use) {
				var _match = false;
				for( var j = 0, m = array_length(ver_filter); j < m; j++ ) {
					if(string_starts_with(_file.tag_version, ver_filter[j]))
						_match = true;
				}
				if(!_match) continue;
			}
			
			if(search_string != "") {
				var _match = false;
				    _match = _match || string_pos(_search, string_lower(_file.title)) != 0;
				    _match = _match || string_pos(_search, string_lower(_file.getAuthorName())) != 0;
				
				if(!_match) continue;
			}
			
			if(!own_filter) {
				var _owned = struct_has(STEAM_SUBS_IDS, _file.file_id);
				if(_owned) continue;
			}
			
			array_push(displayFiles, _file);
		}
		
		pageTotal = ceil(array_length(displayFiles) / item_per_page);
		setPageIndices();
	}
	
	function queryAllFiles(_page = page) {
		var _type  = ugc_query_RankedByVote;
		var _mType = ugc_match_Items;
		
		switch(sort_type) {
			case 0 : _type = ugc_query_RankedByVote;            break;
			case 1 : _type = ugc_query_RankedByTrend;           break;
			case 2 : _type = ugc_query_RankedByPublicationDate; break;
		}
		
		var _que = steam_ugc_create_query_all(_type, _mType, _page);
		
		if(sort_type == 1) {
			var _days = 1;
			switch(sort_trend_day) {
				case 0 : _days = 1;   break;
				case 1 : _days = 7;   break;
				case 2 : _days = 30;  break;
				case 3 : _days = 365; break;
			}
			
			steam_ugc_query_set_ranked_by_trend_days(_que, _days);
		}
		
		asyncCall(steam_ugc_send_query(_que), function(_param, _data) /*=>*/ {
			var _result = _data[? "result"];
			
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_warning($"UGC query error {_result}: {errStr}");
				querying = false;
				return;
			}
			
			var _total_matching = _data[? "total_matching"];
			var _num_results    = _data[? "num_results"];
			var _page = _param.page;
			
			if(_total_matching == 0 || _num_results == 0) {
				filterFiles(_page == 1, (_page - 1) * 50);
				querying = false;
				return;
			}
			
			var _results_list = _data[? "results_list"];
			var _result_len   = ds_list_size(_results_list);
			
			for( var i = 0; i < _result_len; i++ ) {
				var _res  = _results_list[| i];
				var _fid  = int64(_res[? "published_file_id"]);
				var _item = struct_has(fileCache, _fid)? fileCache[$ _fid] : new Steam_workshop_item(_res);
				
				fileCache[$ _fid] = _item;
				array_push(allFiles, _item);
			}
			
			if(_num_results == 50)
				queryAllFiles(_page + 1);
			else 
				querying = false;
			
			filterFiles(_page == 1, (_page - 1) * 50);
			
		}, { page : _page });
	}
	
	function queryFiles() {
		sc_content.setScroll(0);
		querying     = true;
		allFiles     = [];
		displayFiles = [];
		
		queryAllFiles(1);
	}
	
	sc_content = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		
		var _hover = sc_content.hover;
		var _focus = sc_content.active;
		
		var _w    = sc_content.surface_w;
		var _h    = sc_content.surface_h;
		
		if(!querying && array_empty(displayFiles)) {
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_w / 2, _h / 2, "No results");
			return 0;
		}
		
		var _gw   = ui(120);
		var _gh   = ui(120);
		var _th   = line_get_height(f_p2b) + ui(4) + line_get_height(f_p4);
		var _marx = ui(4), _mary = ui(4);
		
		var _ind_start = (page - 1) * item_per_page;
		var _ind_end   = min(_ind_start + item_per_page, array_length(displayFiles));
		
		var _itemAmo = _ind_end - _ind_start;
		var _amo = querying? item_per_page : _itemAmo;
		var _col = max(1, floor(_w / _gw));
		var _row = ceil(_amo / _col);
		
		_gw   = _w / _col;
		_marx = ui(4) + (_gw - _gh) / 2;
		
		var _ghh = _gh + ui(6) + _th + ui(4);
		var _hh  = _ghh * _row;
		
		var _scis = gpu_get_scissor();
		var _filt = undefined;
		
		for( var i = 0; i < _amo; i++ ) {
			var _c = i % _col;
			var _r = floor(i / _col);
			
			var _gx = _gw * _c;
			var _gy = _y + _ghh * _r;
			
			var _x0 = _gx + _marx;
			var _y0 = _gy + _mary;
			var _x1 = _gx + _gw - _marx;
			var _y1 = _gy + _gh - _mary;
			
			var _cw = _gw - _marx * 2;
			var _ch = _gh - _mary * 2;
			
			var _xc = (_x0 + _x1) / 2;
			var _yc = (_y0 + _y1) / 2;
			
			var _draw = _y0 < _h && _gy + _ghh > 0;
			if(!_draw) continue;
			
			draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x0, _y0, _cw, _ch);
			if(querying && i >= _itemAmo) continue;
			
			var _file = displayFiles[_ind_start + i];
			var _fid  = _file.file_id;
			var _hov  = _hover && point_in_rectangle(_m[0], _m[1], _x0, _y0, _x1, _y1);
			var _spr  = _file.getPreviewSprite();
			var _own  = struct_has(STEAM_SUBS_IDS, _fid);
			var _addi = struct_has(STEAM_SUBSCRIBING, _fid);
			
			if(_spr == -1) {
				draw_sprite_ui(THEME.loading, 0, _xc, _yc, 1, 1, current_time / 2, COLORS._main_icon, 1);
				
			} else if(sprite_exists(_spr)) {
				gpu_set_colorwriteenable(1, 1, 1, 0);
				draw_sprite_stretched(_spr, 0, _x0, _y0, _cw, _ch);
				gpu_set_colorwriteenable(1, 1, 1, 1);
			}
			
			var _ox = _x0 + ui(14);
			var _oy = _y1 - ui(14);
			var _subHov = _hov && point_in_rectangle(_m[0], _m[1], _ox - ui(8), _oy - ui(8), _ox + ui(8), _oy + ui(8));
			
			if(_own) {
				if(_subHov) {
					draw_sprite_ui(THEME.cross_inv_16, 0, _ox, _oy, 1, 1, 0, COLORS._main_value_negative, 1);
					TOOLTIP = __txt("Unsubscribe");
					
					if(mouse_lpress(_focus))
						UGC_unsubscribe_item(_fid);
					
				} else 
					draw_sprite_ui(THEME.accept_inv_16, 0, _ox, _oy, 1, 1, 0, COLORS._main_icon, .8);
				
			} else if(_addi) {
				draw_sprite_ui(THEME.loading_s, 0, _ox, _oy, .75, .75, current_time / 2, COLORS._main_icon, .8);
				var _added = steam_ugc_get_item_install_info(_fid, ds_map_info);
				
			} else {
				draw_sprite_ui(THEME.add_inv_16, 0, _ox, _oy, 1, 1, 0, COLORS._main_value_positive, .8 + _subHov * .2);
				if(_subHov || _hov) {
					if(_subHov) TOOLTIP = __txt("Subscribe");
					
					if(mouse_lpress(_focus))
						UGC_subscribe_item(_fid);
				}
			}
			
			if(_hov) {
				draw_sprite_stretched_add(THEME.box_r5, 1, _x0, _y0, _cw, _ch, c_white, .5);
				if(!_subHov) TOOLTIP = _file;
				
				if(mouse_rpress(_focus)) {
					menuCall("steam_workshop_item", [
						menuItem(__txt("Open in browser"), function(_fid) /*=>*/ {
							steam_activate_overlay_browser($"https://steamcommunity.com/sharedfiles/filedetails/?id={_fid}")
						}).setParam(_fid)
					])
				}
				
				if(!_subHov && _own && mouse_lpress(_focus)) {
					var _info = steam_ugc_get_item_install_info(_fid, ds_map_info);
					
					if(_info) {
						var _dir = ds_map_info[? "folder"];
							
						if(_file.type == FILE_TYPE.project) {
							var _fil = file_find_first(_dir + "/*.pxc", 0); file_find_close();
							var _pat = filename_combine(_dir, _fil);
							
							DRAGGING = { type : "Project", data : { path: _pat, spr: _spr } };
						}
						
						if(_file.type == FILE_TYPE.collection) {
							var _fil = file_find_first(_dir + "/*.pxcc", 0); file_find_close();
							var _pat = filename_combine(_dir, _fil);
							
							DRAGGING = { type : "Collection", data : { path: _pat, spr: _spr } };
						}
					}
				}
			}
			
			var _vote_up   = _file.votes_up;
			var _vote_down = _file.votes_down;
			var _vote_totl = _vote_up + _vote_down;
			
			var _vy = _y1 + ui(4);
			var _vx = _x0;
			var _vw = _cw;
			var _vh = ui(2);
			
			if(_vote_totl == 0) {
				draw_set_color(COLORS._main_icon);
				draw_set_alpha(.5);
				draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
				draw_set_alpha(1);
				
			} else {
				var _vote_rat = _vote_up / _vote_totl;
				
				draw_set_color(COLORS._main_value_negative);
				draw_rectangle(_vx, _vy, _vx + _vw, _vy + _vh, false);
				
				draw_set_color(COLORS._main_value_positive);
				draw_rectangle(_vx, _vy, _vx + _vw * _vote_rat, _vy + _vh, false);
			}
			
			var _ty = _vy + ui(6);
			
			gpu_set_scissor(_x0, _ty, _cw, _th);
			draw_set_color(COLORS.panel_bg_clear_inner);
			draw_rectangle(_x0, _ty, _x1, _ty + _th, false);
			
			draw_set_text(f_p2b, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_x0, _ty, _file.title);
			_ty += line_get_height(f_p2b);
			
			var _hovAuthor = _hover && point_in_rectangle(_m[0], _m[1], _x0, _ty - ui(2), _x1, _ty + line_get_height(f_p4, 4));
			var _author    = _file.getAuthorName();
			draw_set_text(f_p4, fa_left, fa_top, _hovAuthor? COLORS._main_accent : CDEF.main_mdwhite);
			draw_text_add(_x0, _ty, _author);
			gpu_set_scissor(_scis);
			
			if(_hovAuthor && mouse_lpress(_focus))
				_filt = _author;
		}
		
		if(_filt != undefined) {
			search_string = _filt; 
			filterFiles();	
		}
		
		return _hh;
	});
	
	sc_filter = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var _hover = sc_filter.hover;
		var _focus = sc_filter.active;
		
		var _w = sc_filter.surface_w;
		var _h = sc_filter.surface_h;
		
		var ww = _w - ui(20);
		var hh = 0;
		
		var x0 = ui(10);
		var y0 = _y;
		
		var mx = _m[0];
		var my = _m[1];
		
		if(hold_filter != 0 && mouse_lrelease()) {
			hold_filter = 0;
			filterFiles();
		}
		
		#region own
			y0 += ui(8);
			
			var hv = _hover && point_in_rectangle(mx, my, x0, y0, x0 + ww, y0 + ui(16));
			var hs = own_filter;
			
			draw_sprite_stretched_ext(THEME.box_r5_clr, 0, x0, y0, ui(16), ui(16), COLORS._main_icon);
			if(hs) draw_sprite_stretched_ext(THEME.box_r2, 0, x0 + ui(2), y0 + ui(2), ui(16 - 4), ui(16 - 4), COLORS._main_accent);
			
			if(hv) {
				draw_sprite_stretched_add(THEME.box_r5, 1, x0, y0, ui(16), ui(16), COLORS._main_icon, .5);
				if(mouse_lpress(_focus)) {
					own_filter = !own_filter;
					filterFiles();
				}
			}
			
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			draw_text_add(x0 + ui(22), y0 + ui(8), "Subscribed");
			y0 += ui(22);
		#endregion
		
		#region type
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(x0, y0, "Type");
			y0 += ui(24);
			
			for (var i = 0, n = array_length(type_strings); i < n; i++) {
				var tg = type_strings[i];
				
				var hv = _hover && point_in_rectangle(mx, my, x0, y0, x0 + ww, y0 + ui(16));
				var hs = array_exists(type_filter, tg);
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, x0, y0, ui(16), ui(16), COLORS._main_icon);
				if(hs) draw_sprite_stretched_ext(THEME.box_r2, 0, x0 + ui(2), y0 + ui(2), ui(16 - 4), ui(16 - 4), COLORS._main_accent);
				
				if(hv) {
					draw_sprite_stretched_add(THEME.box_r5, 1, x0, y0, ui(16), ui(16), COLORS._main_icon, .5);
					if(hold_filter != 0) {
						     if(hold_filter ==  1 &&  hs) array_remove(type_filter, tg);
						else if(hold_filter == -1 && !hs) array_push(type_filter, tg);
						
					} else if(mouse_lpress(_focus)) {
						if(hs) array_remove(type_filter, tg);
						else   array_push(type_filter, tg);
						
						hold_filter = hs? 1 : -1;
					}
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(x0 + ui(22), y0 + ui(8), tg);
				y0 += ui(22);
			}
			
			y0 += ui(8);
		#endregion
		
		#region tags
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(x0, y0, "Tags");
			y0 += ui(24);
			
			for (var i = 0, n = array_length(META_TAGS); i < n; i++) {
				var tg = META_TAGS[i];
				
				var hv = _hover && point_in_rectangle(mx, my, x0, y0, x0 + ww, y0 + ui(16));
				var hs = array_exists(tag_filter, tg);
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, x0, y0, ui(16), ui(16), COLORS._main_icon);
				if(hs) draw_sprite_stretched_ext(THEME.box_r2, 0, x0 + ui(2), y0 + ui(2), ui(16 - 4), ui(16 - 4), COLORS._main_accent);
				
				if(hv) {
					draw_sprite_stretched_add(THEME.box_r5, 1, x0, y0, ui(16), ui(16), COLORS._main_icon, .5);
					if(hold_filter != 0) {
						     if(hold_filter ==  1 &&  hs) array_remove(tag_filter, tg);
						else if(hold_filter == -1 && !hs) array_push(tag_filter, tg);
						
					} else if(mouse_lpress(_focus)) {
						if(hs) array_remove(tag_filter, tg);
						else   array_push(tag_filter, tg);
						
						hold_filter = hs? 1 : -1;
					}
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(x0 + ui(22), y0 + ui(8), tg);
				y0 += ui(22);
			}
			
			y0 += ui(8);
		#endregion
		
		#region version
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(x0, y0, "Versions");
			y0 += ui(24);
			
			for (var i = 0, n = array_length(VERSIONS); i < n; i++) {
				var vv = VERSIONS[i];
				var vs = $"1.{vv}";
				
				var hv = _hover && point_in_rectangle(mx, my, x0, y0, x0 + ww, y0 + ui(16));
				var hs = array_exists(ver_filter, vs);
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, x0, y0, ui(16), ui(16), COLORS._main_icon);
				if(hs) draw_sprite_stretched_ext(THEME.box_r2, 0, x0 + ui(2), y0 + ui(2), ui(16 - 4), ui(16 - 4), COLORS._main_accent);
				
				if(hv) {
					draw_sprite_stretched_add(THEME.box_r5, 1, x0, y0, ui(16), ui(16), COLORS._main_icon, .5);
					if(hold_filter != 0) {
						     if(hold_filter ==  1 &&  hs) array_remove(ver_filter, vs);
						else if(hold_filter == -1 && !hs) array_push(ver_filter, vs);
						
					} else if(mouse_lpress(_focus)) {
						if(hs) array_remove(ver_filter, vs);
						else   array_push(ver_filter, vs);
						
						hold_filter = hs? 1 : -1;
					}
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(x0 + ui(22), y0 + ui(8), vs);
				y0 += ui(22);
			}
			
			y0 += ui(8);
		#endregion
		
		return y0 - _y;
	});
	sc_filter.show_scroll = false;
	
	function drawContent(panel) {
		var _filt_width  = ui(160);
		var _sort_height = ui(32);
		var _page_height = ui(24);
		
		var px = padding + _filt_width;
		var py = padding + _sort_height;
		var pw = w - padding * 2 - _filt_width;
		var ph = h - padding * 2 - _sort_height;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px, py, pw, ph);
		
		sc_content.verify(pw - ui(16), ph - _page_height - ui(16));
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.drawOffset(px + ui(8), py + ui(8), mx, my);
		
		sc_filter.verify(_filt_width, ph - ui(16));
		sc_filter.setFocusHover(pFOCUS, pHOVER);
		sc_filter.drawOffset(padding, py + ui(8), mx, my);
		
		#region actions
			draw_sprite_stretched(THEME.ui_panel_bg, 1, padding, padding, _filt_width - ui(4), _sort_height - ui(4));
			
			var bx = padding + ui(4);
			var by = padding + ui(2);
			var bs = ui(24);
			var bc = [COLORS._main_icon, COLORS._main_icon_light];
			
			if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Open in Browser"), THEME.steam, 0, bc) == 2)
				steam_activate_overlay_browser("https://steamcommunity.com/app/2299510/workshop/");
			bx += bs + ui(4);
			
			bx = _filt_width - bs - ui(4);
			
			if(buttonInstant(noone, bx, by, bs, bs, [mx, my], pHOVER, pFOCUS, __txt("Refresh"), THEME.refresh_16, 0, bc) == 2) {
				var _dir = ROAMING_DIRECTORY + "ugc";
				directory_clear(_dir);
				var _files = struct_get_names(fileCache);
				for( var i = 0, n = array_length(_files); i < n; i++ )
					fileCache[$ _files[i]].refresh();
				
				queryFiles();
			}
			bx -= bs + ui(4);
			
		#endregion
		
		#region sort
			var ww = _filt_width;
			var x0 = px + ui(8);
			var y0 = padding;
			var hh = _sort_height - padding;
			
			var _txt = __txt("Sort by: ");
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
			draw_text(x0, y0 + hh / 2, _txt);
			x0 += string_width(_txt);
			
			var _param = new widgetParam(x0, y0, ww, hh, sort_type, {}, [mx, my], x, y)
				.setFocusHover(pFOCUS, pHOVER)
				.setFont(f_p2);
				
			sc_sort.drawParam(_param);
			
			if(sort_type == 1) {
				x0 += ww + ui(8);
			
				var _param = new widgetParam(x0, y0, ui(104), hh, sort_trend_day, {}, [mx, my], x, y)
					.setFocusHover(pFOCUS, pHOVER)
					.setFont(f_p2);
					
				sc_trend_days.drawParam(_param);
					
			}
		#endregion
		
		#region search
			var ww = ui(200);
			var x0 = px + pw - ww;
			var y0 = padding;
			var hh = _sort_height - padding;
			
			var _param = new widgetParam(x0, y0, ww, hh, search_string, {}, [mx, my], x, y)
				.setFocusHover(pFOCUS, pHOVER)
				.setFont(f_p2);
				
			tb_search.setBoxColor(search_string == ""? c_white : COLORS._main_accent).drawParam(_param);
			
			if(search_string == "")
				draw_sprite_ui(THEME.search, 0, x0 + ui(16), y0 + hh / 2, 1, 1, 0, COLORS._main_icon);
			else {
				var _hov = pHOVER && point_in_circle(mx, my, x0 + ui(16), y0 + hh / 2, hh / 2);
				
				draw_sprite_ui(THEME.cross_16, 0, x0 + ui(16), y0 + hh / 2, 1, 1, 0, _hov? COLORS._main_icon_light : COLORS._main_icon);
				if(_hov && mouse_lpress(pFOCUS)) {
					tb_search.deactivate();
					search_string = ""; 
					filterFiles();	
				}
			}
		#endregion
		
		#region page
			var _ps = ui(24);
			var _page_l  = array_length(pageIndex);
			var _page_xc = px + pw / 2;
			var _page_x0 = _page_xc - (_page_l - 1) / 2 * _ps;
			var _pageSet = noone;
			
			var _py = py + ph - _page_height / 2 - ui(4);
			
			if(page_goto != undefined) {
				var _goto_page = KEYBOARD_NUMBER;
				if(key_press(vk_enter)) {
					_pageSet  = clamp(round(_goto_page), 0, pageTotal);
					page_goto = undefined;
					
				} else if(key_press(vk_escape)) {
					page_goto = undefined;
					
				} else if(mouse_lpress()) {
					page_goto = undefined;
					
				}
			}
			
			for( var i = 0; i < _page_l; i++ ) {
				var _page = pageIndex[i];
				var _px = _page_x0 + i * _ps;
				
				if(page_goto == i) {
					draw_sprite_stretched_add(THEME.box_r2, 1, _px - _ps/2, _py - _ps/2, _ps, _ps, COLORS._main_accent, 1);
					draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
					draw_text_add(_px, _py, KEYBOARD_NUMBER ?? "");
					continue;
				}
				
				var _hv = pHOVER && point_in_rectangle(mx, my, _px - _ps/2 + 1, _py - _ps/2, _px + _ps/2 - 1, _py + _ps/2);
				
				if(_page == -1) {
					if(_hv) {
						draw_sprite_stretched_add(THEME.box_r2, 1, _px - _ps/2, _py - _ps/2, _ps, _ps, c_white, .25);
						if(mouse_lpress(pFOCUS)) {
							page_goto = i;
							KEYBOARD_RESET
						}
					}
					
					draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text_sub);
					draw_text_add(_px, _py, "...");
					continue;
				} 
				
				var _pc = _page == page;
				
				if(_hv && !_pc) {
					draw_sprite_stretched_add(THEME.box_r2, 1, _px - _ps/2, _py - _ps/2, _ps, _ps, c_white, .25);
					
					if(mouse_lpress(pFOCUS))
						_pageSet = _page;
				}
				
				draw_set_text(f_p2, fa_center, fa_center, _pc? COLORS._main_accent : COLORS._main_text_sub);
				draw_text_add(_px, _py, _page);
				
			}
			
			if(_pageSet != noone)
				setPage(_pageSet);
		#endregion
		
	}
	
	queryFiles();
	
}