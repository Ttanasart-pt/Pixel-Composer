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
		if(variable_struct_exists(str, "split")) {
			var pan = panel;
			if(str.split == "v")
				pan = panel.split_v(ui(str.width));
			else if(str.split == "h")
				pan = panel.split_h(ui(str.width));
			
			if(variable_struct_exists(str, "content")) {
				loadPanelStruct(pan[0], str.content[0]);
				loadPanelStruct(pan[1], str.content[1]);
			}
		} else if(variable_struct_exists(str, "content"))
			panel.set(getPanelFromName(str.content));
	}
	
	function getPanelFromName(name) {
		switch(name) {
			case "INSPECTOR" : return PANEL_INSPECTOR;
			case "ANIMATION" : return PANEL_ANIMATION;
			case "PREVIEW"   : return PANEL_PREVIEW;
			case "GRAPH"	 : return PANEL_GRAPH;
		}
		
		return noone;
	}
	
	function loadPanel(path, panel) {
		var f = json_load_struct(path);
		loadPanelStruct(panel, f.panel);
		
		if(PREF_MAP[? "panel_collection"]) {
			var pan  = getPanelFromName(f.collection.parent);
			var p;
			
			if(f.collection.split == "v")
				p = pan.panel.split_v(ui(f.collection.width));
			else if(f.collection.split == "h")
				p = pan.panel.split_h(ui(f.collection.width));
			
			p[0].set(PANEL_COLLECTION);
			p[1].set(pan);
		}
	}
	
	function setPanel() {
		PANEL_MAIN = new Panel(noone, ui(2), ui(2), WIN_SW - ui(4), WIN_SH - ui(4));
		
		PANEL_MENU      = new Panel_Menu();
		PANEL_INSPECTOR = new Panel_Inspector();
		PANEL_ANIMATION = new Panel_Animation();
		PANEL_PREVIEW   = new Panel_Preview();
		PANEL_GRAPH     = new Panel_Graph();
		PANEL_COLLECTION = new Panel_Collection();
		
		var split_menu	= PANEL_MAIN.split_v(ui(40));
		split_menu[0].set(PANEL_MENU);
		
		zip_unzip("data/layouts.zip", DIRECTORY);
		loadPanel(DIRECTORY + "layouts/" + PREF_MAP[? "panel_layout_file"] + ".json", split_menu[1]);
		
		PANEL_ANIMATION.updatePropertyList();
		PANEL_MAIN.refresh();
	}
	
	function findPanel(_type, _pane, _res) {
		if(instanceof(_pane) != "Panel")
			return _res;
		if(!ds_exists(_pane.childs, ds_type_list))
			return _res;
		
		if(ds_list_size(_pane.childs) == 0 && _pane.content && instanceof(_pane.content) == _type)
			return _pane.content;
		
		for(var i = 0; i < ds_list_size(_pane.childs); i++) {
			var _re = findPanel(_type, _pane.childs[| i], _res);
			if(_re != noone)
				_res = _re;
		}
		
		return _res;
	}
	
	function panelInit() {
		panel_dragging = noone;
		panel_hovering = noone;
		panel_split = 0;
	}
	
	function panelDraw() {
		if(panel_dragging) {
			draw_surface_ext(panel_dragging.dragSurface, mouse_mx + 8, mouse_my + 8, 0.5, 0.5, 0, c_white, 0.5);
			
			if(mouse_release(mb_left)) {
				var p = [];
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
				
				panel_hovering = noone;
				panel_dragging = noone;
			}
		}
	}
	
	function panelSerialize() {
		var cont = _panelSerialize(PANEL_MAIN);
		print(json_stringify(cont, true));
	}
	
	function _panelSerialize(panel) {
		var cont = {};
		
		cont.content = panel.content == noone? noone : instanceof(panel.content);
		cont.split   = panel.split;
		
		cont.child = [];
		for( var i = 0; i < ds_list_size(panel.childs); i++ )
			cont.child[i] = _panelSerialize(panel.childs[| i]);
		
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
		return HOVER && is_struct(HOVER) && instanceof(HOVER) == "Panel" && HOVER.content == content;
	}
	
	function panelFocus(content) {
		return FOCUS && is_struct(FOCUS) && instanceof(FOCUS) == "Panel" && FOCUS.content == content;
	}
#endregion