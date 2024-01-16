/// @description Insert description here
MOUSE_BLOCK = true;

var dx = mouse_mx + ui(36);
var dy = mouse_my + ui(36);
draw_sprite_stretched(THEME.color_picker_sample, 0, dx - ui(20), dy - ui(20), ui(40), ui(40));
draw_sprite_stretched_ext(THEME.color_picker_sample, 0, dx - ui(18), dy - ui(18), ui(36), ui(36), cur_c, 1);