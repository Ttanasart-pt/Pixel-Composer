/// @description Insert description here
event_inherited();

var hov = point_in(mouse_mx, mouse_my);
	
for( var i = 0, n = array_length(children); i < n; i++ ) {
	if(!instance_exists(children[i])) continue; 
	hov |= children[i].point_in(mouse_mx, mouse_my);
}
	
_hovering_ch = hov;
if((mouse_check_button_pressed(mb_left)) && !hov) 
	instance_destroy();