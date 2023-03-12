function Panel_Workspace() : PanelContent() constructor {
	workspaces = [];
	w = ui(480);
	h = ui(96);
	
	function refreshContent() {
		workspaces = [];
		
		var f   = file_find_first(DIRECTORY + "layouts/*", 0);
		while(f != "") {
			array_push(workspaces, filename_name_only(f));
			f = file_find_next();
		}
	}
	refreshContent();
	
	function drawContent(panel) {
		draw_clear(COLORS.panel_bg_clear);
		
		var hori = w > h;
		
		var x0 = ui(6), x1;
		var y0 = ui(6), y1;
		
		draw_set_text(f_p1, hori? fa_left : fa_center, fa_top, COLORS._main_text_sub);
		
		for( var i = 0; i < array_length(workspaces); i++ ) {
			var tw = hori? string_width(workspaces[i]) + ui(16) : w - ui(16);
			var th = string_height(workspaces[i]) + ui(8);
			
			x1 = x0 + tw;
			y1 = y0 + th;
			
			if(pHOVER && point_in_rectangle(mx, my, x0, y0, x1, y1)) {
				draw_sprite_stretched(THEME.button_hide_fill, 1, x0, y0, x1 - x0, y1 - y0);
				
				if(mouse_press(mb_left, pFOCUS)) {
					PREF_MAP[? "panel_layout_file"] = workspaces[i];
					PREF_SAVE();
					setPanel();
				}
			}
			
			draw_set_color(PREF_MAP[? "panel_layout_file"] == workspaces[i]? COLORS._main_text : COLORS._main_text_sub)
			draw_text_add(hori? x0 + ui(8) : (x0 + x1) / 2, y0 + ui(4), workspaces[i]);
			
			if(hori) x0 += tw + ui(4);
			else     y0 += th + ui(4);
		}
	}
}