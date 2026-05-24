function Panel_Steam_Workshop_Selector(_onSelect) : PanelContent() constructor {
	title     = "Select Workshop file";
	auto_pin  = true;
	onSelect  = _onSelect;

	#region dimension
		w       = ui(800);
		h       = ui(560);
		min_w   = ui(640);
		min_h   = ui(480);
		padding = ui(6);
		
		grid_size    = ui(120);
		grid_size_to = ui(120);
	#endregion
		
	allFiles     = [];
	displayFiles = [];
	
	querying      = false;
	item_per_page = 30;
		
	page      = 0;
	pageTotal = 0;
	page_goto = undefined;
	pageIndex = [];

	function setPage(_page = 1) {
		sc_content.setScroll(0);
		page = _page;
		setPageIndices();
	}
	
	function setPageIndices() {
		pageTotal = ceil(array_length(displayFiles) / item_per_page);
		pageIndex = [];
		
		for( var i = 0; i <= min(3, pageTotal - 1); i++ ) 
			array_push(pageIndex, i);
		
		for( var i = max(0, page - 1); i <= min(page + 1, pageTotal - 1); i++ ) 
			array_push(pageIndex, i);
		
		for( var i = max(0, pageTotal - 1 - 3); i <= pageTotal - 1; i++ ) 
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
	
	function queryAuthorPageNew(_page = 1) {
		var _que = steam_ugc_create_query_all(ugc_query_RankedByPublicationDate, ugc_match_Items, _page);
		steam_ugc_query_set_allow_cached_response(_que, true);
		
		querying = true;
		asyncCallGroup("steam", steam_ugc_send_query(_que), function(_param, _data) /*=>*/ {
			var _result = _data[? "result"];
			querying = false;
			
			if(_result != ugc_result_success) {
				var errStr = steam_ugc_get_error(_result);
				noti_status($"UGC query error {_result}: {errStr}");
				return;
			}
			
			var _total_matching = _data[? "total_matching"];
			var _num_results    = _data[? "num_results"];
			
			var _results_list   = _data[? "results_list"];
			var _result_len     = ds_list_size(_results_list);
			var _aid = STEAM_ID;
			
			for( var i = 0; i < _result_len; i++ ) {
				var _res  = _results_list[| i];
				var _fid  = int64(_res[? "published_file_id"]);
				var _item = has(WORKSHOP_FILE_CACHE, _fid)? WORKSHOP_FILE_CACHE[$ _fid] : new Steam_workshop_item().setMap(_res);
				
				WORKSHOP_FILE_CACHE[$ _fid] = _item;
				if(_item.owner_steam_id == _aid)
					array_push(allFiles, _item);
			}
			
			if(_num_results == 50) queryAuthorPageNew(_param.page + 1);
			
			allFiles     = array_unique(allFiles);
			displayFiles = allFiles;
			setPageIndices();
			
		}, {page: _page});
		
	} queryAuthorPageNew();
	
	sc_content = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		
		var _hover = sc_content.hover;
		var _focus = sc_content.active;
		
		var _w    = sc_content.surface_w;
		var _h    = sc_content.surface_h;
		
		var _rx = sc_content.x;
		var _ry = sc_content.y;
		
		if(!querying && array_empty(displayFiles)) {
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_w / 2, _h / 2, "No results");
			return 0;
		}
		
		var _gw   = grid_size;
		var _gh   = _gw;
		var _th   = line_get_height(f_p2b) + ui(4) + line_get_height(f_p4);
		var _marx = ui(4), _mary = ui(4);
		
		var _ind_start = page * item_per_page;
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
		
		for( var i = 0; i < _amo; i++ ) {
			var _c = i % _col;
			var _r = floor(i / _col);
			
			var _gx = _gw * _c;
			var _gy = _y + _ghh * _r;
			
			var _x0 = _gx + _marx;
			var _y0 = _gy + _mary;
			var _x1 = _gx + _gw - _marx;
			var _y1 = _gy + _gh - _mary;
			
			var _cw = _x1 - _x0;
			var _ch = _y1 - _y0;
			
			var _draw = _y0 < _h && _gy + _ghh > 0;
			if(!_draw) continue;
			
			if(querying && i >= _itemAmo) {
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x0, _y0, _cw, _ch, c_white, sin(current_time / 150 - i * .5) * .2 + .8);
				continue;
			}
			
			var _file = displayFiles[_ind_start + i];
			var _fhov = _hover && point_in_rectangle(_m[0], _m[1], _x0, _y0, _x1, _y1);
			
			_file.drawStatic(_x0, _y0, _cw, _ch);
			if(_fhov) {
				draw_sprite_stretched_add(THEME.box_r5, 1, _x0, _y0, _cw, _ch, c_white, .5);
				if(onSelect && mouse_lpress(_focus)) {
					onSelect(_file);
					close();
				}
			}
		}
		
		return _hh;
	}).setUseDepth();
	
	
	////- Draw
	
	function drawContent(panel) {
		if(MOUSE_MOVED) hold_tooltip = false;
		
		var _page_height = ui(24);
		
		#region content
			var px = padding;
			var py = padding;
			var pw = w - padding * 2;
			var ph = h - padding * 2;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, px, py, pw, ph);
			
			sc_content.verify(pw - ui(16), ph - _page_height - ui(16));
			sc_content.setFocusHover(pFOCUS, pHOVER);
			sc_content.drawOffset(px + ui(8), py + ui(8), mx, my);
		#endregion
			
		#region page
			var _ps = ui(24);
			var _py = py + ph - _page_height / 2 - ui(4);
			var _page_l  = array_length(pageIndex);
			var _page_xc = px + pw / 2;
			var _page_x0 = _page_xc - (_page_l - 1) / 2 * _ps;
			var _pageSet = noone;
			
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
					draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_text);
					draw_text_add(_px, _py, KEYBOARD_NUMBER ?? "");
					continue;
				}
				
				var _hv = pHOVER && point_in_rectangle(mx, my, _px - _ps/2 + 1, _py - _ps/2, _px + _ps/2 - 1, _py + _ps/2);
				var  cc = COLORS._main_text_sub;
				var _pc = _page == page;
				
				if(_page == -1) {
					if(_hv) {
						cc = COLORS._main_text;
						if(mouse_lpress(pFOCUS)) {
							page_goto = i;
							KEYBOARD_RESET
						}
					}
					
					draw_set_text(f_p2b, fa_center, fa_center, cc);
					draw_text_add(_px, _py, "...");
					continue;
				} 
				
				if(_pc) cc = COLORS._main_accent;
				if(_hv && !_pc) {
					cc = COLORS._main_text;
					
					if(mouse_lpress(pFOCUS))
						_pageSet = _page;
				}
				
				draw_set_text(f_p2b, fa_center, fa_center, cc);
				draw_text_add(_px, _py, _page + 1);
				
			}
			
			if(pFOCUS) {
				if(key_press(vk_left))  _pageSet = max(page - 1, 1);
				if(key_press(vk_right)) _pageSet = min(page + 1, pageTotal);
			}
			
			if(_pageSet != noone) setPage(_pageSet);
				
			if(page > 0) {
				var _itemCounts = array_length(displayFiles);
				var _str = $"{_itemCounts} items";
				
				draw_set_text(f_p2, fa_right, fa_center, COLORS._main_text_sub);
				draw_text_add(px + pw - ui(8), _py, _str);
			}
		#endregion
	}
	
}