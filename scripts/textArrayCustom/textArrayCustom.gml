function textArrayCustom(_onModify = noone) : widget() constructor {
	onModify = _onModify;
	
	editArray = undefined;
	editIndex = undefined;
	tb_edit   = textBox_Text(function(t) /*=>*/ {
		if(editIndex == undefined) return;
		
		if(t == "") {
			if(editIndex < array_length(editArray) - 1)
				array_delete(editArray, editArray, 1);
		} else 
			editArray[editIndex] = t;
		editIndex = undefined;
	}).setEmpty();
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, arr, _m, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		w = _w;
		editArray = arr;
		
		var hg    = line_get_height(font, ui(4));
		var hh    = 0;
		var hovi  = noone;
		var toDel = undefined;
		
		var yy = _y;
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
			var _txt = arr[i];
			
			if(editIndex == i) {
				tb_edit.setFocusHover(active, hover);
				tb_edit.draw(_x, yy, _w, hg, _txt, _m);
				
				yy += hg + ui(2);
				hh += hg + ui(2);
				continue;
			}
			
			var _hov = hover && point_in_rectangle(_m[0], _m[1], _x, yy, _x + _w, yy + hg);
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, hg, COLORS._main_icon_light);
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, hg, boxColor);
			if(_hov) draw_sprite_stretched_ext(THEME.textbox, 1, _x, yy, _w, hg, boxColor);
			
			draw_set_color(COLORS._main_text);
			draw_text_add(_x + ui(8), yy + hg / 2, _txt);
			
			var _rmx = _x + _w - ui(4 + 8);
			var _rmy = yy + hg / 2;
			var _chv = hover && point_in_circle(_m[0], _m[1], _rmx, _rmy, ui(8));
			var  cc  = COLORS._main_icon;
			
			if(_chv) {
				_hov = false;
				 cc  = COLORS._main_value_negative;
				if(mouse_lpress(active)) toDel = i;
			}
			
			draw_sprite_ui(THEME.cross_16, 0, _rmx, _rmy, 1, 1, 0, cc);
			if(_hov && mouse_lpress(active)) {
				editIndex = i;
				tb_edit.activate(_txt);
			}
			
			yy += hg + ui(2);
			hh += hg + ui(2);
		}
		
		if(toDel != undefined) {
			array_delete(arr, toDel, 1);
			if(onModify) onModify();
		}
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, yy, _w, hg, boxColor);
		
		if(editIndex == array_length(arr)) {
			tb_edit.setFocusHover(active, hover);
			tb_edit.draw(_x, yy, _w, hg, "", _m);
			
		} else {
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, yy, _w, hg, boxColor);
			draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + ui(8), yy + hg / 2, __txt("Add value"));
			
			if(hover && point_in_rectangle(_m[0], _m[1], _x, yy, _x + _w, yy + hg)) {
				draw_sprite_stretched_ext(THEME.textbox, 1, _x, yy, _w, hg, boxColor, 0.5 + !hide * 0.5);	
				if(mouse_lpress(active)) {
					editIndex = array_length(arr);
					tb_edit.activate("");
				}
			}
		}
		
		yy += hg + ui(2);
		hh += hg + ui(2);
		
		resetFocus();
		return hh;
	}
	
	static clone = function() /*=>*/ {return new textArrayCustom(onModify)};
}