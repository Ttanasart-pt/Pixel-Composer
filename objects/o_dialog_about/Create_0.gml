/// @description init
event_inherited();

#region data
	dialog_w = ui(500);
	dialog_h = ui(600);
	
	destroy_on_click_out = true;
#endregion

#region scroll
	credits = [
		[ "ImageMagick", "ImageMagick Studio LLC" ],
		[ "WebP", "Google" ],
		[ "FFmpeg", "FFmpeg team" ],
		[ "BMP Importer", "Samuel Venable" ],
		[ "GIF Importer\nWindow Commands\nApollow LUA Compiler", "YellowAfterLife" ],
		
		[ "The Book of Shaders", "Patricio Gonzalez Vivo & Jen Lowe" ],
		[ "Many noise and shape shaders", "Inigo Quilez" ],
		[ "Chromatic aberration shader", "jcant0n" ],
		[ "Triangle grid", "Farini" ],
		[ "Pixel sort", "Ciphrd" ],
		[ "Simplex noise", "Ian McEwan" ],
		[ "BBMOD", "BlueBurn" ],
	];
	
	patreons = "";
	
	if(os_is_network_connected())
		patron_list_id = http_get("https://gist.githubusercontent.com/Ttanasart-pt/573ab1dea80606616cac5ba497e528fd/raw/patreon");
	
	sc_thank = new scrollPane(1, 1, function(_y, _m) {
		var cx = sc_thank.surface_w / 2;
		var _h = _y;
		var yy = _y;
		draw_clear_alpha(COLORS.dialog_about_bg, 0);
		
		BLEND_OVERRIDE
		draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
		draw_text(cx, yy, "Special Thanks");
		
		for( var i = 0, n = array_length(credits); i < n; i++ ) {
			yy += line_get_height(, 8); 
			draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
			draw_text(cx, yy, credits[i][0]);
			
			yy += string_height(credits[i][0]); 
			draw_set_text(f_p0b, fa_center, fa_top, COLORS._main_text);
			draw_text(cx, yy, credits[i][1]);
			
			yy += ui(8);
		}
		
		yy += ui(40); 
		
		if(patreons != "") {
			draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
			draw_text(cx, yy, "Patreon Suporters");
			yy += line_get_height();
			
			draw_set_text(f_p0b, fa_center, fa_top, COLORS._main_text);
			draw_text_ext(cx, yy, patreons, -1, sc_thank.surface_w);
			yy += string_height_ext(patreons, -1, sc_thank.surface_w);
			
			yy += ui(8);
		}
		
		yy += ui(40); 
		draw_set_text(f_p0b, fa_center, fa_top, COLORS._main_text_sub);
		draw_text_line(cx, yy, "Made with GameMaker Studio 2, Affinity Designer", -1, sc_thank.w - ui(16));
		yy += ui(32);
		BLEND_NORMAL
		
		return yy - _h + ui(32);
	})
#endregion