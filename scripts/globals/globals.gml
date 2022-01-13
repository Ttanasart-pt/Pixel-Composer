#region save
	globalvar LOADING, APPENDING, APPEND_ID, READONLY, CONNECTION_CONFLICT, GLOBAL_SEED;
	LOADING   = false;
	APPENDING = false;
	APPEND_ID = 0;
	READONLY  = false;
	CONNECTION_CONFLICT = ds_queue_create();
	
	randomize();
	GLOBAL_SEED = irandom(9999999999);
#endregion

#region main
	globalvar DEBUG;
	DEBUG = false;
	
	globalvar VERSION, SAVEFILE_VERSION, VERSION_STRING;
	VERSION = 82;
	SAVEFILE_VERSION = 80;
	VERSION_STRING = "0.8.2";
	
	globalvar NODES, ANIMATOR, NODE_ID, NODE_MAP, HOTKEYS, HOTKEY_CONTEXT;
	
	NODE_ID		= 0;
	NODES		= ds_list_create();
	NODE_MAP	= ds_map_create();
	
	HOTKEYS			= ds_map_create();
	HOTKEY_CONTEXT	= ds_list_create();
	HOTKEY_CONTEXT[| 0] = "";
	
	enum ANIMATOR_END {
		loop,
		stop
	}
	ANIMATOR = {
		frames_total : 30,
		current_frame : 0,
		real_frame : 0,
		framerate : 30,
		is_playing : false,
		is_scrubing : false,
		
		frame_progress : false,
		
		playback : ANIMATOR_END.loop
	};
#endregion

#region panel
	globalvar FOCUS, FOCUS_STR, HOVER, DOUBLE_CLICK, CURRENT_PATH;
	globalvar TEXTBOX_ACTIVE;
	
	CURRENT_PATH	= "";
	DOUBLE_CLICK	= false;
	FOCUS			= noone;
	FOCUS_STR		= "";
	HOVER			= noone;
	
	globalvar PANEL_MAIN, PANEL_MENU, PANEL_PREVIEW, PANEL_INSPECTOR, PANEL_GRAPH, PANEL_ANIMATION, PANEL_COLLECTION;
	PANEL_MAIN = 0;
	
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
		PANEL_MAIN = new Panel(noone, 0, 0, WIN_W, WIN_H);
		
		var split_menu	= PANEL_MAIN.split_v(40);
		PANEL_MENU      = new Panel_Menu(split_menu[0]);
		
		var split_ins	= split_menu[1].split_h(-400);
		PANEL_INSPECTOR = new Panel_Inspector(split_ins[1]);
		
		switch(PREF_MAP[? "panel_layout"]) {
			case 0 :
				var split_anim	= split_ins[0].split_v(-48);
				PANEL_ANIMATION = new Panel_Animation(split_anim[1]);
		
				var split_prev	= split_anim[0].split_v(-500);
				PANEL_PREVIEW   = new Panel_Preview(split_prev[0]);
				
				PANEL_GRAPH     = new Panel_Graph(split_prev[1]);
				
				if(PREF_MAP[? "panel_collection"]) {
					var pane = PANEL_GRAPH.panel.split_h(460);
					pane[1].set(PANEL_GRAPH);
					PANEL_COLLECTION = new Panel_Collection(pane[0]);
				}
				break;
			case 1 :
				var split_anim	= split_ins[0].split_v(-240);
				PANEL_ANIMATION = new Panel_Animation(split_anim[1]);
				
				var split_prev	= split_anim[0].split_h(400);
				PANEL_PREVIEW   = new Panel_Preview(split_prev[0]);
				
				PANEL_GRAPH     = new Panel_Graph(split_prev[1]);
				
				if(PREF_MAP[? "panel_collection"]) {
					var pane = PANEL_ANIMATION.panel.split_h(460);
					pane[1].set(PANEL_ANIMATION);
					PANEL_COLLECTION = new Panel_Collection(pane[0]);
				}
				break;
		}
		
		PANEL_ANIMATION.updatePropertyList();
		PANEL_MAIN.refresh();
	}
	
	TEXTBOX_ACTIVE = noone
	
	globalvar ADD_NODE_PAGE, ADD_NODE_W, ADD_NODE_H;
	ADD_NODE_PAGE  = "";
	ADD_NODE_W     = 372 + 16 * 3 + 8;
	ADD_NODE_H     = 320;
	
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
	
	globalvar AXIS_COLOR;
	
	AXIS_COLOR = [ c_ui_red, c_ui_lime, c_ui_cyan, c_yellow, c_aqua, c_fuchsia, c_orange, c_ltgray ];
#endregion

#region macro
	#macro WIN_W window_get_width() / PREF_MAP[? "display_scaling"]
	#macro WIN_H window_get_height() / PREF_MAP[? "display_scaling"]
	
	#macro mouse_mx device_mouse_x_to_gui(0)
	#macro mouse_my device_mouse_y_to_gui(0)
	
	#region color
		#macro c_ui_blue_dkblack	$251919
		#macro c_ui_blue_mdblack	$2c1e1e
		#macro c_ui_blue_black		$362727
		#macro c_ui_blue_dkgrey		$4e3b3b
		#macro c_ui_blue_grey		$816d6d
		#macro c_ui_blue_ltgrey		$8f7e7e
		#macro c_ui_blue_white		$e8d6d6
		#macro c_ui_cyan			$e9ff88
									
		#macro c_ui_yellow			$78e4ff
		#macro c_ui_orange			$6691ff
		#macro c_ui_orange_light	$92c2ff
		
		#macro c_ui_red				$4b00eb
		#macro c_ui_pink			$b700eb
		#macro c_ui_purple			$d40092
		
		#macro c_ui_lime_dark		$38995e
		#macro c_ui_lime			$5dde8f
		#macro c_ui_lime_light		$b2ffd0
	#endregion
	
	#region functions
		#macro BLEND_ADD gpu_set_blendmode_ext(bm_one, bm_zero);
		#macro BLEND_NORMAL gpu_set_blendmode(bm_normal);
	#endregion
#endregion

#region presets
	function INIT_FOLDERS() {
		if(!directory_exists(DIRECTORY + "Palettes"))
			directory_create(DIRECTORY + "Palettes");
		if(!directory_exists(DIRECTORY + "Gradients"))
			directory_create(DIRECTORY + "Gradients");
	}
#endregion

#region default
	globalvar DEF_SURFACE;
	function DEF_SURFACE_RESET() {
		DEF_SURFACE = surface_create(1, 1);
		surface_set_target(DEF_SURFACE);
			draw_clear_alpha(c_white, 0);
		surface_reset_target();
	}
	DEF_SURFACE_RESET();
#endregion