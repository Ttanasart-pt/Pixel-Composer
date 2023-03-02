enum KEYFRAME_DRAG_TYPE {
	move,
	ease_in,
	ease_out, 
	ease_both
}

function Panel_Animation() : PanelContent() constructor {
	context_str = "Animation";
	
	timeline_h = ui(28);
	min_w = ui(348);
	min_h = ui(48);
	tool_width = ui(280);
	
	function initSize() {
		timeline_w = w - tool_width - ui(12);
		timeline_surface = surface_create_valid(timeline_w, timeline_h);
		timeline_mask = surface_create_valid(timeline_w, timeline_h);
		
		dope_sheet_w = w - tool_width;
		dope_sheet_h = h - timeline_h - ui(20);
		dope_sheet_surface = surface_create_valid(dope_sheet_w, 1);
		dope_sheet_mask = surface_create_valid(dope_sheet_w, 1);
	}
	initSize();
	
	dope_sheet_y = 0;
	dope_sheet_y_to = 0;
	dope_sheet_y_max = 0;
	is_scrolling = false;
	
	dope_sheet_node_padding = ui(2);
	
	ds_name_surface = surface_create_valid(tool_width - ui(16), 1);
	
	timeline_scubbing = false;
	timeline_scub_st = 0;
	timeline_scale = 20;
	_scrub_frame = -1;
	
	timeline_shift = 0;
	timeline_shift_to = 0;
	timeline_dragging = false;
	timeline_drag_sx = 0;
	timeline_drag_sy = 0;
	timeline_drag_mx = 0;
	timeline_drag_my = 0;
	
	timeline_stretch = 0;
	timeline_stretch_sx = 0;
	timeline_stretch_mx = 0;
	
	timeline_show_time = -1;
	timeline_preview = noone;
	
	keyframe_dragging = noone;
	keyframe_drag_type = -1;
	keyframe_dragout = false;
	keyframe_drag_mx = 0;
	keyframe_drag_my = 0;
	keyframe_selecting = ds_list_create();
	keyframe_boxing = false;
	keyframe_box_sx = -1;
	keyframe_box_sy = -1;
	
	node_ordering = noone;
	show_node_outside_context = true;
	
	stagger_mode  = 0;
	stagger_index = 0;
	
	graph_h = ui(64);        
	
	anim_properties = ds_list_create();
	
	prev_cache = array_create(ANIMATOR.frames_total);
	
	addHotkey("", "Play/Pause",		vk_space, MOD_KEY.none,	function() { 
		ANIMATOR.is_playing = !ANIMATOR.is_playing; 
		ANIMATOR.frame_progress = true;
		ANIMATOR.time_since_last_frame = 0;
		
		if(ANIMATOR.is_playing && ANIMATOR.frames_total) 
			ANIMATOR.setFrame(0);
		
	});
	addHotkey("", "First frame",	vk_home,  MOD_KEY.none,	function() { ANIMATOR.setFrame(0); });
	addHotkey("", "Last frame",		vk_end,   MOD_KEY.none,	function() { ANIMATOR.setFrame(ANIMATOR.frames_total - 1); });
	addHotkey("", "Next frame",		vk_right, MOD_KEY.none,	function() { 
		ANIMATOR.setFrame(min(ANIMATOR.real_frame + 1, ANIMATOR.frames_total - 1)); 
	});
	addHotkey("", "Previous frame",	vk_left, MOD_KEY.none,	function() { 
		ANIMATOR.setFrame(max(ANIMATOR.real_frame - 1, 0));
	});
	addHotkey("Animation", "Delete keys",	vk_delete,	MOD_KEY.none, function() { deleteKeys(); });
	addHotkey("Animation", "Duplicate",		"D",		MOD_KEY.ctrl, function() { doDuplicate(); });
	addHotkey("Animation", "Copy",			"C",		MOD_KEY.ctrl, function() { doCopy(); });
	addHotkey("Animation", "Paste",			"V",		MOD_KEY.ctrl, function() { doPaste(); });
	
	function deleteKeys() {
		for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
			var k  = keyframe_selecting[| i];
			k.anim.removeKey(k);
		}
		ds_list_clear(keyframe_selecting);
		updatePropertyList();
	}
	
	function alignKeys(halign = fa_left) {
		if(ds_list_empty(keyframe_selecting)) return;
		
		var tt = 0;
		
		switch(halign) {
			case fa_left :	
				tt = 9999;
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ )
					tt = min(tt, keyframe_selecting[| i].time);
				break;
			case fa_center :	
				tt = 0;
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ )
					tt += keyframe_selecting[| i].time;
				tt = round(tt / ds_list_size(keyframe_selecting));
				break;
			case fa_right :	
				tt = -9999;
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ )
					tt = max(tt, keyframe_selecting[| i].time);
				break;
		}
		
		for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
			var k = keyframe_selecting[| i];
			k.anim.setKeyTime(k, tt);
		}
	}
	
	function arrangeKeys() {
		var l = ds_list_create();
		for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
			var node = anim_properties[| i];
			if(!show_node_outside_context && node.group != PANEL_GRAPH.getCurrentContext()) continue;
			
			for( var j = 0; j < ds_list_size(node.inputs); j++ ) {
				var prop = node.inputs[| j];
				if(!prop.animator.is_anim) continue;
				
				for(var k = 0; k < ds_list_size(prop.animator.values); k++) {
					var keyframe = prop.animator.values[| k];
				
					if(ds_list_exist(keyframe_selecting, keyframe))
						ds_list_add(l, keyframe);
				}
			}
		}
		
		ds_list_copy(keyframe_selecting, l);
		ds_list_destroy(l);
	}
	
	function staggerKeys(_index, _stag) {
		var t = keyframe_selecting[| _index].time;
		for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
			var k = keyframe_selecting[| i];
			var _t = t + abs(i -  _index) * _stag;
			
			k.anim.setKeyTime(k, _t);
		}
	}
	
	keyframe_menu = [
		menuItemGroup(get_text("panel_animation_ease_in", "Ease in"),  [ 
			[ [THEME.timeline_ease, 0], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_in_type = CURVE_TYPE.none;
					k.ease_in = [0, 1];
				}
			}, get_text("panel_animation_ease_linear", "Linear") ],
			[ [THEME.timeline_ease, 1], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_in_type = CURVE_TYPE.bezier;
					k.ease_in = [1, 1];
				}
			}, get_text("panel_animation_ease_smooth", "Smooth") ],
			[ [THEME.timeline_ease, 2], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_in_type = CURVE_TYPE.bezier;
					k.ease_in = [1, 2];
				}
			}, get_text("panel_animation_ease_overshoot", "Overshoot") ],
			[ [THEME.timeline_ease, 3], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_in_type = CURVE_TYPE.bezier;
					k.ease_in = [0, 0];
				}
			}, get_text("panel_animation_ease_sharp", "Sharp") ],
			[ [THEME.timeline_ease, 4], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_in_type = CURVE_TYPE.cut;
					k.ease_in = [0, 0];
				}
			}, get_text("panel_animation_ease_hold", "Hold") ],
		]),
		menuItemGroup(get_text("panel_animation_ease_out", "Ease out"),  [ 
			[ [THEME.timeline_ease, 0], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_out_type = CURVE_TYPE.none;
					k.ease_out = [0, 0];
				}
			}, get_text("panel_animation_ease_linear", "Linear") ],
			[ [THEME.timeline_ease, 1], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_out_type = CURVE_TYPE.bezier;
					k.ease_out = [1, 0];
				}
			}, get_text("panel_animation_ease_smooth", "Smooth") ],
			[ [THEME.timeline_ease, 2], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_out_type = CURVE_TYPE.bezier;
					k.ease_out = [1, -1];
				}
			}, get_text("panel_animation_ease_overshoot", "Overshoot") ],
			[ [THEME.timeline_ease, 3], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_out_type = CURVE_TYPE.bezier;
					k.ease_out = [0, 1];
				}
			}, get_text("panel_animation_ease_sharp", "Sharp") ],
		]),
		-1,
		menuItemGroup(get_text("align", "Align"),  [ 
			[ [THEME.timeline_key_halign, 0], function() { alignKeys(fa_left); } ],
			[ [THEME.timeline_key_halign, 1], function() { alignKeys(fa_center); } ],
			[ [THEME.timeline_key_halign, 2], function() { alignKeys(fa_right); } ],
		]),
		menuItem(get_text("panel_animation_stagger", "Stagger"), function() { stagger_mode = 1; }),
		-1,
		menuItem(get_text("delete", "Delete"),		 function() { deleteKeys(); },	noone, [ "Animation", "Delete keys" ]),
		menuItem(get_text("duplicate", "Duplicate"), function() { doDuplicate(); }, THEME.duplicate, [ "Animation", "Duplicate" ]),
		menuItem(get_text("copy", "Copy"),			 function() { doCopy(); },		THEME.copy, [ "Animation", "Copy" ]),
		menuItem(get_text("paste", "Paste"),		 function() { doPaste(); },		THEME.paste, [ "Animation", "Paste" ]),
	];
	
	function onResize() {
		initSize();
		
		if(w - tool_width > 1) {
			if(is_surface(timeline_mask) && surface_exists(timeline_mask))
				surface_size_to(timeline_mask, timeline_w, timeline_h);
			else
				timeline_mask = surface_create_valid(timeline_w, timeline_h);
				
			if(is_surface(timeline_surface) && surface_exists(timeline_surface))
				surface_size_to(timeline_surface, timeline_w, timeline_h);
			else
				timeline_surface = surface_create_valid(timeline_w, timeline_h);
		}
		
		dope_sheet_w = timeline_w;
		dope_sheet_h = h - timeline_h - ui(24);
		if(dope_sheet_h > ui(8)) {
			if(is_surface(dope_sheet_mask) && surface_exists(dope_sheet_mask))
				surface_size_to(dope_sheet_mask, dope_sheet_w, dope_sheet_h);
			else 
				dope_sheet_mask = surface_create_valid(dope_sheet_w, dope_sheet_h);
				
			if(is_surface(dope_sheet_surface) && surface_exists(dope_sheet_surface))
				surface_size_to(dope_sheet_surface, dope_sheet_w, dope_sheet_h);
			else
				dope_sheet_surface = surface_create_valid(dope_sheet_w, dope_sheet_h);
				
			if(is_surface(ds_name_surface) && surface_exists(ds_name_surface))
				surface_size_to(ds_name_surface, tool_width - ui(16), dope_sheet_h);
			else
				ds_name_surface = surface_create_valid(tool_width - ui(16), dope_sheet_h);
		}
		resetTimelineMask();
	}
	
	function resetTimelineMask() {
		if(!surface_exists(timeline_mask))
			timeline_mask = surface_create_valid(timeline_w, timeline_h);
			
		surface_set_target(timeline_mask);
		draw_clear(c_black);
		gpu_set_blendmode(bm_subtract);
		draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, timeline_w, timeline_h);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		if(dope_sheet_h > 8) {
			if(!surface_exists(dope_sheet_mask))
				dope_sheet_mask = surface_create_valid(dope_sheet_w, dope_sheet_h);
			
			surface_set_target(dope_sheet_mask);
			draw_clear(c_black);
			gpu_set_blendmode(bm_subtract);
			draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, dope_sheet_w, dope_sheet_h);
			gpu_set_blendmode(bm_normal);
			surface_reset_target();
		}
	}
	resetTimelineMask();
	
	function updatePropertyList() {
		ds_list_destroy(anim_properties);
		var amo = ds_map_size(NODE_MAP);
		var k = ds_map_find_first(NODE_MAP);
		var pr = ds_priority_create();
		
		repeat(amo) {
			var _node = NODE_MAP[? k];
			k = ds_map_find_next(NODE_MAP, k);
			
			if(!_node.active) continue;
			
			var is_anim = false;
			for(var j = 0; j < ds_list_size(_node.inputs); j++) {
				var jun = _node.inputs[| j];
				is_anim |= jun.animator.is_anim && jun.value_from == noone;
			}
			
			if(!is_anim) continue;
			ds_priority_add(pr, _node, _node.anim_priority);
		}
		
		anim_properties = ds_priority_to_list(pr);
		ds_priority_destroy(pr);
	}
	
	function drawTimeline() {
		var bar_x = tool_width - ui(48);
		var bar_y = h - timeline_h - ui(10);
		var bar_w = timeline_w;
		var bar_h = timeline_h;
		var bar_total_w = ANIMATOR.frames_total * ui(timeline_scale);
		
		resetTimelineMask();
		if(!is_surface(timeline_surface) || !surface_exists(timeline_surface)) 
			timeline_surface = surface_create_valid(timeline_w, timeline_h);
			
		surface_set_target(timeline_surface);	
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
			
		#region bg
			draw_sprite_stretched(THEME.ui_panel_bg, 1, 0, 0, bar_w, bar_h);
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, 0, bar_total_w, bar_h, COLORS.panel_animation_timeline_blend, 1);
			
			for(var i = 10; i <= ANIMATOR.frames_total; i += 10) {
				var bar_line_x = i * ui(timeline_scale) + timeline_shift;
				draw_set_color(COLORS.panel_animation_frame_divider);
				draw_line(bar_line_x, ui(12), bar_line_x, bar_h);
					
				draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text_sub);
				draw_text(bar_line_x, ui(16), string(i));
			}
				
			var bar_line_x = (ANIMATOR.current_frame + 1) * ui(timeline_scale) + timeline_shift;
			var cc = ANIMATOR.is_playing? COLORS._main_value_positive : COLORS._main_accent;
			draw_set_color(cc);
			draw_line(bar_line_x, ui(12), bar_line_x, bar_h);
					
			draw_set_text(f_p2, fa_center, fa_bottom, cc);
			draw_text(bar_line_x, ui(16), string(ANIMATOR.current_frame + 1));
		#endregion
			
		#region cache
			var inspecting = PANEL_INSPECTOR.inspecting;
				
			if(inspecting && inspecting.use_cache) {
				for(var i = 0; i < ANIMATOR.frames_total; i++) {
					if(i >= array_length(inspecting.cache_result)) 
						break;
						
					var x0 = (i + 0) * ui(timeline_scale) + timeline_shift;
					var x1 = (i + 1) * ui(timeline_scale) + timeline_shift;
					
					draw_set_color(inspecting.cacheExist(i)? c_lime : c_red);
					draw_set_alpha(0.5);
					draw_rectangle(x0, bar_h - ui(4), x1, bar_h, false);
					draw_set_alpha(1);
				}
			}
		#endregion
			
		#region summary
			var index = 0, key_y = timeline_h / 2;
					
			for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
				var node = anim_properties[| i];
				if(!show_node_outside_context && node.group != PANEL_GRAPH.getCurrentContext()) continue;
				
				for( var j = 0; j < ds_list_size(node.inputs); j++ ) {
					var prop = node.inputs[| j];
				
					for(var k = 0; k < ds_list_size(prop.animator.values); k++) {
						var t = (prop.animator.values[| k].time + 1) * ui(timeline_scale) + timeline_shift;
						var ind = prop.animator.values[| k].ease_in_type == CURVE_TYPE.cut? 4 : 1;
						draw_sprite_ui_uniform(THEME.timeline_keyframe, ind, t, key_y, 1, COLORS.panel_animation_keyframe_hide);
					}
				}
			}
		#endregion
			
		#region pan zoom
			timeline_shift = lerp_float(timeline_shift, timeline_shift_to, 4);
				
			if(timeline_scubbing) {
				var rfrm = (mx - bar_x - timeline_shift) / ui(timeline_scale) - 1;
				ANIMATOR.setFrame(clamp(rfrm, 0, ANIMATOR.frames_total - 1));
				timeline_show_time  = ANIMATOR.current_frame;
					
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
			
			if(pHOVER && point_in_rectangle(mx, my, bar_x, 16, bar_x + bar_w, bar_y - 8)) {
				if(mouse_wheel_down()) {
					timeline_scale = max(timeline_scale - 1, 1);
					timeline_shift_to = 0;
				}
					
				if(mouse_wheel_up()) {
					timeline_scale = min(timeline_scale + 1, 24);
					timeline_shift_to = 0;
				}
						
				if(mouse_press(mb_middle, pFOCUS)) {
					timeline_dragging = true;
					
					timeline_drag_sx = timeline_shift;
					timeline_drag_sy = dope_sheet_y_to;
					timeline_drag_mx = mx;
					timeline_drag_my = my;
				}
			}
					
			if(pHOVER && point_in_rectangle(mx, my, bar_x, bar_y, bar_x + min(timeline_w, timeline_shift + bar_total_w), bar_y + bar_h)) { //preview
				if(mouse_wheel_down())
					timeline_shift_to = clamp(timeline_shift_to - 64, -max(bar_total_w - bar_w + 32, 0), 0);
				if(mouse_wheel_up())
					timeline_shift_to = clamp(timeline_shift_to + 64, -max(bar_total_w - bar_w + 32, 0), 0);
						
				if(mouse_press(mb_left, pFOCUS)) {
					timeline_scubbing = true;
					timeline_scub_st  = ANIMATOR.current_frame;
					_scrub_frame = timeline_scub_st;
				}
			}
					
			if(pHOVER && point_in_rectangle(mx, my, bar_x, 8, bar_x + min(timeline_w, timeline_shift + bar_total_w), 8 + 16)) { //top bar
				if(mouse_press(mb_left, pFOCUS)) {
					timeline_scubbing = true;
					timeline_scub_st  = ANIMATOR.current_frame;
					_scrub_frame = timeline_scub_st;
				}
			}
		#endregion
			
		gpu_set_blendmode(bm_subtract);
		draw_surface_safe(timeline_mask, 0, 0);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		draw_surface_safe(timeline_surface, bar_x, bar_y);
	}
	
	function drawDopesheetGraph(prop, key_y, msx, msy) { 
		var bar_total_w = ANIMATOR.frames_total * ui(timeline_scale);
		var hovering = noone;
		var _gy_val_min = 999999;
		var _gy_val_max = -999999;
		var _gy_top = key_y + ui(16);
		var _gy_bottom = _gy_top + graph_h - ui(8);
		
		var amo = ds_list_size(prop.animator.values);
						
		for(var k = 0; k < amo; k++) {
			var key_val = prop.animator.values[| k].value;
			if(is_array(key_val)) {
				for( var ki = 0; ki < array_length(key_val); ki++ ) {
					_gy_val_min = min(_gy_val_min, key_val[ki]);
					_gy_val_max = max(_gy_val_max, key_val[ki]);
				}
			} else {
				_gy_val_min = min(_gy_val_min, key_val);
				_gy_val_max = max(_gy_val_max, key_val);
			}
		}
		
		var valArray = is_array(prop.animator.values[| 0].value);
		var ox = 0, oy = valArray? [] : noone, nx = 0, ny = noone, oly = 0, nly = 0;
		
		for(var k = 0; k < amo; k++) {
			var key = prop.animator.values[| k];
			var t = (key.time + 1) * ui(timeline_scale) + timeline_shift;
			
			#region easing line
				if(key.ease_in_type == CURVE_TYPE.bezier) {
					draw_set_color(COLORS.panel_animation_keyframe_ease_line);
					var _tx = t - key.ease_in[0] * ui(timeline_scale) * 2;
					draw_line_width(_tx, key_y - 1, t, key_y - 1, 2);
											
					if(pHOVER && point_in_circle(msx, msy, _tx, key_y, ui(6))) {
						hovering = key;
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 2, _tx, key_y, 1, COLORS.panel_animation_keyframe_selected);
						if(mouse_press(mb_left, pFOCUS)) {
							keyframe_dragging = prop.animator.values[| k];
							keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_in;
						}
					} else 
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 2, _tx, key_y, 1, COLORS.panel_animation_keyframe_unselected);
				} 
						
				if(key.ease_out_type == CURVE_TYPE.bezier) {
					draw_set_color(COLORS.panel_animation_keyframe_ease_line);
					var _tx = t + key.ease_out[0] * ui(timeline_scale) * 2;
					draw_line_width(t, key_y - 1, _tx, key_y - 1, 2);
										
					if(pHOVER && point_in_circle(msx, msy, _tx, key_y, ui(6))) {
						hovering = key;
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 3, _tx, key_y, 1, COLORS.panel_animation_keyframe_selected);
						if(mouse_press(mb_left, pFOCUS)) {
							keyframe_dragging = prop.animator.values[| k];
							keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_out;
						}
					} else
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 3, _tx, key_y, 1, COLORS.panel_animation_keyframe_unselected);
				}
			#endregion
			
			if(!prop.animator.show_graph) continue;
			if(k >= amo - 1) continue;
			
			//draw graph content
			
			var key_next = prop.animator.values[| k + 1];
			var dx = key_next.time - key.time;
			
			if(key.ease_out_type == CURVE_TYPE.none && key_next.ease_in_type == CURVE_TYPE.none) { //linear draw
				nx = (key_next.time + 1) * ui(timeline_scale) + timeline_shift;
				if(valArray) {
					for( var ki = 0; ki < array_length(key.value); ki++ ) {
						draw_set_color(COLORS.axis[ki]);
						ny[ki] = value_map(key.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
						
						if(array_length(oy) > ki)
							draw_line(t, oy[ki], t, ny[ki]);
						oy[ki] = ny[ki];
						
						ny[ki] = value_map(key_next.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
						draw_line(t, oy[ki], nx, ny[ki]);
						oy[ki] = ny[ki];
					}
				} else {
					draw_set_color(COLORS.panel_animation_graph_line);
					ny = value_map(key.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
					if(oy != noone) draw_line(t, oy, t, ny);
					oy = ny;
					
					ny = value_map(key_next.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
					draw_line(t, oy, nx, ny);
					oy = ny;
				}
				
				ox = nx;
			} else { //bezier easing
				var _step = 1 / dx;
				for( var _r = 0; _r <= 1; _r += _step ) {
					nx = t + _r * dx * ui(timeline_scale);
					nly = prop.animator.interpolate(key, key_next, _r);
					
					if(valArray) {
						for( var ki = 0; ki < array_length(key.value); ki++ ) {
							draw_set_color(COLORS.axis[ki]);
							ny[ki] = value_map(lerp(key.value[ki], key_next.value[ki], nly), _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
							
							if(array_length(oy) > ki)
								draw_line(ox, oy[ki], nx, ny[ki]);
							
							oy[ki] = ny[ki];
						}
					} else {
						draw_set_color(COLORS.panel_animation_graph_line);
						ny = value_map(lerp(key.value, key_next.value, nly), _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
						if(oy != noone)
							draw_line(ox, oy, nx, ny);
						oy = ny;
					}
					
					ox = nx;
					oly = nly;
				}
			}
		}
		
		if(prop.animator.show_graph && ds_list_size(prop.animator.values) > 0) {
			var bar_show_w = timeline_shift + bar_total_w;
			
			if(ds_list_size(prop.animator.values) == 1) { //draw graph before and after
				var key_first = prop.animator.values[| 0];
				
				if(valArray) {
					for( var ki = 0; ki < array_length(key_first.value); ki++ ) {
						draw_set_color(COLORS.axis[ki]);
						sy = value_map(key_first.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
						draw_line(0, sy, bar_show_w, sy);
					}
				} else {
					draw_set_color(COLORS.panel_animation_graph_line);
					sy = value_map(key_first.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
					draw_line(0, sy, bar_show_w, sy);
				}
			} else { //draw graph before and after
				var key_first = prop.animator.values[| 0];
				var t_first = (key_first.time + 1) * ui(timeline_scale) + timeline_shift;
				var sy;
			
				if(valArray) {
					for( var ki = 0; ki < array_length(key_first.value); ki++ ) {
						draw_set_color(COLORS.axis[ki]);
						sy = value_map(key_first.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
						draw_line(0, sy, t_first, sy);
					}
				} else {
					draw_set_color(COLORS.panel_animation_graph_line);
					sy = value_map(key_first.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
					draw_line(0, sy, t_first, sy);
				}
			
				var key_last = prop.animator.values[| ds_list_size(prop.animator.values) - 1];
				var t_last = (key_last.time + 1) * ui(timeline_scale) + timeline_shift;
				
				if(key_last.time < ANIMATOR.frames_total) {
					if(valArray) {
						for( var ki = 0; ki < array_length(key_last.value); ki++ ) {
							draw_set_color(COLORS.axis[ki]);
							ny[ki] = value_map(key_last.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
							draw_line(t_last, oy[ki], t_last, ny[ki]);
							draw_line(t_last, oy[ki], bar_show_w, oy[ki]);
						}
					} else {
						draw_set_color(COLORS.panel_animation_graph_line);
						ny = value_map(key_last.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
						draw_line(t_last, oy, t_last, ny);
						draw_line(t_last, ny, bar_show_w, ny);
					}
				}
			}
		}
		
		return hovering;
	}
	
	function drawDopesheetName() {
		surface_set_target(ds_name_surface);	
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var msx = mx - ui(8);
		var msy = my - ui(8);
		
		var lable_w = tool_width - ui(64);
		var key_y = ui(24) + dope_sheet_y;
		var _node = noone;
		var _node_y = 0;
		draw_set_text(f_p2, fa_left, fa_center);
		
		var hovering = noone;
		var hoverIndex = 0;
		
		for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
			_node = anim_properties[| i];
			if(!show_node_outside_context && _node.group != PANEL_GRAPH.getCurrentContext()) continue;
			
			var aa = _node.group == PANEL_GRAPH.getCurrentContext()? 1 : 0.9;
			
			key_y += dope_sheet_node_padding;
			_node_y = key_y - ui(10);
			var _node_y_start = _node_y;
			
			if(pHOVER && point_in_rectangle(msx, msy, ui(20), key_y - ui(10), lable_w, key_y + ui(10))) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, key_y - ui(10), lable_w, ui(20), COLORS.panel_animation_dope_bg_hover, aa);
				if(mouse_press(mb_left, pFOCUS))
					node_ordering = _node;
			} else 
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, key_y - ui(10), lable_w, ui(20), COLORS.panel_animation_dope_bg, aa);
			
			if(_node == PANEL_INSPECTOR.inspecting)
				draw_sprite_stretched_ext(THEME.node_active, 0, 0, key_y - ui(10), lable_w, ui(20), COLORS._main_accent, 1);
							
			var tx = tool_width - ui(76 + 16 * 0);
			if(pHOVER && point_in_circle(msx, msy, tx, key_y - 1, ui(10))) {
				draw_sprite_ui_uniform(THEME.animate_node_go, 0, tx, key_y - 1, 1, COLORS._main_icon_light, 1);
				TOOLTIP = get_text("panel_animation_goto", "Go to node");
								
				if(mouse_press(mb_left, pFOCUS)) {
					PANEL_INSPECTOR.inspecting = _node;
					ds_list_clear(PANEL_GRAPH.nodes_select_list);
					PANEL_GRAPH.node_focus = _node;
					PANEL_GRAPH.fullView();
				}
			} else
				draw_sprite_ui_uniform(THEME.animate_node_go, 0, tx, key_y - 1, 1, COLORS._main_icon, 0.75);
				
			if(pHOVER && point_in_rectangle(msx, msy, 0, key_y - ui(10), ui(20), key_y + ui(10))) {
				draw_sprite_ui_uniform(THEME.arrow, _node.anim_show? 3 : 0, ui(10), key_y, 1, COLORS._main_icon_light, 1);
				if(mouse_press(mb_left, pFOCUS))
					_node.anim_show = !_node.anim_show;
			} else
				draw_sprite_ui_uniform(THEME.arrow, _node.anim_show? 3 : 0, ui(10), key_y, 1, COLORS._main_icon, 0.75);
			
			draw_set_color(node_ordering == _node? COLORS._main_text_accent : COLORS._main_text_sub);
			draw_set_alpha(aa);
			draw_text(ui(20), key_y - ui(2), _node.name);
			draw_set_alpha(1);
			
			key_y += ui(22);
			
			if(!_node.anim_show) {
				if(pHOVER && point_in_rectangle(msx, msy, 0, _node_y_start, lable_w, key_y))
					hovering = _node;
				continue;
			}
			
			for( var j = 0; j < ds_list_size(_node.inputs); j++ ) {
				var prop = _node.inputs[| j];
				if(!prop.animator.is_anim) continue;
				
				var tx = tool_width - ui(72 + 16 * 3);
				var ty = key_y - 1;
				
				#region keyframe control
					if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(6))) {
						draw_sprite_ui_uniform(THEME.prop_keyframe, 0, tx, ty, 1, COLORS._main_icon, 1);
							
						if(mouse_press(mb_left, pFOCUS)) {
							var _t = -1;
							for(var j = 0; j < ds_list_size(prop.animator.values); j++) {
								var _key = prop.animator.values[| j];
								if(_key.time < ANIMATOR.current_frame) {
									_t = _key.time;
								}
							}
							if(_t > -1) ANIMATOR.setFrame(_t);
						}
					} else
						draw_sprite_ui_uniform(THEME.prop_keyframe, 0, tx, ty, 1, COLORS._main_icon, 0.75);
						
					var tx = tool_width - ui(72 + 16 * 1);
					if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(6))) {
						draw_sprite_ui_uniform(THEME.prop_keyframe, 2, tx, ty, 1, COLORS._main_icon, 1);
					
						if(mouse_press(mb_left, pFOCUS)) {
							for(var j = 0; j < ds_list_size(prop.animator.values); j++) {
								var _key = prop.animator.values[| j];
								if(_key.time > ANIMATOR.current_frame) {
									ANIMATOR.setFrame(_key.time);
									break;
								}
							}
						}
					} else
						draw_sprite_ui_uniform(THEME.prop_keyframe, 2, tx, ty, 1, COLORS._main_icon, 0.75);
				#endregion
				
				var tx = tool_width - ui(72 + 16 * 2);
				if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(6))) {
					draw_sprite_ui_uniform(THEME.prop_keyframe, 1, tx, ty, 1, COLORS._main_accent, 1);
							
					if(mouse_press(mb_left, pFOCUS)) {
						var _add = false;
						for(var j = 0; j < ds_list_size(prop.animator.values); j++) {
							var _key = prop.animator.values[| j];
							if(_key.time == ANIMATOR.current_frame) {
								if(ds_list_size(prop.animator.values) > 1)
									ds_list_delete(prop.animator.values, j);
								_add = true;
								break;
							} else if(_key.time > ANIMATOR.current_frame) {
								ds_list_insert(prop.animator.values, j, new valueKey(ANIMATOR.current_frame, prop.getValue(, false), prop.animator));
								_add = true;
								break;	
							}
						}
						if(!_add) ds_list_add(prop.animator.values, new valueKey(ANIMATOR.current_frame, prop.getValue(, false), prop.animator));	
					}
				} else
					draw_sprite_ui_uniform(THEME.prop_keyframe, 1, tx, ty, 1, COLORS._main_accent, 0.75);
						
				if(isGraphable(prop.type)) {
					var tx = tool_width - ui(68 + 16 * 0);
					if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(8))) {
						draw_sprite_ui_uniform(THEME.timeline_graph, 1, tx, ty, 1, COLORS._main_icon, prop.animator.show_graph? 1 : 0.75);
						TOOLTIP = get_text("panel_animation_show_graph", "Show graph");
								
						if(mouse_press(mb_left, pFOCUS)) {
							prop.animator.show_graph = !prop.animator.show_graph;
						}
					} else
						draw_sprite_ui_uniform(THEME.timeline_graph, 1, tx, ty, 1, prop.animator.show_graph? COLORS._main_accent : COLORS._main_icon);
				}
						
				var tx = tool_width - ui(72 + 16 * 4.5);
				if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(6))) {
					draw_sprite_ui_uniform(THEME.prop_on_end, prop.on_end, tx, ty, 1, COLORS._main_icon, 1);
					TOOLTIP = get_text("panel_animation_looping_mode", "Looping mode") + ": " + ON_END_NAME[prop.on_end];
							
					if(mouse_press(mb_left, pFOCUS))
						prop.on_end = safe_mod(prop.on_end + 1, sprite_get_number(THEME.prop_on_end));
				} else
					draw_sprite_ui_uniform(THEME.prop_on_end, prop.on_end, tx, ty, 1, COLORS._main_icon, 0.75);
						
				if(pHOVER && point_in_circle(msx, msy, ui(22), key_y - 1, ui(10))) {
					draw_sprite_ui_uniform(THEME.timeline_clock, 1, ui(22), key_y - 1, 1, COLORS._main_icon, 1);
							
					if(mouse_press(mb_left, pFOCUS)) {
						prop.animator.is_anim = !prop.animator.is_anim;
						updatePropertyList();
					}
				} else
					draw_sprite_ui_uniform(THEME.timeline_clock, 1, ui(22), key_y - 1, 1, COLORS._main_icon, 0.75);
							
				draw_set_color(COLORS._main_text);
				draw_set_alpha(aa);
				draw_text(ui(32), key_y - 2, prop.name);
				draw_set_alpha(1);
			
				if(prop.animator.show_graph)
					key_y += graph_h + ui(8);
							
				key_y += ui(18);
			} //end prop loop
			
			if(pHOVER && point_in_rectangle(msx, msy, 0, _node_y_start, lable_w, key_y))
				hovering = _node;
			
		} //end node loop
		
		if(hovering == noone && _node != noone)
			hovering = _node;
		
		if(hovering != noone && node_ordering != noone) {
			hoverIndex = hovering.anim_priority;
			rearrange_priority(node_ordering, hoverIndex);
				
			if(mouse_release(mb_left))
				node_ordering = noone;
		}
		
		surface_reset_target();
	}
	
	function drawDopesheet() { 
		var bar_x = tool_width - ui(48);
		var bar_y = h - timeline_h - ui(10);
		var bar_w = timeline_w;
		var bar_h = timeline_h;
		var bar_total_w = ANIMATOR.frames_total * ui(timeline_scale);
		
		if(!is_surface(dope_sheet_surface) || !surface_exists(dope_sheet_surface)) 
			dope_sheet_surface = surface_create_valid(dope_sheet_w, dope_sheet_h);
				
		if(!is_surface(ds_name_surface) || !surface_exists(ds_name_surface)) 
			ds_name_surface = surface_create_valid(dope_sheet_w, dope_sheet_h);
			
		#region scroll
			dope_sheet_y = lerp_float(dope_sheet_y, dope_sheet_y_to, 4);
					
			if(pHOVER && point_in_rectangle(mx, my, ui(8), ui(8), tool_width, ui(8) + dope_sheet_h)) {
				if(mouse_wheel_down())	dope_sheet_y_to = clamp(dope_sheet_y_to - ui(32), -dope_sheet_y_max, 0);
				if(mouse_wheel_up())	dope_sheet_y_to = clamp(dope_sheet_y_to + ui(32), -dope_sheet_y_max, 0);
			}
					
			var scr_x = bar_x + dope_sheet_w + ui(4);
			var scr_y = ui(8);
			var scr_s = dope_sheet_h;
			var scr_prog = -dope_sheet_y / dope_sheet_y_max;
			var scr_size = dope_sheet_h / (dope_sheet_h + dope_sheet_y_max);
					
			var scr_scale_s = scr_s * scr_size;
			var scr_prog_s  = scr_prog * (scr_s - scr_scale_s);
				
			var scr_w	= ui(sprite_get_width(THEME.ui_scrollbar));
			var scr_h	= scr_s;
			var s_bar_w	= ui(sprite_get_width(THEME.ui_scrollbar));
			var s_bar_h   = scr_scale_s;
			var s_bar_x	= scr_x;
			var s_bar_y	= scr_y + scr_prog_s;
				
			if(is_scrolling) {
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
		#endregion
				
		surface_set_target(dope_sheet_surface);	
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var msx = mx - bar_x;
		var msy = my - ui(8);
				
		#region bg
			var bar_show_w = timeline_shift + bar_total_w;
			draw_sprite_stretched(THEME.ui_panel_bg, 1, 0, 0, bar_w, dope_sheet_h); //base BG
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, timeline_shift, 0, bar_total_w, dope_sheet_h, COLORS.panel_animation_timeline_blend, 1);
			
			dope_sheet_y_max = 0;
			var key_y = ui(24) + dope_sheet_y, key_y_node;
			
			for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
				var _node = anim_properties[| i];
				if(!show_node_outside_context && _node.group != PANEL_GRAPH.getCurrentContext()) continue;
				
				key_y += dope_sheet_node_padding;
				key_y_node = key_y;
				
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, key_y - ui(10), bar_show_w, ui(20), COLORS.panel_animation_node_bg, 1);
				key_y += ui(22);
				dope_sheet_y_max += ui(28);
				
				if(!_node.anim_show) continue;
				for( var j = 0; j < ds_list_size(_node.inputs); j++ ) {
					var prop = _node.inputs[| j];
					if(!prop.animator.is_anim) continue;
					
					key_y += ui(18);
					dope_sheet_y_max += ui(18);
						
					if(prop.animator.show_graph) {
						draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, key_y - ui(4), bar_show_w, graph_h, COLORS.panel_animation_graph_bg, 1);
						key_y += graph_h + ui(8);
						dope_sheet_y_max += graph_h + ui(8);
					}
				}
			}
			
			dope_sheet_y_max = max(0, dope_sheet_y_max - dope_sheet_h + ui(48));
			
			for(var i = 10; i <= ANIMATOR.frames_total; i += 10) {
				var bar_line_x = i * ui(timeline_scale) + timeline_shift;
				draw_set_color(COLORS.panel_animation_frame_divider);
				draw_line(bar_line_x, ui(16), bar_line_x, dope_sheet_h);
			}
		#endregion
		
		#region stretch
			var stx = timeline_shift + bar_total_w + ui(16);
			var sty = ui(10);
			
			if(timeline_stretch == 1) {
				var len = round((mx - bar_x - timeline_shift) / ui(timeline_scale)) - 2;
				len = max(1, len);
				TOOLTIP = get_text("panel_animation_length", "Animation length") + " " + string(len);
				ANIMATOR.frames_total = len;
				
				if(mouse_release(mb_left))
					timeline_stretch = 0;
					
				draw_sprite_ui(THEME.animation_stretch, 0, stx, sty, 1, 1, 0, COLORS._main_accent, 1);
			} else if(timeline_stretch == 2) {
				var len = round((mx - bar_x - timeline_shift) / ui(timeline_scale)) - 2;
				len = max(1, len);
				TOOLTIP = get_text("panel_animation_length", "Animation length") + " " + string(len);
				var _len = ANIMATOR.frames_total;
				ANIMATOR.frames_total = len;
				
				if(_len != len) {
					var key = ds_map_find_first(NODE_MAP);
					repeat(ds_map_size(NODE_MAP)) {
						var n = NODE_MAP[? key];
						key = ds_map_find_next(NODE_MAP, key);
						if(!n || !n.active) continue;
						
						for(var i = 0; i < ds_list_size(n.inputs); i++) {
							var in = n.inputs[| i];
							if(!in.animator.is_anim) continue;
							for(var j = 0; j < ds_list_size(in.animator.values); j++) {
								var t = in.animator.values[| j];
								t.time = t.ratio * (len - 1);
							}
						}
					}
				}
				
				if(mouse_release(mb_left))
					timeline_stretch = 0;
					
				draw_sprite_ui(THEME.animation_stretch, 1, stx, sty, 1, 1, 0, COLORS._main_accent, 1);
			} else {
				if(pHOVER && point_in_circle(msx, msy, stx, sty, sty)) {
					if(key_mod_press(CTRL)) {
						draw_sprite_ui(THEME.animation_stretch, 1, stx, sty, 1, 1, 0, COLORS._main_icon, 1);
						TOOLTIP = get_text("panel_animation_stretch", "Stretch animation");
						if(mouse_press(mb_left, pFOCUS)) {
							timeline_stretch = 2;
							timeline_stretch_mx = msx;
							timeline_stretch_sx = ANIMATOR.frames_total;
						}
					} else {
						draw_sprite_ui(THEME.animation_stretch, 0, stx, sty, 1, 1, 0, COLORS._main_icon, 1);
						TOOLTIP = get_text("panel_animation_adjust_length", "Adjust animation length");
						if(mouse_press(mb_left, pFOCUS)) {
							timeline_stretch = 1;
							timeline_stretch_mx = msx;
							timeline_stretch_sx = ANIMATOR.frames_total;
						}
					}
				} else
					draw_sprite_ui(THEME.animation_stretch, 0, stx, sty, 1, 1, 0, COLORS._main_icon, 0.5);
			}
		#endregion
		
		var key_sy = ui(24) + dope_sheet_y;
		var key_y, key_y_node;
		draw_set_text(f_p2, fa_left, fa_top);
		var key_hover = noone;
		
		#region draw graph
			key_y = key_sy;
			for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
				var _node = anim_properties[| i];
				if(!show_node_outside_context && _node.group != PANEL_GRAPH.getCurrentContext()) continue;
				
				key_y += ui(22) + dope_sheet_node_padding;
				
				if(!_node.anim_show) continue;
				for( var j = 0; j < ds_list_size(_node.inputs); j++ ) {
					var prop = _node.inputs[| j];
					if(!prop.animator.is_anim) continue;
					
					var key_list = prop.animator.values;
					if((prop.on_end == KEYFRAME_END.loop || prop.on_end == KEYFRAME_END.ping) && ds_list_size(key_list) > 1) {
						var keyframe_s = key_list[| 0].time;
						var keyframe_e = key_list[| ds_list_size(key_list) - 1].time;
								
						var ks_x = (keyframe_s + 1) * ui(timeline_scale) + timeline_shift;
						var ke_x = (keyframe_e + 1) * ui(timeline_scale) + timeline_shift;
						
						draw_set_color(COLORS.panel_animation_loop_line);
						draw_set_alpha(0.2);
						draw_line_width(ks_x, key_y - 1, ke_x, key_y - 1, 4);
						draw_set_alpha(1);
					}
					
					if(!isGraphable(prop.type)) {
						key_y += ui(18);
						continue;
					}
					
					var _key = drawDopesheetGraph(prop, key_y, msx, msy);
					if(_key) key_hover = _key;
			
					if(prop.animator.show_graph && ds_list_size(prop.animator.values) > 0)
						key_y += graph_h + ui(8);
			
					key_y += ui(18);
				}
			}
		#endregion
					
		key_y = key_sy;
						
		if(keyframe_boxing) {
			draw_set_color(COLORS._main_accent);
			draw_roundrect_ext(keyframe_box_sx, keyframe_box_sy, msx, msy, 6, 6, true);
			draw_set_alpha(0.05);
			draw_roundrect_ext(keyframe_box_sx, keyframe_box_sy, msx, msy, 6, 6, false);
			draw_set_alpha(1);
					
			if(mouse_release(mb_left))
				keyframe_boxing = false;
		}
		#region drag key
			if(keyframe_dragging) {
				if(keyframe_drag_type == KEYFRAME_DRAG_TYPE.move) {
					var tt = round((mx - bar_x - timeline_shift) / ui(timeline_scale)) - 1;
					tt = max(tt, 0);
					var sh = tt - keyframe_dragging.time;
								
					for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
						var k  = keyframe_selecting[| i];
						var kt = k.time + sh;
						
						k.anim.setKeyTime(k, kt, false);
					}
								
					timeline_show_time     = floor(tt);
								
					if(mouse_release(mb_left) || mouse_press(mb_left)) {
						keyframe_dragging = noone;
									
						for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
							var k  = keyframe_selecting[| i];
							k.anim.setKeyTime(k, k.time);
						}
					}
				} else {
					var dx = abs((keyframe_dragging.time + 1) - (mx - bar_x - timeline_shift) / ui(timeline_scale)) / 2;
					dx = clamp(dx, 0, 1);
					if(dx > 0.2) keyframe_dragout = true;
				
					var dy = (my - keyframe_drag_my) / 32;
				
					var _in = keyframe_dragging.ease_in;
					var _ot = keyframe_dragging.ease_out;
				
					switch(keyframe_drag_type) {
						case KEYFRAME_DRAG_TYPE.ease_in :
							for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
								var k = keyframe_selecting[| i];
								k.ease_in_type  = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.none;
								k.ease_in[0] = dx;
							}
						
							break;
						case KEYFRAME_DRAG_TYPE.ease_out :
							for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
								var k = keyframe_selecting[| i];
								k.ease_out_type = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.none;
								k.ease_out[0] =  dx;
							}
							break;
						case KEYFRAME_DRAG_TYPE.ease_both :
							for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
								var k  = keyframe_selecting[| i];
								k.ease_in_type  = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.none;
								k.ease_out_type = keyframe_dragout? CURVE_TYPE.bezier : CURVE_TYPE.none;
							
								k.ease_in[0] = dx;
								k.ease_out[0] = dx;
							}
							break;
					}
								
					if(mouse_release(mb_left)) {
						recordAction(ACTION_TYPE.var_modify, keyframe_dragging, [_in, "ease_in"]);
						recordAction(ACTION_TYPE.var_modify, keyframe_dragging, [_ot, "ease_out"]);
								
						keyframe_dragging = noone;
					}
				}
			}
		#endregion
		
		#region draw keys
			for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
				var _node = anim_properties[| i];
				if(!show_node_outside_context && _node.group != PANEL_GRAPH.getCurrentContext()) continue;
				
				key_y += dope_sheet_node_padding;
				key_y_node = key_y;
				key_y += ui(22);
				
				for( var j = 0; j < ds_list_size(_node.inputs); j++ ) {
					var prop = _node.inputs[| j];
					if(!prop.animator.is_anim) continue;
					
					for(var k = 0; k < ds_list_size(prop.animator.values); k++) {
						var t = (prop.animator.values[| k].time + 1) * ui(timeline_scale) + timeline_shift;
						var keyframe = prop.animator.values[| k];
						
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 0, t, key_y_node, 1, COLORS._main_icon);
						
						if(!_node.anim_show) continue;
						var cc = COLORS.panel_animation_keyframe_unselected;
						if(pHOVER && point_in_circle(msx, msy, t, key_y, ui(8))) {
							cc = COLORS.panel_animation_keyframe_selected;
							key_hover = keyframe;
									
							if(pFOCUS) {
								if(DOUBLE_CLICK) {
									keyframe_dragging = keyframe;
									keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_both;
									keyframe_dragout = false;
									keyframe_drag_mx = mx;
									keyframe_drag_my = my;
								} else if(mouse_press(mb_left)) {
									keyframe_dragging = keyframe;
									keyframe_drag_type = KEYFRAME_DRAG_TYPE.move;
									keyframe_drag_mx = mx;
									keyframe_drag_my = my;
								}
							}
						}
								
						if(stagger_mode == 1 && ds_list_exist(keyframe_selecting, keyframe))
							cc = key_hover == keyframe? COLORS.panel_animation_keyframe_selected : COLORS._main_accent;
						
						draw_sprite_ui_uniform(THEME.timeline_keyframe, keyframe.ease_in_type == CURVE_TYPE.cut? 4 : 1, t, key_y, 1, cc);
						if(ds_list_exist(keyframe_selecting, keyframe)) 
							draw_sprite_ui_uniform(THEME.timeline_keyframe_selecting, keyframe.ease_in_type == CURVE_TYPE.cut, t, key_y, 1, COLORS._main_accent);
						
						if(keyframe_boxing) {
							var box_x0 = min(keyframe_box_sx, msx);
							var box_x1 = max(keyframe_box_sx, msx);
							var box_y0 = min(keyframe_box_sy, msy);
							var box_y1 = max(keyframe_box_sy, msy);
									
							if(pHOVER && !point_in_rectangle(t, key_y, box_x0, box_y0, box_x1, box_y1) && ds_list_exist(keyframe_selecting, keyframe))
								ds_list_remove(keyframe_selecting, keyframe);
							if(pHOVER && point_in_rectangle(t, key_y, box_x0, box_y0, box_x1, box_y1) && !ds_list_exist(keyframe_selecting, keyframe))
								ds_list_add(keyframe_selecting, keyframe);
						}
					}
					
					if(_node.anim_show) {
						if(prop.animator.show_graph)
							key_y += graph_h + ui(8);
							
						key_y += 18;
					}
				}
			}
		#endregion
						
		if(pHOVER && point_in_rectangle(msx, msy, 0, ui(18), dope_sheet_w, dope_sheet_h)) {
			if(mouse_press(mb_left, pFOCUS) || mouse_press(mb_right, pFOCUS)) {
				if(key_hover == noone) {
					ds_list_clear(keyframe_selecting);
				} else {
					if(key_mod_press(SHIFT)) {
						if(ds_list_exist(keyframe_selecting, key_hover))
							ds_list_remove(keyframe_selecting, key_hover);
						else
							ds_list_add(keyframe_selecting, key_hover)
					} else {
						if(!ds_list_exist(keyframe_selecting, key_hover)) {
							ds_list_clear(keyframe_selecting);
							ds_list_add(keyframe_selecting, key_hover);
						}
					}
				}
			}
							
			if(mouse_press(mb_left, pFOCUS)) {
				if(stagger_mode == 1) {
					if(key_hover == noone || !ds_list_exist(keyframe_selecting, key_hover)) 
						stagger_mode = 0;
					else {
						arrangeKeys();
						stagger_index = ds_list_find_index(keyframe_selecting, key_hover);
						stagger_mode = 2;
					}
				} else if(stagger_mode == 2) {
					stagger_mode = 0;
				} else if(key_hover == noone) {
					keyframe_boxing = true;
					keyframe_box_sx = msx;
					keyframe_box_sy = msy;
				}
			}
		}
						
		if(mouse_press(mb_right, pFOCUS)) {
			if(!ds_list_empty(keyframe_selecting))
				menuCall(,, keyframe_menu);
		}
				
		if(stagger_mode == 2) {
			var ts = keyframe_selecting[| stagger_index].time;
			var tm = round((mx - bar_x - timeline_shift) / ui(timeline_scale)) - 1;
			tm = max(tm, 0);
			
			var stg = tm - ts;
			staggerKeys(stagger_index, stg);
		}
		
		#region overlay
			draw_set_color(COLORS.panel_animation_timeline_top);
			draw_rectangle(0, 0, bar_show_w, ui(16), false);
			
			for(var i = 10; i <= ANIMATOR.frames_total; i += 10) {
				var bar_line_x = i * ui(timeline_scale) + timeline_shift;
				draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text_sub);
				draw_text(bar_line_x - ui(2), 0, string(i));
			}
				
			var bar_line_x = (ANIMATOR.current_frame + 1) * ui(timeline_scale) + timeline_shift;
			var cc = ANIMATOR.is_playing? COLORS._main_value_positive : COLORS._main_accent;
		
			draw_set_color(cc);
			draw_set_font(f_p2);
			draw_line(bar_line_x, 0, bar_line_x, dope_sheet_h);
			
			var cf = string(ANIMATOR.current_frame + 1);
			var tx = string_width(cf) + ui(4);
			draw_rectangle(bar_line_x - tx, 0, bar_line_x, ui(16), false);
			draw_roundrect_ext(bar_line_x - tx - ui(2), 0, bar_line_x, ui(16), ui(2), ui(2), false);
			
			draw_set_text(f_p2, fa_right, fa_top, COLORS._main_icon_dark);
			draw_text(bar_line_x - ui(2), 0, cf);
		#endregion
				
		gpu_set_blendmode(bm_subtract);
		draw_surface_safe(dope_sheet_mask, 0, 0);
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
			
		drawDopesheetName();
			
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), ui(8), tool_width, dope_sheet_h);
		draw_surface_safe(ds_name_surface, ui(8), ui(8));
		draw_surface_safe(dope_sheet_surface, bar_x, ui(8));
	}
	
	function drawAnimationControl() {
		var bx = ui(8);
		var by = h - ui(40);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("stop", "Stop"), THEME.sequence_control, 4, ANIMATOR.is_playing? COLORS._main_accent : COLORS._main_icon) == 2) {
			ANIMATOR.is_playing = false;
			ANIMATOR.setFrame(0);
		}
		
		bx += ui(36);
		var ind = !ANIMATOR.is_playing;
		var cc  = ANIMATOR.is_playing? COLORS._main_accent : COLORS._main_icon;
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, ANIMATOR.is_playing? get_text("pause", "Pause") : get_text("play", "Play"), THEME.sequence_control, ind, cc) == 2) {
			ANIMATOR.is_playing = !ANIMATOR.is_playing;
			ANIMATOR.frame_progress = true;
		}
		
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_animation_go_to_first_frame", "Go to first frame"), THEME.sequence_control, 3) == 2) {
			ANIMATOR.setFrame(0);
		}
			
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_animation_go_to_last_frame", "Go to last frame"), THEME.sequence_control, 2) == 2) {
			ANIMATOR.setFrame(ANIMATOR.frames_total - 1);
		}
			
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_animation_previous_frame", "Previous frame"), THEME.sequence_control, 5) == 2) {
			ANIMATOR.setFrame(ANIMATOR.real_frame - 1);
		}
			
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_animation_next_frame", "Next frame"), THEME.sequence_control, 6) == 2) {
			ANIMATOR.setFrame(ANIMATOR.real_frame + 1);
		}
		
		bx = w - ui(44);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_animation_animation_settings", "Animation settings"), THEME.animation_setting, 2) == 2)
			dialogCall(o_dialog_animation, x + bx + 32, y + by - 8);
			
		if(dope_sheet_h > 8) {
			by -= ui(40);
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, get_text("panel_animation_scale_animation", "Scale animation"), THEME.animation_timing, 2) == 2) {
				var dia = dialogCall(o_dialog_anim_time_scaler, x + bx + ui(32), y + by - ui(8));
				dia.anchor = ANCHOR.right | ANCHOR.bottom;
			}
			
			by = ui(8);
			var txt = show_node_outside_context? get_text("panel_animation_hide_node", "Hide node outside context") : get_text("panel_animation_show_node", "Show node outside context");
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(24), [mx, my], pFOCUS, pHOVER, txt, THEME.junc_visible, show_node_outside_context) == 2)
				show_node_outside_context = !show_node_outside_context;
		}
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		drawTimeline();
		if(dope_sheet_h > 8)
			drawDopesheet();
		drawAnimationControl();
		
		if(timeline_show_time > -1) {
			TOOLTIP = get_text("frame", "Frame") + " " + string(timeline_show_time + 1) + "/" + string(ANIMATOR.frames_total);
			timeline_show_time = -1;
		}
	}
	
	function doDuplicate() {
		if(ds_list_empty(keyframe_selecting)) return;
		
		var clones = ds_list_create();
		for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
			ds_list_add(clones, keyframe_selecting[| i].cloneAnimator());
		}
		
		ds_list_destroy(keyframe_selecting);
		keyframe_selecting = clones;
		
		keyframe_dragging  = keyframe_selecting[| 0];
		keyframe_drag_type = KEYFRAME_DRAG_TYPE.move;
		keyframe_drag_mx   = mx;
		keyframe_drag_my   = my;
	}
	
	copy_clipboard = ds_list_create();
	function doCopy() {
		ds_list_clear(copy_clipboard);
		for( var i = 0; i < ds_list_size(keyframe_selecting); i++ )
			ds_list_add(copy_clipboard, keyframe_selecting[| i]);
	}
	
	function doPaste() {
		if(ds_list_empty(copy_clipboard)) return;
		
		var shf  = 0;
		var minx = ANIMATOR.frames_total + 2;
		for( var i = 0; i < ds_list_size(copy_clipboard); i++ )
			minx = min(minx, copy_clipboard[| i].time);
		shf = ANIMATOR.current_frame - minx; print(minx);
		
		for( var i = 0; i < ds_list_size(copy_clipboard); i++ )
			copy_clipboard[| i].cloneAnimator(shf);
	}
}