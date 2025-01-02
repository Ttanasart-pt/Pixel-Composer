function Node_Tile_Tileset(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
    name        = "Tileset";
    bypass_grid = true;
    preserve_height_for_preview = true;
    
    node_edit      = noone;
    renaming       = noone;
	rename_text    = "";
	tb_rename      = new textBox(TEXTBOX_INPUT.text, function(_name) { 
		if(renaming == noone) return;
		renaming.name  = _name;
		renaming       = noone;
	});
	tb_rename.font = f_p2;
	tb_rename.hide = true;
	
    gmTile     = noone;
    texture    = noone;
    tileSize   = [ 1, 1 ];
    tileAmount = [ 1, 1 ];
	rules      = new Tileset_Rule(self);
    
    newInput( 0, nodeValue_Surface("Texture", self, noone));
    
    newInput( 1, nodeValue_Vec2("Tile size", self, [ 16, 16 ]));
    
	newOutput(0, nodeValue_Output("Tileset", self, VALUE_TYPE.tileset, self));
	
	function drawTile(index, _x, _y, _w, _h) {
		if(index < -1) { // animated
			var _an = -index - 2;
			var _at = array_safe_get(animatedTiles, _an, noone);
			if(_at == noone) return;
			
			var _prin = array_safe_get(_at.index, safe_mod(current_time / 1000 * 2, array_length(_at.index)), undefined);
			if(_prin != undefined) drawTile(_prin, _x, _y, _w, _h);
			return;
		}
		
		var _prc = safe_mod(index, tileAmount[0]);
		var _prr = floor(index / tileAmount[0]);
		
		var _pr_tx = _prc * tileSize[0];
		var _pr_ty = _prr * tileSize[1];
		
		var _pr_sx = _w / tileSize[0];
		var _pr_sy = _h / tileSize[1];
		
		draw_surface_part_ext(texture, _pr_tx, _pr_ty, tileSize[0], tileSize[1], _x, _y, _pr_sx, _pr_sy, c_white, 1);
	}
	
	static setPencil = function() {
		var _n = PANEL_INSPECTOR.getInspecting(); 
		if(!is(_n, Node_Tile_Drawer)) return;
		if(PANEL_PREVIEW.tool_current != _n.tool_pencil) 
			_n.tool_pencil.toggle();
	}
	
	////- Tile selector
	#region Tile selector
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
	    
	    tile_zoom_drag = false;
	    tile_zoom_mx   = noone;
	    tile_zoom_sx   = noone;
	    
	    object_selecting = noone;
	    object_select_id = noone;
	    
	    selecting_surface      = noone;
	    selecting_surface_tile = noone;
	    
	    autoterrain_selector_mask = 0;
	    
	    grid_draw = true;
	    brush     = new tiler_brush(self);
	    
	    tile_selector = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) { 
	    	var _tileSet = texture;
	    	var _tileSiz = tileSize;
	    	
	    	var _pd  = ui(4);
	    	var _yy  = _y;
	    	var _tsh = tile_selector.fixHeight > 0? tile_selector.fixHeight - ui(24 + 4 + 48 + 8) : tile_selector_h;
			var _h   = _tsh;
	    	
			#region top bar
				var bx = _x;
				var by = _yy;
				var bs = ui(24);
				
				if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "Clear selection", THEME.canvas_tools_selection_rectangle, 0, COLORS._main_icon_light) == 2) {
					brush.brush_indices = [[]];
					brush.brush_width   = 0;
					brush.brush_height  = 0;
				}
				
				var _lx = bx + bs + ui(8);
				
				bx = _x + _w - bs;
				if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "Zoom to fit", THEME.path_tools_transform, 0, COLORS._main_icon_light) == 2) {
				    if(is_surface(_tileSet)) {
				        var _tdim = surface_get_dimension(_tileSet);
						var _sw   = _w - _pd * 2;
			    	    var _sh   = _tsh - _pd * 2;
			    	    
			    	    var _ss = min(_sw / (_tdim[0] + 16), _sh / (_tdim[1] + 16));
			    	    tile_selector_s    = _ss;
			    	    tile_selector_s_to = _ss;
			    	    
			    	    tile_selector_x =   _w / 2 - _tdim[0] * _ss / 2;
		                tile_selector_y = _tsh / 2 - _tdim[1] * _ss / 2;
				    }
				}
				
				var _rx = bx - ui(8);
				
				var _zw  = ui(128);
				var _zh  = ui(12);
				var _zx1 = _rx;
				var _zx0 = max(_lx, _zx1 - _zw);
				    _zw  = _zx1 - _zx0;
				var _zy  = by + bs / 2 - _zh / 2;
				
				if(_zw) { //zoom
					var _zcc = (tile_selector_s_to - 0.5) / 3.5;
					var _zcw = _zw * _zcc;
					
					draw_sprite_stretched_ext(THEME.textbox, 3, _zx0, _zy, _zw,  _zh, c_white, 1);
					draw_sprite_stretched_ext(THEME.textbox, 4, _zx0, _zy, _zcw, _zh, c_white, 1);
					
					if(_hover && point_in_rectangle(_m[0], _m[1], _zx0, _zy, _zx0 + _zw, _zy + _zh)) {
						draw_sprite_stretched_ext(THEME.textbox, 1, _zx0, _zy, _zw,  _zh, c_white, 1);
						
						if(mouse_press(mb_left, _focus)) {
							tile_zoom_drag = true;
						    tile_zoom_mx   = _m[0];
						    tile_zoom_sx   = tile_selector_s_to;
						}
					}
					
					if(tile_zoom_drag) {
						var _zl = clamp(tile_zoom_sx + (_m[0] - tile_zoom_mx) / _zw * 3.5, .5, 4);
						
						var _s = tile_selector_s;
						tile_selector_s_to = _zl;
						tile_selector_s    = _zl;
						
						if(_s != tile_selector_s) {
			    			var _ds  = tile_selector_s - _s;
			    			
					    	var _msx = (_w   / 2 - _pd) - tile_selector_x;
					    	var _msy = (_tsh / 2 - _pd) - tile_selector_y;
					    	
			    			tile_selector_x -= _msx * _ds / _s;
			    			tile_selector_y -= _msy * _ds / _s;
			    		}
			    		
						if(mouse_release(mb_left)) 
							tile_zoom_drag = false;
					}
				}
			#endregion
			
			#region draw tile surface
				_h  += bs + ui(4);
				_yy += bs + ui(4);
				
		    	var _sx = _x + _pd;
		    	var _sy = _yy + _pd;
		    	var _sw = _w - _pd * 2;
		    	var _sh = _tsh - _pd * 2;
		    	
		    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, _tsh, COLORS.node_composite_bg_blend, 1);
		    	tile_selector_surface  = surface_verify(tile_selector_surface,  _sw, _sh);
		    	tile_selector_mask     = surface_verify(tile_selector_mask,     _sw, _sh);
		    	autoterrain_selector_mask = surface_verify(autoterrain_selector_mask, _sw, _sh);
		    	
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
		    	var _bg0 = colorMultiply(COLORS.panel_bg_clear, COLORS.node_composite_bg_blend);
		    	var _bg1 = colorMultiply(COLORS.panel_preview_transparent, COLORS.node_composite_bg_blend);
		    	
		    	surface_set_target(tile_selector_surface); 
				draw_clear(_bg0);
				draw_sprite_tiled_ext(s_transparent, 0, tile_selector_x, tile_selector_y, tile_selector_s, tile_selector_s, _bg1, 1);
				
				draw_surface_ext(_tileSet, tile_selector_x, tile_selector_y, tile_selector_s, tile_selector_s, 0, c_white, 1);
				
				if(gmTile != noone) {
					var ssw = _tileSel_w / 16; 
					var ssh = _tileSel_h / 16; // non uniform tile size anyone?
					draw_sprite_ext(s_transparent, 0, tile_selector_x + _tileSel_w / 2, tile_selector_y + _tileSel_h / 2, -ssw, ssh, 0, _bg0);
					draw_sprite_ext(s_transparent, 0, tile_selector_x + _tileSel_w / 2, tile_selector_y + _tileSel_h / 2,  ssw, ssh, 0, _bg1);
				}
				
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
		    		
		    		     if(is(object_selecting, tiler_brush_autoterrain) && object_select_id != noone) TOOLTIP = "Set Autoterrain";
					else if(is(object_selecting, tiler_brush_animated)    && object_select_id != noone) TOOLTIP = "Set Animated tile";
					else if(is(object_selecting, tiler_rule)              && object_select_id != noone) TOOLTIP = "Set Rule selector";
					else if(is(object_selecting, tiler_rule_replacement))  TOOLTIP = "Set Rule replacement";
					else if(is(object_selecting, tilemap_convert_object))  TOOLTIP = "Set Replacement target";
					
					if(mouse_press(mb_left, _focus)) {
						if((is(object_selecting, tiler_brush_autoterrain) || is(object_selecting, tiler_brush_animated)) && object_select_id != noone) {
							object_selecting.index[object_select_id] = _mid;
							do { object_select_id++; } until(object_select_id == array_length(object_selecting.index) || object_selecting.index[object_select_id] == -1)
		    				if(object_select_id >= array_length(object_selecting.index))
		    					object_select_id = noone;
							
						} else if(is(object_selecting, tiler_rule)) {
							if(object_select_id != noone)
								object_selecting.selection_rules[object_select_id] = _mid;
							object_selecting = noone;
							triggerRender();
							
						} else if(is(object_selecting, tiler_rule_replacement)) {
							tile_selecting = true;
		    				tile_select_ss = [ _mtx, _mty ];
							
						} else if(is(object_selecting, tilemap_convert_object)) {
							object_selecting.target = _mid;
							object_selecting = noone;
							if(node_edit) node_edit.triggerRender();
							
						} else {
							object_selecting = noone;
							object_select_id = noone;
							tile_selecting   = true;
		    				tile_select_ss   = [ _mtx, _mty ];
		    				
						}
						
		    			palette_using = false;
					}
				}
		    	surface_reset_target();
			#endregion
		    	
			#region draw selector mask
		    	surface_set_target(tile_selector_mask);
		    		DRAW_CLEAR
		    		draw_set_color(c_white);
		    		
		    		for( var i = 0, n = array_length(brush.brush_indices);    i < n; i++ ) 
		    		for( var j = 0, m = array_length(brush.brush_indices[i]); j < m; j++ ) {
		    			var _bindex = floor(brush.brush_indices[i][j][0]);
		    			
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
					
					for( var i = _ts_sy; i <= _ts_ey; i++ ) 
					for( var j = _ts_sx; j <= _ts_ex; j++ )
						brush.brush_indices[i - _ts_sy][j - _ts_sx] = [ i * _tileAmo[0] + j, 0 ];
						
					if(mouse_release(mb_left)) {
						if(is(object_selecting, tiler_rule_replacement)) {
							object_select_id.size[0] = max(object_select_id.size[0], brush.brush_width);
							object_select_id.size[1] = max(object_select_id.size[1], brush.brush_height);
							
							var _ind = 0;
							for( var i = _ts_sy; i <= _ts_ey; i++ ) 
							for( var j = _ts_sx; j <= _ts_ex; j++ )
								object_selecting.index[_ind++] = i * _tileAmo[0] + j;
							object_selecting = noone;
							object_select_id = noone;
							triggerRender();
							
		    			}
		    			
		    			setPencil();
		    			tile_selecting = false;
					}
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
		    	
		    #region misc
				shader_set(sh_brush_outline);
					var _brush_tiles = brush.brush_width * brush.brush_height;
					var _cc = c_white;
					if(_brush_tiles == 9 || _brush_tiles == 15 || _brush_tiles == 48 || _brush_tiles == 55) _cc = COLORS._main_value_positive;
					
					shader_set_f("dimension", _sw, _sh);
					draw_surface_ext(tile_selector_mask, _sx, _sy, 1, 1, 0, _cc, 1);
				shader_reset();
				
				if(is(object_selecting, tiler_brush_autoterrain)) { // autoterrain
			    	surface_set_target(autoterrain_selector_mask);
			    		DRAW_CLEAR
			    		
			    		draw_set_color(c_white);
			    		for( var j = 0, m = array_length(object_selecting.index); j < m; j++ ) {
			    			var _bindex = object_selecting.index[j];
			    			if(_bindex < 0) continue;
		    				
					    	var _tileSel_row = floor(_bindex / _tileAmo[0]);
					    	var _tileSel_col = safe_mod(_bindex, _tileAmo[0]);
				    		var _tileSel_x   = tile_selector_x + _tileSel_col * _tileSiz[0] * tile_selector_s;
				    		var _tileSel_y   = tile_selector_y + _tileSel_row * _tileSiz[1] * tile_selector_s;
				    		draw_rectangle(_tileSel_x, _tileSel_y, _tileSel_x + _tileSel_w, _tileSel_y + _tileSel_h, false);
			    		}
			    	surface_reset_target();
			    	
					shader_set(sh_brush_outline);
						shader_set_f("dimension", _sw, _sh);
						draw_surface_ext(autoterrain_selector_mask, _sx, _sy, 1, 1, 0, COLORS._main_accent, 1);
					shader_reset();
				}
			#endregion
				
			#region varients
				var _bw = 1;
				var _bh = 1;
				var _sel_sw = _tileSiz[0];
				var _sel_sh = _tileSiz[1];
				
				selecting_surface      = surface_verify(selecting_surface, _bw, _bh, surface_rgba16float);
		    	selecting_surface_tile = surface_verify(selecting_surface_tile, _sel_sw, _sel_sh);
		    	
				var _ty = _yy + _tsh + ui(8);
				
				var _sx =  _x + ui(8);
				var _sy = _ty + ui(8);
				
				var _ss = ui(32) / _sel_sh;
				var _sw = _ss * _sel_sw;
				var _sh = _ss * _sel_sh;
				
		    	var _vv  = [ 0, 0b0011, 0b0010, 0b0001, 0b0100, 0b0111, 0b0110, 0b0101 ];
				var  p   = array_length(_vv)
				var _col = max(1, floor((_w - ui(8)) / (_sw + ui(8))));
				var _row = brush.brush_width * brush.brush_height == 1? ceil((p + 1) / _col) : 1;
				
				var _th = ui(8) + (_sh + ui(8)) * _row;
				_h += ui(8) + _th;
				
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _ty, _w, _th, COLORS.node_composite_bg_blend, 1);
				
				var _shov = _hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _sw, _sy + _sh);
				var _aa   = 0.5 + 0.5 * _shov;
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _sx, _sy, _sw, _sh, COLORS._main_icon, _aa);
				draw_sprite_uniform(THEME.cross, 0, _sx + _sw / 2, _sy + _sh / 2, 1, COLORS._main_icon, _aa);
				
				if(_shov) {
					if(object_selecting == noone) {
						if(mouse_press(mb_left, _focus)) {
							brush.brush_indices = [[[ -1, 0 ]]];
			    			brush.brush_width   = 1;
							brush.brush_height  = 1;
						}
						
					} else if(is(object_selecting, tiler_rule)) {
						TOOLTIP = "Set Rule selector";
						
						if(mouse_press(mb_left, _focus)) {
							if(object_select_id != noone)
								object_selecting.selection_rules[object_select_id] = -10000;
							object_selecting = noone;
							triggerRender();
							
						}
					}
				}
				
				_sx += _sw + ui(8);
				
				if(brush.brush_width * brush.brush_height != 1) return _h;
				
				var _bb = brush.brush_indices[0][0];
				var _vi = 1;
				
				for( var v = 0; v < p; v++ ) {
					var _var = _vv[v];
					
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
		    		
		    		var _shov = _hover && point_in_rectangle(_m[0], _m[1], _sx, _sy, _sx + _sw, _sy + _sh);
		    		var _aa   = _bb[1] == _var? 1 : 0.5 + 0.5 * _shov;
		    		
		    		draw_surface_ext(selecting_surface_tile, _sx, _sy, _ss, _ss, 0, c_white, _aa);
		    		
		    		if(_bb[1] == _var)
		    			draw_sprite_stretched_ext(THEME.ui_panel, 1, _sx, _sy, _sw, _sh, COLORS._main_accent);
		    		
		    		if(_shov && mouse_press(mb_left, _focus))
		    			_bb[1] = _var;
		    		
					_sx += _sw + ui(8);
					if(++_vi >= _col) {
						_sx  = _x + ui(8);
						_sy += _sh + ui(8);
						_vi  = 0;
					}
				}
			#endregion
		    	
	    	return _h;
	    });
	    
	    tile_selector.setName("Tileset");
	#endregion
    
    ////- Auto terrain
    #region Auto terrain
    	autoterrain = [];
		autoterrain_selector_h = 0;
		
    	autoterrain_selector = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) { 
	    	var _yy = _y;
	    	var _h  = 0;
	    	
	    	var _tileSet = texture;
	    	var _tileSiz = tileSize;
	    	
	    	if(!is_surface(_tileSet)) return _h;
	    	var _tdim    = surface_get_dimension(_tileSet);
	    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
	    	
	    	#region top bar
				var bx = _x;
				var by = _yy;
				var bs = ui(24);
				var _brush_tiles = brush.brush_width * brush.brush_height;
				var _fromSel = _brush_tiles ==  9 || _brush_tiles == 15 || _brush_tiles == 25 ||_brush_tiles == 48 || _brush_tiles == 55;
				
				var _txt = _fromSel? "New autoterrain from selection" : "New autoterrain";
				if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, _txt, THEME.add_16, 0, COLORS._main_value_positive) == 2) {
					var _new_at = noone;
					var _indx   = array_create(brush.brush_width * brush.brush_height);
					
					for( var i = 0, n = brush.brush_height; i < n; i++ ) 
		    		for( var j = 0, m = brush.brush_width;  j < m; j++ ) 
		    			_indx[i * brush.brush_width + j] = brush.brush_indices[i][j][0];
		    		
					     if(_brush_tiles ==  9) _new_at = new tiler_brush_autoterrain(AUTOTERRAIN_TYPE.box9,   _indx);
					else if(_brush_tiles == 25) _new_at = new tiler_brush_autoterrain(AUTOTERRAIN_TYPE.box25,  _indx);
					else if(_brush_tiles == 15) _new_at = new tiler_brush_autoterrain(AUTOTERRAIN_TYPE.side15, _indx);
					else if(_brush_tiles == 48) _new_at = new tiler_brush_autoterrain(AUTOTERRAIN_TYPE.top48,  _indx);
					else if(_brush_tiles == 55) _new_at = new tiler_brush_autoterrain(AUTOTERRAIN_TYPE.top55,  _indx);
					else                        _new_at = new tiler_brush_autoterrain(AUTOTERRAIN_TYPE.box9,   _indx);
					
					object_selecting = _new_at;
					object_select_id = noone;
					array_push(autoterrain, _new_at);
					
					if(!array_empty(_indx)) {
						brush.brush_indices = [[ [ _new_at.index[0], 0 ] ]];
		    			brush.brush_width   = 1;
						brush.brush_height  = 1;
					}
				}
			#endregion
			
			_h  += bs + ui(4);
			_yy += bs + ui(4);
			
	    	var _pd = ui(4);
	    	var _ah = _pd * 2;
	    	var del = -1;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, autoterrain_selector_h, COLORS.node_composite_bg_blend, 1);
	    	
	    	_yy += _pd;
	    	
	    	for( var i = 0, n = array_length(autoterrain); i < n; i++ ) {
	    		var _hg = ui(32);
	    		var _at = autoterrain[i];
	    		
	    		var _pw = ui(24);
	    		var _ph = ui(24);
	    		var _px = _x + ui(8);
	    		var _py = _yy + ui(4);
	    		
	    		#region header
	    		var _prin = array_safe_get(_at.index, _at.prevInd, undefined);
	    		
	    		if(_prin == undefined) draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _pw, _ph, COLORS._main_icon);
	    		else drawTile(_prin, _px, _py, _pw, _ph);
	    		
	    		var _tx  = _px + _pw + ui(8);
	    		var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _hg - 1);
	    		var _cc  = object_selecting == _at? COLORS._main_accent : (_hov? COLORS._main_text : COLORS._main_text_sub);
	    		
	    		if(renaming == _at) {
					tb_rename.setFocusHover(_focus, _hover);
					tb_rename.draw(_tx, _yy, _w - _pw - ui(8), _hg, rename_text, _m);
				
				} else {
		    		draw_set_text(f_p2, fa_left, fa_center, _cc);
		    		draw_text_add(_tx, _yy + _hg / 2, _at.name);
		    		
		    		var bs = ui(24);
					var bx = _w  - bs - ui(4);
					var by = _yy + _hg / 2 - bs / 2;
					var bc = _hov? COLORS._main_value_negative : COLORS._main_icon;
					
					if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, bc) == 2) 
						del = i;
				}
				
	    		if(_hov && _m[0] < _x + _w - ui(32)) {
	    			if(is(object_selecting, tiler_rule)) {
	    				TOOLTIP = "Set Rule selector";
	    				
	    				if(mouse_press(mb_left, _focus)) {
		    				if(object_select_id != noone)
	    						object_selecting.selection_rules[object_select_id] = [ "terrain", i ];
							object_selecting = noone;
	    					triggerRender();
	    				}
	    				
	    			} else if(is(object_selecting, tilemap_convert_object)) {
	    				TOOLTIP = "Set Replacement target";
	    			
	    				if(mouse_press(mb_left, _focus)) {
		    				object_selecting.target = [ "terrain", i ];
							object_selecting = noone;
							if(node_edit) node_edit.triggerRender();
	    				}
	    				
	    			} else if(_m[0] > _tx) {
		    			if(DOUBLE_CLICK && _focus) {
							renaming    = _at;
							rename_text = _at.name;
							
							tb_rename._current_text = _at.name;
							tb_rename.activate();
		    				
		    			} else if(mouse_press(mb_left, _focus)) {
		    				object_selecting = object_selecting == _at? noone : _at;
			    			object_select_id = noone;
			    			
		    				brush.brush_indices = [[ [ _prin, 0 ] ]];
			    			brush.brush_width   = 1;
		    				brush.brush_height  = 1;
		    				palette_using = false;
		    				
		    				setPencil();
		    			}
	    			} else {
	    				draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _pw, _ph, COLORS._main_accent);
		    			
		    			if(mouse_press(mb_left, _focus))
		    				_at.open = !_at.open;
	    			}
	    		}
	    		
	    		_yy += _hg;
	    		_ah += _hg;
	    		#endregion
	    		
	    		if(!_at.open) continue;
	    		
	    		#region content
	    		_yy += ui(4);
	    		_ah += ui(4);
	    		
	    		var _atWid = _at.sc_type;
	    		var _scx = _x + ui(8);
	    		var _scy = _yy;
	    		var _scw = ui(200);
	    		var _sch = ui(24);
	    		
	    		_atWid.setFocusHover(_focus, _hover);
	    		_atWid.draw(_scx, _scy, _scw, _sch, _at.type, _m, autoterrain_selector.rx, autoterrain_selector.ry);
	    		
	    		_yy += _sch + ui(8);
	    		_ah += _sch + ui(8);
	    		
    			var _atIdx = _at.index;
    			var _coll  = floor(_w - ui(16)) / _tileSiz[0];
    			var _over  = noone;
    			var _roww;
    			
    			switch(_at.type) {
    				case AUTOTERRAIN_TYPE.box9   : _coll =  3; _roww = 3; _over = s_autoterrain_3x3;  break;
    				case AUTOTERRAIN_TYPE.box25  : _coll =  5; _roww = 5; _over = s_autoterrain_5x5;  break;
    				case AUTOTERRAIN_TYPE.side15 : _coll =  5; _roww = 3; _over = s_autoterrain_5x3;  break;
    				case AUTOTERRAIN_TYPE.top48  : _coll = 12; _roww = 4; _over = s_autoterrain_8x6;  break;
    				case AUTOTERRAIN_TYPE.top55  : _coll = 11; _roww = 5; _over = s_autoterrain_11x5; break;
    			}
    			
    			var _pre_sx = _x + ui(8);
    			var _pre_sy = _yy;
    			var _pre_sw = _coll * _tileSiz[0];
    			var _pre_sh = _roww * _tileSiz[1];
    			
    			var _ss = min((_w - ui(16)) / _pre_sw, ui(64) / _tileSiz[1]);
    			
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
    			    	
			    surface_set_shader(_at.preview_surface_tile, sh_draw_tile_map, true, BLEND.over);
			        shader_set_2("dimension", surface_get_dimension(_at.preview_surface_tile));
			        
			        shader_set_surface("indexTexture", _at.preview_surface);
			        shader_set_2("indexTextureDim", surface_get_dimension(_at.preview_surface));
			        
					shader_submit();
					
			        draw_empty();
			    surface_reset_shader();
    			
    			if(_over != noone) draw_sprite_ext(_over, 0, _pre_sx, _pre_sy, _ss * _tileSiz[0] / 4, _ss * _tileSiz[1] / 4, 0, COLORS._main_icon, 0.5);
	    		draw_surface_ext(_at.preview_surface_tile, _pre_sx, _pre_sy, _ss, _ss, 0, c_white, 1);
    			
    			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text);
    			BLEND_ADD
    			for( var iy = 0; iy < _roww; iy++ ) 
    			for( var ix = 0; ix < _coll; ix++ ) {
    				var _indx = iy * _coll + ix;
    				var _inx  = _pre_sx + ix * _ss * _tileSiz[0];
    				var _iny  = _pre_sy + iy * _ss * _tileSiz[1];
    				
    				draw_text(_inx + 4, _iny + 4, _indx);
    			}
    			BLEND_NORMAL
    			
	    		if(grid_draw) {
	    			var _gw = _tileSiz[0] * _ss;
			        var _gh = _tileSiz[1] * _ss;
			        
			        var gw = _pre_sw / _tileSiz[0];
			        var gh = _pre_sh / _tileSiz[1];
			    	
			        var cx = _pre_sx - 1;
			        var cy = _pre_sy - 1;
			    
			        draw_set_color(PROJECT.previewGrid.color);
			        draw_set_alpha(PROJECT.previewGrid.opacity);
			        
			        for( var j = 1; j < gw; j++ ) {
			            var _lxx = cx + j * _gw;
			            draw_line(_lxx, cy, _lxx, cy + _pre_sh * _ss);
			        }
			    
			        for( var j = 1; j < gh; j++ ) {
			            var _lyy = cy + j * _gh;
			            draw_line(cx, _lyy, cx + _pre_sw * _ss, _lyy);
			        }
			        
			        draw_set_alpha(1);
	    		}
	    		
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
							object_selecting = _at;
							object_select_id = object_select_id == _at_id? noone : _at_id;
    					}
    					
    					if(mouse_press(mb_right, _focus))
    						_at.index[_at_id] = -1;
    				}
    			}
    			
    			if(object_selecting == _at && object_select_id != noone) {
    				var _at_sl_x = object_select_id % _coll;
    				var _at_sl_y = floor(object_select_id / _coll);
    				
    				var _at_c_sx = _pre_sx + _at_sl_x * _dtile_w;
					var _at_c_sy = _pre_sy + _at_sl_y * _dtile_h;
					
					draw_set_color(COLORS._main_accent);
					draw_rectangle(_at_c_sx, _at_c_sy, _at_c_sx + _dtile_w, _at_c_sy + _dtile_h, true);
    			}
    			
    			_yy += _pre_sh * _ss + ui(4);
	    		_ah += _pre_sh * _ss + ui(4);
	    		#endregion
	    	}
	    	
	    	if(del != -1) {
	    		array_delete(autoterrain, del, 1);
	    		object_selecting = noone;
	    		object_select_id = noone;
	    	}
	    	
	    	autoterrain_selector_h = max(ui(12), _ah);
    		return _h + _ah;
    	});
    	
    	autoterrain_selector.setName("Autoterrain");
    #endregion
    
    ////- Brush palette
    #region Brush palette
    	brush_palette_h    = ui(320);
    	
    	brush_palette           = surface_create(64, 64, surface_rgba16float);
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
	    	
	    	var _tileSet = texture;
	    	var _tileSiz = tileSize;
	    	
	    	#region top bar
			var bx = _x;
			var by = _yy;
			var bs = ui(24);
			
			var _tsh = palette_viewer.fixHeight > 0? palette_viewer.fixHeight - ui(24 + 4) : brush_palette_h;
			
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "Pencil", THEME.canvas_tools_pencil, 0, palette_tool == 1? COLORS._main_accent : c_white) == 2)
				palette_tool = palette_tool == 1? 0 : 1;
			
			draw_sprite_ui_uniform(THEME.canvas_tools_pencil, 1, bx + bs / 2, by + bs / 2, 1, palette_tool == 1? COLORS._main_accent : c_white);
			
			bx += bs + ui(4);
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "Eraser", THEME.canvas_tools_eraser, 0, palette_tool == 2? COLORS._main_accent : c_white) == 2) 
				palette_tool = palette_tool == 2? 0 : 2;
			
			bx = _x + _w - bs;
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "Zoom to fit", THEME.path_tools_transform, 0, COLORS._main_icon_light) == 2) {
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
			#endregion
			
	    	var _sx = _x  + _pd;
	    	var _sy = _yy + _pd;
	    	var _sw = _w  - _pd * 2;
	    	var _sh = _tsh - _pd * 2;
	    	
	    	_h += _tsh;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, _tsh, COLORS.node_composite_bg_blend, 1);
	    	palette_selector_surface  = surface_verify(palette_selector_surface,  _sw, _sh);
	    	palette_selector_mask     = surface_verify(palette_selector_mask,     _sw, _sh);
	    	
	    	#region draw palette
	    	if(!is_surface(_tileSet))      return _h;
	    	if(!is_surface(brush_palette)) {
	    		if(brush_palette_buffer && buffer_exists(brush_palette_buffer))
	    			brush_palette = surface_from_buffer(brush_palette_buffer);
	    		else 
	    			brush_palette = surface_create(64, 64, surface_rgba16float);
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
			    	
			        var cx = palette_selector_x - 1;
			        var cy = palette_selector_y - 1;
			    
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
		    			object_selecting = noone;
		    			object_select_id = noone;
		    			
	    				palette_selecting  = true;
	    				palette_using      = true;
	    				palette_select_ss  = [ _mtx, _mty ];
	    			}
	    		}
	    	surface_reset_target();
	    	#endregion
	    	
	    	#region selection
    		if(palette_selecting) {
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
    		#endregion
	    	
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
			#region // pencil tool
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
    		#endregion
		    	
			} else if(palette_tool == 2) { 
			#region eraser tool
				
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
			#endregion
			
			} else if(palette_using) { 
			#region no tool
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
	    	#endregion
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
    	
    	palette_viewer.setName("Tile Palette");
    #endregion
    
    ////- Animated tiles
    #region Animated tiles
    	animatedTiles = [];
		animated_selector_h = 0;
		
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
	    	
	    	var _tileSet = texture;
	    	var _tileSiz = tileSize;
	    	
	    	if(!is_surface(_tileSet)) return _h;
	    	var _tdim    = surface_get_dimension(_tileSet);
	    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
	    	
	    	#region top bar
	    	
			var bx = _x;
			var by = _yy;
			var bs = ui(24);
			var _brush_tiles = brush.brush_width * brush.brush_height;
			
			if(_brush_tiles < 1) 
			    draw_sprite_uniform(THEME.add_16, 0, bx + bs / 2, by + bs / 2, 1, COLORS._main_icon);
			    
			else if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "New animated tiles", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
				var _new_at = noone;
				var _indx   = array_create(brush.brush_width * brush.brush_height);
				
				for( var i = 0, n = brush.brush_height; i < n; i++ ) 
	    		for( var j = 0, m = brush.brush_width;  j < m; j++ )
	    			_indx[i * brush.brush_width + j] = brush.brush_indices[i][j][0];
	    		
	    		_new_at = new tiler_brush_animated(_indx);
	    		
				if(_new_at != noone) {
					object_selecting = _new_at;
					object_select_id = noone;
					array_push(animatedTiles, _new_at);
					
					brush.brush_indices = [[ [ -(array_length(animatedTiles) + 1), 0 ] ]];
	    			brush.brush_width   = 1;
					brush.brush_height  = 1;
				}
				
				refreshAnimatedData();
			}
			
			_h  += bs + ui(4);
			_yy += bs + ui(4);
			#endregion
			
	    	var _pd = ui(4);
	    	var _ah = _pd * 2;
	    	var del = -1;
	    	
	    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, animated_selector_h, COLORS.node_composite_bg_blend, 1);
	    	
	    	_yy += _pd;
	    	
	    	for( var i = 0, n = array_length(animatedTiles); i < n; i++ ) {
	    		var _hg = ui(32);
	    		var _at = animatedTiles[i];
	    		
	    		#region header
	    		var _pw = ui(24);
	    		var _ph = ui(24);
	    		var _px = _x + ui(8);
	    		var _py = _yy + ui(4);
	    		
	    		var _prin = array_safe_get(_at.index, safe_mod(current_time / 1000 * 2, array_length(_at.index)), undefined);
	    		
	    		if(_prin == undefined)
		    		draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _pw, _ph, COLORS._main_icon);
	    		else
	    			drawTile(_prin, _px, _py, _pw, _ph);
	    		
	    		var _tx  = _px + _pw + ui(8);
	    		var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _hg - 1);
	    		var _cc  = object_selecting == _at? COLORS._main_accent : (_hov? COLORS._main_text : COLORS._main_text_sub);
	    		
	    		if(renaming == _at) {
					tb_rename.setFocusHover(_focus, _hover);
					tb_rename.draw(_tx, _yy, _w - _pw - ui(8), _hg, rename_text, _m);
				
				} else {
		    		draw_set_text(f_p2, fa_left, fa_center, _cc);
		    		draw_text_add(_tx, _yy + _hg / 2, _at.name);
		    		
		    		var bs = ui(24);
					var bx = _w  - bs - ui(4);
					var by = _yy + _hg / 2 - bs / 2;
					if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, _hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
						del = i;	
				}
				
	    		if(_hov && _m[0] < _x + _w - ui(32)) {
	    			if(is(object_selecting, tiler_rule)) {
	    				TOOLTIP = "Set Rule selector";
	    				
	    				if(mouse_press(mb_left, _focus)) {
		    				if(object_select_id != noone)
	    						object_selecting.selection_rules[object_select_id] = -(i + 2);
							object_selecting = noone;
	    					triggerRender();
	    				}
	    			} else if(is(object_selecting, tiler_rule_replacement)) {
	    				TOOLTIP = "Set Rule replacement";
	    				
	    				if(mouse_press(mb_left, _focus)) {
	    					object_selecting.index = -(i + 2);
	    					object_selecting = noone;
	    					triggerRender();
	    				}
    				} else if(is(object_selecting, tilemap_convert_object)) {
	    				TOOLTIP = "Set Replacement target";
	    			
	    				if(mouse_press(mb_left, _focus)) {
		    				object_selecting.target = -(i + 2);
							object_selecting = noone;
							if(node_edit) node_edit.triggerRender();
	    				}
	    				
	    			} else if(_m[0] > _tx) {
		    			if(DOUBLE_CLICK && _focus) {
							renaming    = _at;
							rename_text = _at.name;
							
							tb_rename._current_text = _at.name;
							tb_rename.activate();
		    				
		    			} else if(mouse_press(mb_left, _focus)) {
		    				object_selecting = object_selecting == _at? noone : _at;
		    				object_select_id = noone;
		    				
		    				brush.brush_indices = [[ [ -(i + 2), 0 ] ]];
			    			brush.brush_width   = 1;
		    				brush.brush_height  = 1;
		    				palette_using = false;
		    				
		    				setPencil();
		    			}
	    			} else {
	    				draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _pw, _ph, COLORS._main_accent);
		    			
		    			if(mouse_press(mb_left, _focus))
		    				_at.open = !_at.open;
	    			}
	    		}
	    		
	    		_yy += _hg;
	    		_ah += _hg;
	    		#endregion
	    		
	    		if(!_at.open) continue;
	    		
	    		#region content
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
    			draw_sprite_stretched_ext(THEME.ui_panel, 1, _pre_sx, _pre_sy, _pre_sw * _ss, _pre_sh * _ss, COLORS._main_icon);
    			
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
							object_selecting = _at;
							object_select_id = object_select_id == _at_id? noone : _at_id;
    					}
    					
    					if(mouse_press(mb_right, _focus))
    						_at.index[_at_id] = -1;
    				}
    			}
    			
    			if(object_selecting == _at && object_select_id != noone) {
    				var _at_sl_x = object_select_id % _coll;
    				var _at_sl_y = floor(object_select_id / _coll);
    				
    				var _at_c_sx = _pre_sx + _at_sl_x * _dtile_w;
					var _at_c_sy = _pre_sy + _at_sl_y * _dtile_h;
					
					draw_sprite_stretched_ext(THEME.ui_panel, 1, _at_c_sx, _at_c_sy, _dtile_w, _dtile_h, COLORS._main_accent);
    			}
    			
    			_yy += _pre_sh * _ss + ui(4);
	    		_ah += _pre_sh * _ss + ui(4);
	    		#endregion
	    	}
	    	
	    	if(del != -1) {
	    		array_delete(animatedTiles, del, 1);
	    		object_selecting = noone;
	    		object_select_id = noone;
	    		refreshAnimatedData();
	    	}
	    	
	    	animated_selector_h = max(ui(12), _ah);
    		return _h + _ah;
    	});
    	
    	animated_viewer.setName("Animated Tile");
    #endregion
    
	input_display_list = [ 1, 0, 
		["Tileset",      false, noone, tile_selector.b_toggle        ], tile_selector, 
		["Autoterrains",  true, noone, autoterrain_selector.b_toggle ], autoterrain_selector, 
		["Palette",       true, noone, palette_viewer.b_toggle       ], palette_viewer,
		["Animated tiles",true, noone, animated_viewer.b_toggle      ], animated_viewer,
		["Rules",         true, noone, rules.b_toggle                ], rules,
	];
	
	////- Update
	
	static shader_submit = function() {
        shader_set_2("tileSize",  tileSize);
        
        shader_set_surface("tileTexture", texture);
        shader_set_2("tileTextureDim", surface_get_dimension(texture));
        
		shader_set_f("animatedTiles",       aTiles);
		shader_set_f("animatedTilesIndex",  aTilesIndex);
		shader_set_f("animatedTilesLength", aTilesLength);
	}
	
	static update = function(frame = CURRENT_FRAME) {
    	texture  = inputs[0].getValue();
		tileSize = inputs[1].getValue();
		
		if(gmTile != noone) {
			inputs[0].setVisible(false, false);
			
			var _spm = gmTile.spriteObject;
            var _spr = _spm == noone? noone : _spm.thumbnail;
            
            if(_spr) {
            	var _sw = sprite_get_width(_spr);
            	var _sh = sprite_get_height(_spr);
            	
            	texture = surface_verify(texture, _sw, _sh);
            	surface_set_target(texture);
            		DRAW_CLEAR
            		BLEND_OVERRIDE
            		draw_sprite(_spr, 0, 0, 0);
            		BLEND_NORMAL
            	surface_reset_target();
            }
            
            tileSize = [ gmTile.raw.tileWidth, gmTile.raw.tileHeight ];
		}
		
		var _tdim  = surface_get_dimension(texture);
		tileAmount = [ floor(_tdim[0] / tileSize[0]), floor(_tdim[1] / tileSize[1]) ];
		
	    outputs[0].setValue(self);
	}
	
	////- Draw
	
	static getPreviewValues       = function() { return texture; }
	static getGraphPreviewSurface = function() { return texture; }
	
    ////- GM
    
	static droppable = function(obj) { return struct_try_get(obj, "type", "") == "GMTileSet"; }
	static onDrop = function(obj) { 
		if(!droppable(obj)) return;
		bindTile(obj.data);
	}
	
    static bindTile = function(_gmTile) {
    	gmTile = _gmTile;
    	if(gmTile == noone) return;
    	
    	display_name = gmTile.name;
    	
    	var _tw = _gmTile.raw.tileWidth;
    	var _th = _gmTile.raw.tileHeight;
    	
    	inputs[1].setValue([ _tw, _th ]);
    }
    
	////- Serialize
	
	static attributeSerialize = function() {
		var _attr = {
			autoterrain, 
			animatedTiles, 
			ruleTiles: rules.ruleTiles,
			palette: surface_encode(brush_palette),
			gm_key: gmTile == noone? noone : gmTile.key,
		};
		
		return _attr; 
	}
	
	static attributeDeserialize = function(attr) {
		var _auto = struct_try_get(attr, "autoterrain",   []);
		var _anim = struct_try_get(attr, "animatedTiles", []);
		var _rule = struct_try_get(attr, "ruleTiles",     []);
		var _palt = struct_try_get(attr, "palette",       noone);
		
		for( var i = 0, n = array_length(_auto); i < n; i++ ) {
			autoterrain[i] = new tiler_brush_autoterrain(_auto[i].type, _auto[i].index);
			autoterrain[i].name = _auto[i].name;
		}
		
		for( var i = 0, n = array_length(_anim); i < n; i++ ) {
			animatedTiles[i] = new tiler_brush_animated(_anim[i].index);
			animatedTiles[i].name = _anim[i].name;
		}
		
		for( var i = 0, n = array_length(_rule); i < n; i++ )
			rules.ruleTiles[i] = new tiler_rule().deserialize(_rule[i]);
		
		if(_palt != noone) {
			surface_free_safe(brush_palette);
			brush_palette = surface_decode(_palt);
			
			var _dim = surface_get_dimension(brush_palette);
			buffer_delete_safe(brush_palette_buffer);
			brush_palette_buffer  = buffer_from_surface(brush_palette, false, buffer_grow);
		}
		
		if(struct_has(attr, "gm_key") && project.bind_gamemaker)
			bindTile(project.bind_gamemaker.getResourceFromPath(attr.gm_key));
		
		refreshAnimatedData();
	}
	
}