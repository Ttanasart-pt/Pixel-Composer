function taggedSurf(_surf = noone) : dynaSurf() constructor {
	surfaces = is(_surf, dynaSurf)? array_clone(_surf.surfaces) : [_surf];
	tags     = {};
	
	static draw = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {
		var _surf = surfaces[0];
		draw_surface_ext_safe(_surf, _x, _y, _xs, _ys, 0, _col, _alp);
	}
	
	static drawTile = function(_x = 0, _y = 0, _xs = 1, _ys = 1, _col = c_white, _alp = 1) {
		var _surf = surfaces[0];
		draw_surface_tiled_ext_safe(_surf, _x, _y, _xs, _ys, 0, _col, _alp);
	}
	
	static drawPart = function(_l, _t, _w, _h, _x, _y, _xs = 1, _ys = 1, _rot = 0, _col = c_white, _alp = 1) {
		var _surf = surfaces[0];
		draw_surface_part_ext_safe(_surf, _l, _t, _w, _h, _x, _y, _xs, _ys, 0, _col, _alp);
	}
	
	static clone   = function() { return new taggedSurf(surfaces[0]); }
	static destroy = function() { surface_array_free(surfaces); }
}

function Node_Surface_Tag(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Tag Surface";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newOutput(0, nodeValue_Output("Tagged Surface", VALUE_TYPE.dynaSurface, noone));
	
	array_adjust_tool = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _yy = _y + ui(8);
		var _h  = ui(8);
		
		var bw = _w;
		var bh = ui(36);
		if(buttonTextIconInstant(true, THEME.button_hide_fill, _x, _yy, bw, bh, _m, _focus, _hover, "", THEME.add, __txt("Add"), COLORS._main_value_positive) == 2) {
			createNewInput();
			triggerRender();
		}
		
		_yy += bh + ui(12);
		_h  += bh + ui(12);
		
		var _hg  = ui(32);
		var _amo = getInputAmount();
		var _del = -1;
		
		for( var i = 0; i < _amo; i++ ) {
	        var _ind = input_fix_len + i * data_length;
	        var _tag_name = getInputData(_ind + 0);
	        var _tag_posi = getInputData(_ind + 1);
	        
	        draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
	        draw_text_add(_x + ui(8), _yy + _hg / 2, "Tag Name");
	        
	        var _wx = ui(112);
	        var _ww = _w - _wx - ui(24 + 8);
	        var _tb = inputs[_ind + 0].editWidget;
	        _tb.setFocusHover(_focus, _hover);
	        _tb.font = f_p2;
	        _tb.draw(_wx, _yy, _ww, _hg, _tag_name, _m);
	        
	        var _bs = _hg;
	        var _bx = _w - ui(24);
	        var _by = _yy + _hg / 2 - _bs / 2;
	        
	        if(buttonInstant(noone, _bx, _by, _bs, _bs, _m, _hover, _focus, "", THEME.minus, 0, CARRAY.button_negative) == 2) 
	            _del = i;
	        
    		_yy += _hg + ui(10);
    		_h  += _hg + ui(10);
		}
		
		if(_del != -1) deleteDynamicInput(_del);
		
		return _h;
	});
	
	input_display_list = [ 
		["Surface", false], 0, 
		["Tags",    false], array_adjust_tool, 
		["Values",   true], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index + 0, nodeValue_Text("Tag", "new tag"));
		
		newInput(index + 1, nodeValue_Vec2("Position", [[ 0, 0 ]] ))
			.setArrayDepth(1);
		
		array_push(input_display_list, inAmo + 1);
		return [ inputs[index + 0], inputs[index + 1] ];
	} 
	
	setDynamicInput(2, false);
	
	tag_dragging    = noone;
	tag_dragging_in = noone;
	tag_dragging_sv = 0;
	tag_dragging_sx = 0;
	tag_dragging_sy = 0;
	tag_dragging_mx = 0;
	tag_dragging_my = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _tagged_surfaces = outputs[0].getValue();
		var _tagged_surface  = is_array(_tagged_surfaces)? array_safe_get_fast(_tagged_surfaces, preview_index) : _tagged_surfaces;
		
		if(is(_tagged_surface, taggedSurf)) {
			var _tags = _tagged_surface.tags;
			var _taga = struct_get_names(_tags);
			
			for( var i = 0, n = array_length(_taga); i < n; i++ ) {
				var _t = _taga[i];
				var _p = _tags[$ _t];
				
				var _px = _x + _p[0] * _s;
				var _py = _y + _p[1] * _s;
				
				draw_set_color(c_white);
	        	draw_rectangle(_px, _py, _px + _s - 1, _py + _s - 1, true);
	        	
	        	draw_set_color(c_black);
	        	draw_rectangle(_px + 1, _py + 1, _px + _s - 2, _py + _s - 2, true);
			}
		}
		
	    var _amo = getInputAmount();
	    
	    var _tag_hov = noone;
	    var _tag_pos = noone;
	    var _tag_sx  = noone;
	    var _tag_sy  = noone;
	    
    	for( var i = 0; i < _amo; i++ ) {
	        var _ind = input_fix_len + i * data_length;
	        var _tag_name = getInputData(_ind + 0);
	        var _tag_posr = getInputData(_ind + 1);
	        var _tag_posi = array_safe_get(_tag_posr, preview_index, [ 0, 0 ]);
	        
	        var _px = _x + _tag_posi[0] * _s;
	        var _py = _y + _tag_posi[1] * _s;
	        var _hv = tag_dragging == i || hover && point_in_rectangle(_mx, _my, _px, _py, _px + _s, _py + _s);
	        
	        draw_set_color(_hv? COLORS._main_accent : c_white);
	        draw_rectangle(_px, _py, _px + _s - 1, _py + _s - 1, true);
	        
	        draw_set_color(c_black);
	        draw_rectangle(_px + 1, _py + 1, _px + _s - 2, _py + _s - 2, true);
	        
	        draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_text);
	        draw_text_add(_px + _s / 2, _py - 4, _tag_name);
	        
	        if(_hv) {
	            _tag_hov = i;
	            _tag_pos = _tag_posr;
	            _tag_sx  = _tag_posi[0];
	            _tag_sy  = _tag_posi[1];
	        }

    	}
    	
    	if(tag_dragging != noone) {
    	    var _tx = round(tag_dragging_sx + (_mx - tag_dragging_mx) / _s);
    	    var _ty = round(tag_dragging_sy + (_my - tag_dragging_my) / _s);
    	    tag_dragging_sv[preview_index] = [ _tx, _ty ];
    	    
    	    if(inputs[tag_dragging_in].setValue(tag_dragging_sv))
    	        UNDO_HOLDING = true;
    	    triggerRender();
    	    
    	    if(mouse_release(mb_left)) {
    	        UNDO_HOLDING = false;
    	        tag_dragging = noone;
    	    }
    	    
    	} else if(_tag_hov != noone) {
    	    if(mouse_press(mb_left, active)) {
    	        _tag_pos = array_verify_ext(_tag_pos, max(1, process_amount), function() /*=>*/ {return [ 0, 0 ]});
    	        
    	        tag_dragging    = _tag_hov;
    	        tag_dragging_in = input_fix_len + _tag_hov * data_length + 1;
            	tag_dragging_sv = _tag_pos;
            	tag_dragging_sx = _tag_sx;
            	tag_dragging_sy = _tag_sy;
            	tag_dragging_mx = _mx;
            	tag_dragging_my = _my;
    	    }
    	}
    	
    	return _tag_hov != noone;
	}
	
	static processData_prebatch  = function() {
		var _amo  = getInputAmount();
	    for( var i = 0; i < _amo; i++ ) {
	        var _ind = input_fix_len + i * data_length;
	        var _tag_name = getInputSingle(_ind + 0);
	        inputs[_ind + 1].setName($"{_tag_name} positions");
	    }
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
	    var _surf = _data[0];
	    var _srf  = new taggedSurf(_surf);
	    
	    if(is(_surf, taggedSurf))
	    	_srf.tags = variable_clone(_surf.tags);
    	
	    var _amo  = getInputAmount();
	    for( var i = 0; i < _amo; i++ ) {
	        var _ind = input_fix_len + i * data_length;
	        var _tag_name = _data[_ind + 0];
	        var _tag_posi = array_safe_get(_data[_ind + 1], _array_index, [ 0, 0 ]);
	        
	        if(_tag_name != "")
	            _srf.tags[$ _tag_name] = _tag_posi;
	    }
	    
	    return _srf;
	}
}