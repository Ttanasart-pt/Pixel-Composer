function ase_cel(_layer, _data, _file) constructor {
	layerTarget = _layer;
	data = _data;
	file = _file;
	
	alpha = (data[$ "Opacity"] ?? 255) / 255;
	
	static checkSurface = function() {
		var width  = data[$ "Width"];
		var height = data[$ "Height"];
		var __zero = [0,0,0,0];
		data[$ "Surface"] = surface_verify(data[$ "Surface"], width, height);
		
		var color  = file[$ "Color depth"];
		if(color == 32) {//rgba 
			buffer_set_surface(data[$ "Buffer"], data[$ "Surface"], 0);
			return;
		}
		
		var size = width * height;
		var buff = buffer_create(size * 4, buffer_fixed, 1);
		buffer_seek(buff, buffer_seek_start, 0);
		buffer_seek(data[$ "Buffer"], buffer_seek_start, 0);
		
		if(color == 16) { //grey
			repeat(size) {
				var _bin = buffer_read(data[$ "Buffer"], buffer_u16);
				buffer_write(buff, buffer_u8, _bin);
				buffer_write(buff, buffer_u8, _bin);
				buffer_write(buff, buffer_u8, _bin);
				buffer_write(buff, buffer_u8, _bin >> 8);
			}
			
		} else if(color == 8) { //index
			var palet  = file[$ "Palette"];
			
			repeat(size) {
				var _bin = buffer_read(data[$ "Buffer"], buffer_u8);
				var cc   = array_safe_get_fast(palet, _bin, __zero);
				
				buffer_write(buff, buffer_u8, cc[0]);
				buffer_write(buff, buffer_u8, cc[1]);
				buffer_write(buff, buffer_u8, cc[2]);
				buffer_write(buff, buffer_u8, cc[3]);
			}
		}
		
		buffer_set_surface(buff, data[$ "Surface"], 0);
	}
	
	static checkTileMap = function() {
		var _tbuff = data[$ "Tile Buffer"];
		if(!buffer_exists(_tbuff)) return;
		
		var _tileset = layerTarget.getTileSet();
		if(!is(_tileset, ase_tileset)) return;
		
		var bitT    = data[$ "Bitmask for tile ID"];
		var bitX    = data[$ "X flip"];
		var bitY    = data[$ "Y flip"];
		var bitR    = data[$ "90CW rotation"];
		
		var twidth  = data[$ "Width"];
		var theight = data[$ "Height"];
		
		var width   = twidth  * _tileset.tileWidth;
		var height  = theight * _tileset.tileHeight;
		
		data[$ "Surface"] = surface_verify(data[$ "Surface"], width, height);
		
		buffer_to_start(_tbuff);
		surface_set_shader(data[$ "Surface"], sh_tile_draw);
			var _tamo = twidth * theight;
			var _col  = 0;
			var _row  = 0;
			
			repeat(_tamo) {
				var dx = _col * _tileset.tileWidth;
				var dy = _row * _tileset.tileHeight;
				
				var ti = buffer_read(_tbuff, buffer_u32);
				
				var tileT = ti & bitT;
				var tileX = ti & bitX;
				var tileY = ti & bitY;
				var tileR = ti & bitR;
				
				var _tile = _tileset.getTile(tileT);
				shader_set_i("tileX", bool(tileX));
				shader_set_i("tileY", bool(tileY));
				shader_set_i("tileR", bool(tileR));
				draw_surface_ext_safe(_tile, dx, dy, 1, 1, 0);
				
				_col++;
				if(_col >= twidth) {
					_col = 0;
					_row++;
				}
			}
		surface_reset_shader();
	}
	
	static getSurface = function() {
		var type = data[$ "Cel type"];
		
		if(type == 0) return noone; // Raw Image Data (unused, compressed image is preferred)
			
		if(type == 1) { // Linked Cel
			var frTarget = data[$ "Frame position"];
			var cel = layerTarget.getCelRaw(frTarget);
			if(!cel) return noone;
			return cel.getSurface();
			
		}
		
		if(type == 2) { // Compressed Image
			checkSurface();
			return data[$ "Surface"];
		}
		
		if(type == 3) { // Compressed Tilemap
			checkTileMap();
			return data[$ "Surface"];
		}
		
		return noone;
	}
	
	function toStr() {
		return {
			type: data[$ "Cel type"], 
			link: data[$ "Frame position"]
		};
	}
	
	function toString() {
		var st = json_stringify(toStr());
		
		return $"[ase cel] {st}";
	}
}