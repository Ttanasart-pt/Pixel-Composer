function dialogCall(_dia, _x = WIN_W / 2, _y = WIN_H / 2, param = {}) {
	var dia = instance_exists(_dia)? instance_find(_dia, 0) : instance_create_depth(_x, _y, 0, _dia);
	
	dia.x = _x;
	dia.y = _y;
	
	var args = variable_struct_get_names(param);
	for( var i = 0; i < array_length(args); i++ ) {
		variable_instance_set(dia, args[i], variable_struct_get(param, args[i]));
	}
	
	return dia;
}