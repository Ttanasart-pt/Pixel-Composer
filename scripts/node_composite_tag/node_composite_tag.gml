function Node_Composite_Tag(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Composite Tag";
	
	newInput(0, nodeValue_Dimension(self));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.dynaSurface, noone));
	
	input_display_list = [ 
		["Output",   false], 0, 
		["Surfaces", false], 
	];
	
	static createNewInput = function(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Surface("Surface", self, noone ))
			.setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.dynaSurface);
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { 
		var _df = array_safe_get(draw_transforms, preview_index, noone);
		if(_df == noone) return noone;
		
		var _amo = getInputAmount();
		for( var i = 0; i < _amo; i++ ) {
			if(_node == inputs[input_fix_len + i].getNodeFrom())
				return _df[i];
		}
		
		return noone;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
	    draw_transforms[_array_index] = noone;
	    
	    var _amo = getInputAmount();
	    var _dim = _data[0];
	    var _tagBase = {};
	    
	    for( var i = 0; i < _amo; i++ ) {
	        var _surf   = _data[input_fix_len + i];
	        var _tags   = _surf.tags;
	        var _tagArr = struct_get_names(_tags);
	        
	        for( var j = 0, m = array_length(_tagArr); j < m; j++ ) {
	            var _t = _tagArr[j];
	            
	            if(!struct_has(_tagBase, _t))
	                _tagBase[$ _t] = _tags[$ _t];
	        }
	    }
	    
	    var minx =  infinity;
	    var miny =  infinity;
	    var maxx = -infinity;
	    var maxy = -infinity;
	    
	    for( var i = 0; i < _amo; i++ ) {
	        var _surf    = _data[input_fix_len + i];
	        var _surface = _surf.surfaces[0];
	        var _tags    = _surf.tags;
	        var _tagArr  = struct_get_names(_tags);
	        
	        var _ox = 0;
	        var _oy = 0;
	        var _tagArrAmo = array_length(_tagArr);
	        
	        for( var j = 0, m = _tagArrAmo; j < m; j++ ) {
	            var _t = _tagArr[j];
	            
	            _ox += _tags[$ _t][0] - _tagBase[$ _t][0];
	            _oy += _tags[$ _t][1] - _tagBase[$ _t][1];
	        }
	        
	        _ox /= _tagArrAmo;
	        _oy /= _tagArrAmo;
	        
	        var _sw = surface_get_width(_surface);
	        var _sh = surface_get_height(_surface);
	        
	        minx = min(minx, -_ox);
	        miny = min(miny, -_oy);
	        maxx = max(maxx, -_ox + _sw);
	        maxy = max(maxy, -_oy + _sh);
	    }
        
        var _cx = round(_dim[0] / 2 - (minx + maxx) / 2);
        var _cy = round(_dim[1] / 2 - (miny + maxy) / 2);
        
        _outSurf   = surface_verify(_outSurf, _dim[0], _dim[1]);
        var _trans = array_create(_amo, noone);
        
        surface_set_shader(_outSurf);
            for( var i = 0; i < _amo; i++ ) {
                var _surf    = _data[input_fix_len + i];
                var _surface = _surf.surfaces[0];
                var _tags    = _surf.tags;
                var _tagArr  = struct_get_names(_tags);
                
                var _ox = 0;
                var _oy = 0;
                var _tagArrAmo = array_length(_tagArr);
                
                for( var j = 0, m = _tagArrAmo; j < m; j++ ) {
                    var _t = _tagArr[j];
                    
                    _ox += _tags[$ _t][0] - _tagBase[$ _t][0];
                    _oy += _tags[$ _t][1] - _tagBase[$ _t][1];
                }
                
                _ox /= _tagArrAmo;
                _oy /= _tagArrAmo;
                
                var _xx = round(_cx - _ox);
                var _yy = round(_cy - _oy);
                
                draw_surface(_surface, _xx, _yy);
                _trans[i] = [ _xx, _yy, 1, 1, 0 ];
            }
        surface_reset_shader();
        
        draw_transforms[_array_index] = _trans;

        return _outSurf;
	}
	
}