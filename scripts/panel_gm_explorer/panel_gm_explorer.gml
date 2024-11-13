function Panel_GM_Explore(gmBinder) : PanelContent() constructor {
    self.gmBinder = gmBinder;
    title = $"{gmBinder.projectName}.yyc";
    
    auto_pin = true;
    padding  = 8;
	w = ui(400);
	h = ui(480);
	
	grid_size    = ui(64);
	grid_size_to = grid_size;
	
	search_string     = "";
	keyboard_lastchar = "";
	KEYBOARD_STRING   = "";
	keyboard_lastkey  = -1;
	
	search_res = [];
	tb_search  = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_string = string(str); searchResource(); });
	tb_search.align			= fa_left;
	tb_search.auto_update	= true;
	tb_search.boxColor		= COLORS._main_icon_light;
	WIDGET_CURRENT			= tb_search;
	
	function searchResource() {
		search_res = [];
		
	}
	
	function onResize() {
		sc_content.resize(w - ui(padding + padding), h - ui(padding + padding + 40));
	}
	
	sc_content = new scrollPane(w - ui(padding + padding), h - ui(padding + padding + 40), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _res = gmBinder.resources;
		var _ww  = sc_content.surface_w;
		var _yy  = _y;
		var _hh  = 0;
		var lbh  = ui(26);
		
		var _hover = sc_content.hover;
		var _focus = sc_content.active;
		
		var _ths = grid_size;
		var _pad = ui(8);
		var _lnh = line_get_height(f_p3, 8);
		var _col = floor((_ww - _pad) / (_ths + _pad));
		
		for( var i = 0, n = array_length(_res); i < n; i++ ) {
		    var _name = _res[i].name;
		    
		    if(_hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _ww, _yy + lbh)) {
                draw_sprite_stretched_ext(THEME.s_box_r5_clr, 0, 0, _yy, _ww, lbh, COLORS.panel_inspector_group_hover, 1);
                if(mouse_press(mb_left, _focus)) _res[i].closed = !_res[i].closed;
                
            } else
                draw_sprite_stretched_ext(THEME.s_box_r5_clr, 0, 0, _yy, _ww, lbh, COLORS.panel_inspector_group_bg, 1);
            
            
            draw_sprite_ui(THEME.arrow, _res[i].closed? 0 : 3, ui(16), _yy + lbh / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);    
            
            draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text_inner);
            draw_text_add(ui(32), _yy + lbh / 2, _name);
            
            _yy += lbh + ui(6);
            _hh += lbh + ui(6);
            
            if(_res[i].closed) continue;
            
            var _data = _res[i].data;
            var _xx   = _pad;
            
            for( var j = 0, m = array_length(_data); j < m; j++ ) {
                var _cc = j % _col;
                var _rr = floor(j / _col);
                
                var _asx = _xx + _cc * (_ths + _pad);
                var _asy = _yy + _rr * (_ths + _pad + _lnh);
                
                var _ass = _data[j];
                var _raw = _ass.raw;
                var _thm = noone;
                
                if(_ass.type == "GMSprite") _thm = _ass.thumbnail;
                else if(_ass.type == "GMTileSet") {
                    var _spm = struct_try_get(gmBinder.resourcesMap, _ass.sprite, noone);
                    _thm = _spm == noone? noone : _spm.thumbnail;
                }
                
                if(sprite_exists(_thm)) draw_sprite_bbox_uniform(_thm, 0, BBOX().fromWH(_asx + ui(2), _asy + ui(2), _ths - ui(4), _ths - ui(4)));
                
                draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text);
                draw_text_add(_asx + _ths / 2, _asy + _ths + ui(4), _raw.name);
                
                if(_hover && point_in_rectangle(_m[0], _m[1], _asx, _asy, _asx + _ths, _asy + _ths)) {
                    draw_sprite_stretched_ext(THEME.ui_panel, 1, _asx, _asy, _ths, _ths, COLORS._main_icon);
                    if(_thm) TOOLTIP = [ _thm, "sprite" ];
                    
                    if(mouse_press(mb_left, _focus)) {
                        DRAGGING = { type : _ass.type, data : _ass };
                    }
                }
            }
            
            var _rrow = ceil(array_length(_data) / _col);
            _yy += (_ths + _pad + _lnh) * _rrow + ui(6);
            _hh += (_ths + _pad + _lnh) * _rrow + ui(6);
            
		}
		
		if(pHOVER && key_mod_press(CTRL) && point_in_rectangle(_m[0], _m[1], 0, 0, sc_content.surface_w, sc_content.surface_h)) {
			if(mouse_wheel_down()) grid_size_to = clamp(grid_size_to - ui(4), ui(32), ui(160));
			if(mouse_wheel_up())   grid_size_to = clamp(grid_size_to + ui(4), ui(32), ui(160));
		}
		grid_size = lerp_float(grid_size, grid_size_to, 5);
		
		return _hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		var _tw = pw - ui(24 + 4);
		var _th = ui(24);
		tb_search.setFocusHover(pFOCUS, pHOVER);
		tb_search.draw(px, py, _tw, _th, search_string, [mx, my]);
		if(search_string == "") tb_search.sprite_index = 1;
		
		var _bs = _th;
		var _bx = px + pw - _bs;
		var _by = py;
		
		if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mx, my ], pFOCUS, pHOVER, "", THEME.refresh_16) == 2)
			gmBinder.refreshResources();
		
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.draw(px, py + ui(40), mx - px, my - (py + ui(40)));
		
	}
}