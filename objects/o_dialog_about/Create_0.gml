/// @description init
event_inherited();

#region data
	dialog_w = 500;
	dialog_h = 600;
	
	thank_h = dialog_h - 220;
	destroy_on_click_out = true;
#endregion

#region scroll
	credits = [
		[ "Execute Shell", "Samuel Venable" ],
		[ "The Book of Shaders", "Patricio Gonzalez Vivo & Jen Lowe" ],
		[ "Many noise and shape shaders", "Inigo Quilez" ],
		[ "Chromatic aberration shader", "jcant0n" ],
		[ "gif importer", "YellowAfterLife" ],
	]
	
	sc_thank = new scrollPane(dialog_w - 64, thank_h, function(_y, _m) {
		var cx = (dialog_w - 64) / 2;
		var _h = _y;
		var yy = _y;
		draw_clear_alpha(c_ui_blue_grey, 0);
		
		draw_set_font(f_p2);
		draw_set_color(c_ui_blue_ltgrey);
		draw_text(cx, yy, "Special Thanks");
		
		for( var i = 0; i < array_length(credits); i++ ) {
			draw_set_font(f_p2);
			draw_set_color(c_ui_blue_grey);
			yy += 40; draw_text(cx, yy, credits[i][0]);
			draw_set_font(f_p0);
			draw_set_color(c_ui_blue_ltgrey);
			yy += 16; draw_text(cx, yy, credits[i][1]);
		}
		
		draw_set_font(f_p0);
		draw_set_color(c_ui_blue_ltgrey);
		yy += 40; draw_text(cx, yy, "Made with GameMaker Studio 2");
		
		return yy - _h + 32;
	})
#endregion