globalvar FONT_LOADED, f_h3, f_h5, f_p0, f_p0b, f_p1, f_p2, f_p3;

FONT_LOADED = false;

function loadFonts() {
	if(FONT_LOADED) {
		font_delete(f_h3);
		font_delete(f_h5);
					
		font_delete(f_p0);
		font_delete(f_p0b);
					
		font_delete(f_p1);
		font_delete(f_p2);
		font_delete(f_p3);
	}
	
	var font = "NotoSans";
	f_h3 = font_add("data/fonts/" + font + "-Bold.ttf", 20 * UI_SCALE, false, false, 32, 127);
	f_h5 = font_add("data/fonts/" + font + "-Bold.ttf", 16 * UI_SCALE, false, false, 32, 127);

	f_p0  = font_add("data/fonts/" + font + "-Medium.ttf", 12 * UI_SCALE, false, false, 32, 127);
	f_p0b = font_add("data/fonts/" + font + "-Bold.ttf",   12 * UI_SCALE, false, false, 32, 127);

	f_p1 = font_add("data/fonts/" + font + "-SemiBold.ttf", 11 * UI_SCALE, false, false, 32, 127);
	f_p2 = font_add("data/fonts/" + font + "-SemiBold.ttf", 10 * UI_SCALE, false, false, 32, 127);
	f_p3 = font_add("data/fonts/" + font + "-SemiBold.ttf",  9 * UI_SCALE, false, false, 32, 127);
	
	FONT_LOADED = true;
}