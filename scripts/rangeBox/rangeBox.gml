function rangeBox(_type, _onModify) constructor {
	onModify = _onModify;
	
	hover  = false;
	active = false;
	
	label = [ "min", "max" ];
	onModifySingle[0] = function(val) { onModify(0, toNumber(val)); }
	onModifySingle[1] = function(val) { onModify(1, toNumber(val)); }
	
	extras = -1;
	
	for(var i = 0; i < 2; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		if(extras && instanceof(extras) == "buttonClass") {
			extras.hover  = hover;
			extras.active = active;
			
			extras.draw(_x + _w - 32, _y + _h / 2 - 32 / 2, 32, 32, _m, s_button_hide);
			_w -= 40;
		}
		
		if(is_array(_data) && array_length(_data) >= 2) {
			var ww  = _w / 2;
			for(var i = 0; i < 2; i++) {
				tb[i].hover  = hover;
				tb[i].active = active;
			
				var bx  = _x + ww * i;
				tb[i].draw(bx + 44, _y, ww - 44, _h, _data[i], _m);
			
				draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_grey);
				draw_text(bx + 8, _y + _h / 2, label[i]);
			}
		}
		
		hover  = false;
		active = false;
	}
}