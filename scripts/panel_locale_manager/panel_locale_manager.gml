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
		current_index    = 0;
		current_progress = [0, 0, 0];
		
		file_lists   = [ "config.json", "words.json", "nodes.json" ];
		file_select  = "";
		file_current = undefined;
		file_base    = undefined;
		
		static setLocal = function(_l) {
			current_local = _l;
			current_index = array_find(locals, _l);
			
			if(current_local == "en") {
				data_text   = base_text;
				data_node   = base_node;
				data_config = base_config;
				
				setFile(file_lists[0]);
				return;
			}
			
			var dirr = $"{DIRECTORY}Locale/{_l}";
			
			var _word   = json_load_struct($"{dirr}/words.json");
			var _ui     = json_load_struct($"{dirr}/UI.json");
			data_text   = struct_append(_word, _ui);
			
			data_node   = json_load_struct($"{dirr}/nodes.json");
			data_config = json_load_struct($"{dirr}/config.json");
			
			data_text_key = struct_get_names(data_text);
			data_node_key = struct_get_names(data_node);
			
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
			
			current_progress[0] = 0;
			current_progress[1] = _text_translated / text_total;
			current_progress[2] = _node_translated / node_total;
			
			setFile(file_lists[0]);
			
		} setLocal(PREFERENCES.local);
		
		static setFile = function(_f) {
			file_select = _f;
			
			switch(_f) {
				case "config.json": file_current = data_config; file_base = base_config; break;
				case "words.json":  file_current = data_text;   file_base = base_text;   break;
				case "nodes.json":  file_current = data_node;   file_base = base_node;   break;
			}
		}
		
		static exportMissing = function(_file) {
			switch(_file) {
				case "words.json" :
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
				
				case "nodes.json" :
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
				case "words.json" :
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
					current_progress[1] = _text_translated / text_total;
					break;
				
				case "nodes.json" :
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
					
					current_progress[2] = _node_translated / node_total;
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
			var _valB = _base[$ _key];
			var _valC = _curr[$ _key];
			var _draw = _y > -hg - ui(8) && _y < _h + ui(8);
			
			if(_draw) {
				draw_set_text(f_p3, fa_left, fa_top, _valC == undefined? COLORS._main_value_negative : COLORS._main_text_sub);
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
		
		BLEND_ADD
		var _h  = drawStruct(file_base, file_current, 0, _y, ww, hh, _m, hov, foc);
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
		
		for( var i = 0, n = array_length(file_lists); i < n; i++ ) {
			var _file = file_lists[i];
			var _path = $"{dirr}/{_file}";
			
			var hov = pHOVER && point_in_rectangle(mx, my, fx, fy, fx + fw, fy + fh);
			var fh  = i? ui(48) + bh : ui(28);
			
			draw_sprite_stretched_ext(THEME.box_r2_clr, 0, fx, fy, fw, fh, COLORS._main_icon_light);
			
			if(hov && mouse_lpress(pFOCUS))
				setFile(_file);
			
			draw_set_text(f_p2, fa_left, fa_bottom, COLORS._main_text);
			draw_text(fx + ui(8), fy + ui(24), _file);
			
			if(i == 0) { 
				if(file_select == _file) 
				     draw_sprite_stretched_ext(THEME.box_r2, 1, fx, fy, fw, fh, COLORS._main_accent, 1);
				else draw_sprite_stretched_add(THEME.box_r2, 1, fx, fy, fw, fh, COLORS._main_icon,  .1 + hov * .2);
				fy += fh + ui(4); 
				continue; 
			}
			
			var _prg = current_progress[i];
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
				exportMissing(_file);
			
			bx += bw + 1;
			var bt = __txt("Import Missing Text");
			if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bw, bh, m, pHOVER, pFOCUS, bt, THEME.dFile_load) == 2) 
				importMissing(_file);
			
			if(file_select == _file) 
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