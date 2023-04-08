function fontScrollBox(_onModify) : widget() constructor {
	onModify  = _onModify;	
	
	open = false;
	open_rx = 0;
	open_ry = 0;
	
	align = fa_center;
	extra_button = button(function() { shellOpenExplorer(DIRECTORY + "Fonts"); } )
						.setTooltip("Open font folder")
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
	
	static draw = function(_x, _y, _w, _h, _text, _m = mouse_ui, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		open_rx = _rx;
		open_ry = _ry;
		h = _h;
		
		w = _w;
		if(extra_button != noone) {
			extra_button.setActiveFocus(hover, active);
			extra_button.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			w -= ui(40);
		}
		
		if(open) {
			resetFocus();
			return;
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
		
		draw_set_text(f_p0, align, fa_center, COLORS._main_text);
		draw_set_alpha(0.5 + 0.5 * interactable);
		if(align == fa_center)
			draw_text(_x + w / 2, _y + _h / 2 - ui(2), _text);
		else if(align == fa_left)
			draw_text(_x + ui(8), _y + _h / 2 - ui(2), _text);
		draw_set_alpha(1);
		
		draw_sprite_ui_uniform(THEME.scroll_box_arrow, 0, _x + w - 20, _y + _h / 2, 1, COLORS._main_icon, 0.5 + 0.5 * interactable);
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _w + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
	}
}