/// @description 
active = textbox != noone;
if(textbox == noone) exit;
if(textbox != WIDGET_CURRENT) exit;

#region
	draw_set_text(f_code, fa_left, fa_top, COLORS._main_text);
	dialog_w = string_width(prompt)  + ui(16);
	dialog_h = string_height(prompt) + ui(16);
	
	dialog_x = clamp(dialog_x, 0, WIN_W - dialog_w - 1);
	var dy   = clamp(dialog_y - dialog_h, 0, WIN_H - dialog_h - 1);
#endregion

#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dy, dialog_w, dialog_h);
	
	var cx = dialog_x + ui(8);
	var cy = dy + ui(8);
	var ind = 1;
	var amo = string_length(prompt);
	var cch = "";
	var fname = true;
	var var_ind = 0;
	var def_val = false;
	
	repeat(amo) {
		cch = string_char_at(prompt, ind);
		ind++;
		
		if(cch == "(") fname = false;
		if(cch == ",") {
			def_val = false;
			var_ind++;
		}
		
		if(cch == "=")
			def_val = true;
		
		if(cch == "(" || cch == ")" || cch == "[" || cch == "]" || cch == "{" || cch == "}") 
			draw_set_color(COLORS.lua_highlight_bracklet);
		else if(cch == ",") 
			draw_set_color(COLORS._main_text);
		else if(fname)
			draw_set_color(COLORS.lua_highlight_function);
		else {
			if(var_ind == index) {
				draw_set_color(def_val? COLORS._main_text : COLORS.lua_highlight_number);
			} else
				draw_set_color(COLORS._main_text_sub);
		}
		
		draw_text(cx, cy, cch);
		cx += string_width(cch);
	}
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dy, dialog_w, dialog_h);
#endregion


if(keyboard_check_pressed(vk_escape))
	textbox = noone;