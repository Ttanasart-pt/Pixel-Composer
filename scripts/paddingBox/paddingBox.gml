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
	
	static draw = function(_x, _y, _data, _mod, _m) {
		draw_sprite_ui_uniform(s_inspector_padding, 0, _x, _y + ui(64));
		
		for(var i = 0; i < 4; i++) {
			tb[i].hover  = hover;
			tb[i].active = active;
			tb[i].align  = fa_center;
		}
		
		tb[0].draw(_x + ui(64),          _y + ui(64 - 17),          ui(64), TEXTBOX_HEIGHT, _data[0], _m);
		tb[1].draw(_x - ui(32),          _y + ui(64 - 48 - 8 - 34), ui(64), TEXTBOX_HEIGHT, _data[1], _m);
		tb[2].draw(_x - ui(64) - ui(64), _y + ui(64 - 17),          ui(64), TEXTBOX_HEIGHT, _data[2], _m);
		tb[3].draw(_x - ui(32),          _y + ui(64 + 48 + 8),      ui(64), TEXTBOX_HEIGHT, _data[3], _m);
		
		b_link.hover = hover;
		b_link.active = active;
		var bx = _x - ui(80);
		var by = _y - ui(16);
		b_link.draw(bx, by, ui(32), ui(32), _m, s_button_hide);
		draw_sprite_ui_uniform(s_padding_link, (_mod & VALUE_MODIFIER.linked) != 0, bx + ui(16), by + ui(16));
		
		active = false;
		hover  = false;
	}
}