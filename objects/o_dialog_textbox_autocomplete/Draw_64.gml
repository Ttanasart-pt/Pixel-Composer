/// @description 
active = textbox != noone && (array_length(data) || textbox.autocomplete_subt != "");

if(textbox == noone)				exit;
if(textbox != WIDGET_CURRENT)		exit;
if(dialog_x == 0 && dialog_y == 0)	exit;
if(array_empty(data) && textbox.autocomplete_subt == "") exit;

#region dialog
	dialog_x = clamp(dialog_x, 0, WIN_W - dialog_w - 1);
	dialog_y = clamp(dialog_y, 0, WIN_H - dialog_h - 1);

	var _w = 300;
	var _h = min(show_items, array_length(data)) * line_get_height(font, pad_item);
	
	for( var i = 0, n = array_length(data); i < n; i++ ) {
		var _dat = data[i];
		var __w  = ui(40 + 32);
		
		draw_set_font(font);
		__w += string_width(_dat[2]);
		__w += string_width(_dat[1]);
		
		_w = max(_w, __w);
	}
	
	dialog_w = _w + 6;
	dialog_h = _h;
	
	sc_content.resize(_w, dialog_h);
#endregion

#region draw
	var _txt = textbox.autocomplete_subt;
	if(_txt != "") dialog_h += ui(20);
	
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	sc_content.setFocusHover(true, true);
	sc_content.draw(dialog_x, dialog_y);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	if(_txt != "") {
		draw_set_text(f_p4, fa_left, fa_bottom, COLORS._main_text_sub);
		draw_text(dialog_x + ui(6), dialog_y + dialog_h - ui(4), _txt);
	}
#endregion

if(keyboard_check_pressed(vk_escape))
	textbox = noone;