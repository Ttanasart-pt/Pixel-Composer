function tilemap_convert_object(_color, _target = undefined) constructor {
    color  = _color;
    target = _target;
}

function Node_Tile_Convert(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
    name = "Convert to Tilemap";
    
    tileset = noone;
	attributes.colorMap  = {};
	attributes.colorList = [];
	
    newInput( 0, nodeValue_Surface("Surface", self));
    
    newInput( 1, nodeValue_Tileset("Tileset", self, noone))
    	.setVisible(true, true);
    
    newInput( 2, nodeValue_Bool("Animated", self, false));
    
    newInput( 3, nodeValueSeed(self));
    
	newOutput(0, nodeValue_Output("Rendered", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Tilemap", self, VALUE_TYPE.surface, noone));
	
	newOutput(2, nodeValue_Output("Tileset", self, VALUE_TYPE.tileset, noone));
	
	tile_mapper = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel = noone) {
	    var bx = _x;
		var by = _y;
		
		var bs = ui(24);
		if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _hover, _focus,, THEME.refresh_16) == 2) 
			refreshPalette();
			
		var _cmap = attributes.colorMap;
		var _clrs = attributes.colorList;
		
		var ss  = ui(32);
		var amo = array_length(_clrs);
		var top = bs + ui(8);
		var hh  = top + (amo * (ss + ui(8)) + ui(8));
		var _yy = _y + top;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, hh - top, COLORS.node_composite_bg_blend, 1);
		
		var _sel_x0 = 0;
		var _sel_x1 = 0;
		var _sel_y0 = 0;
		var _sel_y1 = 0;
		
		for( var i = 0; i < amo; i++ ) {
			var cc = _clrs[i];
			var mp = _cmap[$ cc];
			
			var _x0 = _x  + ui(8);
			var _y0 = _yy + ui(8) + i * (ss + ui(8));
			
			draw_sprite_stretched_ext(THEME.color_picker_box, 0, _x0, _y0, ss, ss, c_white, .5);
			draw_sprite_stretched_ext(THEME.color_picker_box, 1, _x0, _y0, ss, ss, cc, 1);
			
			var _x1 = _x0 + ss + ui(32);
			var _x2 = _x + _w - ui(8);
			var _xw = _x2 - _x1;
			
			draw_sprite_ext(THEME.arrow, 0, (_x0 + ss + _x1) / 2, _y0 + ss / 2, 1, 1, 0, c_white, 0.5);
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x1, _y0, _xw, ss, COLORS.node_composite_bg_blend, 1);
			
			if(tileset == noone) continue;
			
			tileset.node_edit = self;
			if(tileset.object_selecting == mp) 
			    draw_sprite_stretched_ext(THEME.ui_panel, 1, _x1, _y0, _xw, ss, COLORS._main_accent);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], _x1, _y0, _x1 + _xw, _y0 + ss)) {
			    draw_sprite_stretched_add(THEME.ui_panel, 1, _x1, _y0, _xw, ss, c_white, 0.25);
			    
			    if(mouse_press(mb_left, _focus))
			        tileset.object_selecting = tileset.object_selecting == mp? noone : mp;
			        
		        if(mouse_press(mb_right, _focus))
		            mp.target = undefined;
			}
			
			var _targ = mp.target;
			
			var _px = _x1 + ui(4);
			var _py = _y0 + ui(4);
			var _pw =  ss - ui(8);
			var _ph =  ss - ui(8);
			
			if(_targ == undefined) {
			    draw_sprite_stretched_ext(THEME.ui_panel, 1, _px, _py, _pw, _ph, COLORS._main_icon);
			    
			} else if(is_array(_targ)) {
			    var _at   = tileset.autoterrain[_targ[1]];
			    var _prin = array_safe_get(_at.index, _at.prevInd, undefined);
			    if(_prin != undefined) tileset.drawTile(_prin, _px, _py, _pw, _ph);
			    
			    draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
			    draw_text_add(_x1 + ss + ui(8), _y0 + ss / 2, _at.name);
			    
			} else {
			    tileset.drawTile(_targ, _px, _py, _pw, _ph);
			    
			    draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
			    draw_text_add(_x1 + ss + ui(8), _y0 + ss / 2, _targ >= 0? $"Tile {_targ}" : $"Animated tile {-_targ - 2}");
			}
			
		}
		
		return hh;
	});
	
	input_display_list  = [ 1, 0, 
	    ["Tile map",     false], 3, 2, 
	    ["Tile convert", false], tile_mapper, 
    ];
	
	output_display_list = [ 2, 1, 0 ];
	temp_surface        = [ 0, 0, 0 ];
	
	static refreshPalette = function() {
		var _surf = inputs[0].getValue();
		
		if(!is_array(_surf)) _surf = [ _surf ];
		
		var _pall = ds_map_create();
		
		for( var i = 0, n = array_length(_surf); i < n; i++ ) {
			var _s = _surf[i];
			if(!is_surface(_s)) continue;
			
			var ww = surface_get_width_safe(_s);
			var hh = surface_get_height_safe(_s);
		
			var c_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
			
			buffer_get_surface(c_buffer, _s, 0);
			buffer_seek(c_buffer, buffer_seek_start, 0);
		
			for( var i = 0; i < ww * hh; i++ ) {
				var b = buffer_read(c_buffer, buffer_u32);
				var c = b & ~(0b11111111 << 24);
				var a = b &  (0b11111111 << 24);
				if(a == 0) continue;
				c = make_color_rgb(color_get_red(c), color_get_green(c), color_get_blue(c));
				_pall[? c] = 1;
			}
		
			buffer_delete(c_buffer);
		}
		
		var palette = ds_map_keys_to_array(_pall);
		var cmap = attributes.colorMap;
		attributes.colorList = [];
		
		for( var i = 0, n = array_length(palette); i < n; i++ ) {
		    array_push(attributes.colorList, palette[i]);
		    cmap[$ palette[i]] = struct_has(cmap, palette[i])? cmap[$ palette[i]] : new tilemap_convert_object(palette[i]);
		}
	}
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING || CLONING) return;
		if(index == 0) refreshPalette();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, params) {
	    
	}
	
	static processData = function(_outData, _data, _output_index, _array_index) { 
	    var _surf     = _data[0];
	    tileset       = _data[1];
	    var _animated = _data[2];
	    var _seed     = _data[3];
	    
	    _outData[2] = tileset;
	    update_on_frame = _animated;
	    
	    if(tileset == noone)   return _outData;
	    if(!is_surface(_surf)) return _outData;
	    
		var _mapSize    = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _mapSize[0], _mapSize[1], surface_rgba16float);
		temp_surface[1] = surface_verify(temp_surface[1], _mapSize[0], _mapSize[1], surface_rgba16float);
		temp_surface[2] = surface_verify(temp_surface[2], _mapSize[0], _mapSize[1], surface_rgba16float);
		
		var _cmap = attributes.colorMap;
		var _clrs = attributes.colorList;
		var _bg   = 0;
		var _rpFr = [];
		var _rpTo = [];
		
		surface_set_target(temp_surface[1]);
		    DRAW_CLEAR BLEND_OVERRIDE draw_surface(_surf, 0, 0); BLEND_NORMAL
		surface_reset_target();
		
		for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
		    var cc = _clrs[i];
			var mp = _cmap[$ cc];
			var tg = mp.target;
			
			if(tg == undefined) continue;
			if(!is_array(tg)) {
			    array_push(_rpFr, cc);
			    array_push(_rpTo, tg >= 0? tg + 1 : tg);
			    continue;
			}
			
			var _at = tileset.autoterrain[tg[1]];
			if(!is(_at, tiler_brush_autoterrain)) continue;
			
			surface_set_shader(temp_surface[_bg], sh_tiler_convert_mask);
			    shader_set_color("target",  cc);
			    shader_set_f("replace", _at.index[_at.prevInd]);
			    
			    draw_surface(temp_surface[!_bg], 0, 0);
			surface_reset_shader();
			
    		surface_set_target(temp_surface[!_bg]);
    		    DRAW_CLEAR BLEND_OVERRIDE draw_surface(temp_surface[_bg], 0, 0); BLEND_NORMAL
    		surface_reset_target();
		    
			_at.drawing_start(temp_surface[!_bg]);
			    draw_surface(temp_surface[_bg], 0, 0);
			_at.drawing_end();
			
			_bg = !_bg;
		}
		
		surface_set_shader(temp_surface[!_bg], sh_tiler_convert);
		    shader_set_palette(_rpFr, "colorFrom", "colorAmount");
		    shader_set_f("colorTo", _rpTo);
		    
		    draw_surface(temp_surface[_bg], 0, 0);
		surface_reset_shader();
		
		var _tileSiz = tileset.tileSize;
	    var _outDim  = [ _tileSiz[0] * _mapSize[0], _tileSiz[1] * _mapSize[1] ];
	    var _tileOut = surface_verify(_outData[0], _outDim[0],  _outDim[1]);
	    var _tileMap = surface_verify(_outData[1], _mapSize[0], _mapSize[1], surface_rgba16float);
	    var _applied = tileset.rules.apply(temp_surface[!_bg], _seed);
	    
	    surface_set_shader(_tileMap, sh_sample, true, BLEND.over);
	        draw_surface(_applied, 0, 0);
	    surface_reset_shader();
	    
	    surface_set_shader(_tileOut, sh_draw_tile_map, true, BLEND.over);
	        shader_set_2("dimension", _outDim);
	        
	        shader_set_surface("indexTexture", _tileMap);
	        shader_set_2("indexTextureDim", surface_get_dimension(_tileMap));
	        
			shader_set_f("frame", CURRENT_FRAME);
	        tileset.shader_submit();
			
	        draw_empty();
	    surface_reset_shader();
	    
	    return [ _tileOut, _tileMap, tileset ];
	}
	
	static attributeDeserialize = function(attr) {
	    struct_append(attributes, attr); 
	    var _map = struct_try_get(attr, "colorMap", noone);
	    
	    if(_map != 0) {
	        var _keys = variable_struct_get_names(_map);
    	    for( var i = 0, n = array_length(_keys); i < n; i++ ) {
    	        var _k = _keys[i];
    	        _map[$ _k] = new tilemap_convert_object(_map[$ _k].color, _map[$ _k].target);
    	    }
    	    
    	    attributes.colorMap = _map;
	    }
	}
}