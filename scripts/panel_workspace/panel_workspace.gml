#macro CHECK_PANEL_WORKSPACE if(!is_instanceof(FOCUS_CONTENT, Panel_Workspace)) return;

function panel_workspace_apply()	{ CHECK_PANEL_WORKSPACE CALL("panel_workspace_apply");		FOCUS_CONTENT.apply_space();   }
function panel_workspace_replace()	{ CHECK_PANEL_WORKSPACE CALL("panel_workspace_replace");	FOCUS_CONTENT.replace_space(); }
function panel_workspace_delete()	{ CHECK_PANEL_WORKSPACE CALL("panel_workspace_delete");		FOCUS_CONTENT.delete_space();  }

function Panel_Workspace() : PanelContent() constructor {
	title      = "Workspace";
	workspaces = [];
	w = ui(480);
	h = ui(32);
	
	scroll     = 0;
	scroll_to  = 0;
	scroll_max = 0;
	hori       = false;
	
	layout_selecting = "";
	
	registerFunction("Workspace", "Apply",	 "", MOD_KEY.none, panel_workspace_apply);
	registerFunction("Workspace", "Replace", "", MOD_KEY.none, panel_workspace_replace);
	registerFunction("Workspace", "Delete",	 "", MOD_KEY.none, panel_workspace_delete);
	
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
	
	function onFocusBegin() { refreshContent(); }
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var _hori = hori;
		hori = w > h;
		
		if(hori != _hori) scroll_to = 0;
		
		var x0 = ui(8) + scroll, x1;
		var y0, y1;
		var cx = w / 2;
		var cy = h / 2;
		
		var ww = 0;
		var hh = 0;
		var amo = array_length(workspaces);
		
		draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
		
		for( var i = 0; i <= amo; i++ ) {
			var str = i == amo? "+" : workspaces[i];
			var tw  = string_width(str)  + ui(16);
			var th  = string_height(str) + ui(8);
			
			x1 = x0 + tw;
			
			y0 = cy - th / 2;
			y1 = y0 + th;
			
			if(pHOVER && point_in_rectangle(mx, my, x0, y0, x1, y1)) {
				draw_sprite_stretched(THEME.button_hide_fill, 1, x0, y0, tw, th);
				
				if(mouse_press(mb_left, pFOCUS)) {
					if(i == amo) {
						var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
						dia.name = PREFERENCES.panel_layout_file;
						dia.onModify = function(name) { 
							var cont = panelSerialize();
							json_save_struct($"{DIRECTORY}layouts/{name}.json", cont);
							
							PREFERENCES.panel_layout_file = name;
							PREF_SAVE();
							refreshContent();
						};
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
			
			if(PREFERENCES.panel_layout_file == str) draw_set_color(COLORS._main_text);    
			else                                     draw_set_color(COLORS._main_text_sub);
			
			var _tx = x0 + tw / 2;
			var _ty = cy;
			
			draw_text_add(_tx, _ty, str);
			
			x0 += tw + ui(4);
			ww += tw + ui(4);
		}
		
		scroll = lerp_float(scroll, scroll_to, 5);
		
		if(hori) {
			scroll_max = max(ww - w + ui(16), 0);
			if(pHOVER && MOUSE_WHEEL != 0)
				scroll_to = clamp(scroll_to + ui(128) * MOUSE_WHEEL, -scroll_max, 0);
			
		} else {
			scroll_max = max(hh - h + ui(16), 0);
			if(pHOVER && MOUSE_WHEEL != 0)
				scroll_to = clamp(scroll_to + ui(32) * MOUSE_WHEEL, -scroll_max, 0);
		}
	}
}