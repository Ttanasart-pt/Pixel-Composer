#region global
	enum KEYFRAME_DRAG_TYPE {
	    move,
	    ease_in,
	    ease_out, 
	    ease_both,
	    
	    scale,
	}
	
	enum KEYFRAME_MODULATE {
		envelope,
		randomize,
	}
#endregion

function Panel_Animation_Dopesheet() {
	
	#region ---- Dimension ----
		tool_width_drag  = false;
	    tool_width_start = 0;
	    tool_width_mx    = 0;
	    
	    is_scrolling       = false;
		dopesheet_y        = 0;
	    dopesheet_y_to     = 0;
	    dopesheet_y_max    = 0;
	    dopesheet_dragging = noone;
	    dopesheet_drag_mx  = 0;
	    
	    dopesheet_w            = w - tool_width;
        dopesheet_h            = h - timeline_h - ui(20);
        dopesheet_surface      = noone;
        dopesheet_mask         = noone;
        
        dopesheet_name_mask    = noone;
        dopesheet_name_surface = noone;
        dopesheet_name_hover   = false;
    #endregion
	
	#region ---- Timeline ----
		timeline_stretch      = 0;
        timeline_stretch_sx   = 0;
        timeline_stretch_mx   = 0;
        timeline_draggable    = true;
        timeline_frame_typing = false;
    	
    	tooltip_anim_end = new tooltipAnimEnd();
    	
    	scroll_s = sprite_get_width(THEME.ui_scrollbar);
        scroll_w = scroll_s;
        
        timeline_snap_points  = [];
        timeline_snap_line    = undefined;
        
        timeline_content_dragging   = undefined;
        timeline_content_drag_type  = 0;
        timeline_content_drag_dx    = 0;
		timeline_content_drag_mx    = 0;
		timeline_content_drag_range = [0,0];
	#endregion
	
    #region ---- Keyframes ----
        keyframe_dragging      = noone;
        keyframe_drag_type     = -1;
        keyframe_dragout       = false;
        keyframe_drag_mx       = 0;
        keyframe_drag_my       = 0;
        keyframe_drag_sv       = 0;
        keyframe_drag_st       = 0;
        
        keyframe_selecting     = [];
        keyframe_selecting_f   = noone;
        keyframe_selecting_l   = noone;
    	_keyframe_selecting_f  = noone;
        _keyframe_selecting_l  = noone;
        
        keyframe_boxable       = true;
        keyframe_boxing        = false;
        keyframe_box_sx        = -1;
        keyframe_box_sy        = -1;
        
        keyframe_graph_surface = noone;
        _graph_key_hover       = noone;
        _graph_key_hover_index = noone;
        _graph_key_hover_array = noone;
        _graph_key_hover_x     = noone;
        _graph_key_hover_y     = noone;
        graph_key_hover        = noone;
        graph_key_hover_index  = noone;
        graph_key_hover_array  = noone;
        graph_key_hover_range  = noone;
        
        graph_key_drag         = noone;
        graph_key_drag_index   = noone;
        graph_key_drag_array   = noone;
        graph_key_drag_range   = [0,1];
        graph_key_drag_value   = 0;
        graph_key_drag_yrange  = 1;
        
        graph_key_mx = 0;
        graph_key_my = 0;
        graph_key_sx = 0;
        graph_key_sy = 0;
    
        value_hovering = noone;
        value_focusing = noone;
        
        show_value = false;
        
        region_hovering = noone;
    #endregion
    
    #region ---- Display ---- 
        show_node_outside_context = true;
        show_nodes = true;
        
        tooltip_loop_prop = noone;
        tooltip_loop_type = new tooltipSelector(__txtx("panel_animation_looping_mode", "Looping mode"), global.junctionEndName);
    #endregion
    
    #region ---- Graph ----
    	graph_height_dragging = noone;
    	graph_height_drag_sy  = 0;
    	graph_height_drag_my  = 0;
    #endregion
    
    #region ---- Item Hover ----
        _item_dragging    = noone;
         item_dragging    = noone;
        item_dragging_mx  = noone;
        item_dragging_my  = noone;
        item_dragging_dx  = noone;
        item_dragging_dy  = noone;
        
        hovering_folder   = noone;
        hovering_order    = noone;
    #endregion
    
    #region ---- Actions ----
        stagger_mode  = 0;
        stagger_index = 0;
    
	    on_end_dragging_anim = noone;
	    onion_dragging       = noone;
	    prev_cache           = array_create(GLOBAL_TOTAL_FRAMES);
	    copy_clipboard       = ds_list_create();
	    
	    __keyframe_editing   = noone;
	    
	    modulate_animator    = noone;
	    modulate_type        = KEYFRAME_MODULATE.envelope;
	    modulate_keys        = [];
	    modulate_range       = [ 0, GLOBAL_TOTAL_FRAMES ];
	    modulate_value_range = [ 0, 0 ];
	    modulate_fade_anchor = [ 0, 0 ];
	    modulate_fade        = [ 0, 0 ];
	    modulate_curve       = CURVE_DEF_01;
	    
	    modulate_drag    = 0;
	    modulate_drag_mx = 0;
	#endregion
	
	#region ---- Draw ----
        bar_x = 0;
        bar_y = 0;
        bar_w = 1;
        bar_h = 1;
        bar_total_w     = 1;
        bar_total_shift = 1;
	#endregion
	
    #region ++++ Context Menu ++++
	    
	    #region actions
	        function edit_keyframe_value()   { if(array_empty(keyframe_selecting)) return; editKeyFrame(keyframe_selecting[0]); }
	        function edit_keyframe_lock_y()  { array_foreach(keyframe_selecting, function(k) /*=>*/ { k.ease_y_lock = !k.ease_y_lock; });   }
	        
	        function edit_keyframe_stagger() { stagger_mode = 1; }
	        function edit_keyframe_driver()  { dialogPanelCall(new Panel_Keyframe_Driver(keyframe_selecting[0]), mouse_mx + ui(8), mouse_my + ui(8)); }
	        
	        function dopesheet_new_folder()        { var _dir = new timelineItemGroup(); PROJECT.timelines.addItem(_dir); }
	        
	        function dopesheet_new_folder_select() { 
	        	var _dir = new timelineItemGroup(); 
	        	PROJECT.timelines.addItem(_dir); 
	        	
	        	var _nodes = PANEL_GRAPH.nodes_selecting;
	        	
	        	for( var i = 0, n = array_length(_nodes); i < n; i++ ) {
	        		var _item = _nodes[i].timeline_item;
	        		
		        	_item.removeSelf();
	                array_push(_dir.contents, _item);
	                _item.parent = _dir;
	        	}
	        }
	        
	        function dopesheet_expand()      { for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) timeline_contents[i].item.show = true;  }
	        function dopesheet_collapse()    { for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) timeline_contents[i].item.show = false; }
	        
	        function group_rename()          { context_selecting_item.item.rename();  }
	        function group_remove()          { context_selecting_item.item.destroy(); }
	        
	        function toggle_axis()           { context_selecting_prop.toggleAxisSeparation(); }
	        function separate_axis()         { context_selecting_prop.separateAxis();         }
	        function combine_axis()          { context_selecting_prop.combineAxis();          }
	        
	        function range_reset()     { 
            	recordAction_variable_change(PROJECT.animator, "frame_range_start", PROJECT.animator.frame_range_start);
            	recordAction_variable_change(PROJECT.animator, "frame_range_end",   PROJECT.animator.frame_range_end);
	        	PROJECT.animator.frame_range_start = undefined; 
            	PROJECT.animator.frame_range_end   = undefined;
	        }
	        
	        function range_set_start() { 
	        	recordAction_variable_change(PROJECT.animator, "frame_range_start", PROJECT.animator.frame_range_start);
	        	recordAction_variable_change(PROJECT.animator, "frame_range_end",   PROJECT.animator.frame_range_end);
	        	PROJECT.animator.frame_range_start = __selecting_frame; 
	        	PROJECT.animator.frame_range_end   = PROJECT.animator.frame_range_end ?? PROJECT.animator.frames_total;
	        }
	        
	        function range_set_end()   { 
	        	recordAction_variable_change(PROJECT.animator, "frame_range_start", PROJECT.animator.frame_range_start);
	        	recordAction_variable_change(PROJECT.animator, "frame_range_end",   PROJECT.animator.frame_range_end);
	        	PROJECT.animator.frame_range_start = PROJECT.animator.frame_range_start ?? 0; 
	        	PROJECT.animator.frame_range_end   = __selecting_frame; 
	        }
	        
		    context_selecting_item = noone;
		    context_selecting_prop = noone;
		    
		    function setSelectingItemColor(color) { if(context_selecting_item == noone) return; context_selecting_item.item.setColor(color); }
	    
	    #endregion
	    
	    global.menuItems_animation_keyframe = [
	        "animation_edit_keyframe_value",
	        "animation_group_ease_in",
	        "animation_group_ease_out",
	        -1,
	        "animation_group_align",
	        "animation_driver",
	        "animation_reverse",
	        "animation_stagger",
	        "animation_envelope",
	        -1,
	        "animation_delete_keys",
	        "animation_duplicate",
	        "animation_copy",
	        "animation_paste",
	    ];
	    
	    global.menuItems_animation_keyframe_empty = [
	        "animation_paste",
			-1,
			"animation_marker_add",
			"animation_marker_remove",
			"animation_marker_clear",
	    ];
	    
	    // global.menuItems_animation_region = [
	    //     "animation_region_curve",
	    // ];
	    
	    global.menuItems_animation_name_empty = [
	        "animation_new_folder",
	        "animation_new_folder_select",
	    ];
	    
	    global.menuItems_animation_name_item = [
	        "animation_group_label_color",
	        -1,
	        "animation_new_folder",
	        "animation_new_folder_select",
	    ];
	    
	    global.menuItems_animation_name_group = [
	        "animation_group_label_color",
	        "animation_rename_group",
	        "animation_remove_group",
	        -1,
	        "animation_new_folder",
	        "animation_new_folder_select",
	    ];
	    
	    global.menuItems_animation_name_prop_axis = [
	        "animation_toggle_axis",
	    ];
	    
    #endregion ++++ context menu ++++
    
    ////- Interaction
    
    __collapse = false;
    function collapseToggle() {
        PANEL_ANIMATION.__collapse = !PANEL_ANIMATION.__collapse;
    
        for( var i = 0, n = array_length(PANEL_ANIMATION.timeline_contents); i < n; i++ )
            PANEL_ANIMATION.timeline_contents[i].item.show = PANEL_ANIMATION.__collapse;
    }
    
    function dopeSheet_TimelineScrub() {
        var bar_int_x   = min(bar_x + bar_w, bar_x + bar_total_shift);
        
        if(timeline_scubbing) {
            var rfrm = (mx - bar_x - timeline_shift) / timeline_scale - 1;
            if(!key_mod_press(CTRL)) rfrm = clamp(rfrm, 0, GLOBAL_TOTAL_FRAMES - 1);
            
            PROJECT.animator.setFrame(rfrm, !key_mod_press(ALT));
            
            timeline_show_time  = GLOBAL_CURRENT_FRAME;
            if(timeline_show_time != _scrub_frame)
                _scrub_frame = timeline_show_time;
                
	        if(mouse_release(mb_left))
	            timeline_scubbing = false;
        }
        
        if(timeline_frame_typing) {
        	if(timeline_stretch == 0 && KEYBOARD_NUMBER != undefined) {
        		var rfrm = KEYBOARD_NUMBER - 1;
            	PROJECT.animator.setFrame(rfrm);
            	focusTimeline();
        	}
        	
        	if(KEYBOARD_ENTER || keyboard_check_pressed(vk_escape) || mouse_lpress()) {
        		timeline_stretch      = 0; 
        		timeline_frame_typing = false;
        	}
        	
        } else if(pHOVER) {
            if(timeline_draggable && point_in_rectangle(mx, my, bar_x, ui(8), min(bar_x + bar_w, bar_int_x), ui(8 + 16))) { //top bar
            	if(DOUBLE_CLICK) {
					timeline_frame_typing = true;
            		KEYBOARD_RESET
            		
            	} else if(mouse_press(mb_left, pFOCUS) && !key_mod_press_any()) {
                    timeline_scubbing = true;
                    timeline_scub_st  = GLOBAL_CURRENT_FRAME;
                    _scrub_frame      = timeline_scub_st;
                    KEYBOARD_RESET
            	}
            }
        }
        
        timeline_draggable = true;
    }
    
    function dopeSheet_TimelineStretch() {
    	var stx = bar_total_shift;
        var sty = ui(10);
        
        var msx = mx - bar_x;
        var msy = my - ui(8);
        
        var len = timeline_frame_typing? (KEYBOARD_NUMBER != undefined? KEYBOARD_NUMBER : timeline_stretch_sx) :
                                         (round((mx - bar_x - timeline_shift) / timeline_scale));
            len = max(1, len);
        
        if(timeline_stretch == 1) {
            TOOLTIP = __txtx("panel_animation_length", "Animation length") + $" {len}";
            GLOBAL_TOTAL_FRAMES = len;
            
            timeline_draggable = false;
            if(mouse_release(mb_left) && !timeline_frame_typing) timeline_stretch = 0;
            return;
        } 
        
        if(timeline_stretch == 2) {
            TOOLTIP  = __txtx("panel_animation_length", "Animation length") + $" {len}";
            var _len = GLOBAL_TOTAL_FRAMES;
            GLOBAL_TOTAL_FRAMES = len;
            
            if(_len != len) {
                for (var m = 0, n = array_length(PROJECT.allNodes); m < n; m++) {
                    var _node = PROJECT.allNodes[m];
                    if(!_node || !_node.active) continue;
                    
                    for(var i = 0, o = array_length(_node.inputs); i < o; i++) {
                        var in = _node.inputs[i];
                        if(!in.is_anim) continue;
                        
                        for(var j = 0, p = array_length(in.animator.values); j < p; j++) {
                            var t = in.animator.values[j];
                            t.time = t.ratio * (len - 1);
                            if(PREFERENCES.panel_animation_quan_scale)
                            	t.time = round(t.time);
                        }
                        
                        if(!in.sep_axis) continue;
                        
                        var _anims = in.getAnimators();
                        for(var k = 0, p = array_length(_anims); k < p; k++ )
                        for(var j = 0, q = array_length(_anims[k].values); j < q; j++) {
                            var t = _anims[k].values[j];
                            t.time = t.ratio * (len - 1);
                            if(PREFERENCES.panel_animation_quan_scale)
                            	t.time = round(t.time);
                        }
                    }
                }
            }
            
            timeline_draggable = false;
            if(mouse_release(mb_left) && !timeline_frame_typing) {
            	timeline_stretch = 0;
            	
            	if(PREFERENCES.panel_animation_key_override) {
            		for (var m = 0, n = array_length(PROJECT.allNodes); m < n; m++) {
	                    var _node = PROJECT.allNodes[m];
	                    if(!_node || !_node.active) continue;
	                    
	                    for(var i = 0, o = array_length(_node.inputs); i < o; i++) {
	                        var in = _node.inputs[i];
	                        if(!in.is_anim) continue;
	                        
	                        for(var j = array_length(in.animator.values) - 1; j >= 1; j--) {
	                            var t0 = in.animator.values[j-1];
	                            var t1 = in.animator.values[j  ];
	                            
	                            if(t0.time == t1.time) array_delete(in.animator.values, j, 1);
	                        }
	                        
	                        in.animator.updateKeyMap();
	                        
	                        if(!in.sep_axis) continue;
	                        var _anims = in.getAnimators();
	                        for(var k = 0, p = array_length(_anims); k < p; k++ ) {
		                        for(var j = array_length(_anims[k].values) - 1; j >= 1; j--) {
		                            var t0 = _anims[k].values[j-1];
		                            var t1 = _anims[k].values[j  ];
		                            
	                            	if(t0.time == t1.time) array_delete(_anims[k].values, j, 1);
		                        }
		                        
		                        _anims[k].updateKeyMap();
	                        }
	                    }
	                }
            	}
            }
            return;
        } 
        
        if(!GLOBAL_IS_PLAYING && pHOVER && point_in_circle(msx, msy, stx, sty, sty)) {
        	TOOLTIP = tooltip_anim_end;
        	
        	if(key_mod_press(ALT)) {
                TOOLTIP = __txtx("panel_animation_stretch", "Stretch animation");
        		
                if(DOUBLE_CLICK) {
                	timeline_stretch      = 2;
                    timeline_stretch_sx   = GLOBAL_TOTAL_FRAMES;
                	timeline_frame_typing = true;
                	KEYBOARD_RESET
                	
                } else if(mouse_press(mb_left, pFOCUS)) {
                    timeline_stretch    = 2;
                    timeline_stretch_mx = msx;
                    timeline_stretch_sx = GLOBAL_TOTAL_FRAMES;
                }
                
                if(timeline_stretch == 2) {
                	for (var m = 0, n = array_length(PROJECT.allNodes); m < n; m++) {
	                    var _node = PROJECT.allNodes[m];
	                    if(!_node || !_node.active) continue;
	                    
	                    for(var i = 0; i < array_length(_node.inputs); i++) {
	                        var in = _node.inputs[i];
	                        if(!in.is_anim) continue;
	                        
	                        for(var j = 0; j < array_length(in.animator.values); j++)
	                            in.animator.values[j].calcRatio();
	                        
	                        if(!in.sep_axis) continue;
	                        
	                        var _anims = in.getAnimators();
	                        for(var k = 0; k < array_length(_anim); k++ )
	                        for(var j = 0; j < array_length(_anim[k].values); j++)
	                            _anim[k].values[j].calcRatio();
	                    }
	                }
                }
                
            } else if(key_mod_press(CTRL)) {
                TOOLTIP = __txtx("panel_animation_adjust_length", "Adjust animation length");
        		
                if(DOUBLE_CLICK) {
                	timeline_stretch      = 1;
                    timeline_stretch_sx   = GLOBAL_TOTAL_FRAMES;
                	timeline_frame_typing = true;
                	KEYBOARD_RESET
                	
                } else if(mouse_press(mb_left, pFOCUS)) {
                    timeline_stretch    = 1;
                    timeline_stretch_mx = msx;
                    timeline_stretch_sx = GLOBAL_TOTAL_FRAMES;
                }
            }
        }
    }
    
    ////- Editing
    
    function editKeyFrame(keyframe, _x = mouse_mx + ui(8), _y = mouse_my + ui(8)) {
        var _prop = keyframe.anim.prop;
        var _wid  = _prop.getEditWidget();
        __keyframe_editing = keyframe;
        
        switch(_prop.type) {
            case VALUE_TYPE.color : 
                switch(_prop.display_type) {
                	
                    case VALUE_DISPLAY.palette : 
                        var dia = dialogCall(o_dialog_palette);
	        			dia.setDefault(keyframe.value);
	        			dia.setApply(function(val) /*=>*/ { 
	        				__keyframe_editing.value = val; 
	        				__keyframe_editing.anim.node.triggerRender(); 
	        			});
	        			dia.setDrop(_wid);
                        break;
                    
                    default :
                    	var dia = dialogCall(o_dialog_color_selector);
                        dia.setDefault(keyframe.value);
                        dia.setApply(function(val) /*=>*/ { 
                        	__keyframe_editing.value = val; 
                        	__keyframe_editing.anim.node.triggerRender(); 
                        });
                        dia.setDrop(_wid);
                        break;
                }
                break;
            
            case VALUE_TYPE.gradient : 
                dialogCall(o_dialog_gradient)
                	.setDefault(keyframe.value.clone())
	            	.setApply(function(val) /*=>*/ { __keyframe_editing.value = val; })
	            	.setDrop(_wid);
                break;
                
            default : 
                dialogCall(o_dialog_value_editor, _x, _y).setKey(keyframe);
        }
    }
    
    function deleteKeys() {
    	array_foreach(keyframe_selecting, function(k) /*=>*/ { k.anim.removeKey(k); });
        keyframe_selecting = [];
    }
    
    ////- Draw Functions
    
    function drawFrameLine(f, fy0, fy1, cc, aa=1) { 
    	var fx = f * timeline_scale + timeline_shift;
    	// draw_sprite_stretched_ext(THEME.box_r2, 1, fx - timeline_scale/2, fy0, timeline_scale, fy1-fy0, cc, aa); 
    	
    	draw_set_color(cc);
    	draw_set_alpha(aa);
    	draw_line_width(fx, fy0, fx, fy1, 1);
    	draw_set_alpha(1);
    }
    
    function drawDopesheet_setDimension() {
    	dopesheet_w    = timeline_w;
        dopesheet_h    = h - ui(52);
        dopesheet_show = dopesheet_h > ui(24);
    }
    
    function drawDopesheet_ResetTimelineMask() {
    	dopesheet_mask         = surface_verify(dopesheet_mask,    dopesheet_w, dopesheet_h);
        dopesheet_surface      = surface_verify(dopesheet_surface, dopesheet_w, dopesheet_h);
        
        dopesheet_name_mask    = surface_verify(dopesheet_name_mask,    tool_width, dopesheet_h);
        dopesheet_name_surface = surface_verify(dopesheet_name_surface, tool_width, dopesheet_h);
        
        BLEND_SUBTRACT
        
        surface_set_target(dopesheet_mask);
            draw_clear(c_black);
            draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, dopesheet_w, dopesheet_h);
        surface_reset_target();
        
        surface_set_target(dopesheet_name_mask);
            draw_clear(c_black);
            draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, tool_width, dopesheet_h);
        surface_reset_target();
        
        BLEND_NORMAL
    } 
    
    ////- Draw Graph
    
    function drawDopesheet_Graph_Line_Modulate_Envelope(mmx, mmy, _gy0, _gy1) {
    	var _mod_st = modulate_range[0];
    	var _mod_ed = modulate_range[1];
    	
    	var _mod_x0 = timeline_shift + (_mod_st + 1) * timeline_scale;
    	var _mod_x1 = timeline_shift + (_mod_ed + 1) * timeline_scale;
    	var _gyc    = (_gy0 + _gy1) / 2;
    	var _hov    = point_in_rectangle(mmx, mmy, _mod_x0, _gy0, _mod_x1, _gy1);
    	
    	var _mod_fade_st = modulate_fade[0];
    	var _mod_fade_ed = modulate_fade[1];
    	
		var _mod_f0 = _mod_x0 + _mod_fade_st * timeline_scale;
		var _mod_f1 = _mod_x1 - _mod_fade_ed * timeline_scale;
		
    	draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, _mod_x0, _gy0, _mod_x1, _gy1, COLORS._main_icon, .5);
    	draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, _mod_f0, _gy0, _mod_f1, _gy1, COLORS._main_value_positive, .75);
    	
    	var _hovSt = pHOVER && point_in_rectangle(mmx, mmy, _mod_f0 - ui(12), _gy0, _mod_f0 + ui(12), _gy1);
    	var _hovEd = pHOVER && point_in_rectangle(mmx, mmy, _mod_f1 - ui(12), _gy0, _mod_f1 + ui(12), _gy1);
		
		draw_set_color(_hovSt? COLORS._main_value_positive : COLORS._main_icon); draw_line_round(_mod_f0,   _gyc - ui(6), _mod_f0,   _gyc + ui(8), ui(3));
		draw_set_color(_hovEd? COLORS._main_value_positive : COLORS._main_icon); draw_line_round(_mod_f1-1, _gyc - ui(6), _mod_f1-1, _gyc + ui(8), ui(3));
		
    	draw_set_color(COLORS._main_icon);
    	if(_mod_fade_st > 0) draw_line(_mod_x0, lerp(_gy1, _gy0, modulate_fade_anchor[0]), _mod_f0, _gy0);
    	if(_mod_fade_ed > 0) draw_line(_mod_f1, _gy0, _mod_x1, lerp(_gy1, _gy0, modulate_fade_anchor[1]));
    	
    	if(modulate_drag == 1) {
    		modulate_fade[0] = max(0, mmx - _mod_x0) / timeline_scale;
    		modulate_fade_anchor[0] = clamp(1 - (mmy - _gy0) / (_gy1 - _gy0), 0, 1);
    		
    		if(mouse_release(mb_left)) modulate_drag = 0;
    	}
    	
    	if(modulate_drag == -1) {
    		modulate_fade[1] = max(0, _mod_x1 - mmx) / timeline_scale;
    		modulate_fade_anchor[1] = clamp(1 - (mmy - _gy0) / (_gy1 - _gy0), 0, 1);
    		
    		if(mouse_release(mb_left)) modulate_drag = 0;
    	}
    	
    	var _mod_inf_st = _mod_st + _mod_fade_st;
    	var _mod_inf_ed = _mod_ed + _mod_fade_ed;
    	var _inf, _anc;
    	
    	for( var i = 0, n = array_length(modulate_keys); i < n; i++ ) {
    		var _modulate_keys = modulate_keys[i];
    		var _key = _modulate_keys[0];
    		var _ori = _modulate_keys[1];
    		var _val = _ori.value;
    		
    		if(is_numeric(_val)) {
	    		if(_mod_fade_st > 0) {
	    			_inf = clamp((_key.time - _mod_st) / _mod_fade_st, 0, 1);
	    			_anc = lerp(modulate_value_range[0], modulate_value_range[1], modulate_fade_anchor[0]);
	    			_val = lerp(_anc, _val, _inf);
	    		}
	    		
	    		if(_mod_fade_ed > 0) {
	    			_inf = clamp((_mod_ed - _key.time) / _mod_fade_ed, 0, 1);
	    			_anc = lerp(modulate_value_range[0], modulate_value_range[1], modulate_fade_anchor[1]);
	    			_val = lerp(_anc, _val, _inf);
	    		}
	    		
    		} else if(is_array(_val)) {
    			_val = array_clone(_ori.value);
    			
    			for( var j = 0, m = array_length(_val); j < m; j++ ) {
    				if(_mod_fade_st > 0) {
		    			_inf = clamp((_key.time - _mod_st) / _mod_fade_st, 0, 1);
		    			_anc = lerp(modulate_value_range[0], modulate_value_range[1], modulate_fade_anchor[0]);
		    			_val[j] = lerp(_anc, _val[j], _inf);
		    		}
		    		
		    		if(_mod_fade_ed > 0) {
		    			_inf = clamp((_mod_ed - _key.time) / _mod_fade_ed, 0, 1);
		    			_anc = lerp(modulate_value_range[0], modulate_value_range[1], modulate_fade_anchor[1]);
		    			_val[j] = lerp(_anc, _val[j], _inf);
		    		}
    			}
    		}
    		
    		_key.value = _val;
    	}
    	
    	if(mouse_lpress()) {
    		if(_hovSt) {
    			modulate_drag    = 1;
    			modulate_drag_mx = mmx;
    			
    		} else if(_hovEd) {
    			modulate_drag    = -1;
    			modulate_drag_mx = mmx;
    			
    		} else if(!_hov) modulate_animator = noone;
    	}
    }
    
    function drawDopesheet_Graph_Line_Modulate_Randomize(mmx, mmy, _gy0, _gy1) {
    	var _mod_st = modulate_range[0];
    	var _mod_ed = modulate_range[1];
    	
    	var _mod_x0 = timeline_shift + (_mod_st + 1) * timeline_scale;
    	var _mod_x1 = timeline_shift + (_mod_ed + 1) * timeline_scale;
    	var _gyc    = (_gy0 + _gy1) / 2;
    	var _hov    = point_in_rectangle(mmx, mmy, _mod_x0, _gy0, _mod_x1, _gy1);
    	
    	draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, _mod_x0, _gy0, _mod_x1, _gy1, COLORS._main_icon, .5);
    	
    	if(mouse_lpress()) {
    		if(!_hov) modulate_animator = noone;
    	}
    }
    
    function drawDopesheet_Graph_Line_Modulate(mmx, mmy, _gy0, _gy1) {
    	keyframe_boxable = false;
    	
    	switch(modulate_type) {
    		case KEYFRAME_MODULATE.envelope  : return drawDopesheet_Graph_Line_Modulate_Envelope(mmx, mmy, _gy0, _gy1);
    		case KEYFRAME_MODULATE.randomize : return drawDopesheet_Graph_Line_Modulate_Randomize(mmx, mmy, _gy0, _gy1);
    	}
    	
    }
    
    function drawDopesheet_Graph_Line(animator, key_y, msx, msy, _gy_val_min = infinity, _gy_val_max = -infinity) { 
    	if(modulate_animator != noone && modulate_animator != animator) return noone;
        var hovering = noone;
        
        var _gh  = ui(animator.prop.graph_h - 16);
        var _gy0 = ui(8);
        var _gy1 = _gy0 + _gh;
        var kamo = array_length(animator.values);
        var aa   = 1;
        
        var mmx = msx;
        var mmy = msy - (key_y + ui(8));
        
        #region get range
            var _prevDelt = [ 0, 0 ];
            
            for(var k = 0; k < kamo; k++) { 
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
                        var nk = k + 1 < kamo? animator.values[k + 1].time : GLOBAL_TOTAL_FRAMES;
                    
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
            
            animator.prop.graph_range[0] = _gy_val_min;
            animator.prop.graph_range[1] = _gy_val_max;
            
            animator.prop.graph_draw_y[0] = _gy0 + (key_y + ui(8));
            animator.prop.graph_draw_y[1] = _gy1 + (key_y + ui(8));
            
        #endregion
        
        var val_rng  = (_gy_val_max - _gy_val_min) / (_gy1 - _gy0);
        var valArray = is_array(animator.values[0].value);
        var ox  = 0;
        var nx  = 0;
        var ny  = noone;
        
        var _kv, _kn, sy;
        
        var _oy = animator.values[0].value;
        if(!valArray) _oy = [ _oy ];
        
        var ss = array_length(_oy);
        var oy = array_create(ss);
        for( var ki = 0; ki < ss; ki++ ) oy[ki] = value_map(_oy[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
        
        for(var k = 0; k < kamo - 1; k++) { // draw line in between
            var key      = animator.values[k];
            var key_next = animator.values[k + 1];
            
            var t  = key.dopesheet_x;
            var dx = key_next.time - key.time;
            
            if(key.drivers.type) { // driver
                nx = (key.time + 1) * timeline_scale + timeline_shift;
                    
                for( var _time = key.time; _time <= key_next.time; _time++ ) {
                    var rat = (_time - key.time) / (key_next.time - key.time);
                    
                    _kv = animator.processDriver(_time, key, animator.lerpValue(key, key_next, rat), rat);
                    
                    if(!valArray) _kv = [ _kv ];
                        
                    for( var ki = 0; ki < array_length(_kv); ki++ ) {
                        var cc = COLORS.panel_animation_graph_line;
                        if(valArray)                    cc = array_safe_get(COLORS.axis, ki, cc);
                        else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
                        
                        cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
                        draw_set_color(cc);
                        draw_set_alpha(aa);
                        
                        ny[ki] = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
                        
                        if(_time == key.time) draw_line(nx, oy[ki], nx, ny[ki]);
                        else                  draw_line(ox, oy[ki], nx, ny[ki]);
                            
                        oy[ki] = ny[ki];
                    }
                    
                    ox  = nx;
                    nx += timeline_scale;
                }
                
                draw_set_alpha(1);
                
            } else if(key_next.ease_in_type == CURVE_TYPE.cut) { // hold draw
            	nx  = (key_next.time + 1) * timeline_scale + timeline_shift;
                
                _kv = key.value;
                _kn = key_next.value;
                
                if(!valArray) {
                    _kv = [ _kv ];
                    _kn = [ _kn ];
                }
                
                var kn = min(array_length(_kv), array_length(_kn));
                for( var ki = 0; ki < kn; ki++ ) {
                    var cc = COLORS.panel_animation_graph_line;
                    if(valArray)                    cc = array_safe_get(COLORS.axis, ki, cc);
                    else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
                    
                    cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
                    draw_set_color(cc);
                    draw_set_alpha(aa);
                    
                    ny[ki] = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
                    
                    if(array_length(oy) > ki) draw_line(t, oy[ki], t, ny[ki]);
                    oy[ki] = ny[ki];
                    
                    ny[ki] = value_map(_kn[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
                    draw_line( t, oy[ki], nx, oy[ki]);
                    draw_line(nx, oy[ki], nx, ny[ki]);
                    oy[ki] = ny[ki];
                }
                
                ox = nx;
             //   draw_set_alpha(1);
                
            } else if(key.ease_out_type == CURVE_TYPE.linear && key_next.ease_in_type == CURVE_TYPE.linear) { // linear draw
                nx  = (key_next.time + 1) * timeline_scale + timeline_shift;
                
                _kv = key.value;
                _kn = key_next.value;
                
                if(!valArray) {
                    _kv = [ _kv ];
                    _kn = [ _kn ];
                }
                
                var kn = min(array_length(_kv), array_length(_kn));
                for( var ki = 0; ki < kn; ki++ ) {
                    var cc = COLORS.panel_animation_graph_line;
                    if(valArray)                    cc = array_safe_get(COLORS.axis, ki, cc);
                    else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
                    
                    cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
                    draw_set_color(cc);
                    draw_set_alpha(aa);
                    
                    ny[ki] = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
                    
                    if(array_length(oy) > ki) draw_line(t, oy[ki], t, ny[ki]);
                    oy[ki] = ny[ki];
                    
                    ny[ki] = value_map(_kn[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
                    draw_line(t, oy[ki], nx, ny[ki]);
                    oy[ki] = ny[ki];
                }
                
                ox = nx;
                draw_set_alpha(1);
                
            } else { //bezier easing
                var _step = 1 / dx;
                for( var _r = 0; _r <= 1; _r += _step ) {
                    nx  = t + _r * dx * timeline_scale;
                    
                    _kv = key.value;
                    _kn = key_next.value;
                
                    if(!valArray) {
                        _kv = [ _kv ];
                        _kn = [ _kn ];
                    }
                	
                	var kn = min(array_length(_kv), array_length(_kn));
                    for( var ki = 0; ki < kn; ki++ ) {
                        var cc = COLORS.panel_animation_graph_line;
                        if(valArray)                    cc = array_safe_get(COLORS.axis, ki, cc);
                        else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
                        
                        cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
                        draw_set_color(cc);
                        draw_set_alpha(aa);
                        
                        var __i = animator.interpolate(key, key_next, _r);
                        ny[ki] = value_map(lerp(_kv[ki], _kn[ki], __i), _gy_val_min, _gy_val_max, _gy1, _gy0);
                        if(array_length(oy) > ki) draw_line(ox, oy[ki], nx, ny[ki]);
                            
                        oy[ki] = ny[ki];
                    }
                    
                    ox = nx;
                    draw_set_alpha(1);
                }
            }
        } // draw line in between
        
        if(animator.prop.show_graph && array_length(animator.values) > 0) { // draw line outside keyframe range
            var key_first = animator.values[0];
            var t_first  = (key_first.time + 1) * timeline_scale + timeline_shift;
            
            _kv = key_first.value;
            if(!valArray) _kv = [ _kv ];
            
            for( var ki = 0, kn = array_length(_kv); ki < kn; ki++ ) {
                var cc = COLORS.panel_animation_graph_line;
                if(valArray)                    cc = array_safe_get(COLORS.axis, ki, cc);
                else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
                    
                cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
                draw_set_color(cc);
                draw_set_alpha(aa);
                
                sy = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
                draw_line(0, sy, t_first, sy);
                    
                if(array_length(animator.values) == 1) oy[ki] = sy;
            }
            
            draw_set_alpha(1);
                
            var key_last = array_last(animator.values);
            var t_last = (key_last.time + 1) * timeline_scale + timeline_shift;
                
            if(key_last.time < GLOBAL_TOTAL_FRAMES) {
                if(key_last.drivers.type) {
                    nx = t_last;
                    
                    for( var _time = key_last.time; _time < GLOBAL_TOTAL_FRAMES; _time++ ) {
                        _kv = animator.processDriver(_time, key_last);
                        if(!valArray) _kv = [ _kv ];
                        
                        for( var ki = 0, kn = array_length(_kv); ki < kn; ki++ ) {
                            var cc = COLORS.panel_animation_graph_line;
                            if(valArray)                    cc = array_safe_get(COLORS.axis, ki, cc);
                            else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
                            
                            cc = colorMultiplyRGB(cc, CDEF.main_ltgrey);
                            draw_set_color(cc);
                            draw_set_alpha(aa);
                            
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
                    
                    for( var ki = 0, kn = array_length(_kv); ki < kn; ki++ ) {
                        var cc = COLORS.panel_animation_graph_line;
                        if(valArray)                    cc = array_safe_get(COLORS.axis, ki, cc);
                        else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
                        
                        cc = colorMultiplyRGB(cc, CDEF.main_ltgrey); 
                        draw_set_color(cc);
                        draw_set_alpha(aa);
                        
                        ny[ki] = value_map(_kv[ki], _gy_val_min, _gy_val_max, _gy1, _gy0);
                        draw_line(t_last, oy[ki], t_last, ny[ki]);
                        draw_line(t_last, ny[ki], bar_total_shift, ny[ki]);
                    }
                }
            }
        } // draw line outside keyframe range
        
        draw_set_alpha(1);
        
        if(modulate_animator == noone)
        for(var i = 0; i < kamo; i++) { // draw key
            var key = animator.values[i];
            var px  = key.dopesheet_x;
            var v   = valArray? key.value : [key.value];
            
            var ei  = key.ease_in;
            var eo  = key.ease_out;
            
            var spBef = /*i > 0?        key.time - animator.values[i-1].time : */2;
            var spAft = /*i < kamo - 1? animator.values[i+1].time - key.time : */2;
            
            var ix  = px - ei[0] * timeline_scale * spBef;
            var ox  = px + eo[0] * timeline_scale * spAft;
            
            for (var j = 0, m = array_length(v); j < m; j++) {
                var py = value_map(v[j], _gy_val_min, _gy_val_max, _gy1, _gy0);
                var iy = py + (1 - ei[1]) / val_rng;
                var oy = py - (    eo[1]) / val_rng;
                
                var cc = COLORS.panel_animation_graph_line;
                if(valArray)                    cc = array_safe_get(COLORS.axis, j, cc);
                else if(animator.prop.sep_axis) cc = array_safe_get(COLORS.axis, animator.index, cc);
                
                if(ei[0] != 0 && key.ease_in_type == CURVE_TYPE.bezier) {
                    var _hv = (graph_key_hover == key && ( graph_key_hover_index == KEYFRAME_DRAG_TYPE.ease_in || graph_key_hover_index == KEYFRAME_DRAG_TYPE.ease_both)) || 
                              (graph_key_drag  == key && ( graph_key_drag_index  == KEYFRAME_DRAG_TYPE.ease_in || graph_key_drag_index  == KEYFRAME_DRAG_TYPE.ease_both));
                    
                    draw_set_color(_hv? COLORS._main_accent : cc);
                    draw_set_alpha(aa);
                    draw_line(ix, iy, px, py);
                    draw_sprite_ui_uniform(THEME.circle, 0, ix, iy, .75, _hv? COLORS._main_accent : cc, aa);
                    
                    if(point_in_circle(mmx, mmy, ix, iy, 4)) {
                        _graph_key_hover       = key;
                        _graph_key_hover_index = KEYFRAME_DRAG_TYPE.ease_in;
                        
                        _graph_key_hover_x = px;
                        _graph_key_hover_y = py + (key_y + ui(8));
                        graph_key_hover_range = val_rng;
                    }
                }
                
                if(eo[0] != 0 && key.ease_in_type == CURVE_TYPE.bezier) {
                    var _hv = (graph_key_hover == key && (graph_key_hover_index == KEYFRAME_DRAG_TYPE.ease_out || graph_key_hover_index == KEYFRAME_DRAG_TYPE.ease_both)) || 
                              (graph_key_drag  == key && (graph_key_drag_index  == KEYFRAME_DRAG_TYPE.ease_out || graph_key_drag_index  == KEYFRAME_DRAG_TYPE.ease_both));
                    
                    draw_set_color(_hv? COLORS._main_accent : cc);
                    draw_set_alpha(aa);
                    draw_line(px, py, ox, oy);
                    draw_sprite_ui_uniform(THEME.circle, 0, ox, oy, .75, _hv? COLORS._main_accent : cc, aa);
                    
                    if(point_in_circle(mmx, mmy, ox, oy, 4)) {
                        _graph_key_hover       = key;
                        _graph_key_hover_index = KEYFRAME_DRAG_TYPE.ease_out;
                        
                        _graph_key_hover_x = px;
                        _graph_key_hover_y = py + (key_y + ui(8));
                        graph_key_hover_range = val_rng;
                    }
                }
                
                var _hv = (graph_key_hover == key && graph_key_hover_index == KEYFRAME_DRAG_TYPE.move) || 
                          (graph_key_drag  == key && graph_key_drag_index  == KEYFRAME_DRAG_TYPE.move);
                
                draw_sprite_ui_uniform(THEME.timeline_keyframe, 0, px, py, 1, _hv? COLORS._main_accent : cc, aa);
                
                if(point_in_circle(mmx, mmy, px, py, 5)) {
                	TOOLTIP = v[j];
                	
                    _graph_key_hover       = key;
                    _graph_key_hover_index = KEYFRAME_DRAG_TYPE.move;
                    _graph_key_hover_array = j;
                    
                    _graph_key_hover_x = px;
                    _graph_key_hover_y = py + (key_y + ui(8));
                    graph_key_hover_range = val_rng;
                }
            }
        } // draw key
        
        draw_set_alpha(1);
        
        if(modulate_animator == animator) drawDopesheet_Graph_Line_Modulate(mmx, mmy, _gy0, _gy1);
    }
    
    function drawDopesheet_Graph_Prop(prop, key_y, msx, msy) {
        if(prop.type == VALUE_TYPE.color) { // draw color line
            
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
                var dx         = key_next.time - key.time;
                var _step     = 1 / dx;
                
                for( var _r = 0; _r <= 1; _r += _step ) {
                    nx = key.dopesheet_x + _r * dx * timeline_scale;
                    var lrp = prop.animator.interpolate(key, key_next, _r);
                    nc = merge_color(key.value, key_next.value, lrp);
                    
                    if(_r > 0) draw_rectangle_color(ox, _gy0, nx, _gy1, oc, nc, nc, oc, 0);
                        
                    ox = nx;
                    oc = nc;
                }
            }
            
            key_next = array_last(prop.animator.values);
            if(key_next.time < GLOBAL_TOTAL_FRAMES) {
                draw_set_color(key_next.value);
                draw_rectangle(key_next.dopesheet_x, _gy0, bar_total_shift, _gy1, 0);
            }
            
            return;
        } // draw color line
        
        var _gh  = ui(prop.graph_h);
        var _gy0 = key_y + ui(8);
        var _gy1 = _gy0 + _gh;
        
        var _stW = timeline_separate * timeline_scale;
        var _st  = ceil(-timeline_shift / _stW);
        var _fr  = _st + ceil(bar_w / _stW);
        
        keyframe_graph_surface = surface_verify(keyframe_graph_surface, w, _gh);
        surface_set_target(keyframe_graph_surface);
            draw_clear(COLORS.panel_animation_timeline_top);
            
            for(var i = _st; i <= _fr; i++) {
                var bar_frame  = i * timeline_separate;
                var _cc = COLORS.panel_animation_frame_divider;
                var _aa = (i % timeline_separate == 0? 1 : 0.1) * ((bar_frame <= GLOBAL_TOTAL_FRAMES) * 0.5 + 0.5) * 0.3;
                
                drawFrameLine(bar_frame, 0, _gh, _cc, _aa);
            }
            
            drawFrameLine(GLOBAL_TOTAL_FRAMES, 0, _gh, COLORS.panel_animation_end_line, .5);
            drawFrameLine(0, 0, _gh, COLORS.panel_animation_end_line, .5);
                
            if(prop.sep_axis) {
                var _min =  999999;
                var _max = -999999;
                var _anims = prop.getAnimators();
                
                for( var i = 0, n = array_length(_anims); i < n; i++ ) {
                    if(!prop.show_graphs[i]) continue;
                    
                    var animator = _anims[i];
                    for(var k = 0, m = array_length(animator.values); k < m; k++) {
                        var key_val = animator.values[k].value;
                        if(is_array(key_val)) {
                            for( var ki = 0, mm = array_length(key_val); ki < mm; ki++ ) {
                                _min = min(_min, key_val[ki]);
                                _max = max(_max, key_val[ki]);
                            }
                            
                        } else {
                            _min = min(_min, key_val);
                            _max = max(_max, key_val);
                        }
                    }
                }
                
                for( var i = 0, n = array_length(_anims); i < n; i++ ) {
                    if(!prop.show_graphs[i]) continue;
                    drawDopesheet_Graph_Line(_anims[i], key_y, msx, msy, _min, _max);
                }
                
            } else
                drawDopesheet_Graph_Line(prop.animator, key_y, msx, msy);
        surface_reset_target();
        
        draw_surface(keyframe_graph_surface, 0, _gy0);
        
        var _hov = pHOVER && distance_to_line(msx, msy, 0, _gy1, w, _gy1) < ui(4);
        draw_set_color(COLORS._main_icon_dark);
        if(_hov) draw_set_color(CDEF.main_dkgrey);
        if(graph_height_dragging == prop) draw_set_color(COLORS._main_accent);
        
        draw_line_width(0, _gy1, w, _gy1, 1 + (_hov|| graph_height_dragging == prop));
        if(_hov) keyframe_boxable = false;
        
		if(_hov && mouse_lpress(pFOCUS)) {
			graph_height_dragging = prop;
			graph_height_drag_sy  = prop.graph_h;
			graph_height_drag_my  = msy;
		}
		
		if(graph_height_dragging == prop) {
			prop.graph_h = max(16, graph_height_drag_sy + (msy - graph_height_drag_my) / UI_SCALE);
			if(mouse_release(mb_left)) graph_height_dragging = noone;
		}
		
		draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_add(ui(4), _gy0, prop.graph_range[1]);
		
		draw_set_text(f_p4, fa_left, fa_bottom, COLORS._main_text_sub);
		draw_text_add(ui(4), _gy1, prop.graph_range[0]);
    }
    
    function drawDopesheet_Graph_BG(animator, msx, msy) { 
        var prop_dope_y = animator.y;
        var _cy = prop_dope_y - 1;
        
        var key_hover   = noone;
        var key_list    = animator.values;
        
        if((animator.prop.on_end == KEYFRAME_END.loop || animator.prop.on_end == KEYFRAME_END.ping) && array_length(key_list) > 1) {
            var keyframe_s = animator.prop.loop_range == -1? key_list[0].time : key_list[array_length(key_list) - 1 - animator.prop.loop_range].time;
            var keyframe_e = array_last(key_list).time;
                                
            var ks_x = (keyframe_s + 1) * timeline_scale + timeline_shift;
            var ke_x = (keyframe_e + 1) * timeline_scale + timeline_shift;
                        
            draw_set_color(COLORS.panel_animation_loop_line);
            draw_set_alpha(0.2);
            draw_line_width(ks_x, _cy, ke_x, _cy, 4);
            draw_set_alpha(1);
        }
        
        if(is(animator.prop, __NodeValue_Active)) { //draw active region
	        var _ox = timeline_shift, _nx;
        	var _y1 = timeline_shift + GLOBAL_TOTAL_FRAMES * timeline_scale;
        	var _ov, _nv;
        	
        	draw_set_color_alpha(COLORS._main_value_positive, .4);
        	
        	for( var k = 0, n = array_length(key_list); k < n; k++ ) {
	            var key = key_list[k];
	            _nx = key.dopesheet_x;
	            _nv = key.value;
	            
	            if(k && _ov)          draw_line_width(_ox, _cy, _nx, _cy, ui(4));
	            if(k == n - 1 && _nv) draw_line_width(_nx, _cy, _y1, _cy, ui(4));
	            
	            _ox = _nx;
	            _ov = _nv;
        	}
        	
        	draw_set_alpha(1);
        	
        } else if(animator.prop.type == VALUE_TYPE.boolean) { //draw boolean true region
        	var _ox = timeline_shift, _nx;
        	var _y1 = timeline_shift + GLOBAL_TOTAL_FRAMES * timeline_scale;
        	var _ov, _nv;
        	
        	draw_set_color_alpha(COLORS._main_value_positive, .2);
        	
        	for( var k = 0, n = array_length(key_list); k < n; k++ ) {
	            var key = key_list[k];
	            _nx = key.dopesheet_x;
	            _nv = key.value;
	            
	            if(k == 0 && _nv || k && _ov) draw_line_width(_ox, _cy, _nx, _cy, ui(6));
	            if(k == n - 1 && _nv)         draw_line_width(_nx, _cy, _y1, _cy, ui(6));
	            
	            _ox = _nx;
	            _ov = _nv;
        	}
        	
        	draw_set_alpha(1);
        } else {
        	var _ox = timeline_shift, _nx;
        	var _ok;
        	
        	draw_set_color_alpha(CDEF.blue, .2);
        	
        	for( var k = 0, n = array_length(key_list); k < n; k++ ) {
	            var key = key_list[k];
	            _nx = key.dopesheet_x;
	            
	            if(k && _ok.freeze) draw_line_width(_ox, _cy, _nx, _cy, ui(6));
	            
	            _ok = key;
	            _ox = _nx;
        	}
        	
        	draw_set_alpha(1);
        }
        
        for( var k = 0, n = array_length(key_list); k < n; k++ ) { //draw easing
            var key = key_list[k];
            var t   = key.dopesheet_x;
        	
            if(key.ease_in_type == CURVE_TYPE.bezier) {
                draw_set_color(COLORS.panel_animation_keyframe_ease_line);
                var _tx = t - key.ease_in[0] * timeline_scale * 2;
                draw_line_width(_tx, _cy, t, _cy, 2);
                                            
                if(pHOVER && point_in_circle(msx, msy, _tx, prop_dope_y, ui(6))) {
                    key_hover = key;
                    draw_sprite_ui_uniform(THEME.timeline_key_ease, 0, _tx, prop_dope_y, 1, CDEF.main_grey);
                    if(mouse_press(mb_left, pFOCUS) && !key_mod_press(SHIFT)) {
                        keyframe_dragging  = animator.values[k];
                        keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_in;
                    }
                    
                } else 
                    draw_sprite_ui_uniform(THEME.timeline_key_ease, 0, _tx, prop_dope_y, 1, CDEF.main_dkgrey);
            } 
                        
            if(key.ease_out_type == CURVE_TYPE.bezier) {
                draw_set_color(COLORS.panel_animation_keyframe_ease_line);
                var _tx = t + key.ease_out[0] * timeline_scale * 2;
                draw_line_width(t, _cy, _tx, _cy, 2);
                                        
                if(pHOVER && point_in_circle(msx, msy, _tx, prop_dope_y, ui(6))) {
                    key_hover = key;
                    draw_sprite_ui_uniform(THEME.timeline_key_ease, 1, _tx, prop_dope_y, 1, CDEF.main_grey);
                    if(mouse_press(mb_left, pFOCUS) && !key_mod_press(SHIFT)) {
                        keyframe_dragging  = animator.values[k];
                        keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_out;
                    }
                } else
                    draw_sprite_ui_uniform(THEME.timeline_key_ease, 1, _tx, prop_dope_y, 1, CDEF.main_dkgrey);
            }
        }
        
        return key_hover;
    }
	
    function drawDopesheet_Graph() {
    	
        var msx = mx - bar_x;
        var msy = my - ui(8);
        
    	var key_hover          = noone;
        _graph_key_hover       = noone;
        _graph_key_hover_index = noone;
        _graph_key_hover_array = noone;
        _graph_key_hover_x     = 0;
        _graph_key_hover_y     = 0;
        graph_key_hover_range  = 1;
        
        for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
            var _cont = timeline_contents[i];
            if( _cont.type != "node") continue;
            var _node = _cont.node;
            
            if(_node.use_cache || PROJECT.onion_skin.enabled) { // cache status
	        	draw_set_alpha(0.05);
	            for(var j = 0, m = min(GLOBAL_TOTAL_FRAMES, array_length(_node.cache_result)); j < m; j++) {
	                var x0 = (j + 0) * timeline_scale + timeline_shift;
	                var x1 = (j + 1) * timeline_scale + timeline_shift;
	                
	                draw_set_color(_node.getAnimationCacheExist(j)? c_lime : c_red);
	                draw_rectangle(x0, _cont.y + ui(10) - ui(4), x1 - 1, _cont.y + ui(10) + ui(4), false);
	            }
                draw_set_alpha(1);
	        } // cache status
	        
	        if(show_nodes && (!_cont.show || !_cont.item.show)) continue;
            
            for( var j = 0, m = array_length(_cont.props); j < m; j++ ) {
                var prop  = _cont.props[j];
                var _prop = prop.prop;
                var _dy   = prop.y;
                
                if(isGraphable(_prop)) {
                    var _graph_show = _prop.sep_axis? array_any(_prop.show_graphs, function(v) /*=>*/ {return v == true}) : _prop.show_graph;
                    if(_graph_show) drawDopesheet_Graph_Prop(_prop, _dy, msx, msy);
                }
                    
                var _anims = prop.animations;
                for( var k = 0, o = array_length(_anims); k < o; k++ ) {
                    var key = drawDopesheet_Graph_BG(_anims[k], msx, msy);
                    if(key != noone) key_hover = key;
                    
                    _dy = _anims[k].y;
                }
            }
        }
        
        graph_key_hover       = _graph_key_hover;
        graph_key_hover_index = _graph_key_hover_index;
        graph_key_hover_array = _graph_key_hover_array;
        
        if(graph_key_drag != noone) {
            var k = graph_key_drag;
            
            if(graph_key_drag_index == KEYFRAME_DRAG_TYPE.move) {
                var tt = round((mx - bar_x - timeline_shift) / timeline_scale) - 1;
                    tt = max(tt, 0);
                
                if(is_numeric(graph_key_drag_value)) {
                	var  pr   = graph_key_drag.anim.prop.graph_draw_y;
                	var _mrat = (msy - pr[0]) / (pr[1] - pr[0]);
                	
	                var vv  = lerp(graph_key_drag_range[1], graph_key_drag_range[0], _mrat);
	                TOOLTIP = vv;
	                k.value = vv;
	                
                } else if(is_array(graph_key_drag_value) && graph_key_drag_array >= 0 && graph_key_drag_array < array_length(graph_key_drag_value)) {
                	var  pr   = graph_key_drag.anim.prop.graph_draw_y;
                	var _mrat = (msy - pr[0]) / (pr[1] - pr[0]);
                	
	                var vv  = lerp(graph_key_drag_range[1], graph_key_drag_range[0], _mrat);
	                TOOLTIP = vv;
	                k.value[graph_key_drag_array] = vv;
                }
                
                var edited = k.anim.setKeyTime(k, tt, false, true);
                if(edited) UNDO_HOLDING = true;
                
                if(mouse_release(mb_left)) k.anim.setKeyTime(k, k.time, true, true);
                
            } else {
            	var _dyy = graph_key_drag_range[1] - graph_key_drag_range[0];
                var _dx =  (graph_key_sx - msx) / timeline_scale / 2;
                var _dy = -(graph_key_sy - msy) * graph_key_drag_yrange;
                var _in = k.ease_in;
                var _ot = k.ease_out;
                
            	if(_dx < 0) _dy = -_dy;
            	
                switch(graph_key_drag_index) {
                    case KEYFRAME_DRAG_TYPE.ease_in :
                    	_dx = clamp(_dx, 0, 1);
                    	
                        k.ease_in_type = _dx > 0? CURVE_TYPE.bezier : CURVE_TYPE.linear;
                        k.ease_in[0]   = _dx;
                        k.ease_in[1]   = 1 - _dy;
                        break;
                         
                    case KEYFRAME_DRAG_TYPE.ease_out :
                    	_dx = clamp(-_dx, 0, 1);
                        
                        k.ease_out_type = _dx > 0? CURVE_TYPE.bezier : CURVE_TYPE.linear;
                        k.ease_out[0]   = _dx;
                        k.ease_out[1]   = _dy;
                        break;
                        
                    case KEYFRAME_DRAG_TYPE.ease_both :
                        _dx = clamp(abs(_dx), 0, 1);
                        if(_dx < .1) _dx = 0;
                        
                        k.ease_in_type  = _dx > 0? CURVE_TYPE.bezier : CURVE_TYPE.linear;
                        k.ease_in[0]    = _dx;
                        k.ease_in[1]    = 1 - _dy;
                    	
                        k.ease_out_type = _dx > 0? CURVE_TYPE.bezier : CURVE_TYPE.linear;
                        k.ease_out[0]   = _dx;
                        k.ease_out[1]   = _dy;
                        break;
                }
                            
                if(mouse_release(mb_left)) {
                    recordAction(ACTION_TYPE.var_modify, k, [ _in, "ease_in"  ]);
                    recordAction(ACTION_TYPE.var_modify, k, [ _ot, "ease_out" ]);
                }
            }
            
            if(mouse_release(mb_left)) {
                graph_key_drag = noone;
                UNDO_HOLDING   = false;
            }
            
        } else if(graph_key_hover != noone) {
            key_hover = graph_key_hover;
            
            if(mouse_press(mb_left)) {
                graph_key_drag       = _graph_key_hover;
                graph_key_drag_index = _graph_key_hover_index;
                graph_key_drag_array = _graph_key_hover_array;
                graph_key_mx         = msx;
                graph_key_my         = msy;
                graph_key_sx         = _graph_key_hover_x;
                graph_key_sy         = _graph_key_hover_y;
                
                var _prop = graph_key_drag.anim.prop;
                graph_key_drag_range[0] = _prop.graph_range[0];
        		graph_key_drag_range[1] = _prop.graph_range[1];
                graph_key_drag_value    = graph_key_drag.value;
                graph_key_drag_yrange   = graph_key_hover_range;
                
                if(DOUBLE_CLICK) {
	                graph_key_drag_index = KEYFRAME_DRAG_TYPE.ease_both;
	                keyframe_dragout     = false;
	            }
            }
        }
        
        return key_hover;
    }
    
    ////- Draw Animator
    
    function drawDopesheet_AnimatorKeys(_cont, animator, msx, msy) {
        var _node      = _cont.node;
        var prop_y     = animator.y;
        var node_y     = _cont.y;
        var anim_set   = true;
        var key_hover  = noone;
        
        var _scaling   = key_mod_check(MOD_KEY.ctrl | MOD_KEY.alt) && array_length(keyframe_selecting) > 1;
        var valAmo     = array_length(animator.values);
        
        var hov   = pHOVER;
        var toSel = undefined;
        var ot    = undefined;
        
        for(var k = 0; k < valAmo; k++) {
            var keyframe = animator.values[k];
            var _select  = array_exists(keyframe_selecting, keyframe);
            var t = keyframe.dopesheet_x;
            
            if(show_nodes) {
            	for( var j = 0, n = array_length(_cont.contexts); j < n; j++ ) {
	                var _cxt = _cont.contexts[j];
	                if(!_cxt.show) continue;
	                draw_sprite_ui_uniform(THEME.timeline_key_empty, 0, t, _cxt.y + ui(10), 1, COLORS._main_icon);
	            }
	            
            	draw_sprite_ui_uniform(THEME.timeline_key_empty, 0, t, node_y + ui(10), 1, COLORS._main_icon);
            	if(!_cont.show || !_cont.item.show) continue;
            }
            
        	if(k) { // in-between keys
        		var ky0 = prop_y - ui(8);
        		var ky1 = prop_y + ui(8);
        		
        		var spa_hov = keyframe_dragging == noone && hov && point_in_rectangle(msx, msy, ot + ui(8), ky0, t - ui(8), ky1); 
        		if(spa_hov) {
        			region_hovering = keyframe;
        			
        			draw_set_color_alpha(CDEF.main_mdblack);
        			BLEND_MAX
        			draw_rectangle(ot, ky0 + ui(3), t, ky1 - ui(3), false);
        			BLEND_NORMAL
        			draw_set_alpha(1);
        			
        			if(DOUBLE_CLICK) toSel = [ animator.values[k-1], animator.values[k] ];
        		}
        	} // in-between keys
            
            var cc = COLORS.panel_animation_keyframe_unselected;
            if(on_end_dragging_anim == animator.prop && msx < t && anim_set) {
                animator.prop.loop_range = k == 0? -1 : valAmo - k;
                anim_set = false;
            }
            
            var key_hov  = hov && point_in_circle(msx, msy, t, prop_y, ui(8)); 
            var sca_back = keyframe == keyframe_selecting_f;
            
            if(key_hov) {
                cc = COLORS.panel_animation_keyframe_selected;
                key_hover = keyframe;
                if(!instance_exists(o_dialog_menubox))
                    TOOLTIP = [ keyframe, animator.prop.type ];
                
                if(pFOCUS && !key_mod_press(SHIFT)) {
                    if(DOUBLE_CLICK) {
                        keyframe_dragging  = keyframe;
                        keyframe_drag_type = KEYFRAME_DRAG_TYPE.ease_both;
                        keyframe_dragout   = false;
                        keyframe_drag_mx   = mx;
                        keyframe_drag_my   = my;
                        
                    } else if(mouse_press(mb_left)) {
                        if(key_mod_check(MOD_KEY.ctrl)) {
                            editKeyFrame(keyframe);
                        	
                        } else {
                        	if(key_mod_check(MOD_KEY.alt)) {
                        		keyframe_dragging  = keyframe.cloneAnimator(0, animator, false);
                        		key_hover          = keyframe_dragging;
                        		
                        	} else 
                            	keyframe_dragging  = keyframe;
                        	
                            keyframe_drag_st   = keyframe_dragging.time;
                            keyframe_drag_type = _scaling? KEYFRAME_DRAG_TYPE.scale : KEYFRAME_DRAG_TYPE.move;
                            keyframe_drag_mx   = mx;
                            keyframe_drag_my   = my;
                            
                            keyframe_drag_sv   = sca_back? keyframe_selecting_l : keyframe_selecting_f;
                        }
                    }
                }
                
            }
            
            if(stagger_mode == 1 && _select)
                cc = key_hover == keyframe? COLORS.panel_animation_keyframe_selected : COLORS._main_accent;
            
            var ind = keyframe.getDrawIndex();
            if(show_value) {
        		draw_set_text(f_p4, fa_center, fa_center, COLORS._main_text_on_accent);
            	
            	switch(animator.prop.type) {
            		case VALUE_TYPE.integer : 
            		case VALUE_TYPE.float : 
            		case VALUE_TYPE.text : 
		            	var _val = string(keyframe.value);
		            	var _kw = max(ui(14), string_width(_val) + ui(8));
		            	var _kh = ui(14);
		            	var _kx = t;
		            	var _ky = prop_y;
		            	
		            	draw_sprite_stretched_ext(THEME.box_r2, 0, _kx - _kw/2, _ky - _kh/2, _kw, _kh, cc);
		            	draw_text(_kx, _ky, _val);
            			break;
            			
            		case VALUE_TYPE.color : 
		            	var _val = keyframe.value;
		            	var _kw = ui(14);
		            	var _kh = ui(14);
		            	var _kx = t;
		            	var _ky = prop_y;
		            	
		            	draw_sprite_stretched_ext(THEME.box_r2, 0, _kx - _kw/2, _ky - _kh/2, _kw, _kh, _val);
		            	draw_sprite_stretched_ext(THEME.box_r2, 1, _kx - _kw/2, _ky - _kh/2, _kw, _kh, cc);
            			break;
            	}
            	
            } else draw_sprite_ui_uniform(THEME.timeline_keyframe, ind, t, prop_y, 1, cc);
            
            if(_select) {
            	if(_keyframe_selecting_f == noone) _keyframe_selecting_f = keyframe;
            	else _keyframe_selecting_f = keyframe.time < _keyframe_selecting_f.time? keyframe : _keyframe_selecting_f;
            	
            	if(_keyframe_selecting_l == noone) _keyframe_selecting_l = keyframe;
            	else _keyframe_selecting_l = keyframe.time > _keyframe_selecting_l.time? keyframe : _keyframe_selecting_l;
            	
                if(_scaling && key_hov) {
                	if(sca_back) draw_sprite_ui_uniform(THEME.arrow, 2, t - ui(12), prop_y, 1, CDEF.cyan, .5);
                	else         draw_sprite_ui_uniform(THEME.arrow, 0, t + ui(12), prop_y, 1, CDEF.cyan, .5);
                }
                
                var hc = _scaling? CDEF.cyan : COLORS._main_accent;
                draw_sprite_ui_uniform(THEME.timeline_keyframe_selecting, ind, t, prop_y, 1, hc);
            }
            
            if(keyframe_boxing) {
                var box_x0 = min(keyframe_box_sx, msx);
                var box_x1 = max(keyframe_box_sx, msx);
                var box_y0 = min(keyframe_box_sy, msy);
                var box_y1 = max(keyframe_box_sy, msy);
                                    
                if(!point_in_rectangle(t, prop_y, box_x0, box_y0, box_x1, box_y1) && array_exists(keyframe_selecting, keyframe))
                    array_remove(keyframe_selecting, keyframe);
                    
                if(point_in_rectangle(t, prop_y, box_x0, box_y0, box_x1, box_y1) && !array_exists(keyframe_selecting, keyframe))
                    array_push(keyframe_selecting, keyframe);
            }
            
            ot = t;
        }
        
        if(toSel != undefined) {
        	keyframe_selecting = toSel;
        	return toSel[0];
        }
        
        return key_hover;
    }
    
    ////- Draw Label
    
    function drawDopesheet_Label_Animator(_item, _node, animator, msx, msy) {
        var prop = animator.prop;
        var aa   = _node.group == PANEL_GRAPH.getCurrentContext()? 1 : 0.9;
        var tx   = tool_width;
        var ty   = animator.y - 1;
        var ty0  = ty - ui(8);
        var ty1  = ty0 + animator.h;
        var m    = [msx, msy];
        
        var drw  = ty0 < dopesheet_h + ui(16) && ty1 > -ui(16);
        var hov  = item_dragging == noone && dopesheet_name_hover && point_in_rectangle(msx, msy, 0, ty0, w - ui(64), ty1);
        var foc  = pFOCUS;
        
        ////- =Draw Name
        
        var cc = prop.sep_axis? COLORS.axis[animator.index] : COLORS._main_text_sub;
        if(hov) cc = COLORS._main_text_accent;
        
        draw_set_color(CDEF.main_mdblack);
        draw_rectangle(0, ty - ui(8), tool_width, ty + ui(8), false);
        
        var tw = ui(15);
        var th = ui(17);
        
        if(drw) {
	        var _gx = ui(8);
	        var _gy = ty - ui(9);
	        var  bc = [COLORS._main_icon, COLORS._main_icon_on_inner];
	        if(buttonInstant(noone, _gx, _gy, tw, th, m, hov, foc, "", THEME.animate_prop_go, 0, bc, .75) == 2) {
	            graphFocusNode(_node);
	            PANEL_INSPECTOR.highlightProp(prop);
	        }
	        _gx += tw + 1;
	        
	        var ii = prop.attributes.timeline_hide;
	        if(buttonInstant(noone, _gx, _gy, tw, th, m, hov, foc, "", THEME.timeline_hide, ii, bc, .75, .75) == 2)
	            prop.toggleAttribute("timeline_hide");
	        _gx += tw + 1;
	        
	        var _title_x = _gx + ui(4);
	        draw_set_text(f_p4, fa_left, fa_center, cc);
	        
        	if(!show_nodes) {
	            var _txt = animator.prop.node.getDisplayName();
	            
	            draw_set_alpha(aa * 0.5);
	            draw_text_add(_title_x, ty - 2, _txt);
	            draw_set_alpha(1);
	            
	            _title_x += string_width(_txt) + ui(4);
        	}
        	
	        var _txt = animator.getName();
	        draw_set_alpha(aa);
	        draw_text_add(_title_x, ty - 2, _txt);
	        draw_set_alpha(1);
        }
        
        if(hov) {
            value_hovering = animator;
            if(mouse_lclick(pFOCUS))
                value_focusing = animator;
                
            if(mouse_rpress(pFOCUS)) {
                context_selecting_prop = prop;
                context_selecting_item = _item;
            }
        }
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        var _tool_a = .75 + hov * .25;
        
        if(drw) {
	        var _tool_x0 = tool_width - ui(20 + 16 * 4.5 + 12);
	        var _tool_x1 = tool_width;
	        draw_set_color(c_white);
	        BLEND_SUBTRACT
	        draw_rectangle(_tool_x0, ty - ui(8), _tool_x1, ty + ui(8), false);
	        BLEND_NORMAL
        }
        
        var _graph_show = prop.sep_axis? prop.show_graphs[animator.index] : prop.show_graph;
        var tx = tool_width - ui(16);
        
        if(drw && isGraphable(prop)) {
            tx = tool_width - ui(16);
            if(pHOVER && point_in_rectangle(msx, msy, tx - ui(9), ty - ui(10), tx + ui(10), ty + ui(8))) {
                draw_sprite_ui_uniform(THEME.timeline_graph, 1, tx, ty, 1, COLORS._main_icon_on_inner, _tool_a);
                TOOLTIP = _graph_show? __txtx("panel_animation_hide_graph", "Hide graph") : 
                                       __txtx("panel_animation_show_graph", "Show graph");
                
                if(mouse_press(mb_left, pFOCUS)) {
                    if(prop.sep_axis) prop.show_graphs[animator.index] = !_graph_show;
                    else              prop.show_graph                  = !_graph_show;
                }
            } else
                draw_sprite_ui_uniform(THEME.timeline_graph, 1, tx, ty, 1, _graph_show? COLORS._main_accent : COLORS._main_icon, _graph_show? 1 : _tool_a);
        
        } tx -= tw;
           
        #region keyframe controls
            bc = [COLORS._main_icon, COLORS._main_icon_on_inner];    
            if(drw && buttonInstant(noone, tx-ui(10), ty-ui(9), tw, th, m, hov, foc, "", THEME.prop_keyframe, 2, bc, _tool_a) == 2) {
                for(var k = 0; k < array_length(animator.values); k++) {
                    var _key = animator.values[k];
                    if(_key.time > GLOBAL_CURRENT_FRAME) {
                        PROJECT.animator.setFrame(_key.time);
                        break;
                    }
                }
            
            } tx -= tw;
            
            bc = [COLORS._main_accent, COLORS._main_icon_on_inner];
            if(drw && buttonInstant(noone, tx-ui(10), ty-ui(9), tw, th, m, hov, foc, "", THEME.prop_keyframe, 1, bc, _tool_a) == 2) {
                var _add = false;
                for(var k = 0; k < array_length(animator.values); k++) {
                    var _key = animator.values[k];
                    if(_key.time == GLOBAL_CURRENT_FRAME) {
                        if(array_length(animator.values) > 1)
                            array_delete(animator.values, k, 1);
                        _add = true;
                        break;
                        
                    } else if(_key.time > GLOBAL_CURRENT_FRAME) {
                        array_insert(animator.values, k, new valueKey(GLOBAL_CURRENT_FRAME, variable_clone(animator.getValue()), animator));
                        _add = true;
                        break;    
                    }
                }
                
                if(!_add) array_push(animator.values, new valueKey(GLOBAL_CURRENT_FRAME, variable_clone(animator.getValue(, false)), animator));    
            
            } tx -= tw;
            
            bc = [COLORS._main_icon, COLORS._main_icon_on_inner];
            if(drw && buttonInstant(noone, tx-ui(10), ty-ui(9), tw, th, m, hov, foc, "", THEME.prop_keyframe, 0, bc, _tool_a) == 2) {
                var _t = -1;
                for(var k = 0; k < array_length(animator.values); k++) {
                    var _key = animator.values[k];
                    if(_key.time < GLOBAL_CURRENT_FRAME)
                        _t = _key.time;
                }
                if(_t > -1) PROJECT.animator.setFrame(_t);
                
            } tx -= tw;
        #endregion
        
        #region Looping
        	tx -= ui(4);
	        if(drw && hov && point_in_rectangle(msx, msy, tx - ui(10), ty - ui(9), tx + ui(10), ty + ui(8))) { 
	            draw_sprite_ui_uniform(THEME.prop_on_end, prop.on_end, tx, ty, 1, COLORS._main_icon_on_inner);
	            
	            if(tooltip_loop_prop != prop) tooltip_loop_type.arrow_pos = noone;
	            tooltip_loop_prop       = prop;
	            tooltip_loop_type.index = prop.on_end;
	            TOOLTIP = tooltip_loop_type;
	                            
	            if(mouse_release(mb_left, pFOCUS)) prop.on_end = safe_mod(prop.on_end + 1, sprite_get_number(THEME.prop_on_end));
	            if(mouse_press(  mb_left, pFOCUS)) on_end_dragging_anim = prop;
	            
	    		if(key_mod_press(SHIFT) && MOUSE_WHEEL != 0)
	    			prop.on_end = (prop.on_end + sign(MOUSE_WHEEL) + sprite_get_number(THEME.prop_on_end)) % sprite_get_number(THEME.prop_on_end);
	        } else
	            draw_sprite_ui_uniform(THEME.prop_on_end, prop.on_end, tx, ty, 1, on_end_dragging_anim == prop? COLORS._main_accent : COLORS._main_icon);
	        tx -= tw;
        #endregion
        
        draw_set_alpha(1);
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        var wl = tx - ui(16);
        var wh = ui(18);
        
        #region editWidget
        	var _edt = prop.getTimelineWidget();
        	var _wdw = wl * .5;
    		var _wh  = undefined;
        	
        	if(is(_edt, widget) && _wdw > ui(96)) {
	        	var _wdh = ui(15);
	        	var _wdx = tx - _wdw;
	        	var _wdy = ty - _wdh / 2 - ui(1);
	        	var _wrx = mouse_mx - msx;
	        	var _wry = mouse_my - msy;
	        	
	        	var _par = new widgetParam(_wdx, _wdy, _wdw, _wdh, prop.showValue(), prop.display_data, m, _wrx, _wry)
	        		.setS(_wdh).setFont(f_p4).setHide(1)
	        		
        		if(is(_edt, checkBox)) _par.setHalign(fa_center)
        		
        		if(drw) {
		        	_edt.setFocusHover(foc, hov);
		        	_wh = _edt.drawParam(_par);
		        	
        		} else
        			_wh = _edt.fetchHeight(_par);
        		
	        	if(_wh) wh = max(wh, _wh + ui(2));
        	}
        #endregion
        
        animator.h = wh;
        return wh;
    }
    
    function drawDopesheet_Label_Item(_item, _x, _y, msx = -1, msy = -1, alpha = 1) {
        var _itx = _x;
        var _ity = _y;
        var _itw = tool_width;
        var _hov = pHOVER && (msy > 0 && msy < dopesheet_h);
        var _foc = pFOCUS;
        
        var pd   = ui(4);
        var _res = _item.item.drawLabel(_item, _itx + pd, _ity, _itw - pd * 2, msx, msy, _hov, _foc, item_dragging, hovering_folder, node_name_type, alpha);
        
        if(_res == 1) {
            if(mouse_lpress(_foc)) {
                _item_dragging   = _item;
                item_dragging_mx = msx;
                item_dragging_my = msy;
                
                item_dragging_dx = msx - _x;
                item_dragging_dy = msy - _y;
            }
            
            if(mouse_rpress(_foc))
                context_selecting_item = _item;
        }
    }
	    
    function drawDopesheet_Label() { 
    	dopesheet_name_hover = pHOVER && point_in_rectangle(mx, my, ui(8), ui(8), ui(8) + tool_width, ui(8) + dopesheet_h);
    	
        surface_set_target(dopesheet_name_surface);    
        draw_clear_alpha(COLORS.panel_bg_clear_inner, 0);
        var msx = mx - ui(8);
        var msy = my - ui(8);
        
        draw_set_text(f_p2, fa_left, fa_center);
        
        value_hovering = noone;
        if(mouse_lclick(pFOCUS))
            value_focusing = noone;
            
        if(mouse_rpress(pFOCUS)) {
            context_selecting_item = noone;
            context_selecting_prop = noone;
        }
        
        #region draw
            hovering_folder = PROJECT.timelines;
            hovering_order  = 0;
            
            var last_y = 0;
            
            if(item_dragging != noone)
            for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
                var _cont = timeline_contents[i];
                if(!_cont.show && show_nodes) continue;
                
                var _y = _cont.y;
                var _h = _cont.h;
                
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
            }
            
            if(msy > last_y) {
                hovering_folder = PROJECT.timelines;
                hovering_order  = array_length(hovering_folder.contents);
            }
            
            var _itx, _ity = -1, _itw;
            
            for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
                var _cont = timeline_contents[i];
                if(!_cont.show && show_nodes) continue;
                
                var _y = _cont.y;
                var _h = _cont.h;
                
                if(item_dragging != noone && item_dragging.item == _cont.item) {
                    _itx = _cont.depth * ui(20);
                    _ity = _cont.y;
                    _itw = tool_width - _cont.depth * ui(20);
                    continue;
                }
                
                if(_y + _h < 0) continue;
                if(_y > h) break;
                
                if(show_nodes) drawDopesheet_Label_Item(_cont, 0, _cont.y, msx, msy);
                
                if(_cont.type == "node" && (_cont.item.show || !show_nodes)) {
                	var prop = _cont.item;
                    var tx   = tool_width;
        			var ty   = -infinity;
        			var ah;
        			
        			var _anims = _cont.animations;
	                for( var j = 0, m = array_length(_anims); j < m; j++ ) {
	                    ah = drawDopesheet_Label_Animator(_cont, _cont.node, _anims[j], msx, msy);
	                    ty = max(ty, _anims[j].y - 1);
	                }
	                
                }
            }
            
            if(_ity != -1) {
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
        
        BLEND_SUBTRACT
        draw_surface_safe(dopesheet_name_mask);
        BLEND_NORMAL
        surface_reset_target();
        
        if(on_end_dragging_anim != noone && mouse_release(mb_left)) on_end_dragging_anim = noone;
    }
    
    ////- Draw
    
    function drawDopesheet() { 
    	drawDopesheet_ResetTimelineMask();
    	
    	#region Tool width
    		var cc = COLORS._main_icon;
    		var aa = .5;
    		
	    	if(tool_width_drag) {
	            CURSOR = cr_size_we;
	            cc = COLORS._main_icon_light;
				aa = 1;
				
	            tool_width = tool_width_start + (mx - tool_width_mx);
	            tool_width = clamp(tool_width, ui(224), w - ui(128));
	            if(mouse_release(mb_left)) tool_width_drag = false;
	        }
	        
	        if(pHOVER && point_in_rectangle(mx, my, tool_width + ui(8), ui(8), tool_width + ui(16), ui(8) + dopesheet_h)) {
	            CURSOR = cr_size_we;
	            aa = 1;
	            
	            if(mouse_press(mb_left, pFOCUS)) {
	                tool_width_drag  = true;
	                tool_width_start = tool_width;
	                tool_width_mx    = mx;
	            }
	            
	        } 
	        
            var cy = ui(8) + dopesheet_h / 2;
	        draw_set_alpha(aa);
            draw_set_color(cc);
            draw_line_round(tool_width + ui(12), cy - ui(12), tool_width + ui(12), cy + ui(12), ui(3));
            draw_set_alpha(1);
        #endregion
        
        bar_x = tool_width + ui(16);
        bar_y = h - timeline_h - ui(10);
        bar_w = timeline_w;
        bar_h = timeline_h;
        
        bar_total_w     = GLOBAL_TOTAL_FRAMES * timeline_scale;
        bar_total_shift = bar_total_w + timeline_shift;
        if(pFOCUS && key_mod_double(ALT)) show_value = !show_value;
        
        #region Scroll
            dopesheet_y = lerp_float(dopesheet_y, dopesheet_y_to, 4);
                
            if(pHOVER && point_in_rectangle(mx, my, ui(8), ui(8), bar_x, ui(8) + dopesheet_h) && MOUSE_WHEEL != 0)
                dopesheet_y_to = clamp(dopesheet_y_to + ui(32) * MOUSE_WHEEL, -dopesheet_y_max, 0);
                
            var scr_x    = bar_x + dopesheet_w + ui(4);
            var scr_y    = ui(8);
            var scr_s    = dopesheet_h;
            var scr_prog = -dopesheet_y / dopesheet_y_max;
            var scr_size = dopesheet_h / (dopesheet_h + dopesheet_y_max);
                    
            var scr_scale_s = scr_s * scr_size;
            var scr_prog_s  = scr_prog * (scr_s - scr_scale_s);
                
            var scr_w   = scroll_w;
            var scr_h   = scr_s;
            var s_bar_w = scroll_w;
            var s_bar_h = scr_scale_s;
            var s_bar_x = scr_x;
            var s_bar_y = scr_y + scr_prog_s;
                
            if(is_scrolling) {
                if(scr_s - scr_scale_s != 0)
                    dopesheet_y_to = clamp((my - scr_y - scr_scale_s / 2) / (scr_s - scr_scale_s), 0, 1) * -dopesheet_y_max;
                    
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
		
        var msx = mx - bar_x;
        var msy = my - ui(8);
        
        surface_set_target(dopesheet_surface);    
        draw_clear_alpha(COLORS.panel_bg_clear, 1);
                
        #region BG & set X, Y for Node and Prop
            draw_sprite_stretched_ext(THEME.ui_panel_bg, 2, 0, 0, bar_w, dopesheet_h, COLORS.panel_animation_timeline_blend, 1);
            
            dopesheet_y_max = 0;
            var key_y = ui(22) + dopesheet_y;
            var c0, c1;
            
            for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
                var _cont = timeline_contents[i];
                var _item = _cont.item;
                
                _cont.y   = key_y;
                _cont.h   = 0;
                
                if(!_cont.show && show_nodes) continue;
                if(item_dragging != noone && item_dragging.item == _item) continue;
                
                var _expand = _cont.type == "node" && (_item.show || !show_nodes); 
                
                var _ks = key_y;
                if(_item.color_dsp > -1) {
                    draw_set_color(_item.color_dsp);
                    draw_rectangle(0, _ks - 1, bar_total_shift, _ks + _item.h, false);
                }
                
                if(_item.color_cur > -1) {
                    c0 = colorMultiply(_item.color_cur, COLORS.panel_animation_dope_key_bg);
                    c1 = colorMultiply(_item.color_cur, COLORS.panel_animation_dope_key_bg_hover);
                    
                } else {
                    c0 = COLORS.panel_animation_dope_key_bg;
                    c1 = COLORS.panel_animation_dope_key_bg_hover;
                }
                
                key_y   += _item.h * show_nodes + _expand * ui(10);
                _cont.h += _item.h * show_nodes;
                _ks      = key_y - ui(10);
                
                if(_expand) 
                for( var j = 0, m = array_length(_cont.props); j < m; j++ ) {
                    var  prop   = _cont.props[j];
                    var _prop   = prop.prop;
                         prop.y = key_y;
                    
                    var _anims = prop.animations;
                    for( var k = 0, p = array_length(_anims); k < p; k++ ) {
                    	var ph = max(ui(18), _anims[k].h);
                        _anims[k].y = key_y;
                        
                        if(_item.color_cur > -1) {
                            draw_set_color(c0);
                            draw_rectangle(0, key_y - ui(10), bar_total_shift, key_y + ui(10), false);
                            
                            var _vFocus = value_focusing != noone && _prop == value_focusing.prop;
                            var _vHover = value_hovering != noone && _prop == value_hovering.prop;
                            
                        	     if(_vFocus) draw_sprite_stretched_ext(THEME.box_r2, 0, 0, key_y - ui(8), bar_total_shift, ui(16), c1);
                            else if(_vHover) draw_sprite_stretched_ext(THEME.box_r2, 0, 0, key_y - ui(8), bar_total_shift, ui(16), c1, .9);
                        }
                        
                        if(k) prop.y = key_y;
                        key_y       += ph;
                        _cont.h     += ph;
                    }
                    
                    var _graph_show = _prop.sep_axis? array_any(_prop.show_graphs, function(v) /*=>*/ {return v == true}) : _prop.show_graph;
                    
                    if(_graph_show && _prop.type != VALUE_TYPE.color) {
                        if(_item.color_cur > -1) {
                            draw_set_color(c1);
                            draw_rectangle(0, key_y - ui(10), bar_total_shift, key_y + ui(_prop.graph_h) - ui(2), false);
                        }
                        
                        var _gr_h = ui(_prop.graph_h);
                        key_y   += _gr_h + ui(8);
                        _cont.h += _gr_h + ui(8);
                    }
                }
                
                key_y -= _expand * ui(10);
                dopesheet_y_max += _cont.h;
            }
            
            dopesheet_y_max = max(0, dopesheet_y_max - dopesheet_h + ui(48));
            
            var _stW = timeline_separate * timeline_scale;
            var _st  = ceil(-timeline_shift / _stW);
            var _fr  = _st + ceil(bar_w / _stW);
            
            for(var i = _st; i <= _fr; i++) {
                var bar_frame = i * timeline_separate;
                var _aa = (bar_frame % timeline_separate == 0? 1 : 0.1) * ((bar_frame <= GLOBAL_TOTAL_FRAMES) * 0.5 + 0.5);
                
                drawFrameLine(bar_frame, ui(16), dopesheet_h, COLORS.panel_animation_frame_divider, _aa);
            }
            
            drawFrameLine(GLOBAL_TOTAL_FRAMES, ui(16), dopesheet_h, COLORS.panel_animation_end_line, .5);
            drawFrameLine(0,            ui(16), dopesheet_h, COLORS.panel_animation_end_line, .5);
        #endregion
        
        var key_hover = drawDopesheet_Graph();
        
        #region Draw & Edit Keyframes 
        	_keyframe_selecting_f = noone;
        	_keyframe_selecting_l = noone;
        	region_hovering       = noone;
        	
        	var _len = array_length(timeline_contents);
        	
        	timeline_snap_points = array_verify(timeline_snap_points, _len + 1);
        	timeline_snap_line   = [];
        	
            for( var i = 0; i < _len; i++ ) {
                var _cont = timeline_contents[i];
                if(_cont.type != "node") continue;
                
                var _node  = _cont.node;
                var _anims = _cont.animations;
                
                if(!is_struct(timeline_snap_points[i])) {
	                timeline_snap_points[i] = {
	                	node   : _node,
	                	points : [],
	                }
                } else {
                	timeline_snap_points[i].node   = _node;
                	timeline_snap_points[i].points = [];
                }
                
                if(_node.attributes.timeline_override) {
                	var _x = timeline_shift;
                	var _y = _cont.y;
                	var _s = timeline_scale;
                	
                	var _hovering = _node.drawTimeline(_x, _y, _s, msx, msy, self);
                	if(_hovering) keyframe_boxable = false;
                	timeline_snap_points[i] = _node.timeline_content_snap;
                	
                } else {
	                var _keyFirst   =  infinity;
	        		var _keyLast    = -infinity;
	                
	                for( var j = 0, m = array_length(_anims); j < m; j++ ) {
	                    var _anim  = _anims[j];
				        
				        for(var k = 0, p = array_length(_anim.values); k < p; k++) {
				            _keyFirst = min(_keyFirst, _anim.values[k].dopesheet_x);
				    		_keyLast  = max(_keyLast,  _anim.values[k].dopesheet_x);
				        }
	                }
	                
	                if(_keyFirst != infinity && _keyFirst != _keyLast) {
	                	var _ex0 = _keyFirst;
	                	var _ex1 = _keyLast;
	                	var _ey0 = _cont.y + ui(10) - ui(8);
	                	var _ey1 = _cont.y + ui(10) + ui(8);
	                	
	                	var frameFirst = (_keyFirst - timeline_shift) / timeline_scale;
	                	var frameLast  = (_keyLast  - timeline_shift) / timeline_scale;
	                	
	                	var _ew = _ex1 - _ex0;
	                	var _eh = _ey1 - _ey0;
	                	var _es = ui(4);
	                	
	                	var _hovF = pHOVER && point_in_rectangle(msx, msy, _ex0 - _es, _ey0, _ex0 + _es, _ey1);
	                	var _hovL = pHOVER && point_in_rectangle(msx, msy, _ex1 - _es, _ey0, _ex1 + _es, _ey1);
	                	var _hovC = pHOVER && point_in_rectangle(msx, msy, _ex0, _ey0, _ex1, _ey1);
	                	
	                	var _hov = 0;
	                	if(_hovC) _hov = 1;
	                	if(_hovF) _hov = 2;
	                	if(_hovL) _hov = 3;
	                	
	                	var baseC = _cont.item.getColor();
	                	if(baseC == -1) baseC = CDEF.main_ltgrey;
	                	
	                	var _drg = timeline_content_dragging != undefined && timeline_content_dragging.node == _cont.node;
	                	var _hlg = _hov || _drg;
	                	draw_sprite_stretched_ext(THEME.box_r2, 0, _ex0, _ey0, _ew, _eh, baseC, .2 + _hlg * .3);
	                	draw_sprite_stretched_add(THEME.box_r2, 1, _ex0, _ey0, _ew, _eh, baseC, .2);
	                	
	                	if(_drg) draw_sprite_stretched_ext(THEME.box_r2, 1, _ex0, _ey0, _ew, _eh, COLORS._main_accent, 1);
	                	
	                	var _hlg = _hovF || (_drg && timeline_content_drag_type == 2);
	                	if(_hlg) {
	                		var cc = _drg && timeline_content_drag_type == 2? COLORS._main_accent : baseC;
	                		draw_sprite_stretched_ext(THEME.box_r2, 0, _ex0 - _es, _ey0, _es*2, _eh, cc, 1);
	                	}
	                	
	                	var _hlg = _hovL || (_drg && timeline_content_drag_type == 3);
	                	if(_hlg) {
	                		var cc = _drg && timeline_content_drag_type == 3? COLORS._main_accent : baseC;
	                		draw_sprite_stretched_ext(THEME.box_r2, 0, _ex1 - _es, _ey0, _es*2, _eh, cc, 1);
	                	}
	                	
	                	if(_hov) {
	                		keyframe_boxable = false;
	                		
	                		if(mouse_lpress(pFOCUS)) {
	                			timeline_content_dragging   = _cont;
	                			timeline_content_drag_type  = _hov;
	                			
	                			timeline_content_drag_dx       = 0;
	                			timeline_content_drag_mx       = msx;
	                			timeline_content_drag_range[0] = frameFirst;
	                			timeline_content_drag_range[1] = frameLast;
	                		}
	                	}
	                	
	                	timeline_snap_points[i].points = [ frameFirst, frameLast ];
	                }
                }
	            
                for( var j = 0, m = array_length(_anims); j < m; j++ ) {
                    var _anim = _anims[j];
                    var _key  = drawDopesheet_AnimatorKeys(_cont, _anim, msx, msy);
                    if(_key != noone) key_hover = _key;
                }
                
            }
            
            var _markers = PROJECT.timelineMarkers;
            timeline_snap_points[_len] = {
            	node   : undefined,
            	points : PROJECT.timelineMarkersArray,
            }
            
        	for( var i = 0, n = array_length(timeline_snap_line); i < n; i++ ) {
            	var _snapx = timeline_shift + timeline_snap_line[i] * timeline_scale;
            	
            	draw_set_color(COLORS._main_icon);
            	draw_line(_snapx, 0, _snapx, h);
        	}
            
            if(timeline_content_dragging != undefined) {
            	timeline_content_drag_dx += (msx - timeline_content_drag_mx) / timeline_scale;
            	timeline_content_drag_mx  = msx;
            	
            	var _delta = floor(timeline_content_drag_dx);
            	var _anims = timeline_content_dragging.animations;
            	
            	if(_delta != 0) {
	            	if(timeline_content_drag_type == 1) {
		                for( var j = 0, m = array_length(_anims); j < m; j++ ) {
		                    var _anim  = _anims[j];
					        for(var k = 0, p = array_length(_anim.values); k < p; k++)
					            _anim.values[k].time += _delta;
		                }
		                
	            	} else if(timeline_content_drag_type == 2 || timeline_content_drag_type == 3) {
	            		var _os = timeline_content_drag_range[0] - 1;
	            		var _oe = timeline_content_drag_range[1] - 1;
	            		
	            		timeline_content_drag_range[timeline_content_drag_type - 2] += _delta;
	            		
	            		var _ns = timeline_content_drag_range[0] - 1;
	            		var _ne = timeline_content_drag_range[1] - 1;
	            		
	            		for( var j = 0, m = array_length(_anims); j < m; j++ ) {
		                    var _anim  = _anims[j];
					        for(var k = 0, p = array_length(_anim.values); k < p; k++) {
					            _anim.values[k].time = lerp(_ns, _ne, (_anim.values[k].time - _os) / (_oe - _os));
					        }
		                }
		                
	            	}
	                
	            	timeline_content_drag_dx -= _delta;
            	}
            	
            	if(mouse_lrelease()) {
            		for( var j = 0, m = array_length(_anims); j < m; j++ )
                    	_anims[j].updateKeyMap();
                    	
            		timeline_content_dragging = undefined;
            	}
            }
            
            keyframe_selecting_f = _keyframe_selecting_f;
        	keyframe_selecting_l = _keyframe_selecting_l;
        	
	        if(pHOVER && point_in_rectangle(msx, msy, 0, ui(18), dopesheet_w, dopesheet_h) && timeline_stretch == 0) { // selection & stagger
	            if(mouse_rpress(pFOCUS) && key_hover == noone)
	                keyframe_selecting = [];
	            
	            if(key_mod_press(CTRL)) {
	                var _fr = round((mx - bar_x - timeline_shift) / timeline_scale) - 1;
	                
	            	if(value_hovering != noone && key_hover == noone) {
		                var _kx = (_fr + 1) * timeline_scale + timeline_shift;
		                var _ky = value_hovering.y;
		                draw_sprite_ui_uniform(THEME.add, 0, _kx, _ky, .5, COLORS._main_value_positive, 1);
		                
		                if(mouse_press(mb_left, pFOCUS)) {
		                	var _nk  = new valueKey(_fr, variable_clone(value_hovering.getValue(_fr)), value_hovering);
		                	var _add = false;
		                	
		                	for(var k = 0; k < array_length(value_hovering.values); k++) {
			                    var _key = value_hovering.values[k];
			                    if(_key.time <= _fr) continue;
			                    
		                        array_insert(value_hovering.values, k, _nk);
		                        _add = true;
		                        break;
			                }
		                	
		                	if(!_add) array_push(value_hovering.values, _nk);
		                	value_hovering.updateKeyMap();
		                }
            		}
	            	
	            	if(value_hovering == noone && mouse_click(mb_left, pFOCUS)) PROJECT.animator.setFrame(_fr);
	            	
	            } else if(mouse_lpress(pFOCUS)) {
	                     if(key_hover == noone)                           keyframe_selecting = [];
	                else if(key_mod_press(SHIFT))                         array_toggle(keyframe_selecting, key_hover);
	                else if(!array_exists(keyframe_selecting, key_hover)) keyframe_selecting = [ key_hover ];
	                
	                if(stagger_mode == 1) {
	                    if(key_hover == noone || !array_exists(keyframe_selecting, key_hover)) 
	                        stagger_mode = 0;
	                    else {
	                        arrangeKeys();
	                        stagger_index = array_find(keyframe_selecting, key_hover);
	                        stagger_mode  = 2;
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
	                var tm = max(0, round((mx - bar_x - timeline_shift) / timeline_scale) - 1);
	                var st = tm - ts;
	                
	                staggerKeys(stagger_index, st);
	            }
	        }
	        
	        if(keyframe_dragging) { // drag key
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
	                            
	                if(mouse_release(mb_left)) {
	                    keyframe_dragging = noone;
	                    
	                    for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
	                        var k  = keyframe_selecting[i];
	                        k.anim.setKeyTime(k, k.time, true, true);
	                    }
	                    
	                    UNDO_HOLDING = false;
	                }
	                
	            } else if(keyframe_drag_type == KEYFRAME_DRAG_TYPE.scale) {
	            	var tt = round((mx - bar_x - timeline_shift) / timeline_scale) - 1;
	                tt = max(tt, 0);
	                
	                var _sf = keyframe_drag_sv.time;
	                var _st = keyframe_dragging.time;
	                
	                if(_st != _sf) {
		                var _sca = (tt - _sf) / (_st - _sf);
		            	var edited = false;
		                
		                for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
		                    var k  = keyframe_selecting[i];
		                    var kt = _sf + (k.time - _sf) * _sca;
		                    
		                    if(k.anim.setKeyTime(k, kt, false, true))
		                        edited = true;
		                }
		                
		                if(edited) UNDO_HOLDING = true;
		                
		                var _tsca = (tt - _sf) / (keyframe_drag_st - _sf);
	                	TOOLTIP = $"{__txt("Key stretch")} {keyframe_drag_st - _sf} > {tt - _sf} [{string_format(_tsca * 100, -1, 2)}%]";
	                }
	                            
	                if(mouse_release(mb_left)) {
	                    keyframe_dragging = noone;
	                    
	                    for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
	                        var k  = keyframe_selecting[i];
	                        k.anim.setKeyTime(k, k.time, true, true);
	                    }
	                    
	                    UNDO_HOLDING = false;
	                }
	                
	            } else {
	                var _dx = ((keyframe_dragging.time + 1) - (mx - bar_x - timeline_shift) / timeline_scale) / 2;
	                var _in = keyframe_dragging.ease_in;
	                var _ot = keyframe_dragging.ease_out;
	            	
	                switch(keyframe_drag_type) {
	                    case KEYFRAME_DRAG_TYPE.ease_in :
	                    	_dx = clamp(_dx, 0, 1);
	                    	
	                        for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
	                            var k = keyframe_selecting[i];
	                            
	                            k.ease_in_type = _dx > 0? CURVE_TYPE.bezier : CURVE_TYPE.linear;
	                            k.ease_in[0]   = _dx;
	                            k.ease_in[1]   = 1;
	                        }
	                    
	                        break;
	                    case KEYFRAME_DRAG_TYPE.ease_out :
	                    	_dx = clamp(-_dx, 0, 1);
	                    	
	                        for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
	                            var k = keyframe_selecting[i];
	                            
	                            k.ease_out_type = _dx > 0? CURVE_TYPE.bezier : CURVE_TYPE.linear;
	                            k.ease_out[0]   = _dx;
	                            k.ease_out[1]   = 0;
	                        }
	                        break;
	                        
	                    case KEYFRAME_DRAG_TYPE.ease_both :
                            _dx = clamp(abs(_dx), 0, 1);
                    		if(_dx < .1) _dx = 0;
                    		
	                        for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
	                            var k  = keyframe_selecting[i];
	                            
	                            k.ease_in_type  = _dx > 0? CURVE_TYPE.bezier : CURVE_TYPE.linear;
	                            k.ease_in[0]    = _dx;
	                            k.ease_in[1]    = 1;
	                        
	                            k.ease_out_type = _dx > 0? CURVE_TYPE.bezier : CURVE_TYPE.linear;
	                            k.ease_out[0]   = _dx;
	                            k.ease_out[1]   = 0;
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
        
        #region Overlay 
            var hh = ui(20);
            
            var bar_line_x = (GLOBAL_CURRENT_FRAME + 1) * timeline_scale + timeline_shift;
            
            var cc = PROJECT.animator.is_playing? COLORS._main_value_positive : COLORS._main_accent;
            var aa = (GLOBAL_CURRENT_FRAME >= 0 && GLOBAL_CURRENT_FRAME < GLOBAL_TOTAL_FRAMES) * .5 + .5;
            drawFrameLine(GLOBAL_CURRENT_FRAME + 1, PANEL_PAD, dopesheet_h, cc, aa);
            
            var _phover = pHOVER && msy > hh;
            for( var i = 0, n = array_length(timeline_contents); i < n; i++ ) {
                var _cont = timeline_contents[i];
                if(!_cont.show && show_nodes) continue;
                
                var _hov  = _cont.item.drawDopesheetOver(timeline_shift, _cont.y, timeline_scale, msx, msy, _phover, pFOCUS);
                if(is_undefined(_hov)) continue;
                if(_hov) keyframe_boxable = false;
            }
            
            draw_set_color(COLORS.panel_animation_timeline_top);
            draw_rectangle(0, 0, bar_w, hh, false);
	            
			#region Markers
				var _markers = PROJECT.timelineMarkers;
				var _s = .4;
				var _y = sprite_get_height(THEME.timeline_marker) * .5 * _s - ui(2);
				
				for( var i = 0, n = array_length(_markers); i < n; i++ ) {
					var _m = _markers[i];
					var _f = _m.frame;
					var _l = _m.label;
					
					var _x = timeline_shift + _f * timeline_scale;
					draw_sprite_ui(THEME.timeline_marker, 1, _x, _y, _s, _s, 0, COLORS._main_icon,  .7);
				}
			#endregion
			
			#region Frame number
	            var _stW = timeline_separate * timeline_scale;
	            var _st  = ceil(-timeline_shift / _stW);
	            var _fr  = _st + ceil(bar_w / _stW);
	            
	            for(var i = _st; i <= _fr; i++) {
	                var bar_frame = i * timeline_separate;
	                var ln_x = bar_frame * timeline_scale + timeline_shift;
	                var ln_a = (bar_frame < 0 || bar_frame > GLOBAL_TOTAL_FRAMES)? .5 : 1;
	                
	                draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub, ln_a);
	                draw_text_add(ln_x, PANEL_PAD, bar_frame);
	            }
	            
	            draw_set_alpha(1);
	            draw_set_text(f_p2, fa_center, fa_top, CDEF.main_mdwhite);
	            var end_x = GLOBAL_TOTAL_FRAMES * timeline_scale + timeline_shift;
	            draw_text_add(end_x, PANEL_PAD, GLOBAL_TOTAL_FRAMES);
            
	            var end_x = 0 * timeline_scale + timeline_shift;
	            draw_text_add(end_x, PANEL_PAD, 0);
	            
	            if(pHOVER && point_in_rectangle(mx, my, 0, 0, w, h)) {
	            	var _frame_hover   = round((msx - timeline_shift) / timeline_scale);
	            	var _frame_hover_x = _frame_hover * timeline_scale + timeline_shift;
	            	
		            draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub, .5);
		            draw_text_add(_frame_hover_x, PANEL_PAD, _frame_hover);
		            draw_set_alpha(1);
	            }
            #endregion
            
            if(PROJECT.onion_skin.enabled) { // ONION SKIN
                var rang = PROJECT.onion_skin.range;
                var colr = PROJECT.onion_skin.color;
            
                var fr = GLOBAL_CURRENT_FRAME + 1;
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
                    draw_sprite_ui(THEME.arrow, 2, _sx, yc, 1, 1, 0, colr[0], 1);
                
                    if(mouse_press(mb_left, pFOCUS))
                        onion_dragging = 0;
                    timeline_draggable = false;
                    
                } else
                    draw_sprite_ui(THEME.arrow, 2, _sx, yc, 1, 1, 0, colr[0], 0.5);
            
                if(point_in_circle(msx, msy, _ex, yc, ui(8))) {
                    draw_sprite_ui(THEME.arrow, 0, _ex, yc, 1, 1, 0, colr[1], 1);
                
                    if(mouse_press(mb_left, pFOCUS))
                        onion_dragging = 1;
                    timeline_draggable = false;
                    
                } else 
                    draw_sprite_ui(THEME.arrow, 0, _ex, yc, 1, 1, 0, colr[1], 0.5);
                
                if(onion_dragging != noone) {
                    if(onion_dragging == 0) {
                        var mf = round((msx - timeline_shift + ui(8)) / timeline_scale) - fr;
                            mf = min(mf, 0);
                    
                        if(PROJECT.onion_skin.range[0] != mf)
                            PROJECT.onion_skin.range[0] = mf;
                        
                    } else if(onion_dragging == 1) {
                        var mf = round((msx - timeline_shift - ui(8)) / timeline_scale) - fr;
                            mf = max(mf, 0);
                    
                        if(PROJECT.onion_skin.range[1] != mf)
                            PROJECT.onion_skin.range[1] = mf;
                    }
                    
                    if(mouse_release(mb_left))
                        onion_dragging = noone;
                }
            }
            
            draw_set_font(f_p2);
            var cf = string(GLOBAL_CURRENT_FRAME + 1);
            var tx = string_width(cf) + ui(4);
            
            if(timeline_frame_typing && timeline_stretch == 0) {
	            draw_sprite_stretched_ext(THEME.box_r2, 0, bar_line_x - tx / 2, 0, tx, hh + PANEL_PAD, CDEF.main_dkblack, 1);
	            draw_sprite_stretched_ext(THEME.box_r2, 1, bar_line_x - tx / 2, 0, tx, hh + PANEL_PAD, cc, 1);
	            
	            draw_set_text(f_p2, fa_center, fa_top, cc);
	            draw_text_add(bar_line_x, PANEL_PAD, cf);
	            
            } else {
	            draw_sprite_stretched_ext(THEME.box_r2, 0, bar_line_x - tx / 2, 0, tx, hh + PANEL_PAD, cc, 1);
	            
	            draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_on_accent);
	            draw_text_add(bar_line_x, PANEL_PAD, cf);
            }
            
            if(timeline_frame_typing && timeline_stretch) {
            	var bar_end_x = GLOBAL_TOTAL_FRAMES * timeline_scale + timeline_shift;
            	var cc = COLORS._main_value_positive;
            	var cf = string(GLOBAL_TOTAL_FRAMES);
            	var tx = string_width(cf) + ui(4);
            	
            	draw_sprite_stretched_ext(THEME.box_r2, 0, bar_end_x - tx / 2, 0, tx, hh + PANEL_PAD, CDEF.main_dkblack, 1);
	            draw_sprite_stretched_ext(THEME.box_r2, 1, bar_end_x - tx / 2, 0, tx, hh + PANEL_PAD, cc, 1);
	            
	            draw_set_text(f_p2, fa_center, fa_top, cc);
	            draw_text_add(bar_end_x, PANEL_PAD, cf);
            }
            
			#region Markers
				var _markers = PROJECT.timelineMarkers;
				var _s = .4;
				var _y = sprite_get_height(THEME.timeline_marker) * .5 * _s - ui(2);
				
				for( var i = 0, n = array_length(_markers); i < n; i++ ) {
					var _m = _markers[i];
					var _f = _m.frame;
					var _l = _m.label;
					
					if(_f - 1 != GLOBAL_CURRENT_FRAME) continue;
					
					var _x = timeline_shift + _f * timeline_scale;
					draw_sprite_ui(THEME.timeline_marker, 1, _x, _y, _s, _s, 0, COLORS._main_icon_dark, 1);
				}
			#endregion
			
        #endregion
        
        #region End Line
        	var stx = bar_total_shift;
	        var sty = ui(10);
	        var drw = timeline_stretch > 0;
	        var _cc = timeline_stretch == 1? COLORS._main_accent : COLORS._main_value_positive;
	        
			if(!GLOBAL_IS_PLAYING && timeline_stretch == 0 && pHOVER && point_in_circle(msx, msy, stx, sty, sty)) { 
				_cc = COLORS._main_icon_light;
				drw = true;
			}
	        
            if(drw) drawFrameLine(GLOBAL_TOTAL_FRAMES, sty - ui(10), sty + ui(10), _cc);
        #endregion
        
        if(keyframe_boxing) {
            draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, keyframe_box_sx, keyframe_box_sy, msx, msy, COLORS._main_accent);
            if(mouse_release(mb_left)) keyframe_boxing = false;
        }
        
        BLEND_SUBTRACT
        draw_surface_safe(dopesheet_mask);
        BLEND_NORMAL
        surface_reset_target();
        
        drawDopesheet_Label();
        
        if(keyframe_boxable && mouse_rpress(pFOCUS)) { // context menu
        	__selecting_frame = clamp(round((mx - bar_x - timeline_shift) / timeline_scale), 0, GLOBAL_TOTAL_FRAMES - 1);
        	
            if(point_in_rectangle(mx, my, bar_x, ui(8), bar_x + dopesheet_w, ui(8) + dopesheet_h)) {
            	// if(region_hovering != noone)             menuCallGen("animation_region");
                if(array_empty(keyframe_selecting)) menuCallGen("animation_keyframe_empty");
                else                                menuCallGen("animation_keyframe");
                
            } else if(point_in_rectangle(mx, my, ui(8), ui(8), ui(8) + tool_width, ui(8) + dopesheet_h)) {
                if(context_selecting_prop != noone) {
                    if(context_selecting_prop.sepable) menuCallGen("animation_name_prop_axis");
                    else                               menuCallGen("animation_name_empty");
                }
                else if(context_selecting_item == noone)                    menuCallGen("animation_name_empty");
                else if(is(context_selecting_item.item, timelineItemNode))  menuCallGen("animation_name_item");
                else if(is(context_selecting_item.item, timelineItemGroup)) menuCallGen("animation_name_group");
            }
        }
            
        draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), ui(8), tool_width, dopesheet_h);
        draw_surface_safe(dopesheet_name_surface, ui(8), ui(8));
        
        draw_sprite_stretched(THEME.ui_panel_bg, 1, bar_x, ui(8), bar_w, dopesheet_h);
        draw_surface_safe(dopesheet_surface, bar_x, ui(8));
        
        draw_sprite_stretched(THEME.ui_panel_bg_cover, 1, bar_x, ui(8), bar_w, dopesheet_h);
        
        if(item_dragging != noone) drawDopesheet_Label_Item(item_dragging, mx - item_dragging_dx, my - item_dragging_dy,,, 0.5);
    
    	dopeSheet_TimelineScrub();
    	dopeSheet_TimelineStretch();
    }
    
    ////- Actions
    	
    function doDuplicate() {
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
    }
    
    function doCopy() {
        ds_list_clear(copy_clipboard);
        for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ )
            ds_list_add(copy_clipboard, keyframe_selecting[i]);
    }
    
    function doPaste(val = noone) {
        if(ds_list_empty(copy_clipboard)) return;
        
        var shf  = 0;
        var minx = GLOBAL_TOTAL_FRAMES + 2;
        for( var i = 0; i < ds_list_size(copy_clipboard); i++ )
            minx = min(minx, copy_clipboard[| i].time);
        shf = GLOBAL_CURRENT_FRAME - minx;
        
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
    }
	
	function doQuantize() {
		for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
			var k = keyframe_selecting[i];
			k.time = round(k.time);
		}
	}
	
    function repeatKeys_anim(_anim) {
    	__anim = _anim;
    	var _keys = array_filter(keyframe_selecting, function(k) /*=>*/ {return k.anim == __anim});
        if(array_length(_keys) < 2) return;
        
    	var _tLast   = array_reduce(_anim.values,       function(v, k) /*=>*/ {return max(v, k.time)}, -infinity);
    	var _kFirst  = array_reduce(_keys, function(v, k) /*=>*/ {return min(v, k.time)},  infinity);
    	var _kLast   = array_reduce(_keys, function(v, k) /*=>*/ {return max(v, k.time)}, -infinity);
    	var _kLength = _kLast - _kFirst;
    	var _kEnds_last = -infinity;
    	
        if(array_length(_keys) == 2) {
        	for( var i = 0, n = array_length(_keys); i < n; i++ ) {
	    		var _k = _keys[i];
	    		var _nt = _tLast + _kLength + (_k.time - _kFirst);
	    		var _nk = _k.clone(_anim);
	    		
	    		_nk.value = variable_clone(_k.value);
	    		_nk.time  = _nt;
	    		_kEnds_last = max(_kEnds_last, _nt);
	    		
	    		array_push(_anim.values, _nk);
	    	}
        	
        } else {
	    	for( var i = 0, n = array_length(_keys); i < n; i++ ) {
	    		var _k = _keys[i];
	    		if(_k.time == _kFirst) continue;
	    		
	    		var _nt = _tLast + (_k.time - _kFirst);
	    		var _nk = _k.clone(_anim);
	    		
	    		_nk.value = variable_clone(_k.value);
	    		_nk.time  = _nt;
	    		_kEnds_last = max(_kEnds_last, _nt);
	    		
	    		array_push(_anim.values, _nk);
	    	}
        }
        
    	array_sort(_anim.values, function(a,b) /*=>*/ {return a.time - b.time});
    	_anim.updateKeyMap();
    	_anim.prop.node.triggerRender();
    }
    function repeatKeys() {
        if(array_empty(keyframe_selecting)) return;
        
        var _anims = array_create_ext(array_length(keyframe_selecting), function(i) /*=>*/ {return keyframe_selecting[i].anim});
            _anims = array_unique(_anims);
        
        array_foreach(_anims, function(a) /*=>*/ {return repeatKeys_anim(a)});
    }
    
    function distributeKeys_anim(_anim, _fr, _to) {
    	__anim = _anim;
    	var _keys = array_filter(keyframe_selecting, function(k) /*=>*/ {return k.anim == __anim});
        if(array_length(_keys) <= 2) return;
        
    	array_sort(_keys, function(a,b) /*=>*/ {return a.time - b.time});
    	for( var i = 0, n = array_length(_keys); i < n; i++ ) {
    		var _k = _keys[i];
    		var _t = lerp(_fr, _to, i / (n - 1));
    		
    		_k.time = _t;
    	}
    	
    	array_sort(_anim.values, function(a,b) /*=>*/ {return a.time - b.time});
    	_anim.updateKeyMap();
    	_anim.prop.node.triggerRender();
    }
    function distributeKeys() {
        if(array_empty(keyframe_selecting)) return;
        
        var _anims = array_create_ext(array_length(keyframe_selecting), function(i) /*=>*/ {return keyframe_selecting[i].anim});
            _anims = array_unique(_anims);
        
    	__kFirst = array_reduce(keyframe_selecting, function(v, k) /*=>*/ {return min(v, k.time)},  infinity);
    	__kLast  = array_reduce(keyframe_selecting, function(v, k) /*=>*/ {return max(v, k.time)}, -infinity);
    	
        array_foreach(_anims, function(a) /*=>*/ {return distributeKeys_anim(a, __kFirst, __kLast)});
    }
    
    function alignKeys(halign = fa_left) {
        if(array_empty(keyframe_selecting)) return;
        
        __tt = 0;
        
        switch(halign) {
            case fa_left  : __tt = array_reduce(keyframe_selecting, function(v, k) /*=>*/ {return min(v, k.time)},  infinity); break;
            case fa_right : __tt = array_reduce(keyframe_selecting, function(v, k) /*=>*/ {return max(v, k.time)}, -infinity); break;
                
            case fa_center :    
            	__tt = array_reduce(keyframe_selecting, function(v, k) /*=>*/ {return v + k.time}, 0);
                __tt = round(__tt / array_length(keyframe_selecting));
                break;
        }
        
        array_foreach(keyframe_selecting, function(k) /*=>*/ { k.anim.setKeyTime(k, __tt,, true) });
    }
    
    function arrangeKeys() {}
    
    function staggerKeys(_index, _stag) {
        var modified = false;
        var t = keyframe_selecting[_index].time;
        
        for( var i = 0, n = array_length(keyframe_selecting); i < n; i++ ) {
            var k = keyframe_selecting[i];
            var _t = t + abs(i -  _index) * _stag;
            
            modified = k.anim.setKeyTime(k, _t) || modified;
        }
        
        if(modified) UNDO_HOLDING = true;
    }
    
    function modulateKeys(_type = KEYFRAME_MODULATE.envelope) {
    	if(array_empty(keyframe_selecting)) return;
        
        __anim = keyframe_selecting[0].anim;
        __prop = __anim.prop; 
        __keys = array_filter(keyframe_selecting, function(k) /*=>*/ {return k.anim == __anim});
        
	    if(!isGraphable(__prop) || __prop.type == VALUE_TYPE.color) return;
        if(array_length(__keys) < 2) return;
        
	    __prop.show_graph = true;
    	modulate_animator = __anim;
	    modulate_keys     = array_create_ext(array_length(__keys), function(v) /*=>*/ {return [__keys[v], __keys[v].clone()]});
	    
	    var _kFirst = array_reduce(__keys, function(v, k) /*=>*/ {return min(v, k.time)},  infinity);
    	var _kLast  = array_reduce(__keys, function(v, k) /*=>*/ {return max(v, k.time)}, -infinity);
    	var _vFirst = array_reduce(__keys, function(v, k) /*=>*/ {return min(v, array_min(k.value))},  infinity);
    	var _vLast  = array_reduce(__keys, function(v, k) /*=>*/ {return max(v, array_max(k.value))}, -infinity);
    	
	    modulate_range       = [ _kFirst, _kLast ];
	    modulate_value_range = [ _vFirst, _vLast ];
	    
	    modulate_curve  = CURVE_DEF_01;
	    modulate_amount = [ 0, 0 ];
	    modulate_type   = _type;
    }
    
	function reverseKeys_anim(_anim, _fr, _to) {
		__anim = _anim;
    	var _keys = array_filter(keyframe_selecting, function(k) /*=>*/ {return k.anim == __anim});
        if(array_length(_keys) < 2) return;
        
    	for( var i = 0, n = array_length(_keys); i < n; i++ ) {
    		var _k = _keys[i];
    		var _t = _to - (_k.time - _fr);
    		_k.time = _t;
    	}
    	
    	array_sort(_anim.values, function(a,b) /*=>*/ {return a.time - b.time});
    	_anim.updateKeyMap();
    	_anim.prop.node.triggerRender();
	}
	function reverseKeys() {
		if(array_length(keyframe_selecting) < 2) return;
		
		var _anims = array_create_ext(array_length(keyframe_selecting), function(i) /*=>*/ {return keyframe_selecting[i].anim});
            _anims = array_unique(_anims);
        
    	__kFirst = array_reduce(keyframe_selecting, function(v, k) /*=>*/ {return min(v, k.time)},  infinity);
    	__kLast  = array_reduce(keyframe_selecting, function(v, k) /*=>*/ {return max(v, k.time)}, -infinity);
    	
        array_foreach(_anims, function(a) /*=>*/ {return reverseKeys_anim(a, __kFirst, __kLast)});
        
	}
	
}

function tooltipAnimEnd() constructor {
	static drawTooltip = function() {
		var lh = line_get_height(f_p1);
		var _h = lh * 2 + ui(4);
		var _w = ui(136);
		
		var mx = min(mouse_mxs + ui(16), WIN_W - (_w + ui(16) + ui(4)));
		var my = min(mouse_mys + ui(16), WIN_H - (_h + ui(16) + ui(4)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, _w + ui(16), _h + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, _w + ui(16), _h + ui(16));
		
		var yy = my + ui(8);
		draw_set_text(f_p1b, fa_left, fa_top, COLORS._main_text_sub);
		draw_text(mx + ui(116), yy,              "Ctrl");
		draw_text(mx + ui(116), yy + lh + ui(4), "Alt");
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
		draw_text(mx + ui(8), yy,              "Adjust Length");
		draw_text(mx + ui(8), yy + lh + ui(4), "Stretch");
	}
}