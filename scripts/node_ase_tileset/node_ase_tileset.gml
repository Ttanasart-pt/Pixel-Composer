function Node_ASE_Tileset(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "ASE Tileset";
	
	newInput(0, nodeValue("ASE data", self, CONNECT_TYPE.input, VALUE_TYPE.object, undefined ))
		.setIcon(THEME.junc_aseprite, c_white).setVisible(false, true).rejectArray();
	newInput(1, nodeValue_Text( "Tileset Name" )).rejectArray();
	
	newOutput(0, nodeValue_Output("Tiles",         VALUE_TYPE.surface, []    ));
	newOutput(1, nodeValue_Output("Tile Size",     VALUE_TYPE.integer, [1,1] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput(2, nodeValue_Output("Tile Amount",   VALUE_TYPE.integer, 0     ));
	newOutput(3, nodeValue_Output("Tileset name",  VALUE_TYPE.text,    ""    ));
	
	tile_renderer   = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var by = _y;
		var _h = ui(8);
		
		var tsize = ui(32);
		var tcol  = floor((_w - ui(8)) / tsize);
		
		var _tname = inputs[1].getValue();
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, by, _w, tile_renderer.h, COLORS.node_composite_bg_blend, 1);
		by += ui(4);
		
		if(!is(ase_data, Node)) return _h;
		var tilesets = ase_data.tilesets;
		
		for( var i = 0, n = array_length(tilesets); i < n; i++ ) {
			var  tile = tilesets[i];
			var _name = tile.name;
			var  hh   = ui(24);
			
			var hv = _hover && point_in_rectangle(_m[0], _m[1], _x, by, _x + _w, by + hh);
			draw_sprite_ui(THEME.tileset, 0, _x + ui(16), by + hh / 2 + ui(2), .75, .75, 0, hv? COLORS._main_icon_light : COLORS._main_icon);
			draw_set_text(f_p2, fa_left, fa_center, _tname == _name? COLORS._main_text_accent : COLORS._main_text);
			draw_text_add(_x + ui(16 + 12), by + hh / 2, _name);
			
			if(hv && mouse_lpress(_focus)) inputs[1].setValue(_name);
			
			var _c = 0;
			var ty = by + hh + ui(4);
			hh += tsize + ui(4);
			
			for( var j = 0; j < tile.tileAmount; j++ ) {
				var tx = _x + ui(4) + _c * tsize;
				
				var _tspr = tile.getTile(j);
				if(!is_surface(_tspr)) continue;
				
				draw_surface_fit(_tspr, tx+tsize/2, ty+tsize/2, tsize, tsize);
				draw_sprite_stretched_add(THEME.box_r2, 1, tx, ty, tsize, tsize, c_white, .2);
				
				_c++;
				if(_c >= tcol) {
					_c = 0;
					ty += tsize;
					hh += tsize;
				}
			}
			
			by += hh;
			_h += hh;
		}
		
		tile_renderer.h = _h;
		return _h;
	}); 
	
	input_display_list = [
		tile_renderer, 0, 1, 
	];
	
	////- Node
	
	ase_data = undefined;
	
	static update = function(frame = CURRENT_FRAME) {
		var data   = getInputData(0);
		var _tname = getInputData(1);
		
		outputs[3].setValue(_tname);
		if(!is(data, Node)) return;
		ase_data = data;
		
		var _tile = data.tilesetMap[$ _tname];
		
		if(_tile != undefined) {
			outputs[0].setValue( _tile.tileSurfaces );
			outputs[1].setValue([_tile.tileWidth, _tile.tileHeight]);
			outputs[2].setValue( _tile.tileAmount );
			
		} else 
			outputs[0].setValue([]);
	}
}