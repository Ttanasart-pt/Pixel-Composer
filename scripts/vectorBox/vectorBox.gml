function vectorBox(_size, _type, _onModify, _unit = noone) constructor {
	size     = _size;
	onModify = _onModify;
	unit	 = _unit;
	
	hover  = false;
	active = false;
	linked = false;
	b_link = button(function() { linked = !linked; });
	b_link.icon = THEME.value_link;
	
	onModifyIndex = function(index, val) { 
		if(linked) {
			for( var i = 0; i < size; i++ )
				onModify(i, toNumber(val)); 
			return;
		}
		
		onModify(index, toNumber(val)); 
	}
	
	axis = [ "x", "y", "z", "w" ];
	onModifySingle[0] = function(val) { onModifyIndex(0, val); }
	onModifySingle[1] = function(val) { onModifyIndex(1, val); }
	onModifySingle[2] = function(val) { onModifyIndex(2, val); }
	onModifySingle[3] = function(val) { onModifyIndex(3, val); }
	
	extras = -1;
	
	for(var i = 0; i < size; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		if(extras && instanceof(extras) == "buttonClass") {
			extras.hover  = hover;
			extras.active = active;
			
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		if(unit != noone && unit.reference != noone) {
			_w += ui(4);
			
			unit.triggerButton.hover  = hover;
			unit.triggerButton.active = active;
			
			unit.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m);
			_w -= ui(40);
		}
		
		b_link.hover = hover;
		b_link.active = active;
		b_link.icon_index = linked;
		b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		b_link.tooltip = linked? "Unlink axis" : "Link axis";
		
		var bx = _x;
		var by = _y + _h / 2 - ui(32 / 2);
		b_link.draw(bx + ui(4), by + ui(4), ui(24), ui(24), _m, THEME.button_hide);
		
		_x += ui(28);
		_w -= ui(28);
		
		var ww  = _w / size;
		for(var i = 0; i < size; i++) {
			tb[i].hover  = hover;
			tb[i].active = active;
			
			var bx  = _x + ww * i;
			tb[i].draw(bx + ui(24), _y, ww - ui(24), _h, _data[i], _m);
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
			draw_text(bx + ui(8), _y + _h / 2, axis[i]);
		}
		hover  = false;
		active = false;
	}
}