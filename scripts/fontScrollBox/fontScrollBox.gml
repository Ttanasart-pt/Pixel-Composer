function fontScrollBox(_onModify) : widget() constructor {
	onModify  = _onModify;	
	
	open = false;
	open_rx = 0;
	open_ry = 0;
	
	align = fa_center;
	extra_button = button(function() { shellOpenExplorer(DIRECTORY + "Fonts"); } )
						.setTooltip(__txtx("widget_font_open_folder", "Open font folder"))
						.setIcon(THEME.folder_content, 0, COLORS._main_icon);
						
	static trigger = function() {
		refreshFontFolder();
		open = true;
		with(dialogCall(o_dialog_fontscrollbox, x + open_rx, y + open_ry)) {
			scrollbox = other;	
			align = other.align;
		}
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		extra_button.interactable = interactable;
	}
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _text, _m = mouse_ui, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		open_rx = _rx;
		open_ry = _ry;
		h = _h;
		w = _w;
		
		var _bs = min(_h, ui(32));
		
		if(_w - _bs > ui(100) && extra_button != noone) {
			extra_button.setFocusHover(active, hover);
			extra_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
			w -= _bs + ui(4);
		}
		
		if(open) {
			resetFocus();
			return h;
		}
		
		draw_sprite_stretched(THEME.textbox, 3, _x, _y, w, _h);
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + w, _y + _h)) {
			draw_sprite_stretched(THEME.textbox, 1, _x, _y, w, _h);
			if(mouse_press(mb_left, active))
				trigger();
			if(mouse_click(mb_left, active))
				draw_sprite_stretched_ext(THEME.textbox, 2, _x, _y, w, _h, COLORS._main_accent, 1);	
		} else {
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, w, _h, c_white, 0.5 + 0.5 * interactable);
			if(mouse_press(mb_left)) deactivate();
		}
		
		var _txt   = "";
		var _texts = is_array(_text)? _text : [ _text ];
		for( var i = 0, n = array_length(_texts); i < n; i++ ) 
			_txt += (i? ", " : "") + filename_name_only(_texts[i]);
		_txt  = $"[{_txt}]";
		_text = is_array(_text)? _txt : filename_name_only(_text);
		
		draw_set_text(font, align, fa_center, COLORS._main_text);
		draw_set_alpha(0.5 + 0.5 * interactable);
		
			 if(align == fa_center) draw_text_add(_x + w / 2, _y + _h / 2, _text);
		else if(align == fa_left)   draw_text_add(_x + ui(8), _y + _h / 2, _text);
		
		draw_set_alpha(1);

		draw_sprite_ui_uniform(THEME.icon_font, 0, _x + min(_h / 2, ui(20)), _y + _h / 2, min(1, _h / 24), COLORS._main_icon, 0.5 + 0.5 * interactable);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new fontScrollBox(onModify);
		return cln;
	}
}