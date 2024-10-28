function tiler_rule_replacement(_index) constructor {
	index = _index;
}

function tiler_rule() constructor {
	name = "rule";
    open = false;
    active = true;
    
    range           = 1;
    size            = [ 1, 1 ];
    probability     = 100;
    _probability    = 1;
    
    selection_rules    = array_create(9, -1);
    selection_rules[4] = -10000;
    replacements       = [];
    
    sl_prop = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { probability = v; })
    				.setSlideRange(0, 100);
    sl_prop.suffix = "%";
    sl_prop.font   = f_p3;
    
    __aut = [];
    __sel = [];
    
    static shader_select = function(tileset) {
    	shader_set_i("range",        range);
    	
    	selection_rules = array_verify_ext(selection_rules, (size[0] + range * 2) * (size[1] + range * 2), function() /*=>*/ {return -1} );
    	
	    __aut = [];
	    __sel = [];
    	var autI = [];
	    
    	for( var i = 0, n = array_length(selection_rules); i < n; i++ ) {
    		var _r = selection_rules[i];
    		
    		if(is_array(_r)) {
    			var _auI = _r[1];
    			array_push(__sel, 10000 + _auI);
    			array_push_unique(autI, _auI);
    		} else 
    			array_push(__sel, _r);
    	}
    	
    	for( var i = 0, n = array_length(autI); i < n; i++ ) {
    		var _i = autI[i];
    		var _t = tileset.autoterrain[_i];
    		
    		var _ind = 64 * i;
    		__aut[_ind] = array_length(_t.index);
    		for( var j = 0, m = array_length(_t.index); j < m; j++ )
    			__aut[_ind + 1 + j] = _t.index[j];
    	}
    	
    	shader_set_f("selection",      __sel);
    	shader_set_f("selectionGroup", __aut);
    	
    }
    
    static shader_submit = function(tileset) {
    	shader_set_i("range",        range);
    	shader_set_f("probability",  probability / 100);
    	
    	shader_set_f("size",           size);
    	shader_set_f("selection",      __sel);
    	shader_set_f("selectionGroup", __aut);
    	
    	var rep = [];
    	var rsz = size[0] * size[1];
    	
    	for( var i = 0, n = array_length(replacements); i < n; i++ ) {
    		var _r   = replacements[i];
    		_r.index = array_verify_ext(_r.index, rsz, function() /*=>*/ {return -1} );
    		array_append(rep, _r.index);
    	}
    	
    	shader_set_f("replacements",     rep);
    	shader_set_i("replacementCount", array_length(replacements));
    }
    
    static deserialize = function(_struct) {
        name   = struct_try_get(_struct, "name",   name);
        size   = struct_try_get(_struct, "size",   size);
        range  = struct_try_get(_struct, "range",  range);
        active = struct_try_get(_struct, "active", active);
        
        selection_rules = struct_try_get(_struct, "selection_rules", selection_rules);
		probability     = struct_try_get(_struct, "probability",     probability);
		
		var _rep = struct_try_get(_struct, "replacements", noone);
        if(_rep != noone) {
        	for( var i = 0, n = array_length(_rep); i < n; i++ )
        		replacements[i] = new tiler_rule_replacement(_rep[i].index);
        }
        
        return self;
    }
}