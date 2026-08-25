/// @description Insert description here
if(is_winwin(window)) winwin_set_rectangle(window, WIN_X + dialog_x, WIN_Y + dialog_y, dialog_w, dialog_h);

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

var _mx = is_winwin(window)? mouse_rx - WIN_X : mouse_mx;
var _my = is_winwin(window)? mouse_ry - WIN_Y : mouse_my;
var hov = point_in(_mx, _my);

if(instance_exists(submenu)) {
	var _mx = is_winwin(submenu.window)? mouse_rx - WIN_X : mouse_mx;
	var _my = is_winwin(submenu.window)? mouse_ry - WIN_Y : mouse_my;
	hov = hov || submenu.point_in(_mx, _my);
}

_hovering_ch = hov;

if(!hov && mouse_lpress()) instance_destroy();