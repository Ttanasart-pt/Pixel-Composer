function pathArrayBox(_target, _data, _onClick) : widget() constructor {
	target  = _target;
	data    = _data;
	onClick = _onClick;
	
	openPath = button(function() {
		var path = get_open_filenames(data[0], data[1]);
		key_release();
		if(path == "") return noone;
		
		var paths = string_splice(path, "\n");
		onClick(paths);
	}, THEME.button_path_icon);
	
	static trigger = function() { 
		with(dialogCall(o_dialog_image_array_edit, WIN_W / 2, WIN_H / 2))
			target = other.target;
	}
	
	static draw = function(_x, _y, _w, _h, _files, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		openPath.setFocusHover(active, hover);
		openPath.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
		_w -= ui(40);
		
		var click = false;
		draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched(THEME.textbox, 1, _x, _y, _w, _h);
			
			if(mouse_press(mb_left, active)) {
				trigger();
				click = true;
			}
			
			if(mouse_click(mb_left, active))
				draw_sprite_stretched(THEME.textbox, 2, _x, _y, _w, _h);
		} else {
			draw_sprite_stretched(THEME.textbox, 0, _x, _y, _w, _h);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var aa = interactable * 0.25 + 0.75;
		if(!is_array(_files)) _files = [ _files ];
		var len = array_length(_files);
		var txt = "(" + string(len) + ") " + "[";
		for( var i = 0; i < array_length(_files); i++ )
			txt += (i? ", " : "") + filename_name_only(_files[i]);
		txt += "]";
		
		draw_set_alpha(aa);
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text_cut(_x + ui(8), _y + _h / 2, txt, _w - ui(16));
		draw_set_alpha(1);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return click;
	}
}