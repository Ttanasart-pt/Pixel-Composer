function Node_Tile_Rule(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
    name  = "Tileset Rule";
    
    newInput( 0, nodeValue_Tileset("Tileset", self, noone))
    	.setVisible(true, true);
    
    newInput( 1, nodeValue_Surface("Tilemap", self, noone));
    
    newInput( 2, nodeValueSeed(self, VALUE_TYPE.float));
    
	newOutput(0, nodeValue_Output("Rendered", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Tilemap", self, VALUE_TYPE.surface, noone));
	
	newOutput(2, nodeValue_Output("Tileset", self, VALUE_TYPE.tileset, noone));
	
	rules = new Tileset_Rule(noone);
	
	input_display_list = [ 2, 
	    ["Tile data", false], 0, 1, 
		["Rules",     false, noone, rules.b_toggle ], rules,
	];
	
	output_display_list = [ 2, 1, 0 ];
	
	static update = function(frame = CURRENT_FRAME) {
    	var tileset = inputs[0].getValue();
		var tilemap = inputs[1].getValue();
		var _seed   = inputs[2].getValue();
		
		outputs[2].setValue(tileset);
		if(tileset == noone) return;
		
		rules.setTileset(tileset);
		if(!is_surface(tilemap)) return;
		
		var _tileSiz = tileset.tileSize;
		var _mapSize = surface_get_dimension(tilemap);
		
		var _outDim  = [ _tileSiz[0] * _mapSize[0], _tileSiz[1] * _mapSize[1] ];
	    var _tileOut = surface_verify(outputs[0].getValue(), _outDim[0],  _outDim[1]);
	    var _tileMap = surface_verify(outputs[1].getValue(), _mapSize[0], _mapSize[1], surface_rgba16float);
	    var _applied = rules.apply(tilemap, _seed);
	    
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
	    
	    outputs[0].setValue(_tileOut);
	    outputs[1].setValue(_tileMap);
	}
	
	static attributeSerialize = function() {
		var _attr = {
			ruleTiles: rules.ruleTiles,
		};
		
		return _attr; 
	}
	
	static attributeDeserialize = function(attr) {
		var _rule = struct_try_get(attr, "ruleTiles",     []);
		
		for( var i = 0, n = array_length(_rule); i < n; i++ )
			rules.ruleTiles[i] = new tiler_rule().deserialize(_rule[i]);
	}
	
}