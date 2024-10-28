function Node_Tile_Tilemap_Export(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
    name  = "Export Tilemap";
    
    newInput( 0, nodeValue_Surface("Tilemap", self, noone));
    
    newInput( 1, nodeValue_Path("Path", self, ""))
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "" })
		.setVisible(true);
    
    export_format = [ "CSV", "JSON" ];
    newInput( 2, nodeValue_Enum_Scroll("Format", self, 0, export_format));
    
	insp1UpdateTooltip   = "Export";
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function(_fromValue = false) {
		export();
	}
	
    static export = function() {
	    var tilemap = inputs[0].getValue();
	    var path    = inputs[1].getValue();
	    var format  = inputs[2].getValue();
	    
	    if(!is_surface(tilemap)) return;
	    
	    var _form = surface_get_format(tilemap);
	    if(_form != surface_rgba16float) {
	        noti_warning("Invalid tilemap type (RGBA16float only)")
	        return; 
	    }
	    
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
    				noti.path = filename_dir(path);
    				noti.setOnClick(function() /*=>*/ { shellOpenExplorer(self.path); }, "Open in explorer", THEME.explorer);
    				
            	} else {
            	    
            	}
	            break;
	            
	    }
	    
	}
}