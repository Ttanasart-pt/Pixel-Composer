function Node_Tile_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
    name  = "Render Tilemap";
    
    newInput( 0, nodeValue_Tileset())
    	.setVisible(true, true);
    
    newInput( 1, nodeValue_Surface("Tilemap"));
    
    newInput( 2, nodeValue_Bool("Animated", false));
    
	newOutput(0, nodeValue_Output("Rendered", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
	    ["Tile data", false], 0, 1, 2, 
	];
	
	////- Node
	
	temp_surface = [noone];
	output_display_list = [ 0 ];
	
	static update = function(frame = CURRENT_FRAME) {
    	var tileset = inputs[0].getValue();
		var tilemap = inputs[1].getValue();
		
		if(tileset == noone)     return;
		if(!is_surface(tilemap)) return;
		
		var _tileSiz = tileset.tileSize;
		var _mapSize = surface_get_dimension(tilemap);
		
		var _outDim  = [ _tileSiz[0] * _mapSize[0], _tileSiz[1] * _mapSize[1] ];
		
		var _outSurf = outputs[0].getValue();
	        _outSurf = surface_verify(_outSurf, _outDim[0],  _outDim[1]);
	    
	    surface_set_shader(_outSurf, sh_draw_tile_map, true, BLEND.over);
	        shader_set_2("dimension", _outDim);
	        
	        shader_set_surface("indexTexture", tilemap);
	        shader_set_2("indexTextureDim", surface_get_dimension(tilemap));
	        
			shader_set_f("frame", CURRENT_FRAME);
	        tileset.shader_submit();
			
	        draw_empty();
	    surface_reset_shader();
	    
	    outputs[0].setValue(_outSurf);
	}
}