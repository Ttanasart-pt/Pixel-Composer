function Panel_GM_Explore(_gmBinder) : PanelContent() constructor {
    gmBinder = _gmBinder;
    title    = $"{gmBinder.projectName}.yyc";
    auto_pin = true;
    
	w = ui(400);
	h = ui(480);
	
	GM_Explore_draw_init();
	
	search_string     = "";
	keyboard_lastchar = "";
	KEYBOARD_RESET
	keyboard_lastkey  = -1;
	
	search_res = [];
	tb_search  = textBox_Text(function(str) /*=>*/ { search_string = string(str); searchResource(); })
					.setAutoupdate().setAlign(fa_left).setBoxColor(COLORS._main_icon_light)
					.activate();
	
	function searchResource() {
		search_res = [];
	}
	
	sc_content = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		return GM_Explore_draw(gmBinder, 0, _y, sc_content.surface_w, sc_content.surface_h, _m, sc_content.hover, sc_content.active);
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		var _tw = pw - ui(24 + 4);
		var _th = ui(24);
		tb_search.setFocusHover(pFOCUS, pHOVER);
		tb_search.draw(px, py, _tw, _th, search_string, [mx, my]);
		if(search_string == "") tb_search.sprite_index = 1;
		
		var _bs = _th;
		var _bx = px + pw - _bs;
		var _by = py;
		
		if(gmBinder.refreshing) {
			draw_sprite_ui_uniform(THEME.refresh_16, 0, _bx + _bs / 2, _by + _bs / 2, 1, COLORS._main_value_positive, 1, current_time / 90);
			
		} else if(buttonInstant(THEME.button_hide_fill, _bx, _by, _bs, _bs, [ mx, my ], pHOVER, pFOCUS, "", THEME.refresh_16) == 2)
			gmBinder.refreshResources();
		
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.verify(pw, ph - ui(40));
		sc_content.drawOffset(px, py + ui(40), mx, my);
		
	}
}

function GM_Explore_draw_init() {
	grid_size    = ui(48);
	grid_size_to = grid_size;
}

function GM_Explore_draw(gmBinder, _x, _y, _w, _h, _m, _hover, _focus) {
	var _res = gmBinder.resources;
	var _ww  = _w;
	var _yy  = _y;
	var _hh  = 0;
	var lbh  = ui(26);
	
	var _sciss = gpu_get_scissor();
	var _call  = 0;
	
	for( var i = 0, n = array_length(_res); i < n; i++ ) {
	    var _name = _res[i].name;
	    var _data = _res[i].data;
	    var _panw = _ww - ui(32);
	    var _hov  = _hover && point_in_rectangle(_m[0], _m[1], 0, _yy, _panw, _yy + lbh);
	    
	    draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, _yy, _panw, lbh, COLORS.panel_inspector_group_bg, 1);
	    if(_hov) {
            draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, _yy, _panw, lbh, COLORS.panel_inspector_group_hover, 1);
            if(DOUBLE_CLICK) _call = _res[i].closed? -1 : 1;
            else if(mouse_press(mb_left, _focus)) _res[i].closed = !_res[i].closed;
        }
        
        draw_sprite_ui(THEME.arrow, _res[i].closed? 0 : 3, ui(16), _yy + lbh / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);    
        
        draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text_inner);
        draw_text_add(ui(32), _yy + lbh / 2, $"{_name} ({array_length(_data)})");
        
	    var _rx = _panw + ui(4);
	    var _ry = _yy;
	    var _rw = ui(32 - 4);
	    var _rh = lbh;
	    draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _rx, _ry, _rw, _rh, COLORS.panel_inspector_group_bg, 1);
	    if(buttonInstant(THEME.button_hide_fill, _rx + ui(2), _ry + ui(2), _rw - ui(4), _rh - ui(4), _m, _hover, _focus, "", 
	    	THEME.view_mode, _res[i].view, COLORS._main_icon, 1, .7) == 2)
	    	_res[i].view = !_res[i].view;
	    
        _yy += lbh + ui(6);
        _hh += lbh + ui(6);
        
        if(_res[i].closed) continue;
        
        var _grid  = !_res[i].view;
        
		var _padx  = ui(8);
		var _lnh   = line_get_height(f_p3, 8);
		var _col   = _grid? max(1, floor((_ww - _padx) / (grid_size * 1.5 + _padx))) : 1;
		    
		var grid_w = (_ww - _padx) / _col;
		var grid_h = _grid? grid_size + _lnh : grid_size * .5;
        var _xx    = _padx;
        
        for( var j = 0, m = array_length(_data); j < m; j++ ) {
            var _cc = j % _col;
            var _rr = floor(j / _col);
            
            var _asx = _xx + _cc * grid_w;
            var _asy = _yy + _rr * grid_h;
            
            var _draw = _asy + grid_h > 0 && _asy - grid_h < _h;
            if(!_draw) continue;
            
            var _x0 = _asx;
            var _x1 = _x0 + grid_w;
            var _xc = _x0 + grid_w / 2;
            var _y0 = _asy;
            var _y1 = _y0 + grid_h;
            
            var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x0, _y0, _x1, _y1 - 1);
            
            var _ass = _data[j];
            var _raw = _ass.raw;
            var _thm = _ass.getThumbnail();
            var _nod = struct_try_get(gmBinder.nodeMap, _ass.key, noone);
            
            if(_thm == noone) {
	            switch(_ass.type) {
	            	case "GMSprite"  : _thm = s_gmsprite; break;
	            	case "GMObject"  : _thm = s_gmobject; break;
	            	case "GMTileSet" : _thm = s_gmtile;   break;
	            	case "GMRoom"    : _thm = s_gmroom;   break;
	            }
	            
	            gpu_set_texfilter(true);
            }
            
            if(sprite_exists(_thm)) {
            	var _sw = sprite_get_width(_thm);
            	var _sh = sprite_get_height(_thm);
            	var _ox = sprite_get_xoffset(_thm);
            	var _oy = sprite_get_yoffset(_thm);
            	
            	var _ss = _grid? min(grid_w - ui(4), grid_size - ui(4)) / max(_sw, _sh) : (grid_h - ui(6)) / max(_sw, _sh);
            	var _sx = _grid? _xc                          : _x0 + grid_h / 2;
            	var _sy = _grid? _y0 + ui(2) + grid_size / 2  : _y0 + grid_h / 2;
            	
            	_sx = _sx - _sw / 2 * _ss + _ox * _ss
            	_sy = _sy - _sh / 2 * _ss + _oy * _ss
            	
            	draw_sprite_ext(_thm, 0, _sx, _sy, _ss, _ss);
            }
            
            gpu_set_texfilter(false);
            var _tw = string_width(_raw.name);
            
            if(_grid) {
	            draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text);
	            var _tx = max(_xc - _tw / 2, _x0 + ui(2));
	            var _ty = _y0 + grid_size + ui(2);
	            
            } else {
            	draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text);
	            var _tx = _x0 + grid_h + ui(4);
	            var _ty = _y0 + grid_h / 2;
            }
            
            gpu_set_scissor(_x0 + ui(2), _y0, grid_w - ui(4), grid_h);
            draw_text_add(_tx, _ty, _raw.name);
            gpu_set_scissor(_sciss);
            
            if(_hov) {
                draw_sprite_stretched_ext(THEME.ui_panel, 1, _x0, _y0, grid_w, grid_h, COLORS._main_icon);
                if(_thm && _ass.type != "GMRoom") TOOLTIP = [ _thm, "sprite" ];
                
                if(_nod == noone) {
                	if(mouse_press(mb_left, _focus)) 
                		DRAGGING = { type : _ass.type, data : _ass };
                } else 
                	TOOLTIP = "Assets is already binded to a node.";
            }
        }
        
        var _rrow = ceil(array_length(_data) / _col);
        _yy += grid_h * _rrow + ui(6);
        _hh += grid_h * _rrow + ui(6);
	}
	
	if(_call != 0) {
		for( var i = 0, n = array_length(_res); i < n; i++ )
			_res[i].closed = _call == 1? false : true;
	}
	
	if(_hover && key_mod_press(CTRL) && point_in_rectangle(_m[0], _m[1], 0, 0, _w, _h) && MOUSE_WHEEL != 0)
		grid_size_to = clamp(grid_size_to + ui(4) * MOUSE_WHEEL, ui(32), ui(160));
	grid_size = lerp_float(grid_size, grid_size_to, 5);
	
	return _hh;
}