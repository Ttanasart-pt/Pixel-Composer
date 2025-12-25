function ase_tileset(_name, _data) constructor {
	name   = _name;
	data   = _data;
	expand = true;
	
	// Assume 32 bit tile data
	
	type = data[$ "Flag"];
	
	tileWidth  = data[$ "Tile width"];
	tileHeight = data[$ "Tile height"];
	tileAmount = data[$ "Tile amount"];
	
	tileSurfaceWidth  = tileWidth;
	tileSurfaceHeight = tileHeight * tileAmount;
	
	surface      = undefined;
	tileSurfaces = undefined;
	
	static getSurface = function() {
		if(is_surface(surface)) return surface;
		
		if(type & (1 << 1)) {
			var tileBuffer = data[$ "Buffer"];
			if(!buffer_exists(tileBuffer)) {
				noti_warning("ASE: Tileset data not found.");
				return undefined;
			}
			
			var surf = surface_create(tileSurfaceWidth, tileSurfaceHeight);
			buffer_set_surface(tileBuffer, surf, 0);
			surface = surf;
		}
		
		return surface;
	}
	
	static getTileSurfaces = function() {
		if(is_array(tileSurfaces)) return tileSurfaces;
		
		var _surf = getSurface();
		if(!is_surface(_surf)) return undefined;
		
		tileSurfaces = array_create(tileAmount);
		for( var i = 0; i < tileAmount; i++ ) {
			tileSurfaces[i] = surface_create(tileWidth, tileHeight);
			var _dy = -i * tileHeight;
			
			surface_set_shader(tileSurfaces[i]);
				draw_surface(_surf, 0, _dy);
			surface_reset_shader();
		}
	}
	
	static getTile = function(_index) {
		if(_index < 0 || _index >= tileAmount) return undefined;
		
		var _tiles = getTileSurfaces();
		
		return array_safe_get_fast(_tiles, _index);
	} 
}

