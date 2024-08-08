#region funtion calls
	function __fnInit_Animation() {
		__registerFunction("animation_play_pause",		panel_animation_play_pause);
		__registerFunction("animation_resume",			panel_animation_resume);
		
		__registerFunction("animation_first_frame",		panel_animation_first_frame);
		__registerFunction("animation_last_frame",		panel_animation_last_frame);
		__registerFunction("animation_next_frame",		panel_animation_next_frame);
		__registerFunction("animation_prev_frame",		panel_animation_prev_frame);
		
		__registerFunction("animation_delete_key",		panel_animation_delete_key);
		__registerFunction("animation_duplicate",		panel_animation_duplicate);
		__registerFunction("animation_copy",			panel_animation_copy);
		__registerFunction("animation_paste",			panel_animation_paste);
	}
	
	function panel_animation_play_pause()	{ CALL("animation_play_pause");	if(IS_RENDERING) return; if(IS_PLAYING) PROJECT.animator.pause() else PROJECT.animator.play();					  }
	function panel_animation_resume()		{ CALL("animation_resume");		if(IS_RENDERING) return; if(PROJECT.animator.is_playing) PROJECT.animator.pause() else PROJECT.animator.resume(); }
	
	function panel_animation_first_frame()	{ CALL("animation_first_frame");	if(IS_RENDERING) return; PROJECT.animator.firstFrame(); }
	function panel_animation_last_frame()	{ CALL("animation_last_frame");		if(IS_RENDERING) return; PROJECT.animator.lastFrame();  }
	function panel_animation_next_frame()	{ CALL("animation_next_frame");		if(IS_RENDERING) return; PROJECT.animator.setFrame(min(PROJECT.animator.real_frame + 1, TOTAL_FRAMES - 1)); }
	function panel_animation_prev_frame()	{ CALL("animation_prev_frame");		if(IS_RENDERING) return; PROJECT.animator.setFrame(max(PROJECT.animator.real_frame - 1, 0));                }
	
	function panel_animation_delete_key()	{ CALL("animation_delete_key");	PANEL_ANIMATION.deleteKeys();   }
	function panel_animation_duplicate()	{ CALL("animation_duplicate");	PANEL_ANIMATION.doDuplicate();  }
	function panel_animation_copy()			{ CALL("animation_copy");		PANEL_ANIMATION.doCopy();       }
	function panel_animation_paste()		{ CALL("animation_paste");		PANEL_ANIMATION.doPaste(PANEL_ANIMATION.value_focusing); }
	function panel_animation_show_nodes()	{ CALL("animation_paste");		PANEL_ANIMATION.show_nodes = !PANEL_ANIMATION.show_nodes; }
#endregion

enum KEYFRAME_DRAG_TYPE {
	move,
	ease_in,
	ease_out, 
	ease_both
}

function Panel_Animation() : PanelContent() constructor {
	title		= __txt("Animation");
	context_str = "Animation";
	icon		= THEME.panel_animation_icon;
	
	#region ---- dimension ----
		timeline_h	= ui(28);
		min_w		= ui(40);
		min_h		= ui(48);
		tool_width	= ui(224);
	#endregion
	
	static initSize = function() { #region
		timeline_w = w - tool_width - ui(80);
		timeline_surface = surface_create_valid(timeline_w, timeline_h);
		timeline_mask = surface_create_valid(timeline_w, timeline_h);
		
		dope_sheet_w = w - tool_width;
		dope_sheet_h = h - timeline_h - ui(20);
		dope_sheet_surface = surface_create_valid(dope_sheet_w, 1);
		dope_sheet_mask    = surface_create_valid(dope_sheet_w, 1);
		
		dope_sheet_name_mask    = surface_create_valid(tool_width, 1);
		dope_sheet_name_surface = surface_create_valid(tool_width, 1);
	} #endregion
	initSize();
	
	#region ---- position ----
		dope_sheet_y	 = 0;
		dope_sheet_y_to  = 0;
		dope_sheet_y_max = 0;
		is_scrolling	 = false;
	
		dopesheet_dragging = noone;
		dopesheet_drag_mx  = 0;
	#endregion
	
	#region ---- timeline ----
		timeline_scubbing = false;
		timeline_scub_st  = 0;
		timeline_scale    = 20;
		timeline_separate = 5;
		timeline_sep_line = 1;
		_scrub_frame	  = -1;
	
		timeline_shift	  = 0;
		timeline_shift_to = 0;
		timeline_dragging = false;
		timeline_drag_sx  = 0;
		timeline_drag_sy  = 0;
		timeline_drag_mx  = 0;
		timeline_drag_my  = 0;
		timeline_draggable	= true;
	
		timeline_stretch	= 0;
		timeline_stretch_sx = 0;
		timeline_stretch_mx = 0;
	
		timeline_show_time	= -1;
		timeline_preview	= noone;
		
		timeline_contents = [];
		
		scroll_s = sprite_get_width(THEME.ui_scrollbar);
		scroll_w = scroll_s;
		
	#endregion
	
	#region ---- keyframes ----
		keyframe_dragging	= noone;
		keyframe_drag_type	= -1;
		keyframe_dragout	= false;
		keyframe_drag_mx	= 0;
		keyframe_drag_my	= 0;
		keyframe_selecting	= [];
	
		keyframe_boxable = true;
		keyframe_boxing	 = false;
		keyframe_box_sx	 = -1;
		keyframe_box_sy	 = -1;
		
		keyframe_graph_surface = noone;
		_graph_key_hover       = noone;
		_graph_key_hover_index = noone;
		_graph_key_hover_x     = noone;
		_graph_key_hover_y     = noone;
		graph_key_hover        = noone;
		graph_key_hover_index  = noone;
		
		graph_key_drag         = noone;
		graph_key_drag_index   = noone;
		
		graph_key_mx = 0;
		graph_key_my = 0;
		graph_key_sx = 0;
		graph_key_sy = 0;
	#endregion
	
	#region ---- values ----
		value_hovering = noone;
		value_focusing = noone;
	#endregion
	
	#region ---- display ---- 
		show_node_outside_context = true;
		show_nodes = true;
		
		tooltip_loop_prop = noone;
		tooltip_loop_type = new tooltipSelector(__txtx("panel_animation_looping_mode", "Looping mode"), global.junctionEndName);
	#endregion
	
	#region ---- item hover ----
		_item_dragging	 = noone;
		 item_dragging	 = noone;
		item_dragging_mx = noone;
		item_dragging_my = noone;
		item_dragging_dx = noone;
		item_dragging_dy = noone;
		
		hovering_folder = noone;
		hovering_order  = noone;
		
		node_name_type	  = 0;
		node_name_tooltip = new tooltipSelector("Name Display", [
			__txtx("panel_animation_name_full", "Full name"),
			__txtx("panel_animation_name_type", "Node type"),
			__txtx("panel_animation_name_only", "Node name"),
		]);
	#endregion
	
	#region ---- stagger ----
		stagger_mode  = 0;
		stagger_index = 0;
	#endregion
	
	#region ---- tools ----
		tool_width_drag  = false;
		tool_width_start = 0;
		tool_width_mx    = 0;
	#endregion
	
	on_end_dragging_anim = noone;
	
	onion_dragging = noone;
	
	prev_cache = array_create(TOTAL_FRAMES);
	
	copy_clipboard = ds_list_create();
	
	#region ++++ hotkeys ++++

		__collapse = false;
		function collapseToggle() { #region
			PANEL_ANIMATION.__collapse = !PANEL_ANIMATION.__collapse;
		
			for( var i = 0, n = array_length(PANEL_ANIMATION.timeline_contents); i < n; i++ )
				PANEL_ANIMATION.timeline_contents[i].item.show = PANEL_ANIMATION.__collapse;
		} #endregion
	
		addHotkey("",			"Play/Pause",		vk_space,	MOD_KEY.none,	panel_animation_play_pause);
		addHotkey("",			"Resume/Pause",		vk_space,	MOD_KEY.shift,	panel_animation_resume);
								
		addHotkey("",			"First frame",		vk_home,	MOD_KEY.none,	panel_animation_first_frame);
		addHotkey("",			"Last frame",		vk_end,		MOD_KEY.none,	panel_animation_last_frame);
		addHotkey("",			"Next frame",		vk_right,	MOD_KEY.none,	panel_animation_next_frame);
		addHotkey("",			"Previous frame",	vk_left,	MOD_KEY.none,	panel_animation_prev_frame);
	
		addHotkey("Animation", "Delete keys",		vk_delete,	MOD_KEY.none,	panel_animation_delete_key);
		addHotkey("Animation", "Duplicate",			"D",		MOD_KEY.ctrl,	panel_animation_duplicate);
		addHotkey("Animation", "Copy",				"C",		MOD_KEY.ctrl,	panel_animation_copy);
		addHotkey("Animation", "Paste",				"V",		MOD_KEY.ctrl,	panel_animation_paste);
		addHotkey("Animation", "Collapse Toggle",	"C",		MOD_KEY.none,	collapseToggle);
		addHotkey("Animation", "Toggle nodes",		"H",		MOD_KEY.none,	panel_animation_show_nodes);
		
		addHotkey("Animation", "Settings",			"S",		MOD_KEY.ctrl | MOD_KEY.shift,	function() { 
			var dia = dialogPanelCall(new Panel_Animation_Setting()); 
			dia.anchor = ANCHOR.none;
		});
		
		tooltip_toggle_nodes = new tooltipHotkey(__txtx("panel_animation_show_node", "Toggle node label"), "Animation", "Toggle nodes");
	#endregion
	
	#region ++++ control_buttons ++++
		tooltip_resume   = new tooltipHotkey(__txt("Resume"), "", "Resume/Pause");
		tooltip_pause    = new tooltipHotkey(__txt("Pause"),  "", "Resume/Pause");
		tooltip_fr_first = new tooltipHotkey(__txtx("panel_animation_go_to_first_frame", "Go to first frame"),  "", "First frame");
		tooltip_fr_last  = new tooltipHotkey(__txtx("panel_animation_go_to_last_frame", "Go to last frame"),    "", "Last frame");
		tooltip_fr_prev  = new tooltipHotkey(__txtx("panel_animation_previous_frame", "Previous frame"),        "", "Previous frame");
		tooltip_fr_next  = new tooltipHotkey(__txtx("panel_animation_next_frame", "Next frame"),                "", "Next frame");
	
		control_buttons = [ 
			[ 
			  function() { return __txt("Stop"); }, 
			  function() { return 4; }, 
			  function() { return PROJECT.animator.is_playing? COLORS._main_accent : COLORS._main_icon; },
			  function() { PROJECT.animator.stop(); } 
			],
			[ 
			  function() { return PROJECT.animator.is_playing? tooltip_pause : tooltip_resume; }, 
			  function() { return !PROJECT.animator.is_playing; }, 
			  function() { return PROJECT.animator.is_playing? COLORS._main_accent : COLORS._main_icon; },
			  function() { if(PROJECT.animator.is_playing) PROJECT.animator.pause(); else PROJECT.animator.resume(); } 
			],
			[ 
			  function() { return tooltip_fr_first; }, 
			  function() { return 3; }, 
			  function() { return COLORS._main_icon; },
			  function() { PROJECT.animator.firstFrame(); } 
			],
			[ 
			  function() { return tooltip_fr_last; }, 
			  function() { return 2; }, 
			  function() { return COLORS._main_icon; },
			  function() { PROJECT.animator.lastFrame(); } 
			],
			[ 
			  function() { return tooltip_fr_prev; }, 
			  function() { return 5; }, 
			  function() { return COLORS._main_icon; },
			  function() { PROJECT.animator.setFrame(PROJECT.animator.real_frame - 1); } 
			],
			[ 
			  function() { return tooltip_fr_next; }, 
			  function() { return 6; }, 
			  function() { return COLORS._main_icon; },
			  function() { PROJECT.animator.setFrame(PROJECT.animator.real_frame + 1); } 
			],
		];
	#endregion
	
	#region ++++ context menu ++++
	
	keyframe_menu = [
		
		menuItem(__txtx("panel_animation_keyframe_edit", "Edit Value..."), function() { 
			if(array_empty(keyframe_selecting)) return;
			editKeyFrame(keyframe_selecting[0]);
		}),
		
		menuItem(__txtx("panel_animation_lock_y", "Lock/Unlock Y easing"), function() { 
			for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
				var k = keyframe_selecting[i];
				k.ease_y_lock = !k.ease_y_lock;
			} 
		}),
				
		menuItemGroup(__txtx("panel_animation_ease_in", "Ease in"),  [ 
			[ [THEME.timeline_ease, 0], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_in_type = CURVE_TYPE.linear;
					k.ease_in = [0, 1];
				}
			}, __txtx("panel_animation_ease_linear", "Linear") ],
			[ [THEME.timeline_ease, 1], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_in_type = CURVE_TYPE.bezier;
					k.ease_in = [1, 1];
				}
			}, __txtx("panel_animation_ease_smooth", "Smooth") ],
			[ [THEME.timeline_ease, 2], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_in_type = CURVE_TYPE.bezier;
					k.ease_in = [1, 2];
				}
			}, __txtx("panel_animation_ease_overshoot", "Overshoot") ],
			[ [THEME.timeline_ease, 3], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_in_type = CURVE_TYPE.bezier;
					k.ease_in = [0, 0];
				}
			}, __txtx("panel_animation_ease_sharp", "Sharp") ],
			[ [THEME.timeline_ease, 4], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_in_type = CURVE_TYPE.cut;
					k.ease_in = [0, 0];
				}
			}, __txtx("panel_animation_ease_hold", "Hold") ],
		]),
		menuItemGroup(__txtx("panel_animation_ease_out", "Ease out"),  [ 
			[ [THEME.timeline_ease, 0], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_out_type = CURVE_TYPE.linear;
					k.ease_out = [0, 0];
				}
			}, __txtx("panel_animation_ease_linear", "Linear") ],
			[ [THEME.timeline_ease, 1], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_out_type = CURVE_TYPE.bezier;
					k.ease_out = [1, 0];
				}
			}, __txtx("panel_animation_ease_smooth", "Smooth") ],
			[ [THEME.timeline_ease, 2], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_out_type = CURVE_TYPE.bezier;
					k.ease_out = [1, -1];
				}
			}, __txtx("panel_animation_ease_overshoot", "Overshoot") ],
			[ [THEME.timeline_ease, 3], function() { 
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
					var k = keyframe_selecting[i];
					k.ease_out_type = CURVE_TYPE.bezier;
					k.ease_out = [0, 1];
				}
			}, __txtx("panel_animation_ease_sharp", "Sharp") ],
		]),
		-1,
		menuItemGroup(__txt("Align"),  [ 
			[ [THEME.object_halign, 0], function() { alignKeys(fa_left); } ],
			[ [THEME.object_halign, 1], function() { alignKeys(fa_center); } ],
			[ [THEME.object_halign, 2], function() { alignKeys(fa_right); } ],
		]),
		menuItem(__txtx("panel_animation_stagger", "Stagger"), function() { stagger_mode = 1; }),
		menuItem(__txtx("panel_driver", "Driver..."), function() { dialogPanelCall(new Panel_Keyframe_Driver(keyframe_selecting[0]), mouse_mx + ui(8), mouse_my + ui(8)); }),
		-1,
		menuItem(__txt("Delete"),	 function() { deleteKeys(); },				noone,			 [ "Animation", "Delete keys" ]),
		menuItem(__txt("Duplicate"), function() { doDuplicate(); },				THEME.duplicate, [ "Animation", "Duplicate" ]),
		menuItem(__txt("Copy"),		 function() { doCopy(); },					THEME.copy,		 [ "Animation", "Copy" ]),
		menuItem(__txt("Paste"),	 function() { doPaste(value_focusing); },	THEME.paste,	 [ "Animation", "Paste" ]),
	];
	
	keyframe_menu_empty = [
		menuItem(__txt("Paste"),	 function() { doPaste(value_focusing); },	THEME.paste,	 [ "Animation", "Paste" ]),
	];
	
	context_selecting_item = noone;
	context_selecting_prop = noone;
	
	name_menu_empty = [
		menuItem(__txt("New folder"), function() { 
			var _dir = new timelineItemGroup();
			PROJECT.timelines.addItem(_dir);
		},	THEME.folder_content),
		-1,
		menuItem(__txt("Expand all"), function() {
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ )
				timeline_contents[i].item.show = true;
		}),
		menuItem(__txt("Collapse all"), function() {
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ )
				timeline_contents[i].item.show = false;
		}),
	];
	
	var _clrs = COLORS.labels;
	var _item = array_create(array_length(_clrs));
	
	function setSelectingItemColor(color) { if(context_selecting_item == noone) return; context_selecting_item.item.setColor(color); }
	
	for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
		_item[i] = [ 
			[ THEME.timeline_color, i > 0, _clrs[i] ], 
			function(_data) { setSelectingItemColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
		];
	}
	
	array_push(_item, [ 
		[ THEME.timeline_color, 2 ], 
		function(_data) /*=>*/ { colorSelectorCall(context_selecting_item? context_selecting_item.item.getColor() : c_white, setSelectingItemColor); }
	]);
	
	var clr = menuItemGroup(__txt("Color"), _item);
	clr.spacing = ui(24);
	
	name_menu_item = [
		clr,
		-1,
		name_menu_empty[0],
		name_menu_empty[2],
		name_menu_empty[3],
	];
	
	name_menu_group = [
		clr,
		menuItem(__txt("Rename"), function() { context_selecting_item.item.rename(); }),
		menuItem(__txt("Delete"), function() { context_selecting_item.item.destroy(); }, THEME.cross),
		-1,
		name_menu_empty[0]
	];
	
	name_menu_prop_sep = [
		menuItem(__txtx("panel_inspector_axis_separate", "Separate axis"),	function() { context_selecting_prop.sep_axis = true; }),
		-1,
		name_menu_empty[2],
		name_menu_empty[3],
	];
	
	name_menu_prop_join = [
		menuItem(__txtx("panel_inspector_axis_combine", "Combine axis"),	function() { context_selecting_prop.sep_axis = false; }),
		-1,
		name_menu_empty[2],
		name_menu_empty[3],
	];
	
	#endregion ++++ context menu ++++
	
	function deleteKeys() {
		for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
			var k  = keyframe_selecting[i];
			k.anim.removeKey(k);
		}
		
		keyframe_selecting = [];
	}
	
	function alignKeys(halign = fa_left) { #region
		if(array_empty(keyframe_selecting)) return;
		
		var tt = 0;
		
		switch(halign) {
			case fa_left :	
				tt = 9999;
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ )
					tt = min(tt, keyframe_selecting[i].time);
				break;
			case fa_center :	
				tt = 0;
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ )
					tt += keyframe_selecting[i].time;
				tt = round(tt / array_length(keyframe_selecting));
				break;
			case fa_right :	
				tt = -9999;
				for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ )
					tt = max(tt, keyframe_selecting[i].time);
				break;
		}
		
		for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
			var k = keyframe_selecting[i];
			k.anim.setKeyTime(k, tt,, true);
		}
	} #endregion
	
	function arrangeKeys() { #region
		//keyframe_selecting = l;
	} #endregion
	
	function staggerKeys(_index, _stag) { #region
		var modified = false;
		var t = keyframe_selecting[_index].time;
		
		for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
			var k = keyframe_selecting[i];
			var _t = t + abs(i -  _index) * _stag;
			
			modified |= k.anim.setKeyTime(k, _t);
		}
		
		if(modified) UNDO_HOLDING = true;
	} #endregion
	
	function onFocusBegin() { PANEL_ANIMATION = self; }
	
	function surfaceVerify() { #region
		if(w - tool_width > 1) {
			timeline_mask    = surface_verify(timeline_mask, timeline_w, timeline_h);
			timeline_surface = surface_verify(timeline_surface, timeline_w, timeline_h);
		}
		
		dope_sheet_w = timeline_w;
		dope_sheet_h = h - timeline_h - ui(24);
		if(dope_sheet_h > ui(8)) {
			dope_sheet_mask    = surface_verify(dope_sheet_mask, dope_sheet_w, dope_sheet_h);
			dope_sheet_surface = surface_verify(dope_sheet_surface, dope_sheet_w, dope_sheet_h);
			
			dope_sheet_name_mask    = surface_verify(dope_sheet_name_mask,    tool_width, dope_sheet_h);
			dope_sheet_name_surface = surface_verify(dope_sheet_name_surface, tool_width, dope_sheet_h);
		}
	} #endregion
	
	function onResize() { #region
		initSize();
		
		surfaceVerify();
		resetTimelineMask();
	} #endregion
	
	function resetTimelineMask() { #region
		timeline_mask = surface_verify(timeline_mask, timeline_w, timeline_h);
			
		surface_set_target(timeline_mask);
		draw_clear(c_black);
		gpu_set_blendmode(bm_subtract);
		draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, timeline_w, timeline_h);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		if(dope_sheet_h > 8) {
			gpu_set_blendmode(bm_subtract);
			
			surface_set_target(dope_sheet_mask);
				draw_clear(c_black);
				draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, dope_sheet_w, dope_sheet_h);
			surface_reset_target();
			
			surface_set_target(dope_sheet_name_mask);
				draw_clear(c_black);
				draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, tool_width, dope_sheet_h);
			surface_reset_target();
			
			gpu_set_blendmode(bm_normal);
		}
	} #endregion
	resetTimelineMask();
	
	function getTimelineContentFolder(folder, _context = [], _depth = 0, _show = true) { #region
		var ind = 0;
		
		for( var i = 0, n = array_length(folder.contents); i < n; i++ ) {
			var _cont = folder.contents[i];
			if(!_cont.active) continue;
			
			var _content = {
				item:	  _cont,
				parent:   _cont.parent,
				index:    ind,
				contexts: _context,
				y: 0,
				h: 0,
				depth: _depth,
				show: _show,
			};
			
			if(is_instanceof(_cont, timelineItemGroup)) {
				_content.type = "folder";
				array_push(timeline_contents, _content);
				
				var _context_folder = array_create(array_length(_context) + 1);
				for( var j = 0, m = array_length(_context); j < m; j++ ) 
					_context_folder[j] = _context[j];
				_context_folder[m] = _content;
				
				if(item_dragging == noone || item_dragging.item != _cont)
					getTimelineContentFolder(_cont, _context_folder, _depth + 1, _show && _cont.show);
			} else if(is_instanceof(_cont, timelineItemNode)) {
				var _node = _cont.node;
				if(!is_struct(_node)) continue;
				
				var _anim = [];
				var _prop = [];
				
				for( var j = 0, m = array_length(_node.inputs); j < m; j++ ) {
					var prop = _node.inputs[j];
					if(!prop.isTimelineVisible()) continue;
					
					var anim = prop.sep_axis? prop.animators : [ prop.animator ];
					if(prop.sep_axis) array_append(_anim, prop.animators);
					else			  array_push(_anim, prop.animator);
				
					array_push(_prop, { prop, animators: anim, y: 0 });
				}
				
				_content.type  = "node";
				_content.node  = _node;
				_content.props = _prop;
				_content.animators = _anim;
				
				array_push(timeline_contents, _content);
			}
			
			if(item_dragging == noone || item_dragging.item != _cont) ind++;
		}
	} #endregion
	
	function getTimelineContent() { #region
		timeline_contents = [];
		getTimelineContentFolder(PROJECT.timelines);
	} #endregion
	
	function drawTimeline() { #region // Draw summary
		var bar_x = tool_width + ui(16);
		var bar_y = h - timeline_h - ui(10);
		var bar_w = timeline_w;
		var bar_h = timeline_h;
		var bar_total_w = TOTAL_FRAMES * timeline_scale;
		var inspecting = PANEL_INSPECTOR.getInspecting();
		
		resetTimelineMask();
		timeline_surface = surface_verify(timeline_surface, timeline_w, timeline_h);
			
		surface_set_target(timeline_surface);	
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
			
		#region bg
			draw_sprite_stretched(THEME.ui_panel_bg, 1, 0, 0, bar_w, bar_h);
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 2, 0, 0, bar_w, bar_h, COLORS.panel_animation_timeline_blend, 1);
		#endregion
		
		#region cache
			if(inspecting && inspecting.use_cache) {
				for(var i = 0; i < TOTAL_FRAMES; i++) {
					if(i >= array_length(inspecting.cache_result)) 
						break;
						
					var x0 = (i + 0) * timeline_scale + timeline_shift;
					var x1 = (i + 1) * timeline_scale + timeline_shift;
					
					draw_set_color(inspecting.getAnimationCacheExist(i)? c_lime : c_red);
					draw_set_alpha(0.05);
					draw_rectangle(x0, 0, x1, bar_h, false);
					draw_set_alpha(1);
				}
			}
		#endregion
		
		#region lines
			if(inspecting)
				inspecting.drawAnimationTimeline(timeline_shift, bar_w, bar_h, timeline_scale);
			
			var _fr = ceil((bar_w / timeline_scale - timeline_shift) / timeline_separate) * timeline_separate;
			
			for(var i = timeline_separate; i <= _fr; i += timeline_separate) {
				var bar_line_x = i * timeline_scale + timeline_shift;
				
				if(i > TOTAL_FRAMES) draw_set_alpha(0.5);
				
				draw_set_color(COLORS.panel_animation_frame_divider);
				draw_line(bar_line_x, ui(12), bar_line_x, bar_h - PANEL_PAD);
					
				draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text_sub);
				draw_text_add(bar_line_x, ui(16), string(i));
			}
				
			draw_set_alpha(1);
			
			var bar_line_x = TOTAL_FRAMES * timeline_scale + timeline_shift;
			draw_set_color(COLORS.panel_animation_end_line);
			draw_set_alpha(0.5);
			draw_line_width(bar_line_x, 0, bar_line_x, bar_h, 2);
			draw_set_alpha(1.0);
			
			if(FRAME_RANGE != noone) {
				var _fr_x0 = FRAME_RANGE[0] * timeline_scale + timeline_shift - 6;
				var _fr_x1 = FRAME_RANGE[1] * timeline_scale + timeline_shift + 2;
				
				if(PROJECT.animator.is_simulating)
					draw_sprite_stretched_ext(THEME.ui_selection_range_sim_hori, 0, _fr_x0, 0, _fr_x1 - _fr_x0, bar_h, COLORS.panel_animation_range_sim, 1);
				else
					draw_sprite_stretched_ext(THEME.ui_selection_range_hori, 0, _fr_x0, 0, _fr_x1 - _fr_x0, bar_h, COLORS.panel_animation_range, 1);
			}
			
			var bar_line_x = (CURRENT_FRAME + 1) * timeline_scale + timeline_shift;
			var cc = PROJECT.animator.is_playing? COLORS._main_value_positive : COLORS._main_accent;
			draw_set_color(cc);
			draw_line(bar_line_x, ui(15), bar_line_x, bar_h - PANEL_PAD);
			
			draw_set_text(f_p2, fa_center, fa_bottom, cc);
			draw_text_add(bar_line_x, ui(16), string(CURRENT_FRAME + 1));
		#endregion
			
		#region summary \\\ Set X for all keyframes
			var index = 0;
			var key_y = ui(12) + (bar_h - ui(12)) / 2;
				
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
				var _cont  = timeline_contents[i];
				if(_cont.type != "node") continue;
				
				var _anims = _cont.animators;
				
				for( var j = 0, m = array_length(_anims); j < m; j++ ) {
					var _anim = _anims[j];
					
					for(var k = 0; k < array_length(_anim.values); k++) {
						var _keyframe = _anim.values[k];
						
						var t = (_keyframe.time + 1) * timeline_scale + timeline_shift;
						_keyframe.dopesheet_x = t;
						
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 0, t, key_y, 1, COLORS.panel_animation_keyframe_hide);
					}
				}
			}
		#endregion
			
		#region pan zoom
			timeline_shift = lerp_float(timeline_shift, timeline_shift_to, 4);
				
			if(timeline_scubbing) {
				var rfrm = (mx - bar_x - timeline_shift) / timeline_scale - 1;
				PROJECT.animator.setFrame(clamp(rfrm, 0, TOTAL_FRAMES - 1), !key_mod_press(ALT));
				timeline_show_time  = CURRENT_FRAME;
					
				if(timeline_show_time != _scrub_frame) {
					_scrub_frame = timeline_show_time;
				}
					
				if(mouse_release(mb_left))
					timeline_scubbing = false;
			}
			
			if(timeline_dragging) {
				timeline_shift_to = clamp(timeline_drag_sx + mx - timeline_drag_mx, -max(bar_total_w - bar_w + 32, 0), 0);
				timeline_shift = timeline_shift_to;
				dope_sheet_y_to = clamp(timeline_drag_sy + my - timeline_drag_my, -dope_sheet_y_max, 0);
					
				if(mouse_release(mb_middle))
					timeline_dragging = false;
			}
		#endregion
		
		gpu_set_blendmode(bm_subtract);
		draw_surface_safe(timeline_mask);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		draw_surface_safe(timeline_surface, bar_x, bar_y);
		
		#region mouse interact
			var bar_line_w = TOTAL_FRAMES * timeline_scale + timeline_shift;
			var bar_int_x  = min(bar_x + bar_w, bar_x + bar_line_w);
			
			if(pHOVER && point_in_rectangle(mx, my, bar_x, 16, bar_x + bar_w, bar_y - 8)) {
				var sca = timeline_scale;
				
				if(mouse_wheel_down()) timeline_scale = max(timeline_scale - 1 * SCROLL_SPEED, 1);
				if(mouse_wheel_up())   timeline_scale = min(timeline_scale + 1 * SCROLL_SPEED, 24);
				
				timeline_separate = 5;
				timeline_sep_line = 1;
				
					 if(timeline_scale <=  1) { timeline_separate =  50; timeline_sep_line = 10; }
				else if(timeline_scale <=  3) { timeline_separate =  20; timeline_sep_line =  5; }
				else if(timeline_scale <= 10) { timeline_separate =  10; timeline_sep_line =  2; }
				
				if(sca != timeline_scale) {
					var mfb = (mx - bar_x - timeline_shift) / timeline_scale;
					var mfa = (mx - bar_x - timeline_shift) / ui(sca);
					
					timeline_shift_to = clamp(timeline_shift_to - (mfa - mfb) * timeline_scale, -max(bar_total_w - bar_w + 32, 0), 0);
					timeline_shift = timeline_shift_to;
				}
						
				if(mx < bar_int_x && mouse_press(mb_middle, pFOCUS)) {
					timeline_dragging = true;
					
					timeline_drag_sx = timeline_shift;
					timeline_drag_sy = dope_sheet_y_to;
					timeline_drag_mx = mx;
					timeline_drag_my = my;
				}
			}
			
			if(pHOVER && point_in_rectangle(mx, my, bar_x, bar_y, bar_x + bar_w, bar_y + bar_h)) { //preview
				if(mouse_wheel_down()) timeline_shift_to = clamp(timeline_shift_to - 64 * SCROLL_SPEED, -max(bar_total_w - bar_w + 32, 0), 0);
				if(mouse_wheel_up())   timeline_shift_to = clamp(timeline_shift_to + 64 * SCROLL_SPEED, -max(bar_total_w - bar_w + 32, 0), 0);
						
				if(mx < bar_int_x && mouse_press(mb_left, pFOCUS)) {
					timeline_scubbing = true;
					timeline_scub_st  = CURRENT_FRAME;
					_scrub_frame = timeline_scub_st;
				}
						
				if(mouse_press(mb_right, pFOCUS)) {
					__selecting_frame = clamp(round((mx - bar_x - timeline_shift) / timeline_scale), 0, TOTAL_FRAMES - 1);
					
					menuCall("animation_summary_menu",,, [
						menuItem(__txtx("panel_animation_range_start", "Set start"),	function() { if(FRAME_RANGE == noone) FRAME_RANGE = [ __selecting_frame, TOTAL_FRAMES ]; else FRAME_RANGE[0] = __selecting_frame; }, [ THEME.frame_range, 0 ]),
						menuItem(__txtx("panel_animation_range_end",   "Set end"),		function() { if(FRAME_RANGE == noone) FRAME_RANGE = [ 0, __selecting_frame ];            else FRAME_RANGE[1] = __selecting_frame; }, [ THEME.frame_range, 1 ]),
						menuItem(__txtx("panel_animation_range_reset", "Reset range"),	function() { FRAME_RANGE = noone; }),
					]);
				}
			}
					
			if(pHOVER && point_in_rectangle(mx, my, bar_x, 8, bar_x + bar_w, 8 + 16)) { //top bar
				if(mx < bar_int_x && mouse_press(mb_left, pFOCUS) && timeline_draggable) {
					timeline_scubbing = true;
					timeline_scub_st  = CURRENT_FRAME;
					_scrub_frame = timeline_scub_st;
				}
			}
			
			timeline_draggable	= true;
		#endregion
	} #endregion
	
	function __drawDopesheetGraphLine(animator, key_y, msx, msy, _gy_val_min = 999999, _gy_val_max = -999999) { 
		var bar_total_w = TOTAL_FRAMES * timeline_scale;
		var bar_show_w  = timeline_shift + bar_total_w;
		var hovering	= noone;
		
		var _gh  = animator.prop.graph_h - ui(16);
		var _gy0 = key_y + ui(8);
		var _gy1 = _gy0 + _gh;
		
		var amo = array_length(animator.values);
		
		#region get range
			var _prevDelt = [ 0, 0 ];
			
			for(var k = 0; k < amo; k++) { 
				var key     = animator.values[k];
				var key_val = key.value;
				
				var _minn = _gy_val_min;
				var _maxx = _gy_val_max;
				
				if(is_array(key_val)) {
					for( var ki = 0; ki < array_length(key_val); ki++ ) {
						_minn = min(_minn, key_val[ki]);
						_maxx = max(_maxx, key_val[ki]);
					}
				} else {
					_minn = min(_minn, key_val);
					_maxx = max(_maxx, key_val);
				}
				
				_minn += _prevDelt[0];
				_maxx += _prevDelt[1];
				_prevDelt = [ 0, 0 ];
				
				switch(key.drivers.type) {
					case DRIVER_TYPE.linear :
						var nk = k + 1 < amo? animator.values[k + 1].time : TOTAL_FRAMES;
					
						var spd = key.drivers.speed * (nk - key.time);
						_minn += min(spd, 0);
						_maxx += max(spd, 0);
						_prevDelt = [ min(spd, 0), max(spd, 0) ];
						break;
					case DRIVER_TYPE.wiggle :
					case DRIVER_TYPE.sine   :
						_minn -= abs(key.drivers.amplitude);
						_maxx += abs(key.drivers.amplitude);
						_prevDelt = [ -key.drivers.amplitude, key.drivers.amplitude ];
						break;
				}
				
				_gy_val_min = min(_minn, _gy_val_min);
				_gy_val_max = max(_maxx, _gy_val_max);
			}
		#endregion
		
		var valArray = is_array(animator.values[0].value);
		var ox  = 0;
		var nx  = 0;
		var ny  = noone;
		
		var oly = 0;
		var nly = 0;
		var _kv, _kn;
		var sy;
		
		var _oy  = animator.values[0].value;
		if(!valArray) _oy = [ _oy ];
		
		var oy = array_create(array_length(_oy));
		for( var ki = 0; ki < array_length(_oy); ki++ ) 
			oy[ki] = value_map(_oy[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
		
		for(var k = 0; k < amo - 1; k++) { // draw line in between
			var key      = animator.values[k];
			var t        = key.dopesheet_x;
			var key_next = animator.values[k + 1];
			var dx       = key_next.time - key.time;
			
			if(key.drivers.type) { // driver
				nx = (key.time + 1) * timeline_scale + timeline_shift;
					
				for( var _time = key.time; _time <= key_next.time; _time++ ) {
					var rat  = (_time - key.time) / (key_next.time - key.time);
					var _lrp = animator.interpolate(key, key_next, rat);
					
					_kv = animator.processDriver(_time, key, animator.lerpValue(key, key_next, _lrp), rat);
					
					if(!valArray) _kv = [ _kv ];
						
					for( var ki = 0; ki < array_length(_kv); ki++ ) {
						var cc = COLORS.panel_animation_graph_line;
						if(valArray)					cc = array_safe_get(COLORS.axis, ki, cc);
						else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
						
						cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
						__draw_set_color(cc);
						
						ny[ki] = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
						
						if(_time == key.time) draw_line(nx, oy[ki], nx, ny[ki]);
						else                  draw_line(ox, oy[ki], nx, ny[ki]);
							
						oy[ki] = ny[ki];
					}
					
					ox  = nx;
					nx += timeline_scale;
				}
			} else if(key.ease_out_type == CURVE_TYPE.linear && key_next.ease_in_type == CURVE_TYPE.linear) { //linear draw
				nx  = (key_next.time + 1) * timeline_scale + timeline_shift;
				
				_kv = key.value;
				_kn = key_next.value;
				
				if(!valArray) {
					_kv = [ _kv ];
					_kn = [ _kn ];
				}
				
				for( var ki = 0; ki < array_length(_kv); ki++ ) {
					var cc = COLORS.panel_animation_graph_line;
					if(valArray)                    cc = array_safe_get(COLORS.axis, ki, cc);
					else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
					
					cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
					__draw_set_color(cc);
					
					ny[ki] = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
					
					if(array_length(oy) > ki) draw_line(t, oy[ki], t, ny[ki]);
					oy[ki] = ny[ki];
					
					ny[ki] = value_map(_kn[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
					draw_line(t, oy[ki], nx, ny[ki]);
					oy[ki] = ny[ki];
				}
				
				ox = nx;
			} else { //bezier easing
				var _step = 1 / dx;
				for( var _r = 0; _r <= 1; _r += _step ) {
					nx  = t + _r * dx * timeline_scale;
					nly = animator.interpolate(key, key_next, _r);
					
					_kv = key.value;
					_kn = key_next.value;
				
					if(!valArray) {
						_kv = [ _kv ];
						_kn = [ _kn ];
					}
				
					for( var ki = 0; ki < array_length(_kv); ki++ ) {
						var cc = COLORS.panel_animation_graph_line;
						if(valArray)					cc = array_safe_get(COLORS.axis, ki, cc);
						else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
						
						cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
						__draw_set_color(cc);
						
						ny[ki] = value_map(lerp(_kv[ki], _kn[ki], nly), _gy_val_min, _gy_val_max, _gy1, _gy0);
						
						if(array_length(oy) > ki) draw_line(ox, oy[ki], nx, ny[ki]);
							
						oy[ki] = ny[ki];
					}
					
					ox = nx;
					oly = nly;
				}
			}
		} // draw line in between
		
		if(animator.prop.show_graph && array_length(animator.values) > 0) { // draw line outside keyframe range
			var key_first = animator.values[0];
			var t_first  = (key_first.time + 1) * timeline_scale + timeline_shift;
			
			_kv = key_first.value;
			if(!valArray) _kv = [ _kv ];
				
			for( var ki = 0; ki < array_length(_kv); ki++ ) {
				var cc = COLORS.panel_animation_graph_line;
				if(valArray)					cc = array_safe_get(COLORS.axis, ki, cc);
				else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
					
				cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
				__draw_set_color(cc);
				
				sy = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
				draw_line(0, sy, t_first, sy);
					
				if(array_length(animator.values) == 1) oy[ki] = sy;
			}
				
			var key_last = animator.values[array_length(animator.values) - 1];
			var t_last = (key_last.time + 1) * timeline_scale + timeline_shift;
				
			if(key_last.time < TOTAL_FRAMES) {
				if(key_last.drivers.type) {
					nx = t_last;
					
					for( var _time = key_last.time; _time < TOTAL_FRAMES; _time++ ) {
						_kv = animator.processDriver(_time, key_last);
						if(!valArray) _kv = [ _kv ];
						
						for( var ki = 0; ki < array_length(_kv); ki++ ) {
							var cc = COLORS.panel_animation_graph_line;
							if(valArray)					cc = array_safe_get(COLORS.axis, ki, cc);
							else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
							
							cc = colorMultiplyRGB(cc, CDEF.main_ltgrey);
							__draw_set_color(cc);
							
							ny[ki] = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
							if(_time == key_last.time)
								draw_line(t_last, oy[ki], t_last, ny[ki]);
							else 
								draw_line(ox, oy[ki], nx, ny[ki]);
							
							oy[ki] = ny[ki];
						}
						
						ox  = nx;
						nx += timeline_scale;
					}
				} else {
					_kv = key_last.value;
					if(!valArray) _kv = [ _kv ];
					
					for( var ki = 0; ki < array_length(_kv); ki++ ) {
						var cc = COLORS.panel_animation_graph_line;
						if(valArray)					cc = array_safe_get(COLORS.axis, ki, cc);
						else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
						
						cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
						__draw_set_color(cc);
						
						ny[ki] = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
						draw_line(t_last, oy[ki], t_last, ny[ki]);
						draw_line(t_last, ny[ki], bar_show_w, ny[ki]);
					}
				}
			}
		} // draw line outside keyframe range
		
		#region // draw key
			
			for(var i = 0; i < amo; i++) { 
				var key = animator.values[i];
				var px  = key.dopesheet_x;
				
				var v   = key.value;
				if(!valArray) v = [ v ];
				
				var ei = key.ease_in;
				var eo = key.ease_out;
				
				var ix = px - ei[0] * timeline_scale * 2;
				var ox = px + eo[0] * timeline_scale * 2;
				
				for (var j = 0, m = array_length(v); j < m; j++) {
					var py  = value_map(v[j], _gy_val_min, _gy_val_max, _gy1, _gy0);
					var iy = py + (1 - ei[1]) * timeline_scale * 2;
					var oy = py - (    eo[1]) * timeline_scale * 2;
					
					var cc = COLORS.panel_animation_graph_line;
					if(valArray)					cc = array_safe_get(COLORS.axis, j, cc);
					else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
					
					if(ei[0] != 0) {
						var _hv = (graph_key_hover == key && ( graph_key_hover_index == KEYFRAME_DRAG_TYPE.ease_in || graph_key_hover_index == KEYFRAME_DRAG_TYPE.ease_both)) || 
						          (graph_key_drag  == key && ( graph_key_drag_index  == KEYFRAME_DRAG_TYPE.ease_in || graph_key_drag_index  == KEYFRAME_DRAG_TYPE.ease_both));
						
						draw_set_color(_hv? COLORS._main_accent : cc);
						draw_line(ix, iy, px, py);
						draw_circle(ix, iy, 3, false);
						
						if(point_in_circle(msx, msy, ix, iy, 4)) {
							_graph_key_hover       = key;
							_graph_key_hover_index = KEYFRAME_DRAG_TYPE.ease_in;
							
							_graph_key_hover_x = px;
							_graph_key_hover_y = py;
						}
					}
					
					if(eo[0] != 0) {
						var _hv = (graph_key_hover == key && (graph_key_hover_index == KEYFRAME_DRAG_TYPE.ease_out || graph_key_hover_index == KEYFRAME_DRAG_TYPE.ease_both)) || 
						          (graph_key_drag  == key && (graph_key_drag_index  == KEYFRAME_DRAG_TYPE.ease_out || graph_key_drag_index  == KEYFRAME_DRAG_TYPE.ease_both));
						
						draw_set_color(_hv? COLORS._main_accent : cc);
						draw_line(px, py, ox, oy);
						draw_circle(ox, oy, 3, false);
						
						if(point_in_circle(msx, msy, ox, oy, 4)) {
							_graph_key_hover       = key;
							_graph_key_hover_index = KEYFRAME_DRAG_TYPE.ease_out;
							
							_graph_key_hover_x = px;
							_graph_key_hover_y = py;
						}
					}
					
					var _hv = (graph_key_hover == key && graph_key_hover_index == KEYFRAME_DRAG_TYPE.move) || 
					          (graph_key_drag  == key && graph_key_drag_index  == KEYFRAME_DRAG_TYPE.move);
					
					draw_set_color(_hv? COLORS._main_accent : cc);
					draw_circle(px, py, 4, false);
					
					if(point_in_circle(msx, msy, px, py, 5)) {
						_graph_key_hover       = key;
						_graph_key_hover_index = KEYFRAME_DRAG_TYPE.move;
						
						_graph_key_hover_x = px;
						_graph_key_hover_y = py;
					}
				}
				
			}
		#endregion // draw key
	}
	
	function _drawDopesheetGraph(prop, key_y, msx, msy) {
		var bar_total_w = TOTAL_FRAMES * timeline_scale;
		var bar_show_w  = timeline_shift + bar_total_w;
		
		if(prop.type == VALUE_TYPE.color) { // draw color
			
			var _gy0 = key_y - ui(4);
			var _gy1 = key_y + ui(4);
			
			var amo = array_length(prop.animator.values);
			var _prevKey = prop.animator.values[0];
			
			draw_set_color(_prevKey.value);
			draw_rectangle(0, _gy0, _prevKey.dopesheet_x, _gy1, 0);
			
			var ox, nx, oc, nc;
			
			for(var k = 0; k < amo - 1; k++) {
				var key      = prop.animator.values[k];
				var key_next = prop.animator.values[k + 1];
				var dx		 = key_next.time - key.time;
				var _step	 = 1 / dx;
				
				for( var _r = 0; _r <= 1; _r += _step ) {
					nx = key.dopesheet_x + _r * dx * timeline_scale;
					var lrp = prop.animator.interpolate(key, key_next, _r);
					nc = merge_color(key.value, key_next.value, lrp);
					
					if(_r > 0) draw_rectangle_color(ox, _gy0, nx, _gy1, oc, nc, nc, oc, 0);
						
					ox = nx;
					oc = nc;
				}
			}
			
			key_next = prop.animator.values[array_length(prop.animator.values) - 1];
			if(key_next.time < TOTAL_FRAMES) {
				draw_set_color(key_next.value);
				draw_rectangle(key_next.dopesheet_x, _gy0, bar_show_w, _gy1, 0);
			}
			return;
		}
		
		var bar_x = tool_width + ui(16);
		var bar_y = h - timeline_h - ui(10);
		var bar_w = timeline_w;
		var bar_h = timeline_h;
		var bar_total_w = TOTAL_FRAMES * timeline_scale;
		
		var _gh  = prop.graph_h;
		var _gy0 = key_y + ui(8);
		var _gy1 = _gy0 + _gh;
			
		if(point_in_rectangle(msx, msy, 0, _gy0, w, _gy1))
			keyframe_boxable = false;
		
		var _fr = ceil((bar_w / timeline_scale - timeline_shift) / timeline_separate) * timeline_separate;
		var _mmx = msx - 0;
		var _mmy = msy - _gy0;
		
		keyframe_graph_surface = surface_verify(keyframe_graph_surface, w, _gh);
		surface_set_target(keyframe_graph_surface);
			draw_clear(COLORS.panel_animation_timeline_top);
			
			for(var i = timeline_sep_line; i <= _fr; i += timeline_sep_line) {
				var bar_line_x = i * timeline_scale + timeline_shift;
				
				draw_set_color(COLORS.panel_animation_frame_divider);
				draw_set_alpha((i % timeline_separate == 0? 1 : 0.1) * ((i <= TOTAL_FRAMES) * 0.5 + 0.5) * 0.3);
				draw_line(bar_line_x, 0, bar_line_x, _gh - PANEL_PAD);
			}
			draw_set_alpha(1);
			
			var bar_line_x = TOTAL_FRAMES * timeline_scale + timeline_shift;
			draw_set_color(COLORS.panel_animation_end_line);
			draw_set_alpha(0.5);
			draw_line_width(bar_line_x, 0, bar_line_x, _gh, 2);
			draw_set_alpha(1);
			
			if(prop.sep_axis) { // draw number graphs
				var _min =  999999;
				var _max = -999999;
				
				for( var i = 0, n = array_length(prop.animators); i < n; i++ ) {
					if(!prop.show_graphs[i]) continue;
					
					var animator = prop.animators[i];
					for(var k = 0; k < array_length(animator.values); k++) {
						var key_val = animator.values[k].value;
						if(is_array(key_val)) {
							for( var ki = 0; ki < array_length(key_val); ki++ ) {
								_min = min(_min, key_val[ki]);
								_max = max(_max, key_val[ki]);
							}
						} else {
							_min = min(_min, key_val);
							_max = max(_max, key_val);
						}
					}
				}
				
				for( var i = 0, n = array_length(prop.animators); i < n; i++ ) {
					if(!prop.show_graphs[i]) continue;
					
					__drawDopesheetGraphLine(prop.animators[i], 0, _mmx, _mmy, _min, _max);
				}
			} else
				__drawDopesheetGraphLine(prop.animator, 0, _mmx, _mmy);
		surface_reset_target();
		
		draw_surface(keyframe_graph_surface, 0, _gy0);
		
	}
	
	function editKeyFrame(keyframe, _x = mouse_mx + ui(8), _y = mouse_my + ui(8)) {
		var _prop = keyframe.anim.prop;
		var _wid  = _prop.editWidget;
		__keyframe_editing = keyframe;
		
		switch(_prop.type) {
			case VALUE_TYPE.color : 
				switch(_prop.display_type) {
					case VALUE_DISPLAY.palette : 
						var dialog = dialogCall(o_dialog_palette, WIN_W / 2, WIN_H / 2);
						dialog.setDefault(keyframe.value);
						dialog.onApply      = function(val) { __keyframe_editing.value = val; };
						dialog.drop_target  = _wid;
						break;
					
					default :
						var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
						dialog.setDefault(keyframe.value);
						dialog.selector.onApply = function(val) { __keyframe_editing.value = val; };
						dialog.onApply          = function(val) { __keyframe_editing.value = val; };
						dialog.drop_target      = _wid;
				}
				break;
			
			case VALUE_TYPE.gradient : 
				var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2);
				dialog.setDefault(keyframe.value.clone());
				dialog.onApply      = function(val) { __keyframe_editing.value = val; };
				dialog.drop_target  = _wid;
				break;
				
			default : 
				dialogCall(o_dialog_value_editor, _x, _y).setKey(keyframe);
		}
	}
	
	function _drawDopesheetAnimatorKeysBG(animator, msx, msy) { #region
		var prop_dope_y = animator.y;
		var key_hover   = noone;
		var key_list    = animator.values;
		
		if((animator.prop.on_end == KEYFRAME_END.loop || animator.prop.on_end == KEYFRAME_END.ping) && ds_list_size(key_list) > 1) {
			var keyframe_s = animator.prop.loop_range == -1? key_list[| 0].time : key_list[| ds_list_size(key_list) - 1 - animator.prop.loop_range].time;
			var keyframe_e = key_list[| ds_list_size(key_list) - 1].time;
								
			var ks_x = (keyframe_s + 1) * timeline_scale + timeline_shift;
			var ke_x = (keyframe_e + 1) * timeline_scale + timeline_shift;
						
			draw_set_color(COLORS.panel_animation_loop_line);
			draw_set_alpha(0.2);
			draw_line_width(ks_x, prop_dope_y - 1, ke_x, prop_dope_y - 1, 4);
			draw_set_alpha(1);
		}
		
		for( var k = 0; k < ds_list_size(key_list); k++ ) { //draw easing
			var key = key_list[| k];
			var t   = key.dopesheet_x;
						
			if(key.ease_in_type == CURVE_TYPE.bezier) {
				draw_set_color(COLORS.panel_animation_keyframe_ease_line);
				var _tx = t - key.ease_in[0] * timeline_scale * 2;
				draw_line_width(_tx, prop_dope_y - 1, t, prop_dope_y - 1, 2);
											
				if(pHOVER && point_in_circle(msx, msy, _tx, prop_dope_y, ui(6))) {
					key_hover = key;
					draw_sprite_ui_uniform(THEME.timeline_key_ease, 0, _tx, prop_dope_y, 1, COLORS.panel_animation_keyframe_selected);
					if(mouse_press(mb_left, pFOCUS) && !key_mod_press(SHIFT)) {
						keyframe_dragging  = animator.values[k];
						keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_in;
					}
				} else 
					draw_sprite_ui_uniform(THEME.timeline_key_ease, 0, _tx, prop_dope_y, 1, COLORS.panel_animation_keyframe_unselected);
			} 
						
			if(key.ease_out_type == CURVE_TYPE.bezier) {
				draw_set_color(COLORS.panel_animation_keyframe_ease_line);
				var _tx = t + key.ease_out[0] * timeline_scale * 2;
				draw_line_width(t, prop_dope_y - 1, _tx, prop_dope_y - 1, 2);
										
				if(pHOVER && point_in_circle(msx, msy, _tx, prop_dope_y, ui(6))) {
					key_hover = key;
					draw_sprite_ui_uniform(THEME.timeline_key_ease, 1, _tx, prop_dope_y, 1, COLORS.panel_animation_keyframe_selected);
					if(mouse_press(mb_left, pFOCUS) && !key_mod_press(SHIFT)) {
						keyframe_dragging  = animator.values[k];
						keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_out;
					}
				} else
					draw_sprite_ui_uniform(THEME.timeline_key_ease, 1, _tx, prop_dope_y, 1, COLORS.panel_animation_keyframe_unselected);
			}
		}
		
		return key_hover;
	} #endregion
	
	__keyframe_editing = noone;
	
	function _drawDopesheetAnimatorKeys(_cont, animator, msx, msy) { #region 
		var _node     = _cont.node;
		var prop_y	  = animator.y;
		var node_y	  = _cont.y;
		var anim_set  = true;
		var key_hover = noone;
		
		for(var k = 0; k < array_length(animator.values); k++) {
			var keyframe = animator.values[k];
			var t = keyframe.dopesheet_x;
			
			for( var j = 0, n = array_length(_cont.contexts); j < n; j++ ) {
				var _cxt = _cont.contexts[j];
				if(!_cxt.show) continue;
				draw_sprite_ui_uniform(THEME.timeline_key_empty, 0, t, _cxt.y + ui(10), 1, COLORS._main_icon);
			}
			
			if(!_cont.show)      continue;
			draw_sprite_ui_uniform(THEME.timeline_key_empty, 0, t, node_y + ui(10), 1, COLORS._main_icon);
			
			if(!_cont.item.show) continue;
			
			var cc = COLORS.panel_animation_keyframe_unselected;
			if(on_end_dragging_anim == animator.prop && msx < t && anim_set) {
				if(k == 0)
					animator.prop.loop_range = -1;
				else
					animator.prop.loop_range = array_length(animator.values) - k;
				anim_set = false;
			}
			
			if(pHOVER && point_in_circle(msx, msy, t, prop_y, ui(8))) {
				cc = COLORS.panel_animation_keyframe_selected;
				key_hover = keyframe;
				if(!instance_exists(o_dialog_menubox))
					TOOLTIP = [ keyframe.value, animator.prop.type ];
									
				if(pFOCUS && !key_mod_press(SHIFT)) {
					if(DOUBLE_CLICK) {
						keyframe_dragging = keyframe;
						keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_both;
						keyframe_dragout = false;
						keyframe_drag_mx = mx;
						keyframe_drag_my = my;
						
					} else if(mouse_press(mb_left)) {
						if(key_mod_press(CTRL)) {
							editKeyFrame(keyframe);
							
						} else {
							keyframe_dragging = keyframe;
							keyframe_drag_type = KEYFRAME_DRAG_TYPE.move;
							keyframe_drag_mx = mx;
							keyframe_drag_my = my;
						}
					}
				}
			}
			
			if(stagger_mode == 1 && array_exists(keyframe_selecting, keyframe))
				cc = key_hover == keyframe? COLORS.panel_animation_keyframe_selected : COLORS._main_accent;
			
			var ind = keyframe.getDrawIndex();
			draw_sprite_ui_uniform(THEME.timeline_keyframe, ind, t, prop_y, 1, cc);
			
			if(array_exists(keyframe_selecting, keyframe)) 
				draw_sprite_ui_uniform(THEME.timeline_keyframe_selecting, ind, t, prop_y, 1, COLORS._main_accent);
						
			if(keyframe_boxing) {
				var box_x0 = min(keyframe_box_sx, msx);
				var box_x1 = max(keyframe_box_sx, msx);
				var box_y0 = min(keyframe_box_sy, msy);
				var box_y1 = max(keyframe_box_sy, msy);
									
				if(pHOVER && !point_in_rectangle(t, prop_y, box_x0, box_y0, box_x1, box_y1) && array_exists(keyframe_selecting, keyframe))
					array_remove(keyframe_selecting, keyframe);
				if(pHOVER && point_in_rectangle(t, prop_y, box_x0, box_y0, box_x1, box_y1) && !array_exists(keyframe_selecting, keyframe))
					array_push(keyframe_selecting, keyframe);
			}
		}
		
		return key_hover;
	} #endregion
	
	function __drawDopesheetLabelAnimator(_item, _node, animator, msx, msy) { #region
		var prop = animator.prop;
		var aa   = _node.group == PANEL_GRAPH.getCurrentContext()? 1 : 0.9;
		var tx   = tool_width;
		var ty   = animator.y - 1;
		
		var hov = item_dragging == noone && pHOVER && point_in_rectangle(msx, msy, 0, ty - ui(8), w - ui(64), ty + ui(8));
		
		//// DRAW NAME
		var cc = prop.sep_axis? COLORS.axis[animator.index] : COLORS._main_text_sub;
		if(hov) cc = COLORS._main_text_accent;
		
		draw_set_color(CDEF.main_mdblack);
		draw_rectangle(ui(32), ty - ui(8), tool_width, ty + ui(8), false);
		
		draw_set_color(cc);
		
		var _title_x = ui(32);
		if(!show_nodes) {
			var _txt = animator.prop.node.getDisplayName();
			
			draw_set_alpha(aa * 0.5);
			draw_text_add(_title_x, ty - 2, _txt);
			_title_x += string_width(_txt) + ui(4);
		}
		
		var _txt = animator.getName();
		draw_set_alpha(aa);
		draw_text_add(_title_x, ty - 2, _txt);
		draw_set_alpha(1);
		_title_x += string_width(_txt) + ui(4);
		
		if(hov) {
			value_hovering = prop;
			if(mouse_click(mb_left, pFOCUS))
				value_focusing = prop;
				
			if(mouse_press(mb_right, pFOCUS)) {
				context_selecting_prop = prop;
				context_selecting_item = _item;
			}
		}
		
		var _gx = ui(20);
		var _gy = ty;
		if(hov)
		if(buttonInstant(noone, _gx - ui(10), _gy - ui(9), ui(20), ui(17), [msx, msy], pFOCUS, pHOVER, "", THEME.animate_prop_go, 0, [COLORS._main_icon, COLORS._main_icon_on_inner], 0.75) == 2) {
			graphFocusNode(_node);
			PANEL_INSPECTOR.highlightProp(prop);
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var _tool_a = 0.5 + hov * 0.5;
		
		var _on_end_disp = prop.on_end || hov;
		var _tool_x0 = tool_width - ui(20 + 16 * (3 + _on_end_disp * 1.5) + 12);
		var _tool_x1 = tool_width;
		draw_set_color(c_white);
		BLEND_SUBTRACT
		draw_rectangle(_tool_x0, ty - ui(8), _tool_x1, ty + ui(8), false);
		BLEND_NORMAL
		
		var _graph_show = prop.sep_axis? prop.show_graphs[animator.index] : prop.show_graph;
		
		if(_graph_show) {
			var _y1 = ty + ui(10) + prop.graph_h + ui(8);
			var c1  = colorMultiply(_item.item.color_cur, COLORS.panel_animation_dope_key_bg_hover);
			draw_set_color(c1);
			draw_rectangle(0, ty + ui(10), tx, _y1, false);
		}
		
		var c0  = colorMultiply(_item.item.color_cur, COLORS.panel_animation_dope_key_bg);
		draw_set_color(c0);
		draw_rectangle(0, ty - ui(10), tx, ty + ui(10), false);
		
		#region keyframe control
			tx = tool_width - ui(20 + 16 * 3);
			if(buttonInstant(noone, tx - ui(10), ty - ui(9), ui(20), ui(17), [msx, msy], pFOCUS, pHOVER, "", THEME.prop_keyframe, 0, [COLORS._main_icon, COLORS._main_icon_on_inner], _tool_a) == 2) {
				var _t = -1;
				for(var k = 0; k < array_length(animator.values); k++) {
					var _key = animator.values[k];
					if(_key.time < CURRENT_FRAME)
						_t = _key.time;
				}
				if(_t > -1) PROJECT.animator.setFrame(_t);
			}
				
			tx = tool_width - ui(20 + 16 * 1);
			if(buttonInstant(noone, tx - ui(10), ty - ui(9), ui(20), ui(17), [msx, msy], pFOCUS, pHOVER, "", THEME.prop_keyframe, 2, [COLORS._main_icon, COLORS._main_icon_on_inner], _tool_a) == 2) {
				for(var k = 0; k < array_length(animator.values); k++) {
					var _key = animator.values[k];
					if(_key.time > CURRENT_FRAME) {
						PROJECT.animator.setFrame(_key.time);
						break;
					}
				}
			}
		#endregion
				
		#region add keyframe
			tx = tool_width - ui(20 + 16 * 2);
			if(buttonInstant(noone, tx - ui(10), ty - ui(9), ui(20), ui(17), [msx, msy], pFOCUS, pHOVER, "", THEME.prop_keyframe, 1, [COLORS._main_accent, COLORS._main_icon_on_inner], _tool_a) == 2) {
				var _add = false;
				for(var k = 0; k < array_length(animator.values); k++) {
					var _key = animator.values[k];
					if(_key.time == CURRENT_FRAME) {
						if(array_length(animator.values) > 1)
							array_delete(animator.values, k, 1);
						_add = true;
						break;
					} else if(_key.time > CURRENT_FRAME) {
						array_insert(animator.values, k, new valueKey(CURRENT_FRAME, variable_clone(animator.getValue()), animator));
						_add = true;
						break;	
					}
				}
				if(!_add) array_push(animator.values, new valueKey(CURRENT_FRAME, variable_clone(animator.getValue(, false)), animator));	
			}
		#endregion
				
		if(isGraphable(prop)) {
			tx = tool_width - ui(16);
			if(pHOVER && point_in_rectangle(msx, msy, tx - ui(9), ty - ui(10), tx + ui(10), ty + ui(8))) {
				draw_sprite_ui_uniform(THEME.timeline_graph, 1, tx, ty, 1, COLORS._main_icon_on_inner, _tool_a);
				TOOLTIP = _graph_show? __txtx("panel_animation_hide_graph", "Hide graph") : __txtx("panel_animation_show_graph", "Show graph");
				
				if(mouse_press(mb_left, pFOCUS)) {
					if(prop.sep_axis) prop.show_graphs[animator.index] = !_graph_show;
					else              prop.show_graph                  = !_graph_show;
				}
			} else
				draw_sprite_ui_uniform(THEME.timeline_graph, 1, tx, ty, 1, _graph_show? COLORS._main_accent : COLORS._main_icon, _graph_show? 1 : _tool_a);
		}
						
		tx = tool_width - ui(20 + 16 * 4.5);
		
		if(pHOVER && point_in_rectangle(msx, msy, tx - ui(10), ty - ui(9), tx + ui(10), ty + ui(8))) {
			draw_sprite_ui_uniform(THEME.prop_on_end, prop.on_end, tx, ty, 1, COLORS._main_icon_on_inner, _on_end_disp);
			
			if(tooltip_loop_prop != prop) 
				tooltip_loop_type.arrow_pos = noone;
			tooltip_loop_prop = prop;
			tooltip_loop_type.index = prop.on_end;
			TOOLTIP = tooltip_loop_type;
							
			if(mouse_release(mb_left, pFOCUS)) 
				prop.on_end = safe_mod(prop.on_end + 1, sprite_get_number(THEME.prop_on_end));
			if(mouse_press(mb_left, pFOCUS)) 
				on_end_dragging_anim = prop;
		} else
			draw_sprite_ui_uniform(THEME.prop_on_end, prop.on_end, tx, ty, 1, on_end_dragging_anim == prop? COLORS._main_accent : COLORS._main_icon, _on_end_disp);
		
		draw_set_alpha(1);
	} #endregion
	
	function __drawDopesheetLabelItem(_item, _x, _y, msx = -1, msy = -1, alpha = 1) { #region
		var _itx = _x;
		var _ity = _y;
		var _itw = tool_width;
		var _hov = pHOVER && (msy > 0 && msy < dope_sheet_h);
		var _foc = pFOCUS;
		
		var pd   = ui(4);
		var _res = _item.item.drawLabel(_item, _itx + pd, _ity, _itw - pd * 2, msx, msy, _hov, _foc, item_dragging, hovering_folder, node_name_type, alpha);
		
		if(_res == 1) {
			if(mouse_press(mb_left, _foc)) {
				_item_dragging   = _item;
				item_dragging_mx = msx;
				item_dragging_my = msy;
				
				item_dragging_dx = msx - _x;
				item_dragging_dy = msy - _y;
			}
			
			if(mouse_press(mb_right, _foc))
				context_selecting_item = _item;
		}
	} #endregion
	
	function _drawDopesheetLabel() { #region
		surface_set_target(dope_sheet_name_surface);	
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
		var msx = mx - ui(8);
		var msy = my - ui(8);
		
		draw_set_text(f_p2, fa_left, fa_center);
		
		value_hovering = noone;
		if(mouse_click(mb_left, pFOCUS))
			value_focusing = noone;
			
		if(mouse_press(mb_right, pFOCUS)) {
			context_selecting_item = noone;
			context_selecting_prop = noone;
		}
		
		#region draw
			hovering_folder = PROJECT.timelines;
			hovering_order  = 0;
			
			var last_y = 0;
			var last_i = 0;
			
			if(item_dragging != noone)
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
				var _cont = timeline_contents[i];
				if(!_cont.show) continue;
				
				var _y = _cont.y;
				var _h = _cont.h;
				
				if(_y + _h < 0) continue;
				if(_y > h) break;
				
				if(item_dragging != noone && item_dragging.item == _cont.item) continue;
				
				if(_cont.type == "folder") {
					if(msy > _y && msy <= _y + _h) {
						hovering_folder = _cont.item;
						hovering_order  = -1;
					} 
				} else if(_cont.type == "node") {
					if(msy > _y && msy <= _y + _h / 2) {
						hovering_folder = _cont.parent;
						hovering_order  = _cont.index;
					} else if(msy > _y + _h / 2 && msy <= _y + _h) {
						hovering_folder = _cont.parent;
						hovering_order  = _cont.index + 1;
					}
				}
				
				last_y = _y + _h;
				if(_cont.parent == PROJECT.timelines)
					last_i = _cont.index + 1;
			}
			
			if(msy > last_y) {
				hovering_folder = PROJECT.timelines;
				hovering_order  = last_i;
			}
			
			var _itx = -1, _ity, _itw;
			
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
				var _cont = timeline_contents[i];
				if(!_cont.show) continue;
				
				var _y = _cont.y;
				var _h = _cont.h;
				
				if(_y + _h < 0) continue;
				if(_y > h) break;
				
				if(item_dragging != noone && item_dragging.item == _cont.item) {
					_itx = _cont.depth * ui(20);
					_ity = _cont.y;
					_itw = tool_width - _cont.depth * ui(20);
					continue;
				}
				
				if(show_nodes) __drawDopesheetLabelItem(_cont, 0, _cont.y, msx, msy);
				
				if(_cont.type == "node" && _cont.item.show)
				for( var j = 0; j < array_length(_cont.animators); j++ )
					__drawDopesheetLabelAnimator(_cont, _cont.node, _cont.animators[j], msx, msy);
			}
			
			if(_itx != -1) {
				draw_set_color(COLORS._main_accent);
				draw_line_width(_itx, _ity, _itx + _itw, _ity, 2);
			}	
			
			if(_item_dragging != noone) {
				if(point_distance(msx, msy, item_dragging_mx, item_dragging_my) > 4) {
					item_dragging  = _item_dragging;
					_item_dragging = noone;
				}
			}
		
			if(item_dragging != noone) {
				item_dragging.item.removeSelf();
				if(hovering_order == -1) 
					array_insert(hovering_folder.contents, 0, item_dragging.item);
				else {
					var _ind = min(array_length(hovering_folder.contents), hovering_order);
					array_insert(hovering_folder.contents, _ind, item_dragging.item);
				}
				
				item_dragging.item.parent = hovering_folder;
			}
			
			if(mouse_release(mb_left)) {
				_item_dragging = noone;
				item_dragging  = noone;
			}
		#endregion
		
		gpu_set_blendmode(bm_subtract);
		draw_surface_safe(dope_sheet_name_mask);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
	} #endregion
	
	function drawDopesheet() { #region
		var bar_x = tool_width + ui(16);
		var bar_y = h - timeline_h - ui(10);
		var bar_w = timeline_w;
		var bar_h = timeline_h;
		var bar_total_w = TOTAL_FRAMES * timeline_scale;
		
		surfaceVerify();
		
		#region scroll
			dope_sheet_y = lerp_float(dope_sheet_y, dope_sheet_y_to, 4);
				
			if(pHOVER && point_in_rectangle(mx, my, ui(8), ui(8), bar_x, ui(8) + dope_sheet_h)) {
				if(mouse_wheel_down())	dope_sheet_y_to = clamp(dope_sheet_y_to - ui(32) * SCROLL_SPEED, -dope_sheet_y_max, 0);
				if(mouse_wheel_up())	dope_sheet_y_to = clamp(dope_sheet_y_to + ui(32) * SCROLL_SPEED, -dope_sheet_y_max, 0);
			}
					
			var scr_x    = bar_x + dope_sheet_w + ui(4);
			var scr_y    = ui(8);
			var scr_s    = dope_sheet_h;
			var scr_prog = -dope_sheet_y / dope_sheet_y_max;
			var scr_size = dope_sheet_h / (dope_sheet_h + dope_sheet_y_max);
					
			var scr_scale_s = scr_s * scr_size;
			var scr_prog_s  = scr_prog * (scr_s - scr_scale_s);
				
			var scr_w	= scroll_w;
			var scr_h	= scr_s;
			var s_bar_w	= scroll_w;
			var s_bar_h   = scr_scale_s;
			var s_bar_x	= scr_x;
			var s_bar_y	= scr_y + scr_prog_s;
				
			if(is_scrolling) {
				if(scr_s - scr_scale_s != 0)
					dope_sheet_y_to = clamp((my - scr_y - scr_scale_s / 2) / (scr_s - scr_scale_s), 0, 1) * -dope_sheet_y_max;
					
				if(mouse_release(mb_left)) is_scrolling = false;
			}
				
			if(pHOVER && point_in_rectangle(mx, my, scr_x - ui(2), scr_y - ui(2), scr_x + scr_w + ui(2), scr_y + scr_h + ui(2))) {
				draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, s_bar_x, s_bar_y, s_bar_w, s_bar_h, COLORS.scrollbar_hover, 1);
				if(mouse_click(mb_left, pFOCUS))
					is_scrolling = true;
			} else {
				draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, s_bar_x, s_bar_y, s_bar_w, s_bar_h, COLORS.scrollbar_idle, 1);	
			}
			
			var _p   = PEN_USE && (is_scrolling || point_in_rectangle(mx, my, scr_x - ui(2), scr_y - ui(2), scr_x + scr_w + ui(2), scr_y + scr_h + ui(2)));
			scroll_w = lerp_float(scroll_w, _p? 12 : scroll_s, 5);
		#endregion
				
		surface_set_target(dope_sheet_surface);	
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var msx = mx - bar_x;
		var msy = my - ui(8);
				
		#region bg \\\\ set X, Y for Node and Prop
			var bar_show_w = timeline_shift + bar_total_w;
			
			var _bg_w = min(bar_total_w + PANEL_PAD, bar_w);
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 2, 0, 0, bar_w, dope_sheet_h, COLORS.panel_animation_timeline_blend, 1);
			
			dope_sheet_y_max = 0;
			var key_y = ui(22) + dope_sheet_y;
			var c0, c1;
			
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
				var _cont = timeline_contents[i];
				_cont.y   = key_y;
				_cont.h   = 0;
				_cont.item.drawDopesheet(timeline_shift, _cont.y, timeline_scale, msx, msy);
				
				if(!_cont.show)
					continue;
				if(item_dragging != noone && item_dragging.item == _cont.item)
					continue;
				
				var _expand = _cont.type == "node" && _cont.item.show; 
				
				var _ks = key_y;
				if(_cont.item.color_dsp > -1) {
					draw_set_color(_cont.item.color_dsp);
					draw_rectangle(0, _ks - 1, bar_show_w, _ks + ui(20), false);
				}
				
				if(_cont.item.color_cur > -1) {
					c0 = colorMultiply(_cont.item.color_cur, COLORS.panel_animation_dope_key_bg);
					c1 = colorMultiply(_cont.item.color_cur, COLORS.panel_animation_dope_key_bg_hover);
				} else {
					c0 = COLORS.panel_animation_dope_key_bg;
					c1 = COLORS.panel_animation_dope_key_bg_hover;
				}
				
				key_y	+= ui(20) * show_nodes + _expand * ui(10);
				_cont.h	+= ui(20) * show_nodes;
				_ks      = key_y - ui(10);
				
				if(_expand) {
					for( var j = 0; j < array_length(_cont.props); j++ ) {
						var  prop   = _cont.props[j];
						var _prop   = prop.prop;
						     prop.y = key_y;
						
						for( var k = 0; k < array_length(prop.animators); k++ ) {
							prop.animators[k].y = key_y;
							
							if(_cont.item.color_cur > -1) {
								draw_set_color(c0);
								draw_rectangle(0, key_y - ui(10), bar_show_w, key_y + ui(10), false);
								
								     if(_prop == value_focusing) draw_sprite_stretched_ext(THEME.s_box_r2, 0, 0, key_y - ui(8), bar_show_w, ui(16), c1);
								else if(_prop == value_hovering) draw_sprite_stretched_ext(THEME.s_box_r2, 0, 0, key_y - ui(8), bar_show_w, ui(16), c1, .9);
							}
							
							if(k) prop.y = key_y;
							key_y	+= ui(18);
							_cont.h	+= ui(18);
						}
						
						var _graph_show = _prop.sep_axis? array_any(_prop.show_graphs, function(v) /*=>*/ {return v == true}) : _prop.show_graph;
						
						if(_graph_show && _prop.type != VALUE_TYPE.color) {
							if(_cont.item.color_cur > -1) {
								draw_set_color(c1);
								draw_rectangle(0, key_y - ui(10), bar_show_w, key_y + _prop.graph_h - ui(2), false);
							}
							
							var _gr_h = _prop.graph_h;
							key_y   += _gr_h + ui(8);
							_cont.h += _gr_h + ui(8);
						}
					}
				}
				
				key_y -= _expand * ui(10);
				dope_sheet_y_max += _cont.h;
			}
			
			dope_sheet_y_max = max(0, dope_sheet_y_max - dope_sheet_h + ui(48));
			
			var _fr = ceil((bar_w / timeline_scale - timeline_shift) / timeline_separate) * timeline_separate;
			
			for(var i = timeline_sep_line; i <= _fr; i += timeline_sep_line) {
				var bar_line_x = i * timeline_scale + timeline_shift;
				
				draw_set_color(COLORS.panel_animation_frame_divider);
				draw_set_alpha((i % timeline_separate == 0? 1 : 0.1) * ((i <= TOTAL_FRAMES) * 0.5 + 0.5));
				draw_line(bar_line_x, ui(16), bar_line_x, dope_sheet_h - PANEL_PAD);
			}
			draw_set_alpha(1);
			
			var bar_line_x = TOTAL_FRAMES * timeline_scale + timeline_shift;
			draw_set_color(COLORS.panel_animation_end_line);
			draw_set_alpha(0.5);
			draw_line_width(bar_line_x, ui(16), bar_line_x, dope_sheet_h, 2);
			draw_set_alpha(1);
		#endregion
		
		draw_set_text(f_p2, fa_left, fa_top);
		
		#region draw graph, easing line
			var key_hover = noone;
			_graph_key_hover       = noone;
			_graph_key_hover_index = noone;
			_graph_key_hover_x     = 0;
			_graph_key_hover_y     = 0;
			
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
				var _cont = timeline_contents[i];
				
				if(!_cont.show)			 continue;
				if(_cont.type != "node") continue;
				
				if(_cont.item.show)
				for( var j = 0, m = array_length(_cont.props); j < m; j++ ) {
					var prop  = _cont.props[j];
					var _dy   = prop.y;
					var _prop = prop.prop;
					
					if(isGraphable(_prop)) {
						var _graph_show = _prop.sep_axis? array_any(_prop.show_graphs, function(v) /*=>*/ {return v == true}) : _prop.show_graph;
						if(_graph_show) _drawDopesheetGraph(_prop, _dy, msx, msy);
					}
						
					for( var k = 0; k < array_length(prop.animators); k++ ) {
						var key = _drawDopesheetAnimatorKeysBG(prop.animators[k], msx, msy);
						_dy = prop.animators[k].y;
						if(key != noone) key_hover = key;
					}
				}
			}
			
			graph_key_hover       = _graph_key_hover;
			graph_key_hover_index = _graph_key_hover_index;
			
			if(graph_key_drag != noone) {
				var bar_x = tool_width + ui(16);
				var k     = graph_key_drag;
				
				if(graph_key_drag_index == KEYFRAME_DRAG_TYPE.move) {
					var tt = round((mx - bar_x - timeline_shift) / timeline_scale) - 1;
					    tt = max(tt, 0);
					
					var sh = tt - k.time;
					var kt = k.time + sh;
					var edited = k.anim.setKeyTime(k, kt, false, true)
					if(edited) UNDO_HOLDING = true;
					
					if(mouse_release(mb_left)) 
						k.anim.setKeyTime(k, k.time, true, true);
					
				} else {
					var _dir = point_direction(graph_key_sx, graph_key_sy, msx, msy);
					var _dis = point_distance( graph_key_sx, graph_key_sy, msx, msy);
					
					var _dx = lengthdir_x(_dis, _dir) / timeline_scale / 2;
					var _dy = lengthdir_y(_dis, _dir) / 32;
					if(_dx < 0) _dy = -_dy;
					
					_dx = clamp(abs(_dx), 0, 1);
					if(_dx > 0.1) keyframe_dragout = true;
					else { _dx = 0; _dy = 0; }
					
					var _in = k.ease_in;
					var _ot = k.ease_out;
				
					switch(graph_key_drag_index) {
						case KEYFRAME_DRAG_TYPE.ease_in :
							k.ease_in_type  = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.linear;
							k.ease_in[0] = _dx;
							// k.ease_in[1] = _dy + 1;
							
							break;
						case KEYFRAME_DRAG_TYPE.ease_out :
							k.ease_out_type = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.linear;
							k.ease_out[0] =  _dx;
							// k.ease_out[1] = -_dy;
							
							break;
						case KEYFRAME_DRAG_TYPE.ease_both :
							
							k.ease_in_type  = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.linear;
							k.ease_out_type = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.linear;
						
							k.ease_in[0]  = _dx;
							// k.ease_in[1]  = _dy + 1;
							
							k.ease_out[0] =  _dx;
							// k.ease_out[1] = -_dy;
							break;
					}
								
					if(mouse_release(mb_left)) {
						recordAction(ACTION_TYPE.var_modify, k, [_in, "ease_in"]);
						recordAction(ACTION_TYPE.var_modify, k, [_ot, "ease_out"]);
					}
				}
				
				if(mouse_release(mb_left)) {
					graph_key_drag = noone;
					UNDO_HOLDING   = false;
				}
				
			} else if(graph_key_hover != noone) {
				
				if(DOUBLE_CLICK) {
					graph_key_drag		 = _graph_key_hover;
					graph_key_drag_index = KEYFRAME_DRAG_TYPE.ease_both;
					graph_key_mx	     = msx;
					graph_key_my	     = msy;
					graph_key_sx		 = _graph_key_hover_x;
					graph_key_sy		 = _graph_key_hover_y;
					keyframe_dragout     = false;
					
				} else if(mouse_press(mb_left)) {
					graph_key_drag		 = _graph_key_hover;
					graph_key_drag_index = _graph_key_hover_index;
					graph_key_mx	     = msx;
					graph_key_my	     = msy;
					graph_key_sx		 = _graph_key_hover_x;
					graph_key_sy		 = _graph_key_hover_y;
				}
				
			}
		#endregion
			
		#region drag key
			if(keyframe_dragging) {
				if(keyframe_drag_type == KEYFRAME_DRAG_TYPE.move) {
					var tt = round((mx - bar_x - timeline_shift) / timeline_scale) - 1;
					tt = max(tt, 0);
					var sh = tt - keyframe_dragging.time;
					var edited = false;
					
					for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
						var k  = keyframe_selecting[i];
						var kt = k.time + sh;
						
						if(k.anim.setKeyTime(k, kt, false, true))
							edited = true;
					}
					
					if(edited) UNDO_HOLDING = true;
					timeline_show_time = floor(tt);
								
					if(mouse_release(mb_left) || mouse_press(mb_left)) {
						keyframe_dragging = noone;
						UNDO_HOLDING = false;
						
						for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
							var k  = keyframe_selecting[i];
							k.anim.setKeyTime(k, k.time, true, true);
						}
					}
				} else {
					var dx = abs((keyframe_dragging.time + 1) - (mx - bar_x - timeline_shift) / timeline_scale) / 2;
					dx = clamp(dx, 0, 1);
					if(dx > 0.2) keyframe_dragout = true;
				
					var dy = -(my - keyframe_drag_my) / 32;
				
					var _in = keyframe_dragging.ease_in;
					var _ot = keyframe_dragging.ease_out;
				
					switch(keyframe_drag_type) {
						case KEYFRAME_DRAG_TYPE.ease_in :
							for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
								var k = keyframe_selecting[i];
								k.ease_in_type  = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.linear;
								
								k.ease_in[0] = dx;
								if(!k.ease_y_lock) 
									k.ease_in[1] = dy;
							}
						
							break;
						case KEYFRAME_DRAG_TYPE.ease_out :
							for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
								var k = keyframe_selecting[i];
								k.ease_out_type = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.linear;
								
								k.ease_out[0] =  dx;
								if(!k.ease_y_lock) 
									k.ease_out[1] =  dy;
							}
							break;
						case KEYFRAME_DRAG_TYPE.ease_both :
							for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
								var k  = keyframe_selecting[i];
								k.ease_in_type  = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.linear;
								k.ease_out_type = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.linear;
							
								k.ease_in[0] = dx;
								if(!k.ease_y_lock) 
									k.ease_in[1] = dy;
								
								k.ease_out[0] = dx;
								if(!k.ease_y_lock) 
									k.ease_out[1] = dy;
							}
							break;
					}
								
					if(mouse_release(mb_left)) {
						recordAction(ACTION_TYPE.var_modify, keyframe_dragging, [_in, "ease_in"]);
						recordAction(ACTION_TYPE.var_modify, keyframe_dragging, [_ot, "ease_out"]);
								
						keyframe_dragging = noone;
						UNDO_HOLDING      = false;
					}
				}
			}
		#endregion
		
		#region on end dragging
			if(on_end_dragging_anim != noone) {
				if(mouse_release(mb_left))
					on_end_dragging_anim = false;
			}
		#endregion
		
		if(keyframe_boxing) { #region
			draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, keyframe_box_sx, keyframe_box_sy, msx, msy, COLORS._main_accent);
					
			if(mouse_release(mb_left))
				keyframe_boxing = false;
		} #endregion
		
		#region ======= draw keys =======
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
				var _cont = timeline_contents[i];
				if(_cont.type != "node") continue;
				
				for( var j = 0, m = array_length(_cont.animators); j < m; j++ ) {
					var _anim = _cont.animators[j];
					
					var key = _drawDopesheetAnimatorKeys(_cont, _anim, msx, msy);
					if(key != noone) key_hover = key;
				}
			}
		#endregion
		
		if(pHOVER && point_in_rectangle(msx, msy, 0, ui(18), dope_sheet_w, dope_sheet_h)) { #region selection & stagger
			if(mouse_press(mb_right, pFOCUS) && key_hover == noone)
				keyframe_selecting = [];
				
			if(mouse_press(mb_left, pFOCUS)) {
				if(key_hover == noone) {
					keyframe_selecting = [];
				} else if(key_mod_press(SHIFT)) {
					if(array_exists(keyframe_selecting, key_hover))
						array_remove(keyframe_selecting, key_hover);
					else
						array_push(keyframe_selecting, key_hover)
				} else {
					if(!array_exists(keyframe_selecting, key_hover))
						keyframe_selecting = [ key_hover ];
				}
				
				if(stagger_mode == 1) {
					if(key_hover == noone || !array_exists(keyframe_selecting, key_hover)) 
						stagger_mode = 0;
					else {
						arrangeKeys();
						stagger_index = array_find(keyframe_selecting, key_hover);
						stagger_mode = 2;
					}
				} else if(stagger_mode == 2) {
					stagger_mode = 0;
					UNDO_HOLDING = false;
				} else if(key_hover == noone && keyframe_boxable) {
					keyframe_boxing = true;
					keyframe_box_sx = msx;
					keyframe_box_sy = msy;
				}
			}
			
			keyframe_boxable = true;
			
			if(stagger_mode == 2) {
				var ts = keyframe_selecting[stagger_index].time;
				var tm = round((mx - bar_x - timeline_shift) / timeline_scale) - 1;
				tm = max(tm, 0);
			
				var stg = tm - ts;
				staggerKeys(stagger_index, stg);
			}
		} #endregion
				
		#region overlay 
			var hh = ui(20);
			
			var bar_line_x = (CURRENT_FRAME + 1) * timeline_scale + timeline_shift;
			var cc = PROJECT.animator.is_playing? COLORS._main_value_positive : COLORS._main_accent;
			
			draw_set_color(cc);
			draw_line(bar_line_x, PANEL_PAD, bar_line_x, dope_sheet_h);
			
			var _phover = pHOVER && msy > hh;
			for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
				var _cont = timeline_contents[i];
				if(!_cont.show) continue;
				
				var _hov  = _cont.item.drawDopesheetOver(timeline_shift, _cont.y, timeline_scale, msx, msy, _phover, pFOCUS);
				if(is_undefined(_hov)) continue;
				if(_hov) keyframe_boxable = false;
			}
			
			draw_set_color(COLORS.panel_animation_timeline_top);
			draw_rectangle(0, 0, bar_w, hh, false);
			
			var _fr = ceil((bar_w / timeline_scale - timeline_shift) / timeline_separate) * timeline_separate;
			
			for(var i = timeline_separate; i <= _fr; i += timeline_separate) {
				var ln_x = i * timeline_scale + timeline_shift;
				
				if(i > TOTAL_FRAMES) draw_set_alpha(0.5);
				
				draw_set_color(COLORS.panel_animation_frame_divider);
				draw_line(ln_x, 0, ln_x, hh);
				
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
				draw_text_add(ln_x, PANEL_PAD, i);
			}
			
			draw_set_alpha(1);
			
			var end_x = TOTAL_FRAMES * timeline_scale + timeline_shift;
			draw_set_color(COLORS.panel_animation_end_line);
			draw_line_width(end_x, 0, end_x, ui(20), 2);
			
			if(PROJECT.onion_skin.enabled) { //ONION SKIN
				var rang = PROJECT.onion_skin.range;
				var colr = PROJECT.onion_skin.color;
			
				var fr = CURRENT_FRAME + 1;
				var tx = fr * timeline_scale + timeline_shift;
				var sx = (fr + rang[0]) * timeline_scale + timeline_shift;
				var ex = (fr + rang[1]) * timeline_scale + timeline_shift;
				var y0 = PANEL_PAD;
				var y1 = hh;
				var yc = (y0 + y1) / 2;
			
				draw_sprite_stretched_ext(THEME.timeline_onion_skin, 0, sx, y0, tx - sx, y1 - y0, colr[0], 1);
				draw_sprite_stretched_ext(THEME.timeline_onion_skin, 1, tx, y0, ex - tx, y1 - y0, colr[1], 1);
			
				var _sx = (fr + rang[0]) * timeline_scale + timeline_shift - ui(8);
				var _ex = (fr + rang[1]) * timeline_scale + timeline_shift + ui(8);
			
				if(point_in_circle(msx, msy, _sx, yc, ui(8))) {
					draw_sprite_ext(THEME.arrow, 2, _sx, yc, 1, 1, 0, colr[0], 1);
				
					if(mouse_press(mb_left, pFOCUS))
						onion_dragging = 0;
					timeline_draggable = false;
				} else
					draw_sprite_ext(THEME.arrow, 2, _sx, yc, 1, 1, 0, colr[0], 0.5);
			
				if(point_in_circle(msx, msy, _ex, yc, ui(8))) {
					draw_sprite_ext(THEME.arrow, 0, _ex, yc, 1, 1, 0, colr[1], 1);
				
					if(mouse_press(mb_left, pFOCUS))
						onion_dragging = 1;
					timeline_draggable = false;
				} else 
					draw_sprite_ext(THEME.arrow, 0, _ex, yc, 1, 1, 0, colr[1], 0.5);
				
				if(onion_dragging != noone) {
					if(onion_dragging == 0) {
						var mf = round((msx - timeline_shift + ui(8)) / timeline_scale) - fr;
						    mf = min(mf, 0);
					
						if(PROJECT.onion_skin.range[0] != mf) {
							PROJECT.onion_skin.range[0] = mf;
						}
					} else if(onion_dragging == 1) {
						var mf = round((msx - timeline_shift - ui(8)) / timeline_scale) - fr;
						    mf = max(mf, 0);
					
						if(PROJECT.onion_skin.range[1] != mf) {
							PROJECT.onion_skin.range[1] = mf;
						}
					}
					
					if(mouse_release(mb_left))
						onion_dragging = noone;
				}
			}
			
			draw_set_font(f_p2);
			var cf = string(CURRENT_FRAME + 1);
			var tx = string_width(cf) + ui(4);
			draw_sprite_stretched_ext(THEME.s_box_r2, 0, bar_line_x - tx / 2, 0, tx, hh + PANEL_PAD, cc, 1);
			
			draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_on_accent);
			draw_text_add(bar_line_x, PANEL_PAD, cf);
			
		#endregion
		
		#region stretch
			var stx = timeline_shift + bar_total_w + ui(24);
			var sty = ui(10);
			
			if(timeline_stretch == 1) {
				var len = round((mx - bar_x - timeline_shift) / timeline_scale) - 2;
				    len = max(1, len);
				TOOLTIP = __txtx("panel_animation_length", "Animation length") + " " + string(len);
				TOTAL_FRAMES = len;
				
				if(mouse_release(mb_left))
					timeline_stretch = 0;
					
				draw_sprite_ui(THEME.animation_stretch, 0, stx, sty, 1, 1, 0, COLORS.panel_animation_end_line, 1);
				
			} else if(timeline_stretch == 2) {
				var len  = round((mx - bar_x - timeline_shift) / timeline_scale) - 2;
				    len  = max(1, len);
				TOOLTIP  = __txtx("panel_animation_length", "Animation length") + " " + string(len);
				var _len = TOTAL_FRAMES;
				TOTAL_FRAMES = len;
				
				if(_len != len) {
					for (var m = 0, n = array_length(PROJECT.allNodes); m < n; m++) {
						var _node = PROJECT.allNodes[m];
						if(!_node || !_node.active) continue;
						
						for(var i = 0; i < array_length(_node.inputs); i++) {
							var in = _node.inputs[i];
							if(!in.is_anim) continue;
							
							for(var j = 0; j < array_length(in.animator.values); j++) {
								var t = in.animator.values[j];
								t.time = t.ratio * (len - 1);
							}
							
							for( var k = 0; k < array_length(in.animators); k++ )
							for(var j = 0; j < array_length(in.animators[k].values); j++) {
								var t = in.animators[k].values[j];
								t.time = t.ratio * (len - 1);
							}
						}
					}
				}
				
				if(mouse_release(mb_left))
					timeline_stretch = 0;
					
				draw_sprite_ui(THEME.animation_stretch, 1, stx, sty, 1, 1, 0, COLORS.panel_animation_end_line, 1);
				
			} else {
				if(!IS_PLAYING && pHOVER && point_in_circle(msx, msy, stx, sty, sty)) {
					if(key_mod_press(CTRL)) {
						draw_sprite_ui(THEME.animation_stretch, 1, stx, sty, 1, 1, 0, COLORS._main_icon, 1);
						TOOLTIP = __txtx("panel_animation_stretch", "Stretch animation");
						if(mouse_press(mb_left, pFOCUS)) {
							timeline_stretch = 2;
							timeline_stretch_mx = msx;
							timeline_stretch_sx = TOTAL_FRAMES;
						}
					} else {
						draw_sprite_ui(THEME.animation_stretch, 0, stx, sty, 1, 1, 0, COLORS._main_icon, 1);
						TOOLTIP = __txtx("panel_animation_adjust_length", "Adjust animation length");
						if(mouse_press(mb_left, pFOCUS)) {
							timeline_stretch = 1;
							timeline_stretch_mx = msx;
							timeline_stretch_sx = TOTAL_FRAMES;
						}
					}
				} else
					draw_sprite_ui(THEME.animation_stretch, 0, stx, sty, 1, 1, 0, COLORS._main_icon, 0.5);
			}
		#endregion
		
		gpu_set_blendmode(bm_subtract);
		draw_surface_safe(dope_sheet_mask);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		_drawDopesheetLabel();
		
		if(keyframe_boxable && mouse_press(mb_right, pFOCUS)) { #region context menu
			if(point_in_rectangle(mx, my, bar_x, ui(8), bar_x + dope_sheet_w, ui(8) + dope_sheet_h)) {
				
				if(array_empty(keyframe_selecting)) menuCall("animation_keyframe_empty_menu",,, keyframe_menu_empty);
				else								menuCall("animation_keyframe_menu",,, keyframe_menu,, keyframe_selecting);
				
			} else if(point_in_rectangle(mx, my, ui(8), ui(8), ui(8) + tool_width, ui(8) + dope_sheet_h)) {
				
				if(context_selecting_prop != noone) {
					if(context_selecting_prop.sepable) 
						menuCall("animation_name_empty_menu",,, context_selecting_prop.sep_axis? name_menu_prop_join : name_menu_prop_sep);
					else 
						menuCall("animation_name_empty_menu",,, name_menu_empty);
				}
				
				else if(context_selecting_item == noone)
					menuCall("animation_name_empty_menu",,, name_menu_empty);
					
				else if(is_instanceof(context_selecting_item.item, timelineItemNode))
					menuCall("animation_name_empty_menu",,, name_menu_item);
					
				else if(is_instanceof(context_selecting_item.item, timelineItemGroup))
					menuCall("animation_name_empty_menu",,, name_menu_group);
			}
		} #endregion
			
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), ui(8), tool_width, dope_sheet_h);
		draw_surface_safe(dope_sheet_name_surface, ui(8), ui(8));
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, bar_x, ui(8), bar_w, dope_sheet_h); //base BG
		draw_surface_safe(dope_sheet_surface, bar_x, ui(8));
		
		draw_sprite_stretched(THEME.ui_panel_bg_cover, 1, bar_x, ui(8), bar_w, dope_sheet_h);
		
		if(item_dragging != noone) __drawDopesheetLabelItem(item_dragging, mx - item_dragging_dx, my - item_dragging_dy,,, 0.5);
	} #endregion
	
	function drawAnimationControl() { #region
		var mini = w < ui(348);
		
		var amo = array_length(control_buttons);
		var col = floor((w - ui(8)) / ui(36));
		var row = ceil(amo / col);
		if(col < 1) return;
		
		var bx = tool_width / 2 - ui(36) * amo / 2 + ui(8);
		var by = h - ui(40);
		
		for( var i = 0; i < row; i++ ) {
			var colAmo = min(amo - i * col, col);
			if(mini) bx = w / 2 - ui(36) * colAmo / 2;
			
			for( var j = 0; j < colAmo; j++ ) {
				var ind = i * col + j;
				if(ind >= amo) return;
				var but = control_buttons[ind];
				var txt = but[0]();
				var ind = but[1]();
				var cc  = IS_RENDERING? COLORS._main_icon_dark : but[2]();
				var fnc = but[3];
			
				if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS && !IS_RENDERING, pHOVER && !IS_RENDERING, txt, THEME.sequence_control, ind, cc) == 2)
					fnc();
			
				bx += ui(36);
			}
			
			by -= ui(36);
		}
		
		if(mini) {
			var y0 = ui(8);
			var y1 = by + ui(36) - ui(8);
			var cy = (y0 + y1) / 2;
			
			if(y1 - y0 < 12) return;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), y0, w - ui(16), y1 - y0);
			
			var pw = w - ui(16);
			var px = ui(8) + pw * (CURRENT_FRAME / TOTAL_FRAMES);
			draw_set_color(COLORS._main_accent);
			draw_line(px, y0, px, y1);
			
			if(point_in_rectangle(mx, my, ui(8), y0, w - ui(16), y1)) {
				if(mouse_click(mb_left, pFOCUS)) {
					var rfrm = (mx - ui(8)) / (w - ui(16)) * TOTAL_FRAMES;
					PROJECT.animator.setFrame(clamp(rfrm, 0, TOTAL_FRAMES - 1));
				}
			}
			
			var txt = string(CURRENT_FRAME + 1) + "/" + string(TOTAL_FRAMES);
			
			if(y1 - y0 < ui(40)) {
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text_sub);
				draw_text_add(ui(16), cy, __txt("Frame"));
				draw_set_text(f_p1, fa_right, fa_center, PROJECT.animator.is_playing? COLORS._main_accent : COLORS._main_text_sub);
				draw_text_add(w - ui(16), cy, txt);
			} else {
				draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
				draw_text_add(w / 2, cy - ui(12), __txt("Frame"));
			
				draw_set_text(f_h5, fa_center, fa_center, PROJECT.animator.is_playing? COLORS._main_accent : COLORS._main_text_sub);
				draw_text_add(w / 2, cy + ui(6), txt);
			}
			return;
		}
		
		by += ui(36);
		bx = w - ui(44);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_animation_animation_settings", "Animation settings"), THEME.animation_setting, 2) == 2)
			dialogPanelCall(new Panel_Animation_Setting(), x + bx + ui(32), y + by - ui(8), { anchor: ANCHOR.right | ANCHOR.bottom }); 
		
		by -= ui(40); if(by < 8) return;
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_animation_scale_animation", "Scale animation"), THEME.animation_timing, 2) == 2)
			dialogPanelCall(new Panel_Animation_Scaler(), x + bx + ui(32), y + by - ui(8), { anchor: ANCHOR.right | ANCHOR.bottom }); 
		
		var max_y = by - ui(28);
		if(by < ui(28)) return;
		by = ui(8);
		
		var txt = __txt("New folder");
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(28), [mx, my], pFOCUS, pHOVER, txt, THEME.folder_content) == 2) {
			var _dir = new timelineItemGroup();
			PROJECT.timelines.addItem(_dir);
		}
		
		by += ui(32); if(by > max_y) return;
		node_name_tooltip.index = node_name_type;
		
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(28), [mx, my], pFOCUS, pHOVER, node_name_tooltip, THEME.node_name_type, node_name_type) == 2)
			node_name_type = (node_name_type + 1) % 3;
		
		by += ui(32); if(by > max_y) return;
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(28), [mx, my], pFOCUS, pHOVER, tooltip_toggle_nodes, THEME.junc_visible, show_nodes) == 2)
			show_nodes = !show_nodes;
		
		by += ui(32); if(by > max_y) return;
		txt = __txtx("panel_animation_keyframe_override", "Override Keyframe");
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(28), [mx, my], pFOCUS, pHOVER, txt, THEME.keyframe_override, global.FLAG.keyframe_override) == 2)
			global.FLAG.keyframe_override = !global.FLAG.keyframe_override;
		
		by += ui(32); if(by > max_y) return;
		txt = __txt("Onion skin");
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(28), [mx, my], pFOCUS, pHOVER, txt, THEME.onion_skin,, PROJECT.onion_skin.enabled? c_white : COLORS._main_icon) == 2)
			PROJECT.onion_skin.enabled = !PROJECT.onion_skin.enabled;
	} #endregion
	
	function drawContent(panel) { #region					>>>>>>>>>>>>>>>>>>>> MAIN DRAW <<<<<<<<<<<<<<<<<<<<
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		if(!PROJECT.active) return;
		
		if(tool_width_drag) {
			CURSOR = cr_size_we;
			
			tool_width = tool_width_start + (mx - tool_width_mx);
			tool_width = clamp(tool_width, ui(224), w - ui(128));
			onResize();
			
			if(mouse_release(mb_left))
				tool_width_drag = false;
		}
		
		getTimelineContent();
		if(w >= ui(348)) {
			drawTimeline();
			
			if(dope_sheet_h > 8) {
				drawDopesheet();
				
				if(pHOVER && point_in_rectangle(mx, my, tool_width + ui(8), ui(8), tool_width + ui(12), ui(8) + dope_sheet_h)) {
					CURSOR = cr_size_we;
					if(mouse_press(mb_left, pFOCUS)) {
						tool_width_drag  = true;
						tool_width_start = tool_width;
						tool_width_mx    = mx;
					}
				}
			}
		}
		drawAnimationControl();
		
		if(timeline_show_time > -1) {
			TOOLTIP = $"{__txt("Frame")} {timeline_show_time + 1}/{TOTAL_FRAMES}";
			timeline_show_time = -1;
		}
	} #endregion
	
	function doDuplicate() { #region
		if(array_empty(keyframe_selecting)) return;
		
		var clones = [];
		for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
			var cl = keyframe_selecting[i].cloneAnimator(,, false);
			if(cl == noone) continue;
			array_push(clones, cl);
		}
		
		if(array_empty(clones)) return;
		
		keyframe_selecting = clones;
		keyframe_dragging  = keyframe_selecting[0];
		keyframe_drag_type = KEYFRAME_DRAG_TYPE.move;
		keyframe_drag_mx   = mx;
		keyframe_drag_my   = my;
	} #endregion
	
	function doCopy() { #region
		ds_list_clear(copy_clipboard);
		for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ )
			ds_list_add(copy_clipboard, keyframe_selecting[i]);
	} #endregion
	
	function doPaste(val = noone) { #region
		if(ds_list_empty(copy_clipboard)) return;
		
		var shf  = 0;
		var minx = TOTAL_FRAMES + 2;
		for( var i = 0; i < ds_list_size(copy_clipboard); i++ )
			minx = min(minx, copy_clipboard[| i].time);
		shf = CURRENT_FRAME - minx;
		
		var multiVal = false;
		var _val = noone;
		
		for( var i = 0; i < ds_list_size(copy_clipboard); i++ ) {
			if(_val != noone && _val != copy_clipboard[| i].anim) {
				multiVal = true;
				break;
			}
			_val = copy_clipboard[| i].anim;
		}
		
		if(multiVal && val != noone) {
			var nodeTo = val.node;
			for( var i = 0; i < ds_list_size(copy_clipboard); i++ ) {
				var propFrom = copy_clipboard[| i].anim.prop;
				var propTo   = noone;
				
				for( var j = 0; j < array_length(nodeTo.inputs); j++ ) {
					if(nodeTo.inputs[j].name == propFrom.name) {
						propTo = nodeTo.inputs[j].animator;
						copy_clipboard[| i].cloneAnimator(shf, propTo);
						break;
					}
				}
			}
		} else {
			for( var i = 0; i < ds_list_size(copy_clipboard); i++ )
				copy_clipboard[| i].cloneAnimator(shf, (multiVal || val == noone)? noone : val.animator);
		}
	} #endregion
}
