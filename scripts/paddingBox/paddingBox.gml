function paddingBox(_onModify, _linked) constructor {
	onModify = _onModify;
	linked   = _linked;
	
	active  = false;
	hover   = false;
	
	onModifySingle[0] = function(val) { onModify(0, toNumber(val)); }
	onModifySingle[1] = function(val) { onModify(1, toNumber(val)); }
	onModifySingle[2] = function(val) { onModify(2, toNumber(val)); }
	onModifySingle[3] = function(val) { onModify(3, toNumber(val)); }
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		//tb[i].slidable = true;
	}
	
	b_link = button(linked);
	
	function draw(_x, _y, _data, _mod, _m) {
		draw_sprite(s_inspector_padding, 0, _x, _y + 64);
		
		for(var i = 0; i < 4; i++) {
			tb[i].hover  = hover;
			tb[i].active = active;
			tb[i].align  = fa_center;
		}
		
		tb[0].draw(_x + 64,      _y + 64 - 17,          64, 34, _data[0], _m);
		tb[1].draw(_x - 32,      _y + 64 - 48 - 8 - 34, 64, 34, _data[1], _m);
		tb[2].draw(_x - 64 - 64, _y + 64 - 17,          64, 34, _data[2], _m);
		tb[3].draw(_x - 32,      _y + 64 + 48 + 8,      64, 34, _data[3], _m);
		
		b_link.hover = hover;
		b_link.active = active;
		var bx = _x - 64 - 16;
		var by = _y      - 16;
		b_link.draw(bx, by, 32, 32, _m, s_button_hide);
		draw_sprite(s_padding_link, (_mod & VALUE_MODIFIER.linked) != 0, bx + 16, by + 16);
		
		active = false;
		hover  = false;
	}
}