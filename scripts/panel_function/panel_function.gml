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
	
	function setPanel() {
		PANEL_MAIN = new Panel(noone, 0, 0, WIN_SW, WIN_SH);
		
		PANEL_MENU      = new Panel_Menu();
		PANEL_INSPECTOR = new Panel_Inspector();
		PANEL_ANIMATION = new Panel_Animation();
		PANEL_PREVIEW   = new Panel_Preview();
		PANEL_GRAPH     = new Panel_Graph();
		PANEL_COLLECTION = new Panel_Collection();
		
		var split_menu	= PANEL_MAIN.split_v(ui(40));
		split_menu[0].set(PANEL_MENU);
		
		var split_ins	= split_menu[1].split_h(ui(-400));
		split_ins[1].set(PANEL_INSPECTOR);
		
		switch(PREF_MAP[? "panel_layout"]) {
			case 0 :
				var split_anim	= split_ins[0].split_v(ui(-48));
				split_anim[1].set(PANEL_ANIMATION);
				
				var split_prev	= split_anim[0].split_v(ui(-500));
				if(split_prev == noone) break;
				
				split_prev[0].set(PANEL_PREVIEW);
				split_prev[1].set(PANEL_GRAPH);
				
				if(PREF_MAP[? "panel_collection"]) {
					var pane = split_prev[1].split_h(ui(460));
					if(pane == noone) break;
					pane[1].set(PANEL_GRAPH);
					pane[0].set(PANEL_COLLECTION);
				}
				break;
			case 1 :
				var split_anim	= split_ins[0].split_v(ui(-300));
				split_anim[1].set(PANEL_ANIMATION);
				
				var split_prev	= split_anim[0].split_h(ui(400));
				if(split_prev == noone) break;
				
				split_prev[0].set(PANEL_PREVIEW);
				split_prev[1].set(PANEL_GRAPH);
				
				if(PREF_MAP[? "panel_collection"]) {
					var pane = split_anim[1].split_h(ui(500));
					if(pane == noone) break;
					pane[1].set(PANEL_ANIMATION);
					pane[0].set(PANEL_COLLECTION);
				}
				break;
		}
		
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