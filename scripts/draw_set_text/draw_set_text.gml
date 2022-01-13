function draw_set_text(font, halign, valign) {
	if(argument_count > 3) draw_set_color(argument[3]);
	draw_set_font(font);
	draw_set_halign(halign);
	draw_set_valign(valign);
}