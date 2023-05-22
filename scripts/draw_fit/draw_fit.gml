function draw_sprite_fit(spr, ind, xx, yy, w, h, color = c_white, alpha = 1) {
	var ss = min(w / sprite_get_width(spr), h / sprite_get_height(spr));
	draw_sprite_ext(spr, ind, xx, yy, ss, ss, 0, color, alpha);
}

function draw_surface_fit(surf, xx, yy, w, h, color = c_white, alpha = 1) {
	var ss = min(w / surface_get_width(surf), h / surface_get_height(surf));
	draw_surface_ext_safe(surf, xx - surface_get_width(surf) * ss / 2, yy - surface_get_height(surf) * ss / 2, ss, ss,, color, alpha);
}

function draw_surface_stretch_fit(surf, xx, yy, w, h, sw, sh) {
	var ss = min(w / sw, h / sh);
	draw_surface_stretched_safe(surf, xx - sw * ss / 2, yy - sh * ss / 2, sw * ss, sh * ss);
}

function draw_surface_bbox(surf, bbox, color = c_white, alpha = 1) {
	draw_surface_fit(surf, bbox.xc, bbox.yc, bbox.w, bbox.h, color, alpha);
}