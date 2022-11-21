function vectorRangeBox(_size, _type, _onModify) constructor {
	size     = _size;
	onModify = _onModify;
	
	hover  = false;
	active = false;
	
	axis = [ "x", "y", "z", "w"];
	label = [];
	onModifySingle[0] = function(val) { onModify(0, toNumber(val)); }
	onModifySingle[1] = function(val) { onModify(1, toNumber(val)); }
	onModifySingle[2] = function(val) { onModify(2, toNumber(val)); }
	onModifySingle[3] = function(val) { onModify(3, toNumber(val)); }
	
	extras = -1;
	
	for(var i = 0; i < size; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
		
		label[i] = (i % 2? "max " : "min ") + axis[floor(i / 2)];
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		if(extras && instanceof(extras) == "buttonClass") {
			extras.hover  = hover;
			extras.active = active;
			
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		var ww  = _w / size * 2;
		for(var i = 0; i < size; i++) {
			tb[i].hover  = hover;
			tb[i].active = active;
			
			var bx  = _x + ww * floor(i / 2);
			var by  = _y + i % 2 * 40;
			tb[i].draw(bx + ui(56), by, ww - ui(56), TEXTBOX_HEIGHT, _data[i], _m);
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
			draw_text(bx + ui(8), by + _h / 2, label[i]);
		}
		hover  = false;
		active = false;
		
		return TEXTBOX_HEIGHT * 2 + ui(4);
	}
}