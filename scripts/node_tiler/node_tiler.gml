function Node_Tile_Drawer(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
    name = "Tile Drawer";
    bypass_grid = true;
    
    renaming       = noone;
	rename_text    = "";
	tb_rename = new textBox(TEXTBOX_INPUT.text, function(_name) { 
		if(renaming == noone) return;
		renaming.name  = _name;
		renaming       = noone;
	});
	tb_rename.font = f_p2;
	tb_rename.hide = true;
	
    newInput( 0, nodeValue_Surface("Tileset", self, noone));
    
    newInput( 1, nodeValue_IVec2("Map size", self, [ 16, 16 ]));
    
    newInput( 2, nodeValue_Vec2("Tile size", self, [ 16, 16 ]));
    
    #region tile selector 
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
	    
	    selecting_surface      = noone;
	    selecting_surface_tile = noone;
	    
	    tile_selecting = false;
	    tile_select_ss = [ 0, 0 ];
	    
	    autotile_selector_mask = 0;
	    
	    grid_draw = true;
	    
	    tile_selector = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
	    	var _h       = tile_selector_h;
	    	var _pd      = ui(4);
	    	var _tileSet = array_safe_get(current_data, 0);
	    	var _tileSiz = array_safe_get(current_data, 2);
	    	
	    	var _sx = _x + _pd;
	    	var _sy = _y + _pd;
	    	var _sw = _w - _pd * 2;
	    	var _sh = _h - _pd * 2;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
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
	    	
	    	var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
	    	
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
			            var _xx = cx + i * _gw;
			            draw_line(_xx, cy, _xx, cy + _tdim[1] * tile_selector_s);
			        }
			    
			        for( var i = 1; i < gh; i++ ) {
			            var _yy = cy + i * _gh;
			            draw_line(cx, _yy, cx + _tdim[0] * tile_selector_s, _yy);
			        }
			        
			        draw_set_alpha(1);
	    		}
	    		
	    		draw_set_color(COLORS.panel_preview_surface_outline);
            	draw_rectangle(tile_selector_x, tile_selector_y, tile_selector_x + _tdim[0] * tile_selector_s - 1, tile_selector_y + _tdim[1] * tile_selector_s - 1, true);
	    		
	    		draw_set_color(c_white);
	    		draw_rectangle_width(_tileHov_x - 1, _tileHov_y - 1, _tileHov_x + _tileSel_w, _tileHov_y + _tileSel_h, 1);
	    		
	    		draw_set_color(c_black);
	    		draw_rectangle_width(_tileHov_x, _tileHov_y, _tileHov_x + _tileSel_w - 1, _tileHov_y + _tileSel_h - 1, 1);
	    		
	    		if(_hov && _mid > noone && mouse_press(mb_left, _focus)) {
	    			
	    			if(autotile_subtile_selecting == noone) {
		    			autotile_selecting = noone;
	    				tile_selecting = true;
	    				tile_select_ss = [ _mtx, _mty ];
	    				
	    			} else {
	    				autotiles[autotile_selecting].index[autotile_subtile_selecting] = _mid;
	    				autotile_subtile_selecting++;
	    				if(autotile_subtile_selecting >= array_length(autotiles[autotile_selecting].index))
	    					autotile_subtile_selecting = noone;
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
	    			var _bindex      = brush.brush_indices[i][j];
			    	var _tileSel_row = floor(_bindex / _tileAmo[0]);
			    	var _tileSel_col = safe_mod(_bindex, _tileAmo[0]);
		    		var _tileSel_x   = tile_selector_x + _tileSel_col * _tileSiz[0] * tile_selector_s;
		    		var _tileSel_y   = tile_selector_y + _tileSel_row * _tileSiz[1] * tile_selector_s;
		    		draw_rectangle(_tileSel_x, _tileSel_y, _tileSel_x + _tileSel_w, _tileSel_y + _tileSel_h, false);
	    		}
	    	surface_reset_target();
	    	#endregion
	    	
	    	#region tile selection
	    		if(tile_selecting) {
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
	    				brush.brush_indices[i - _ts_sy][j - _ts_sx] = i * _tileAmo[0] + j;
	    			
	    			if(mouse_release(mb_left))
		    			tile_selecting = false;
	    		}
	    	#endregion
	    	
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
		    		if(key_mod_press(CTRL)) {
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
		    	var _miny = -(_tdim_hs - _h) - 32;
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
				var _bw = power(2, ceil(log2(brush.brush_width)));
				var _bh = power(2, ceil(log2(brush.brush_height)));
				var _sel_sw = brush.brush_width  * _tileSiz[0];
				var _sel_sh = brush.brush_height * _tileSiz[1];
				
				selecting_surface      = surface_verify(selecting_surface, _bw, _bh, surface_rgba16float);
		    	selecting_surface_tile = surface_verify(selecting_surface_tile, _sel_sw, _sel_sh);
		    	
				var _ty = _y + _h + ui(8);
				var _th = ui(48);
				_h += ui(8) + _th;
				
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _ty, _w, _th, COLORS.node_composite_bg_blend, 1);
				
				var _sx =  _x  + ui(8);
				var _variences = [ 0, 1, 2, 3, 8, 16 ];
				
				if(brush.brush_width * brush.brush_height > 1) {
					_variences = [ 0 ];
					brush.brush_varient = 0;
				}
				
				for( var v = 0, p = array_length(_variences); v < p; v++ ) {
					
			    	surface_set_shader(selecting_surface, sh_draw_tile_brush, true, BLEND.over);
			    		for( var i = 0, n = array_length(brush.brush_indices);    i < n; i++ ) 
			    		for( var j = 0, m = array_length(brush.brush_indices[i]); j < m; j++ ) {
			    			var _bindex = brush.brush_indices[i][j];
			    			shader_set_f("index", _bindex);
			    			shader_set_f("varient", _variences[v]);
			    			draw_point(j, i);
			    		}
			    	surface_reset_shader();
			    	    	
				    var _tileSetDim = surface_get_dimension(_tileSet);
				    
				    surface_set_shader(selecting_surface_tile, sh_draw_tile_map, true, BLEND.over);
				        shader_set_2("dimension", [ _sel_sw, _sel_sh ]);
				        shader_set_2("tileSize",  _tileSiz);
				        shader_set_2("tileAmo",   [ floor(_tileSetDim[0] / _tileSiz[0]), floor(_tileSetDim[1] / _tileSiz[1]) ]);
				        
				        shader_set_surface("tileTexture", _tileSet);
				        shader_set_2("tileTextureDim", _tileSetDim);
				        
				        shader_set_surface("indexTexture", selecting_surface);
				        shader_set_2("indexTextureDim", surface_get_dimension(selecting_surface));
				        
				        draw_empty();
				    surface_reset_shader();
		    		
		    		var _sy =  _ty + ui(8);
		    		var _ss = (_th - ui(16)) / _sel_sh;
		    		var _sw = _ss * _sel_sw;
		    		var _sh = _ss * _sel_sh;
		    		
		    		draw_surface_ext(selecting_surface_tile, _sx, _sy, _ss, _ss, 0, c_white, 1);
		    		
		    		var _shov = _hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _sw, _sy + _sh);
		    		var cc = _shov? COLORS._main_icon_light : COLORS._main_icon;
		    		if(v == brush.brush_varient)
		    			cc = COLORS._main_accent;
		    		
		    		draw_set_color(cc);
		    		draw_rectangle(_sx, _sy, _sx + _sw, _sy + _sh, true);
		    		
		    		if(_shov && mouse_press(mb_left, _focus))
		    			brush.brush_varient = brush.brush_varient == _variences[v]? 0 : _variences[v];
		    		
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
	    	
	    	var _tileSet = array_safe_get(current_data, 0);
	    	var _tileSiz = array_safe_get(current_data, 2);
	    	
	    	if(!is_surface(_tileSet)) return _h;
	    	var _tdim    = surface_get_dimension(_tileSet);
	    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
	    	
			var bx = _x;
			var by = _yy;
			var bs = ui(24);
			var _brush_tiles = brush.brush_width * brush.brush_height;
			var _fromSel = (_brush_tiles ==  9 || _brush_tiles == 15 || _brush_tiles == 48 || _brush_tiles == 55);
			
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, _fromSel? "New autotile from selection" : "New autotile", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
				var _new_at = noone;
				
				     if(_brush_tiles ==  9) _new_at = new tiler_brush_autotile(AUTOTILE_TYPE.box9,   array_spread(brush.brush_indices));
				else if(_brush_tiles == 15) _new_at = new tiler_brush_autotile(AUTOTILE_TYPE.side15, array_spread(brush.brush_indices));
				else if(_brush_tiles == 48) _new_at = new tiler_brush_autotile(AUTOTILE_TYPE.top48,  array_spread(brush.brush_indices));
				else if(_brush_tiles == 55) _new_at = new tiler_brush_autotile(AUTOTILE_TYPE.top55,  array_spread(brush.brush_indices));
				
				if(_new_at != noone) {
					autotile_selecting = array_length(autotiles);
					array_push(autotiles, _new_at);
					
					brush.brush_indices = [[ _new_at.index[0] ]];
	    			brush.brush_width   = 1;
					brush.brush_height  = 1;
				}
			}
			
			_h  += bs + ui(8);
			_yy += bs + ui(8);
			
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
		    				brush.brush_indices = [[ _prin ]];
			    			brush.brush_width   = 1;
		    				brush.brush_height  = 1;
		    				
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
				        shader_set_2("tileSize",  _tileSiz);
				        shader_set_2("tileAmo",   [ floor(_tileSetDim[0] / _tileSiz[0]), floor(_tileSetDim[1] / _tileSiz[1]) ]);
				        
				        shader_set_surface("tileTexture", _tileSet);
				        shader_set_2("tileTextureDim", _tileSetDim);
				        
				        shader_set_surface("indexTexture", _at.preview_surface);
				        shader_set_2("indexTextureDim", surface_get_dimension(_at.preview_surface));
				        
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
	    	
	    	autotile_selector_h = _ah;
    		return _h + _ah;
    	});
    #endregion
    
    #region ++++ brush palette ++++
    	brush_palette = surface_create(1, 1, surface_rgba16float);
    	
    	palette_viewer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
    		var _h = 0;
    		
    		return _h;
    	});
    #endregion
    
	input_display_list = [ 
		["Tileset",   false], 0, 2, 
		["Map",       false], 1, 
		["Tiles",     false], tile_selector, 
		["Autotiles", false], autotile_selector, 
		["Palette",   false], palette_viewer
	]
	
	newOutput(0, nodeValue_Output("Tile output", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Tile map", self, VALUE_TYPE.surface, noone));
	
	newOutput(2, nodeValue_Output("Index array", self, VALUE_TYPE.integer, []))
	    .setArrayDepth(1);
	
	#region ++++ data ++++
		canvas_surface   = surface_create_empty(1, 1, surface_rgba16float);
		canvas_buffer    = buffer_create(1 * 1 * 2, buffer_grow, 2);
	    
		drawing_surface  = noone;
		draw_stack       = ds_list_create();
		
		preview_drawing_tile      = surface_create_empty(1, 1);
		preview_draw_overlay      = surface_create_empty(1, 1);
		preview_draw_overlay_tile = surface_create_empty(1, 1);
		
		_preview_draw_mask        = surface_create_empty(1, 1);
		preview_draw_mask         = surface_create_empty(1, 1);
		
		attributes.dimension = [ 1, 1 ];
		temp_surface         = [ 0 ];
		
		selection_mask       = noone;
	#endregion
	
	#region ++++ selection ++++
		selecting   = false;
		selection_x = 0;
		selection_y = 0;
		
		selection_mask = noone;
	#endregion
	
	#region ++++ tool object ++++
		brush = new tiler_brush(self);
		
		tool_brush     = new tiler_tool_brush(self, brush, false);
		tool_eraser    = new tiler_tool_brush(self, brush, true);
		tool_fill      = new tiler_tool_fill( self, brush, tool_attribute);
		
		tool_rectangle = new tiler_tool_shape(self, brush, CANVAS_TOOL_SHAPE.rectangle);
		tool_ellipse   = new tiler_tool_shape(self, brush, CANVAS_TOOL_SHAPE.ellipse);
	#endregion
	
	#region ++++ tools ++++
		tool_attribute.size = 1;
		tool_size_edit      = new textBox(TEXTBOX_INPUT.number, function(val) { tool_attribute.size = max(1, round(val)); }).setSlideType(true)
									.setFont(f_p3)
									.setSideButton(button(function() { dialogPanelCall(new Panel_Node_Canvas_Pressure(self), mouse_mx, mouse_my, { anchor: ANCHOR.top | ANCHOR.left }) })
										.setIcon(THEME.pen_pressure, 0, COLORS._main_icon));
		tool_size           = [ "Size", tool_size_edit, "size", tool_attribute ];
		
		tool_attribute.fillType = 0;
		tool_fil8_edit      	= new buttonGroup( [ THEME.canvas_fill_type, THEME.canvas_fill_type, THEME.canvas_fill_type ], function(val) { tool_attribute.fillType = val; })
									.setTooltips( [ "Edge", "Edge + Corner" ] )
									.setCollape(false);
		tool_fil8           	= [ "Fill", tool_fil8_edit, "fillType", tool_attribute ];
		
		tools = [
			new NodeTool( "Pencil",		  THEME.canvas_tools_pencil)
				.setSetting(tool_size)
				.setToolObject(tool_brush),
			
			new NodeTool( "Eraser",		  THEME.canvas_tools_eraser)
				.setSetting(tool_size)
				.setToolObject(tool_eraser),
				
			new NodeTool( "Rectangle",	[ THEME.canvas_tools_rect_fill  ])
				.setSetting(tool_size)
				.setToolObject(tool_rectangle),
					
			new NodeTool( "Ellipse",	[ THEME.canvas_tools_ellip_fill ])
				.setSetting(tool_size)
				.setToolObject(tool_ellipse),
			
			new NodeTool( "Fill",		  THEME.canvas_tools_bucket)
				.setSetting(tool_fil8)
				.setToolObject(tool_fill),
		];
	#endregion
	
	function apply_draw_surface() {
		if(!is_surface(canvas_surface))  return;
		if(!is_surface(drawing_surface)) return;
		
		if(selecting) {
			surface_set_shader(canvas_surface, sh_draw_tile_apply_selection, true, BLEND.over);
				shader_set_surface("selectionMask", selection_mask);
				draw_surface(drawing_surface, 0, 0);
			surface_reset_shader();
			
		} else {
			surface_set_shader(canvas_surface, sh_draw_tile_apply, true, BLEND.over);
				draw_surface(drawing_surface, 0, 0);
			surface_reset_shader();
		}
		
		triggerRender();
	}
	
	function reset_surface(surface) {
		surface_set_shader(surface, noone, true, BLEND.over);
			draw_surface(canvas_surface, 0, 0);
		surface_reset_shader();
	}
	
    static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, params) {
        var _tileSet  = current_data[0];
        var _mapSize  = current_data[1];
    	var _tileSize = current_data[2];
	    
	    canvas_surface = surface_verify(canvas_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    
        if(!surface_valid(drawing_surface, _mapSize[0], _mapSize[1], surface_rgba16float)) {
        	drawing_surface = surface_verify(drawing_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    	
		    surface_set_shader(drawing_surface, noone, true, BLEND.over);
				draw_surface(canvas_surface, 0, 0);
			surface_reset_shader();
        }
        
	    #region surfaces
	    	var _dim      = attributes.dimension;
	    	var _outDim   = [ _tileSize[0] * _dim[0], _tileSize[1] * _dim[1] ];
	    	
			preview_draw_overlay = surface_verify(preview_draw_overlay, _dim[0], _dim[1], surface_rgba16float);
			preview_drawing_tile = surface_verify(preview_drawing_tile, _dim[0] * _tileSize[0], _dim[1] * _tileSize[1]);
			preview_draw_overlay_tile = surface_verify(preview_draw_overlay_tile, _dim[0] * _tileSize[0], _dim[1] * _tileSize[1]);
	    	
			var __s  = surface_get_target();
			var _sw  = surface_get_width(__s);
			var _sh  = surface_get_height(__s);
			
			_preview_draw_mask = surface_verify(_preview_draw_mask, _dim[0], _dim[1]);
			 preview_draw_mask = surface_verify( preview_draw_mask, _sw, _sh);
			
	    #endregion
	    
	    #region tools
	    	var _currTool = PANEL_PREVIEW.tool_current;
	    	var _tool     = _currTool == noone? noone : _currTool.getToolObject();
	    	
	    	brush.brush_size = tool_attribute.size;
	    	brush.autotiler  = autotile_selecting == noone? noone : array_safe_get(autotiles, autotile_selecting, noone);
	    	
			if(_tool) {
				_tool.subtool            = _currTool.selecting;
				_tool.apply_draw_surface = apply_draw_surface;
				_tool.drawing_surface    = drawing_surface;
				_tool.tile_size          = _tileSize;
				
				_tool.step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				
				surface_set_target(preview_draw_overlay);
					DRAW_CLEAR
					_tool.drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				surface_reset_target();
				
				surface_set_target(_preview_draw_mask);
					DRAW_CLEAR
					_tool.drawMask(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				surface_reset_target();
				
				surface_set_target(preview_draw_mask);
					DRAW_CLEAR
					draw_surface_ext(_preview_draw_mask, _x, _y, _s * _tileSize[0], _s * _tileSize[1], 0, c_white, 1);
				surface_reset_target();
				
				if(_tool.brush_resizable) { 
					if(hover && key_mod_press(CTRL)) {
						if(mouse_wheel_down()) tool_attribute.size = max( 1, tool_attribute.size - 1);
						if(mouse_wheel_up())   tool_attribute.size = min(64, tool_attribute.size + 1);
					}
					
					brush.sizing(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
				} 
			}
	    #endregion
	    
	    #region draw preview surfaces
			var _tileSetDim = surface_get_dimension(_tileSet);
	    	
		    surface_set_shader(preview_drawing_tile, sh_draw_tile_map, true, BLEND.over);
		        shader_set_2("dimension", _outDim);
		        shader_set_2("tileSize",  _tileSize);
		        shader_set_2("tileAmo",   [ floor(_tileSetDim[0] / _tileSize[0]), floor(_tileSetDim[1] / _tileSize[1]) ]);
		        
		        shader_set_surface("tileTexture", _tileSet);
		        shader_set_2("tileTextureDim", _tileSetDim);
		        
		        shader_set_surface("indexTexture", drawing_surface);
		        shader_set_2("indexTextureDim", surface_get_dimension(drawing_surface));
		        
		        draw_empty();
		    surface_reset_shader();
		    
	    	draw_surface_ext(preview_drawing_tile, _x, _y, _s, _s, 0, c_white, 1);
	    	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	    	
		    surface_set_shader(preview_draw_overlay_tile, sh_draw_tile_map, true, BLEND.over);
		        shader_set_2("dimension", _outDim);
		        shader_set_2("tileSize",  _tileSize);
		        shader_set_2("tileAmo",   [ floor(_tileSetDim[0] / _tileSize[0]), floor(_tileSetDim[1] / _tileSize[1]) ]);
		        
		        shader_set_surface("tileTexture", _tileSet);
		        shader_set_2("tileTextureDim", _tileSetDim);
		        
		        shader_set_surface("indexTexture", preview_draw_overlay);
		        shader_set_2("indexTextureDim", surface_get_dimension(preview_draw_overlay));
		        
		        draw_empty();
		    surface_reset_shader();
		    
	    	draw_surface_ext(preview_draw_overlay_tile, _x, _y, _s, _s, 0, c_white, 1);
	    	
	    	params.panel.drawNodeGrid();
	    	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	    	
			shader_set(sh_brush_outline);
				shader_set_f("dimension", _sw, _sh);
				draw_surface(preview_draw_mask, 0, 0);
			shader_reset();
			
	    #endregion
	    
	    //if(!array_empty(autotiles)) draw_surface_ext(autotiles[0].mask_surface, 32, 32, 8, 8, 0, c_white, 1);
	    // draw_surface_ext(canvas_surface,   32, 32, 8, 8, 0, c_white, 1);
	    // draw_surface_ext(drawing_surface, 232, 32, 8, 8, 0, c_white, 1);
	    // draw_surface_ext(preview_draw_overlay, 432, 32, 8, 8, 0, c_white, 1);
    }
    
	static processData = function(_outData, _data, _output_index, _array_index) {
	    var _tileSet  = _data[0];
	    var _mapSize  = _data[1];
	    var _tileSize = _data[2];
	    
	    attributes.dimension[0] = _mapSize[0];
	    attributes.dimension[1] = _mapSize[1];
	    
	    //print($"{canvas_surface} [{is_surface(canvas_surface)}] : {drawing_surface} [{is_surface(drawing_surface)}]");
	    
	    if(!is_surface(canvas_surface) && buffer_exists(canvas_buffer)) {
	    	canvas_surface = surface_create(_mapSize[0], _mapSize[1], surface_rgba16float);
	    	buffer_set_surface(canvas_buffer, canvas_surface, 0);
	    } else 
	    	canvas_surface = surface_verify(canvas_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    drawing_surface = surface_verify(drawing_surface, _mapSize[0], _mapSize[1], surface_rgba16float);
	    
	    surface_set_shader(drawing_surface, noone, true, BLEND.over);
			draw_surface(canvas_surface, 0, 0);
		surface_reset_shader();
		
	    if(!is_surface(_tileSet)) return _outData;
	    
	    var _tileOut = _outData[0];
	    var _tileMap = _outData[1];
	    var _arrIndx = _outData[2];
	    
	    var _outDim   = [ _tileSize[0] * _mapSize[0], _tileSize[1] * _mapSize[1] ];
	    
	    _tileOut = surface_verify(_tileOut, _outDim[0],  _outDim[1]);
	    _tileMap = surface_verify(_tileMap, _mapSize[0], _mapSize[1], surface_rgba16float);
	    _arrIndx = array_verify(_arrIndx, _mapSize[0] * _mapSize[1]);
	    
	    buffer_resize(canvas_buffer, _mapSize[0] * _mapSize[1] * 2);
	    buffer_get_surface(canvas_buffer, canvas_surface, 0);
	    
	    surface_set_shader(_tileMap, sh_sample, true, BLEND.over);
	        draw_surface(canvas_surface, 0, 0);
	    surface_reset_shader();
	    
	    var _tileSetDim = surface_get_dimension(_tileSet);
	    
	    surface_set_shader(_tileOut, sh_draw_tile_map, true, BLEND.over);
	        shader_set_2("dimension", _outDim);
	        shader_set_2("tileSize",  _tileSize);
	        shader_set_2("tileAmo",   [ floor(_tileSetDim[0] / _tileSize[0]), floor(_tileSetDim[1] / _tileSize[1]) ]);
	        
	        shader_set_surface("tileTexture", _tileSet);
	        shader_set_2("tileTextureDim", _tileSetDim);
	        
	        shader_set_surface("indexTexture", _tileMap);
	        shader_set_2("indexTextureDim", surface_get_dimension(_tileMap));
	        
	        draw_empty();
	    surface_reset_shader();
	    
	    return [ _tileOut, _tileMap, _arrIndx ];
	}
	
    static getPreviewValues       = function() { return preview_drawing_tile; }
    static getGraphPreviewSurface = function() { return getSingleValue(0, preview_index, true); }
	
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
	static doSerialize = function(_map) {
		_map.surface = buffer_serialize(canvas_buffer);
	}
	
	static doApplyDeserialize = function() {
	     canvas_buffer   = buffer_deserialize(load_map.surface);
	     canvas_surface  = surface_verify(canvas_surface,  attributes.dimension[0], attributes.dimension[1], surface_rgba16float);
	     drawing_surface = surface_verify(drawing_surface, attributes.dimension[0], attributes.dimension[1], surface_rgba16float);
	     
	     buffer_set_surface(canvas_buffer, canvas_surface,  0);
	     buffer_set_surface(canvas_buffer, drawing_surface, 0);
	}
	
	static attributeSerialize = function() {
		var _attr = {
			autotiles, 
			canvas:  buffer_from_surface(canvas_surface),
			palette: buffer_from_surface(brush_palette),
		};
		
		return _attr; 
	}
	
	static attributeDeserialize = function(attr) {
		var _auto = struct_try_get(attr, "autotiles", []);
		var _canv = struct_try_get(attr, "canvas",  noone);
		var _palt = struct_try_get(attr, "palette", noone);
		
		for( var i = 0, n = array_length(_auto); i < n; i++ ) {
			autotiles[i] = new tiler_brush_autotile(_auto[i].type, _auto[i].index);
			autotiles[i].name = _auto[i].name;
		}
		
		if(_canv) {
			surface_free_safe(canvas_surface);
			canvas_surface = surface_from_buffer(_canv);
		}
		
		if(_palt) {
			surface_free_safe(brush_palette);
			brush_palette = surface_from_buffer(_canv);
		}
	}
}