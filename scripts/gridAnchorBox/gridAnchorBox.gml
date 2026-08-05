function gridAnchorBox(_onModify, _unit) : widget() constructor {
	tbx = textBox_Number( function(val) /*=>*/ {return onModify(toNumber(val), GRID_ANCHOR.x )}).setHide(1).setLabel("x");
	tby = textBox_Number( function(val) /*=>*/ {return onModify(toNumber(val), GRID_ANCHOR.y )}).setHide(1).setLabel("y");
	
	unit      = _unit;
	
	widgets   = [tbx, tby];
	widgetLen = array_length(widgets);
	
	static setInteract = function(n = noone) /*=>*/ { interactable = n; for( var i = 0; i < widgetLen; i++ ) widgets[i].setInteract(n); }
	static register    = function(p = noone) /*=>*/ {                   for( var i = 0; i < widgetLen; i++ ) widgets[i].register(p);    }
	static isHovering  = function() /*=>*/ {return array_any(widgets, function(w,i) /*=>*/ {return w.isHovering()})};
	
	static fetchHeight = function(params) { return params.h; }
	static drawParam   = function(params) {
		setParam(params);
		for( var i = 0; i < widgetLen; i++ ) widgets[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry); 
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m, _rx, _ry) {
		x = _x;
		y = _y;
		h = _h;
		
		var _cx = array_safe_get_fast( _data, GRID_ANCHOR.x );
		var _cy = array_safe_get_fast( _data, GRID_ANCHOR.y );
		
		if(is_array(_cx) || is_array(_cy))
			return 0;
		
		var bs = min(_h, ui(32));
		var bx = _x + _w - bs;
		var by = _y;
		
		if(unit != noone && unit.reference != noone) {
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, by, bs, _h, CDEF.main_mdwhite, 1);
			
			unit.triggerButton.setFocusHover(iactive, ihover);
			unit.draw(bx, by, bs, bs, _m);
			bx -= bs;
			_w -= bs;
		}
		
		var w2 = _w / 2;
		var lh = _h;
		
		for( var i = 0; i < widgetLen; i++ )
			widgets[i].setFocusHover(active, hover);
		
		if(hide == 0) {
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, by, _w, lh, boxColor,  1);
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, by, _w, lh, boxColor, .5 + .5 * interactable);	
		}
		
		tbx.draw(_x,      by, w2, _h, _cx, _m);
		tby.draw(_x + w2, by, w2, _h, _cy, _m);
		
		resetFocus();
		return h;
	}
	
	static clone = function() { return new controlPointBox(onModify); }

	static free = function() {
		for( var i = 0, n = widgetLen; i < n; i++ ) 
			widgets[i].free();
	}
}
