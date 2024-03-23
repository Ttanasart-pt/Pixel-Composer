#region data
	globalvar PANEL_MAIN, PANEL_MENU, PANEL_PREVIEW, PANEL_INSPECTOR, PANEL_GRAPH, PANEL_ANIMATION, PANEL_COLLECTION;
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
	
	#macro PANEL_PADDING padding      = in_dialog? ui(24) : ui(16); \
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
	} #endregion
	
	function getPanelFromName(name, create = false) { #region
		switch(name) {
			case "Panel_Menu"       : return (create || findPanel(name))? new Panel_Menu()		 : PANEL_MENU;
			case "Panel_Inspector"  : return (create || findPanel(name))? new Panel_Inspector()	 : PANEL_INSPECTOR;
			case "Panel_Animation"  : return (create || findPanel(name))? new Panel_Animation()	 : PANEL_ANIMATION;
			case "Panel_Preview"    : return (create || findPanel(name))? new Panel_Preview()	 : PANEL_PREVIEW;
			case "Panel_Graph"      : return (create || findPanel(name))? new Panel_Graph()		 : PANEL_GRAPH;
			
			case "Panel_Collection"		: return new Panel_Collection();
			case "Panel_Workspace"		: return new Panel_Workspace();
			case "Panel_Tunnels"		: return new Panel_Tunnels();
			case "Panel_History"		: return new Panel_History();
			case "Panel_Notification"   : return new Panel_Notification();
			case "Panel_Nodes"			: return new Panel_Nodes();
			case "Panel_Globalvar"		: return new Panel_Globalvar();
			case "Panel_Node_Align"		: return new Panel_Node_Align();
			
			case "Panel_Color"		: return new Panel_Color();
			case "Panel_Palette"	: return new Panel_Palette();
			case "Panel_Gradient"	: return new Panel_Gradient();
			case "Panel_Console"	: return new Panel_Console();
		}
		
		return noone;
	} #endregion
	
	function loadPanelStruct(panel, str) { #region
		var cont = str.content;
		
		if(variable_struct_exists(str, "split")) {
			var pan = panel;
			if(str.split == "v")
				pan = panel.split_v(ui(str.width));
			else if(str.split == "h")
				pan = panel.split_h(ui(str.width));
			
			if(pan != noone) {
				loadPanelStruct(pan[0], cont[0]);
				loadPanelStruct(pan[1], cont[1]);
			}
		} else {
			if(!is_array(cont)) cont = [ cont ];
			for( var i = 0, n = array_length(cont); i < n; i++ ) {
				var _cont = getPanelFromName(cont[i])
				if(_cont != noone) panel.setContent(_cont);
			}
		}
	} #endregion
	
	function loadPanel(path, panel) { #region
		CURRENT_PANEL = json_load_struct(path);
		loadPanelStruct(panel, CURRENT_PANEL.panel);
	} #endregion
	
	function checkPanelValid() { #region
		var val = true;
		if(!is_instanceof(PANEL_GRAPH.panel, Panel))     val = false;
		if(!is_instanceof(PANEL_PREVIEW.panel, Panel))   val = false;
		if(!is_instanceof(PANEL_INSPECTOR.panel, Panel)) val = false;
		
		if(!val) {
			noti_warning("Invalid Panel Layout, layout and UI scale will be reset to the default value.\n\nRestart recommended.");
			
			PREFERENCES.panel_layout_file = "Vertical";
			PREFERENCES._display_scaling  = 1;
			PREFERENCES.display_scaling   = 0;
			resetScale(1);
		}
		
		return val;
	} #endregion
	
	function panelAdd(panel, create = false) { #region
		var pan = getPanelFromName(panel, create);
		if(pan == noone) return noone;
		
		return dialogPanelCall(pan);
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
	
	function resetPanel() { #region
		clearPanel();
		panelObjectInit();
		loadPanelStruct(PANEL_MAIN, CURRENT_PANEL.panel);
		PANEL_MAIN.refresh();
		
		checkPanelValid();
	} #endregion
	
	function __initPanel() { #region
		directory_verify($"{DIRECTORY}layouts");
		
		if(check_version($"{DIRECTORY}layouts/version"))
			zip_unzip("data/Layouts.zip", DIRECTORY);
		
		setPanel();
		panelDisplayInit();
		
		checkPanelValid();
	} #endregion
	
	function setPanel() { #region
		globalvar CURRENT_PANEL;
		
		panelObjectInit();
		
		var file = $"{DIRECTORY}layouts/{PREFERENCES.panel_layout_file}.json"; 
		if(!file_exists_empty(file))
			file = DIRECTORY + "layouts/Horizontal.json"; 
		loadPanel(file, PANEL_MAIN);
		
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
		if(!ds_exists(_pane.childs, ds_type_list))
			return _res;
		
		if(ds_list_size(_pane.childs) == 0) {
			for( var i = 0, n = array_length(_pane.content); i < n; i++ ) 
				if(instanceof(_pane.content[i]) == _type)
					return _pane.content[i];
		}
		
		for(var i = 0; i < ds_list_size(_pane.childs); i++) {
			var _re = _findPanel(_type, _pane.childs[| i], _res);
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
		if(!ds_exists(_pane.childs, ds_type_list))
			return _arr;
		
		for( var i = 0, n = array_length(_pane.content); i < n; i++ ) {
			var _cnt = instanceof(_pane.content[i]);
			//print($" - content {_cnt} \ {_cnt == _type}");
			if(_cnt == _type)
				array_push(_arr, _pane.content[i]);
		}
		
		for(var i = 0; i < ds_list_size(_pane.childs); i++)
			_arr = _findPanels(_type, _pane.childs[| i], _arr);
		
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
					
					panel.parent.childs[| (panel_split + 1) % 2] = main;
					main.parent = panel.parent;
					panel.parent.childs[| (panel_split + 0) % 2].setContent(panel_dragging);
					
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
	
	function panelSerialize() { #region
		var cont = {};
		cont.panel = _panelSerialize(PANEL_MAIN);
		return cont;
	} #endregion
	
	function _panelSerialize(panel) { #region
		var cont = {};
		var ind = 0;
		
		cont.content = [];
		if(panel.split != "" && ds_list_size(panel.childs) == 2) {
			cont.split = panel.split;
			if(panel.split == "h") {
				ind = panel.childs[| 1].w < panel.childs[| 0].w;
				cont.width = panel.childs[| ind].w * (panel.childs[| ind].x == panel.x? 1 : -1);
				
			} else {
				ind = panel.childs[| 1].h < panel.childs[| 0].h;
				cont.width = panel.childs[| ind].h * (panel.childs[| ind].y == panel.y? 1 : -1);
			}
			
			ind = panel.childs[| 1].x == panel.x && panel.childs[| 1].y == panel.y;
			for( var i = 0; i < ds_list_size(panel.childs); i++ )
				cont.content[i] = _panelSerialize(panel.childs[| (ind + i) % 2]);
		} else {
			for( var i = 0, n = array_length(panel.content); i < n; i++ )
				cont.content[i] = instanceof(panel.content[i]);
		}
		
		return cont;
	} #endregion
	
	function panelSerializeArray() { #region
		return _panelSerializeArray(PANEL_MAIN);
	} #endregion
	
	function _panelSerializeArray(panel) { #region
		var cont = [];
		
		if(!ds_list_empty(panel.childs)) {
			for( var i = 0; i < ds_list_size(panel.childs); i++ )
				cont[i] = _panelSerializeArray(panel.childs[| i] );
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
		
			PANEL_MAIN.childs[| 1].setContent(content);
			
			FULL_SCREEN_PARENT  = PANEL_MAIN.childs[| 1];
			FULL_SCREEN_PANEL   = panel;
			FULL_SCREEN_CONTENT = content;
		
			content.onFullScreen();
		} else {
			PANEL_MAIN.childs[| 1].content = [];
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