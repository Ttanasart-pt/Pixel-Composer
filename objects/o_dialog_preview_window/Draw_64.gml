/// @description init
if !ready exit;
if(node_target == noone) {
	instance_destroy()
	exit;
}

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(padding);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(padding + padding);
	
	surfaceCheck();
	
	surface_set_target(content_surface);
		draw_clear_alpha(c_black, 0);
		draw_sprite_tiled(s_transparent, 0, 0, 0);
		
		var surf = node_target.outputs[| preview_channel].getValue();
		if(is_array(surf))
			surf = array_spread(surf);
		else 
			surf = [ surf ];
		
		var dx  = 0;
		var dy  = 0;
		var ind = 0;
		var col = round(sqrt(array_length(surf)));
		
		for( var i = 0; i < array_length(surf); i++ ) {
			var s  = surf[i];
			var sw = surface_get_width(s);
			var sh = surface_get_height(s);
			if(scale == 0)
				scale = min(pw / sw, ph / sh);
			var sx = dx + pw / 2 - (sw * scale) / 2 + panx;
			var sy = dy + ph / 2 - (sh * scale) / 2 + pany;
		
			draw_surface_ext_safe(s, sx, sy, scale, scale, 0, c_white, 1);
			draw_set_color(COLORS._main_icon);
			draw_rectangle(sx, sy, sx + sw * scale, sy + sh * scale, true);
			
			if(++ind >= col) {
				ind = 0;
				dx  = 0;
				dy += (sh + 2) * scale;
			} else
				dx += (sw + 2) * scale;
		}
	surface_reset_target();
	draw_surface_safe(content_surface, px, py);
	
	if(panning) {
		panx = pan_sx + (mouse_mx - pan_mx);
		pany = pan_sy + (mouse_my - pan_my);
		
		if(mouse_release(mb_middle)) 
			panning = false;
	}
	
	if(mouse_press(mb_middle, sFOCUS)) {
		panning = true;
		pan_mx = mouse_mx;
		pan_my = mouse_my;
		pan_sx = panx;
		pan_sy = pany;
	}
	
	if(sHOVER) {
		var inc = 0.5;
		if(scale > 16)		inc = 2;
		else if(scale > 8)	inc = 1;
		
		var s = scale;
		if(mouse_wheel_down()) scale = max(round(scale / inc) * inc - inc, 0.25);
		if(mouse_wheel_up())   scale = min(round(scale / inc) * inc + inc, 32);
		
		var ds = scale - s;
		panx = panx / s * scale;
		pany = pany / s * scale;
	}
	
	title_show = lerp_float(title_show, sHOVER || sFOCUS, 3);
	
	draw_sprite_stretched_ext(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, title_height, c_white, title_show);
	
	draw_set_alpha(0.5 + title_show * 0.5);
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(padding + 8), dialog_y + ui(title_height) / 2, node_target.getFullName());
	draw_set_alpha(1);
	
	var bw = ui(24);
	var bh = ui(24);
	var bx = dialog_x + dialog_w - ui(4) - bw;
	var by = dialog_y + ui(4);
	if(buttonInstant(THEME.button_hide_fill, bx, by, bw, bh, mouse_ui, sFOCUS, sHOVER,, THEME.window_exit, 0, COLORS._main_accent) == 2)
		instance_destroy();
	
	if(mouse_click(mb_right, sFOCUS)) {
		var _menu = array_clone(menu);
		for( var i = 0; i < ds_list_size(node_target.outputs); i++ ) {
			var o = node_target.outputs[| i];
			if(o.type != VALUE_TYPE.surface) continue;
			
			array_push(_menu, menuItem(o.name, function(_dat) { changeChannel(_dat.index); }));
		}
		menuCall("preview_window_menu",,, _menu);
	}
#endregion

if(sFOCUS)
	draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);