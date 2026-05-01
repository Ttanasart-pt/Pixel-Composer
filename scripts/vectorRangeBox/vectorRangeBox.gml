function vectorRangeBox(_size, _type, _onModify, _unit = noone) : widget() constructor {
	size     = _size;
	dim      = ceil(_size / 2);
	type     = _type;
	onModify = _onModify;
	unit	 = _unit;
	
	linked   = false;
	ranged   = false;
	
	disp_h = 0;
	
	rangeDrag = false;
	rangeDrag_mx = 0;
	rangeDrag_my = 0;
	rangeDrag_ss = 0;
	
	tooltip_ranged = new tooltipSelector("Value Type", [ __txt("widget_range_constant", "Constant"), __txt("widget_range_random", "Random Range") ]);
	
	onModifyIndex = function(val, index) { 
		var v = toNumber(val);
		
		if(!linked && ranged) return onModify(v, index);
		var modi = false;
		
		if(linked && !ranged) {
			for( var i = 0; i < size; i++ ) {
				var m = onModify(v, i); modi = modi || m;
			}
			
		} else if(linked) {
			if(dim >= 1) { var m = onModify(v, 0 + (index % 2)); modi = modi || m; }
			if(dim >= 2) { var m = onModify(v, 2 + (index % 2)); modi = modi || m; }
			if(dim >= 3) { var m = onModify(v, 4 + (index % 2)); modi = modi || m; }
			
		} else if(!ranged) {
			var m = onModify(v, index + 0); modi = modi || m;
			var m = onModify(v, index + 1); modi = modi || m;
		}
		
		return modi;
	}
	
	axis = [ "min", "max" ];
	extras = -1;
	
	////- Textbox
	
	tb[0] = new textBox(_type, function(v) /*=>*/ {return onModifyIndex(v,0)}).setHide(1);
	tb[1] = new textBox(_type, function(v) /*=>*/ {return onModifyIndex(v,1)}).setHide(1);
	
	if(dim >= 2) {
		tb[2] = new textBox(_type, function(v) /*=>*/ {return onModifyIndex(v,2)}).setHide(1);
		tb[3] = new textBox(_type, function(v) /*=>*/ {return onModifyIndex(v,3)}).setHide(1);
	}
	
	if(dim >= 3) {
		tb[4] = new textBox(_type, function(v) /*=>*/ {return onModifyIndex(v,4)}).setHide(1);
		tb[5] = new textBox(_type, function(v) /*=>*/ {return onModifyIndex(v,5)}).setHide(1);
	}
	
	if(dim >= 4) {
		tb[6] = new textBox(_type, function(v) /*=>*/ {return onModifyIndex(v,6)}).setHide(1);
		tb[7] = new textBox(_type, function(v) /*=>*/ {return onModifyIndex(v,7)}).setHide(1);
	}
	
	////- Set
	
	static setInteract = function(interactable = noone) {
		self.interactable = interactable;
		for( var i = 0; i < size; i++ ) tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) { for( var i = 0; i < size; i++ ) tb[i].register(parent); }
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static fetchHeight = function(params) { 
		if(has(params.display_data, "ranged")) ranged = params.display_data.ranged;
		return ranged? params.h * 2 : params.h; 
	}
	
	////- Draw
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < size; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		_data = array_verify(_data, size);
		
		if(has(_display_data, "linked")) linked = _display_data.linked;
		if(has(_display_data, "ranged")) ranged = _display_data.ranged;
		
		h = ranged? _h * 2 : _h;
		
		var bs = min(_h, ui(32));
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, w, h, boxColor, 1);
		
		if((_w - bs) / 2 > ui(64)) {
			if(side_button) {
				var bx = _x + _w - bs;
				
				if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, h, CDEF.main_mdwhite, 1);
				side_button.setFocusHover(active, hover);
				side_button.draw(bx, _y + _h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
				_w -= bs;
			}
			
			if(side_button2) {
				var bx = _x + _w - bs;
				
				if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, h, CDEF.main_mdwhite, 1);
				side_button2.setFocusHover(active, hover);
				side_button2.draw(bx, _y + _h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
				_w -= bs;
			}
			
			var bx = _x;
			var by = _y + _h / 2 - bs / 2;
			var bc = linked? COLORS._main_accent : COLORS._main_icon;
			
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs * 2, h, CDEF.main_mdwhite, 1);
			if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, hover, active, __txt("Link axis"), THEME.value_link, linked, bc) == 2) {
				linked = !linked;
				_display_data.linked = linked;
				
				if(linked) {
					if(dim >= 1) { onModifyIndex(_data[0], 0); onModifyIndex(_data[1], 1); }
					if(dim >= 2) { onModifyIndex(_data[0], 2); onModifyIndex(_data[1], 3); }
					if(dim >= 3) { onModifyIndex(_data[0], 4); onModifyIndex(_data[1], 5); }
				}
			}
			
			bx += bs;
			
			tooltip_ranged.index = ranged;
			var b  = buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, hover, active, tooltip_ranged, THEME.value_range, ranged);
			var tg = false;
			if(b == 1 && key_mod_press(SHIFT) && MOUSE_WHEEL != 0) tg = true;
			if(b == 2) tg = true;
			
			if(tg) {
				ranged = !ranged;
				_display_data.ranged = ranged;
				
				if(!ranged) {
					if(dim >= 1) { onModifyIndex(_data[0], 1); }
					if(dim >= 2) { onModifyIndex(_data[2], 3); }
					if(dim >= 3) { onModifyIndex(_data[4], 5); }
				}
			}
			
			_x += bs * 2;
			_w -= bs * 2;
		}
		
		var ww = _w / dim;
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, x, y, w, h, boxColor, 0.5 + 0.5 * interactable);	
		
		if(linked) {
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, _x + ww / 2 - ui(2), _y + _h / 2, _w - ww, ui(4), COLORS._main_accent, .2);
		}
		
		if(rangeDrag) {
			hover = false;
			
			var _dt = (_m[0] - rangeDrag_mx) / w;
			var _sc = power(2, _dt);
			var _ed = false;
			
			if(ranged) {
				for( var i = 0; i < dim; i++ ) {
					var ind = i * 2 + rangeDrag - 1;
					var _v = rangeDrag_ss[ind] * _sc;
					if(key_mod_press(CTRL))
						_v = round(_v);
					
					var u = onModify(_v, ind); _ed |= u;
				}
				
			} else {
				for( var i = 0; i < dim; i++ ) {
					var ind = i * 2;
					var _v = rangeDrag_ss[ind] * _sc;
					if(key_mod_press(CTRL))
						_v = round(_v);
					
					var u = onModify(_v, ind); _ed |= u;
				}
			}
			
			if(_ed) UNDO_HOLDING = true;
			
			if(mouse_lrelease()) {
				UNDO_HOLDING = false;
				rangeDrag    = false;
			}
		}
		
		var bxHover = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		var tbHover = bxHover;
		
		if(ranged) {
			for( var j = 0; j < 2; j++ ) {
				var by  = _y + _h * j;
				
				for( var i = 1; i < dim; i++ ) {
					var bx  = _x + ww * i;
					
					var ps = _h / 2;
					var px = bx;
					var py = by + _h / 2;
					
					if(bxHover && w > ui(80)) {
						var pHover = hover && point_in_rectangle(_m[0], _m[1], px-ps, py-ps, px+ps, py+ps);
						if(pHover) tbHover = false;
					}
				}
				
				for( var i = 0; i < dim; i++ ) {
					var bx  = _x + ww * i;
					var ind = i * 2 + j;
					
					var ps = _h / 2;
					var px = bx;
					var py = by + _h / 2;
					
					if(i == 0) tb[ind].label = axis[j];
					tb[ind].setFocusHover(active, tbHover);
					tb[ind].draw(bx, by, ww, _h, array_safe_get_fast(_data, ind), _m);
					
					if(i == 0) continue;
					if(rangeDrag == 1 + j) {
						draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, COLORS._main_accent, 1);
						
					} else if(bxHover && w > ui(80)) {
						draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, pHover? COLORS._main_icon_light : COLORS._main_icon, 1);
						if(pHover && mouse_lpress(active)) {
							rangeDrag = 1 + j;
							rangeDrag_mx = _m[0];
							rangeDrag_my = _m[1];
							rangeDrag_ss = array_clone(_data);
						}
					}
				}
			}
			
		} else {
			for( var i = 1; i < dim; i++ ) {
				var bx  = _x + ww * i;
				var by  = _y;
				
				var ps = _h / 2;
				var px = bx;
				var py = by + _h / 2;
				
				if(bxHover && w > ui(80)) {
					var pHover = hover && point_in_rectangle(_m[0], _m[1], px-ps, py-ps, px+ps, py+ps);
					if(pHover) tbHover = false;
				}
			}
			
			for( var i = 0; i < dim; i++ ) {
				var bx  = _x + ww * i;
				var by  = _y;
				var ind = i * 2;
				
				var ps = _h / 2;
				var px = bx;
				var py = by + _h / 2;
				
				tb[ind].label = "";
				tb[ind].setFocusHover(active, tbHover);
				tb[ind].draw(bx, by, ww, _h, array_safe_get_fast(_data, ind), _m);
				
				if(i == 0) continue;
				if(rangeDrag) {
					draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, COLORS._main_accent, 1);
					
				} else if(bxHover && w > ui(80)) {
					draw_sprite_ui(THEME.window_pan_icon, 0, px, py, 1, 1, 0, pHover? COLORS._main_icon_light : COLORS._main_icon, 1);
					if(pHover && mouse_lpress(active)) {
						rangeDrag = true;
						rangeDrag_mx = _m[0];
						rangeDrag_my = _m[1];
						rangeDrag_ss = array_clone(_data);
					}
				}
			}
		}
		
		resetFocus();
		
		return h;
	}
	
	////- Action
	
	static clone = function() {
		var cln = new vectorRangeBox(size, type, onModify, unit);
		
		cln.axis   = axis;
		cln.extras = extras;
		
		return cln;
	}
	
	static free = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) tb[i].free();
	}
}