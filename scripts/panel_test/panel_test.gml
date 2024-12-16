globalvar ASSERTING, ASSERT_LOG, ASSERT_AMOUNT, ASSERT_PASSED;
ASSERTING     = false;
ASSERT_LOG    = [];
ASSERT_AMOUNT = 0;
ASSERT_PASSED = 0;

function Panel_Test() : PanelContent() constructor {
	w = ui(960);
	h = ui(480);
	
	title       = "Tester";
	auto_pin    = true;
	padding     = ui(4);
	content_w   = ui(320);
	
	test_dir    = "";
	tb_test_dir = new textBox(TEXTBOX_INPUT.text,   function(txt) /*=>*/ { setTestDir(txt);   });
	tb_index    = new textBox(TEXTBOX_INPUT.number, function(txt) /*=>*/ { start_index = txt; });
	tb_amount   = new textBox(TEXTBOX_INPUT.number, function(txt) /*=>*/ { test_amount = txt; });
	
	testing     = false;
	test_files  = [];
	start_index = 0;
	end_index   = 0;
	test_amount = 100;
	test_index  = start_index;
	test_step   = 0;
	test_result = [];
	
	test_result_total = {
		projects:       0,
		project_pass:   0, 
		
		assertion:      0,
		assertion_pass: 0,
	}
	
	wait_step   = 5;
	waiting     = 0;
	
	load_param  = new __loadParams(true);
	
	function onResize() { sc_content.resize(content_w, h - padding * 2 - ui(8 * 2) - ui(24)); }
	
	sc_content = new scrollPane(content_w, h - padding * 2 - ui(8 * 2) - ui(24), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _h = 0;
		var yy = _y;
		var ww = sc_content.surface_w;
		var wh = ui(20);
		
		for( var i = 0, n = array_length(test_files); i < n; i++ ) {
			var _f = test_files[i];
			var _d = test_files[i][1];
			var _n = filename_name_only(_f[0]);
			
			var cc = COLORS._main_text_sub;
			if(start_index <= i && i < start_index + test_amount)
				cc = COLORS._main_text;
			
			var _hover = sc_content.hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + wh - 1);
			if(_hover) {
				draw_sprite_stretched_ext(THEME.s_box_r2_clr, 0, 0, yy, ww, wh, c_white, 1);
				if(mouse_press(mb_left, pFOCUS))
					LOAD_AT(_f[0]);
			}
			
			if(testing && i == test_index) {
				cc = COLORS._main_accent;
				draw_sprite_stretched_ext(THEME.s_box_r2, 0, 0, yy, ww * test_step / 4, wh, cc, 0.1);
				
				sc_content.scroll_y_to = -_h + sc_content.surface_h / 2;
				
			} else {
				var _res = array_safe_get(test_result, i);
				if(is_array(_res)) {
					var _a_amo = _res[0];
					var _a_pas = _res[1];
					var c = _a_pas == _a_amo? COLORS._main_value_positive : COLORS._main_value_negative;
					cc = merge_color(c, c_white, 0.5); 
					
					if(_a_amo == 0) draw_sprite_stretched_ext(THEME.s_box_r2, 0, 0, yy, ww, wh, c, 0.1);
					else            draw_sprite_stretched_ext(THEME.s_box_r2, 0, 0, yy, ww * _a_pas / _a_amo, wh, c, 0.1);
					
					draw_set_text(f_p3, fa_right, fa_center, cc);
					draw_text_add(ww - ui(8), yy + wh / 2, $"{_a_pas} / {_a_amo}");
					
				}
			}
			
			draw_set_text(f_p3, fa_left, fa_center, cc);
			draw_text_add(ui(8), yy + wh / 2, _n);
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub, 0.5);
			draw_text_add(ww - ui(100), yy + wh / 2, _d);
			draw_set_alpha(1);
			
			_h += wh;
			yy += wh;
		}
		
		_h += wh;
		
		return _h;
	});
	
	sc_log = new scrollPane(content_w, h - padding * 2 - ui(8 * 2), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var _h   = 0;
		var yy   = _y;
		var ww = sc_log.surface_w - ui(32);
		
		for( var i = 0, n = array_length(ASSERT_LOG); i < n; i++ ) {
			var _f = ASSERT_LOG[i];
			
			if(_f.type == 0) {
				if(i >= n - 1) continue;
				if(ASSERT_LOG[i + 1].type >= 0) continue;
					
				if(i) {
					_h += ui(4);
					yy += ui(4);
				}
			}
			
			draw_set_font(f_p3);
			var wh = string_height_ext(_f.text, -1, ww);
			var cc = COLORS._main_text_sub;
			var tx = ui(8);
			var hv = sc_log.hover && point_in_rectangle(_m[0], _m[1], 0, yy, sc_log.surface_w, yy + wh - 1);
			
			if(hv) draw_sprite_stretched_ext(THEME.s_box_r2_clr, 0, 0, yy, sc_log.surface_w, wh, c_white, 1);
						
			switch(_f.type) {
				case -1 : 
					cc = merge_color(COLORS._main_value_negative, c_white, 0.5); 
					tx = ui(16);
					
					if(hv && _f.tooltip != -1) TOOLTIP = _f.tooltip;
					break;
					
				case  0 : 
					cc = COLORS._main_text_sub;       
					tx = ui(8);
					
					if(hv && mouse_press(mb_left, pFOCUS))
						LOAD_AT(_f.file);
					break;
					
				case  1 : 
					cc = merge_color(COLORS._main_value_positive, c_white, 0.5); 
					tx = ui(16);
					break;
					
			}
			
			draw_set_text(f_p3, fa_left, fa_top, cc);
			draw_text_ext_add(tx, yy, _f.text, -1, ww);
			
			_h += wh + ui(0);
			yy += wh + ui(0);
		}
		
		_h += ui(16);
		
		return _h;
	});
	
	function setTestDir(dir) {
		test_dir   = dir;
		test_files = [];
		
		scanDir(test_dir);
	}
	
	function scanDir(dir) {
		if(!directory_exists(dir)) return;
		
		var f = file_find_first($"{dir}/*", fa_none);
		var v = filename_name(dir);
		
		while(f != "") {
			var path = $"{dir}/{f}";
			f = file_find_next();
			
			if(filename_ext_raw(path) == "pxc") 
				array_push(test_files, [ path, v ]);
		}
		
		file_find_close();
		
		var f = file_find_first($"{dir}/*", fa_directory);
		var _dir = [];
		
		while(f != "") {
			var path = $"{dir}/{f}";
			f = file_find_next();
			
			array_push(_dir, path);
		}
		
		file_find_close();
		
		for( var i = 0, n = array_length(_dir); i < n; i++ )
			scanDir(_dir[i]);
	}
	
	function startTesting() {
		if(testing) return;
		
		end_index   = min(start_index + test_amount, array_length(test_files));
		testing     = true;
		test_index  = start_index;
		test_result = array_create(array_length(test_files));
		
		ASSERT_LOG = [];
		TEST_ERROR = true;
		
		test_result_total.projects       = 0;
		test_result_total.project_pass   = 0;
		
		test_result_total.assertion      = 0;
		test_result_total.assertion_pass = 0;
	
		__start_time = get_timer();
	}
	
	function doTesting() {
		var _cur = test_files[test_index][0];
		
		try {
			switch(test_step) {
				case 0 :
					array_append(ASSERT_LOG, {
						type: 0,
						text: $"Testing {filename_name_only(_cur)}",
						file: _cur,
					});
					
					test_result_total.projects++;
					test_step++;
					break;
				
				case 1 :
					LOAD_AT(_cur, load_param);
					test_step++;
					waiting = 0;
					break;
					
				case 2 : 
					if(waiting++ > wait_step) test_step++;
					break;
				
				case 3 : 
					if(!instance_exists(project_loader)) {
						ASSERTING = true;
						Render();
						ASSERTING = false;
						test_step++;
					}
					break;
					
				case 4 : 
					closeProject(PROJECT);
					test_result[test_index] = [ ASSERT_AMOUNT, ASSERT_PASSED ];
					
					test_result_total.assertion      += ASSERT_AMOUNT;
					test_result_total.assertion_pass += ASSERT_PASSED;

					if(ASSERT_AMOUNT == ASSERT_PASSED) test_result_total.project_pass++;
					
					ASSERT_AMOUNT = 0;
					ASSERT_PASSED = 0;
					test_step++;
					break;
			}
			
		} catch(e) {
			array_append(ASSERT_LOG, {
				type: -1,
				text: $"Test failed: {e}",
			});
		}
		
		if(test_step < 5) return;
		
		test_step = 0;
		test_index++;
		
		if(test_index < end_index) return;
		
		testing    = false;
		TEST_ERROR = false;
		var ts = test_result_total;
		
		var _time  = (get_timer() - __start_time) / 1000;
		var _summ  = $"Testing completed in {_time}ms. ";
		    _summ += $"\n{ts.project_pass}/{ts.projects} projects passed [{ts.project_pass / ts.projects * 100}%].";
		    _summ += $"\n{ts.assertion_pass}/{ts.assertion} assertions passed [{ts.assertion == 0? "-" : ts.assertion_pass / ts.assertion * 100}%].";
		
		array_append(ASSERT_LOG, {
			type: 1,
			text: _summ,
		});
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		// Lists
		
		var _pd = padding;
		var ndx = _pd;
		var ndy = _pd + ui(24);
		var ndw = content_w + ui(16);
		var ndh = h - _pd * 2 - ui(24);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_add(ndx + ui(8), ui(4), $"{test_amount} / {array_length(test_files)} Files");
		
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.draw(ndx + ui(8), ndy + ui(8), mx - ndx - ui(8), my - ndy - ui(8));
		
		// Data
		
		var yy = ui(8);
		var lx = ndx + ndw + ui(8);
		var lw = ui(100);
		var dw = w - lx - lw - _pd;
		var hh = TEXTBOX_HEIGHT;
		
		tb_test_dir.setFocusHover(pFOCUS, pHOVER);
		tb_index.setFocusHover(pFOCUS, pHOVER);
		tb_amount.setFocusHover(pFOCUS, pHOVER);
		
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(lx + ui(8), yy + hh / 2, "Directory");
		
		tb_test_dir.draw(lx + lw, yy, dw, hh, test_dir, [ mx, my ]);
		yy += hh + ui(8);
		
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(lx + ui(8), yy + hh / 2, "Start");
		
		tb_index.draw(lx + lw, yy, dw, hh, start_index, [ mx, my ]);
		yy += hh + ui(8);
		
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(lx + ui(8), yy + hh / 2, "Amount");
		
		tb_amount.draw(lx + lw, yy, dw, hh, test_amount, [ mx, my ]);
		yy += hh + ui(8);
		
		// Log
		
		var ndx = lx;
		var ndy = yy;
		var ndw = w - _pd - lx;
		var ndh = h - _pd - ndy - hh - ui(8);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		var log_w = ndw - ui(16);
		var log_h = ndh - ui(16);
		
		if(sc_log.w != log_w || sc_log.h != log_h) sc_log.resize(log_w, log_h);
		
		sc_log.setFocusHover(pFOCUS, pHOVER);
		sc_log.draw(ndx + ui(8), ndy + ui(8), mx - ndx - ui(8), my - ndy - ui(8));
		
		// Button
		
		var bw = w - _pd - lx;
		var bh = hh;
		var bx = lx;
		var by = h - _pd - bh;
		
		if(testing) {
			var _a = end_index - start_index;
			var _w = bw * (test_index - start_index) / _a;
			draw_sprite_stretched(THEME.progress_bar, 0, bx, by, bw, bh);
			draw_sprite_stretched(THEME.progress_bar, 1, bx, by, _w, bh);
			
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(bx + bw / 2, by + bh / 2, $"Testing {test_index - start_index}/{_a}");
			
			doTesting();
			
		} else {
			if(buttonInstant(THEME.button_def, bx, by, bw, bh, [ mx, my ], pHOVER, pFOCUS) == 2)
				startTesting();
				
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
			draw_text_add(bx + bw / 2, by + bh / 2, "Start test");
		}
	}
	
	setTestDir("D:/Project/MakhamDev/LTS-PixelComposer/TEST/Tester");
}