function Panel_Locale_Manager() : PanelContent() constructor {
	title = "Locale Manager";
	w = ui(800);
	h = ui(480);
	auto_pin = true;
	padding  = ui(8);
	
	#region all locales
		locals = [];
		var f = file_find_first(DIRECTORY + "Locale/*", fa_directory);
		while(f != "") {
			if(directory_exists(DIRECTORY + "Locale/" + f)) { if(f != "_extend") array_push(locals, f); }
			f = file_find_next();
		}
		file_find_close();
		
		sc_local_selector = new scrollBox(locals, function(_idx) /*=>*/ { 
			setLocal(array_safe_get(locals, _idx, "en"));
		}).setUpdateHover(false);
		
	#endregion
	
	#region base local
		var _word   = json_load_struct($"{DIRECTORY}Locale/en/words.json");
		var _ui     = json_load_struct($"{DIRECTORY}Locale/en/UI.json");
		base_text  = struct_append(_word, _ui);
		
		base_node   = json_load_struct($"{DIRECTORY}Locale/en/nodes.json");
		base_config = json_load_struct($"{DIRECTORY}Locale/en/config.json");
		base_notes  = directory_listdir($"{DIRECTORY}Locale/en/notes", fa_none);
		
		base_text_key = struct_get_names(base_text);
		base_node_key = struct_get_names(base_node);
		
		text_total = array_length(base_text_key);
		node_total = 0;
		
		for( var i = 0, n = array_length(base_node_key); i < n; i++ ) {
			var _node = base_node[$ base_node_key[i]];
			
			node_total++;
			node_total += array_length(_node.inputs);
			node_total += array_length(_node.outputs);
		}
	#endregion
	
	#region current local
		pages = [ "config", "fonts", "words", "nodes", "notes" ];
		page  = 0;
		
		current_local    = undefined;
		current_index    = 0;
		current_progress = {
			words: 0, 
			nodes: 0, 
			notes: 0, 
		};
		
		current_fonts = [];
		fonts_data = undefined;
		
		static setLocal = function(_l) {
			if(current_local == _l) return;
			
			current_local = _l;
			current_index = array_find(locals, _l);
			page = 0;
			
			if(current_local == "en") {
				data_config = base_config;
				
				data_text   = base_text;
				data_node   = base_node;
				data_notes  = base_notes;
				
				current_fonts = [];
				fonts_data = undefined;
				return;
			}
			
			var dirr = $"{DIRECTORY}Locale/{_l}";
			
			var _word   = json_load_struct($"{dirr}/words.json");
			var _ui     = json_load_struct($"{dirr}/UI.json");
			data_text   = struct_append(_word, _ui);
			
			data_node     = json_load_struct($"{dirr}/nodes.json");
			data_config   = json_load_struct($"{dirr}/config.json");
			data_notes    = directory_listdir($"{dirr}/notes", fa_none);
			current_fonts = directory_listdir($"{dirr}/fonts", fa_none);
			
			data_text_key = struct_get_names(data_text);
			data_node_key = struct_get_names(data_node);
			
			for( var i = 0, n = array_length(current_fonts); i < n; i++ ) {
				var _font = current_fonts[i];
				if(filename_ext(_font) == ".json") {
					array_delete(current_fonts, i, 1);
					fonts_data = json_load_struct(_font);
					break;
				}
			}
			
			var _text_translated = 0;
			for( var i = 0, n = text_total; i < n; i++ ) {
				var _base_key = base_text_key[i];
				if(_base_key == "" || has(data_text, _base_key))
					_text_translated++;
			}
			
			var _node_translated = 0;
			for( var i = 0, n = array_length(base_node_key); i < n; i++ ) {
				var _node = base_node[$ base_node_key[i]];
				if(!has(data_node, base_node_key[i])) continue;
				
				var _data = data_node[$ base_node_key[i]];
				_node_translated++;
				_node_translated += array_length(_data.inputs);
				_node_translated += array_length(_data.outputs);
			}
			
			current_progress.words = _text_translated / text_total;
			current_progress.nodes = _node_translated / node_total;
			current_progress.notes = array_length(data_notes) / array_length(base_notes);
			
		} setLocal(PREFERENCES.local);
		
		static exportMissing = function(_file) {
			switch(_file) {
				case "words" :
					var _path = get_save_filename_compat("JSON|*.json", "words_missing.json");
					if(_path == "") return;
					
					var _missings = {};
					for( var i = 0, n = text_total; i < n; i++ ) {
						var _base_key = base_text_key[i];
						if(_base_key == "" || has(data_text, _base_key)) continue;
						
						_missings[$ _base_key] = base_text[$ _base_key];
					}
					
					json_save_struct(_path, _missings, true);
					break;
				
				case "nodes" :
					var _path = get_save_filename_compat("JSON|*.json", "nodes_missing.json");
					if(_path == "") return;
					
					var _missings = {};
					
					for( var i = 0, n = array_length(base_node_key); i < n; i++ ) {
						var _nkey = base_node_key[i];
						var _node = base_node[$ _nkey];
						var _tran = undefined;
						
						if(has(data_node, _nkey)) {
							var _binl = array_length(_node.inputs);
							var _botl = array_length(_node.outputs);
							
							var _data = data_node[$ _nkey];
							var _dinl = array_length(_data.inputs);
							var _dotl = array_length(_data.outputs);
							
							if(_dinl == _binl && _dotl == _botl) continue;
							
							_tran = {};
							if(_dinl < _binl) _tran.inputs  = array_clone(_node.inputs);
							if(_dotl < _botl) _tran.outputs = array_clone(_node.outputs);
							
						} else
							_tran = variable_clone(_node);
						
						if(_tran != undefined) _missings[$ _nkey] = _tran;
					}
					
					json_save_struct(_path, _missings, true);
					break;
				
			}
		}
		
		static importMissing = function(_file) {
			switch(_file) {
				case "words" :
					var _path = get_open_filename_compat("JSON|*.json", "words_missing.json");
					if(_path == "") return;
					
					var _str = json_load_struct(_path);
					struct_append(data_text, _str);
					
					var _data_path = $"{DIRECTORY}Locale/{current_local}/words.json";
					json_save_struct(_data_path, data_text, true);
					
					var _text_translated = 0;
					for( var i = 0, n = text_total; i < n; i++ ) {
						var _base_key = base_text_key[i];
						if(_base_key == "" || has(data_text, _base_key))
							_text_translated++;
					}
					current_progress.words = _text_translated / text_total;
					break;
				
				case "nodes" :
					var _path = get_open_filename_compat("JSON|*.json", "nodes_missing.json");
					if(_path == "") return;
					
					var _str = json_load_struct(_path);
					struct_append_nested(data_node, _str);
					
					var _data_path = $"{DIRECTORY}Locale/{current_local}/nodes.json";
					json_save_struct(_data_path, data_node, true);
					
					var _node_translated = 0;
					for( var i = 0, n = array_length(base_node_key); i < n; i++ ) {
						var _node = base_node[$ base_node_key[i]];
						if(!has(data_node, base_node_key[i])) continue;
						
						var _data = data_node[$ base_node_key[i]];
						_node_translated++;
						_node_translated += array_length(_data.inputs);
						_node_translated += array_length(_data.outputs);
					}
					
					current_progress.notes = _node_translated / node_total;
					break;
				
			}
		}
	#endregion
	
	static drawStruct = function(_base, _curr, _x, _y, _w, _h, _m, _hov, _foc) {
		var hh = 0;
		var hg = ui(20);
		var cx = _x + _w / 3;
		
		var _keys = struct_get_names(_base);
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var _key = _keys[i];
			if(_key == "") continue;
			
			var _hh   = hg;
			var _valB = _base == undefined? undefined : _base[$ _key];
			var _valC = _curr == undefined? undefined : _curr[$ _key];
			var _draw = _y > -hg - ui(8) && _y < _h + ui(8);
			var _miss = _curr != undefined && _valC == undefined;
			
			if(_draw) {
				draw_set_text(f_p3, fa_left, fa_top, _miss? COLORS._main_value_negative : COLORS._main_text_sub);
				draw_text(_x + ui(8), _y, _key);
			}
			
			if(_valC != undefined) {
				if(is_struct(_valC)) {
					var _sh = drawStruct(_valB, _valC, _x + ui(32), _y + hg, _w - ui(32), _h, _m, _hov, _foc);
					_hh += _sh + ui(4);
					
				} else if(_draw) {
					draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text);
					draw_text(cx, _y, _valC);
				}
			}
			
			if(i % 2) draw_sprite_stretched_ext(THEME.box_r2, 0, _x, _y, _w, _hh, COLORS._main_icon, .05);
			
			hh += _hh;
			_y += _hh;
		}
		
		return hh;
	}
	
	sc_content = new scrollPane(1, 1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var ww  = sc_content.surface_w;
		var hh  = sc_content.surface_h;
		var hov = sc_content.hover;
		var foc = sc_content.active;
		
		var _h = 0;
		var hg = ui(20);
		
		switch(pages[page]) {
			case "config" : file_current = data_config; file_base = base_config; break;
			case "words"  : file_current = data_text;   file_base = base_text;   break;
			case "nodes"  : file_current = data_node;   file_base = base_node;   break;
		}
		
		BLEND_ADD
		switch(pages[page]) {
			case "config" : case "words" : case "nodes" :
				_h  = drawStruct(file_base, file_current, 0, _y, ww, hh, _m, hov, foc);
				break;
				
			case "notes" : 
				for( var i = 0, n = array_length(base_notes); i < n; i++ ) {
					var _note = base_notes[i];
					var _fnam = filename_name(_note);
					var _tnam = $"{DIRECTORY}Locale/{current_local}/notes/{_fnam}";
					var _fhas = file_exists(_tnam);
					
					draw_set_text(f_p3, fa_left, fa_top, _fhas? COLORS._main_text_sub : COLORS._main_value_negative);
					draw_text(ui(8), _y, filename_name_only(_note));
				
					if(i % 2) draw_sprite_stretched_ext(THEME.box_r2, 0, 0, _y, ww, hg, COLORS._main_icon, .05);
					
					_y += hg;
					_h += hg;
				}
				break;
				
			case "fonts":
				var lw = ww / 3;
				
				var yy = 0;
				for( var i = 0, n = array_length(current_fonts); i < n; i++ ) {
					var _font = current_fonts[i];
					var _fnam = filename_name(_font);
					
					draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
					draw_text(ui(8), yy, _fnam);
					
					if(i % 2) draw_sprite_stretched_ext(THEME.box_r2, 0, 0, yy, lw - ui(8), hg, COLORS._main_icon, .05);
					
					yy += hg;
					_h += hg;
				}
				
				draw_sprite_stretched_ext(THEME.box_r2, 0, lw - ui(2), 0, ui(4), hh, CDEF.main_dkblack, .25);
				
				var yy = _y;
				if(fonts_data != undefined) {
					_h = drawStruct(fonts_data, fonts_data, lw + ui(8), yy, ww - lw - ui(8), hh, _m, hov, foc);
				}
				break;
		}
		BLEND_NORMAL
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var _pd = padding;
		var  m  = [ mx, my ];
		
		var dirr = $"{DIRECTORY}Locale/{current_local}";
		var _sidew = ui(160);
		
		var hh = line_get_height(f_p2, 4);
		var bx = _pd + _sidew - hh;
		var by = _pd;
		var bs = hh;
		var bt = __txt("Open in Explorer");
		if(buttonInstant_Pad(THEME.button_hide, bx, by, bs, bs, m, pHOVER, pFOCUS, bt, THEME.dPath_open) == 2)
			shellOpenExplorer(dirr);
		
		var x0 = _pd;
		var y0 = _pd;
		var ww = _sidew - hh - ui(4);
		
		sc_local_selector.setFocusHover(pFOCUS, pHOVER);
		sc_local_selector.drawParam(new widgetParam(x0, y0, ww, hh, current_index, {}, m, x, y).setFont(f_p2));
		
		var fx = _pd;
		var fy = y0 + hh + _pd;
		var fw = _sidew;
		var fh = ui(48);
		var bh = ui(24);
		
		for( var i = 0, n = array_length(pages); i < n; i++ ) {
			var _page = pages[i];
			
			switch(_page) {
				case "config" : 
				case "fonts"  : fh = ui(28); break;
				
				case "words"  : 
				case "nodes"  : 
				case "notes"  : fh = ui(48) + bh; break;
			}
			
			var hov = pHOVER && point_in_rectangle(mx, my, fx, fy, fx + fw, fy + fh);
			
			draw_sprite_stretched_ext(THEME.box_r2_clr, 0, fx, fy, fw, fh, COLORS._main_icon_light);
			
			if(hov && mouse_lpress(pFOCUS))
				page = i;
			
			draw_set_text(f_p2, fa_left, fa_bottom, COLORS._main_text);
			draw_text(fx + ui(8), fy + ui(24), _page);
			
			switch(_page) {
				case "words"  : 
				case "nodes"  : 
				case "notes"  : 
					var _prg = current_progress[$ _page] ?? 0;
					var _pw = fw - ui(16);
					var _ph = ui(8);
					
					var _px = fx + ui(8);
					var _py = fy + ui(40) - _ph;
					
					draw_sprite_stretched(THEME.progress_bar, 0, _px, _py, _pw, _ph);
					draw_sprite_stretched(THEME.progress_bar, 1, _px, _py, _pw * _prg, _ph);
					
					draw_set_text(f_p3, fa_right, fa_bottom, _prg >= 1? COLORS._main_value_positive : COLORS._main_text_sub);
					draw_text(fx + fw - ui(8), fy + ui(24), $"{_prg * 100}%");
					
					var bw = fw / 2;
					var bx = fx;
					var by = fy + ui(48);
					
					var bt = __txt("Export Missing Text");
					if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bw, bh, m, pHOVER, pFOCUS, bt, THEME.dFile_save) == 2) 
						exportMissing(_page);
					
					bx += bw + 1;
					var bt = __txt("Import Missing Text");
					if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bw, bh, m, pHOVER, pFOCUS, bt, THEME.dFile_load) == 2) 
						importMissing(_page);
					break;
			}
			
			if(page == i) 
			     draw_sprite_stretched_ext(THEME.box_r2, 1, fx, fy, fw, fh, COLORS._main_accent, 1);
			else draw_sprite_stretched_add(THEME.box_r2, 1, fx, fy, fw, fh, COLORS._main_icon,  .1 + hov * .2);
			
			fy += fh + ui(4);
		}
		
		var x0 = _pd + _sidew + ui(8);
		var y0 = _pd;
		var ww = w - _pd * 2 - _sidew - ui(8);
		var hh = h - _pd * 2;
		var cpd = ui(8);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, x0, y0, ww, hh);
		sc_content.verify(ww - cpd * 2, hh - cpd * 2);
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.drawOffset(x0 + cpd, y0 + cpd, mx, my);
	}
}