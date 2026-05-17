/// @description Insert description here
with(o_pie_menu) { if(self != other) instance_destroy(); }

#region data
	depth   = -9999;
	
	menu_id = "";
	menus   = [];
	
	name_width = ui(32);
	pie_width  = ui(32);
	pie_height = ui(32);
	pie_half   = false;
	angles     = [];
	
	font     = f_p3;
	hght     = line_get_height(font, 8);
	
	context    = noone;
	active     = true;
	selectable = true;
	anim_prog  = 0;
	
	selecting = false;
	
	mouse_tx = mouse_mx;
	mouse_ty = mouse_my;
	
	onActivate = -1;
	onDestroy  = -1;
	
	itemSelecting = -1;
	
	HOVER = self;
	FOCUS = self;
#endregion

function setMenu(menu) {
	draw_set_font(font);
	
	name_width = 0;
	menus      = [];
	
	for( var i = 0, n = array_length(menu); i < n; i++ ) {
		var m = menu[i];
		if(!is(m, MenuItem)) continue;
		
		array_push(menus, m);
		name_width = max(name_width, string_width(m.name));
	}
	
	name_width += ui(16 + 4) + hght;
	if(array_empty(menus)) menus = [ menuItem(__txt("Create pie menu..."), function() /*=>*/ {return menuItemEdit(menu_id,true)}) ];
	
	refreshAngles();
	return self;
}

function setHalf() {
	pie_half = true;
	refreshAngles();
	return self;
}

function refreshAngles() {
	angles  = [];
	var len = array_length(menus);
	
	if(pie_half) {
		pie_width  = max(ui(32), len / 2 * hght);
		pie_height = max(ui(32), len / 2 * hght);
		
		     if(len == 1) angles = [ 90 ];
		else {
			var phg = (pie_height + hght / 2) / ((len - 1) / 2);
			var cen = (len - 1) / 2;
			
			for( var i = 0; i < len; i++ ) {
				var prg = cen - abs(i - cen);
				var hhg = prg * phg;
				
				var ang = darcsin(clamp(hhg / pie_height, 0, 1));
				if(i >= cen) ang = 180 - ang;
				angles[i] = ang;
			}
		}
		
	} else {
		pie_width  = max(ui(32), len / 3 * hght);
		pie_height = max(ui(32), len / 3 * hght);
		
		     if(len == 1) angles = [ 90 ];
		else if(len == 2) angles = [ 90, 270 ];
		else {
			var lamo = floor((len - 2) / 2);
			var ramo = len - 2 - lamo;
			
			var langles = [];
			if(lamo == 1) langles = [ 180 ];
			else for( var i = 1; i <= lamo; i++ ) {
				var hhg = 1 - i / (lamo + 1) * 2;
				var ang = 180 - darcsin(hhg);
				langles[i-1] = ang;
			}
			
			var rangles = [];
			if(ramo == 1) rangles = [ 180 ];
			else for( var i = 1; i <= ramo; i++ ) {
				var hhg = -1 + i / (ramo + 1) * 2;
				var ang = darcsin(hhg);
				rangles[i-1] = ang;
			}
			
			angles = array_merge([90], langles, [270], rangles);
		}
	}
}