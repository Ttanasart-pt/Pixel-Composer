/// @description init
event_inherited();

#region data
	dialog_w = ui(500);
	dialog_h = ui(600);
	
	thank_h = dialog_h - ui(220);
	destroy_on_click_out = true;
#endregion

#region scroll
	credits = [
		[ "The Book of Shaders", "Patricio Gonzalez Vivo & Jen Lowe" ],
		[ "Many noise and shape shaders", "Inigo Quilez" ],
		[ "Chromatic aberration shader", "jcant0n" ],
		[ "gif importer\nWindow commands\nExecute shell simple", "YellowAfterLife" ],
		[ "Triangle grid", "Farini" ],
		[ "Pixel sort", "Ciphrd" ],
	]
	
	sc_thank = new scrollPane(dialog_w - ui(64), thank_h, function(_y, _m) {
		var cx = (dialog_w - ui(64)) / 2;
		var _h = _y;
		var yy = _y;
		draw_clear_alpha(COLORS.dialog_about_bg, 0);
		
		BLEND_ADD
		draw_set_font(f_p2);
		draw_set_color(COLORS._main_text_sub);
		draw_text(cx, yy, "Special Thanks");
		
		for( var i = 0; i < array_length(credits); i++ ) {
			yy += line_height(, 8); 
			draw_set_font(f_p2);
			draw_set_color(COLORS._main_text_sub);
			draw_text(cx, yy, credits[i][0]);
			
			yy += string_height(credits[i][0]); 
			draw_set_font(f_p0b);
			draw_set_color(COLORS._main_text);
			draw_text(cx, yy, credits[i][1]);
			
			yy += ui(8);
		}
		
		draw_set_font(f_p0);
		draw_set_color(COLORS._main_text_sub);
		yy += ui(40); 
		draw_text_ext(cx, yy, "Made with GameMaker Studio 2, Abode Illustrator, Aseprite", -1, sc_thank.w - ui(16));
		yy += ui(32);
		BLEND_NORMAL
		
		return yy - _h + ui(32);
	})
#endregion