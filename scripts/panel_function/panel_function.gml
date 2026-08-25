#region data
	globalvar PANEL_MAIN; PANEL_MAIN          = 0;
	globalvar PANEL_MENU; PANEL_MENU          = 0;
	globalvar PANEL_PREVIEW; PANEL_PREVIEW       = undefined;
	globalvar PANEL_INSPECTOR; PANEL_INSPECTOR     = undefined;
	globalvar PANEL_GRAPH; PANEL_GRAPH         = undefined;
	globalvar PANEL_ANIMATION; PANEL_ANIMATION     = undefined;
	globalvar PANEL_COLLECTION; PANEL_COLLECTION    = undefined;
	globalvar PANEL_FILE; PANEL_FILE          = noone;
	globalvar PANEL_NODES; PANEL_NODES         = noone;
	
	globalvar PANEL_HOVERING; PANEL_HOVERING      = noone;
	
	globalvar PANEL_DRAGGING; PANEL_DRAGGING      = noone;
	globalvar PANEL_DRAG_MOUSE; PANEL_DRAG_MOUSE    = 0;
	
	globalvar FULL_SCREEN_PANEL; FULL_SCREEN_PANEL   = noone;
	globalvar FULL_SCREEN_CONTENT; FULL_SCREEN_CONTENT = noone;
	globalvar FULL_SCREEN_PARENT; FULL_SCREEN_PARENT  = noone;
	
	globalvar PANEL_DRAW_X0; PANEL_DRAW_X0       = noone;
	globalvar PANEL_DRAW_Y0; PANEL_DRAW_Y0       = noone;
	globalvar PANEL_DRAW_X1; PANEL_DRAW_X1       = noone;
	globalvar PANEL_DRAW_Y1; PANEL_DRAW_Y1       = noone;
	globalvar PANEL_DRAW_SPLIT; PANEL_DRAW_SPLIT    = 0;
	
	globalvar __PANEL_DRAW_X0; __PANEL_DRAW_X0     = noone;
	globalvar __PANEL_DRAW_Y0; __PANEL_DRAW_Y0     = noone;
	globalvar __PANEL_DRAW_X1; __PANEL_DRAW_X1     = noone;
	globalvar __PANEL_DRAW_Y1; __PANEL_DRAW_Y1     = noone;
	globalvar __PANEL_DRAW_SPLIT; __PANEL_DRAW_SPLIT  = 0;

	enum PANEL_CONTENT {
		empty,
		splith,
		splitv,
		menu,
		inspector,
		animation,
		preview,
		graph,
		collection
	}
#endregion

	////- Global
	
function __initPanel() {
	var root = $"{DIRECTORY}layouts";
	directory_verify(root);
	
	if(check_version($"{root}/version"))
		zip_unzip($"{working_directory}pack/layouts.zip", root);
	
	setPanel();
	checkPanelValid();
}

function panelObjectInit(_w = WIN_SW, _h = WIN_SH) {
	if(PANEL_MAIN)       delete PANEL_MAIN;
	if(PANEL_MENU)       delete PANEL_MENU;
	if(PANEL_INSPECTOR)  delete PANEL_INSPECTOR;
	if(PANEL_PREVIEW)    delete PANEL_PREVIEW;
	if(PANEL_GRAPH)      delete PANEL_GRAPH;
	if(PANEL_COLLECTION) delete PANEL_COLLECTION;
	
	if(PANEL_FILE)       delete PANEL_FILE;
	if(PANEL_NODES)      delete PANEL_NODES;
	
	PANEL_MAIN       = new Panel(noone, ui(2), ui(2), _w - ui(4), _h - ui(4));
	PANEL_MENU       = new Panel_Menu();
	PANEL_INSPECTOR  = new Panel_Inspector();
	PANEL_ANIMATION  = new Panel_Animation();
	PANEL_PREVIEW    = new Panel_Preview();
	PANEL_GRAPH      = new Panel_Graph();
	PANEL_COLLECTION = new Panel_Collection();
}

	////- Setter

function setPanel(_initPanel = true) {
	globalvar CURRENT_PANEL;
	
	if(_initPanel) panelObjectInit();
	var file = $"{DIRECTORY}layouts/{PREFERENCES.panel_layout_file}.json"; 
	
	if(!file_exists_empty(file)) {
		noti_warning($"Panel layout file not found: Reverted to default {PREFERENCES.panel_layout_file} layout.")
		PREFERENCES.panel_layout_file = PREFERENCES_DEF.panel_layout_file;
		file = $"{DIRECTORY}layouts/{PREFERENCES.panel_layout_file}.json"; 
	}
		
	CURRENT_PANEL = json_load_struct(file);
	loadPanelStruct(CURRENT_PANEL.panel, _initPanel);
	
	PANEL_MAIN.refresh();
	PANEL_MAIN.refreshSize();
}

function refreshPanel(check = true) {
	panelObjectInit();
	__loadPanelStruct(PANEL_MAIN, CURRENT_PANEL.panel);
	PANEL_MAIN.refresh();
	
	if(check) checkPanelValid();
}

function checkPanelValid() {
	var valid = true;
	var missp = "";
	
	if(!is(PANEL_GRAPH.panel,     Panel)) { valid = false; missp += "Graph, "     };
	if(!is(PANEL_PREVIEW.panel,   Panel)) { valid = false; missp += "Preview, "   };
	if(!is(PANEL_INSPECTOR.panel, Panel)) { valid = false; missp += "Inspector, " };
	
	if(!valid) {
		noti_warning($"Invalid Panel Layout, missing {missp} panel(s). Reset to the default layout and restart recommened.");
		PREFERENCES.panel_layout_file = "__default";
		PREFERENCES._display_scaling  = 1;
		PREFERENCES.display_scaling   = 0;
		resetScale(1);
	}
	
	return valid;
}

	////- Getter

function getPanelFromName(name, create = false, focus = true) {
	var c = create || findPanel(name);
	
	switch(name) {
		case "Panel_Menu"          : var p = c? new Panel_Menu()          : PANEL_MENU;       if(focus) { PANEL_MENU       = p; } return p;
		case "Panel_Inspector"     : var p = c? new Panel_Inspector()     : PANEL_INSPECTOR;  if(focus) { PANEL_INSPECTOR  = p; } return p;
		case "Panel_Animation"     : var p = c? new Panel_Animation()     : PANEL_ANIMATION;  if(focus) { PANEL_ANIMATION  = p; } return p;
		case "Panel_Preview"       : var p = c? new Panel_Preview()       : PANEL_PREVIEW;    if(focus) { PANEL_PREVIEW    = p; } return p;
		case "Panel_Graph"         : var p = c? new Panel_Graph()         : PANEL_GRAPH;      if(focus) { PANEL_GRAPH      = p; } return p;
		case "Panel_Collection"    : var p = c? new Panel_Collection()    : PANEL_COLLECTION; if(focus) { PANEL_COLLECTION = p; } return p;
		case "Panel_File_Explorer" : var p = c? new Panel_File_Explorer() : PANEL_FILE;       if(focus) { PANEL_FILE       = p; } return p;
		
		default : 
			var fn = asset_get_index(name); 
			if(is_callable(fn)) return new fn();
	}
	
	return noone;
}

function   findPanel(_type, _pane = PANEL_MAIN) {
	var pan = __findPanel(_type, _pane); if(pan) return pan;
	with(o_dialog_panel) { if(instanceof(content) == _type) return content; }
	return noone;
}
function __findPanel(_type, _pane, _res = noone) {
	if(instanceof(_pane) != "Panel")
		return _res;
	
	if(array_empty(_pane.childs) == 0) {
		for( var i = 0, n = array_length(_pane.content); i < n; i++ ) 
			if(instanceof(_pane.content[i]) == _type)
				return _pane.content[i];
	}
	
	for( var i = 0, n = array_length(_pane.childs); i < n; i++ ) {
		var _re = __findPanel(_type, _pane.childs[i], _res);
		if(_re != noone) _res = _re;
	}
	
	return _res;
}

function   findPanels(_type, _pane = PANEL_MAIN) { return __findPanels(_type, _pane, []); }
function __findPanels(_type, _pane, _arr = []) {
	if(!is(_pane, Panel))
		return _arr;
	
	for( var i = 0, n = array_length(_pane.content); i < n; i++ ) {
		var _cnt = instanceof(_pane.content[i]);
		//print($" - content {_cnt} \ {_cnt == _type}");
		if(_cnt == _type)
			array_push(_arr, _pane.content[i]);
	}
	
	for(var i = 0; i < array_length(_pane.childs); i++)
		_arr = __findPanels(_type, _pane.childs[i], _arr);
	
	return _arr;
}

	////- o_main

function PANEL_INIT() {
	dialog_popup    = 0;
	dialog_popup_to = 0;
	dialog_popup_x  = 0;
	dialog_popup_y  = 0;
}

function PANEL_DRAW() {
	__PANEL_DRAW_X0    = __PANEL_DRAW_X0 == noone? PANEL_DRAW_X0 : lerp_float(__PANEL_DRAW_X0, PANEL_DRAW_X0, 3);
	__PANEL_DRAW_Y0    = __PANEL_DRAW_Y0 == noone? PANEL_DRAW_Y0 : lerp_float(__PANEL_DRAW_Y0, PANEL_DRAW_Y0, 3);
	__PANEL_DRAW_X1    = __PANEL_DRAW_X1 == noone? PANEL_DRAW_X1 : lerp_float(__PANEL_DRAW_X1, PANEL_DRAW_X1, 3);
	__PANEL_DRAW_Y1    = __PANEL_DRAW_Y1 == noone? PANEL_DRAW_Y1 : lerp_float(__PANEL_DRAW_Y1, PANEL_DRAW_Y1, 3);
	__PANEL_DRAW_SPLIT = lerp_float(__PANEL_DRAW_SPLIT, PANEL_DRAW_SPLIT == 4, 3);
	
	if(HOVER_WINDOW == 1)
		PANEL_DRAW_DRAG();
	
	if(PANEL_DRAGGING) {
		draw_surface_ext_safe(PANEL_DRAGGING.dragSurface, mouse_mx + 8, mouse_my + 8, 0.5, 0.5, 0, c_white, 0.5);
		if((PANEL_DRAG_MOUSE == 0 && mouse_lrelease()) || (PANEL_DRAG_MOUSE == 1 && mouse_lpress())) {
			var p = [];
			
			if(PANEL_DRAW_SPLIT == 4) { 
				if(PANEL_HOVERING == PANEL_MAIN) { // Pop out
					var panel = instanceof(PANEL_DRAGGING) == "Panel"? PANEL_DRAGGING.content : PANEL_DRAGGING;
					dialogPanelCall(panel);
					
				} else if(is(PANEL_HOVERING, Panel))
					PANEL_HOVERING.setContent(PANEL_DRAGGING, true);
					
			} else if(PANEL_HOVERING == PANEL_MAIN) { // Split main panel
				var panel = new Panel(noone, ui(2), ui(2), WIN_SW - ui(4), WIN_SH - ui(4));
				var main  = PANEL_MAIN;
				
				switch(PANEL_DRAW_SPLIT) {
					case 0 : p = panel.split_v( panel.h / 2); break; 
					case 1 : p = panel.split_h( panel.w / 2); break;
					case 2 : p = panel.split_h( panel.w / 2); break;
					case 3 : p = panel.split_v( panel.h / 2); break;
				}
				
				panel.parent.childs[(PANEL_DRAW_SPLIT + 1) % 2] = main;
				main.parent = panel.parent;
				panel.parent.childs[(PANEL_DRAW_SPLIT + 0) % 2].setContent(PANEL_DRAGGING);
				
				PANEL_MAIN.refreshSize();
				
			} else if(PANEL_HOVERING != noone) {
				var c = PANEL_HOVERING.content;
				PANEL_HOVERING.content = [];
				
				switch(PANEL_DRAW_SPLIT) {
					case 0 : p = PANEL_HOVERING.split_v( PANEL_HOVERING.h / 2); break; 
					case 1 : p = PANEL_HOVERING.split_h( PANEL_HOVERING.w / 2); break;
					case 2 : p = PANEL_HOVERING.split_h( PANEL_HOVERING.w / 2); break;
					case 3 : p = PANEL_HOVERING.split_v( PANEL_HOVERING.h / 2); break;
				}
			
				p[(PANEL_DRAW_SPLIT + 1) % 2].setContent(c);
				p[(PANEL_DRAW_SPLIT + 0) % 2].setContent(PANEL_DRAGGING);
				
				PANEL_HOVERING.refreshSize();
			}
			
			PANEL_HOVERING  = noone;
			PANEL_DRAGGING  = noone;
			
			PANEL_DRAW_X0   = noone;
			PANEL_DRAW_Y0   = noone;
			PANEL_DRAW_X1   = noone;
			PANEL_DRAW_Y1   = noone;
			
			__PANEL_DRAW_X0 = noone; 
			__PANEL_DRAW_Y0 = noone; 
			__PANEL_DRAW_X1 = noone; 
			__PANEL_DRAW_Y1 = noone; 
			
			__PANEL_DRAW_SPLIT = 0;
		}
	}
}

function PANEL_DRAW_DRAG() {
	var _rr = THEME_VALUE.panel_corner_radius;
	if(PANEL_DRAW_X0 != noone) {
		draw_set_color(COLORS._main_accent);
		
		if(PANEL_DRAW_SPLIT == 4) {
			var dist = ui(8) * __PANEL_DRAW_SPLIT;
			draw_set_alpha(.2);
			draw_roundrect_ext(__PANEL_DRAW_X0 - dist, __PANEL_DRAW_Y0 - dist, __PANEL_DRAW_X1 - dist, __PANEL_DRAW_Y1 - dist, _rr, _rr, false);
			draw_set_alpha(1.);
			draw_roundrect_ext(__PANEL_DRAW_X0 - dist, __PANEL_DRAW_Y0 - dist, __PANEL_DRAW_X1 - dist, __PANEL_DRAW_Y1 - dist, _rr, _rr,  true);		
		
			draw_set_alpha(.2);
			draw_roundrect_ext(__PANEL_DRAW_X0 + dist, __PANEL_DRAW_Y0 + dist, __PANEL_DRAW_X1 + dist, __PANEL_DRAW_Y1 + dist, _rr, _rr, false);
			draw_set_alpha(1.);
			draw_roundrect_ext(__PANEL_DRAW_X0 + dist, __PANEL_DRAW_Y0 + dist, __PANEL_DRAW_X1 + dist, __PANEL_DRAW_Y1 + dist, _rr, _rr,  true);		
			
		} else {
			draw_set_alpha(.4);
			draw_roundrect_ext(__PANEL_DRAW_X0, __PANEL_DRAW_Y0, __PANEL_DRAW_X1, __PANEL_DRAW_Y1, _rr, _rr, false);
			draw_set_alpha(1.);
			draw_roundrect_ext(__PANEL_DRAW_X0, __PANEL_DRAW_Y0, __PANEL_DRAW_X1, __PANEL_DRAW_Y1, _rr, _rr,  true);	
		}
		
	}
	
}

function PANEL_DRAW_GUI() {
	draw_set_color(COLORS._main_accent);
	dialog_popup = lerp_float(dialog_popup, dialog_popup_to, 5);
	dialog_popup_to = 0;
	
	if(dialog_popup > 0) {
		var _rr = THEME_VALUE.panel_corner_radius;
		var dpw = ui(24) * dialog_popup;
		var dph = ui(24) * dialog_popup;
		
		var dpx = clamp(dialog_popup_x, 8 + dpw, WIN_W - 8 - dpw);
		var dpy = clamp(dialog_popup_y, 8 + dph, WIN_H - 8 - dph);
		
		draw_set_alpha(.4);
		draw_roundrect_ext(dpx - dpw, dpy - dph, dpx + dpw, dpy + dph, _rr, _rr, false);
		draw_set_alpha(1.);
		draw_roundrect_ext(dpx - dpw, dpy - dph, dpx + dpw, dpy + dph, _rr, _rr,  true);
	}
}

	////- Serialize

function   loadPanelStruct(_str, _initPanel = true) { 
	if(_initPanel) PANEL_MAIN = new Panel(noone, ui(2), ui(2), WIN_SW - ui(4), WIN_SH - ui(4));
	__loadPanelStruct(PANEL_MAIN, _str); 
}
function __loadPanelStruct(panel, str) {
	var focPanel = undefined;
	var cont = str.content;
	
	panel.tab_align     = str[$ "tab_align"]     ?? 0;
	panel.content_index = str[$ "content_index"] ?? 0;
		
	if(has(str, "split")) {
		var pan = panel;
		     if(str.split == "v") pan = panel.split_v(ui(str.width));
		else if(str.split == "h") pan = panel.split_h(ui(str.width));
		
		if(pan != noone) {
			var _f = __loadPanelStruct(pan[0], cont[0]); focPanel = focPanel ?? _f;
			var _f = __loadPanelStruct(pan[1], cont[1]); focPanel = focPanel ?? _f;
		}
		
	} else {
		if(!is_array(cont)) cont = [ cont ];
		var is_main = str[$ "main"] ?? false;
		
		for( var i = 0, n = array_length(cont); i < n; i++ ) {
			var _content = cont[i];
			var _key = is_struct(_content)? _content[$ "name"] : _content;
			if(_key == undefined) continue;
			
			var _pnCont = getPanelFromName(_key, true);
			if(_pnCont == noone) continue; 
			
			if(is_main) focPanel = _pnCont;
			panel.setContent(_pnCont);
			if(is_struct(_content))
				_pnCont.deserialize(_content);
		}
	}
	
	if(panel.isGlobal()) PANEL_MODIFIED = false;
	
	return focPanel;
}

function   panelSerialize(_content = false) { return { panel : __panelSerialize(PANEL_MAIN, _content) }; }
function __panelSerialize(_panel, _content = false) {
	var cont = {};
	cont.content       = [];
	cont.tab_align     = _panel.tab_align;
	cont.content_index = _panel.content_index;
	
	var ind = 0;
	if(_panel.split != "" && array_length(_panel.childs) == 2) {
		cont.split = _panel.split;
		if(_panel.split == "h") {
			ind = _panel.childs[1].w < _panel.childs[0].w;
			cont.width = _ui(_panel.childs[ind].w * (_panel.childs[ind].x == _panel.x? 1 : -1));
			
		} else {
			ind = _panel.childs[1].h < _panel.childs[0].h;
			cont.width = _ui(_panel.childs[ind].h * (_panel.childs[ind].y == _panel.y? 1 : -1));
		}
		
		ind = _panel.childs[1].x == _panel.x && _panel.childs[1].y == _panel.y;
		for( var i = 0; i < array_length(_panel.childs); i++ )
			cont.content[i] = __panelSerialize(_panel.childs[(ind + i) % 2], _content);
			
	} else {
		for( var i = 0, n = array_length(_panel.content); i < n; i++ )
			cont.content[i] = _content? _panel.content[i].serialize() : instanceof(_panel.content[i]);
	}
	
	return cont;
}

function   panelSerializeArray() { return __panelSerializeArray(PANEL_MAIN); }
function __panelSerializeArray(panel) {
		var cont = [];
		
		if(!array_empty(panel.childs)) {
			for( var i = 0; i < array_length(panel.childs); i++ )
				cont[i] = __panelSerializeArray(panel.childs[i] );
				
		} else {
			for( var i = 0, n = array_length(panel.content); i < n; i++ )
				cont[i] = instanceof(panel.content[i]);
		}
		
		return cont;
	}

	////- Actions

function set_focus_fullscreen() {
	if(FULL_SCREEN_PANEL == noone) {
		var panel = PREFERENCES.expand_hover? HOVER : FOCUS;
	
		if(panel == noone)                   return;
		if(!is_struct(panel))                return;
		if(instanceof(panel) != "Panel")     return;
		if(array_length(panel.content) == 0) return;
	
		var content = panel.getContent();
		if(!content.expandable)   return;
	
		PANEL_MAIN.childs[1].setContent(content);
		
		FULL_SCREEN_PARENT  = PANEL_MAIN.childs[1];
		FULL_SCREEN_PANEL   = panel;
		FULL_SCREEN_CONTENT = content;
	
		content.onFullScreen();
	} else {
		PANEL_MAIN.childs[1].content = [];
		PANEL_MAIN.refreshSize();
		
		FULL_SCREEN_CONTENT.onFullScreen();
		
		FULL_SCREEN_PARENT  = noone;
		FULL_SCREEN_PANEL   = noone;
		FULL_SCREEN_CONTENT = noone;
	}
}

function panelHover(content) {
	if(!HOVER) return false;
	if(instanceof(HOVER) != "Panel") return false;
	
	return instanceof(HOVER.getContent()) == instanceof(content);
}

function panelFocus(content) {
		if(!FOCUS) return false;
		if(instanceof(FOCUS) != "Panel") return false;
		
		return instanceof(FOCUS.getContent()) == instanceof(content);
	}

	////- Hotkey

function __fnInit_Panels() {
		var n = MOD_KEY.none;
		var c = MOD_KEY_CTRL;
		var s = MOD_KEY.shift;
		var a = MOD_KEY.alt;
		
        registerFunction("", "Preferences",               "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Preference())}        ).setMenu("preference",      THEME.gear)
        registerFunction("", "Splash screen",             "", n, function() /*=>*/ {return dialogCall(o_dialog_splash)}                    ).setMenu("splash_screen")
        registerFunction("", "Release note",              "", n, function() /*=>*/ {return dialogCall(o_dialog_release_note)}              ).setMenu("release_note")
        registerFunction("", "Command Palette",     vk_space, c, function() /*=>*/ {return dialogCall(o_dialog_command_palette)}           ).setMenu("command_palette")
        registerFunction("", "Open Autosave Folder",      "", n, function() /*=>*/ {return shellOpenExplorer(DIRECTORY + "autosave")}      ).setMenu("autosave_folder", THEME.save_auto)
        
        registerFunction("", "Addons",                 "",  n,   function() /*=>*/ {return dialogPanelCall(new Panel_Addon())}             ).setMenu("addons")
        registerFunction("", "History",                "Z", c|a, function() /*=>*/ {return dialogPanelCall(new Panel_History())}           ).setMenu("history")
        
        registerFunction("", "Notification Panel",    vk_f12, n, function() /*=>*/ {return dialogPanelCall(new Panel_Notification())}      ).setMenuAlt("Notification",   "notification_panel")
        registerFunction("", "Collections Panel",         "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Collection())}        ).setMenuAlt("Collections",    "collections_panel")
        registerFunction("", "Graph Panel",               "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Graph())}             ).setMenuAlt("Graph",          "graph_panel")
        
        registerFunction("", "Preview Panel",             "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Preview())}           ).setMenuAlt("Preview",        "preview_panel")
        registerFunction("", "Preview Histogram",         "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Preview_Histogram())} ).setMenuAlt("Histogram",      "preview_histogram")
        
        registerFunction("", "Inspector Panel",           "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Inspector())}         ).setMenuAlt("Inspector",      "inspector_panel")
        registerFunction("", "Workspace Panel",           "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Workspace())}         ).setMenuAlt("Workspace",      "workspace_panel")
        registerFunction("", "Animation Panel",           "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Animation())}         ).setMenuAlt("Animation",      "animation_panel")
        
        registerFunction("", "Randomizer Panel",          "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Randomizer())}        ).setMenuAlt("Randomizer",     "randomizer_panel")
        registerFunction("", "Align Panel",               "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Node_Align())}        ).setMenuAlt("Align",          "align_panel")
        registerFunction("", "Nodes Panel",               "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Nodes())}             ).setMenuAlt("Nodes",          "nodes_panel")
        registerFunction("", "Tunnels Panel",             "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Tunnels())}           ).setMenuAlt("Tunnels",        "tunnels_panel")
        
        registerFunction("", "Color Panel",               "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Color())}             ).setMenuAlt("Color",          "color_panel")
        registerFunction("", "Palettes Panel",            "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Palette())}           ).setMenuAlt("Palettes",       "palettes_panel")
        registerFunction("", "Palettes Mixer Panel",      "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Palette_Mixer())}     ).setMenuAlt("Palettes Mixer", "palettes_mixer_panel")
        registerFunction("", "Gradients Panel",           "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Gradient())}          ).setMenuAlt("Gradients",      "gradients_panel")
        
        registerFunction("", "Console Panel",             "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Console())}           ).setMenuAlt("Console",        "console_panel")
        registerFunction("", "Globalvar Panel",           "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Globalvar())}         ).setMenuAlt("Globalvar",      "globalvar_panel")
        registerFunction("", "File Explorer Panel",       "", n, function() /*=>*/ {return dialogPanelCall(new Panel_File_Explorer())}     ).setMenuAlt("File",           "file_explorer_panel")
        registerFunction("", "Locale Manager",            "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Locale_Manager())}    ).setMenuAlt("Locale Manager", "locale_manager_panel")
        
        registerFunction("", "Steam Workshop Panel",      "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Steam_Workshop())}    ).setMenuAlt("Steam Workshop", "steam_workshop_panel")
        registerFunction("", "Collection Runner Panel",   "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Collection_Runner())} ).setMenuAlt("Runner",         "collection_runner_panel")
        registerFunction("", "Node Manager Panel",        "", n, function() /*=>*/ {return dialogPanelCall(new Panel_Nodes_Manager())}     ).setMenuAlt("Node Manager",   "node_manager_panel")
	}
