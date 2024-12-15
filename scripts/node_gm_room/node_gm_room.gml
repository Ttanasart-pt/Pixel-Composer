function Node_GMRoom(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "GMRoom";
	color  = COLORS.node_blend_input;
	
    gmRoom   = noone;
    layers   = [];
    layerMap = {};
    
    newInput( 0, nodeValue_Vec2("Room size", self, [ 16, 16 ]));
    
    newInput( 1, nodeValue_Bool("Persistance", self, false));
    
    layer_selecting = noone;
    tb_depth = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ {
    	if(layer_selecting == noone) return;
    	layer_selecting.raw.depth = round(v);
    });
    
    tb_depth.label = "Depth";
    tb_depth.font  = f_p3;
    
	layers_renderer  = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(gmRoom == noone) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, ui(28), COLORS.node_composite_bg_blend, 1);	
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + _w / 2, _y + ui(14), "No data");
			return ui(28);
		}
		
		var _amo = array_length(gmRoom.layers);
		var hh   = ui(28);
		var _h   = hh * _amo + ui(16);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		for( var i = 0, n = array_length(gmRoom.layers); i < n; i++ ) {
			var _yy = _y + ui(8) + i * hh;
			var _l  = gmRoom.layers[i];
			var _exposed = struct_has(inputMap, _l.name);
			
			var cc = layer_selecting == _l? COLORS._main_text_accent : COLORS._main_text_sub;
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _yy, _x + _w, _yy + hh - 1)) {
				cc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus))
					layer_selecting = layer_selecting == _l? noone : _l;
			}
			
			if(_exposed) draw_sprite_ui_uniform(THEME.animate_clock, 2, _x + ui(20),_yy + hh / 2, 1, COLORS._main_accent);
			
			draw_sprite_ui_uniform(s_gmlayer, _l.index, _x + ui(44), _yy + hh / 2, 1, cc);
			draw_set_text(f_p2, fa_left, fa_center, cc);
			draw_text_add(_x + ui(64), _yy + hh / 2, _l.name);
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
		var _wpr = new widgetParam(_wdx, _wdy, _wdw, _wdh, _l.raw.depth, {}, _m, layer_renderer.rx, layer_renderer.ry);
	    _wpr.color = COLORS._main_icon_light;
	    
		tb_depth.setFocusHover(_focus, _hover);
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
            draw_sprite_ext(s_node_tileset, 0, _wdx + ui(32) / 2, _wdy + _wdh / 2, .25, .25);
			
			_yy += _wdh + ui(8);
			_h  += _wdh + ui(8);
			
			_wdy = _yy;

			draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + ui(16), _wdy + _wdh / 2, "Tile count");
			
			draw_sprite_stretched_ext(THEME.textbox, 3, _wdx,            _wdy, _wdw / 2, _wdh, COLORS._main_icon_light);
			draw_sprite_stretched_ext(THEME.textbox, 3, _wdx + _wdw / 2, _wdy, _wdw / 2, _wdh, COLORS._main_icon_light);
			
			var _tw    = _l.tiles.SerialiseWidth;
			var _th    = _l.tiles.SerialiseHeight;
			
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
			draw_text_add(_wdx +            _wdw / 4, _wdy + _wdh / 2, _tw);
			draw_text_add(_wdx + _wdw / 2 + _wdw / 4, _wdy + _wdh / 2, _th);
			
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
    	["Room settings", false], 0, 1, 
    	["Layers",        false], 
    	
    	layers_renderer,
    	new Inspector_Spacer(ui(4)), 
    	layer_renderer,
    	
    	["Data",         true], 
	];
	
	static createNewInput = function() {
		var index = array_length(inputs);
		var _jun  = newInput(index, nodeValue("Data", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ));
		
		array_push(input_display_list, index);
		
		return _jun;
	} 
	setDynamicInput(1, false);
	
    ////- GM
    
    static bindRoom = function(_gmRoom) {
    	gmRoom   = _gmRoom;
    	layers   = [];
    	layerMap = {};
    	if(_gmRoom == noone) return;
    	
    	gmRoom.gmBinder.nodeMap[$ gmRoom.key] = self;
    	
    	layers = gmRoom.layers;
    	for( var i = 0, n = array_length(layers); i < n; i++ ) 
    		layerMap[$ layers[i].name] = layers[i];
    	
    	var _settings    = gmRoom.raw.roomSettings;
    	var _width       = _settings.Width;
    	var _height      = _settings.Height;
    	var _persistance = _settings.persistent;
    	
    	inputs[0].setValue([_width, _height]);
    	inputs[1].setValue(_persistance);
    }
    
	static exposeData = function(_layer) {
		var _in = createNewInput();
		_in.name = _layer.name;
		_in.attributes.layerName = _layer.name;
		
		if(is(_layer, GMRoom_Tile)) {
			_in.setType(VALUE_TYPE.integer);
			
			var _tileset = gmRoom.gmBinder.getNodeFromPath(_layer.tileset.key, x - ui(320), y);
			_tileset.bindTile(_layer.tileset);
			
			var _tiler = nodeBuild("Node_Tile_Drawer", x - ui(160), y).skipDefault();
			_tiler.bindTile(_layer);
			
			_tiler.inputs[0].setFrom(_tileset.outputs[0]);
			_in.setFrom(_tiler.outputs[3]);
		}
		
	}
    
    ////- Update
    
    static step = function() {
    	
    }
    
    static update = function() {
    	if(gmRoom == noone) return;
    	
    	for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
    		var _in  = inputs[i];
    		var _val = _in.getValue();
    		var _key = _in.attributes.layerName;
    		var _lay = layerMap[$ _key];
    		inputMap[$ _key] = _in;
    		
    		if(is(_lay, GMRoom_Tile)) {
    			_in.setType(VALUE_TYPE.integer);
    			
    			var _tw = _lay.tiles.SerialiseWidth;
				var _th = _lay.tiles.SerialiseHeight;
				var _tile = array_verify(_val, _tw * _th);
				var _ctil = [];
				
				var _type = _tile[0];
				var _runn = 1;
				for( var j = 1, m = array_length(_tile); j < m; j++ ) {
					if(_tile[j] == _type) _runn++
					else {
						array_push(_ctil, -_runn, _type);
						_type = _tile[j];
						_runn = 1;
					}
				}
				
				array_push(_ctil, -_runn, _type);
				
				if(array_length(_ctil) < array_length(_tile)) {
					_lay.raw.tiles.TileCompressedData = _ctil;
					_lay.raw.tiles.TileDataFormat     = 1;
					
				} else {
					_lay.raw.tiles.TileSerialiseData = _tile;
					struct_remove(_lay.raw.tiles, "TileDataFormat");
				}
    		}
    	}
    	
    	// gmRoom.sync();
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
