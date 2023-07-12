/// @description 
if(!active) exit;
if(textbox == noone) exit;

#region
	dialog_x = clamp(dialog_x, 0, WIN_W - dialog_w - 1);
	dialog_y = clamp(dialog_y, 0, WIN_H - dialog_h - 1);

	var _w   = 300;
	var _h   = array_length(data) * line_get_height(f_p0, 8);
	
	for( var i = 0; i < array_length(data); i++ ) {
		var _dat = data[i];
		var __w  = ui(40 + 32);
		
		draw_set_font(f_p2);
		__w += string_width(_dat[2]);
		
		draw_set_font(f_p0);
		__w += string_width(_dat[1]);
		
		_w = max(_w, __w);
	}
	
	dialog_w = _w;
	dialog_h = min(_h, 160);
	
	sc_content.resize(dialog_w, dialog_h);
#endregion

#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	sc_content.draw(dialog_x, dialog_y);
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion


if(keyboard_check_pressed(vk_escape))
	active = false;