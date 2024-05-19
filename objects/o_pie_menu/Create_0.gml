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
	
	mouse_tx = mouse_mx;
	mouse_ty = mouse_my;
	mouse_ta = 0.5;
	
	function setMenu(menu) {
		menus = menu;
	}
	
	HOVER = self;
	FOCUS = self;
#endregion