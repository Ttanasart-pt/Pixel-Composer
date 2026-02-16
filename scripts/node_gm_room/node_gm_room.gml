function Node_GMRoom(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "GMRoom";
	color  = COLORS.node_blend_input;
	icon   = s_gamemaker;
	
    gmRoom   = noone;
    layers   = [];
    layerMap = {};
    
    maxTileSize = [ 1, 1 ];
    
    newOutput( 0, nodeValue_Surface("Room Preview"));
    
    layer_selecting = noone;
    tb_depth = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { if(layer_selecting == noone) return; layer_selecting.raw.depth = round(v); })
    					.setLabel("Depth").setFont(f_p3);
    
    #region room resize
	    room_resizing      = false;
	    room_resizing_area = [ 0, 0, 0, 0 ];
	    room_resizing_hov  = array_create(4);
	    room_resizing_t    = noone;
	    room_resizing_mx   = 0; room_resizing_my   = 0;
	    room_resizing_ss   = 0;
	    
	    room_resize_apply  = button( function() { applyResizeRoom();     } ).setIcon(THEME.toolbar_check, 0);
		room_resize_cancel = button( function() { room_resizing = false; } ).setIcon(THEME.toolbar_check, 1);
		room_resize_grid   = button( function() { room_resizing = false; } ).setIcon(THEME.toolbar_check, 1);
		
		tb_room_resize_w    = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { room_resizing_area[2] = room_resizing_area[0] + round(v); }).setHide(1).setFont(f_p3);
		tb_room_resize_h    = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { room_resizing_area[3] = room_resizing_area[1] + round(v); }).setHide(1).setFont(f_p3);
    #endregion
    
    room_renderer  = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
    	if(gmRoom == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, ui(28), COLORS.node_composite_bg_blend, 1);	
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + ui(14), "No data");
			return ui(28);
		}
		
    	var  hh = ui(40);
    	var _yy = _y + ui(8);
    	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, hh, COLORS.node_composite_bg_blend, 1);	
    	
    	var _wdx = _x + ui(128);
		var _wdy = _yy;
		var _wdw = _w - ui(128 + 8);
		var _wdh = ui(24);
		
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(_x + ui(16), _wdy + _wdh / 2, "Room Size");
		
		var _wdw = _w - ui(128 + 8) - (room_resizing? _wdh * 2 : _wdh) - ui(8);
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _wdx,            _wdy, _wdw / 2, _wdh, COLORS._main_icon_light);
		draw_sprite_stretched_ext(THEME.textbox, 3, _wdx + _wdw / 2, _wdy, _wdw / 2, _wdh, COLORS._main_icon_light);
		
		var _ww = gmRoom.roomSettings.Width;
		var _hh = gmRoom.roomSettings.Height;
		
		if(room_resizing) {
			_ww = room_resizing_area[2] - room_resizing_area[0];
			_hh = room_resizing_area[3] - room_resizing_area[1];
			
			var _wpr = new widgetParam(_wdx, _wdy, _wdw / 2, _wdh, _ww, {}, _m, room_renderer.rx, room_renderer.ry).setFont(f_p2).setFocusHover(_focus, _hover);
			tb_room_resize_w.drawParam(_wpr);
			
			var _wpr = new widgetParam(_wdx + _wdw / 2, _wdy, _wdw / 2, _wdh, _hh, {}, _m, room_renderer.rx, room_renderer.ry).setFont(f_p2).setFocusHover(_focus, _hover);
			tb_room_resize_h.drawParam(_wpr);
			
		} else {
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
			draw_text_add(_wdx +            _wdw / 4, _wdy + _wdh / 2, _ww);
			draw_text_add(_wdx + _wdw / 2 + _wdw / 4, _wdy + _wdh / 2, _hh);
		}
		
		if(room_resizing) {
			var _bx = _wdx + _wdw + ui(8);
			if(buttonInstant(THEME.button_left, _bx, _wdy, _wdh, _wdh, _m, _hover, _focus, __txt("Cancel"), THEME.toolbar_check, 1, 
			COLORS._main_value_negative, 1, 1, COLORS._main_icon_light) == 2)
				room_resizing = false;
			
			var misalign = (room_resizing_area[0] % maxTileSize[0] != 0) || (room_resizing_area[1] % maxTileSize[1] != 0) ||
						   (room_resizing_area[2] % maxTileSize[0] != 0) || (room_resizing_area[3] % maxTileSize[1] != 0);
			var _tooltip = misalign? __txt("Warning: room size not divisible by tile size. May cause tile shifting.") : __txt("Apply");
			
			_bx += _wdh;
			if(buttonInstant(THEME.button_right, _bx, _wdy, _wdh, _wdh, _m, _hover, _focus, _tooltip, THEME.toolbar_check, 0, 
			COLORS._main_value_positive, 1, 1, COLORS._main_icon_light) == 2)
				applyResizeRoom();
				
		} else {
			var _bx = _wdx + _wdw + ui(8);
			
			if(buttonInstant(THEME.button_def, _bx, _wdy, _wdh, _wdh, _m, _hover, _focus, __txt("Resize"), THEME.canvas_resize, 0, 
			COLORS._main_icon_light, 1, 1, COLORS._main_icon_light) == 2) {
				
				room_resizing      = true;
				room_resizing_area = [ 0, 0, gmRoom.roomSettings.Width, gmRoom.roomSettings.Height ];
			}
		}
		
    	return hh;
    });
    
	layers_renderer  = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(gmRoom == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, ui(28), COLORS.node_composite_bg_blend, 1);	
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + ui(14), "No data");
			return ui(28);
		}
		
		var _amo = array_length(layers);
		var hh   = ui(28);
		var _h   = hh * _amo + ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(layers); i < n; i++ ) {
			var _ld = layers[i];
			var _l  = _ld.layer;
			var _d  = _ld.depth;
			
			var _xx = _x + _d * ui(32);
			var _yy = _y + ui(8) + i * hh;
			
			var _exposed = struct_has(inputMap, _l.name);
			var cc = layer_selecting == _l? COLORS._main_text_accent : COLORS._main_text_sub;
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + hh - 1)) {
				cc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus))
					layer_selecting = layer_selecting == _l? noone : _l;
			}
			
			if(_exposed) draw_sprite_ui_uniform(THEME.animate_clock, 2, _x + ui(20),_yy + hh / 2, 1, COLORS._main_accent);
			
			draw_sprite_ui_uniform(s_gmlayer, _l.index, _xx + ui(44), _yy + hh / 2, 1, cc);
			draw_set_text(f_p2, fa_left, fa_center, cc);
			draw_text_add(_xx + ui(64), _yy + hh / 2, _l.name);
		}
		
		return _h;
	}); 
	
	layer_renderer_h = 0;
	layer_renderer   = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(layer_selecting == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, ui(28), COLORS.node_composite_bg_blend, 1);	
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text_sub);
			draw_text(_x + _w / 2, _y + ui(14), "No layer selected");
			return ui(28);
		}
		
		var _h = ui(40);
		var _l = layer_selecting;
		var _exposed = struct_has(inputMap, _l.name);
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, layer_renderer_h, COLORS.node_composite_bg_blend, 1);	
		
		draw_sprite_ui_uniform(s_gmlayer, _l.index, _x + ui(8 + 16), _y + ui(8 + 16), 1, COLORS._main_icon);
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
		draw_text_add(_x + ui(8 + 32), _y + ui(8 + 16), layer_selecting.name);
		
		var _wdw = ui(128);
		var _wdx = _x + _w - _wdw - ui(8);
		var _yy  = _y + ui(8);
		var _wdy = _yy;
		var _wdh = ui(32);
		var _wpr = new widgetParam(_wdx, _wdy, _wdw, _wdh, _l.raw.depth, {}, _m, layer_renderer.rx, layer_renderer.ry)
						.setColor(COLORS._main_icon_light)
						.setFocusHover(_focus, _hover);
		tb_depth.drawParam(_wpr);
		
		_yy += _wdh + ui(8);
		
		if(is(_l, GMRoom_Tile)) {
			_wdx = _x + ui(128);
			_wdy = _yy;
			_wdw = _w - ui(128 + 8);
			_wdh = ui(24);

			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + ui(16), _wdy + _wdh / 2, "Tileset");
			
			draw_sprite_stretched_ext(THEME.textbox, 3, _wdx, _wdy, _wdw, _wdh, COLORS._main_icon_light);
			
			var _tset  = _l.tilesetId;
			var _tname = struct_try_get(_tset, "name", "");
			
			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_wdx + ui(8 + 32), _wdy + _wdh / 2, _tname);
			
            draw_sprite_stretched_ext(THEME.textbox, 3, _wdx, _wdy, ui(32), _wdh, c_white);
            draw_sprite_ext(s_node_tile_tileset, 0, _wdx + ui(32) / 2, _wdy + _wdh / 2, .25, .25);
			
			_yy += _wdh + ui(8);
			_h  += _wdh + ui(8);
			
			_wdy = _yy;

			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + ui(16), _wdy + _wdh / 2, "Tile count");
			
			draw_sprite_stretched_ext(THEME.textbox, 3, _wdx,            _wdy, _wdw / 2, _wdh, COLORS._main_icon_light);
			draw_sprite_stretched_ext(THEME.textbox, 3, _wdx + _wdw / 2, _wdy, _wdw / 2, _wdh, COLORS._main_icon_light);
			
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
			draw_text_add(_wdx +            _wdw / 4, _wdy + _wdh / 2, _l.tiles.SerialiseWidth);
			draw_text_add(_wdx + _wdw / 2 + _wdw / 4, _wdy + _wdh / 2, _l.tiles.SerialiseHeight);
			
			_yy += _wdh + ui(8);
			_h  += _wdh + ui(8);
			
			_wdx = _x + ui(8);
			_wdy = _yy;
			_wdw = _w - ui(16);
			
			if(_exposed) {
				_wdh = ui(24);
				draw_sprite_stretched_ext(THEME.textbox, 3, _wdx, _wdy, _wdw, _wdh, COLORS._main_icon_light);
				
				draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
				draw_text_add(_wdx + _wdw / 2, _wdy + _wdh / 2, "Tile Data Overrided");
				
			} else {
				_wdh = ui(48);
				
				var _hov = _hover && point_in_rectangle(_m[0], _m[1], _wdx, _wdy, _wdx + _wdw, _wdy + _wdh);
				var _ind = _hov;
				if(mouse_click(mb_left, _focus && _hov)) _ind = 2;
				
				if(mouse_press(mb_left, _focus && _hov)) exposeData(_l);
				draw_sprite_stretched_ext(THEME.button_def, _ind, _wdx, _wdy, _wdw, _wdh);
				
				draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
				draw_text_add(_wdx + _wdw / 2, _wdy + _wdh / 2, "Override Tile Data");
					
			}
			
			_yy += _wdh + ui(8);
			_h  += _wdh + ui(8);
		}
		
		layer_renderer_h = _h + ui(8);
		return _h + ui(8);
	}); 
	
    input_display_list = [ 
    	["Room",   false], room_renderer,
    	["Layers", false], layers_renderer, new Inspector_Spacer(ui(4)), layer_renderer,
    	["Data",    true], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue("Data", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ));
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	} 
	setDynamicInput(1, false);
	
    ////- GM
    
    static roomLayerExtract = function(_layer, _depth = 0) {
    	var _arr = [];
    	
    	for( var i = 0, n = array_length(_layer.layers); i < n; i++ ) {
    		var _l = _layer.layers[i];
    		array_push(_arr, { layer: _l, depth: _depth });
    		array_append(_arr, roomLayerExtract(_l, _depth + 1));
    	}
    	
    	return _arr;
    }
    
    static bindRoom = function(_gmRoom) {
    	gmRoom   = _gmRoom;
    	layers   = [];
    	layerMap = {};
    	if(_gmRoom == noone) return;
    	
    	display_name = gmRoom.name;
    	gmRoom.gmBinder.nodeMap[$ gmRoom.key] = self;
    	
    	layers = roomLayerExtract(gmRoom);
    	maxTileSize = [ 1, 1 ]; 
    	
    	for( var i = 0, n = array_length(layers); i < n; i++ ) {
    		var _l = layers[i].layer;
    		layerMap[$ _l.name] = _l;
    		_l.refreshPreview();
    		
    		if(is(_l, GMRoom_Tile) && _l.tileset != noone) {
    			maxTileSize[0] = max(maxTileSize[0], _l.tileset.raw.tileWidth);
				maxTileSize[1] = max(maxTileSize[1], _l.tileset.raw.tileHeight);
    		}
    	}
    	
    }
    
	static exposeData = function(_layer) {
		var _in = createNewInput();
		_in.name = _layer.name;
		_in.attributes.layerName = _layer.name;
		
		if(is(_layer, GMRoom_Tile)) {
			_in.setType(VALUE_TYPE.struct);
			_in.getEditWidget().shorted = true;
			
			var _tileset = gmRoom.gmBinder.getNodeFromPath(_layer.tileset.key, x - ui(320), y);
			_tileset.bindTile(_layer.tileset);
			
			var _tiler = nodeBuild("Node_Tile_Drawer", x - ui(160), y);
			_tiler.skipDefault();
			_tiler.bindTile(_layer);
			
			_tiler.inputs[0].setFrom(_tileset.outputs[0]);
			_in.setFrom(_tiler.outputs[3]);
		}
		
	}
    
    static applyResizeRoom = function() {
    	room_resizing = false;
    	
    	var _area = room_resizing_area;
    	var _dx   = -_area[0];
    	var _dy   = -_area[1];
    	var _ww   =  _area[2] - _area[0];
    	var _hh   =  _area[3] - _area[1];
    	
    	gmRoom.roomSettings.Width  = _ww;
    	gmRoom.roomSettings.Height = _hh;
    	
    	for( var i = 0, n = array_length(layers); i < n; i++ ) {
    		var _l = layers[i].layer;
    		
    		switch(instanceof(_l)) {
    			case "GMRoom_Tile" : 
    				var _inp = inputMap[$ _l.name];
    				var _tw  = _l.tileset.raw.tileWidth;
    				var _th  = _l.tileset.raw.tileHeight;
			    	var _trea = [ floor(_area[0] / _tw), floor(_area[1] / _tw), 
			    		          ceil( _area[2] / _tw), ceil( _area[3] / _tw) ];
			    	
    				if(is_undefined(_inp)) {
    					_l.resizeBBOX(_trea);
    					
    				} else if(_inp.value_from) {
    					var _nd = _inp.value_from.node;
    					if(is(_nd, Node_Tile_Drawer))
    						_nd.resizeBBOX(_trea);
    				}
    				break;
    				
    			case "GMRoom_Instance" : 
    				for( var j = 0, m = array_length(_l.instances); j < m; j++ ) {
						var _ins = _l.instances[j];
						_ins.data.x += _dx;
						_ins.data.y += _dy;
    				}
    				break;
    			
    			case "GMRoom_Asset" : 
    				for( var j = 0, m = array_length(_l.assets); j < m; j++ ) {
						var _ass = _l.assets[j];
						_ass.data.x += _dx;
						_ass.data.y += _dy;
    				}
    				break;
    			
    		}
    		
    		_l.refreshPreview();
    	}
    	
    	PANEL_PREVIEW.canvas_x -= _dx * _preview_scale;
    	PANEL_PREVIEW.canvas_y -= _dx * _preview_scale;
		
    	run_in(1, function() /*=>*/ {return triggerRender()});
    }
    
    ////- Update
    
    _preview_scale = 1;
    static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
    	preview_alpha = room_resizing? .5 : 1;
    	if(!room_resizing) return;
    	
    	_preview_scale = _s;
    	var rw = gmRoom.roomSettings.Width;
		var rh = gmRoom.roomSettings.Height;

    	var _x0 = _x;
    	var _y0 = _y;
    	var _x1 = _x + rw * _s;
    	var _y1 = _y + rh * _s;
    	
    	var _area = room_resizing_area;
    	
    	var _cx0 = _x + _area[0] * _s;
    	var _cy0 = _y + _area[1] * _s;
    	var _cx1 = _x + _area[2] * _s;
    	var _cy1 = _y + _area[3] * _s;
    	
    	var _hov = noone;
    	if(hover) {
    			 if(point_in_circle(_mx, _my, _cx0, _cy0, 10))            _hov = 0;
    		else if(point_in_circle(_mx, _my, _cx1, _cy0, 10))            _hov = 1;
    		else if(point_in_circle(_mx, _my, _cx0, _cy1, 10))            _hov = 2;
    		else if(point_in_circle(_mx, _my, _cx1, _cy1, 10))            _hov = 3;
    		else if(point_in_rectangle(_mx, _my, _cx0, _cy0, _cx1, _cy1)) _hov = 4;
    	}
    	
    	for( var i = 0; i < 4; i++ ) room_resizing_hov[i] = lerp_float(room_resizing_hov[i], i == _hov, 5);
    	if(room_resizing_t != noone) _hov = room_resizing_t;
    	
    	draw_set_color(_hov == 4? COLORS._main_accent : COLORS._main_icon);
    	draw_rectangle_dashed(_cx0, _cy0, _cx1, _cy1, 1 + (_hov == 4));
    	
    	var _padL = abs(_area[0]);
    	var _padT = abs(_area[1]);
    	var _padR = abs(_area[2] - rw);
    	var _padB = abs(_area[3] - rh);
    	var _cx   = _x + rw * _s / 2;
    	var _cy   = _y + rh * _s / 2;
    	
    	if(_padL != 0) {
    		draw_set_color(COLORS._main_icon);
    		draw_line_dashed(_cx0, _cy, _x0, _cy);
    		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon_light);
    		draw_text((_cx0 + _x0) / 2, _cy, _padL);
    	}
    	
    	if(_padR != 0) {
    		draw_set_color(COLORS._main_icon);
    		draw_line_dashed(_x1, _cy, _cx1, _cy);
    		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon_light);
    		draw_text((_x1 + _cx1) / 2, _cy, _padR);
    	}
    	
    	if(_padT != 0) {
    		draw_set_color(COLORS._main_icon);
    		draw_line_dashed(_cx, _cy0, _cx, _y0);
    		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon_light);
    		draw_text(_cx, (_cy0 + _y0) / 2, _padT);
    	}
    	
    	if(_padB != 0) {
    		draw_set_color(COLORS._main_icon);
    		draw_line_dashed(_cx, _y1, _cx, _cy1);
    		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon_light);
    		draw_text(_cx, (_y1 + _cy1) / 2, _padB);
    	}
    	
    	draw_anchor(room_resizing_hov[0], _cx0, _cy0, ui(10));
    	draw_anchor(room_resizing_hov[1], _cx1, _cy0, ui(10));
    	draw_anchor(room_resizing_hov[2], _cx0, _cy1, ui(10));
    	draw_anchor(room_resizing_hov[3], _cx1, _cy1, ui(10));
    	
    	if(room_resizing_t == noone) {
	    	if(_hov > noone && mouse_press(mb_left, active)) {
	    		room_resizing_t  = _hov;
	    		room_resizing_ss = [ _area[0], _area[1], _area[2], _area[3] ];
			    room_resizing_mx = _mx;
			    room_resizing_my = _my;
	    	}
	    	
    	} else {
    		var _dx = (_mx - room_resizing_mx) / _s;
    		var _dy = (_my - room_resizing_my) / _s;
    		var _sn = 8 / _s;
    		var _arss = room_resizing_ss;
    		var _dgx = undefined;
    		var _dgy = undefined;
    		
    		switch(room_resizing_t) {
    			case 0 : 
    				_area[0] = PANEL_PREVIEW.snapX(round(_arss[0] + _dx));
    				_area[1] = PANEL_PREVIEW.snapY(round(_arss[1] + _dy));
    				
    				if(abs(_area[0]) < _sn)       { _area[0] = 0;  _dgx =  0; }
    				if(abs(_area[1]) < _sn)       { _area[1] = 0;  _dgy =  0; }
    				break;
    				
    			case 1 : 
    				_area[2] = PANEL_PREVIEW.snapX(round(_arss[2] + _dx));
    				_area[1] = PANEL_PREVIEW.snapY(round(_arss[1] + _dy));
    				
    				if(abs(_area[2] - rw) < _sn)  { _area[2] = rw; _dgx = rw; }
    				if(abs(_area[1]) < _sn)       { _area[1] = 0;  _dgy =  0; }
    				break;
    				
    			case 2 : 
    				_area[0] = PANEL_PREVIEW.snapX(round(_arss[0] + _dx));
    				_area[3] = PANEL_PREVIEW.snapY(round(_arss[3] + _dy));
    				
    				if(abs(_area[0]) < _sn)       { _area[0] = 0;  _dgx =  0; }
    				if(abs(_area[3] - rh) < _sn)  { _area[3] = rh; _dgy = rh; }
    				break;
    				
    			case 3 : 
    				_area[2] = PANEL_PREVIEW.snapX(round(_arss[2] + _dx));
    				_area[3] = PANEL_PREVIEW.snapY(round(_arss[3] + _dy));
    				
    				if(abs(_area[2] - rw) < _sn)  { _area[2] = rw; _dgx = rw; }
    				if(abs(_area[3] - rh) < _sn)  { _area[3] = rh; _dgy = rh; }
    				break;
    				
				case 4 : 
    				var _ww = _area[2] - _area[0];
    				var _hh = _area[3] - _area[1];
    				
    				_area[0] = PANEL_PREVIEW.snapX(round(_arss[0] + _dx));
    				_area[1] = PANEL_PREVIEW.snapY(round(_arss[1] + _dy));
    				_area[2] = PANEL_PREVIEW.snapX(round(_arss[2] + _dx));
    				_area[3] = PANEL_PREVIEW.snapY(round(_arss[3] + _dy));
    				
    				if(abs(_area[0]) < _sn) {
    					_area[0] = 0;
    					_area[2] = _ww;
    					_dgx = 0;
    					
    				} else if(abs(_area[2] - rw) < _sn) {
    					_area[2] = rw;
    					_area[0] = rw - _ww;
    					_dgx = rw;
    					
    				}
    				
    				if(abs(_area[1]) < _sn) {
    					_area[1] = 0;
    					_area[3] = _hh;
    					_dgy = 0;
    					
    				} else if(abs(_area[3] - rh) < _sn) {
    					_area[3] = rh;
    					_area[1] = rh - _hh;
    					_dgy = rh;
    					
    				}
    				break;
    		}
    		
    		draw_set_color(COLORS._main_accent);
    		if(_dgx != undefined) draw_line_width(_x + _dgx * _s, 0, _x + _dgx * _s, WIN_H, 2);
    		if(_dgy != undefined) draw_line_width(0, _y + _dgy * _s, WIN_W, _y + _dgy * _s, 2);
    		
    		if(mouse_release(mb_left))
    			room_resizing_t = noone;
    	}
    }
    
    static step = function() {
    	
    }
    
    static update = function() {
    	if(gmRoom == noone) return;
    	
    	var _width  = gmRoom.roomSettings.Width;
    	var _height = gmRoom.roomSettings.Height;
    	
    	var _prev = outputs[0].getValue();
    	_prev = surface_verify(_prev, _width, _height);
    	
    	for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
    		var _in  = inputs[i];
    		var _val = _in.getValue();
    		var _key = _in.attributes.layerName;
    		var _lay = layerMap[$ _key];
    		inputMap[$ _key] = _in;
    		
    		if(is(_lay, GMRoom_Tile)) {
    			_in.name = _lay.name;
    			_in.setType(VALUE_TYPE.struct);
    			_in.getEditWidget().shorted = true;
    			
    			var _tw = _lay.tiles.SerialiseWidth;
				var _th = _lay.tiles.SerialiseHeight;
				
				var _tdata = struct_try_get(_val, "data", []);
				var _tset  = struct_try_get(_val, "tileset", noone);
				var _tprev = struct_try_get(_val, "preview", noone);
				
				_lay.preview = _tprev;
				
				if(_tset && _tset.gmTile) {
					_lay.tilesetId.name = _tset.gmTile.name;
					_lay.tilesetId.path = _tset.gmTile.key;
				}
				
				_lay.setArray(_tdata);
    		}
    	}
    	
    	surface_set_target(_prev);
    	DRAW_CLEAR
	    	for( var i = array_length(layers) - 1; i >= 0; i-- ) {
	    		var _l = layers[i].layer;
	    		if(!is_surface(_l.preview)) _l.refreshPreview();
	    		
	    		draw_surface_safe(_l.preview);
	    	}
    	surface_reset_target();
    	
    	outputs[0].setValue(_prev);
    	gmRoom.sync();
    }
    
    ////- Serialize
    
	static attributeSerialize = function() {
		var _attr = {
			gm_key: gmRoom == noone? noone : gmRoom.key,
		};
		
		return _attr; 
	}
	
	static attributeDeserialize = function(attr) {
		if(struct_has(attr, "gm_key") && project.bind_gamemaker)
			bindRoom(project.bind_gamemaker.getResourceFromPath(attr.gm_key));
	}
	
	static postApplyDeserialize = function() {
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _in = inputs[i];
    		inputMap[$ _in.attributes.layerName] = _in;
		}
	}
}
