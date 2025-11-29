function numberArrayBox(_onModify) : widget() constructor {
	onModify      = _onModify;
	current_value = [];
	onModifyValue = function() /*=>*/ {return onModify(current_value)};
	
	editing = noone;
	
	tb = textBox_Number(function(v) /*=>*/ {
	    if(editing == noone) return;
	    
	    current_value = array_clone(current_value);
	    current_value[editing] = v;
	    onModify(current_value);
	});
	
	tb.onDeactivate = function() /*=>*/ { editing = noone; }
	
	static setFont    = function(_f) /*=>*/ { tb.setFont(_f); return self; }
	static isHovering = function() /*=>*/ {return tb.isHovering()};
	
	////- Draw
	
	static setInteract = function(i) /*=>*/ { interactable = i; tb.interactable = i; }
	static register    = function(parent = noone) /*=>*/ { tb.register(parent); }
	
	static drawParam = function(params) {
		setParam(params);
		tb.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		current_value = _data;
		var _amo = array_length(_data);
		var _tx  = _x;
		var _ty  = _y;
		
		var _bww = ui(48);
		var _ww = _w - _bww - ui(4);
		var _tw = _ww / _amo;
		var _th = _h;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _ww, _h, boxColor, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _ww, _h, boxColor, 0.5 + 0.5 * interactable);	
			
		for( var i = 0; i < _amo; i++ ) {
		    var _v   = _data[i];
		    var _hov = hover && point_in_rectangle(_m[0], _m[1], _tx, _ty, _tx + _tw - 1, _ty + _th);
		    
		    if(editing == i) {
		        tb.draw(_tx, _ty, _tw, _th, _v, _m);
		        
		    } else {
    		    draw_set_text(font, fa_center, fa_center, COLORS._main_text);
    		    draw_text_add(_tx + _tw / 2, _ty + _th / 2, _v);
    		    
    		    if(_hov) {
			        draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _ty, _tw, _th, boxColor, 1);
			        if(mouse_press(mb_left, active)) {
			            editing = i;
			            tb.activate(_v);
			        }
			    }
		    }
		    
		    _tx += _tw;
		}
		
		var  bb = THEME.button_hide;
		var _bx = _x + _w - _bww;
		var _by = _y;
		var _bw = _bww / 2;
		var _bh = _h;
		
		if(buttonInstant(bb, _bx, _by, _bw, _bh, _m, hover, active, "", THEME.add, 0, COLORS._main_value_positive, 1, .5) == 2) {
		    current_value = array_clone(current_value);
    	    array_push(current_value, 0);
    	    onModify(current_value);
		}
		
		_bx += _bw;
		if(_amo > 1) {
			var b = buttonInstant(bb, _bx, _by, _bw, _bh, _m, hover, active, "", THEME.minus, 0, COLORS._main_value_negative, 1, .5);
			if(b == 2) {
			    current_value = array_clone(current_value);
	    	    array_pop(current_value);
	    	    onModify(current_value);
			}
			
		} else draw_sprite_ui_uniform(THEME.minus, 0, _bx + _bw / 2, _by + _bh / 2, .5, COLORS._main_icon, .5);
		
		resetFocus();
		return h;
	}
	
	static clone = function() /*=>*/ {return new numberArrayBox(onModify)};

	static free = function() { tb.free(); }
}