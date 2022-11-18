#region data
	globalvar PANEL_MAIN, PANEL_MENU, PANEL_PREVIEW, PANEL_INSPECTOR, PANEL_GRAPH, PANEL_ANIMATION, PANEL_COLLECTION;
	PANEL_MAIN = 0;
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
		
		PANEL_MAIN = 0;
		PANEL_MENU = 0;
		PANEL_INSPECTOR = 0;
		PANEL_PREVIEW = 0;
		PANEL_GRAPH = 0;
	}
	
	function setPanel() {
		PANEL_MAIN = new Panel(noone, 0, 0, WIN_SW, WIN_SH);
		
		var split_menu	= PANEL_MAIN.split_v(ui(40));
		PANEL_MENU      = new Panel_Menu(split_menu[0]);
		
		var split_ins	= split_menu[1].split_h(ui(-400));
		PANEL_INSPECTOR = new Panel_Inspector(split_ins[1]);
		
		switch(PREF_MAP[? "panel_layout"]) {
			case 0 :
				var split_anim	= split_ins[0].split_v(ui(-48));
				PANEL_ANIMATION = new Panel_Animation(split_anim[1]);
				
				var split_prev	= split_anim[0].split_v(ui(-500));
				PANEL_PREVIEW   = new Panel_Preview(split_prev[0]);
				
				PANEL_GRAPH     = new Panel_Graph(split_prev[1]);
				
				//if(PREF_MAP[? "panel_collection"]) {
				//	var pane = PANEL_GRAPH.panel.split_h(ui(460));
				//	if(pane == noone) break;
				//	pane[1].set(PANEL_GRAPH);
				//	PANEL_COLLECTION = new Panel_Collection(pane[0]);
				//}
				break;
			case 1 :
				var split_anim	= split_ins[0].split_v(ui(-300));
				PANEL_ANIMATION = new Panel_Animation(split_anim[1]);
				
				var split_prev	= split_anim[0].split_h(ui(400));
				PANEL_PREVIEW   = new Panel_Preview(split_prev[0]);
				
				PANEL_GRAPH     = new Panel_Graph(split_prev[1]);
				
				//if(PREF_MAP[? "panel_collection"]) {
				//	var pane = PANEL_ANIMATION.panel.split_h(ui(500));
				//	if(pane == noone) break;
				//	pane[1].set(PANEL_ANIMATION);
				//	PANEL_COLLECTION = new Panel_Collection(pane[0]);
				//}
				break;
		}
		
		PANEL_ANIMATION.updatePropertyList();
		PANEL_MAIN.refresh();
	}
	
	function findPanel(_name, _pane, _res) {
		if(instanceof(_pane) != "Panel") 
			return _res;
		if(!ds_exists(_pane.childs, ds_type_list))
			return _res;
		
		if(ds_list_size(_pane.childs) == 0 && _pane.content && instanceof(_pane.content) == _name) {
			return _pane.content;
		}
		
		for(var i = 0; i < ds_list_size(_pane.childs); i++) {
			var _re = findPanel(_name, _pane.childs[| i], _res);
			if(_re != noone)
				_res = _re;
		}
		
		return _res;
	}
#endregion