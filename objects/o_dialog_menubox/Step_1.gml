/// @description Insert description here
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

if(submenu != noone && !instance_exists(submenu)) 
	submenu = noone;

var hov = point_in(mouse_mx, mouse_my);
if(instance_exists(submenu)) 
	hov |= submenu.point_in(mouse_mx, mouse_my);

_hovering_ch = hov;
if(!hov && MOUSE_POOL.lpress) instance_destroy();