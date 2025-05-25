function folderArrayBox(_arr, _onApply) : widget() constructor {
	onApply = _onApply;
	array   = _arr;
	editing = noone;
	tb_edit = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { 
		if(editing == noone) return false;
		
		if(str == "") {
			array_delete(array, editing, 1);
			editing = noone;
		} else 
			array[editing] = str;
		
		onApply();
		return true; 
	}).setSlide(false);
	
	tb_edit.setEmpty();
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
		h = (_h + ui(4)) * (array_length(_arr) + 1) - ui(4);
		
		array    = _arr;
		hovering = false;
		
		var _tx = x;
		var _ty = y;
		
		if(editing && !_hovering && mouse_press(mb_left)) {
			tb_edit.deactivate();
			editing = noone;
		}
		
		for( var i = 0, n = array_length(_arr); i <= n; i++ ) {
			_ty = y + i * (_h + ui(4));
			draw_sprite_stretched_ext(THEME.textbox, 3, _tx, _ty, _w, _h, boxColor);
			
			if(hover && point_in_rectangle(_m[0], _m[1], _tx, _ty, _tx + _w, _ty + _h)) 
				hovering = true;
				
			if(editing == i) continue;
			
			if(hover && point_in_rectangle(_m[0], _m[1], _tx, _ty, _tx + _w, _ty + _h)) {
				draw_sprite_stretched_ext(THEME.textbox, 1, _tx, _ty, _w, _h, boxColor);
				
				if(editing != i && mouse_press(mb_left, active)) {
					editing = i;
					if(i == n) array_push(array, "");
					
					tb_edit._current_text = array[i];
					tb_edit.activate();
				}
				
				if(mouse_click(mb_left, active))
					draw_sprite_stretched(THEME.textbox, 2, _tx, _ty, _w, _h);
					
			} //else 
				// draw_sprite_stretched_ext(THEME.textbox, 0, _tx, _ty, _w, _h, boxColor);
				
			if(i < n) {
				draw_set_text(font, fa_left, fa_center, COLORS._main_text);
				draw_text_cut(_tx + ui(8), round(_ty + _h / 2), array[i], _w - ui(16));
			}
		}
			
		if(editing != noone) {
			_ty = y + editing * (_h + ui(4));
			tb_edit.setFocusHover(active, hover);
			tb_edit.draw(_tx, _ty, _w, _h, array[editing], _m);
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