function Panel_Timer() : PanelContent() constructor {
	title    = "Stopwatch";
	auto_pin = true;
	w = ui(320);
	h = ui(160);
	
	stopwatch_stat = 0;
	stopwatch_time = 0;
	
	function drawContent(panel) {
		switch(stopwatch_stat) {
			case 1 : stopwatch_time += delta_time;                 break;
			case 2 : stopwatch_time  = PROJECT.animator.real_time; break;
		}
		
		var raw_sec = stopwatch_time / 1_000_000;
		var curr_hr = floor(raw_sec / 3600); raw_sec -= curr_hr * 3600;
		var curr_mn = floor(raw_sec /   60); raw_sec -= curr_mn *   60;
		var curr_sc = floor(raw_sec);        raw_sec -= curr_sc;
		var curr_ml = floor(raw_sec * 1000);
		
		var s_hr = string_lead_zero(curr_hr, 2);
		var s_mn = string_lead_zero(curr_mn, 2);
		var s_sc = string_lead_zero(curr_sc, 2);
		var s_ml = string_lead_zero(curr_ml, 3);
		
		var cx = w / 2;
		var cy = h / 2;
		
		draw_set_text(f_sdf, fa_center, fa_bottom, c_white);
		draw_text_add(cx, cy - ui(8), $"{s_hr}:{s_mn}:{s_sc}.{s_ml}", .75);
		
		var m  = [mx,my];
		
		var ss = THEME.button_def;
		var bs = ui(40);
		var bx = cx;
		var by = cy + ui(24);
		var ii = !stopwatch_stat;
		var c  = COLORS._main_icon_light;
		if(buttonInstant(ss, bx-bs/2, by-bs/2, bs, bs, m, pHOVER, pFOCUS, "", THEME.sequence_control, ii, c) == 2)
			stopwatch_stat = !stopwatch_stat;
		
		var ss = THEME.button_hide;
		var c  = COLORS._main_icon;
		var bs = ui(32);
		var bx = cx + ui(48);
		var by = cy + ui(24);
		if(buttonInstant_Pad(ss, bx-bs/2, by-bs/2, bs, bs, m, pHOVER, pFOCUS, "", THEME.sequence_control, 4, c, 1, ui(6)) == 2) {
			stopwatch_stat = 0;
			stopwatch_time = 0;
		}
		
		var ss = THEME.button_hide;
		var c  = stopwatch_stat == 2? COLORS._main_icon_light : COLORS._main_icon;
		var bs = ui(32);
		var bx = cx - ui(48);
		var by = cy + ui(24);
		if(buttonInstant_Pad(ss, bx-bs/2, by-bs/2, bs, bs, m, pHOVER, pFOCUS, "", THEME.play_all, 0, c, 1, ui(6)) == 2)
			stopwatch_stat = stopwatch_stat == 2? 0 : 2;
		
		
	}
}