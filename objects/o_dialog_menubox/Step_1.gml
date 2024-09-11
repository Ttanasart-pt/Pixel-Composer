/// @description Insert description here
event_inherited();

if(item_sel_submenu) {
	if(!instance_exists(item_sel_submenu))
		item_sel_submenu = noone;
	exit;
}

var hov = point_in(mouse_raw_x, mouse_raw_y);
if(submenu) hov |= submenu.point_in(mouse_raw_x, mouse_raw_y);
	
_hovering_ch = hov;
if(!hov && mouse_press(mb_left)) instance_destroy();