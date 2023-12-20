/// @description Insert description here
// You can write your code in this editor

#region anim
	anim_prog = lerp_float(anim_prog, active, 5);
	
	if(anim_prog == 0 && !active) instance_destroy();
#endregion

#region draw
	var rad = anim_prog * pie_rad;
	var amo = array_length(menus);
	var _r  = 360 / amo;
	
	for( var i = 0; i < amo; i++ ) {
		var _menuItem = menus[i];
		var label = _menuItem.name;
		
		var _ba  = i * _r;
		
		var _bx  = x + lengthdir_x(rad, _ba);
		var _by  = y + lengthdir_y(rad, _ba);
		
		var _spr = _menuItem.spr;
		
		draw_set_font(f_p0);
		var _spw = string_width(label) + ui(32) + (_spr != noone) * ui(32);
			_spw = max(8, _spw * anim_prog);
		var _sph = hght;
		
		var _bx0 = _bx - _spw / 2;
		var _by0 = _by - _sph / 2;
		var _bx1 = _bx + _spw / 2;
		var _by1 = _by + _sph / 2;
			
		draw_sprite_stretched(THEME.menu_bg, 0, _bx0, _by0, _spw, _sph);
		
		if(point_in_rectangle(mouse_mx, mouse_my, _bx0, _by0, _bx1, _by1)) {
			draw_sprite_stretched_ext(THEME.textbox, 3, _bx0, _by0, _spw, _sph, COLORS.dialog_menubox_highlight, 0.75);
			if(mouse_release(mb_left)) {
				var _dat = {
					_x: _bx0,
					x:  _bx1,
					y:  _by0,
					depth: depth,
					name: _menuItem.name,
					index: i,
					context: context,
					params: _menuItem.params,
				};
				
				var _res = _menuItem.func(_dat);
			}
		}
		
		if(_spr != noone) {
			var spr = is_array(_spr)? _spr[0] : _spr;
			var ind = is_array(_spr)? _spr[1] : 0;
			var aa  = _menuItem.active * 0.5 + 0.25;
			draw_sprite_ui(spr, ind, _bx0 + ui(24), _by0 + _sph / 2,,,, COLORS._main_icon, aa * anim_prog);
		}
			
		if(_menuItem.toggle != noone) {
			var tog = _menuItem.toggle(_menuItem);
			if(tog) draw_sprite_ui(THEME.icon_toggle, 0, _bx0 + ui(24), _by0 + _sph / 2,,,, COLORS._main_icon);
		}
		
		var tx = _bx0 + ui(16) + (_spr != noone) * ui(32);
		var aa = _menuItem.active * 0.75 + 0.25;
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_set_alpha(aa * anim_prog);
		draw_text(tx, _by0 + _sph / 2, label);
		draw_set_alpha(1);
		
		draw_sprite_stretched(THEME.menu_bg, 1, _bx0, _by0, _spw, _sph);
	}
	
	if(mouse_release(mb_left)) {
		HOVER  = noone;
		FOCUS  = noone;
		active = false;
	}
#endregion 