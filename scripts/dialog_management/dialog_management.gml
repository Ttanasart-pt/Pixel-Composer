function dialogCall(_dia, _x = WIN_W / 2, _y = WIN_H / 2) {
	var dia = instance_exists(_dia)? instance_find(_dia, 0) : instance_create_depth(_x, _y, 0, _dia);
	
	dia.x = _x;
	dia.y = _y;
	
	return dia;
}