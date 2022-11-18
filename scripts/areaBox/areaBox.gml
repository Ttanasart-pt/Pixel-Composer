enum AREA_SHAPE {
	rectangle,
	elipse
}

function areaBox(_onModify) constructor {
	onModify = _onModify;
	onSurfaceSize = -1;
	
	active  = false;
	hover   = false;
	
	onModifySingle[0] = function(val) { onModify(0, toNumber(val)); }
	onModifySingle[1] = function(val) { onModify(1, toNumber(val)); }
	onModifySingle[2] = function(val) { onModify(2, toNumber(val)); }
	onModifySingle[3] = function(val) { onModify(3, toNumber(val)); }
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
	}
	
	static draw = function(_x, _y, _data, _m) {
		if(buttonInstant(THEME.button_hide, _x - ui(48), _y + ui(64 - 48), ui(96), ui(96), _m, active, hover, "", THEME.inspector_area, array_safe_get(_data, 4), c_white) == 2) {
			if(mouse_check_button_pressed(mb_left)) {
				var val = (array_safe_get(_data, 4) + 1) % 2;
				onModify(4, val);
			}
		}
		
		if(onSurfaceSize != -1) {
			if(buttonInstant(THEME.button_hide, _x - ui(76), _y + ui(28 - 12), ui(24), ui(24), _m, active, hover, "Fill surface", THEME.fill, 0, c_white) == 2) {
				var ss = onSurfaceSize();
				onModify(0, toNumber(ss[0] / 2));
				onModify(1, toNumber(ss[1] / 2));
				onModify(2, toNumber(ss[0] / 2));
				onModify(3, toNumber(ss[1] / 2));
			}
		}
		
		for(var i = 0; i < 4; i++) {
			tb[i].hover  = hover;
			tb[i].active = active;
			tb[i].align  = fa_center;
		}
		
		tb[0].draw(_x - ui(56) - ui(48), _y - ui(28), ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 0), _m);
		tb[1].draw(_x + ui(56) - ui(48), _y - ui(28), ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
		
		tb[2].draw(_x - ui(36),      _y + ui(64 + 48 + 8),      ui(64), TEXTBOX_HEIGHT, array_safe_get(_data, 2), _m);
		tb[3].draw(_x + ui(64),      _y + ui(64 - 16),          ui(64), TEXTBOX_HEIGHT, array_safe_get(_data, 3), _m);
		
		active = false;
		hover  = false;
	}
}