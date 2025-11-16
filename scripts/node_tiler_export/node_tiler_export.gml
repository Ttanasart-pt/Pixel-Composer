function Node_Tile_Tilemap_Export(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
    name  = "Export Tilemap";
    
    newInput( 0, nodeValue_Surface("Tilemap"));
    
    newInput( 1, nodeValue_Path("Path"))
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "" })
		.setVisible(true);
    
    export_format = [ "CSV", "GameMaker" ];
    newInput( 2, nodeValue_Enum_Scroll("Format", 0, export_format));
    
    newInput( 3, nodeValue_Enum_Scroll("GM Export Type", 0, [ "Room" ]));
    
    newInput( 4, nodeValue_Path("GM Room"))
    	.setDisplay(VALUE_DISPLAY.path_load, { filter: "GameMaker room|*.yy" })
    	.setVisible(false, false);
    
    newInput( 5, nodeValue_Text("GM Room Name", "rmRoom"));
    
    newInput( 6, nodeValue_Text("GM Layer Name", "Tiles_1"));
    
    newInput( 7, nodeValue_Tileset())
    	.setVisible(true, true);
    
    newInput( 8, nodeValue_Path("GD Scene"))
    	.setDisplay(VALUE_DISPLAY.path_load, { filter: "Godot scene|*.tscn" })
    	.setVisible(false, false);
    
    input_display_list = [ 7, 0, 
    	["Output",    false], 1, 2, 
    	["GameMaker",  true], 3, 4, 5, 6, 
    	["Godot",      true], 8, 
	];
    
	setTrigger(1, "Export", [ THEME.sequence_control, 1, COLORS._main_value_positive ], function() /*=>*/ {return export()});
	
    static export = function() {
	    var tilemap = inputs[0].getValue();
	    var path    = inputs[1].getValue();
	    var format  = inputs[2].getValue();
	    var tileset = inputs[7].getValue();
	    
	    if(tileset == noone)     return;
	    if(!is_surface(tilemap)) return;
	    
	    var _form = surface_get_format(tilemap);
	    if(_form != surface_rgba16float) {
	        noti_warning("Invalid tilemap type (RGBA16float only)", noone, self)
	        return; 
	    }
	    
	    var tileSize = tileset.tileSize;
	    var tileName = tileset.getDisplayName();
	    
	    var _dim  = surface_get_dimension(tilemap);
	    var _buff = buffer_from_surface(tilemap, false); buffer_to_start(_buff);
	    var _data = array_create(_dim[1]);
	    
	    for( var i = 0; i < _dim[1]; i++ ) {
	        _data[i] = array_create(_dim[0]);
    	    for( var j = 0; j < _dim[0]; j++ ) {
    	        var _a = array_create(4);
    	        
    	        _a[0] = buffer_read(_buff, buffer_f16);
    	        _a[1] = buffer_read(_buff, buffer_f16);
    	        _a[2] = buffer_read(_buff, buffer_f16);
    	        _a[3] = buffer_read(_buff, buffer_f16);
    	        
    	        _data[i][j] = _a[0];
    	    }
	    }
	    
	    buffer_delete(_buff);
	    
	    switch(export_format[format]) {
	        case "CSV" :
	            path = filename_change_ext(path, ".csv");
	            if(file_exists_empty(path)) file_delete(path);
	            
            	var f = file_text_open_write(path);
            	if(f) {
            	    for( var i = 0; i < _dim[1]; i++ ) {
            	        var _txt = string_join_ext(",", _data[i]);
                	    file_text_write_string(f, _txt);
                	    file_text_writeln(f);
            	    }
            	    
                	file_text_close(f);
                	
                	var _txt = $"Export tilemap complete.";
    				logNode(_txt);
    				
    	            var noti  = log_message("EXPORT", _txt, THEME.noti_icon_tick, COLORS._main_value_positive, false);
    				noti.setOnClick(function(p) /*=>*/ { shellOpenExplorer(p); }, "Open in explorer", THEME.explorer, path);
    				
            	}
	            break;
	            
        	case "GameMaker":
        		var gmType  = inputs[3].getValue();
        		var gmRoom  = inputs[4].getValue();
        		var gmRname = inputs[5].getValue();
        		var gmLname = inputs[6].getValue();
        		
        		// inputs[5].setVisible(gmType == 0);
        		// inputs[6].setVisible(gmType == 1);
        		
        		var _tile_arr = array_create(_dim[0] * _dim[1]), ind = 0;
        		
        		for( var i = 0; i < _dim[0]; i++ ) 
        		for( var j = 0; j < _dim[1]; j++ ) {
            	    _tile_arr[ind++] = _data[i][j];
        	    }
        		
        		var _templateDir = filepath_resolve("%APP%/data/TemplateStrings/");
    			
        		if(gmType == 0) {
	    			var _template_str = file_read_all(_templateDir + "tileset_gamemaker2_room.yy");
	    			var _template_map = json_try_parse(_template_str);
	    			
	    			if(_template_map == -1) return;
	    			
        			_template_map.parent.name = gmRname;
        			_template_map.parent.path = $"folders/{gmRname}.yy";
        			
        			var _layer = _template_map.layers[0];
        			
        			_layer.name  = gmLname;
        			_layer.gridX = tileSize[0] / 2;
        			_layer.gridY = tileSize[1] / 2;
        			_layer.tilesetId.name = tileName;
        			_layer.tilesetId.path = $"tilesets/{tileName}/{tileName}.yy";
        			
        			_layer.tiles.SerialiseWidth    = _dim[0];
        			_layer.tiles.SerialiseHeight   = _dim[1];
        			_layer.tiles.TileSerialiseData = _tile_arr;
        			
        			path = filename_change_ext(path, ".yy");
	            	if(file_exists_empty(path)) file_delete(path);
	            	
        			file_text_write_all(path, json_stringify(_template_map, true));
        			
        			var _txt = $"Export GameMaker room complete.";
    				logNode(_txt);
    				
    	            var noti  = log_message("EXPORT", _txt, THEME.noti_icon_tick, COLORS._main_value_positive, false);
    				noti.setOnClick(function(p) /*=>*/ { shellOpenExplorer(p); }, "Open in explorer", THEME.explorer, path);
        		} 
        		
        		break;
        		
    		case "Godot":
        		var gdScene = inputs[8].getValue();
    			if(!file_exists_empty(gdScene)) return;
    			
    			var _gdData = file_read_all(gdScene);
        		break;
	    }
	    
	}
}