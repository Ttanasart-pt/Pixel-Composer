/// @description Insert description here
with(o_pie_menu) { if(self != other) active = false; }

#region data
	depth       = -9999;
	context_str = "Pie";
	
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
	deactivate_key       = keyboard_check(vk_anykey)? keyboard_lastkey : undefined;
	deactivate_keyable   = false;
	
	onDestroy     = -1;
	itemSelecting = -1;
	
	preFocus = FOCUS;
	setFocus(self.id);
#endregion

function setMenu(menu) {
	draw_set_font(font);
	
	name_width = 0;
	pie_size   = 0;
	menus      = [];
	
	for( var i = 0, n = array_length(menu); i < n; i++ ) {
		var _menuItem = menu[i];
		if(is(_menuItem, MenuItem)) {
			var _txt  = _menuItem.name;
			var _key  = string_trim_start(_txt, [">"]);
			
			var _hasSub = string_pos(">", _txt);
			if(_hasSub) {
				var _sep = string_split(_txt, ">");
				_key = _sep[0];
			}
			
			var _node = struct_try_get(ALL_NODES, _key, noone);
			var _labW = string_width(_menuItem.name);
			
			if(_node) {
				_menuItem.isNode = true;
				_menuItem.preset = _hasSub;
				
				if(_hasSub) {
					_menuItem.name       = _txt + "   ";
					_menuItem.nodeName   = _node.getName();
					_menuItem.presetName = _sep[1];
					
					if(!has(PRESETS_MAP, _key)) continue;
					
					var presNode = PRESETS_MAP[$ _key]; 
					if(!has(presNode, _menuItem.presetName)) continue;
					
					var presObj = presNode[$ _menuItem.presetName];
					_menuItem.surface = presObj.getThumbnail();
					if(!is_surface(_menuItem.surface))
						_menuItem.spr = _node.getSpr();
						
				} else {
					_menuItem.name   = _node.getName();
					_menuItem.spr    = _node.getSpr();
				}
				
				_labW = string_width(_menuItem.name);
			}
			
			var _tww  = _labW + (_menuItem.spr     != noone) * (hght + ui(4)) 
				              + (_menuItem.surface != noone) * (hght + ui(4));
			
			_menuItem.displayWidth = _tww;
			pie_size += hght;
			array_push(menus, _menuItem);
			name_width = max(name_width, _tww);
			
		} else if(is(_menuItem, MenuItemGroup)) {
			var amo = array_length(_menuItem.group);
			var mww = ui(16) + amo * (_menuItem.spacing + ui(4));
			_menuItem.width = max(string_width(_menuItem.name), mww)
			pie_size += ui(48);
			
			array_push(menus, _menuItem);
			name_width = max(name_width, _menuItem.width);
			
		} else if(is(_menuItem, MenuWidget)) {
			KEYBOARD_BLOCK = true;
			pie_size += ui(48);
			
			array_push(menus, _menuItem);
			name_width = max(name_width, string_width(_menuItem.name), ui(200));
		}
		
	}
	
	name_width += ui(16 + 4) + hght;
	if(array_empty(menus)) menus = [ menuItem(__txt("Create pie menu..."), function() /*=>*/ {return menuItemEdit(menu_id,true)}) ];
	
	refreshAngles();
	return self;
}

function setHalf() {
	y -= ui(24);
	
	pie_half = true;
	refreshAngles();
	return self;
}

function refreshAngles() {
	angles  = [];
	var len = array_length(menus);
	
	if(pie_half) {
		pie_width  = max(ui(32), pie_size / 4);
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
		pie_width  = max(ui(32), pie_size / 5);
		pie_height = max(ui(32), pie_size / 3);
		
		     if(len == 1) angles = [ 90 ];
		else if(len == 2) angles = [ 90, 270 ];
		else if(len == 3) angles = [ 90, 210, 330 ];
		else {
			var odd = len % 2;
			var amo = floor(len / 2);
			
			if(odd) {
				var st = -1 +  .5/amo;
				var ed =  1 - 1.5/amo;
				
			} else {
				var st = -1 + .5/amo;
				var ed =  1 - .5/amo;
			}
			
			var langles = array_create(amo);
			for( var i = 0; i < amo; i++ ) {
				var hhg = lerp(st, ed, i / (amo-1));
				var ang = 180 - darcsin(hhg);
				langles[amo-i-1] = ang;
			}
			
			var rangles = array_create(amo);
			for( var i = 0; i < amo; i++ ) {
				var hhg = lerp(st, ed, i / (amo-1));
				var ang = darcsin(hhg);
				rangles[amo-i-1] = ang;
			}
			
			angles = array_merge(odd? [90] : [], langles, rangles);
			array_sort(angles, true); 
		}
	}
	
}

function deactivate() {
	active = false;
	if(sFOCUS && preFocus) setFocus(preFocus);
}

function onActivate() {
	// instance_destroy(o_dialog_menubox);
}

function checkFocus() {
	if(itemSelecting != -1 && depth <= DIALOG_DEPTH_HOVER) {
		DIALOG_DEPTH_HOVER = depth;
		HOVER = self.id;
	}
} 

function checkDepth() {
	if(active && depth == DIALOG_DEPTH_HOVER) 
		setFocus(self.id);
}