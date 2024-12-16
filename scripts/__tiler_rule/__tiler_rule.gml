function tiler_rule_replacement(_index) constructor {
	index = _index;
}

function tiler_rule() constructor {
	name = "rule";
    open = false;
    active = true;
    
    range           = 1;
    size            = [ 1, 1 ];
    scanSize        = [ 1, 1 ];
    probability     = 100;
    _probability    = 1;
    
    selection_rules    = array_create(9, -1);
    selection_rules[4] = -10000;
    replacements       = [];
    
    sl_prop = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { probability = v; })
    				.setSlideRange(0, 100);
    sl_prop.suffix = "%";
    sl_prop.font   = f_p3;
    
    __aut = [];
    __sel = [];
    
    static shader_select = function(tileset) {
    	var _sw = size[0] + range * 2;
    	var _sh = size[1] + range * 2;
    	
    	selection_rules = array_verify_ext(selection_rules, _sw * _sh, function() /*=>*/ {return -1} );
    	
	    __aut = [];
	    __sel = [];
    	var autI = [];
    	var minX = 999, maxX = 0;
	    var minY = 999, maxY = 0;
    	
    	// print($"{size}, {range}")
    	
    	for( var i = 0, n = array_length(selection_rules); i < n; i++ ) {
    		var _s = selection_rules[i];
    		var _r = floor(i / _sw);
    		var _c = i % _sw;
    		
    		if(_s != -1 && (_r < range || _r >= size[1] + range || _c < range || _c >= size[0] + range)) {
    			minX = min(minX, _c);
    			maxX = max(maxX, _c);
				minY = min(minY, _r);
				maxY = max(maxY, _r);
				
				// print($"{_s}: {_c}, {_r}");
    		}
    		
    		if(is_array(_s)) {
    			var _auI = _s[1];
    			array_push(__sel, 10000 + _auI);
    			array_push(autI, _auI);
    		} else 
    			array_push(__sel, _s);
    	}
    	
    	scanSize = minX < maxX? [ max(1, maxX - minX + 1), max(1, maxY - minY + 1) ] : size;
    	// print($"{maxX}, {minX} | {maxY}, {minY} | {scanSize}");
    	
    	autI = array_unique(autI);
    	for( var i = 0, n = array_length(autI); i < n; i++ ) {
    		var _i = autI[i];
    		var _t = array_safe_get(tileset.autoterrain, _i, noone);
    		if(_t == noone) continue;
    		
    		var _ind = 64 * i;
    		__aut[_ind] = array_length(_t.index);
    		for( var j = 0, m = array_length(_t.index); j < m; j++ )
    			__aut[_ind + 1 + j] = _t.index[j];
    	}
    	
    	var _selu = array_unique(__sel);
    	
    	shader_set_f("selection",      _selu);
    	shader_set_i("selectionSize",  array_length(_selu));
    	shader_set_f("selectionGroup", __aut);
    	
    }
    
    static shader_submit = function(tileset) {
    	shader_set_i("range",        range);
    	shader_set_f("size",         size);
    	shader_set_f("scanSize",     scanSize);
    	shader_set_f("probability",  probability / 100);
    	
    	shader_set_f("selection",      __sel);
    	shader_set_f("selectionGroup", __aut);
    	
    	var rep = [];
    	var rsz = size[0] * size[1];
    	
    	for( var i = 0, n = array_length(replacements); i < n; i++ ) {
    		var _r   = replacements[i];
    		_r.index = array_verify_ext(_r.index, rsz, function() /*=>*/ {return -1} );
    		array_append(rep, _r.index);
    	}
    	
    	// print($"selection:   {__sel}");
    	// print($"selectGroup: {__aut}\n");
    	
    	shader_set_f("replacements",     rep);
    	shader_set_i("replacementCount", array_length(replacements));
    }
    
    static deserialize = function(_struct) {
        name   = struct_try_get(_struct, "name",   name);
        size   = struct_try_get(_struct, "size",   size);
        range  = struct_try_get(_struct, "range",  range);
        active = struct_try_get(_struct, "active", active);
        
        selection_rules = struct_try_get(_struct, "selection_rules", selection_rules);
		probability     = struct_try_get(_struct, "probability",     probability);
		
		var _rep = struct_try_get(_struct, "replacements", noone);
        if(_rep != noone) {
        	for( var i = 0, n = array_length(_rep); i < n; i++ )
        		replacements[i] = new tiler_rule_replacement(_rep[i].index);
        }
        
        return self;
    }
}

function Tileset_Rule(_tileset) : Inspector_Custom_Renderer(noone, noone) constructor {
	name      = "Tile Riles";
	tileset   = _tileset;
	ruleTiles = [];
	
	rule_dragging   = noone;
	rule_selector_h = 0;
	
    renaming       = noone;
	rename_text    = "";
	tb_rename      = new textBox(TEXTBOX_INPUT.text, function(_name) { 
		if(renaming == noone) return;
		renaming.name  = _name;
		renaming       = noone;
	});
	tb_rename.font = f_p2;
	tb_rename.hide = true;
	
	temp_surface   = [ noone, noone, noone ];
	
	function setTileset(_tileset) { tileset = _tileset; return self; }
	
	function draw(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
		var _yy = _y;
    	var _h  = 0;
    	
    	if(tileset == noone) return _h;
    	
    	var _tileSet = tileset.texture;
    	var _tileSiz = tileset.tileSize;
    	
    	if(!is_surface(_tileSet)) return _h;
    	var _tdim    = surface_get_dimension(_tileSet);
    	var _tileAmo = [ floor(_tdim[0] / _tileSiz[0]), floor(_tdim[1] / _tileSiz[1]) ];
    	
		var bx = _x;
		var by = _yy;
		var bs = ui(24);
		
		if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "New rule", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			var _new_rl  = new tiler_rule();
			_new_rl.name = $"rule {array_length(ruleTiles)}"
			_new_rl.open = true;
    		array_push(ruleTiles, _new_rl);
    		tileset.triggerRender();
		}
		
		_h  += bs + ui(4);
		_yy += bs + ui(4);
		
    	var _pd = ui(4);
    	var _ah = _pd * 2;
    	var del = -1;
    	var rl_iHover = 0;
    	
    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, rule_selector_h, COLORS.node_composite_bg_blend, 1);
    	
    	_yy += _pd;
    	
    	for( var i = 0, n = array_length(ruleTiles); i < n; i++ ) {
    		var _hg = ui(32);
    		var _rl = ruleTiles[i];
    		
    		var _pw = ui(24);
    		var _ph = ui(24);
    		var _px = _x + ui(8);
    		var _py = _yy + ui(4);
    		
    		if(_m[1] > _yy) rl_iHover = i;
    		
    		var _prin = array_safe_get(_rl.replacements, 0, undefined);
    		
    		if(_prin == undefined)
	    		draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _pw, _ph, COLORS._main_icon);
	    	else if(is(_prin, tiler_rule_replacement)) {
	    		var _ind = array_safe_get(_prin.index, 0);
    			tileset.drawTile(_ind, _px, _py, _pw, _ph);
	    	}
    		
    		var _tx  = _px + _pw + ui(8);
    		var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + _hg - 1);
    		
    		if(renaming == _rl) {
				tb_rename.setFocusHover(_focus, _hover);
				tb_rename.draw(_tx, _yy, _w - _pw - ui(8), _hg, rename_text, _m);
			
			} else {
    			var _cc = _hov? COLORS._main_text : COLORS._main_text_sub;
    			if(rule_dragging == _rl) _cc = COLORS._main_accent;
    			
	    		draw_set_text(f_p2, fa_left, fa_center, _cc);
	    		draw_text_add(_tx, _yy + _hg / 2, _rl.name);
	    		
	    		var bs = ui(24);
				var bx = _w  - bs - ui(4);
				var by = _yy + _hg / 2 - bs / 2;
				if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, _hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
					del = i;	
			}
			
    		if(_hov && _m[0] < _x + _w - ui(32 + 160)) {
    			if(_m[0] > _tx) {
    				
    				if(DOUBLE_CLICK && _focus) {
						renaming    = _rl;
						rename_text = _rl.name;
						
						tb_rename._current_text = _rl.name;
						tb_rename.activate();
						
	    			} else if(mouse_press(mb_left, _focus)) {
    					rule_dragging = _rl;
    				}
	    			
    			} else {
    				draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _pw, _ph, COLORS._main_accent);
    				
	    			if(mouse_press(mb_left, _focus))
	    				_rl.open = !_rl.open;
    			}
    		}
    		
    		var _atWid = _rl.sl_prop;
    		var _scw = ui(120);
    		var _sch = ui(20);
    		var _scx = _x + _w - _scw - ui(32 + 8);
    		var _scy = _yy + _hg / 2 - _sch / 2;
    		
    		_atWid.setFocusHover(_focus, _hover);
    		_atWid.rx = rx; 
    		_atWid.ry = ry;
    		_atWid.draw(_scx, _scy, _scw, _sch, _rl.probability, _m);
    		if(_rl.probability != _rl._probability) {
    			_rl._probability = _rl.probability;
    			tileset.triggerRender();
    		}
    		
    		var _acw = ui(20);
    		var _ach = ui(20);
    		var _acx = _scx - _acw - ui(8);
    		var _acy = _yy + _hg / 2 - _sch / 2;
    		var _ahv = _hover && point_in_rectangle(_m[0], _m[1], _acx, _acy, _acx + _acw, _acy + _ach);
    		
    		if(_ahv) {
    			TOOLTIP = "Active";
    			if(mouse_press(mb_left, _focus)) {
    				_rl.active = !_rl.active;
    				tileset.triggerRender();
    			}
    		}
    		
    		draw_sprite_stretched_ext(THEME.checkbox_def, _ahv, _acx, _acy, _acw, _ach, c_white);
    		if(_rl.active) draw_sprite_stretched_ext(THEME.checkbox_def, 2, _acx, _acy, _acw, _ach, COLORS._main_accent);
    		
    		_yy += _hg;
    		_ah += _hg;
    		
    		if(_rl.open) {
	    		_yy += ui(4);
	    		_ah += ui(4);
	    		
	    		var _sls  = ui(28);
	    		
	    		var _rep = _rl.replacements;
	    		var _siz = _rl.size;
	    		
	    		var _rpw = _sls * _siz[0];
	    		var _rph = _sls * _siz[1];
	    		
	    		var _radw = _rl.size[0] + _rl.range * 2;
	    		var _radh = _rl.size[1] + _rl.range * 2;
	    		var _slw  = ui(16) + _radw * _sls;
	    		var _slh  = ui(16) + _radh * _sls;
	    		var _hh0  = _slh;
	    		
	    		var _dx  = ui(8) + _slw + ui(16);
	    		var _nln = (_rpw + ui(4)) * 2 > _w - _dx - ui(24);
	    		var _sx  = _x + ui(8);
	    		
	    		if(_nln) {
	    			_sx  = _w / 2 - _slw / 2 + ui(4);
	    			_slw = _w - ui(16);
	    		}
	    		
	    		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x + ui(8), _yy, _slw, _slh, COLORS.node_composite_bg_blend, 1);
	    		
	    		for( var j = 0, m = array_length(_rl.selection_rules); j < m; j++ ) {
	    			var _rl_sel = _rl.selection_rules[j];
	    			var _rl_col = j % _radw;
	    			var _rl_row = floor(j / _radw);
	    			
	    			var _cen  = _rl_col >= _rl.range && _rl_col < _rl.range + _rl.size[0] &&
	    					    _rl_row >= _rl.range && _rl_row < _rl.range + _rl.size[1];
	    			
	    			var _rl_x = _sx + ui(8) + _rl_col * _sls;
	    			var _rl_y = _yy + ui(8) + _rl_row * _sls;
	    			
	    			var _rl_selected = tileset.object_selecting == _rl && tileset.object_select_id == j;
	    			var _rl_hov = _hover && point_in_rectangle(_m[0], _m[1], _rl_x, _rl_y, _rl_x + _sls - 1, _rl_y + _sls - 1);
	    			var _pad = ui(2);
	    			
	    			var _cc = _rl_selected? COLORS._main_accent : COLORS._main_icon;
	    			var _aa = _rl_selected? 1 : .5 + _rl_hov * .5;
	    			
	    			if(is_array(_rl_sel)) {
	    				var _autt = array_safe_get(tileset.autoterrain, _rl_sel[1], noone);
	    				
	    				tileset.drawTile(_autt == noone? 0 : _autt.index[0], _rl_x + ui(2), _rl_y + ui(2), _sls - ui(4), _sls - ui(4));
	    				draw_sprite_uniform(THEME.circle, 0, _rl_x + _sls - ui(8), _rl_y + _sls - ui(8), 1, COLORS._main_accent);
	    				
	    			} else if (_rl_sel == -10000) {
	    				draw_sprite_uniform(THEME.cross, 0, _rl_x + _sls / 2, _rl_y + _sls / 2, 1, _cc, _aa);
					
	    			} else if(_rl_sel != -1) {
	    				tileset.drawTile(_rl_sel, _rl_x + ui(2), _rl_y + ui(2), _sls - ui(4), _sls - ui(4));
	    				
	    			} else if(!_cen) _pad = ui(10);
	    			
	    			draw_sprite_stretched_ext(THEME.ui_panel, 1 + _cen, _rl_x + _pad, _rl_y + _pad, _sls - _pad * 2, _sls - _pad * 2, _cc, _aa);
	    			
	    			if(_rl_hov) {
	    				if(mouse_press(mb_left, _focus)) {
		    				tileset.object_selecting = _rl_selected? noone : _rl;
		    				tileset.object_select_id = j;
		    				tileset.triggerRender();
	    				}
	    				
	    				if(mouse_press(mb_right, _focus)) {
	    					_rl.selection_rules[j] = -1;
	    					tileset.object_selecting = noone;
		    				tileset.object_select_id = noone;
		    				tileset.triggerRender();
	    				}
	    			}
	    		}
	    		
	    		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	    		
	    		var _rx, _rpww;
	    		
	    		if(_nln) {
	    			_rx   = _x + ui(8);
	    			_rpww = _w - ui(16);
	    			_hh0  = 0;
	    			
	    			_yy += _slh + ui(8);
	    			_ah += _slh + ui(8);
	    			
	    			draw_sprite_uniform(THEME.arrow, 3, _x + _w / 2, _yy + ui(2), 1, COLORS._main_icon, 1);
	    			
	    			_yy += ui(8);
	    			_ah += ui(8);
	    			
	    		} else {
	    			_rx   = _x + _dx;
	    			_rpww = _w - _dx - ui(8);
	    			
	    			draw_sprite_uniform(THEME.arrow, 0, _rx - ui(8), _yy + _slh / 2, 1, COLORS._main_icon, 1);
	    		}
	    		
	    		var _col = max(1, floor((_rpww - ui(16)) / (_rpw + ui(4))));
	    		var _row = ceil((array_length(_rep) + 1) / _col);
	    		var _rphh = ui(16) + _row * _rph;
	    		
	    		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _rx, _yy, _rpww, max(_hh0, _rphh), COLORS.node_composite_bg_blend, 1);
	    		
	    		var del_rep = -1;
	    		
	    		for( var j = 0, m = array_length(_rep) + 1; j < m; j++ ) {
	    			var _rcl = j % _col;
	    			var _rrw = floor(j / _col);
	    			
	    			var _rpx = _rx + ui(8) + _rcl * (_rpw + ui(4));
	    			var _rpy = _yy + ui(8) + _rrw * _rph;
	    			var _rl_hov = _hover && point_in_rectangle(_m[0], _m[1], _rpx, _rpy, _rpx + _rpw, _rpy + _rph);
	    			
	    			if(j == 0) {
	    				var _cc = _rl_hov? COLORS._main_value_positive : COLORS._main_icon;
						draw_sprite_uniform(THEME.add_16, 0, _rpx + _rpw / 2, _rpy + _rph / 2, 1, _cc);
						
						if(_rl_hov && mouse_press(mb_left, _focus)) {
							var _new_rep = new tiler_rule_replacement([-1]);
	    					array_push(_rl.replacements, _new_rep);
	    					tileset.object_selecting = _new_rep;
	    					tileset.object_select_id = _rl;
						}
	    				continue;
	    			}
	    			
	    			var _replace     = _rep[j - 1];
	    			var _repIndex    = _replace.index;
	    			if(!is_array(_repIndex)) continue;
	    			
	    			for( var k = 0, q = array_length(_repIndex); k < q; k++ ) {
	    				var _repBlockCol = k % _siz[0];
	    				var _repBlockRow = floor(k / _siz[0]);
	    				var _rpbx = _rpx + _repBlockCol * _sls;
	    				var _rpby = _rpy + _repBlockRow * _sls;
	    				
		    			if(_replace.index[k] != -1) tileset.drawTile(_replace.index[k], _rpbx, _rpby, _sls, _sls);
	    			}
	    			
	    			var _rl_selected = tileset.object_selecting == _replace;
	    			var _cc = _rl_selected? COLORS._main_accent : COLORS._main_icon;
	    			var _aa = _rl_selected? 1 : .5 + _rl_hov * .5;
	    			draw_sprite_stretched_ext(THEME.ui_panel, 1, _rpx, _rpy, _rpw, _rph, _cc, _aa);
	    			
	    			if(_rl_hov) {
	    				if(mouse_press(mb_left, _focus)) {
		    				tileset.object_selecting = tileset.object_selecting == _replace? noone : _replace;
		    				tileset.object_select_id = _rl;
		    				tileset.triggerRender();
	    				}
		    				
	    				if(mouse_press(mb_right, _focus))
	    					del_rep = j - 1;
	    			}
	    		}
	    		
	    		if(del_rep != -1) {
	    			array_delete(_rep, del_rep, 1);
	    			tileset.triggerRender();
	    		}
	    		
	    		_yy += max(_hh0, _rphh) + ui(8); 
	    		_ah += max(_hh0, _rphh) + ui(8);
	    		
    		}
    	}
    	
    	if(rule_dragging != noone) {
    		array_remove(ruleTiles, rule_dragging);
    		array_insert(ruleTiles, rl_iHover, rule_dragging);
    		
    		if(mouse_release(mb_left)) {
    			rule_dragging = noone;
    			tileset.triggerRender();
    		}
    	}
    	
    	if(del != -1) {
    		array_delete(ruleTiles, del, 1);
    		tileset.triggerRender();
    	}
    	
    	rule_selector_h = max(ui(12), _ah);
		return _h + _ah;
	}
	
	function apply(_tilemap, _seed) { 
		var _mapSize    = surface_get_dimension(_tilemap);
		temp_surface[0] = surface_verify(temp_surface[0], _mapSize[0], _mapSize[1], surface_rgba16float);
	    temp_surface[1] = surface_verify(temp_surface[1], _mapSize[0], _mapSize[1], surface_rgba16float);
	    temp_surface[2] = surface_verify(temp_surface[2], _mapSize[0], _mapSize[1], surface_r16float);
	    
	    var bg = 0;
    	surface_set_shader(temp_surface[1], noone, true, BLEND.over);
	        draw_surface(_tilemap, 0, 0);
	    surface_reset_shader();
	    
	    for( var i = 0, n = array_length(ruleTiles); i < n; i++ ) {
	    	var _rule = ruleTiles[i];
	    	
	    	if(!_rule.active) continue;
	    	if(array_empty(_rule.replacements)) continue;
	    	
	    	surface_set_shader(temp_surface[2], sh_tile_rule_select, true, BLEND.over);
	    		shader_set_2("dimension", _mapSize);
	    		_rule.shader_select(tileset);
	    		
	    		draw_surface(_tilemap, 0, 0);
		    surface_reset_shader();
		    
	    	surface_set_shader(temp_surface[bg], sh_tile_rule_apply, true, BLEND.over);
	    		shader_set_2("dimension",    _mapSize);
	    		shader_set_f("seed",         _seed);
	    		shader_set_surface("group",  temp_surface[2]);
	    		_rule.shader_submit(tileset);
	    		
		        draw_surface(temp_surface[!bg], 0, 0);
		    surface_reset_shader();
	    	
	    	bg = !bg;
	    }
	    
	    surface_set_shader(_tilemap, noone, true, BLEND.over);
	    	draw_surface(temp_surface[!bg], 0, 0);
	    surface_reset_shader();
	    
	    return _tilemap;
	}
}