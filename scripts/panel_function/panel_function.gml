#region data
	globalvar PANEL_MAIN, PANEL_MENU, PANEL_PREVIEW, PANEL_INSPECTOR, PANEL_GRAPH, PANEL_ANIMATION, PANEL_COLLECTION;
	globalvar FULL_SCREEN_CONTENT;
	
	PANEL_MAIN = 0;
	FULL_SCREEN_CONTENT = noone;
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
#endregion

#region functions 
	function clearPanel() {
		delete PANEL_MAIN;
		delete PANEL_MENU;
		delete PANEL_INSPECTOR;
		delete PANEL_PREVIEW;
		delete PANEL_GRAPH;
		delete PANEL_COLLECTION;
		
		PANEL_MAIN = 0;
		PANEL_MENU = 0;
		PANEL_INSPECTOR = 0;
		PANEL_PREVIEW = 0;
		PANEL_GRAPH = 0;
		PANEL_COLLECTION = 0;
	}
	
	function loadPanelStruct(panel, str) {
		if(variable_struct_exists(str, "split") && is_array(str.content)) {
			var pan = panel;
			if(str.split == "v")
				pan = panel.split_v(ui(str.width));
			else if(str.split == "h")
				pan = panel.split_h(ui(str.width));
			
			if(pan != noone) {
				loadPanelStruct(pan[0], str.content[0]);
				loadPanelStruct(pan[1], str.content[1]);
			}
		} else {
			var cont = getPanelFromName(str.content)
			if(cont != noone) panel.set(cont);
		}
	}
	
	function getPanelFromName(name, create = false) {
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
		}
		
		return noone;
	}
	
	function loadPanel(path, panel) {
		CURRENT_PANEL = json_load_struct(path);
		loadPanelStruct(panel, CURRENT_PANEL.panel);
	}
	
	function panelAdd(panel, create = false) {
		var pan = getPanelFromName(panel, create);
		if(pan) dialogPanelCall(pan);
	}
	
	function panelObjectInit() {
		PANEL_MAIN       = new Panel(noone, ui(2), ui(2), WIN_SW - ui(4), WIN_SH - ui(4));
		PANEL_MENU       = new Panel_Menu();
		PANEL_INSPECTOR  = new Panel_Inspector();
		PANEL_ANIMATION  = new Panel_Animation();
		PANEL_PREVIEW    = new Panel_Preview();
		PANEL_GRAPH      = new Panel_Graph();
		PANEL_COLLECTION = new Panel_Collection();
	}
	
	function resetPanel() {
		clearPanel();
		panelObjectInit();
		loadPanelStruct(PANEL_MAIN, CURRENT_PANEL.panel);
		PANEL_MAIN.refresh();
	}
	
	function setPanel() {
		globalvar CURRENT_PANEL;
		
		panelObjectInit();
		if(!directory_exists(DIRECTORY + "layouts")) 
			zip_unzip("data/layouts.zip", DIRECTORY);
			
		var file = DIRECTORY + "layouts/" + PREF_MAP[? "panel_layout_file"] + ".json"; 
		if(!file_exists(file))
			file = DIRECTORY + "layouts/Horizontal.json"; 
		loadPanel(file, PANEL_MAIN);
		
		PANEL_ANIMATION.updatePropertyList();
		PANEL_MAIN.refresh();
	}
	
	function findPanel(_type, _pane = PANEL_MAIN) {
		var pan = _findPanel(_type, _pane);
		if(pan) return pan;
		
		with(o_dialog_panel) {
			if(instanceof(content) == _type) 
				return content;
		}
		
		return noone;
	}
	
	function _findPanel(_type, _pane, _res = noone) {
		if(instanceof(_pane) != "Panel")
			return _res;
		if(!ds_exists(_pane.childs, ds_type_list))
			return _res;
		
		if(ds_list_size(_pane.childs) == 0 && _pane.content && instanceof(_pane.content) == _type)
			return _pane.content;
		
		for(var i = 0; i < ds_list_size(_pane.childs); i++) {
			var _re = _findPanel(_type, _pane.childs[| i], _res);
			if(_re != noone) _res = _re;
		}
		
		return _res;
	}
	
	function panelInit() {
		panel_dragging = noone;
		panel_hovering = noone;
		panel_split = 0;
		
		panel_mouse = 0;
		
		panel_draw_x0 = noone; panel_draw_x0_to = noone;
		panel_draw_y0 = noone; panel_draw_y0_to = noone;
		panel_draw_x1 = noone; panel_draw_x1_to = noone;
		panel_draw_y1 = noone; panel_draw_y1_to = noone;
		
		panel_draw_depth = 0;
	}
	
	function panelDraw() {
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
				draw_roundrect_ext(panel_draw_x0 - dist, panel_draw_y0 - dist, panel_draw_x1 - dist, panel_draw_y1 - dist, 8, 8, false);
				draw_set_alpha(1.);
				draw_roundrect_ext(panel_draw_x0 - dist, panel_draw_y0 - dist, panel_draw_x1 - dist, panel_draw_y1 - dist, 8, 8,  true);		
			
				draw_set_alpha(.2);
				draw_roundrect_ext(panel_draw_x0 + dist, panel_draw_y0 + dist, panel_draw_x1 + dist, panel_draw_y1 + dist, 8, 8, false);
				draw_set_alpha(1.);
				draw_roundrect_ext(panel_draw_x0 + dist, panel_draw_y0 + dist, panel_draw_x1 + dist, panel_draw_y1 + dist, 8, 8,  true);		
			} else {
				draw_set_alpha(.4);
				draw_roundrect_ext(panel_draw_x0, panel_draw_y0, panel_draw_x1, panel_draw_y1, 8, 8, false);
				draw_set_alpha(1.);
				draw_roundrect_ext(panel_draw_x0, panel_draw_y0, panel_draw_x1, panel_draw_y1, 8, 8,  true);		
			}
		}
		
		if(panel_dragging) {
			draw_surface_ext(panel_dragging.dragSurface, mouse_mx + 8, mouse_my + 8, 0.5, 0.5, 0, c_white, 0.5);
			if((panel_mouse == 0 && mouse_release(mb_left)) || (panel_mouse == 1 && mouse_press(mb_left))) {
				var p = [];
				
				if(panel_split == 4) {
					var panel = instanceof(panel_dragging) == "Panel"? panel_dragging.content : panel_dragging;
					dialogPanelCall(panel);
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
					panel.parent.childs[| (panel_split + 0) % 2].set(panel_dragging);
					
					PANEL_MAIN.refreshSize();
				} else {
					var c = panel_hovering.content;
					panel_hovering.content = noone;
					
					switch(panel_split) {
						case 0 : p = panel_hovering.split_v( panel_hovering.h / 2); break; 
						case 1 : p = panel_hovering.split_h( panel_hovering.w / 2); break;
						case 2 : p = panel_hovering.split_h( panel_hovering.w / 2); break;
						case 3 : p = panel_hovering.split_v( panel_hovering.h / 2); break;
					}
				
					p[(panel_split + 1) % 2].set(c);
					p[(panel_split + 0) % 2].set(panel_dragging);
					
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
	}
	
	function panelSerialize() {
		var cont = {};
		cont.panel = _panelSerialize(PANEL_MAIN);
		return cont;
	}
	
	function _panelSerialize(panel) {
		var cont = {};
		var ind = 0;
		
		if(panel.split != "" && ds_list_size(panel.childs) == 2) {
			cont.split = panel.split;
			if(panel.split == "h") {
				ind = panel.childs[| 1].w < panel.childs[| 0].w;
				cont.width = panel.childs[| ind].w * (panel.childs[| ind].x == panel.x? 1 : -1);
				
			} else {
				ind = panel.childs[| 1].h < panel.childs[| 0].h;
				cont.width = panel.childs[| ind].h * (panel.childs[| ind].y == panel.y? 1 : -1);
			}
			
			cont.content = [];
			ind = panel.childs[| 1].x == panel.x && panel.childs[| 1].y == panel.y;
			for( var i = 0; i < ds_list_size(panel.childs); i++ )
				cont.content[i] = _panelSerialize(panel.childs[| (ind + i) % 2]);
		} else if(panel.content != noone)
			cont.content = instanceof(panel.content);
		
		return cont;
	}
	
	function panelSerializeArray() {
		return _panelSerializeArray(PANEL_MAIN);
	}
	
	function _panelSerializeArray(panel) {
		var cont = [];
		
		if(panel.content == noone) {
			for( var i = 0; i < ds_list_size(panel.childs); i++ )
				cont[i] = _panelSerializeArray(panel.childs[| i]);
		} else
			cont = instanceof(panel.content);
		
		return cont;
	}
#endregion

#region fullscreen
	function set_focus_fullscreen() {
		if(FULL_SCREEN_CONTENT != noone) {
			PANEL_MAIN.childs[| 1].content = noone;
			FULL_SCREEN_CONTENT = noone;
			PANEL_MAIN.refreshSize();
			return;
		}
		
		var panel = PREF_MAP[? "expand_hover"]? HOVER : FOCUS;
		
		if(panel == noone) return;
		if(!is_struct(panel)) return;
		if(instanceof(panel) != "Panel") return;
		if(panel.content == noone) return;
		if(!panel.content.expandable) return;
		
		PANEL_MAIN.childs[| 1].set(panel.content);
		FULL_SCREEN_CONTENT = panel;
	}
#endregion

#region function
	function panelHover(content) {
		return HOVER && is_struct(HOVER) && instanceof(HOVER) == "Panel" && instanceof(HOVER.content) == instanceof(content);
	}
	
	function panelFocus(content) {
		return FOCUS && is_struct(FOCUS) && instanceof(FOCUS) == "Panel" && instanceof(FOCUS.content) == instanceof(content);
	}
#endregion