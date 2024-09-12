/// @description Insert description here
event_inherited();

if(item_sel_submenu) {
	if(!instance_exists(item_sel_submenu))
		item_sel_submenu = noone;
	exit;
}

if(init_press_l) {
	if(MOUSE_POOL.lrelease) 
		init_press_l = false;
	exit;
}

var hov = point_in(mouse_raw_x, mouse_raw_y);
if(submenu) hov |= submenu.point_in(mouse_raw_x, mouse_raw_y);

_hovering_ch = hov;
if(!hov && MOUSE_POOL.lpress) instance_destroy();