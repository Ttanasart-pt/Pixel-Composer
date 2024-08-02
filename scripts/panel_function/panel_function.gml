#region data
	globalvar PANEL_MAIN, PANEL_MENU, PANEL_PREVIEW, PANEL_INSPECTOR, PANEL_GRAPH, PANEL_ANIMATION, PANEL_COLLECTION, PANEL_FILE;
	globalvar FULL_SCREEN_PANEL, FULL_SCREEN_CONTENT, FULL_SCREEN_PARENT;
	
	PANEL_MAIN = 0;
	FULL_SCREEN_PANEL   = noone;
	FULL_SCREEN_CONTENT = noone;
	FULL_SCREEN_PARENT  = noone;
#endregion

#region panel class
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
	
	#macro PANEL_PADDING padding      = in_dialog? ui(20) : ui(16); \
						 title_height = in_dialog? ui(64) : ui(56);
	
	#macro PANEL_TITLE  draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text); \
					    draw_text_add(in_dialog? ui(56) : ui(24), title_height / 2 - (!in_dialog) * ui(4), title);
#endregion

#region functions 
	function clearPanel() { #region
		delete PANEL_MAIN;
		delete PANEL_MENU;
		delete PANEL_INSPECTOR;
		delete PANEL_PREVIEW;
		delete PANEL_GRAPH;
		delete PANEL_COLLECTION;
		
		PANEL_MAIN       = {};
		PANEL_MENU       = {};
		PANEL_INSPECTOR  = {};
		PANEL_PREVIEW    = {};
		PANEL_GRAPH      = {};
		PANEL_COLLECTION = {};
		
		PANEL_FILE       = 0;
	} #endregion
	
	function getPanelFromName(name, create = false, focus = true) { #region
		switch(name) {
			case "Panel_Menu"       : var p = (create || findPanel(name))? new Panel_Menu()		 : PANEL_MENU;		if(focus) { PANEL_MENU	     = p; } return p;
			case "Panel_Inspector"  : var p = (create || findPanel(name))? new Panel_Inspector() : PANEL_INSPECTOR; if(focus) { PANEL_INSPECTOR  = p; } return p;
			case "Panel_Animation"  : var p = (create || findPanel(name))? new Panel_Animation() : PANEL_ANIMATION; if(focus) { PANEL_ANIMATION  = p; } return p;
			case "Panel_Preview"    : var p = (create || findPanel(name))? new Panel_Preview()	 : PANEL_PREVIEW;	if(focus) { PANEL_PREVIEW	 = p; } return p;
			case "Panel_Graph"      : var p = (create || findPanel(name))? new Panel_Graph()	 : PANEL_GRAPH;		if(focus) { PANEL_GRAPH		 = p; } return p;
			case "Panel_Collection"	: var p = (create || findPanel(name))? new Panel_Collection(): PANEL_COLLECTION;if(focus) { PANEL_COLLECTION = p; } return p;
			
			case "Panel_Workspace"		: return new Panel_Workspace();
			case "Panel_Tunnels"		: return new Panel_Tunnels();
			case "Panel_History"		: return new Panel_History();
			case "Panel_Notification"   : return new Panel_Notification();
			case "Panel_Nodes"			: return new Panel_Nodes();
			case "Panel_Globalvar"		: return new Panel_Globalvar();
			case "Panel_Node_Align"		: return new Panel_Node_Align();
			case "Panel_File_Explorer"	: var p = (create || findPanel(name))? new Panel_File_Explorer() : PANEL_FILE; 	PANEL_FILE 	= p; return p;
			
			case "Panel_Color"			: return new Panel_Color();
			case "Panel_Palette"		: return new Panel_Palette();
			case "Panel_Palette_Mixer"	: return new Panel_Palette_Mixer();
			case "Panel_Gradient"		: return new Panel_Gradient();
			case "Panel_Console"		: return new Panel_Console();
			
			case "Panel_Preview_Histogram"	: return new Panel_Preview_Histogram();
		}
		
		return noone;
	} #endregion
	
	function LoadPanelStruct(struct) { 
		PANEL_MAIN = new Panel(noone, ui(2), ui(2), WIN_SW - ui(4), WIN_SH - ui(4));
		loadPanelStruct(PANEL_MAIN, struct); 
	}
	
	function loadPanelStruct(panel, str) { #region
		var cont = str.content;
		
		if(variable_struct_exists(str, "split")) {
			
			var pan = panel;
			     if(str.split == "v") pan = panel.split_v(ui(str.width));
			else if(str.split == "h") pan = panel.split_h(ui(str.width));
			
			if(pan != noone) {
				loadPanelStruct(pan[0], cont[0]);
				loadPanelStruct(pan[1], cont[1]);
			}
		} else {
			
			if(!is_array(cont)) cont = [ cont ];
			
			for( var i = 0, n = array_length(cont); i < n; i++ ) {
				var _content = cont[i];
				var _key = is_struct(_content)? _content.name : _content;
				
				var _pnCont = getPanelFromName(_key, true);
				if(_pnCont == noone) continue; 
				
				panel.setContent(_pnCont);
				if(is_struct(_content))
					_pnCont.deserialize(_content);
			}
		}
	} #endregion
	
	function loadPanel(path) {
		CURRENT_PANEL = json_load_struct(path);
		LoadPanelStruct(CURRENT_PANEL.panel);
	}
	
	function checkPanelValid() { #region
		var val  = true;
		var _mst = "";
		if(!is_instanceof(PANEL_GRAPH.panel, Panel))     { val = false; _mst += "Graph, "     };
		if(!is_instanceof(PANEL_PREVIEW.panel, Panel))   { val = false; _mst += "Preview, "   };
		if(!is_instanceof(PANEL_INSPECTOR.panel, Panel)) { val = false; _mst += "Inspector, " };
		
		if(!val) {
			noti_warning($"Invalid Panel Layout, missing {_mst} panel(s). Reset to the default layout and restart recommened.");
			
			PREFERENCES.panel_layout_file = "Vertical";
			PREFERENCES._display_scaling  = 1;
			PREFERENCES.display_scaling   = 0;
			
			resetScale(1);
		}
		
		return val;
	} #endregion
	
	function panelAdd(panel, create = false, focus = true) { #region
		var pan = getPanelFromName(panel, create, focus);
		if(pan == noone) return noone;
		
		return dialogPanelCall(pan, noone, noone, { focus });
	} #endregion
	
	function panelObjectInit() { #region
		PANEL_MAIN       = new Panel(noone, ui(2), ui(2), WIN_SW - ui(4), WIN_SH - ui(4));
		PANEL_MENU       = new Panel_Menu();
		PANEL_INSPECTOR  = new Panel_Inspector();
		PANEL_ANIMATION  = new Panel_Animation();
		PANEL_PREVIEW    = new Panel_Preview();
		PANEL_GRAPH      = new Panel_Graph();
		PANEL_COLLECTION = new Panel_Collection();
	} #endregion
	
	function resetPanel(check = true) { #region
		clearPanel();
		panelObjectInit();
		loadPanelStruct(PANEL_MAIN, CURRENT_PANEL.panel);
		PANEL_MAIN.refresh();
		
		if(check) checkPanelValid();
	} #endregion
	
	function __initPanel() { #region
		directory_verify($"{DIRECTORY}layouts");
		
		if(check_version($"{DIRECTORY}layouts/version"))
			zip_unzip("data/Layouts.zip", DIRECTORY);
		
		setPanel();
		panelDisplayInit();
		
		checkPanelValid();
		__initPanelHotkeys();
	} #endregion
	
	function setPanel() { #region
		globalvar CURRENT_PANEL;
		
		panelObjectInit();
		
		var file = $"{DIRECTORY}layouts/{PREFERENCES.panel_layout_file}.json"; 
		if(!file_exists_empty(file))
			file = DIRECTORY + "layouts/Horizontal.json"; 
		loadPanel(file);
		
		PANEL_MAIN.refresh();
		PANEL_MAIN.refreshSize();
	} #endregion
	
	function findPanel(_type, _pane = PANEL_MAIN) { #region
		var pan = _findPanel(_type, _pane);
		if(pan) return pan;
		
		with(o_dialog_panel) {
			if(instanceof(content) == _type) 
				return content;
		}
		
		return noone;
	} #endregion
	
	function _findPanel(_type, _pane, _res = noone) { #region
		if(instanceof(_pane) != "Panel")
			return _res;
		
		if(array_empty(_pane.childs) == 0) {
			for( var i = 0, n = array_length(_pane.content); i < n; i++ ) 
				if(instanceof(_pane.content[i]) == _type)
					return _pane.content[i];
		}
		
		for(var i = 0; i < array_length(_pane.childs); i++) {
			var _re = _findPanel(_type, _pane.childs[i], _res);
			if(_re != noone) _res = _re;
		}
		
		return _res;
	} #endregion
	
	function findPanels(_type, _pane = PANEL_MAIN) { #region
		return _findPanels(_type, _pane, []);
	} #endregion
	
	function _findPanels(_type, _pane, _arr = []) { #region
		if(!is_instanceof(_pane, Panel))
			return _arr;
		
		for( var i = 0, n = array_length(_pane.content); i < n; i++ ) {
			var _cnt = instanceof(_pane.content[i]);
			//print($" - content {_cnt} \ {_cnt == _type}");
			if(_cnt == _type)
				array_push(_arr, _pane.content[i]);
		}
		
		for(var i = 0; i < array_length(_pane.childs); i++)
			_arr = _findPanels(_type, _pane.childs[i], _arr);
		
		return _arr;
	} #endregion
	
	function panelInit() { #region
		panel_dragging = noone;
		panel_hovering = noone;
		panel_split = 0;
		
		panel_mouse = 0;
		
		panel_draw_x0 = noone; panel_draw_x0_to = noone;
		panel_draw_y0 = noone; panel_draw_y0_to = noone;
		panel_draw_x1 = noone; panel_draw_x1_to = noone;
		panel_draw_y1 = noone; panel_draw_y1_to = noone;
		
		panel_draw_depth = 0;
	} #endregion
	
	function panelDraw() { #region
		panel_draw_x0 = panel_draw_x0 == noone? panel_draw_x0_to : lerp_float(panel_draw_x0, panel_draw_x0_to, 3);
		panel_draw_y0 = panel_draw_y0 == noone? panel_draw_y0_to : lerp_float(panel_draw_y0, panel_draw_y0_to, 3);
		panel_draw_x1 = panel_draw_x1 == noone? panel_draw_x1_to : lerp_float(panel_draw_x1, panel_draw_x1_to, 3);
		panel_draw_y1 = panel_draw_y1 == noone? panel_draw_y1_to : lerp_float(panel_draw_y1, panel_draw_y1_to, 3);
		
		panel_draw_depth = lerp_float(panel_draw_depth, panel_split == 4, 3);
		
		if(panel_draw_x0_to != noone) {
			draw_set_color(COLORS._main_accent);
			
			if(panel_split == 4) {
				var dist = ui(8) * panel_draw_depth;
				draw_set_alpha(.2);
				draw_roundrect_ext(panel_draw_x0 - dist, panel_draw_y0 - dist, panel_draw_x1 - dist, panel_draw_y1 - dist, THEME_VALUE.panel_corner_radius, THEME_VALUE.panel_corner_radius, false);
				draw_set_alpha(1.);
				draw_roundrect_ext(panel_draw_x0 - dist, panel_draw_y0 - dist, panel_draw_x1 - dist, panel_draw_y1 - dist, THEME_VALUE.panel_corner_radius, THEME_VALUE.panel_corner_radius,  true);		
			
				draw_set_alpha(.2);
				draw_roundrect_ext(panel_draw_x0 + dist, panel_draw_y0 + dist, panel_draw_x1 + dist, panel_draw_y1 + dist, THEME_VALUE.panel_corner_radius, THEME_VALUE.panel_corner_radius, false);
				draw_set_alpha(1.);
				draw_roundrect_ext(panel_draw_x0 + dist, panel_draw_y0 + dist, panel_draw_x1 + dist, panel_draw_y1 + dist, THEME_VALUE.panel_corner_radius, THEME_VALUE.panel_corner_radius,  true);		
			} else {
				draw_set_alpha(.4);
				draw_roundrect_ext(panel_draw_x0, panel_draw_y0, panel_draw_x1, panel_draw_y1, THEME_VALUE.panel_corner_radius, THEME_VALUE.panel_corner_radius, false);
				draw_set_alpha(1.);
				draw_roundrect_ext(panel_draw_x0, panel_draw_y0, panel_draw_x1, panel_draw_y1, THEME_VALUE.panel_corner_radius, THEME_VALUE.panel_corner_radius,  true);		
			}
		}
		
		if(panel_dragging) {
			draw_surface_ext_safe(panel_dragging.dragSurface, mouse_mx + 8, mouse_my + 8, 0.5, 0.5, 0, c_white, 0.5);
			if((panel_mouse == 0 && mouse_release(mb_left)) || (panel_mouse == 1 && mouse_press(mb_left))) {
				var p = [];
				
				if(panel_split == 4) { 
					if(panel_hovering == PANEL_MAIN) { //pop out
						var panel = instanceof(panel_dragging) == "Panel"? panel_dragging.content : panel_dragging;
						dialogPanelCall(panel);
					} else 
						panel_hovering.setContent(panel_dragging, true);
				} else if(panel_hovering == PANEL_MAIN) { //split main panel
					var panel = new Panel(noone, ui(2), ui(2), WIN_SW - ui(4), WIN_SH - ui(4));
					var main  = PANEL_MAIN;
					
					switch(panel_split) {
						case 0 : p = panel.split_v( panel.h / 2); break; 
						case 1 : p = panel.split_h( panel.w / 2); break;
						case 2 : p = panel.split_h( panel.w / 2); break;
						case 3 : p = panel.split_v( panel.h / 2); break;
					}
					
					panel.parent.childs[(panel_split + 1) % 2] = main;
					main.parent = panel.parent;
					panel.parent.childs[(panel_split + 0) % 2].setContent(panel_dragging);
					
					PANEL_MAIN.refreshSize();
				} else {
					var c = panel_hovering.content;
					panel_hovering.content = [];
					
					switch(panel_split) {
						case 0 : p = panel_hovering.split_v( panel_hovering.h / 2); break; 
						case 1 : p = panel_hovering.split_h( panel_hovering.w / 2); break;
						case 2 : p = panel_hovering.split_h( panel_hovering.w / 2); break;
						case 3 : p = panel_hovering.split_v( panel_hovering.h / 2); break;
					}
				
					p[(panel_split + 1) % 2].setContent(c);
					p[(panel_split + 0) % 2].setContent(panel_dragging);
					
					panel_hovering.refreshSize();
				}
				
				panel_hovering = noone;
				panel_dragging = noone;
				
				panel_draw_x0 = noone; panel_draw_x0_to = noone;
				panel_draw_y0 = noone; panel_draw_y0_to = noone;
				panel_draw_x1 = noone; panel_draw_x1_to = noone;
				panel_draw_y1 = noone; panel_draw_y1_to = noone;
				panel_draw_depth = 0;
			}
		}
	} #endregion
	
	function panelSerialize(_content = false) { #region
		return { panel : _panelSerialize(PANEL_MAIN, _content) };
	} #endregion
	
	function _panelSerialize(_panel, _content = false) { #region
		var cont = {};
		var ind = 0;
		
		cont.content = [];
		if(_panel.split != "" && array_length(_panel.childs) == 2) {
			cont.split = _panel.split;
			if(_panel.split == "h") {
				ind = _panel.childs[1].w < _panel.childs[0].w;
				cont.width = _panel.childs[ind].w * (_panel.childs[ind].x == _panel.x? 1 : -1);
				
			} else {
				ind = _panel.childs[1].h < _panel.childs[0].h;
				cont.width = _panel.childs[ind].h * (_panel.childs[ind].y == _panel.y? 1 : -1);
			}
			
			ind = _panel.childs[1].x == _panel.x && _panel.childs[1].y == _panel.y;
			for( var i = 0; i < array_length(_panel.childs); i++ )
				cont.content[i] = _panelSerialize(_panel.childs[(ind + i) % 2], _content);
				
		} else {
			for( var i = 0, n = array_length(_panel.content); i < n; i++ )
				cont.content[i] = _content? _panel.content[i].serialize() : instanceof(_panel.content[i]);
		}
		
		return cont;
	} #endregion
	
	function panelSerializeArray() { #region
		return _panelSerializeArray(PANEL_MAIN);
	} #endregion
	
	function _panelSerializeArray(panel) { #region
		var cont = [];
		
		if(!array_empty(panel.childs)) {
			for( var i = 0; i < array_length(panel.childs); i++ )
				cont[i] = _panelSerializeArray(panel.childs[i] );
				
		} else {
			for( var i = 0, n = array_length(panel.content); i < n; i++ )
				cont[i] = instanceof(panel.content[i]);
		}
		
		return cont;
	} #endregion
#endregion

#region fullscreen
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
#endregion

#region focus hover
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
#endregion

#region hotkey
	function __initPanelHotkeys() {
		addHotkey("", "Preference",    "", MOD_KEY.none, function() /*=>*/ {return dialogCall(o_dialog_preference)});
		addHotkey("", "Splash screen", "", MOD_KEY.none, function() /*=>*/ {return dialogCall(o_dialog_splash)});
		addHotkey("", "Release note",  "", MOD_KEY.none, function() /*=>*/ {return dialogCall(o_dialog_release_note)});
		addHotkey("", "Autosave folder",  "", MOD_KEY.none, function() /*=>*/ {return shellOpenExplorer(DIRECTORY + "autosave")});
		
		addHotkey("", "Recent files",  "R", MOD_KEY.ctrl | MOD_KEY.shift, function() /*=>*/ {
			var arr = [];
			for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)
				array_push(arr, menuItem(RECENT_FILES[| i], function(_dat) { LOAD_PATH(_dat.name); }));
			
			return menuCall("Recent files",,, arr);
		});
		
		addHotkey("", "Addons",  "", MOD_KEY.none, function() /*=>*/ {return dialogPanelCall(new Panel_Addon())});
		addHotkey("", "History", "", MOD_KEY.none, function() /*=>*/ {return dialogPanelCall(new Panel_History())});
		
		addHotkey("", "Notification Panel", "", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Notification",	true)});
		addHotkey("", "Collections Panel",  "", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Collection",	true)});
		addHotkey("", "Graph Panel",	  	"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Graph", 		true)});
		addHotkey("", "Preview Panel",  	"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Preview",		true)});
		addHotkey("", "Inspector Panel",	"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Inspector", 	true)});
		addHotkey("", "Workspace Panel",	"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Workspace", 	true)});
		addHotkey("", "Animation Panel",	"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Animation", 	true)});
		addHotkey("", "Align Panel",		"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Node_Align",	true)});
		addHotkey("", "Nodes Panel",		"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Nodes", 		true)});
		addHotkey("", "Tunnels Panel",  	"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Tunnels",		true)});
		addHotkey("", "Color Panel",		"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Color", 		true)});
		addHotkey("", "Palettes Panel", 	"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Palette",		true)});
		addHotkey("", "Gradients Panel",	"", MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Gradient",		true)});
		addHotkey("", "Console Panel",  	"",	MOD_KEY.none, function() /*=>*/ {return panelAdd("Panel_Console",		true)});
	}
#endregion