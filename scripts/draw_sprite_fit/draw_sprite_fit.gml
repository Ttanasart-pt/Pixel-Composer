function draw_sprite_fit(spr, ind, xx, yy, w, h) {
	var ss = min(w / sprite_get_width(spr), h / sprite_get_height(spr));
	draw_sprite_ext(spr, ind, xx, yy, w, h, 0, c_white, 1);
}