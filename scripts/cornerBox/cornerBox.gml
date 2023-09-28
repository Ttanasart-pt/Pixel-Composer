function cornerBox(_onModify, _unit = noone) : widget() constructor {
	onModify = _onModify;
	
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
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < 4; i++)
			tb[i].slide_speed = speed;
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		b_link.interactable = interactable;
		
		for( var i = 0; i < 4; i++ ) 
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		b_link.register();
		
		tb[0].register(parent);
		tb[1].register(parent);
		tb[2].register(parent);
		tb[3].register(parent);
	}
	
	static drawParam = function(params) {
		return draw(params.x + params.w / 2, params.y + ui(32), params.data, params.m);
	}
	
	static draw = function(_x, _y, _data, _m) {
		x = _x;
		y = _y;
		w = 0;
		h = ui(192);
		
		var yy = _y + ui(64);
		draw_sprite_ui_uniform(THEME.inspector_corner, 0, _x, yy);
		
		for(var i = 0; i < 4; i++) {
			tb[i].setFocusHover(active, hover);
			tb[i].align  = fa_center;
		}
		
		tb[0].draw(_x - ui(120), yy + ui(-48 - 34), ui(64), TEXTBOX_HEIGHT, _data[0], _m);
		tb[1].draw(_x + ui(56),  yy + ui(-48 - 34), ui(64), TEXTBOX_HEIGHT, _data[1], _m);
		tb[2].draw(_x - ui(120), yy + ui( 48),      ui(64), TEXTBOX_HEIGHT, _data[2], _m);
		tb[3].draw(_x + ui(56),  yy + ui( 48),      ui(64), TEXTBOX_HEIGHT, _data[3], _m);
		
		b_link.setFocusHover(active, hover);
		b_link.icon_index = linked;
		b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		b_link.tooltip = linked? __txt("Unlink values") : __txt("Link values");
		
		var bx = _x - ui(12);
		var by = yy - ui(12);
		b_link.draw(bx, by, ui(24), ui(24), _m, THEME.button_hide);
		
		resetFocus();
		
		return h;
	}
}