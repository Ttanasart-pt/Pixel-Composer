function fontScrollBox(_onModify) : widget() constructor {
	onModify = _onModify;
	open     = false;
	open_rx  = 0;
	open_ry  = 0;
	
	align = fa_center;
	side_button = button(function() /*=>*/ {return shellOpenExplorer(DIRECTORY + "Fonts")})
						.setTooltip(__txtx("widget_font_open_folder", "Open font folder"))
						.setIcon(THEME.folder_content, 0, COLORS._main_icon).iconPad();
	
	refresh_button = button(function() /*=>*/ {return __initFontFolder(true)})
						.setTooltip(__txt("Refresh"))
						.setIcon(THEME.refresh_icon, 0, COLORS._main_icon).iconPad();
	
	static trigger = function() {
		dialogCall(o_dialog_fontscrollbox, x + open_rx, y + open_ry).setScrollBox(self);
		open = true;
	}
	
	static setInteract = function(i = noone) { 
		interactable = i;
		side_button.interactable = i;
	}
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _text, _m = mouse_ui, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		h = _h;
		w = _w;
		open_rx = _rx;
		open_ry = _ry;
		
		var _bs = min(_h, ui(32));
		
		if(_w - _bs > ui(100) && side_button != noone) {
			side_button.setFocusHover(active, hover);
			side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			_w -= _bs + ui(4);
		}
		
		if(_w - _bs > ui(100) && refresh_button != noone) {
			refresh_button.setFocusHover(active, hover);
			refresh_button.draw(_x, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			_x += _bs + ui(4);
			_w -= _bs + ui(4);
		}
		
		if(open) { resetFocus(); return h; }
		
		draw_sprite_stretched(THEME.textbox, 3, _x, _y, _w, _h);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched(THEME.textbox, 1, _x, _y, _w, _h);
			if(mouse_press(mb_left, active)) trigger();
			if(mouse_click(mb_left, active)) draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, _w, _h, COLORS._main_accent, 1);	
			
		} else {
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var _txt   = "";
		var _texts = is_array(_text)? _text : [ _text ];
		for( var i = 0, n = array_length(_texts); i < n; i++ ) 
			_txt += (i? ", " : "") + filename_name_only(_texts[i]);
			
		_txt  = $"[{_txt}]";
		_text = is_array(_text)? _txt : filename_name_only(_text);
		
		var _scr = gpu_get_scissor();
		gpu_set_scissor(_x + ui(4), _y, _w - ui(8), _h);
			draw_set_text(font, align, fa_center, COLORS._main_text);
			draw_set_alpha(0.5 + 0.5 * interactable);
				 if(align == fa_center) draw_text_add(_x + _w / 2, _y + _h / 2, _text);
			else if(align == fa_left)   draw_text_add(_x + ui(8), _y + _h / 2, _text);
			draw_set_alpha(1);
		gpu_set_scissor(_scr);
		
		draw_sprite_ui_uniform(THEME.icon_font, 0, _x + min(_h / 2, ui(20)), _y + _h / 2, min(1, _h / 24), COLORS._main_icon, 0.5 + 0.5 * interactable);
		
		if(WIDGET_CURRENT == self) 
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() { return new fontScrollBox(onModify); }
}