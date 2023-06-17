function Panel_Test() : PanelContent() constructor {
	w = ui(480);
	h = ui(160);
	title = "Tester";
	
	test_dir = "";
	tb_test_dir = new textBox(TEXTBOX_INPUT.text, function(txt) { test_dir = txt; });
	
	testing = false;
	test_files = [];
	test_index = 0;
	
	function startTesting() {
		if(testing) return;
		
		testing = true;
		test_index = 0;
		
		test_files = [];
		var f = file_find_first(test_dir + "/*", fa_none);
		var _f = "";
	
		while(f != "") {
			var path = test_dir + f;
			if(filename_ext(path) == ".pxc")
				array_push(test_files, path);
			f = file_find_next();
		}
		
		for( var i = 0; i < array_length(test_files); i++ ) {
			run_in(i * 2, function(i) { LOAD_PATH(test_files[i]); test_index = i }, i);
		}
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var yy = 8;
		var hh = TEXTBOX_HEIGHT;
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text(8, yy + hh / 2, "Directory");
		
		tb_test_dir.setActiveFocus(pFOCUS, pHOVER);
		tb_test_dir.draw(128, yy, w - 8 - 128, hh, test_dir, [ mx, my ]);
		yy += hh + 8;
			
		if(testing) {
			draw_sprite_stretched(THEME.progress_bar, 0, 8, yy, w - 16, hh);
			draw_sprite_stretched(THEME.progress_bar, 1, 8, yy, (w - 16) * test_index / array_length(test_files), hh);
			
			if(test_index == array_length(test_files) - 1)
				testing = false;
		} else {
			if(buttonInstant(THEME.button, 8, yy, w - 16, hh, [ mx, my ], pFOCUS, pHOVER) == 2)
				startTesting();
			draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
			draw_text(w / 2, yy + hh / 2, "Start test");
		}
	}
}