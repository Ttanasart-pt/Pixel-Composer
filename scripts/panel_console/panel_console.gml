function Panel_Console() : PanelContent() constructor {
	title = __txtx("panel_debug_console", "Debug Console");
	w = ui(640);
	h = ui(320);
	
	command = "";
	history = [];
	cmd_history = [];
	
	cmd_index = 0;
	
	keyboard_string = "";
	
	static submit_command = function() {
		if(command == "") return;
		array_push(history, { txt: command, color: COLORS._main_text_sub });
		array_push(cmd_history, command);
		
		var cmd = string_splice(command, " ");
		
		switch(cmd[0]) {
			case "flag": 
				if(array_length(cmd) < 2) break;
				var flg = array_safe_get(cmd, 1, "");
				global.FLAG[$ flg] = !global.FLAG[$ flg];
				
				array_push(history, { txt: $"Toggled debug flag: {flg} = {global.FLAG[$ flg]? "True" : "False"}", color: COLORS._main_value_positive });
				break;
		}
		
		keyboard_string = "";
		command = "";
	}
	
	function drawContent(panel) {
		HOTKEY_BLOCK = true;
		command = keyboard_string;
		
		draw_clear_alpha(CDEF.main_dkblack, 1);
		
		draw_set_color(c_black);
		draw_set_alpha(0.75);
		draw_rectangle(0, h - ui(28), w, h, false);
		draw_set_alpha(1);
		
		draw_set_text(f_code, fa_left, fa_bottom, COLORS._main_text);
		draw_text(ui(8), h - ui(4), command);
		draw_set_color(COLORS._main_text_sub);
		draw_text(ui(8) + string_width(command), h - ui(4), "_");
		
		var hy = h - ui(32);
		for( var i = 0, n = array_length(history); i < n; i++ ) {
			var his = history[array_length(history) - i - 1];
			var txt = his.txt;
			
			draw_set_color(his.color);
			draw_text_line(ui(8), hy, txt, -1, w - ui(16));
			hy -= string_height_ext(txt, -1, w - ui(16));
			
			if(hy <= 0) break;
		}
			
		if(keyboard_check_pressed(vk_enter)) 
			submit_command();
		
		if(keyboard_check_pressed(vk_up)) {
			cmd_index = max(0, cmd_index - 1); 
			keyboard_string = array_safe_get(cmd_history, cmd_index, "");
			command = keyboard_string;
		} else if(keyboard_check_pressed(vk_anykey)) 
			cmd_index = array_length(cmd_history);
	}
}