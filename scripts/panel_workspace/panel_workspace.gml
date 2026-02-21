#region function
	globalvar PANEL_MODIFIED; PANEL_MODIFIED = false;
	
	#macro CHECK_PANEL_WORKSPACE if(!is_instanceof(FOCUS_CONTENT, Panel_Workspace)) return;
	
	function panel_workspace_apply()	{ CHECK_PANEL_WORKSPACE CALL("panel_workspace_apply");		FOCUS_CONTENT.apply_space();   }
	function panel_workspace_replace()	{ CHECK_PANEL_WORKSPACE CALL("panel_workspace_replace");	FOCUS_CONTENT.replace_space(); }
	function panel_workspace_delete()	{ CHECK_PANEL_WORKSPACE CALL("panel_workspace_delete");		FOCUS_CONTENT.delete_space();  }
#endregion

function Panel_Workspace() : PanelContent() constructor {
	title      = "Workspace";
	workspaces = [];
	w = ui(480);
	h = ui(24);
	
	font       = f_p3;
	scroll     = 0;
	scroll_to  = 0;
	scroll_max = 0;
	scroll_ini = true;
	
	layout_selecting = "";
	
	registerFunction( "Workspace", "Apply",   "", MOD_KEY.none, panel_workspace_apply   );
	registerFunction( "Workspace", "Replace", "", MOD_KEY.none, panel_workspace_replace );
	registerFunction( "Workspace", "Delete",  "", MOD_KEY.none, panel_workspace_delete  );
	
	////- Workspace
	
	function apply_space() {
		if(layout_selecting == "") return;
		PREFERENCES.panel_layout_file = layout_selecting;
		PREF_SAVE();
		setPanel();
	}
	
	function replace_space() { 
		if(layout_selecting == "") return;
		var cont = panelSerialize();
		json_save_struct(DIRECTORY + "layouts/" + layout_selecting + ".json", cont);
	}
	
	function delete_space() { 
		if(layout_selecting == "") return;
		file_delete(DIRECTORY + "layouts/" + layout_selecting + ".json");
		refreshContent();
	}
	
	function refreshContent() {
		workspaces = [];
		
		var f   = file_find_first(DIRECTORY + "layouts/*", 0);
		while(f != "") {
			if(filename_ext(f) == ".json")
				array_push(workspaces, filename_name_only(f));
			f = file_find_next();
		}
		
	} refreshContent();
	
	////- Draw
	
	function onFocusBegin() { refreshContent(); }
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var x0 = scroll, x1;
		var y0, y1;
		
		var cx = w / 2, _tx;
		var cy = h / 2, _ty;
		
		var ww = 0;
		var hh = 0;
		var amo = array_length(workspaces);
		
		draw_set_font(font);
		var currT = PREFERENCES.panel_layout_file;
		if(PANEL_MODIFIED) currT += "*";
		
		var currW = string_width(currT) + ui(24)
		x0 += currW;
		ww += currW;
		
		draw_set_text(font, fa_center, fa_center);
		
		for( var i = 0; i <= amo; i++ ) {
			var str = i == amo? "+" : workspaces[i];
			var tw  = string_width(str)  + ui(12);
			var th  = string_height(str) + ui(8);
			var sel = PREFERENCES.panel_layout_file == str;
			
			x1 = x0 + tw;
			
			y0 = cy - th / 2;
			y1 = y0 + th;
			
			if(mx > currW && pHOVER && point_in_rectangle(mx, my, x0, y0, x1, y1)) {
				draw_sprite_stretched(THEME.button_hide_fill, 1, x0, y0, tw, th);
				
				if(mouse_press(mb_left, pFOCUS)) {
					if(i == amo) {
						fileNameCall(str, function(name) /*=>*/ { 
							var cont = panelSerialize();
							json_save_struct($"{DIRECTORY}layouts/{name}.json", cont);
							
							PREFERENCES.panel_layout_file = name;
							PREF_SAVE();
							refreshContent();
						}).setName(PREFERENCES.panel_layout_file);
						
					} else {
						PREFERENCES.panel_layout_file = str;
						PREF_SAVE();
						setPanel();
					}
				}
				
				if(mouse_press(mb_right, pFOCUS)) {
					layout_selecting = str;
					menuCall("workspace_menu", [
						menuItem(__txt("Select"), apply_space),
						menuItem(__txtx("workspace_replace_current", "Replace with current"), replace_space),
						menuItem(__txt("Delete"), delete_space, THEME.cross),
					]);
				}
			}
			
			_tx = x0 + tw / 2;
			_ty = cy;
			
			draw_set_color(sel? CDEF.main_mdwhite : CDEF.main_grey);
			draw_text_add(_tx, _ty, str);
			
			x0 += tw + ui(1);
			ww += tw + ui(1);
		}
		
		draw_set_color(COLORS.panel_bg_clear);
		draw_rectangle(0, 0, currW, h, false);
		
		var _hov = pHOVER && point_in_rectangle(mx, my, 0, 0, currW, h);
		if(_hov) {
			draw_sprite_stretched(THEME.button_hide_fill, 1, ui(8), ui(8), currW - ui(16), h - ui(16));
				
			if(mouse_press(mb_right, pFOCUS)) {
				menuCall("workspace_current_menu", [
					menuItem(__txt("Reset"), function() /*=>*/ {return setPanel()}),
				]);
			}
		}
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		draw_text_add(ui(12), cy, currT);
		
		draw_set_color(COLORS._main_icon_dark);
		draw_line_round(currW - ui(4), ui(8), currW - ui(4), h - ui(8), 3);
		
		scroll     = lerp_float(scroll, scroll_to, 5);
		scroll_max = max(ww - w + ui(16), 0);
		if(pHOVER && MOUSE_WHEEL != 0)
			scroll_to = clamp(scroll_to + ui(128) * MOUSE_WHEEL, -scroll_max, 0);
		scroll_ini = false;
			
	}
}