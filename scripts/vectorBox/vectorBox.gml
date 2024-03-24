enum DIMENSION {
	width,
	height
}

function vectorBox(_size, _onModify, _unit = noone) : widget() constructor {
	size     = _size;
	onModify = _onModify;
	unit	 = _unit;
	
	linkable = true;
	per_line = false;
	current_value = [];
	linked        = false;
	side_button   = noone;
	
	link_inactive_color = noone;
	
	tooltip	= new tooltipSelector("Axis", [
		__txt("Independent"),
		__txt("Linked"),
	]);
	
	onModifyIndex = function(index, val) { 
		var v = toNumber(val);
		
		if(linked) {
			var modi = false;
			for( var i = 0; i < size; i++ ) {
				tb[i]._input_text = v;
				
				if(is_callable(onModify))
					modi |= onModify(i, v); 
			}
			return modi;
		}
		
		if(is_callable(onModify))
			return onModify(index, v); 
		return noone;
	}
	
	axis = [ "x", "y", "z", "w" ];
	onModifySingle[0] = function(val) { return onModifyIndex(0, val); }
	onModifySingle[1] = function(val) { return onModifyIndex(1, val); }
	onModifySingle[2] = function(val) { return onModifyIndex(2, val); }
	onModifySingle[3] = function(val) { return onModifyIndex(3, val); }
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setMinMax = function() {
		linkable = false;
		axis     = [ "min", "max" ];
		return self;
	}
	
	static setLinkInactiveColor = function(color) {
		link_inactive_color = color;
		return self;
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < size; i++)
			tb[i].setSlidable(speed);
		return self;
	}
	
	static setInteract = function(interactable) { 
		self.interactable = interactable;
		
		if(side_button != noone) 
			side_button.interactable = interactable;
			
		for( var i = 0; i < size; i++ ) 
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		for( var i = 0; i < size; i++ ) 
			tb[i].register(parent);
		
		if(side_button != noone) 
			side_button.register(parent);
		
		if(unit != noone && unit.reference != noone)
			unit.triggerButton.register(parent);
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = per_line? (_h + ui(8)) * size - ui(8) : _h;
		
		if(struct_has(_display_data, "linked"))	     linked	     = _display_data.linked;
		if(struct_has(_display_data, "side_button")) side_button = _display_data.side_button;
		tooltip.index = linked;
		
		if(!is_array(_data))   return 0;
		if(array_empty(_data)) return 0;
		if(is_array(_data[0])) return 0;
		
		current_value = _data;
		
		var _bs = min(_h, ui(32));
		
		if(side_button) {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide);
			_w -= _bs + ui(4);
		}
		
		if(unit != noone && unit.reference != noone) {
			unit.triggerButton.setFocusHover(iactive, ihover);
			unit.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m);
			_w -= _bs + ui(4);
		}
		
		if(linkable) {
			var _icon_blend = linked? COLORS._main_accent : (link_inactive_color == noone? COLORS._main_icon : link_inactive_color);
			var bx = _x;
			var by = _y + _h / 2 - _bs / 2;
			
			if(buttonInstant(THEME.button_hide, bx, by, _bs, _bs, _m, active, hover, tooltip, THEME.value_link, linked, _icon_blend) == 2) {
				linked = !linked;
				_display_data.linked =  linked;
				
				if(linked) {
					onModify(0, _data[0]);
					onModify(1, _data[0]);
				}
			}
			
			_x += _bs + ui(4);
			_w -= _bs + ui(4);
		}
		
		var sz = min(size, array_length(_data));
		var ww = per_line? _w : _w / sz;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);	
			
		for(var i = 0; i < sz; i++) {
			draw_set_font(f_p0);
			
			var bx = per_line? _x : _x + ww * i;
			var by = per_line? _y + (_h + ui(8)) * i : _y;
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
			draw_set_alpha(0.5);
			draw_text_add(bx + ui(8), by + _h / 2, axis[i]);
			draw_set_alpha(1);
			
			tb[i].setFocusHover(active, hover);
			tb[i].hide = true;
			tb[i].draw(bx, by, ww, _h, _data[i], _m);
		}
		
		resetFocus();
		
		return h;
	}
	
	static apply = function() {
		for( var i = 0; i < size; i++ ) {
			tb[i].apply();
			current_value[i] = toNumber(tb[i]._input_text);
		}
	}
}