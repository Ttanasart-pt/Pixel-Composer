function dialogCall(_dia, _x = noone, _y = noone, param = {}, create = false) {
	if(_x == noone) _x = WIN_SW / 2;
	if(_y == noone) _y = WIN_SH / 2;
	
	var dia = !create && instance_exists(_dia)? instance_find(_dia, 0) : instance_create_depth(_x, _y, 0, _dia);
	
	dia.x = _x;
	dia.y = _y;
	dia.xstart = _x;
	dia.ystart = _y;
	dia.resetPosition();
	
	var args = variable_struct_get_names(param);
	for( var i = 0; i < array_length(args); i++ ) {
		variable_instance_set(dia, args[i], variable_struct_get(param, args[i]));
	}
	
	setFocus(dia.id, "Dialog");
	return dia;
}

function menuCall(_x = mouse_mx + ui(4), _y = mouse_my + ui(4), menu = [], align = fa_left) {
	var dia = dialogCall(o_dialog_menubox, _x, _y);
	dia.setMenu(menu, align);
	return dia;
}

function submenuCall(_x, _y, _depth, menu = []) {
	var dia = instance_create_depth(_x - ui(4), _y, _depth - 1, o_dialog_menubox);
	dia.setMenu(menu);
	return dia;
}

function menuItem(name, func, spr = noone, hotkey = noone) {
	return new MenuItem(name, func, spr, hotkey);
}
function MenuItem(name, func, spr = noone, hotkey = noone) constructor {
	active = true;
	self.name	= name;
	self.func	= func;
	self.spr	= spr;
	self.hotkey = hotkey;
	
	isShelf = false;
	
	static setIsShelf = function() {
		isShelf = true;
		return self;
	}
	
	static setActive = function(active) {
		self.active = active;
		return self;
	}
	
	static deactivate = function() {
		active = false;
		return self;
	}
}

function menuItemGroup(name, group) {
	return new MenuItemGroup(name, group);
}
function MenuItemGroup(name, group) constructor {
	active = true;
	self.name	= name;
	self.group  = group;
}