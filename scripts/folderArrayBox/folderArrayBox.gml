function folderArrayBox(_arr, _onApply) : widget() constructor {
	onApply = _onApply;
	array   = _arr;
	adding  = false;
	
	editing = noone;
	tb_edit = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { 
		if(editing == noone) { adding = false; return false; }
		
		array[editing] = str;
		if(str == "") {
			array_delete(array, editing, 1);
			editing = noone;
		}
		
		adding = false;
		onApply();
		return true; 
	}).setSlide(false).setEmpty();
	
	tb_edit.onDeactivate = function() /*=>*/ { editing = noone; }
	
	_hovering = false;
	
	static setFont = function(font) { 
		self.font    = font;
		tb_edit.font = font;
		return self; 
	}
	
	static drawParam = function(params) {
		setParam(params);
		tb_edit.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _arr, _m) {
		
		x = _x;
		y = _y;
		w = _w;
		h = (_h + ui(4)) * (array_length(_arr) + !adding) - ui(4);
		
		array    = _arr;
		hovering = false;
		
		var _tx = x;
		var _ty = y;
		
		if(editing && !_hovering && mouse_press(mb_left)) {
			tb_edit.deactivate();
			editing = noone;
		}
		
		var _tw  = _w - ui(28);
		var _del = noone;
		
		for( var i = 0, n = array_length(_arr); i < n; i++ ) {
			_ty = y + i * (_h + ui(4));
			draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _ty, _tw, _h, boxColor);
			
			hovering = hovering || (hover && point_in_rectangle(_m[0], _m[1], _tx, _ty, _tx + _w, _ty + _h));
			if(editing == i) {
				tb_edit.setFocusHover(active, hover);
				tb_edit.draw(_tx, _ty, _tw, _h, array[editing], _m);
				continue;
			}
			
			if(hover && point_in_rectangle(_m[0], _m[1], _tx, _ty, _tx + _tw, _ty + _h)) {
				draw_sprite_stretched_ext(THEME.textbox, 1, _tx, _ty, _tw, _h, boxColor);
				
				if(editing != i && mouse_press(mb_left, active)) {
					editing = i;
					
					tb_edit._current_text = array[i];
					tb_edit.activate();
				}
				
				if(mouse_click(mb_left, active))
					draw_sprite_stretched(THEME.textbox, 2, _tx, _ty, _tw, _h);
				
			} else 
				draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _ty, _tw, _h, boxColor);
				
			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
			draw_text_cut(_tx + ui(8), round(_ty + _h / 2), array[i], _tw - ui(16));
			
			var _bs = ui(24);
			var _bx = _x + _w - _bs;
			var _by = _ty + _h / 2 - _bs / 2;
			var _b  = buttonInstant(noone, _bx, _by, _bs, _bs, _m, hover, active, "", THEME.minus_16, 0, [COLORS._main_icon, COLORS._main_value_negative]);
			if(_b == 2) _del = i;
		}
		
		if(!adding) { // Add value
			_ty = y + array_length(_arr) * (_h + ui(4));
			var _hv = hover && point_in_rectangle(_m[0], _m[1], _tx, _ty, _tx + _tw, _ty + _h);
			draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _ty, _tw, _h, boxColor, .5);
			draw_set_text(font, fa_left, fa_center, _hv? COLORS._main_text : COLORS._main_text_sub);
			draw_text(_tx + ui(8), round(_ty + _h / 2), "Add value...");
			
			if(mouse_press(mb_left, _hv && active)) {
				editing = array_length(_arr);
				adding  = true;
				array_push(_arr, "");
				
				tb_edit._current_text = "";
				tb_edit.activate();
			}
		}
		
		if(_del != noone) {
			editing = noone;
			array_delete(_arr, _del, 1);
			onApply();
		} 
		
		hovering = _hovering;
		
		if(WIDGET_CURRENT == self) draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new pathArrayBox(target, data, onClick);
		
		return cln;
	}

	static free = function() {
		tb_edit.free();
	}
}