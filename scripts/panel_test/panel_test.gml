function Panel_Test() : PanelContent() constructor {
	w = ui(480);
	h = ui(160);
	title = "Tester";
	
	test_dir = "D:\\Project\\MakhamDev\\LTS-PixelComposer\\TEST";
	tb_test_dir = new textBox(TEXTBOX_INPUT.text,   function(txt) { test_dir = txt; });
	tb_index    = new textBox(TEXTBOX_INPUT.number, function(txt) { start_index = txt; });
	tb_amount   = new textBox(TEXTBOX_INPUT.number, function(txt) { test_amount = txt; });
	
	testing     = false;
	test_files  = [];
	start_index = 0;
	test_amount = 100;
	test_index  = start_index;
	
	test_button_surface = surface_create(1, 1);
	
	function scanDir(dir) {
		var f = file_find_first(dir + "\\*", fa_none);
		while(f != "") {
			var path = dir + "\\" + f;
			if(filename_ext(path) == ".pxc")
				array_push(test_files, path);
			f = file_find_next();
		}
		file_find_close();
		
		var f = file_find_first(dir + "\\*", fa_directory);
		var _dir = [];
		
		while(f != "") {
			var path = dir + "\\" + f;
			array_push(_dir, path);
			f = file_find_next();
		}
		file_find_close();
		
		for( var i = 0, n = array_length(_dir); i < n; i++ )
			scanDir(_dir[i]);
	}
	
	function startTesting() {
		if(testing) return;
		
		testing = true;
		test_index = start_index;
		
		test_files = [];
		scanDir(test_dir);
		
		__start_time = get_timer();
		
		for( var i = start_index, n = min(start_index + test_amount, array_length(test_files)); i < n; i++ ) {
			run_in(1 + (i - start_index) * 3, function(i) { 
				try {
					show_debug_message($"TESTING {i}/{array_length(test_files)}: {test_files[i]}");
					TEST_PATH(test_files[i]);
					test_index = i;
					show_debug_message($"     > Test complete : {(get_timer() - __start_time) / 1_000_000} s");
				} catch(e) {
					show_debug_message($"     > Test failed");
					exception_print(e);
				}
			}, [i]);
		}
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var yy = 8;
		var hh = TEXTBOX_HEIGHT;
		
		tb_test_dir.setFocusHover(pFOCUS, pHOVER);
		tb_index.setFocusHover(pFOCUS, pHOVER);
		tb_amount.setFocusHover(pFOCUS, pHOVER);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text(8, yy + hh / 2, "Directory");
		
		tb_test_dir.draw(128, yy, w - 8 - 128, hh, test_dir, [ mx, my ]);
		yy += hh + 8;
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text(8, yy + hh / 2, "Start");
		
		tb_index.draw(128, yy, w - 8 - 128, hh, start_index, [ mx, my ]);
		yy += hh + 8;
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text(8, yy + hh / 2, "Amount");
		
		tb_amount.draw(128, yy, w - 8 - 128, hh, test_amount, [ mx, my ]);
		yy += hh + 8;
			
		if(testing) {
			var _w = (w - 16) * test_index / array_length(test_files);
			draw_sprite_stretched(THEME.progress_bar, 0, 8, yy, w - 16, hh);
			draw_sprite_stretched(THEME.progress_bar, 1, 8, yy, _w, hh);
			
			draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
			draw_text(w / 2, yy + hh / 2, $"Testing {test_index + 1}/{array_length(test_files)}");
			
			test_button_surface = surface_verify(test_button_surface, w - 16, hh);
			surface_set_target(test_button_surface);
				DRAW_CLEAR
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text_on_accent);
				draw_text((w - 16) / 2, hh / 2, $"Testing {test_index + 1}/{array_length(test_files)}");
			surface_reset_target();
			draw_surface_part(test_button_surface, 0, 0, _w, hh, 8, yy);
			
			if(test_index >= array_length(test_files) - 1)
				testing = false;
		} else {
			if(buttonInstant(THEME.button_def, 8, yy, w - 16, hh, [ mx, my ], pFOCUS, pHOVER) == 2)
				startTesting();
			draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
			draw_text(w / 2, yy + hh / 2, "Start test");
		}
	}
}