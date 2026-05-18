/// @description Insert description here
with(o_pie_menu) { if(self != other) active = false; }

#region data
	depth   = -9999;
	
	menu_id = "";
	menus   = [];
	
	name_width = ui(32);
	pie_size   = 0;
	pie_width  = ui(32);
	pie_height = ui(32);
	pie_half   = false;
	angles     = [];
	
	widget_width  = ui(160);
	widget_height = ui( 44)
	
	font     = f_p3;
	hght     = line_get_height(font, 8);
	
	context    = noone;
	active     = true;
	selectable = true;
	anim_prog  = 0;
	
	selecting = false;
	
	mouse_tx = mouse_mx;
	mouse_ty = mouse_my;
	
	activate_key_release = false;
	
	onActivate = -1;
	onDestroy  = -1;
	
	itemSelecting = -1;
	
	HOVER = self;
	FOCUS = self;
#endregion

function setMenu(menu) {
	draw_set_font(font);
	
	name_width = 0;
	pie_size   = 0;
	menus      = [];
	
	for( var i = 0, n = array_length(menu); i < n; i++ ) {
		var m = menu[i];
		if(is(m, MenuItem)) {
			var _txt  = m.name;
			var _key  = string_trim_start(_txt, [">"]);
			var _node = struct_try_get(ALL_NODES, _key, noone);
			
			if(_node) {
				m.name = _node.getName();
				m.spr  = _node.getSpr();
			}
			
			pie_size += hght;
			
			array_push(menus, m);
			name_width = max(name_width, string_width(m.name));
			
		} else if(is(m, MenuWidget)) {
			KEYBOARD_BLOCK = true;
			pie_size += ui(48);
			
			array_push(menus, m);
			name_width = max(name_width, string_width(m.name), ui(200));
		}
		
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
		pie_width  = max(ui(32), pie_size / 2);
		pie_height = max(ui(32), pie_size / 2);
		
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
		pie_width  = max(ui(32), pie_size / 3);
		pie_height = max(ui(32), pie_size / 3);
		
		     if(len == 1) angles = [ 90 ];
		else if(len == 2) angles = [ 90, 270 ];
		else if(len == 3) angles = [ 90, 210, 330 ];
		else {
			var odd = len % 2;
			var amo = floor(len / 2);
			
			var langles = [];
			for( var i = 1; i <= amo; i++ ) {
				var hhg = 1 - i / (amo + 1) * 2;
				var ang = 180 - darcsin(hhg);
				langles[i-1] = ang;
			}
			
			var rangles = [];
			for( var i = 1; i <= amo; i++ ) {
				var hhg = -1 + i / (amo + 1) * 2;
				var ang = darcsin(hhg);
				rangles[i-1] = ang;
			}
			
			angles = odd? [90] : [];
			angles = array_merge(angles, langles, rangles);
		}
	}
}