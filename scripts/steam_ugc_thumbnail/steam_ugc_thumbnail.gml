enum UGC_TYPE {
	collection,
	project,
	patreon
}

function steam_ugc_generate_thumbnail(_data, _type, _dest_path = TEMPDIR + "steamUGCthumbnail.png") {
	file_delete_safe(_dest_path);
	
	var prev_size = 512;
	var avar_size = 80;
	
	var _surface  = _data;
	var _clear    = false;
	var spr       = noone;
	
	if(is_string(_data)) {
		var spr = sprite_add(_data, 0, false, false, 0, 0);
		var _sw = sprite_get_width(spr);
		var _sh = sprite_get_height(spr);
		_surface = surface_create(_sw, _sh);
		
		surface_set_shader(_surface);
			if(spr) draw_sprite(spr, 0, 0, 0);
		surface_reset_shader();
		
		_clear = true;
	}
	
	var _s        = surface_create(prev_size, prev_size);
	var avartar   = surface_create(avar_size, avar_size);
	var _surfUse  = surface_exists(_surface);
	var _avarUse  = STEAM_UGC_ITEM_AVATAR && sprite_exists(STEAM_AVATAR);
	var _ico      = undefined;
	var _padd     = _type == UGC_TYPE.patreon? 32 : 80;
	if(!_surfUse && spr == noone) return;
	
	switch(_type) {
		case UGC_TYPE.project :    _ico = THEME.workshop_project;    break;
		case UGC_TYPE.collection : _ico = THEME.workshop_collection; break;
		case UGC_TYPE.patreon :    _ico = THEME.workshop_patreon; _avarUse = false; break;
	}
	
	if(_avarUse) {
		var spw = sprite_get_width(STEAM_AVATAR);
		var sph = sprite_get_height(STEAM_AVATAR);
		var ss  = avar_size / max(spw, sph);
		
	    surface_set_target(avartar);
	    	DRAW_CLEAR
	    	
	    	var avw = spw * ss;
	    	var avh = sph * ss;
	    	var avx = avar_size / 2 - avw / 2;
	    	var avy = avar_size / 2 - avh / 2;
	    	
	    	BLEND_NORMAL
	    		draw_sprite_ext(STEAM_AVATAR, 0, avx, avy, ss, ss, 0, c_white, 1);
	    	BLEND_MULTIPLY
	    		draw_sprite_stretched(THEME.ui_panel, 0, avx, avy, avw, avh);
	    	BLEND_NORMAL
	    	
	    	draw_sprite_stretched_add(THEME.ui_panel, 1, avx, avy, avw, avh, c_white, 0.3);
	    	
	    surface_reset_target();
	}
	
	surface_set_target(_s);
		draw_clear(COLORS._main_icon_dark);
		draw_sprite_tiled(s_workshop_bg, 0, -64, -64);
		
		if(_surfUse) {
			var sw = surface_get_width(_surface);
			var sh = surface_get_height(_surface);
			var ss = (prev_size - _padd * 2) / max(sw, sh);
			draw_surface_ext(_surface, prev_size / 2 - sw / 2 * ss, prev_size / 2 - sh / 2 * ss, ss, ss, 0, c_white, 1);
			
		} else {
			var ss  = (prev_size - _padd * 2) / max(sprite_get_width(spr), sprite_get_height(spr));
			gpu_set_tex_filter(true);
			draw_sprite_ext(_ico, 0, prev_size / 2, prev_size / 2, ss, ss, 0, c_white, 1);
			gpu_set_tex_filter(false);
			
		}
		
		draw_sprite_stretched_ext(s_workshop_frame,  0, 0, 0, prev_size, prev_size, COLORS._main_accent);
		draw_sprite_stretched_ext(s_workshop_badge,  0, 8, 8, 88, 88, COLORS._main_accent);
		draw_sprite_ext(_ico, 0, 40, 40, 1 / THEME_SCALE, 1 / THEME_SCALE, 0, COLORS._main_icon_dark, 1);
		
		draw_set_text(f_h2, fa_right, fa_bottom, COLORS._main_icon_dark);
		var _vstr = VERSION_STRING;
		if(NIGHTLY) _vstr = string_copy(_vstr, 1, string_length(_vstr) - 4);
		
		var _bw = 48 + string_width(_vstr) / UI_SCALE;
		var _bh = 22 + string_height(_vstr) / UI_SCALE;
		draw_sprite_stretched_ext(s_workshop_badge_version, 0, prev_size - 8 - _bw, prev_size - 8 - _bh, _bw, _bh, COLORS._main_accent);
		
		gpu_set_tex_filter(true);
		draw_text_transformed(prev_size - 16, prev_size - 8, _vstr, 1 / UI_SCALE, 1 / UI_SCALE, 0);
		gpu_set_tex_filter(false);
		
		if(_avarUse) draw_surface(avartar, prev_size - 24 - avar_size, 24);
	surface_reset_target();
	
	if(_type == UGC_TYPE.patreon) {
		var _scal = surface_create(prev_size/2, prev_size/2);
		surface_set_shader(_scal);
			draw_surface_stretched(_s, 0, 0, prev_size/2, prev_size/2);
		surface_reset_shader();
		
		surface_save_safe(_scal, _dest_path);
		surface_free(_scal);
		
	} else 
		surface_save_safe(_s, _dest_path);
	
	surface_free(_s);
	surface_free(avartar);
	if(_clear) surface_free(_surface);
	
	return _dest_path;
}