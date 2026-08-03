/// @description Insert description here
if(is_winwin(window)) winwin_set_rectangle(window, window_get_x() + dialog_x, window_get_y() + dialog_y, dialog_w, dialog_h);

if(item_sel_submenu) { 
	if(!instance_exists(item_sel_submenu))
		item_sel_submenu = noone;
	exit;
}

if(init_press_l) {
	if(mouse_lrelease()) 
		init_press_l = false;
	exit;
}

if(submenu != noone && !instance_exists(submenu)) 
	submenu = noone;

var _mx = window? mouse_rx - window_get_x() : mouse_mx;
var _my = window? mouse_ry - window_get_y() : mouse_my;
var hov = point_in(_mx, _my);

if(instance_exists(submenu)) {
	var _mx = submenu.window? mouse_rx - window_get_x() : mouse_mx;
	var _my = submenu.window? mouse_ry - window_get_y() : mouse_my;
	hov = hov || submenu.point_in(_mx, _my);
}

_hovering_ch = hov;

if(!hov && mouse_lpress()) instance_destroy();