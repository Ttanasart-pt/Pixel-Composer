#region
	#macro cmdLine   new __cmdLine
	#macro cmdLineIn new __cmdLineIn
	
	function __cmdLine(txt, color) constructor {
		self.txt   = txt;
		self.color = color;
	}
	
	function __cmdLineIn(txt, color = COLORS._main_text) : __cmdLine(txt, color) constructor {}
#endregion

function Panel_Console() : PanelContent() constructor {
	title = __txtx("panel_debug_console", "Console");
	w     = ui(640);
	h     = ui(320);
	
	auto_pin  = true;
	command   = "";
	cmd_index = 0;
	
	scroll_y  = 0;
	prevFocus = false;
	
	function drawHistory(_y) { #region
		var _x = ui(32 + 8);
		var _w = w - ui(16 + 32);
		
		draw_set_text(f_code, fa_left, fa_bottom, COLORS._main_text_sub);
		
		for( var i = array_length(CMD) - 1 - scroll_y; i >= 0; i-- ) {
			var his = CMD[i];
			
			if(is_instanceof(his, __cmdLine)) {
				var txt = his.txt;
				draw_set_color(his.color);
				
				if(is_instanceof(his, __cmdLineIn)) {
					draw_sprite_ext(THEME.icon_cmd_enter, 0, _x + ui(8), _y - line_get_height() / 2, 1, 1, 0, his.color, 1);
					draw_text_line(_x + ui(20), _y, txt, -1, _w);
				} else 
					draw_text_line(_x, _y, txt, -1, _w);
				
				_y -= string_height_ext(txt, -1, _w);
			
			} else if(is_instanceof(his, notification)) {
				var txt = his.txt;
				
				draw_set_color(his.txtclr);
				draw_text_line(_x, _y, txt, -1, _w);
				_y -= string_height_ext(txt, -1, _w);
				
			} else {
				draw_set_color(COLORS._main_text_sub);
				draw_text_line(_x, _y, his, -1, _w);
				_y -= string_height_ext(his, -1, _w);
			}
			
			draw_set_color(CDEF.main_dkgrey);
			draw_set_halign(fa_right);
			draw_text(_x - ui(12), _y + line_get_height(), i);
			draw_set_halign(fa_left);
			
			_y -= ui(2);
			if(_y <= 0) break;
		}
		
		if(pHOVER) {
			if(mouse_wheel_up())    scroll_y = clamp(scroll_y + 1, 0, array_length(CMD) - 1);
			if(mouse_wheel_down())  scroll_y = clamp(scroll_y - 1, 0, array_length(CMD) - 1);
		}
	} #endregion
	
	function drawContent(panel) { #region
		if(pFOCUS) {
			if(prevFocus == false)
				keyboard_string = command;
			
			HOTKEY_BLOCK = true;
			command = keyboard_string;
		}
		
		prevFocus = pFOCUS;
		
		draw_clear(merge_color(c_black, CDEF.main_dkblack, 0.75));
		
		draw_set_color(merge_color(c_black, CDEF.main_dkblack, 0.60));
		draw_rectangle(0, 0, ui(32), h, false);
		
		draw_set_color(merge_color(c_black, CDEF.main_dkblack, 0.25));
		draw_rectangle(0, h - ui(28), w, h, false);
		
		var hy = h - ui(32);
		drawHistory(hy);
			
		draw_set_text(f_code, fa_right, fa_bottom, CDEF.main_dkgrey);
		draw_text(ui(32 - 4), h - ui(4), ">");
		
		draw_set_text(f_code, fa_left, fa_bottom, COLORS._main_text);
		draw_text(ui(32 + 8), h - ui(4), command);
		
		draw_set_color(COLORS._main_text_sub);
		draw_text(ui(32 + 8) + string_width(command), h - ui(4), "_");
		
		if(pFOCUS) {
			if(keyboard_check_pressed(vk_enter)) { 
				cmd_submit(command);
				
				command = "";
				keyboard_string = "";
				
			} else if(keyboard_check_pressed(vk_up)) {
				cmd_index = max(0, cmd_index - 1); 
			
				var his = array_safe_get(CMDIN, cmd_index, "");
				command = is_instanceof(his, __cmdLine)? his.txt : his;
				keyboard_string = command;
			
			} else if(keyboard_check_pressed(vk_escape)) {
				command = "";
				keyboard_string = "";
				
			} else if(keyboard_check_pressed(vk_anykey)) {
				cmd_index = array_length(CMDIN);
			}
		}
	} #endregion
}