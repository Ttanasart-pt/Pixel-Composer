function vectorBox(_size, _type, _onModify) constructor {
	size     = _size;
	onModify = _onModify;
	
	hover  = false;
	active = false;
	
	axis = [ "x", "y", "z", "w" ];
	onModifySingle[0] = function(val) { onModify(0, toNumber(val)); }
	onModifySingle[1] = function(val) { onModify(1, toNumber(val)); }
	onModifySingle[2] = function(val) { onModify(2, toNumber(val)); }
	onModifySingle[3] = function(val) { onModify(3, toNumber(val)); }
	
	extras = -1;
	
	for(var i = 0; i < size; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		if(extras && instanceof(extras) == "buttonClass") {
			extras.hover  = hover;
			extras.active = active;
			
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, s_button_hide);
			_w -= ui(40);
		}
		
		var ww  = _w / size;
		for(var i = 0; i < array_length(_data); i++) {
			tb[i].hover  = hover;
			tb[i].active = active;
			
			var bx  = _x + ww * i;
			tb[i].draw(bx + ui(24), _y, ww - ui(24), _h, _data[i], _m);
			
			draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_grey);
			draw_text(bx + ui(8), _y + _h / 2, axis[i]);
		}
		hover  = false;
		active = false;
	}
}