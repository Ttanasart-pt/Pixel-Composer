function dialogCall(_dia, _x = noone, _y = noone, param = {}) {
	if(_x == noone) _x = WIN_SW / 2;
	if(_y == noone) _y = WIN_SH / 2;
	
	var dia = instance_exists(_dia)? instance_find(_dia, 0) : instance_create_depth(_x, _y, 0, _dia);
	
	dia.x = _x;
	dia.y = _y;
	
	var args = variable_struct_get_names(param);
	for( var i = 0; i < array_length(args); i++ ) {
		variable_instance_set(dia, args[i], variable_struct_get(param, args[i]));
	}
	
	return dia;
}

function menuCall(_x = mouse_mx, _y = mouse_my, menu = []) {
	var dia = dialogCall(o_dialog_menubox, _x, _y);
	dia.setMenu(menu);
	return dia;
}