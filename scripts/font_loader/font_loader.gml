globalvar f_h3, f_h5, f_p0, f_p0b, f_p1, f_p2, f_p3;

function loadFonts() {
	var font = "NotoSans";
	f_h3 = font_add("data/fonts/" + font + "-Bold.ttf", 20 * DISP_SCALE, false, false, 32, 127);
	f_h5 = font_add("data/fonts/" + font + "-Bold.ttf", 16 * DISP_SCALE, false, false, 32, 127);

	f_p0  = font_add("data/fonts/" + font + "-Medium.ttf", 12 * DISP_SCALE, false, false, 32, 127);
	f_p0b = font_add("data/fonts/" + font + "-Bold.ttf",   12 * DISP_SCALE, false, false, 32, 127);

	f_p1 = font_add("data/fonts/" + font + "-Medium.ttf",   11 * DISP_SCALE, false, false, 32, 127);
	f_p2 = font_add("data/fonts/" + font + "-SemiBold.ttf", 10 * DISP_SCALE, false, false, 32, 127);
	f_p3 = font_add("data/fonts/" + font + "-SemiBold.ttf",  9 * DISP_SCALE, false, false, 32, 127);
}