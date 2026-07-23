function Panel_Default_Editor(_node) : PanelContent() constructor {
	title = __txt("Default Editor");
	w     = ui(320);
	h     = ui(400);
	
	node     = _node;
	nodeType = instanceof(node);
	defPath  = $"{DIRECTORY}Presets/{nodeType}/_values.json";
	fileEdit = 0;
	
	defData  = undefined;
	
	sc_defedit = new scrollPane(0, 0, function(_y, _m) {
		draw_clear(COLORS.panel_bg_clear, 0);
		
		var hg = ui(24);
		var _w = sc_defedit.surface_w;
		var _h = 0;
		
		var _focus = sc_defedit.active;
		var _hover = sc_defedit.hover;
		
		for( var i = 0, n = array_length(node.inputs); i < n; i++ ) {
			if(i) {
				draw_set_color_alpha(COLORS._main_icon, .25);
				draw_line(ui(4), _y, _w - ui(8), _y);
				draw_set_alpha(1);
			}
			
			var cy = _y + hg / 2;
			
			var _inp = node.inputs[i];
			var _nam = _inp.getName();
			var _inm = _inp.internalName;
			var _def = has(defData, _inm);
			
			var _tx = ui(0);
			
			var b = buttonInstant(THEME.button_hide, _tx, _y, hg, hg, _m, _hover, _focus, "", THEME.icon_default, 0, _def? COLORS._main_accent : COLORS._main_icon, .75 + _def * .25, .75);
			if(b == 2) {
				if(_def) _inp.clearDefault();
				else     _inp.setDefault();
				
				_def = !_def;
			}
			
			_tx += hg + ui(4);
			
			draw_set_text(f_p3, fa_left, fa_center, _def? COLORS._main_text : COLORS._main_text_sub);
			draw_text_add(_tx, cy, _nam);
			
			if(!has(defData, _inm)) {
				_y += hg;
				_h += hg;
				continue;
			}
			
			var _valDat = defData[$ _inm];
			var _vx = _w - ui(8);
			
			var _valUnt = _valDat[$ "unit"];
			draw_sprite_ui(THEME.unit_ref, _valUnt, _vx - hg / 2, cy, .75, .75, 0, COLORS._main_icon);
			
			_vx -= hg + ui(4);
			
			var _valCon = _valDat[$ "r"];
			if(is_array(_valCon)) {
				
			} else if(is_struct(_valCon)) {
				var _val = _valCon.d;
				
				draw_set_text(f_p3, fa_right, fa_center, COLORS._main_text);
				draw_text_add(_vx, cy, _val);
			}
			
			_y += hg;
			_h += hg;
		}
		
		return _h;
	});
	
	function checkFile() {
		if(!file_exists_empty(defPath)) {
			defData = undefined;
			return;
		}
		
		var _modi = file_get_modify_s(defPath);
		if(_modi == fileEdit) return;
	
		fileEdit = _modi;
		defData  = json_load_struct(defPath);
	}
	
	function drawContent(panel) {
		checkFile();
		
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var sp = padding - ui(8);
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2 - ui(28);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_defedit.verify(pw, ph);
		sc_defedit.setFocusHover(pFOCUS, pHOVER);
		sc_defedit.draw(px, py, mx - px, my - py);
		
		var ah = ui(24);
		var bx = sp;
		var by = h - ah - sp;
		var ww = w - sp * 2;
		
		var  bs = ui(32);
		
		if(file_exists_empty(defPath)) {
			var hov = pHOVER && point_in_rectangle(mx, my, bx, by, bx + bs, by + ah);
			var cc  = hov? CDEF.cyan : COLORS._main_icon;
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bs, ah, cc, .40 + hov * .10);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bs, ah, cc, .75 + hov * .25);
			draw_sprite_ui(THEME.path_open, 0, bx + bs/2, by + ah/2, .75, .75, 0, cc);
			
			if(hov) {
				TOOLTIP = __txt("Open Default File...");
				if(mouse_lpress(pFOCUS)) shellOpenExplorer(defPath);
			}
		} else {
			draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bs, ah, COLORS._main_icon, .40);
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon);
			draw_sprite_ui(THEME.path_open, 0, bx + bs/2, by + ah/2, .75, .75, 0, COLORS._main_icon);
		}
		
		bx += bs + ui(4);
		ww -= bs + ui(4);
		var _bx = w - sp - bs;
		
		if(file_exists_empty(defPath)) {
			var hov = pHOVER && point_in_rectangle(mx, my, _bx, by, _bx + bs, by + ah);
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, by, bs, ah, COLORS._main_value_negative, .40 + hov * .10);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, by, bs, ah, COLORS._main_value_negative, .75 + hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, hov? COLORS._main_value_positive : COLORS._main_icon);
			draw_sprite_ui(THEME.icon_delete, 0, _bx + bs/2, by + ah/2, 1, 1, 0, COLORS._main_value_negative);
			
			if(hov) {
				TOOLTIP = __txt("Clear all Default Value(s)");
				if(mouse_lpress(pFOCUS)) {
					file_delete_safe(defPath);
					PRESETS_MAP[$ nodeType] = {}
				}
			}
			
		} else {
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, by, bs, ah, COLORS._main_icon, .40);
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon);
			draw_sprite_ui(THEME.icon_delete, 0, _bx + bs/2, by + ah/2, 1, 1, 0, COLORS._main_icon);
		}
		
		ww -= bs + ui(4);
		
		// var hov = pHOVER && point_in_rectangle(mx, my, bx, by, bx + ww, by + ah);
		// draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, ww, ah, hov? COLORS._main_value_positive : COLORS._main_icon, .3 + hov * .10);
		// draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, ww, ah, hov? COLORS._main_value_positive : COLORS._main_icon, .6 + hov * .25);
		// draw_set_text(f_p2, fa_center, fa_center, hov? COLORS._main_value_positive : COLORS._main_icon_light);
		// draw_text_add(bx + ww / 2, by + ah / 2, __txt("New preset"));
		
		// if(mouse_lpress(pFOCUS && hov)) { 
			
		// }
		
	}
}