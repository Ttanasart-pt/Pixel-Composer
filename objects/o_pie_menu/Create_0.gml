/// @description Insert description here
// You can write your code in this editor

#region data
	depth   = -9999;
	
	menu_id = "";
	menus   = [];
	pie_rad = ui(96);
	hght    = ui(36);
	
	context   = noone;
	active    = true;
	anim_prog = 0;
	
	function setMenu(menu) {
		menus = menu;
	}
	
	HOVER = self;
	FOCUS = self;
#endregion