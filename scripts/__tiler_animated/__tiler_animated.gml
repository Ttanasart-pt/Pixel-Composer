function tiler_brush_animated(_refresh, _index = []) constructor {
	name  = "animated";
    index = _index;
    open  = false;
    size  = array_length(index);
    refresh = _refresh;
    
    preview_surface      = noone;
    preview_surface_tile = noone;
    
    tb_length = textBox_Number(function(n) /*=>*/ { 
    	if(n > 0) array_resize(index, n); 
    	size = array_length(index); 
    	refresh();
    }).setFont(f_p3);
    
    ////- Serialize
    
    static serialize = function() {
    	var m = {
    		name, 
    		index, 
    		size, 
    	};
    	
    	return m;
    }
    
    static deserialize = function(m) {
    	name  = m[$ "name"]  ?? name;
    	index = m[$ "index"] ?? index;
    	size  = m[$ "size"]  ?? array_length(index);
    	
    	return self;
    }
}