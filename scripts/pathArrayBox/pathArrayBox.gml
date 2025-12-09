function pathArrayBox(_target, _data, _onClick) : widget() constructor {
	target  = _target;
	data    = _data;
	onClick = _onClick;
	
	openPath = button(function() {
		var path = get_open_filenames_compat(data[0], data[1]);
		key_release();
		if(path == "") return noone;
		
		var paths = string_splice(path, "\n");
		onClick(paths);
	}).setIcon(THEME.button_path_icon, 0, COLORS._main_icon).iconPad();
	
	static trigger = function() { 
		dialogPanelCall(new Panel_Image_Array_Editor(target));
	}
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _files, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		hovering = false;
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, w, h, boxColor);
		
		var bs = min(_h, ui(32));
		if(_w - bs > ui(100)) {
			var bx = _x + _w - bs;
			
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, _h, CDEF.main_mdwhite, 1);
			openPath.setFocusHover(active, hover);
			openPath.draw(bx, _y + _h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
			_w -= bs;
		}
		
		var click = false;
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			hovering = true;
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 1, x, y, w, h, boxColor);
			
			if(mouse_press(mb_left, active)) {
				trigger();
				click = true;
			}
			
			if(mouse_click(mb_left, active)) draw_sprite_stretched(THEME.textbox, 2, x, y, w, h);
			
		} else {
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, x, y, w, h, boxColor);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var aa = interactable * 0.25 + 0.75;
		
		if(!is_array(_files)) _files = [ _files ];
		var len = array_length(_files);
		
		var txt = $"({len}) [";
		for( var i = 0; i < len; i++ )
			txt += (i? ", " : "") + filename_name_only(_files[i]);
		txt += "]";
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		var _scis = gpu_get_scissor();
		if(_h >= line_get_height()) {
			gpu_set_scissor(_x, _y, _w - ui(16), _h);
			draw_set_alpha(aa);
			draw_text_add(_x + ui(8), _y + _h / 2, txt);
			draw_set_alpha(1);
		}
		gpu_set_scissor(_scis);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() { return new pathArrayBox(target, data, onClick); }
}