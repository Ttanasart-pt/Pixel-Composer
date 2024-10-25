function Node_Tile_Tileset(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
    name = "Tileset";
    
    renaming       = noone;
	rename_text    = "";
	tb_rename = new textBox(TEXTBOX_INPUT.text, function(_name) { 
		if(renaming == noone) return;
		renaming.name  = _name;
		renaming       = noone;
	});
	tb_rename.font = f_p2;
	tb_rename.hide = true;
	
    newInput( 0, nodeValue_Surface("Texture", self, noone));
    
    newInput( 1, nodeValue_Vec2("Tile size", self, [ 16, 16 ]));
    
	newOutput(0, nodeValue_Output("Tileset", self, VALUE_TYPE.tileset, self));
	
    #region ++++ tile selector ++++
	    tile_selector_surface = 0;
	    tile_selector_mask    = 0;
	    tile_selector_h       = ui(320);
	    
	    tile_selector_x    = 0;
	    tile_selector_y    = 0;
	    tile_selector_s    = 2;
	    tile_selector_s_to = 2;
	    
	    tile_dragging = false;
	    tile_drag_sx  = 0;
	    tile_drag_sy  = 0;
	    tile_drag_mx  = 0;
	    tile_drag_my  = 0;
	    
	    tile_selecting = false;
	    tile_select_ss = [ 0, 0 ];
	    
	    selecting_surface      = noone;
	    selecting_surface_tile = noone;
	    
	    autotile_selector_mask = 0;
	    
	    grid_draw = true;
	    brush     = new tiler_brush(self);
	    
	    tile_selector = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
	    	var _tileSet = getInputData(0);
	    	var _tileSiz = getInputData(1);
	    	
	    	var _pd  = ui(4);
	    	var _yy  = _y;
	    	var _tsh = tile_selector.fixHeight > 0? tile_selector.fixHeight - ui(24 + 4 + 48 + 8) : tile_selector_h;
    		var _h   = _tsh;
	    	
			var bx = _x;
			var by = _yy;
			var bs = ui(24);
			
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "Clear selection", THEME.canvas_tools_selection_rectangle, 0, COLORS._main_icon_light) == 2) {
				brush.brush_indices = [[]];
    			brush.brush_width   = 0;
				brush.brush_height  = 0;
			}
			
			bx = _x + _w - bs;
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "Zoom to fit", THEME.path_tools_transform, 0, COLORS._main_icon_light) == 2) {
			    if(is_surface(_tileSet)) {
			        var _tdim = surface_get_dimension(_tileSet);
    				var _sw   = _w - _pd * 2;
    	    	    var _sh   = _tsh - _pd * 2;
    	    	    
    	    	    var _ss = min(_sw / (_tdim[0] + 16), _sh / (_tdim[1] + 16));
    	    	    tile_selector_s    = _ss;
    	    	    tile_selector_s_to = _ss;
    	    	    
    	    	    tile_selector_x = _w / 2              - _tdim[0] * _ss / 2;
                    tile_selector_y = _tsh / 2 - _tdim[1] * _ss / 2;
			    }
			}
			
			_h  += bs + ui(4);
			_yy += bs + ui(4);
			
	    	var _sx = _x + _pd;
	    	var _sy = _yy + _pd;
	    	var _sw = _w - _pd * 2;
	    	var _sh = _tsh - _pd * 2;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, _tsh, COLORS.node_composite_bg_blend, 1);
	    	tile_selector_surface  = surface_verify(tile_selector_surface,  _sw, _sh);
	    	tile_selector_mask     = surface_verify(tile_selector_mask,     _sw, _sh);
	    	autotile_selector_mask = surface_verify(autotile_selector_mask, _sw, _sh);
	    	
	    	if(!is_surface(_tileSet)) return _h;
	    	var _tdim    = surface_get_dimension(_tileSet);
	    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
	    	
	    	var _tileSel_w = _tileSiz[0] * tile_selector_s;
	    	var _tileSel_h = _tileSiz[1] * tile_selector_s;
	    	
	    	var _msx = _m[0] - _sx - tile_selector_x;
	    	var _msy = _m[1] - _sy - tile_selector_y;
	    	
	    	var _mtx = floor(_msx / tile_selector_s / _tileSiz[0]);
	    	var _mty = floor(_msy / tile_selector_s / _tileSiz[1]);
	    	var _mid = _mtx >= 0 && _mtx < _tileAmo[0] && _mty >= 0 && _mty < _tileAmo[1]? _mty * _tileAmo[0] + _mtx : noone;
	    	
	    	var _tileHov_x = tile_selector_x + _mtx * _tileSiz[0] * tile_selector_s;
	    	var _tileHov_y = tile_selector_y + _mty * _tileSiz[1] * tile_selector_s;
	    	
	    	var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _tsh);
	    	
	    	#region surface_set_target(tile_selector_surface); 
	    	surface_set_target(tile_selector_surface); 
	    		draw_clear(colorMultiply(COLORS.panel_bg_clear, COLORS.node_composite_bg_blend));
	    		draw_sprite_tiled_ext(s_transparent, 0, tile_selector_x, tile_selector_y, tile_selector_s, tile_selector_s, colorMultiply(COLORS.panel_preview_transparent, COLORS.node_composite_bg_blend), 1);
	    		
	    		draw_surface_ext(_tileSet, tile_selector_x, tile_selector_y, tile_selector_s, tile_selector_s, 0, c_white, 1);
	    		
	    		if(grid_draw) {
	    			var _gw = _tileSiz[0] * tile_selector_s;
			        var _gh = _tileSiz[1] * tile_selector_s;
			        
			        var gw = _tdim[0] / _tileSiz[0];
			        var gh = _tdim[1] / _tileSiz[1];
			    	
			        var cx = tile_selector_x;
			        var cy = tile_selector_y;
			    
			        draw_set_color(PROJECT.previewGrid.color);
			        draw_set_alpha(PROJECT.previewGrid.opacity);
			        
			        for( var i = 1; i < gw; i++ ) {
			            var _lxx = cx + i * _gw;
			            draw_line(_lxx, cy, _lxx, cy + _tdim[1] * tile_selector_s);
			        }
			    
			        for( var i = 1; i < gh; i++ ) {
			            var _lyy = cy + i * _gh;
			            draw_line(cx, _lyy, cx + _tdim[0] * tile_selector_s, _lyy);
			        }
			        
			        draw_set_alpha(1);
	    		}
	    		
	    		draw_set_color(COLORS.panel_preview_surface_outline);
            	draw_rectangle(tile_selector_x, tile_selector_y, tile_selector_x + _tdim[0] * tile_selector_s - 1, tile_selector_y + _tdim[1] * tile_selector_s - 1, true);
	    		
	    		if(_hov && _mid > noone) {
		    		
		    		draw_set_color(c_white);
		    		draw_rectangle_width(_tileHov_x - 1, _tileHov_y - 1, _tileHov_x + _tileSel_w, _tileHov_y + _tileSel_h, 1);
		    		
		    		draw_set_color(c_black);
		    		draw_rectangle_width(_tileHov_x, _tileHov_y, _tileHov_x + _tileSel_w - 1, _tileHov_y + _tileSel_h - 1, 1);
		    		
	    			if(mouse_press(mb_left, _focus)) {
		    			if(autotile_subtile_selecting == noone) {
			    			autotile_selecting = noone;
			    			animated_selecting = noone;
			    			
		    				tile_selecting = true;
		    				tile_select_ss = [ _mtx, _mty ];
		    				
		    			} else {
		    				autotiles[autotile_selecting].index[autotile_subtile_selecting] = _mid;
		    				autotile_subtile_selecting++;
		    				if(autotile_subtile_selecting >= array_length(autotiles[autotile_selecting].index))
		    					autotile_subtile_selecting = noone;
		    			}
		    			
		    			palette_using = false;
	    			}
	    		}
	    	surface_reset_target();
	    	#endregion
	    	
	    	#region surface_set_target(tile_selector_mask);
	    	surface_set_target(tile_selector_mask);
	    		DRAW_CLEAR
	    		draw_set_color(c_white);
	    		
	    		for( var i = 0, n = array_length(brush.brush_indices);    i < n; i++ ) 
	    		for( var j = 0, m = array_length(brush.brush_indices[i]); j < m; j++ ) {
	    			var _bindex      = floor(brush.brush_indices[i][j][0]);
	    			
			    	var _tileSel_row = floor(_bindex / _tileAmo[0]);
			    	var _tileSel_col = safe_mod(_bindex, _tileAmo[0]);
			    	
		    		var _tileSel_x   = tile_selector_x + _tileSel_col * _tileSiz[0] * tile_selector_s;
		    		var _tileSel_y   = tile_selector_y + _tileSel_row * _tileSiz[1] * tile_selector_s;
		    		
		    		draw_rectangle(_tileSel_x, _tileSel_y, _tileSel_x + _tileSel_w, _tileSel_y + _tileSel_h, false);
	    		}
	    	surface_reset_target();
	    	#endregion
	    	
    		if(tile_selecting) { // tile selection
    			var _ts_sx = clamp(min(tile_select_ss[0], _mtx), 0, _tileAmo[0] - 1);
    			var _ts_sy = clamp(min(tile_select_ss[1], _mty), 0, _tileAmo[1] - 1);
    			var _ts_ex = clamp(max(tile_select_ss[0], _mtx), 0, _tileAmo[0] - 1);
    			var _ts_ey = clamp(max(tile_select_ss[1], _mty), 0, _tileAmo[1] - 1);
    			
    			brush.brush_indices = [];
    			brush.brush_width   = _ts_ex - _ts_sx + 1;
				brush.brush_height  = _ts_ey - _ts_sy + 1;
    			var _ind = 0;
    			
    			for( var i = _ts_sy; i <= _ts_ey; i++ ) 
    			for( var j = _ts_sx; j <= _ts_ex; j++ )
    				brush.brush_indices[i - _ts_sy][j - _ts_sx] = [ i * _tileAmo[0] + j, 0 ];
    			
    			if(mouse_release(mb_left))
	    			tile_selecting = false;
    		}
	    	
	    	#region pan zoom 
		    	if(tile_dragging) {
		    		var _tdx = _m[0] - tile_drag_mx;
		    		var _tdy = _m[1] - tile_drag_my;
		    		
		    		tile_selector_x = tile_drag_sx + _tdx;
				    tile_selector_y = tile_drag_sy + _tdy;
				    
		    		if(mouse_release(mb_middle))
		    			tile_dragging = false;
		    	}
		    	
		    	if(_hov) {
		    		if(mouse_press(mb_middle, _focus)) {
			    		tile_dragging = true;
			    		tile_drag_sx  = tile_selector_x;
					    tile_drag_sy  = tile_selector_y;
					    tile_drag_mx  = _m[0];
					    tile_drag_my  = _m[1];
		    		}
		    		
		    		var _s = tile_selector_s;
		    		if(key_mod_press(CTRL) || tile_selector.popupPanel != noone) {
			    		if(mouse_wheel_up())   { tile_selector_s_to = clamp(tile_selector_s_to * 1.2, 0.5, 4); }
			    		if(mouse_wheel_down()) { tile_selector_s_to = clamp(tile_selector_s_to / 1.2, 0.5, 4); }
		    		}
		    		tile_selector_s = lerp_float(tile_selector_s, tile_selector_s_to, 2);
		    		
		    		if(_s != tile_selector_s) {
		    			var _ds  = tile_selector_s - _s;
		    			
		    			tile_selector_x -= _msx * _ds / _s;
		    			tile_selector_y -= _msy * _ds / _s;
		    		}
		    	}
		    	
		    	var _tdim_ws = _tdim[0] * tile_selector_s;
		    	var _tdim_hs = _tdim[1] * tile_selector_s;
		    	var _minx = -(_tdim_ws - _w) - 32;
		    	var _miny = -(_tdim_hs - _tsh) - 32;
		    	var _maxx = 32;
		    	var _maxy = 32;
		    	if(_minx > _maxx) { _minx = (_minx + _maxx) / 2; _maxx = _minx; }
		    	if(_miny > _maxy) { _miny = (_miny + _maxy) / 2; _maxy = _miny; }
		    	
		    	tile_selector_x = clamp(tile_selector_x, _minx, _maxx);
			    tile_selector_y = clamp(tile_selector_y, _miny, _maxy);
		    #endregion
		    	
	    	draw_surface(tile_selector_surface, _sx, _sy);
	    	
			shader_set(sh_brush_outline);
				var _brush_tiles = brush.brush_width * brush.brush_height;
				var _cc = c_white;
				if(_brush_tiles == 9 || _brush_tiles == 15 || _brush_tiles == 48 || _brush_tiles == 55) _cc = COLORS._main_value_positive;
				
				shader_set_f("dimension", _sw, _sh);
				draw_surface_ext(tile_selector_mask, _sx, _sy, 1, 1, 0, _cc, 1);
			shader_reset();
			
			if(autotile_selecting != noone) { // autotile
				var _att = autotiles[autotile_selecting];
				
		    	surface_set_target(autotile_selector_mask);
		    		DRAW_CLEAR
		    		
		    		draw_set_color(c_white);
		    		for( var j = 0, m = array_length(_att.index); j < m; j++ ) {
		    			var _bindex      = _att.index[j];
				    	var _tileSel_row = floor(_bindex / _tileAmo[0]);
				    	var _tileSel_col = safe_mod(_bindex, _tileAmo[0]);
			    		var _tileSel_x   = tile_selector_x + _tileSel_col * _tileSiz[0] * tile_selector_s;
			    		var _tileSel_y   = tile_selector_y + _tileSel_row * _tileSiz[1] * tile_selector_s;
			    		draw_rectangle(_tileSel_x, _tileSel_y, _tileSel_x + _tileSel_w, _tileSel_y + _tileSel_h, false);
		    		}
		    	surface_reset_target();
		    	
				shader_set(sh_brush_outline);
					shader_set_f("dimension", _sw, _sh);
					draw_surface_ext(autotile_selector_mask, _sx, _sy, 1, 1, 0, COLORS._main_accent, 1);
				shader_reset();
			}
			
			#region varients
				var _bw = 1;
				var _bh = 1;
				var _sel_sw = _tileSiz[0];
				var _sel_sh = _tileSiz[1];
				
				selecting_surface      = surface_verify(selecting_surface, _bw, _bh, surface_rgba16float);
		    	selecting_surface_tile = surface_verify(selecting_surface_tile, _sel_sw, _sel_sh);
		    	
				var _ty = _yy + _tsh + ui(8);
				var _th = ui(48);
				_h += ui(8) + _th;
				
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _ty, _w, _th, COLORS.node_composite_bg_blend, 1);
					
				if(brush.brush_width * brush.brush_height != 1) 
					return _h;
			
				var _bb = brush.brush_indices[0][0];
				var _sx = _x + ui(8);
				var _variences = [ 0, 1, 2, 3, 8, 16 ];
				
				for( var v = 0, p = array_length(_variences); v < p; v++ ) {
					var _var = _variences[v];
					
			    	surface_set_shader(selecting_surface, sh_draw_tile_brush, true, BLEND.over);
			    		shader_set_f("index",   _bb[0]);
		    			shader_set_f("varient", _var);
		    			draw_point(0, 0);
			    	surface_reset_shader();
			    	    	
				    var _tileSetDim = surface_get_dimension(_tileSet);
				    
				    surface_set_shader(selecting_surface_tile, sh_draw_tile_map, true, BLEND.over);
				        shader_set_2("dimension", [ _sel_sw, _sel_sh ]);
				        
				        shader_set_surface("indexTexture", selecting_surface);
				        shader_set_2("indexTextureDim", surface_get_dimension(selecting_surface));
				        
						shader_submit();
						
				        draw_empty();
				    surface_reset_shader();
		    		
		    		var _sy =  _ty + ui(8);
		    		var _ss = (_th - ui(16)) / _sel_sh;
		    		var _sw = _ss * _sel_sw;
		    		var _sh = _ss * _sel_sh;
		    		
		    		var _shov = _hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _sw, _sy + _sh);
		    		var _aa   = _bb[1] == _var? 1 : 0.5 + 0.5 * _shov;
		    		
		    		draw_surface_ext(selecting_surface_tile, _sx, _sy, _ss, _ss, 0, c_white, _aa);
		    		
		    		if(_bb[1] == _var) {
			    		draw_set_color(COLORS._main_accent);
			    		draw_rectangle(_sx, _sy, _sx + _sw, _sy + _sh, true);
		    		}
		    		
		    		if(_shov && mouse_press(mb_left, _focus))
		    			_bb[1] = _var;
		    		
					_sx += _sw + ui(8);
				}
	    	#endregion
	    	
	    	return _h;
	    });
    #endregion
    
    #region ++++ auto tile ++++
    	autotiles = [];
		
		autotile_selecting  = noone;
		autotile_selector_h = 0;
		
		autotile_subtile_selecting = noone;
		
    	autotile_selector = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
	    	var _yy = _y;
	    	var _h  = 0;
	    	
	    	var _tileSet = getInputData(0);
	    	var _tileSiz = getInputData(1);
	    	
	    	if(!is_surface(_tileSet)) return _h;
	    	var _tdim    = surface_get_dimension(_tileSet);
	    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
	    	
			var bx = _x;
			var by = _yy;
			var bs = ui(24);
			var _brush_tiles = brush.brush_width * brush.brush_height;
			var _fromSel = (_brush_tiles ==  9 || _brush_tiles == 15 || _brush_tiles == 48 || _brush_tiles == 55);
			
			if(!_fromSel) {
			    draw_sprite_uniform(THEME.add_16, 0, bx + bs / 2, by + bs / 2, 1, COLORS._main_icon);
			    if(_hover && point_in_rectangle(_m[0], _m[1], bx, by, bx + bs, by + bs))
			        TOOLTIP = "Select region with valid size for autotiling (3x3, 5x3, 12x4, 11x5).";
			    
			} else if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "New autotile from selection", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
				var _new_at = noone;
				var _indx   = array_create(brush.brush_width * brush.brush_height);
				
				for( var i = 0, n = brush.brush_height; i < n; i++ ) 
	    		for( var j = 0, m = brush.brush_width;  j < m; j++ ) 
	    			_indx[i * brush.brush_width + j] = brush.brush_indices[i][j][0];
	    		
				     if(_brush_tiles ==  9) _new_at = new tiler_brush_autotile(AUTOTILE_TYPE.box9,   _indx);
				else if(_brush_tiles == 15) _new_at = new tiler_brush_autotile(AUTOTILE_TYPE.side15, _indx);
				else if(_brush_tiles == 48) _new_at = new tiler_brush_autotile(AUTOTILE_TYPE.top48,  _indx);
				else if(_brush_tiles == 55) _new_at = new tiler_brush_autotile(AUTOTILE_TYPE.top55,  _indx);
				
				if(_new_at != noone) {
					autotile_selecting = array_length(autotiles);
					animated_selecting = noone;
					array_push(autotiles, _new_at);
					
					brush.brush_indices = [[ [ _new_at.index[0], 0 ] ]];
	    			brush.brush_width   = 1;
					brush.brush_height  = 1;
				}
			}
			
			_h  += bs + ui(4);
			_yy += bs + ui(4);
			
	    	var _pd = ui(4);
	    	var _ah = _pd * 2;
	    	var del = -1;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, autotile_selector_h, COLORS.node_composite_bg_blend, 1);
	    	
	    	_yy += _pd;
	    	
	    	for( var i = 0, n = array_length(autotiles); i < n; i++ ) {
	    		var _hg = ui(32);
	    		var _at = autotiles[i];
	    		
	    		var _pw = ui(24);
	    		var _ph = ui(24);
	    		var _px = _x + ui(8);
	    		var _py = _yy + ui(4);
	    		
	    		var _prin = array_safe_get(_at.index, 0, noone);
	    		
	    		if(_prin == noone) {
		    		draw_set_color(COLORS._main_icon);
		    		draw_rectangle(_px, _py, _px + _pw, _py + _ph, true);
	    		} else {
	    			var _prc = safe_mod(_prin, _tileAmo[0]);
	    			var _prr = floor(_prin / _tileAmo[0]);
	    			
	    			var _pr_tx = _prc * _tileSiz[0];
	    			var _pr_ty = _prr * _tileSiz[1];
	    			
	    			var _pr_sx = _pw / _tileSiz[0];
	    			var _pr_sy = _ph / _tileSiz[1];
	    			
	    			draw_surface_part_ext(_tileSet, _pr_tx, _pr_ty, _tileSiz[0], _tileSiz[1], _px, _py, _pr_sx, _pr_sy, c_white, 1);
	    		}
	    		
	    		var _tx  = _px + _pw + ui(8);
	    		var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _hg - 1);
	    		var _cc  = i == autotile_selecting? COLORS._main_accent : (_hov? COLORS._main_text : COLORS._main_text_sub);
	    		
	    		if(renaming == _at) {
					tb_rename.setFocusHover(_focus, _hover);
					tb_rename.draw(_tx, _yy, _w - _pw - ui(8), _hg, rename_text, _m);
				
				} else {
		    		draw_set_text(f_p2, fa_left, fa_center, _cc);
		    		draw_text_add(_tx, _yy + _hg / 2, _at.name);
		    		
		    		var bs = ui(24);
					var bx = _w  - bs;
					var by = _yy + _hg / 2 - bs / 2;
					if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "", THEME.minus_16, 0, _hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
						del = i;	
				}
				
	    		if(_hov && _m[0] < _x + _w - ui(32)) {
	    			if(DOUBLE_CLICK && _focus) {
						renaming    = _at;
						rename_text = _at.name;
						
						tb_rename._current_text = _at.name;
						tb_rename.activate();
	    				
	    			}  else if(mouse_press(mb_left, _focus)) {
	    				if(_m[0] > _tx) {
		    				autotile_selecting = autotile_selecting == i? noone : i;
		    				animated_selecting = noone;
			    			
		    				brush.brush_indices = [[ [ _prin, 0 ] ]];
			    			brush.brush_width   = 1;
		    				brush.brush_height  = 1;
		    				palette_using = false;
		    				
	    				} else {
	    					_at.open = !_at.open;
	    				}
	    			}
	    		}
	    		
	    		_yy += _hg;
	    		_ah += _hg;
	    		
	    		if(_at.open) {
		    		_yy += ui(4);
		    		_ah += ui(4);
		    		
	    			var _atIdx = _at.index;
	    			var _coll  = floor(_w - ui(16)) / _tileSiz[0];
	    			
	    			switch(_at.type) {
	    				case AUTOTILE_TYPE.box9   : _coll =  3; break;
	    				case AUTOTILE_TYPE.side15 : _coll =  5; break;
	    				case AUTOTILE_TYPE.top48  : _coll =  8; break;
	    				case AUTOTILE_TYPE.top55  : _coll = 11; break;
	    			}
	    			
	    			var _roww  = ceil(array_length(_atIdx) / _coll);
	    			
	    			var _pre_sx = _x + ui(8);
	    			var _pre_sy = _yy;
	    			var _pre_sw = _coll * _tileSiz[0];
	    			var _pre_sh = _roww * _tileSiz[1];
	    			
	    			var _ss = (_w - ui(16)) / _pre_sw;
	    			
	    			var _bw = power(2, ceil(log2(_coll)));
					var _bh = power(2, ceil(log2(_roww)));
					
				    _at.preview_surface      = surface_verify(_at.preview_surface,      _bw, _bh, surface_rgba16float);
				    _at.preview_surface_tile = surface_verify(_at.preview_surface_tile, _pre_sw, _pre_sh);
				    
			    	surface_set_shader(_at.preview_surface, sh_draw_tile_brush, true, BLEND.over);
	    			for( var j = 0, m = array_length(_atIdx); j < m; j++ ) {
	    				var _til_row = floor(j / _coll);
	    				var _til_col = j % _coll;
	    				
		    			var _bindex = _atIdx[j];
		    			shader_set_f("index",   _bindex);
		    			shader_set_f("varient", 0);
		    			draw_point(_til_col, _til_row);
	    			}
			    	surface_reset_shader();
	    			    	
				    var _tileSetDim = surface_get_dimension(_tileSet);
				    
				    surface_set_shader(_at.preview_surface_tile, sh_draw_tile_map, true, BLEND.over);
				        shader_set_2("dimension", surface_get_dimension(_at.preview_surface_tile));
				        
				        shader_set_surface("indexTexture", _at.preview_surface);
				        shader_set_2("indexTextureDim", surface_get_dimension(_at.preview_surface));
				        
						shader_submit();
						
				        draw_empty();
				    surface_reset_shader();
	    			
		    		draw_surface_ext(_at.preview_surface_tile, _pre_sx, _pre_sy, _ss, _ss, 0, c_white, 1);
	    			
	    			draw_set_color(COLORS._main_icon);
	    			draw_rectangle(_pre_sx, _pre_sy, _pre_sx + _pre_sw * _ss, _pre_sy + _pre_sh * _ss, true);
	    			
	    			var _dtile_w = _tileSiz[0] * _ss;
	    			var _dtile_h = _tileSiz[1] * _ss;
	    			
	    			if(_hover && point_in_rectangle(_m[0], _m[1], _pre_sx, _pre_sy, _pre_sx + _pre_sw * _ss, _pre_sy + _pre_sh * _ss)) {
	    				var _at_cx = clamp(floor((_m[0] - _pre_sx) / _dtile_w), 0, _coll - 1);
	    				var _at_cy = clamp(floor((_m[1] - _pre_sy) / _dtile_h), 0, _roww - 1);
	    				
	    				var _at_id = _at_cy * _coll + _at_cx;
	    				if(_at_id >= 0 && _at_id < array_length(_atIdx)) {
	    					var _at_c_sx = _pre_sx + _at_cx * _dtile_w;
	    					var _at_c_sy = _pre_sy + _at_cy * _dtile_h;
	    					
	    					draw_set_color(COLORS._main_icon_light);
	    					draw_rectangle(_at_c_sx, _at_c_sy, _at_c_sx + _dtile_w, _at_c_sy + _dtile_h, true);
	    					
	    					if(mouse_press(mb_left, _focus)) {
    							autotile_selecting = i;
    							animated_selecting = noone;
    							autotile_subtile_selecting = autotile_subtile_selecting == _at_id? noone : _at_id;
	    					}
	    					
	    					if(mouse_press(mb_right, _focus))
	    						_at.index[_at_id] = -1;
	    				}
	    			}
	    			
	    			if(autotile_selecting == i && autotile_subtile_selecting != noone) {
	    				var _at_sl_x = autotile_subtile_selecting % _coll;
	    				var _at_sl_y = floor(autotile_subtile_selecting / _coll);
	    				
	    				var _at_c_sx = _pre_sx + _at_sl_x * _dtile_w;
    					var _at_c_sy = _pre_sy + _at_sl_y * _dtile_h;
    					
    					draw_set_color(COLORS._main_accent);
    					draw_rectangle(_at_c_sx, _at_c_sy, _at_c_sx + _dtile_w, _at_c_sy + _dtile_h, true);
	    			}
	    			
	    			_yy += _pre_sh * _ss + ui(4);
		    		_ah += _pre_sh * _ss + ui(4);
		    		
	    		}
	    	}
	    	
	    	if(del != -1) {
	    		array_delete(autotiles, del, 1);
	    		autotile_selecting = noone;
	    	}
	    	
	    	autotile_selector_h = max(ui(12), _ah);
    		return _h + _ah;
    	});
    #endregion
    
    #region ++++ brush palette ++++
    	brush_palette_h    = ui(320);
    	
    	brush_palette           = surface_create(16, 16, surface_rgba16float);
    	brush_palette_buffer    = noone;
    	brush_palette_tile      = noone;
    	brush_palette_prev      = noone;
    	brush_palette_prev_tile = noone;
    	
    	palette_selector_surface = 0;
	    palette_selector_mask    = 0;
	    
	    palette_selector_x    = 0;
	    palette_selector_y    = 0;
	    palette_selector_s    = 2;
	    palette_selector_s_to = 2;
	    
	    palette_dragging = false;
	    palette_drag_sx  = 0;
	    palette_drag_sy  = 0;
	    palette_drag_mx  = 0;
	    palette_drag_my  = 0;
	    
	    palette_selecting = false;
	    palette_select_ss = [ 0, 0 ];
	    palette_bbox      = [ 0, 0, 0, 0 ];
	    
	    palette_tool       = 0;
	    palette_tool_using = false;
	    palette_using      = false;
	    
    	palette_viewer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
    		var _yy = _y;
    		var _h  = 0;
	    	var _pd = ui(4);
	    	
	    	var _tileSet = getInputData(0);
	    	var _tileSiz = getInputData(1);
	    	
			var bx = _x;
			var by = _yy;
			var bs = ui(24);
			
			var _tsh = palette_viewer.fixHeight > 0? palette_viewer.fixHeight - ui(24 + 4) : brush_palette_h;
			
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "Pencil", THEME.canvas_tools_pencil, 0, palette_tool == 1? COLORS._main_accent : c_white) == 2)
				palette_tool = palette_tool == 1? 0 : 1;
			
			draw_sprite_ui_uniform(THEME.canvas_tools_pencil, 1, bx + bs / 2, by + bs / 2, 1, palette_tool == 1? COLORS._main_accent : c_white);
			
			bx += bs + ui(4);
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "Eraser", THEME.canvas_tools_eraser, 0, palette_tool == 2? COLORS._main_accent : c_white) == 2) 
				palette_tool = palette_tool == 2? 0 : 2;
			
			bx = _x + _w - bs;
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "Zoom to fit", THEME.path_tools_transform, 0, COLORS._main_icon_light) == 2) {
			    if(is_surface(brush_palette_tile)) {
			        var _tdim = surface_get_dimension(brush_palette_tile);
    				var _sw   = _w - _pd * 2;
    	    	    var _sh   = _tsh - _pd * 2;
    	    	    
    	    	    var _ss = min(_sw / (_tdim[0] + 16), _sh / (_tdim[1] + 16));
    	    	    palette_selector_s    = _ss;
    	    	    palette_selector_s_to = _ss;
    	    	    
    	    	    palette_selector_x = _w / 2              - _tdim[0] * _ss / 2;
                    palette_selector_y = _tsh / 2 - _tdim[1] * _ss / 2;
			    }
			}
			
			_h  += bs + ui(4);
			_yy += bs + ui(4);
			
	    	var _sx = _x  + _pd;
	    	var _sy = _yy + _pd;
	    	var _sw = _w  - _pd * 2;
	    	var _sh = _tsh - _pd * 2;
	    	
	    	_h += _tsh;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, _tsh, COLORS.node_composite_bg_blend, 1);
	    	palette_selector_surface  = surface_verify(palette_selector_surface,  _sw, _sh);
	    	palette_selector_mask     = surface_verify(palette_selector_mask,     _sw, _sh);
	    	
	    	if(!is_surface(_tileSet))      return _h;
	    	if(!is_surface(brush_palette)) {
	    		if(brush_palette_buffer && buffer_exists(brush_palette_buffer))
	    			brush_palette = surface_from_buffer(brush_palette_buffer);
	    		else 
	    			brush_palette = surface_create(16, 16, surface_rgba16float);
	    	}
	    	
    		var _bpdim      = surface_get_dimension(brush_palette);
		    var _tileSetDim = surface_get_dimension(_tileSet);
		    
		    var _bptw = _bpdim[0] * _tileSiz[0];
		    var _bpth = _bpdim[1] * _tileSiz[1];
		    
		    brush_palette_tile      = surface_verify(brush_palette_tile, _bptw, _bpth);
		    brush_palette_prev      = surface_verify(brush_palette_prev, _bpdim[0], _bpdim[1], surface_rgba16float);
    		brush_palette_prev_tile = surface_verify(brush_palette_prev_tile, _bptw, _bpth);
    		
		    surface_set_shader(brush_palette_tile, sh_draw_tile_map, true, BLEND.over);
		        shader_set_2("dimension", [ _bptw, _bpth ]);
		        
		        shader_set_surface("indexTexture", brush_palette);
		        shader_set_2("indexTextureDim", surface_get_dimension(brush_palette));
		        
		        shader_submit();
				
		        draw_empty();
		    surface_reset_shader();
    	
	    	var _tdim    = surface_get_dimension(brush_palette_tile);
	    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
	    	
	    	var _tileSel_w = _tileSiz[0] * palette_selector_s;
	    	var _tileSel_h = _tileSiz[1] * palette_selector_s;
	    	
	    	var _msx = _m[0] - _sx - palette_selector_x;
	    	var _msy = _m[1] - _sy - palette_selector_y;
	    	
	    	var _mtx = floor(_msx / palette_selector_s / _tileSiz[0]);
	    	var _mty = floor(_msy / palette_selector_s / _tileSiz[1]);
	    	var _mid = _mtx >= 0 && _mtx < _tileAmo[0] && _mty >= 0 && _mty < _tileAmo[1]? _mty * _tileAmo[0] + _mtx : noone;
	    	
	    	var _tileHov_x = palette_selector_x + _mtx * _tileSiz[0] * palette_selector_s;
	    	var _tileHov_y = palette_selector_y + _mty * _tileSiz[1] * palette_selector_s;
	    	
	    	var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _tsh);
	    	
	    	#region surface_set_target(palette_selector_surface); 
	    	surface_set_target(palette_selector_surface); 
	    		draw_clear(colorMultiply(COLORS.panel_bg_clear, COLORS.node_composite_bg_blend));
	    		draw_sprite_tiled_ext(s_transparent, 0, palette_selector_x, palette_selector_y, palette_selector_s, palette_selector_s, 
	    			colorMultiply(COLORS.panel_preview_transparent, COLORS.node_composite_bg_blend), 1);
	    		
	    		if(palette_tool) draw_surface_ext(brush_palette_prev_tile, palette_selector_x, palette_selector_y, palette_selector_s, palette_selector_s, 0, c_white, 1);
	    		else             draw_surface_ext(brush_palette_tile,      palette_selector_x, palette_selector_y, palette_selector_s, palette_selector_s, 0, c_white, 1);
	    		
	    		if(grid_draw) {
	    			var _gw = _tileSiz[0] * palette_selector_s;
			        var _gh = _tileSiz[1] * palette_selector_s;
			        
			        var gw = _tdim[0] / _tileSiz[0];
			        var gh = _tdim[1] / _tileSiz[1];
			    	
			        var cx = palette_selector_x;
			        var cy = palette_selector_y;
			    
			        draw_set_color(PROJECT.previewGrid.color);
			        draw_set_alpha(PROJECT.previewGrid.opacity);
			        
			        for( var i = 1; i < gw; i++ ) {
			            var _xx = cx + i * _gw;
			            draw_line(_xx, cy, _xx, cy + _tdim[1] * palette_selector_s);
			        }
			    
			        for( var i = 1; i < gh; i++ ) {
			            var _yy = cy + i * _gh;
			            draw_line(cx, _yy, cx + _tdim[0] * palette_selector_s, _yy);
			        }
			        
			        draw_set_alpha(1);
	    		}
	    		
	    		draw_set_color(COLORS.panel_preview_surface_outline);
            	draw_rectangle(palette_selector_x, palette_selector_y, palette_selector_x + _tdim[0] * palette_selector_s - 1, palette_selector_y + _tdim[1] * palette_selector_s - 1, true);
            	
	    		if(_hov && _mid > noone) {
		    		
		    		if(palette_tool != 1) {
			    		draw_set_color(c_white);
			    		draw_rectangle_width(_tileHov_x - 1, _tileHov_y - 1, _tileHov_x + _tileSel_w, _tileHov_y + _tileSel_h, 1);
			    		
			    		draw_set_color(c_black);
			    		draw_rectangle_width(_tileHov_x, _tileHov_y, _tileHov_x + _tileSel_w - 1, _tileHov_y + _tileSel_h - 1, 1);
		    		}
		    		
	    			if(palette_tool == 0 && mouse_press(mb_left, _focus)) {
		    			autotile_selecting = noone;
		    			animated_selecting = noone;
	    				palette_selecting  = true;
	    				palette_using      = true;
	    				palette_select_ss  = [ _mtx, _mty ];
	    			}
	    		}
	    	surface_reset_target();
	    	#endregion
	    	
    		if(palette_selecting) { //tile selection
    			var _ts_sx = clamp(min(palette_select_ss[0], _mtx), 0, _tileAmo[0] - 1);
    			var _ts_sy = clamp(min(palette_select_ss[1], _mty), 0, _tileAmo[1] - 1);
    			var _ts_ex = clamp(max(palette_select_ss[0], _mtx), 0, _tileAmo[0] - 1);
    			var _ts_ey = clamp(max(palette_select_ss[1], _mty), 0, _tileAmo[1] - 1);
    			
				brush.brush_indices = [];
				brush.brush_width   = _ts_ex - _ts_sx + 1;
				brush.brush_height  = _ts_ey - _ts_sy + 1;
				var _ind = 0;
				
				palette_bbox = [ _ts_sx, _ts_ex, _ts_sy, _ts_ey ];
				
				for( var i = _ts_sy; i <= _ts_ey; i++ ) 
				for( var j = _ts_sx; j <= _ts_ex; j++ ) {
					var _pal_c = surface_getpixel_ext(brush_palette, j, i);
					brush.brush_indices[i - _ts_sy][j - _ts_sx] = [ _pal_c[0] - 1, _pal_c[1] ];
				}
    			
    			if(mouse_release(mb_left))
	    			palette_selecting = false;
    		}
	    	
	    	#region pan zoom 
		    	if(palette_dragging) {
		    		var _tdx = _m[0] - palette_drag_mx;
		    		var _tdy = _m[1] - palette_drag_my;
		    		
		    		palette_selector_x = palette_drag_sx + _tdx;
				    palette_selector_y = palette_drag_sy + _tdy;
				    
		    		if(mouse_release(mb_middle))
		    			palette_dragging = false;
		    	}
		    	
		    	if(_hov) {
		    		if(mouse_press(mb_middle, _focus)) {
			    		palette_dragging = true;
			    		palette_drag_sx  = palette_selector_x;
					    palette_drag_sy  = palette_selector_y;
					    palette_drag_mx  = _m[0];
					    palette_drag_my  = _m[1];
		    		}
		    		
		    		var _s = palette_selector_s;
		    		if(key_mod_press(CTRL) || palette_viewer.popupPanel != noone) {
			    		if(mouse_wheel_up())   { palette_selector_s_to = clamp(palette_selector_s_to * 1.2, 0.5, 4); }
			    		if(mouse_wheel_down()) { palette_selector_s_to = clamp(palette_selector_s_to / 1.2, 0.5, 4); }
		    		}
		    		palette_selector_s = lerp_float(palette_selector_s, palette_selector_s_to, 2);
		    		
		    		if(_s != palette_selector_s) {
		    			var _ds  = palette_selector_s - _s;
		    			
		    			palette_selector_x -= _msx * _ds / _s;
		    			palette_selector_y -= _msy * _ds / _s;
		    		}
		    	}
		    	
		    	var _tdim_ws = _tdim[0] * palette_selector_s;
		    	var _tdim_hs = _tdim[1] * palette_selector_s;
		    	var _minx = -(_tdim_ws - _w) - 32;
		    	var _miny = -(_tdim_hs - _tsh) - 32;
		    	var _maxx = 32;
		    	var _maxy = 32;
		    	if(_minx > _maxx) { _minx = (_minx + _maxx) / 2; _maxx = _minx; }
		    	if(_miny > _maxy) { _miny = (_miny + _maxy) / 2; _maxy = _miny; }
		    	
		    	palette_selector_x = clamp(palette_selector_x, _minx, _maxx);
			    palette_selector_y = clamp(palette_selector_y, _miny, _maxy);
		    #endregion
		    	
			if(palette_tool == 1) {
				surface_set_target(palette_selector_mask);
		    		DRAW_CLEAR
		    		draw_set_color(c_white);
		    		
		    		for( var i = 0, n = array_length(brush.brush_indices);    i < n; i++ ) 
		    		for( var j = 0, m = array_length(brush.brush_indices[i]); j < m; j++ ) {
			    		var _tileSel_x   = palette_selector_x + (_mtx + j) * _tileSiz[0] * palette_selector_s;
			    		var _tileSel_y   = palette_selector_y + (_mty + i) * _tileSiz[1] * palette_selector_s;
			    		draw_rectangle(_tileSel_x, _tileSel_y, _tileSel_x + _tileSel_w, _tileSel_y + _tileSel_h, false);
		    		}
		    	surface_reset_target();
		    	
		    	surface_set_target(brush_palette_prev);
	    			DRAW_CLEAR
	    			BLEND_OVERRIDE
	    			draw_surface(brush_palette, 0, 0);
	    			
	    			shader_set(sh_draw_tile_brush); 
	    			for( var i = 0, n = array_length(brush.brush_indices);    i < n; i++ ) 
	    			for( var j = 0, m = array_length(brush.brush_indices[i]); j < m; j++ ) {
	    				var _b = brush.brush_indices[i][j];
	    				shader_set_f("index",   _b[0]);
						shader_set_f("varient", _b[1]);
						
						draw_point(_mtx + j, _mty + i);
	    			}
	    			
	    			BLEND_NORMAL
	    			shader_reset();
	    		surface_reset_target();
	    		
	    		if(mouse_click(mb_left, _hov && _focus)) {
					palette_tool_using = true;
					
	    			surface_set_target(brush_palette);
	    			shader_set(sh_draw_tile_brush); 
	    			BLEND_OVERRIDE
	    			
	    			for( var i = 0, n = array_length(brush.brush_indices);    i < n; i++ ) 
	    			for( var j = 0, m = array_length(brush.brush_indices[i]); j < m; j++ ) {
	    				var _b = brush.brush_indices[i][j];
	    				shader_set_f("index",   _b[0]);
						shader_set_f("varient", _b[1]);
						
						draw_point(_mtx + j, _mty + i);
	    			}
	    			
	    			BLEND_NORMAL 
	    			shader_reset();
	    			surface_reset_shader();
	    		}
		    	
	    		if(palette_tool_using && mouse_release(mb_left)) {
	    			palette_tool_using = false;
	    			
	    			buffer_delete_safe(brush_palette_buffer);
	    			brush_palette_buffer = buffer_from_surface(brush_palette);
	    		}
		    	
			} else if(palette_tool == 2) {
				
	    		surface_set_target(brush_palette_prev);
	    			DRAW_CLEAR
	    			BLEND_OVERRIDE
	    			draw_surface(brush_palette, 0, 0);
	    			
	    			shader_set(sh_draw_tile_brush); 
	    			shader_set_f("index",   0);
					shader_set_f("varient", 0);
					
					draw_point(_mtx, _mty);
	    			
	    			BLEND_NORMAL
	    			shader_reset();
	    		surface_reset_target();
	    		
				if(mouse_click(mb_left, _focus && _hov)) {
					palette_tool_using = true;
					
	    			surface_set_target(brush_palette);
	    			shader_set(sh_draw_tile_brush); 
	    			BLEND_OVERRIDE
		    			
	    				shader_set_f("index",   0);
						shader_set_f("varient", 0);
						
						draw_point(_mtx, _mty);
		    			
	    			BLEND_NORMAL 
	    			shader_reset();
	    			surface_reset_shader();
	    		}
				
				if(palette_tool_using && mouse_release(mb_left)) {
					palette_tool_using = false;
					
	    			buffer_delete_safe(brush_palette_buffer);
	    			brush_palette_buffer = buffer_from_surface(brush_palette);
	    		}
				
			} else if(palette_using) {
		    	surface_set_target(palette_selector_mask);
		    		DRAW_CLEAR
		    		draw_set_color(c_white);
		    		
		    		for( var i = palette_bbox[0]; i <= palette_bbox[1]; i++ ) 
		    		for( var j = palette_bbox[2]; j <= palette_bbox[3]; j++ ) {
			    		var _tileSel_x = palette_selector_x + i * _tileSiz[0] * palette_selector_s;
			    		var _tileSel_y = palette_selector_y + j * _tileSiz[1] * palette_selector_s;
			    		draw_rectangle(_tileSel_x, _tileSel_y, _tileSel_x + _tileSel_w, _tileSel_y + _tileSel_h, false);
		    		}
		    	surface_reset_target();
			}
			
			if(palette_tool) {
			    surface_set_shader(brush_palette_prev_tile, sh_draw_tile_map, true, BLEND.over);
			        shader_set_2("dimension", [ _bptw, _bpth ]);
			        
			        shader_set_surface("indexTexture", brush_palette_prev);
			        shader_set_2("indexTextureDim", surface_get_dimension(brush_palette_prev));
			        
			        shader_submit();
					
			        draw_empty();
			    surface_reset_shader();
			}
			
			draw_surface(palette_selector_surface, _sx, _sy);
    		
			shader_set(sh_brush_outline);
				shader_set_f("dimension", _sw, _sh);
				draw_surface_ext(palette_selector_mask, _sx, _sy, 1, 1, 0, c_white, 1);
			shader_reset();
			
    		return _h;
    	});
    #endregion
    
    #region ++++ animated tiles ++++
    	animatedTiles = [];
		
		animated_selecting  = noone;
		animated_selector_h = 0;
		animated_subtile_selecting = noone;
		
		aTiles       = [];
		aTilesIndex  = [];
		aTilesLength = [];
		
		function refreshAnimatedData() {
		    aTiles       = [];
			aTilesIndex  = array_create(array_length(animatedTiles));
			aTilesLength = array_create(array_length(animatedTiles));
			
			for( var i = 0, n = array_length(animatedTiles); i < n; i++ ) {
				var _at = animatedTiles[i];
				
				aTilesIndex[i]  = array_length(aTiles);
				aTilesLength[i] = array_length(_at.index);
				array_append(aTiles, _at.index);
			}
		}
		
    	animated_viewer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
    		var _yy = _y;
	    	var _h  = 0;
	    	
	    	var _tileSet = getInputData(0);
	    	var _tileSiz = getInputData(1);
	    	
	    	if(!is_surface(_tileSet)) return _h;
	    	var _tdim    = surface_get_dimension(_tileSet);
	    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
	    	
			var bx = _x;
			var by = _yy;
			var bs = ui(24);
			var _brush_tiles = brush.brush_width * brush.brush_height;
			
			if(_brush_tiles < 1) 
			    draw_sprite_uniform(THEME.add_16, 0, bx + bs / 2, by + bs / 2, 1, COLORS._main_icon);
			else if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "New animated tiles", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
				var _new_at = noone;
				var _indx   = array_create(brush.brush_width * brush.brush_height);
				
				for( var i = 0, n = brush.brush_height; i < n; i++ ) 
	    		for( var j = 0, m = brush.brush_width;  j < m; j++ )
	    			_indx[i * brush.brush_width + j] = brush.brush_indices[i][j][0];
	    		
	    		_new_at = new tiler_brush_animated(_indx);
	    		
				if(_new_at != noone) {
					animated_selecting = array_length(animatedTiles);
					autotile_selecting = noone;
					array_push(animatedTiles, _new_at);
					
					brush.brush_indices = [[ [ -(animated_selecting + 2), 0 ] ]];
	    			brush.brush_width   = 1;
					brush.brush_height  = 1;
				}
				
				refreshAnimatedData();
			}
			
			_h  += bs + ui(4);
			_yy += bs + ui(4);
			
	    	var _pd = ui(4);
	    	var _ah = _pd * 2;
	    	var del = -1;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, animated_selector_h, COLORS.node_composite_bg_blend, 1);
	    	
	    	_yy += _pd;
	    	
	    	for( var i = 0, n = array_length(animatedTiles); i < n; i++ ) {
	    		var _hg = ui(32);
	    		var _at = animatedTiles[i];
	    		
	    		var _pw = ui(24);
	    		var _ph = ui(24);
	    		var _px = _x + ui(8);
	    		var _py = _yy + ui(4);
	    		
	    		var _prin = array_safe_get(_at.index, safe_mod(current_time / 1000 * 2, array_length(_at.index)), noone);
	    		
	    		if(_prin == noone) {
		    		draw_set_color(COLORS._main_icon);
		    		draw_rectangle(_px, _py, _px + _pw, _py + _ph, true);
		    		
	    		} else {
	    			var _prc = safe_mod(_prin, _tileAmo[0]);
	    			var _prr = floor(_prin / _tileAmo[0]);
	    			
	    			var _pr_tx = _prc * _tileSiz[0];
	    			var _pr_ty = _prr * _tileSiz[1];
	    			
	    			var _pr_sx = _pw / _tileSiz[0];
	    			var _pr_sy = _ph / _tileSiz[1];
	    			
	    			draw_surface_part_ext(_tileSet, _pr_tx, _pr_ty, _tileSiz[0], _tileSiz[1], _px, _py, _pr_sx, _pr_sy, c_white, 1);
	    		}
	    		
	    		var _tx  = _px + _pw + ui(8);
	    		var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _hg - 1);
	    		var _cc  = i == animated_selecting? COLORS._main_accent : (_hov? COLORS._main_text : COLORS._main_text_sub);
	    		
	    		if(renaming == _at) {
					tb_rename.setFocusHover(_focus, _hover);
					tb_rename.draw(_tx, _yy, _w - _pw - ui(8), _hg, rename_text, _m);
				
				} else {
		    		draw_set_text(f_p2, fa_left, fa_center, _cc);
		    		draw_text_add(_tx, _yy + _hg / 2, _at.name);
		    		
		    		var bs = ui(24);
					var bx = _w  - bs;
					var by = _yy + _hg / 2 - bs / 2;
					if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "", THEME.minus_16, 0, _hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
						del = i;	
				}
				
	    		if(_hov && _m[0] < _x + _w - ui(32)) {
	    			if(DOUBLE_CLICK && _focus) {
						renaming    = _at;
						rename_text = _at.name;
						
						tb_rename._current_text = _at.name;
						tb_rename.activate();
	    				
	    			}  else if(mouse_press(mb_left, _focus)) {
	    				if(_m[0] > _tx) {
		    				animated_selecting  = animated_selecting == i? noone : i;
		    				autotile_selecting = noone;
			    			
		    				brush.brush_indices = [[ [ - (i + 2), 0 ] ]];
			    			brush.brush_width   = 1;
		    				brush.brush_height  = 1;
		    				palette_using = false;
		    				
	    				} else {
	    					_at.open = !_at.open;
	    				}
	    			}
	    		}
	    		
	    		_yy += _hg;
	    		_ah += _hg;
	    		
	    		if(_at.open) {
		    		_yy += ui(4);
		    		_ah += ui(4);
		    		
	    			var _atIdx = _at.index;
	    			var _coll  = floor(_w - ui(16)) / max(32, _tileSiz[0]);
	    			var _roww  = ceil(array_length(_atIdx) / _coll);
	    			
	    			var _pre_sx = _x + ui(8);
	    			var _pre_sy = _yy;
	    			var _pre_sw = _coll * _tileSiz[0];
	    			var _pre_sh = _roww * _tileSiz[1];
	    			
	    			var _ss = (_w - ui(16)) / _pre_sw;
	    			
	    			var _bw = power(2, ceil(log2(_coll)));
					var _bh = power(2, ceil(log2(_roww)));
					
				    _at.preview_surface      = surface_verify(_at.preview_surface,      _bw, _bh, surface_rgba16float);
				    _at.preview_surface_tile = surface_verify(_at.preview_surface_tile, _pre_sw, _pre_sh);
				    
			    	surface_set_shader(_at.preview_surface, sh_draw_tile_brush, true, BLEND.over);
	    			for( var j = 0, m = array_length(_atIdx); j < m; j++ ) {
	    				var _til_row = floor(j / _coll);
	    				var _til_col = j % _coll;
	    				
		    			var _bindex = _atIdx[j];
		    			shader_set_f("index",   _bindex);
		    			shader_set_f("varient", 0);
		    			draw_point(_til_col, _til_row);
	    			}
			    	surface_reset_shader();
	    			    	
				    var _tileSetDim = surface_get_dimension(_tileSet);
				    
				    surface_set_shader(_at.preview_surface_tile, sh_draw_tile_map, true, BLEND.over);
				        shader_set_2("dimension", surface_get_dimension(_at.preview_surface_tile));
				        
				        shader_set_surface("indexTexture", _at.preview_surface);
				        shader_set_2("indexTextureDim", surface_get_dimension(_at.preview_surface));
				        
				        shader_submit();
						
				        draw_empty();
				    surface_reset_shader();
	    			
		    		draw_surface_ext(_at.preview_surface_tile, _pre_sx, _pre_sy, _ss, _ss, 0, c_white, 1);
	    			
	    			draw_set_color(COLORS._main_icon);
	    			draw_rectangle(_pre_sx, _pre_sy, _pre_sx + _pre_sw * _ss, _pre_sy + _pre_sh * _ss, true);
	    			
	    			var _dtile_w = _tileSiz[0] * _ss;
	    			var _dtile_h = _tileSiz[1] * _ss;
	    			
	    			if(_hover && point_in_rectangle(_m[0], _m[1], _pre_sx, _pre_sy, _pre_sx + _pre_sw * _ss, _pre_sy + _pre_sh * _ss)) {
	    				var _at_cx = clamp(floor((_m[0] - _pre_sx) / _dtile_w), 0, _coll - 1);
	    				var _at_cy = clamp(floor((_m[1] - _pre_sy) / _dtile_h), 0, _roww - 1);
	    				
	    				var _at_id = _at_cy * _coll + _at_cx;
	    				if(_at_id >= 0 && _at_id < array_length(_atIdx)) {
	    					var _at_c_sx = _pre_sx + _at_cx * _dtile_w;
	    					var _at_c_sy = _pre_sy + _at_cy * _dtile_h;
	    					
	    					draw_set_color(COLORS._main_icon_light);
	    					draw_rectangle(_at_c_sx, _at_c_sy, _at_c_sx + _dtile_w, _at_c_sy + _dtile_h, true);
	    					
	    					if(mouse_press(mb_left, _focus)) {
    							animated_selecting = i;
    							autotile_selecting = noone;
    							
    							animated_subtile_selecting = animated_subtile_selecting == _at_id? noone : _at_id;
	    					}
	    					
	    					if(mouse_press(mb_right, _focus))
	    						_at.index[_at_id] = -1;
	    				}
	    			}
	    			
	    			if(animated_selecting == i && animated_subtile_selecting != noone) {
	    				var _at_sl_x = animated_subtile_selecting % _coll;
	    				var _at_sl_y = floor(animated_subtile_selecting / _coll);
	    				
	    				var _at_c_sx = _pre_sx + _at_sl_x * _dtile_w;
    					var _at_c_sy = _pre_sy + _at_sl_y * _dtile_h;
    					
    					draw_set_color(COLORS._main_accent);
    					draw_rectangle(_at_c_sx, _at_c_sy, _at_c_sx + _dtile_w, _at_c_sy + _dtile_h, true);
	    			}
	    			
	    			_yy += _pre_sh * _ss + ui(4);
		    		_ah += _pre_sh * _ss + ui(4);
		    		
	    		}
	    	}
	    	
	    	if(del != -1) {
	    		array_delete(animatedTiles, del, 1);
	    		animated_selecting = noone;
	    		refreshAnimatedData();
	    	}
	    	
	    	animated_selector_h = max(ui(12), _ah);
    		return _h + _ah;
    	});
    #endregion
    
    texture  = noone;
    tileSize = [ 1, 1 ];
        
    tile_selector_toggler     = button(function() /*=>*/ { tile_selector.togglePopup("Tileset");         }).setIcon(THEME.node_goto, 0, COLORS._main_icon, .75);
    autotile_selector_toggler = button(function() /*=>*/ { autotile_selector.togglePopup("Autotile");    }).setIcon(THEME.node_goto, 0, COLORS._main_icon, .75);
    palette_viewer_toggler    = button(function() /*=>*/ { palette_viewer.togglePopup("Tile Palette");   }).setIcon(THEME.node_goto, 0, COLORS._main_icon, .75);
    animated_viewer_toggler   = button(function() /*=>*/ { animated_viewer.togglePopup("Animated Tile"); }).setIcon(THEME.node_goto, 0, COLORS._main_icon, .75);
    
	input_display_list = [ 1, 0, 
		["Tileset",   false, noone, tile_selector_toggler     ], tile_selector, 
		["Autotiles",  true, noone, autotile_selector_toggler ], autotile_selector, 
		["Palette",    true, noone, palette_viewer_toggler    ], palette_viewer,
		["Animated",   true,     2, animated_viewer_toggler   ], animated_viewer,
	];
	
	static shader_submit = function() {
        shader_set_2("tileSize",  tileSize);
        
        shader_set_surface("tileTexture", texture);
        shader_set_2("tileTextureDim", surface_get_dimension(texture));
        
		shader_set_f("animatedTiles",       aTiles);
		shader_set_f("animatedTilesIndex",  aTilesIndex);
		shader_set_f("animatedTilesLength", aTilesLength);
	}
	
	static step = function() {
	    tile_selector_toggler.icon_blend     = tile_selector.popupPanel     == noone? COLORS._main_icon : COLORS._main_accent;
	    autotile_selector_toggler.icon_blend = autotile_selector.popupPanel == noone? COLORS._main_icon : COLORS._main_accent;
	    palette_viewer_toggler.icon_blend    = palette_viewer.popupPanel    == noone? COLORS._main_icon : COLORS._main_accent;
	    animated_viewer_toggler.icon_blend   = animated_viewer.popupPanel   == noone? COLORS._main_icon : COLORS._main_accent;
	}
	
	static update = function(frame = CURRENT_FRAME) {
	    texture  = inputs[0].getValue();
	    tileSize = inputs[1].getValue();
	    
	    outputs[0].setValue(self);
	}
	
	static getPreviewValues       = function() { return texture; }
	static getGraphPreviewSurface = function() { return texture; }
	
	static attributeSerialize = function() {
		var _attr = {
			autotiles, animatedTiles, 
			palette: buffer_from_surface(brush_palette),
		};
		
		return _attr; 
	}
	
	static attributeDeserialize = function(attr) {
		var _auto = struct_try_get(attr, "autotiles",     []);
		var _anim = struct_try_get(attr, "animatedTiles", []);
		var _palt = struct_try_get(attr, "palette", noone);
		
		for( var i = 0, n = array_length(_auto); i < n; i++ ) {
			autotiles[i] = new tiler_brush_autotile(_auto[i].type, _auto[i].index);
			autotiles[i].name = _auto[i].name;
		}
		
		for( var i = 0, n = array_length(_anim); i < n; i++ ) {
			animatedTiles[i] = new tiler_brush_animated(_anim[i].index);
			animatedTiles[i].name = _anim[i].name;
		}
		
		if(_palt) {
			surface_free_safe(brush_palette);
			brush_palette_buffer = _palt;
			brush_palette = surface_from_buffer(_palt);
		}
		
		refreshAnimatedData();
	}
}