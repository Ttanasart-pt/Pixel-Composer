/// @description Insert description here
cur_c = int64(cola(draw_getpixel(mouse_mx, mouse_my)));

MOUSE_BLOCK = true;

if(mouse_check_button_pressed(mb_right) || keyboard_check_released(ALT)) {
	if(def_c != noone) onApply(def_c);
	instance_destroy();
}

if(mouse_check_button_pressed(mb_left)) {
	onApply(cur_c);
	instance_destroy();
}