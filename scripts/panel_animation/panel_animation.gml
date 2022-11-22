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
	
	timeline_show_time = -1;
	timeline_preview = noone;
	
	keyframe_dragging = noone;
	keyframe_drag_type = -1;
	keyframe_selecting = ds_list_create();
	keyframe_boxing = false;
	keyframe_box_sx = -1;
	keyframe_box_sy = -1;
	
	stagger_mode  = 0;
	stagger_index = 0;
	
	graph_h = ui(48);        
	
	anim_properties = ds_list_create();
	
	prev_cache = array_create(ANIMATOR.frames_total);
	
	addHotkey("", "Play/Pause",		vk_space, MOD_KEY.none,	function() { 
		ANIMATOR.is_playing = !ANIMATOR.is_playing; 
		if(ANIMATOR.is_playing && ANIMATOR.frames_total) {
			ANIMATOR.real_frame = 0;
		}
	});
	addHotkey("", "First frame",	vk_home,  MOD_KEY.none,	function() { ANIMATOR.real_frame = 0; });
	addHotkey("", "Last frame",		vk_end,   MOD_KEY.none,	function() { ANIMATOR.real_frame = ANIMATOR.frames_total - 1; });
	addHotkey("", "Next frame",		vk_right, MOD_KEY.none,	function() { 
		ANIMATOR.real_frame = min(ANIMATOR.real_frame + 1, ANIMATOR.frames_total - 1); 
		ANIMATOR.frame_progress = true; 
	});
	addHotkey("", "Previous frame",	vk_left, MOD_KEY.none,	function() { 
		ANIMATOR.real_frame = max(ANIMATOR.real_frame - 1, 0); 
		ANIMATOR.frame_progress = true; 
	});
	addHotkey("Animation", "Delete keys",	vk_delete, MOD_KEY.none, function() { deleteKeys(); });
	
	function deleteKeys() {
		for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
			var k  = keyframe_selecting[| i];
			k.anim.removeKey(k);
		}
		ds_list_clear(keyframe_selecting);
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
			var prop = anim_properties[| i];	
			for(var k = 0; k < ds_list_size(prop.animator.values); k++) {
				var keyframe = prop.animator.values[| k];
				
				if(ds_list_exist(keyframe_selecting, keyframe))
					ds_list_add(l, keyframe);
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
		[ "Ease in",  [ 
			[ [THEME.timeline_ease, 0], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_in = 0;
				}
			} ],
			[ [THEME.timeline_ease, 1], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_in_type = CURVE_TYPE.bezier;
				}
			} ],
			[ [THEME.timeline_ease, 3], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_in_type = CURVE_TYPE.damping;
				}
			} ],
		]],
		[ "Ease out",  [ 
			[ [THEME.timeline_ease, 0], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_out = 0;
				}
			} ],
			[ [THEME.timeline_ease, 1], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_out_type = CURVE_TYPE.bezier;
				}
			} ],
			[ [THEME.timeline_ease, 3], function() { 
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k = keyframe_selecting[| i];
					k.ease_out_type = CURVE_TYPE.damping;
				}
			} ],
		]],
		-1,
		[ "Align",  [ 
			[ [THEME.timeline_key_halign, 0], function() { alignKeys(fa_left); } ],
			[ [THEME.timeline_key_halign, 1], function() { alignKeys(fa_center); } ],
			[ [THEME.timeline_key_halign, 2], function() { alignKeys(fa_right); } ],
		]],
		[ "Stagger", function() { stagger_mode = 1; }],
		-1,
		[ "Delete", function() { deleteKeys(); }, [ "Animation", "Delete keys" ] ],
	];
	
	function onResize(dw, dh) {
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
		ds_list_clear(anim_properties);
		var amo = ds_map_size(NODE_MAP);
		var k = ds_map_find_first(NODE_MAP);
		
		repeat(amo) {
			var _node = NODE_MAP[? k];
			k = ds_map_find_next(NODE_MAP, k);
			
			if(!_node.active) continue;
			
			for(var j = 0; j < ds_list_size(_node.inputs); j++) {
				var jun = _node.inputs[| j];
				if(jun.animator.is_anim)
					ds_list_add(anim_properties, jun);
			}
		}
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
				
			//TODO: Add UI scaling, no one use timeline preview anyway
			//if(timeline_scale > 16 && timeline_preview != noone) {
			//	var prev_s = timeline_scale - ui(4);
			//	draw_set_color(COLORS.panel_animation_preview_frame);
			//	for(var i = 0; i < ANIMATOR.frames_total; i++) {
			//		var fr_x = i * timeline_scale + timeline_shift + ui(2);
			//		var fr_y = timeline_h - ui(2) - prev_s;
						
			//		var surf = timeline_preview.cached_output[i];
			//		if(!surf || !surface_exists(surf)) continue;
						
			//		var ss = prev_s / max(surface_get_width(surf), surface_get_height(surf));
			//		draw_rectangle(fr_x, fr_y, fr_x + prev_s, fr_y + prev_s, 1);
						
			//		draw_surface_ext(surf, fr_x, fr_y, ss, ss, 0, c_white, 1);
			//	}
			//}
			
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
					if(i >= array_length(inspecting.cached_output)) 
						break;
						
					var x0 = (i + 0) * ui(timeline_scale) + timeline_shift;
					var x1 = (i + 1) * ui(timeline_scale) + timeline_shift;
					
					var sh = inspecting.cached_output[i];
					draw_set_color(is_surface(sh)? c_lime : c_red);
					draw_set_alpha(0.5);
					draw_rectangle(x0, bar_h - ui(4), x1, bar_h, false);
					draw_set_alpha(1);
				}
			}
		#endregion
			
		#region summary
			var index = 0, key_y = timeline_h / 2;
					
			for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
				var prop = anim_properties[| i];	
					
				for(var k = 0; k < ds_list_size(prop.animator.values); k++) {
					var t = (prop.animator.values[| k].time + 1) * ui(timeline_scale) + timeline_shift;
					draw_sprite_ui_uniform(THEME.timeline_keyframe, 1, t, key_y, 1, COLORS.panel_animation_keyframe_hide);
				}
			}
		#endregion
			
		#region pan zoom
			timeline_shift = lerp_float(timeline_shift, timeline_shift_to, 5);
				
			if(timeline_scubbing) {
				ANIMATOR.real_frame = (mx - bar_x - timeline_shift) / ui(timeline_scale) - 1;
				ANIMATOR.real_frame = clamp(ANIMATOR.real_frame, 0, ANIMATOR.frames_total - 1);
				timeline_show_time  = ANIMATOR.current_frame;
					
				if(timeline_show_time != _scrub_frame) {
					_scrub_frame = timeline_show_time;
					ANIMATOR.is_scrubing = true;
				}
					
				if(mouse_check_button_released(mb_left))
					timeline_scubbing = false;
			}
			if(timeline_dragging) {
				timeline_shift_to = clamp(timeline_drag_sx + mx - timeline_drag_mx, -max(bar_total_w - bar_w, 0), 0);
				timeline_shift = timeline_shift_to;
				dope_sheet_y_to = clamp(timeline_drag_sy + my - timeline_drag_my, -dope_sheet_y_max, 0);
					
				if(mouse_check_button_released(mb_middle))
					timeline_dragging = false;
			}
				
			if(pHOVER) {
				if(point_in_rectangle(mx, my, bar_x, 16, bar_x + bar_w, bar_y - 8)) {
					if(mouse_wheel_down()) {
						timeline_scale = max(timeline_scale - 1, 1);
						timeline_shift_to = 0;
					}
					
					if(mouse_wheel_up()) {
						timeline_scale = min(timeline_scale + 1, 24);
						timeline_shift_to = 0;
					}
						
					if(mouse_check_button_pressed(mb_middle)) {
						timeline_dragging = true;
					
						timeline_drag_sx = timeline_shift;
						timeline_drag_sy = dope_sheet_y_to;
						timeline_drag_mx = mx;
						timeline_drag_my = my;
					}
				}
					
				if(point_in_rectangle(mx, my, bar_x, bar_y, bar_x + bar_w, bar_y + bar_h)) {
					if(mouse_wheel_down())
						timeline_shift_to = clamp(timeline_shift_to - 64, -max(bar_total_w - bar_w, 0), 0);
					if(mouse_wheel_up())
						timeline_shift_to = clamp(timeline_shift_to + 64, -max(bar_total_w - bar_w, 0), 0);
						
					if(pFOCUS && mouse_check_button_pressed(mb_left)) {
						timeline_scubbing = true;
						timeline_scub_st  = ANIMATOR.current_frame;
						_scrub_frame = timeline_scub_st;
					}
				}
					
				if(point_in_rectangle(mx, my, bar_x, 8, bar_x + bar_w, 8 + 16)) {
					if(pFOCUS && mouse_check_button_pressed(mb_left)) {
						timeline_scubbing = true;
						timeline_scub_st  = ANIMATOR.current_frame;
						_scrub_frame = timeline_scub_st;
					}
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
		
		for(var k = 0; k < amo; k++) {
			var key = prop.animator.values[| k];
			var t = (key.time + 1) * ui(timeline_scale) + timeline_shift;
								
			#region easing line
				if(key.ease_in > 0) {
					draw_set_color(COLORS.panel_animation_keyframe_ease_line);
					var _tx = t - key.ease_in * ui(timeline_scale) * 2;
					if(key.ease_in_type == CURVE_TYPE.bezier)
						draw_line_width(_tx, key_y - 1, t, key_y - 1, 2);
					else if(key.ease_in_type == CURVE_TYPE.damping)
						draw_sprite_stretched_ext(THEME.timeline_elastic, 0, _tx, key_y - 4, t - _tx, 8, COLORS.panel_animation_keyframe_ease_line, 1);
											
					if(pHOVER && point_in_circle(msx, msy, _tx, key_y, ui(6))) {
						hovering = key;
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 2, _tx, key_y, 1, COLORS.panel_animation_keyframe_selected);
						if(pFOCUS && mouse_check_button_pressed(mb_left)) {
							keyframe_dragging = prop.animator.values[| k];
							keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_in;
						}
					} else 
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 2, _tx, key_y, 1, COLORS.panel_animation_keyframe_unselected);
				} 
						
				if(key.ease_out > 0) {
					draw_set_color(COLORS.panel_animation_keyframe_ease_line);
					var _tx = t + key.ease_out * ui(timeline_scale) * 2;
					if(key.ease_out_type == CURVE_TYPE.bezier)
						draw_line_width(t, key_y - 1, _tx, key_y - 1, 2);
					else if(key.ease_out_type == CURVE_TYPE.damping)
						draw_sprite_stretched_ext(THEME.timeline_elastic, 0, t, key_y - 4, _tx - t, 8, COLORS.panel_animation_keyframe_ease_line, 1);
										
					if(pHOVER && point_in_circle(msx, msy, _tx, key_y, ui(6))) {
						hovering = key;
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 3, _tx, key_y, 1, COLORS.panel_animation_keyframe_selected);
						if(pFOCUS && mouse_check_button_pressed(mb_left)) {
							keyframe_dragging = prop.animator.values[| k];
							keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_out;
						}
					} else
						draw_sprite_ui_uniform(THEME.timeline_keyframe, 3, _tx, key_y, 1, COLORS.panel_animation_keyframe_unselected);
				}
			#endregion
								
			if(prop.animator.show_graph && k < amo - 1) { //graph
				var key_next = prop.animator.values[| k + 1];
				var a = key.ease_out;
				var b = key_next.ease_in;
				var dx = key_next.time - key.time;
				var tott = a + b;
				var ox = 0, oy = 0, nx = 0, ny = 0, oly = 0, nly = 0;
										
				if(tott == 0) {
					nx = (key_next.time + 1) * ui(timeline_scale) + timeline_shift;
					if(is_array(key.value)) {
						for( var ki = 0; ki < array_length(key.value); ki++ ) {
							draw_set_color(COLORS.axis[ki]);
							oy = value_map(key.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
							ny = value_map(key_next.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
							draw_line(t, oy, nx, ny);
						}
					} else {
						draw_set_color(COLORS.panel_animation_graph_line);
						var oy = value_map(key.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
						var ny = value_map(key_next.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
						draw_line(t, oy, nx, ny);
					}
				} else {
					a = a;
					b = 1 - b;
										
					var _step = 1 / 20;
					for( var _r = 0; _r <= 1; _r += _step ) {
						nx = t + _r * dx * ui(timeline_scale);
						var nly = prop.animator.interpolate(key, key_next, _r);
												
						if(is_array(key.value)) {
							for( var ki = 0; ki < array_length(key.value); ki++ ) {
								ny = value_map(lerp(key.value[ki], key_next.value[ki], nly), _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
													
								if(_r > 0) {
									draw_set_color(COLORS.axis[ki]);
									oy = value_map(lerp(key.value[ki], key_next.value[ki], oly), _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
									draw_line(ox, oy, nx, ny);
								}
							}
						} else {
							draw_set_color(COLORS.panel_animation_graph_line);
							ny = value_map(lerp(key.value, key_next.value, nly), _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
							if(_r > 0) {
								oy = value_map(lerp(key.value, key_next.value, oly), _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
								draw_line(ox, oy, nx, ny);
							}
						}
											
						ox = nx;
						oly = nly;
					}
				}
			}
		}
		
		if(prop.animator.show_graph && ds_list_size(prop.animator.values) > 0) {
			var key_first = prop.animator.values[| 0];
			var t_first = (key_first.time + 1) * ui(timeline_scale) + timeline_shift;
									
			var key_last = prop.animator.values[| ds_list_size(prop.animator.values) - 1];
			var t_last = (key_last.time + 1) * ui(timeline_scale) + timeline_shift;
									
			var oy = 0;
									
			if(is_array(key_last.value)) {
				for( var ki = 0; ki < array_length(key_last.value); ki++ ) {
					draw_set_color(COLORS.axis[ki]);
					oy = value_map(key_last.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
					draw_line(t_last, oy, bar_total_w, oy);
											
					oy = value_map(key_first.value[ki], _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
					draw_line(0, oy, t_first, oy);
				}
			} else {
				draw_set_color(COLORS.panel_animation_graph_line);
				var oy = value_map(key_last.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
				draw_line(t_last, oy, bar_total_w, oy);
										
				var oy = value_map(key_first.value, _gy_val_min, _gy_val_max, _gy_bottom, _gy_top);
				draw_line(0, oy, t_first, oy);
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
		draw_set_text(f_p2, fa_left, fa_center);
				
		for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
			var prop = anim_properties[| i];	
						
			if(_node != prop.node) {
				_node = prop.node;
							
				key_y += ui(6);
				if(pHOVER && point_in_rectangle(msx, msy, 0, key_y - ui(10), lable_w, key_y + ui(10))) {
					draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, key_y - ui(10), lable_w, ui(20), COLORS.panel_animation_dope_bg_hover, 1);
					if(pFOCUS && msx < tool_width - ui(88) && mouse_check_button_pressed(mb_left))
						prop.node.anim_show = !prop.node.anim_show;
				} else 
					draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, key_y - ui(10), lable_w, ui(20), COLORS.panel_animation_dope_bg, 1);
							
				if(prop.node == PANEL_INSPECTOR.inspecting)
					draw_sprite_stretched_ext(THEME.node_active, 0, 0, key_y - ui(10), lable_w, ui(20), COLORS._main_accent, 1);
							
				var tx = tool_width - ui(76 + 16 * 0);
				if(pHOVER && point_in_circle(msx, msy, tx, key_y - 1, ui(10))) {
					draw_sprite_ui_uniform(THEME.animate_node_go, 0, tx, key_y - 1, 1, COLORS._main_icon, 1);
					TOOLTIP = "Go to node";
								
					if(pFOCUS && mouse_check_button_pressed(mb_left)) {
						PANEL_INSPECTOR.inspecting = _node;
						ds_list_clear(PANEL_GRAPH.nodes_select_list);
						PANEL_GRAPH.node_focus = _node;
						PANEL_GRAPH.fullView();
					}
				} else
					draw_sprite_ui_uniform(THEME.animate_node_go, 0, tx, key_y - 1, 1, COLORS._main_icon, 0.75);
							
				draw_sprite_ui_uniform(THEME.arrow, prop.node.anim_show? 3 : 0, ui(10), key_y, 1, COLORS._main_icon, 0.75);
				draw_set_color(COLORS._main_text_sub);
				draw_text(ui(20), key_y - ui(2), prop.node.name);
				key_y += ui(22);
			}
						
			if(!prop.node.anim_show) continue;
						
			var tx = tool_width - ui(72 + 16 * 3);
			var ty = key_y - 1;
			if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(6))) {
				draw_sprite_ui_uniform(THEME.prop_keyframe, 0, tx, ty, 1, COLORS._main_icon, 1);
							
				if(pFOCUS && mouse_check_button_pressed(mb_left)) {
					var _t = -1;
					for(var j = 0; j < ds_list_size(prop.animator.values); j++) {
						var _key = prop.animator.values[| j];
						if(_key.time < ANIMATOR.current_frame) {
							_t = _key.time;
						}
					}
					if(_t > -1) ANIMATOR.real_frame = _t;
					ANIMATOR.is_scrubing = true;
				}
			} else
				draw_sprite_ui_uniform(THEME.prop_keyframe, 0, tx, ty, 1, COLORS._main_icon, 0.75);
						
			var tx = tool_width - ui(72 + 16 * 1);
			if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(6))) {
				draw_sprite_ui_uniform(THEME.prop_keyframe, 2, tx, ty, 1, COLORS._main_icon, 1);
							
				if(pFOCUS && mouse_check_button_pressed(mb_left)) {
					for(var j = 0; j < ds_list_size(prop.animator.values); j++) {
						var _key = prop.animator.values[| j];
						if(_key.time > ANIMATOR.current_frame) {
							ANIMATOR.real_frame = _key.time;
							ANIMATOR.is_scrubing = true;
							break;
						}
					}
				}
			} else
				draw_sprite_ui_uniform(THEME.prop_keyframe, 2, tx, ty, 1, COLORS._main_icon, 0.75);
						
			var tx = tool_width - ui(72 + 16 * 2);
			if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(6))) {
				draw_sprite_ui_uniform(THEME.prop_keyframe, 1, tx, ty, 1, COLORS._main_accent, 1);
							
				if(pFOCUS && mouse_check_button_pressed(mb_left)) {
					var _add = false;
					for(var j = 0; j < ds_list_size(prop.animator.values); j++) {
						var _key = prop.animator.values[| j];
						if(_key.time == ANIMATOR.current_frame) {
							if(ds_list_size(prop.animator.values) > 1)
								ds_list_delete(prop.animator.values, j);
							_add = true;
							break;
						} else if(_key.time > ANIMATOR.current_frame) {
							ds_list_insert(prop.animator.values, j, new valueKey(ANIMATOR.current_frame, prop.getValue(), prop.animator));
							_add = true;
							break;	
						}
					}
					if(!_add) ds_list_add(prop.animator.values, new valueKey(ANIMATOR.current_frame, prop.getValue(), prop.animator));	
				}
			} else
				draw_sprite_ui_uniform(THEME.prop_keyframe, 1, tx, ty, 1, COLORS._main_accent, 0.75);
						
			if(isGraphable(prop.type)) {
				var tx = tool_width - ui(68 + 16 * 0);
				if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(8))) {
					draw_sprite_ui_uniform(THEME.timeline_graph, 1, tx, ty, 1, COLORS._main_icon, prop.animator.show_graph? 1 : 0.75);
					TOOLTIP = "Show graph";
								
					if(pFOCUS && mouse_check_button_pressed(mb_left)) {
						prop.animator.show_graph = !prop.animator.show_graph;
					}
				} else
					draw_sprite_ui_uniform(THEME.timeline_graph, 1, tx, ty, 1, prop.animator.show_graph? COLORS._main_accent : COLORS._main_icon);
			}
						
			var tx = tool_width - ui(72 + 16 * 4.5);
			if(pHOVER && point_in_circle(msx, msy, tx, ty, ui(6))) {
				draw_sprite_ui_uniform(THEME.prop_on_end, prop.on_end, tx, ty, 1, COLORS._main_icon, 1);
				TOOLTIP = "Looping mode " + ON_END_NAME[prop.on_end];
							
				if(pFOCUS && mouse_check_button_pressed(mb_left)) {
					prop.on_end = safe_mod(prop.on_end + 1, sprite_get_number(THEME.prop_on_end));
				}
			} else
				draw_sprite_ui_uniform(THEME.prop_on_end, prop.on_end, tx, ty, 1, COLORS._main_icon, 0.75);
						
			if(pHOVER && point_in_circle(msx, msy, ui(22), key_y - 1, ui(10))) {
				draw_sprite_ui_uniform(THEME.timeline_clock, 1, ui(22), key_y - 1, 1, COLORS._main_icon, 1);
							
				if(pFOCUS && mouse_check_button_pressed(mb_left)) {
					prop.animator.is_anim = !prop.animator.is_anim;
					updatePropertyList();
				}
			} else
				draw_sprite_ui_uniform(THEME.timeline_clock, 1, ui(22), key_y - 1, 1, COLORS._main_icon, 0.75);
							
			draw_set_color(COLORS._main_text);
			draw_text(ui(32), key_y - 2, prop.name);
						
			if(prop.animator.show_graph)
				key_y += graph_h + ui(8);
							
			key_y += ui(18);
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
			dope_sheet_y = lerp_float(dope_sheet_y, dope_sheet_y_to, 5);
					
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
					
				if(mouse_check_button_released(mb_left)) is_scrolling = false;
			}
				
			if(point_in_rectangle(mx, my, scr_x - ui(2), scr_y - ui(2), scr_x + scr_w + ui(2), scr_y + scr_h + ui(2))) {
				draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, s_bar_x, s_bar_y, s_bar_w, s_bar_h, COLORS.scrollbar_hover, 1);
				if(mouse_check_button(mb_left))
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
			draw_sprite_stretched(THEME.ui_panel_bg, 1, 0, 0, bar_w, dope_sheet_h);
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, 0, bar_total_w, dope_sheet_h, COLORS.panel_animation_timeline_blend, 1);
			
			draw_set_color(COLORS.panel_animation_timeline_top);
			draw_rectangle(0, 0, bar_total_w, 16, false);
					
			dope_sheet_y_max = 0;
			var key_y = ui(24) + dope_sheet_y, key_y_node, _node = noone;
			for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
				var prop = anim_properties[| i];	
						
				if(_node != prop.node) {
					_node = prop.node;
							
					key_y += ui(6);
					key_y_node = key_y;
							
					draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, key_y - ui(10), bar_total_w, ui(20), COLORS.panel_animation_node_bg, 1);
					key_y += ui(22);
					dope_sheet_y_max += ui(28);
				}
						
				if(prop.node.anim_show) {
					key_y += ui(18);
					dope_sheet_y_max += ui(18);
						
					if(prop.animator.show_graph) {
						draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, key_y - ui(4), bar_total_w, graph_h, COLORS.panel_animation_graph_bg, 1);
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
						
				draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text_sub);
				draw_text(bar_line_x, ui(16), string(i));
			}
				
			var bar_line_x = (ANIMATOR.current_frame + 1) * ui(timeline_scale) + timeline_shift;
			var cc = ANIMATOR.is_playing? COLORS._main_value_positive : COLORS._main_accent;
			
			draw_set_color(cc);
			draw_line(bar_line_x, ui(16), bar_line_x, dope_sheet_h);
				
			draw_set_text(f_p2, fa_center, fa_bottom, cc);
			draw_text(bar_line_x, ui(16), string(ANIMATOR.current_frame + 1));
		#endregion
		
		var key_sy = ui(24) + dope_sheet_y;
		var key_y, key_y_node, _node = noone;
		draw_set_text(f_p2, fa_left, fa_top);
		var key_hover = noone;
			
		key_y = key_sy;
		for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
			var prop = anim_properties[| i];	
						
			if(_node != prop.node) {
				_node = prop.node;
				key_y += ui(28);
			}
				
			if(!prop.node.anim_show) continue;
				
			var key_list = prop.animator.values;
			if(prop.node.anim_show && prop.on_end != KEYFRAME_END.hold && ds_list_size(key_list) > 1) {
				var keyframe_s = key_list[| 0].time;
				var keyframe_e = key_list[| ds_list_size(key_list) - 1].time;
								
				var ks_x = keyframe_s * ui(timeline_scale) + timeline_shift;
				var ke_x = keyframe_e * ui(timeline_scale) + timeline_shift;
								
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
					
		key_y = key_sy;
		_node = noone;
						
		if(keyframe_boxing) {
			draw_set_color(COLORS._main_accent);
			draw_rectangle(keyframe_box_sx, keyframe_box_sy, msx, msy, true);
			draw_set_alpha(0.05);
			draw_rectangle(keyframe_box_sx, keyframe_box_sy, msx, msy, false);
			draw_set_alpha(1);
					
			if(mouse_check_button_released(mb_left))
				keyframe_boxing = false;
		}
							
		for( var i = 0; i < ds_list_size(anim_properties); i++ ) {
			var prop = anim_properties[| i];	
						
			if(_node != prop.node) {
				_node = prop.node;
							
				key_y += ui(6);
				key_y_node = key_y;
				key_y += ui(22);
			}
							
			for(var k = 0; k < ds_list_size(prop.animator.values); k++) {
				var t = (prop.animator.values[| k].time + 1) * ui(timeline_scale) + timeline_shift;
				var keyframe = prop.animator.values[| k];
								
				if(!prop.node.anim_show) {
					draw_sprite_ui_uniform(THEME.timeline_keyframe, 0, t, key_y_node, 1, COLORS.panel_animation_keyframe_hide);
					continue;
				}
								
				var cc = COLORS.panel_animation_keyframe_unselected;
				if(pHOVER && point_in_circle(msx, msy, t, key_y, ui(8))) {
					cc = COLORS.panel_animation_keyframe_selected;
					key_hover = keyframe;
									
					if(pFOCUS) {
						if(DOUBLE_CLICK) {
							keyframe_dragging = keyframe;
							keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_both;
						} else if(mouse_check_button_pressed(mb_left)) {
							keyframe_dragging = keyframe;
							keyframe_drag_type = KEYFRAME_DRAG_TYPE.move;
						}
					}
				}
								
				if(stagger_mode == 1 && ds_list_exist(keyframe_selecting, keyframe))
					cc = key_hover == keyframe? COLORS.panel_animation_keyframe_selected : COLORS._main_accent;
									
				draw_sprite_ui_uniform(THEME.timeline_keyframe, 1, t, key_y, 1, cc);
				if(ds_list_exist(keyframe_selecting, keyframe)) 
					draw_sprite_ui_uniform(THEME.timeline_keyframe_selecting, 0, t, key_y, 1, COLORS._main_accent);
								
				if(keyframe_boxing) {
					var box_x0 = min(keyframe_box_sx, msx);
					var box_x1 = max(keyframe_box_sx, msx);
					var box_y0 = min(keyframe_box_sy, msy);
					var box_y1 = max(keyframe_box_sy, msy);
									
					if(!point_in_rectangle(t, key_y, box_x0, box_y0, box_x1, box_y1) && ds_list_exist(keyframe_selecting, keyframe))
						ds_list_remove(keyframe_selecting, keyframe);
					if(point_in_rectangle(t, key_y, box_x0, box_y0, box_x1, box_y1) && !ds_list_exist(keyframe_selecting, keyframe))
						ds_list_add(keyframe_selecting, keyframe);
				}
			}
							
			if(prop.node.anim_show) {
				if(prop.animator.show_graph)
					key_y += graph_h + ui(8);
							
				key_y += 18;
			}
		}
						
		if(pFOCUS && point_in_rectangle(msx, msy, 0, ui(16), dope_sheet_w, dope_sheet_h)) {
			if(mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)) {
				if(key_hover == noone) {
					ds_list_clear(keyframe_selecting);
				} else {
					if(keyboard_check(vk_shift)) {
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
							
			if(mouse_check_button_pressed(mb_left)) {
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
						
		if(pFOCUS && mouse_check_button_pressed(mb_right)) {
			if(!ds_list_empty(keyframe_selecting)) {
				dialogCall(o_dialog_menubox, mouse_mx + ui(8), mouse_my + ui(8))
					.setMenu(keyframe_menu);
			}
		}
						
		if(keyframe_dragging) {
			if(keyframe_drag_type == KEYFRAME_DRAG_TYPE.move) {
				var tt = round((mx - bar_x - timeline_shift) / ui(timeline_scale)) - 1;
				tt = clamp(tt, 0, ANIMATOR.frames_total - 1);
				var sh = tt - keyframe_dragging.time;
								
				for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
					var k  = keyframe_selecting[| i];
					var kt = k.time + sh;
									
					k.anim.setKeyTime(k, kt, false);
				}
								
				timeline_show_time     = floor(tt);
								
				if(mouse_check_button_released(mb_left)) {
					keyframe_dragging = noone;
									
					for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
						var k  = keyframe_selecting[| i];
						k.anim.setKeyTime(k, k.time);
					}
				}
			} else {
				var dx = ((keyframe_dragging.time + 1) - (mx - bar_x) / ui(timeline_scale)) / 2;
				dx = clamp(abs(dx), 0, 0.9);
				if(dx < 0.1) dx = 0;
							
				var _in = keyframe_dragging.ease_in;
				var _ot = keyframe_dragging.ease_out;							
				switch(keyframe_drag_type) {
					case KEYFRAME_DRAG_TYPE.ease_in :
						for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
							var k = keyframe_selecting[| i];
							k.ease_in = dx;
						}
						break;
					case KEYFRAME_DRAG_TYPE.ease_out :
						for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
							var k = keyframe_selecting[| i];
							k.ease_out = dx;
						}
						break;
					case KEYFRAME_DRAG_TYPE.ease_both :
						for( var i = 0; i < ds_list_size(keyframe_selecting); i++ ) {
							var k  = keyframe_selecting[| i];
							k.ease_in = dx;
							k.ease_out = dx;
						}
						break;
				}
								
				if(mouse_check_button_released(mb_left)) {
					recordAction(ACTION_TYPE.var_modify, keyframe_dragging, [_in, "ease_in"]);
					recordAction(ACTION_TYPE.var_modify, keyframe_dragging, [_ot, "ease_out"]);
								
					keyframe_dragging = noone;
				}
			}
		}
					
		if(stagger_mode == 2) {
			var ts = keyframe_selecting[| stagger_index].time;
			var tm = round((mx - bar_x - timeline_shift) / ui(timeline_scale)) - 1;
			tm = clamp(tm, 0, ANIMATOR.frames_total - 1);
			
			var stg = tm - ts;
			staggerKeys(stagger_index, stg);
		}
				
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
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Stop", THEME.sequence_control, 4, ANIMATOR.is_playing? COLORS._main_accent : COLORS._main_icon) == 2) {
			ANIMATOR.is_playing = false;
			ANIMATOR.real_frame = 0;
		}
		
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, ANIMATOR.is_playing? "Pause" : "Play", 
			THEME.sequence_control, !ANIMATOR.is_playing, ANIMATOR.is_playing? COLORS._main_accent : COLORS._main_icon) == 2)
				
			ANIMATOR.is_playing = !ANIMATOR.is_playing;
		
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Go to first frame", THEME.sequence_control, 3) == 2) {
			ANIMATOR.real_frame = 0;
			ANIMATOR.is_scrubing = true;
		}
			
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Go to last frame", THEME.sequence_control, 2) == 2) {
			ANIMATOR.real_frame = ANIMATOR.frames_total - 1;
			ANIMATOR.is_scrubing = true;
		}
			
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Previous frame", THEME.sequence_control, 5) == 2) {
			ANIMATOR.real_frame = clamp(ANIMATOR.real_frame - 1, 0, ANIMATOR.frames_total - 1);
			ANIMATOR.is_scrubing = true;
		}
			
		bx += ui(36);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Next frame", THEME.sequence_control, 6) == 2) {
			ANIMATOR.real_frame = clamp(ANIMATOR.real_frame + 1, 0, ANIMATOR.frames_total - 1);
			ANIMATOR.is_scrubing = true;
		}
		
		bx = w - ui(40);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Animation settings", THEME.animation_setting, 2) == 2)
			dialogCall(o_dialog_animation, x + bx + 32, y + by - 8);
			
		if(dope_sheet_h > 8) {
			by -= ui(40);
			bx = w - ui(40);
			if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, "Scale animation", THEME.animation_timing, 2) == 2) {
				var dia = dialogCall(o_dialog_anim_time_scaler, x + bx + ui(32), y + by - ui(8));
				dia.anchor = ANCHOR.right | ANCHOR.bottom;
			}
		}
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		drawTimeline();
		if(dope_sheet_h > 8)
			drawDopesheet();
		drawAnimationControl();
		
		if(timeline_show_time > -1) {
			TOOLTIP = "Frame " + string(timeline_show_time + 1) + "/" + string(ANIMATOR.frames_total);
			timeline_show_time = -1;
		}
	}
}