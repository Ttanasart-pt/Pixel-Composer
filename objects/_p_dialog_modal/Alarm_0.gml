/// @description init
event_inherited();

draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
dialog_w = max(dialog_w, string_width_ext(content, -1, dialog_w - ui(48)) + ui(48));
dialog_h = ui(112) + string_height_ext(content, -1, dialog_w - ui(48));