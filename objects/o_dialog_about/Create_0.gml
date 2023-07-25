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
		[ "ImageMagick", "ImageMagick Studio LLC" ],
		[ "File dialog module", "Samuel Venable" ],
		[ "gif importer\nWindow commands\nApollow LUA compiler", "YellowAfterLife" ],
		
		[ "The Book of Shaders", "Patricio Gonzalez Vivo & Jen Lowe" ],
		[ "Many noise and shape shaders", "Inigo Quilez" ],
		[ "Chromatic aberration shader", "jcant0n" ],
		[ "Triangle grid", "Farini" ],
		[ "Pixel sort", "Ciphrd" ],
		[ "Simplex noise", "Ian McEwan" ],
		
		[ "Additional help", "ChatGPT by OpenAI" ],
	]
	
	sc_thank = new scrollPane(dialog_w - ui(64), thank_h, function(_y, _m) {
		var cx = sc_thank.surface_w / 2;
		var _h = _y;
		var yy = _y;
		draw_clear_alpha(COLORS.dialog_about_bg, 0);
		
		BLEND_OVERRIDE
		draw_set_font(f_p2);
		draw_set_color(COLORS._main_text_sub);
		draw_text(cx, yy, "Special Thanks");
		
		for( var i = 0, n = array_length(credits); i < n; i++ ) {
			yy += line_get_height(, 8); 
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
		draw_text_line(cx, yy, "Made with GameMaker Studio 2, Adobe Illustrator, Aseprite", -1, sc_thank.w - ui(16));
		yy += ui(32);
		BLEND_NORMAL
		
		return yy - _h + ui(32);
	})
#endregion