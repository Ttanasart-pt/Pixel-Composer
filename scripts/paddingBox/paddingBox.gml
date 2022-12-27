function paddingBox(_onModify, _unit = noone) constructor {
	onModify = _onModify;
	unit	 = _unit;
	
	active  = false;
	hover   = false;
	linked = false;
	b_link = button(function() { linked = !linked; });
	b_link.icon = THEME.value_link;
	
	onModifyIndex = function(index, val) { 
		if(linked) {
			for( var i = 0; i < 4; i++ )
				onModify(i, toNumber(val)); 
			return;
		}
		
		onModify(index, toNumber(val)); 
	}
	
	onModifySingle[0] = function(val) { onModifyIndex(0, val); }
	onModifySingle[1] = function(val) { onModifyIndex(1, val); }
	onModifySingle[2] = function(val) { onModifyIndex(2, val); }
	onModifySingle[3] = function(val) { onModifyIndex(3, val); }
	
	for(var i = 0; i < 4; i++)
		tb[i] = new textBox(TEXTBOX_INPUT.float, onModifySingle[i]);
	
	static draw = function(_x, _y, _data, _m) {
		draw_sprite_ui_uniform(THEME.inspector_padding, 0, _x, _y + ui(64));
		
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
		b_link.icon_index = linked;
		b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		b_link.tooltip = linked? "Unlink axis" : "Link axis";
		
		var bx = _x - ui(80);
		var by = _y - ui(24);
		b_link.draw(bx, by, ui(32), ui(32), _m, THEME.button_hide);
		
		if(unit != noone && unit.reference != noone) {
			unit.triggerButton.hover  = hover;
			unit.triggerButton.active = active;
			
			unit.draw(_x + ui(48),  _y - ui(25), ui(32), ui(32), _m);
		}
		
		active = false;
		hover  = false;
	}
}