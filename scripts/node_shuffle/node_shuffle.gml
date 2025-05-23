#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Shuffle", "Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
		addHotkey("Node_Shuffle", "Axis > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 3); });
	});
#endregion

function Node_Shuffle(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shuffle";
	
	newInput(0, nodeValue_Surface("Surface"));
	
	newInput(1, nodeValue_Enum_Scroll("Type", 0, [ "Pixel", "Block" ]));
	
	newInput(2, nodeValueSeed());
	
	newInput(3, nodeValue_Enum_Scroll("Axis", 2, [ "Horizontal", "Vertical", "Both" ]));
	
	newInput(4, nodeValue_IVec2("Block count", [ 4, 4 ]));
	
	newInput(5, nodeValue_Float("Randomness", 1))
	    .setDisplay(VALUE_DISPLAY.slider);
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 2, 
		["Shuffle", false], 1, 5, 3, 4, 
	];
	
	temp_surface = [ noone, noone ];
	
	static processData_prebatch  = function() { 
	    var _type = getSingleValue(1);
	    
	    inputs[3].setVisible(_type == 0);
	    inputs[4].setVisible(_type == 1);
	}
	
	static genShuffled = function(len, rand = 1) {
	    var _indx = array_create_ext(len, function(i) /*=>*/ {return i});
	    
	    for( var i = len - 1; i >= 1; i-- ) {
	        var t = irandom(i);
	        if(random(1) > rand) continue;
	        
	        var _tmp = _indx[i];
	        _indx[i] = _indx[t];
	        _indx[t] = _tmp;
	    }
	    
	    return _indx;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _type = _data[1];
		var _seed = _data[2];
		var _axis = _data[3];
		var _blok = _data[4];
		var _rand = _data[5];
		if(!is_surface(_surf)) return _outSurf;
		
		var _dim = surface_get_dimension(_surf);
		_outSurf        = surface_verify(_outSurf, _dim[0], _dim[1]);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		temp_surface[1] = surface_verify(temp_surface[1], _dim[0], _dim[1]);
		
		random_set_seed(_seed);
		
		switch(_type) {
		    case 0 :
        		surface_set_shader(temp_surface[1]);
        		    draw_surface_safe(_surf);
        		surface_reset_shader();
        		
        		shader_set(sh_mk_shuffle_pixel);
        		    shader_set_2("dimension", _dim);
        		    	    
        		    var _bg = 0, _arr;
        		    
        		    if(_axis == 0) {
        		        surface_set_target(temp_surface[0]);
        		            DRAW_CLEAR BLEND_OVERRIDE
                		    shader_set_f("index", genShuffled(min(_dim[0], 1024), _rand));
                		    shader_set_i("axis",  0);
                		    shader_set_i("shift", 0);
                		    
                		    draw_surface_safe(temp_surface[1]);
                		surface_reset_target();
                		_bg = 1;
                		
        		    } else if(_axis == 1) {
        		        surface_set_target(temp_surface[0]);
        		            DRAW_CLEAR BLEND_OVERRIDE
                		    shader_set_f("index", genShuffled(min(_dim[1], 1024), _rand));
                		    shader_set_i("axis",  1);
                		    shader_set_i("shift", 0);
                		    
                		    draw_surface_safe(temp_surface[1]);
                		surface_reset_target();
                		_bg = 1;
                		
        		    } else {
            		    repeat(4) {
            		        surface_set_target(temp_surface[_bg]);
            		            DRAW_CLEAR BLEND_OVERRIDE
                    		    shader_set_f("index", genShuffled(min(_bg? _dim[1] : _dim[0], 1024), _rand));
                    		    shader_set_i("axis",  _bg);
                    		    shader_set_i("shift", 1);
                    		    
                    		    draw_surface_safe(temp_surface[!_bg]);
                    		surface_reset_target();
                    		_bg = !_bg;
            		    }
        		    }
        		    
        		    BLEND_NORMAL
        		shader_reset();
        		
        		surface_set_shader(_outSurf);
        		    draw_surface_safe(temp_surface[!_bg]);
        		surface_reset_shader();
        		break;
            		
		    case 1 :
		        var _indx = genShuffled(min(1024, _blok[0] * _blok[1]), _rand);
		        var _rep  = ceil(4);
		        
		        surface_set_shader(temp_surface[1]);
        		    draw_surface_safe(_surf);
        		surface_reset_shader();
        			    
    		    var _bg = 0, _arr;
                repeat(_rep) {
    		        surface_set_shader(temp_surface[_bg], sh_mk_shuffle_block);
    		            shader_set_2("dimension", _dim);
    		            shader_set_2("block", _blok);
    		            shader_set_i("index", _indx);
    		            
    		            draw_surface_safe(temp_surface[!_bg]);
    		        surface_reset_shader();
    		        _bg = !_bg;
                }
		        
        		surface_set_shader(_outSurf);
        		    draw_surface_safe(temp_surface[!_bg]);
        		surface_reset_shader();
		        break;
		}
		
		return _outSurf;
	}
}
