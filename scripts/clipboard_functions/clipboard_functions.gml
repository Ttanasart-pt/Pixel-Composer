function clipboard_set_surface(surf) {
	if(!is_surface(surf)) return;
	var sw = surface_get_width_safe(surf);
	var sh = surface_get_height_safe(surf);
	
	var b = buffer_create(sw * sh * 4, buffer_fixed, 1);
    var s = surface_create(sw, sh);
    
    surface_set_shader(s, sh_BGR, true, BLEND.over);
        draw_surface_safe(surf);
    surface_reset_shader();
    
    buffer_get_surface(b, s, 0);
    surface_free(s);
    
    clipboard_set_bitmap(buffer_get_address(b), sw, sh);
}

function clipboard_get_surface() {
	var hw = window_handle();
	var s  = clipboard_get_bitmap_size(hw);
	if(s <= 0) return noone; 
	
	var w = clipboard_get_bitmap_width(hw);
	var h = s / w / 4;
	var b = buffer_create(s, buffer_fixed, 1);
	var t = clipboard_get_bitmap(hw, buffer_get_address(b));
	
	var s = surface_create(w, h);
	buffer_set_surface(b, s, 0);
	
	var s1 = surface_create(w, h);
    surface_set_shader(s1, sh_BGR, true, BLEND.over);
        draw_surface_safe(s);
    surface_reset_shader();
    
    surface_free(s);
    buffer_get_surface(b, s1, 0);
    
	return { buffer:b, surface:s1, w, h };
}

function clipboard_get_file() {
	var f = clipboard_get_file(window_handle());
	return f;
}