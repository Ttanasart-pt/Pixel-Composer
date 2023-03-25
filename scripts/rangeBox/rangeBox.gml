function rangeBox(_type, _onModify) : widget() constructor {
	onModify = _onModify;
	
	linked = false;
	b_link = button(function() { linked = !linked; });
	b_link.icon = THEME.value_link;
	
	onModifyIndex = function(index, val) { 
		var modi = false;
		
		if(linked) {
			for( var i = 0; i < 2; i++ )
				modi |= onModify(i, toNumber(val)); 
			return modi;
		}
		
		return onModify(index, toNumber(val)); 
	}
	
	label = [ "min", "max" ];
	onModifySingle[0] = function(val) { return onModifyIndex(0, toNumber(val)); }
	onModifySingle[1] = function(val) { return onModifyIndex(1, toNumber(val)); }
	
	extras = -1;
	
	for(var i = 0; i < 2; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < 2; i++)
			tb[i].slide_speed = speed;
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		b_link.interactable = interactable;
		
		for( var i = 0; i < 2; i++ )
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		b_link.register(parent);
		
		for( var i = 0; i < 2; i++ )
			tb[i].register(parent);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		b_link.setActiveFocus(hover, active);
		b_link.icon_index = linked;
		b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		b_link.tooltip = linked? "Unlink axis" : "Link axis";
		
		var bx = _x;
		var by = _y + _h / 2 - ui(32 / 2);
		b_link.draw(bx + ui(4), by + ui(4), ui(24), ui(24), _m, THEME.button_hide);
		
		_x += ui(28);
		_w -= ui(28);
		
		if(extras != -1 && is_struct(extras) && instanceof(extras) == "buttonClass") {
			extras.setActiveFocus(hover, active);
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		if(is_array(_data) && array_length(_data) >= 2) {
			var ww  = _w / 2;
			for(var i = 0; i < 2; i++) {
				tb[i].setActiveFocus(hover, active);
				
				var bx  = _x + ww * i;
				tb[i].draw(bx + ui(44), _y, ww - ui(44), _h, _data[i], _m);
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(bx + ui(8), _y + _h / 2, label[i]);
			}
		}
		
		resetFocus();
	}
}