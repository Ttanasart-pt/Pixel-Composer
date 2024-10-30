function Node_Tile_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
    name  = "Render Tilemap";
    
    newInput( 0, nodeValue_Tileset("Tileset", self, noone))
    	.setVisible(true, true);
    
    newInput( 1, nodeValue_Surface("Tilemap", self, noone));
    
    newInput( 2, nodeValue_Bool("Animated", self, false));
    
	newOutput(0, nodeValue_Output("Rendered", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
	    ["Tile data", false], 0, 1, 2, 
	];
	
	output_display_list = [ 0 ];
	
	static update = function(frame = CURRENT_FRAME) {
    	var tileset = inputs[0].getValue();
		var tilemap = inputs[1].getValue();
		
		if(tileset == noone)     return;
		if(!is_surface(tilemap)) return;
		
		var _tileSiz = tileset.tileSize;
		var _mapSize = surface_get_dimension(tilemap);
		
		var _outDim  = [ _tileSiz[0] * _mapSize[0], _tileSiz[1] * _mapSize[1] ];
	    var _tileOut = surface_verify(outputs[0].getValue(), _outDim[0],  _outDim[1]);
	    var _tileMap = surface_verify(outputs[1].getValue(), _mapSize[0], _mapSize[1], surface_rgba16float);
	    
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
	}
}