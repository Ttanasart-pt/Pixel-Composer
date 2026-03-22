/// @description Insert description here
cur_c = int64(cola(draw_getpixel(mouse_mx, mouse_my)));

MOUSE_BLOCK = true;

if(mouse_rpress(true, true) || keyboard_check_released(ALT)) {
	if(def_c != noone) onModify(def_c);
	instance_destroy();
}

if(mouse_lclick(true, true)) {
	onModify(cur_c);
	instance_destroy();
}