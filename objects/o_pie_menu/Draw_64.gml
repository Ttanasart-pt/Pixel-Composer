/// @description Insert description here
var amo  = array_length(menus);
var mdir = point_direction(x, y, mouse_mx, mouse_my);
var mdis = point_distance( x, y, mouse_mx, mouse_my);

#region anim
	anim_prog = lerp_float(anim_prog, active, 2);
	if(anim_prog == 0 && !active) instance_destroy();
	
	var disSel = mdis > pie_width * 2/3 && mdis < name_width + pie_width + ui(64);
	if(pie_half) selectable = disSel && mouse_my <= y + hght / 2;
	else         selectable = disSel;
#endregion

#region mouse focus 
	draw_set_circle_precision(32);
	draw_set_color(COLORS._main_icon);
	
	draw_set_color(selecting? COLORS._main_icon_light : COLORS._main_icon);
	if(selectable) {
		var tdir = point_direction(x, y, mouse_tx, mouse_ty);
		var fx = x + lengthdir_x(ui(4), tdir);
		var fy = y + lengthdir_y(ui(4), tdir);
		var tx = lerp(x, mouse_tx, anim_prog);
		var ty = lerp(y, mouse_ty, anim_prog);
		draw_line(fx, fy, tx, ty);
	}
	
	draw_set_alpha(.5 + selectable * .5);
	draw_circle(x, y, ui(4), true);
	
	draw_set_color(COLORS._main_icon_dark);
	draw_circle(x, y, ui(4)-2, true);
	draw_set_alpha(1);
#endregion

#region draw
	var mx = mouse_mx;
	var my = mouse_my;
	var pd = ui(8);
	var bs = ui(24);
	
	var mouse_free = !MOUSE_WRAPPING && !MOUSE_BLOCK && CURSOR_LOCK_X == 0 && CURSOR_LOCK_Y == 0;
	if(mouse_free) {
		mouse_tx = mx;
		mouse_ty = my;
	}
	
	selecting = false;
	var edit  = false;
	var widg  = false;
	
	var mouse_rel  = global_mouse_right_is_released() || mouse_lpress();
	    mouse_rel |= activate_key_release && keyboard_check_released(vk_anykey);
	    // mouse_rel &= WIDGET_CURRENT == undefined;
	
	var mouse_sel = sHOVER && mouse_rel;
	
	var _bx0, _bx1, _by0, _by1;
	
	var _itemSelecting = itemSelecting;
	itemSelecting = -1;
	
	var asel = undefined;
	if(amo == 1) {
		if(mdir > 0 && mdir < 180)
			itemSelecting = 0;
			
	} else if(amo == 2) {
		if(pie_half) {
			if(abs(angle_difference(0, mdir)) < 90)
				 itemSelecting = 0;
			else itemSelecting = 1;
			
		} else {
			if(mdir > 0 && mdir < 180)
				 itemSelecting = 0;
			else itemSelecting = 1;
		}
		
	} else for( var i = 0; i < amo; i++ ) {
		var a0 = angles[(i-1+amo)%amo];
		var a1 = angles[(i  +amo)%amo];
		var a2 = angles[(i+1+amo)%amo];
		
		var h0 = lerp_angle_direct(a1, a0, .5);
		var h1 = lerp_angle_direct(a1, a2, .5);
		
		if(angle_difference(h0, mdir) < 0 && angle_difference(h1, mdir) >= 0)
			itemSelecting = i;
	}
	
	if(itemSelecting > -1 && is(menus[itemSelecting], MenuWidget))
		itemSelecting = -1;
	
	var scis = gpu_get_scissor();
	var _spw, _sph;
	var _ba, _bx, _by;
	
	for( var i = 0; i < amo; i++ ) {
		var _menuItem = menus[i];
		
		_ba = angles[i];
		
		_bx = x + lengthdir_x(anim_prog * pie_width,  _ba);
		_by = y + lengthdir_y(anim_prog * pie_height, _ba);
		
		var _hal = fa_center;
		if(abs(angle_difference(  0, _ba)) < 80) _hal = fa_left;
		if(abs(angle_difference(180, _ba)) < 80) _hal = fa_right;
		
		var _val  = fa_center;
		var label = _menuItem.name;
		
		if(is(_menuItem, MenuItem)) {
			var _spr  = _menuItem.spr;
			var _surf = _menuItem.surface;
			
			draw_set_font(font);
			_sph  = hght * anim_prog;
			_spw  = string_width(label) + pd * 2;
			_spw += (_spr  != noone) * (_sph + ui(4));
			_spw += (_surf != noone) * (_sph + ui(4));
			
			_spw *= anim_prog;
				
		} else if(is(_menuItem, MenuItemGroup)) {
			_spw = _menuItem.width;
			_sph = ui(2 + 16) + _menuItem.spacing + ui(4);			
			
		} else if(is(_menuItem, MenuWidget)) {
			_spw = widget_width;
			_sph = widget_height;
		}
		
		switch(_hal) { 
			case fa_left   : _bx0 = _bx;            break;
			case fa_right  : _bx0 = _bx - _spw;     break;
			case fa_center : _bx0 = _bx - _spw / 2; break;
		}
		
		switch(_val) { 
			case fa_top    : _by0 = _by;            break;
			case fa_bottom : _by0 = _by - _sph;     break;
			case fa_center : _by0 = _by - _sph / 2; break;
		}
		
		_bx1 = _bx0 + _spw;
		_by1 = _by0 + _sph;
		
		if(point_in_rectangle(mx, my, _bx0, _by0, _bx1, _by1))
			itemSelecting = i;
		    
		var _hov  = active && selectable && _itemSelecting == i;
		var _hovL = active && selectable && point_in_rectangle(mx, my, _bx0 - bs - ui(4), _by0, _bx1 + bs + ui(4), _by1);
		var sx    = _hal == fa_left? _bx1 + ui(2) + bs/2 : _bx0 - ui(2) - bs/2;
		var sy    = _by0 + bs/2;
		var sHov  = point_in_circle(mx, my, sx, sy, bs/2);
		
		draw_sprite_stretched(THEME.textbox, 3, _bx0, _by0, _spw, _sph);
		if(_hov && !sHov) {
			mouse_tx  = _bx0 + _spw / 2;
			mouse_ty  = _by0 + _sph / 2;
			selecting = true;
			
			draw_sprite_stretched_ext(THEME.textbox, 3, _bx0, _by0, _spw, _sph, COLORS.dialog_menubox_highlight);
			if(is(_menuItem, MenuItem) && mouse_sel) {
				var _dat = {
					_x      : _bx0,
					x       : _bx1,
					y       : _by0,
					depth   : depth,
					name    : _menuItem.name,
					index   : i,
					context : context,
					params  : _menuItem.params,
				};
				
				onActivate();
				var _res = _menuItem.toggleFunction(_dat);
			}
		}
		
		if(_hovL && editable && menu_id != "") {
			draw_sprite_ui(THEME.gear_16, 0, sx, sy, 1, 1, 0, sHov? COLORS._main_icon_light : COLORS._main_icon, .5 + sHov * .5);
			if(sHov) {
				selectable = false;
				if(mouse_rel) edit = true;
			}
		}
		
		if(is(_menuItem, MenuItem)) {
			gpu_set_scissor(_bx0, _by0, _spw, _sph);
			if(_spr != noone) {
				var spr = is_array(_spr)? _spr[0] : _spr;
				var ind = is_array(_spr)? _spr[1] : 0;
				var aa  = _menuItem.active * 0.5 + 0.25;
				
				if(sprite_exists(spr)) {
					var ss = (_sph - ui(8)) / sprite_get_height(spr);
					draw_sprite_ext(spr, ind, _bx0 + pd + _sph/2, _by0 + _sph/2, ss, ss, 0, COLORS._main_icon_light, aa * anim_prog);
				}
			}
			
			if(_surf != noone && is_surface(_surf)) {
				var aa = _menuItem.active * 0.75 + 0.25;
				var _srfw = surface_get_width(_surf);
				var _srfh = surface_get_height(_surf);
				var ss = (_sph - ui(8)) / max(_srfw, _srfh);
				
				var _srfx = _bx0 + ui(4) + _sph/2 - _srfw*ss/2;
				var _srfy = _by0         + _sph/2 - _srfh*ss/2;
				
				draw_surface_ext(_surf, _srfx, _srfy, ss, ss, 0, COLORS._main_icon_light, aa * anim_prog);
			}
				
			if(_menuItem.toggle != noone) {
				var tog = _menuItem.toggle(_menuItem);
				if(tog) draw_sprite_ui(THEME.icon_toggle, 0, _bx0 + pd + _sph/2, _by0 + _sph/2, 1, 1, 0, COLORS._main_icon_light);
			}
			
			var tx = _bx0 + pd
				+ (_spr  != noone) * (_sph + ui(4))
				+ (_surf != noone) * (_sph + ui(4));
			
			var aa = _menuItem.active * 0.75 + 0.25;
			draw_set_text(font, fa_left, fa_center, _hov && !sHov? COLORS._main_text_accent : COLORS._main_text, aa * anim_prog);
			if(_menuItem[$ "isNode"] && _menuItem[$ "preset"]) {
				var ttx = tx;
				var tty = _by0 + _sph / 2;
				
				draw_text(ttx, tty, _menuItem.nodeName);   ttx += string_width(_menuItem.nodeName) + ui(20);
				draw_sprite_ui_uniform(THEME.arrow, 0, ttx - ui(10), tty, 1, COLORS._main_icon);
				draw_text(ttx, tty, _menuItem.presetName);
				
			} else draw_text(tx, _by0 + _sph / 2, label);
			draw_set_alpha(1);
			gpu_set_scissor(scis);
			
		} else if(is(_menuItem, MenuItemGroup)) {
			var _txt = _menuItem.name;
			var _gro = _menuItem.group;
			var _its = _menuItem.spacing;
			var _amo = array_length(_gro);
			
			draw_set_text(f_p4, fa_center, fa_top, _hov && !sHov? COLORS._main_text_accent : COLORS._main_text);
			draw_text(_bx0 + _spw / 2, _by0 + ui(2), _txt);
			
			var _iw = _amo * (_its + ui(4)) - ui(4);
			var _ix = _bx0 + _spw / 2 - _iw / 2;
			var _iy = _by0 + ui(2 + 16);
			
			for( var j = 0; j < _amo; j++ ) {
				var ixx = _ix + j * (_its + ui(4));
				var iyy = _iy;
				
				var ixc = ixx + _its / 2;
				var iyc = iyy + _its / 2;
				
				var _submenu = _gro[j];
				var _sprs = _submenu[0];
				var _spr  = noone;
				var _ind  = 0;
				
				var _tlp  = array_safe_get_fast(_submenu, 2, "");
				var _dat  = array_safe_get_fast(_submenu, 3, {});
				var _clr  = c_white;
				
				var _sw = _menuItem.spacing;
				var _sh = _menuItem.spacing;
				
				if(is_array(_sprs)) {
					_spr = _sprs[0];
					_ind = _sprs[1];
					_clr = array_safe_get_fast(_sprs, 2, c_white);
				} else _spr = _sprs;
				
				var hovRec = point_in_rectangle(mouse_mx, mouse_my, ixc - _sw/2, iyc - _sh/2, ixc + _sw/2, iyc + _sh/2);
				if(sHOVER && _hov && !sHov && hovRec) {
					if(_tlp != "") TOOLTIP = _tlp;
					draw_sprite_stretched_ext(THEME.textbox, 3, ixc - _sw/2, iyc - _sh/2, _sw, _sh, COLORS.dialog_menubox_highlight, 1);
					draw_sprite_stretched_ext(THEME.textbox, 2, ixc - _sw/2, iyc - _sh/2, _sw, _sh, COLORS.dialog_menubox_highlight, 1);
					if(mouse_sel) {
						onActivate();
						_submenu[1](_dat);
					}
				}
				
				if(_spr != noone) draw_sprite_ui_uniform(_spr, _ind, ixc, iyc, 1, _clr);
			}
			
		} else if(is(_menuItem, MenuWidget)) {
			var _txt = _menuItem.name;
			var _edt = _menuItem.editWidget;
			var _par = _menuItem.param;
			var _val = _menuItem.getter(_par);
			
			widg = true;
			
			draw_set_text(f_p4, fa_center, fa_top, _hov && !sHov? COLORS._main_text_accent : COLORS._main_text);
			draw_text(_bx0 + _spw / 2, _by0 + ui(2), _txt);
			
			var _wx = _bx0 + ui(4);
			var _wy = _by0 + ui(2 + 16);
			var _ww = _spw - ui(8);
			var _wh = _sph - ui(4 + 2 + 16);
			
			var _param = new widgetParam(_wx, _wy, _ww, _wh, _val).setFont(f_p3);
			_edt.setFocusHover(true, true);
			_edt.drawParam(_param);
			
			if((is(_edt, scrollBox) || is(_edt, scrollBoxFn)) && _edt.open) selectable = false;
			
			if(_edt == WIDGET_CURRENT) itemSelecting = i;
			if(_hov) mouse_rel = false;
		}
		
		draw_sprite_stretched(THEME.dialog_menu, 1, _bx0, _by0, _spw, _sph);
	}
	
	gpu_set_scissor(scis);
	
	if(edit) {
		instance_destroy(_p_dialog);
		onActivate();
		menuItemEdit(menu_id, true);
		deactivate();
	}
	
	if(widg && KEYBOARD_BLOCK && WIDGET_CURRENT == undefined && keyboard_check_released(vk_anykey)) {
		KEYBOARD_BLOCK          = false;
		KEYBOARD_PRESSED_STRING = "";
		KEYBOARD_STRING         = "";
		keyboard_string         = "";
	}
	
	if(mouse_rel) deactivate();
	
	if(deactivate_key != undefined) {
		if(deactivate_keyable && keyboard_check_pressed(deactivate_key) && WIDGET_CURRENT == undefined)
			deactivate();
			
		if(!deactivate_keyable && keyboard_check_released(deactivate_key))
			deactivate_keyable = true;
	}
#endregion 