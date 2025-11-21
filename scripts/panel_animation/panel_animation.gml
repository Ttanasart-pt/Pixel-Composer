#region ___function calls
    function panel_animation_settings_call()           { var dia = dialogPanelCall(new Panel_Animation_Setting()); dia.anchor = ANCHOR.none;                                                             }
    function panel_animation_scale_call()              { dialogPanelCall(new Panel_Animation_Scaler());                                                                                                  }
    
    function panel_animation_play_pause()              { CALL("play_pause");           if(GLOBAL_IS_RENDERING) return; if(GLOBAL_IS_PLAYING) PROJECT.animator.pause() else PROJECT.animator.play();                    }
    function panel_animation_resume()                  { CALL("resume_pause");         if(GLOBAL_IS_RENDERING) return; if(PROJECT.animator.is_playing) PROJECT.animator.pause() else PROJECT.animator.resume(); }
    
    function panel_animation_first_frame()             { CALL("first_frame");          if(GLOBAL_IS_RENDERING) return; PROJECT.animator.firstFrame();                                                           }
    function panel_animation_last_frame()              { CALL("last_frame");           if(GLOBAL_IS_RENDERING) return; PROJECT.animator.lastFrame();                                                            }
    function panel_animation_prev_frame()              { CALL("previous_frame");       if(GLOBAL_IS_RENDERING) return; PROJECT.animator.setFrame(max(PROJECT.animator.real_frame - 1, 0));                      }
    function panel_animation_next_frame()              { CALL("next_frame");           if(GLOBAL_IS_RENDERING) return; PROJECT.animator.setFrame(min(PROJECT.animator.real_frame + 1, GLOBAL_TOTAL_FRAMES - 1));       }
    function panel_animation_prev_keyframe()           { CALL("previous_keyframe");    if(GLOBAL_IS_RENDERING) return; PANEL_ANIMATION.toPrevKeyframe(); }
    function panel_animation_next_keyframe()           { CALL("next_keyframe");        if(GLOBAL_IS_RENDERING) return; PANEL_ANIMATION.toNextKeyframe(); }
    
    function panel_animation_collapseToggle()          { CALL("animation_collapse_toggle");         PANEL_ANIMATION.collapseToggle();                                                                    }
    function panel_animation_delete_key()              { CALL("animation_delete_key");              PANEL_ANIMATION.deleteKeys();                                                                        }
    function panel_animation_duplicate()               { CALL("animation_duplicate");               PANEL_ANIMATION.doDuplicate();                                                                       }
    function panel_animation_copy()                    { CALL("animation_copy");                    PANEL_ANIMATION.doCopy();                                                                            }
    function panel_animation_paste()                   { CALL("animation_paste");     if(PANEL_ANIMATION.value_focusing != noone) PANEL_ANIMATION.doPaste(PANEL_ANIMATION.value_focusing.prop);          }
    function panel_animation_show_nodes()              { CALL("animation_toggle_nodes");            PANEL_ANIMATION.show_nodes = !PANEL_ANIMATION.show_nodes;                                            }
    function panel_animation_quantize()                { CALL("animation_quantize");                PANEL_ANIMATION.doQuantize();                                                                        }
    
    function panel_animation_edit_keyframe_value()     { CALL("animation_edit_keyframe_value");     PANEL_ANIMATION.edit_keyframe_value();   }
    function panel_animation_edit_keyframe_lock_y()    { CALL("animation_edit_lock_keyframe_y");    PANEL_ANIMATION.edit_keyframe_lock_y();  }
    function panel_animation_edit_keyframe_stagger()   { CALL("animation_stagger");                 PANEL_ANIMATION.edit_keyframe_stagger(); }
    function panel_animation_keyframe_driver()         { CALL("animation_driver");                  PANEL_ANIMATION.edit_keyframe_driver();  }
    
    function panel_animation_keyframe_align_left()     { CALL("animation_align_left");              PANEL_ANIMATION.alignKeys(fa_left);   }
    function panel_animation_keyframe_align_center()   { CALL("animation_align_center");            PANEL_ANIMATION.alignKeys(fa_center); }
    function panel_animation_keyframe_align_right()    { CALL("animation_align_right");             PANEL_ANIMATION.alignKeys(fa_right);  }
    function panel_animation_keyframe_repeat()         { CALL("animation_repeat");                  PANEL_ANIMATION.repeatKeys();         }
    function panel_animation_keyframe_distribute()     { CALL("animation_distribute");              PANEL_ANIMATION.distributeKeys();     }
    function panel_animation_keyframe_reverse()        { CALL("animation_reverse");                 PANEL_ANIMATION.reverseKeys();        }
    function panel_animation_keyframe_envelope()       { CALL("animation_envelope");                PANEL_ANIMATION.modulateKeys(KEYFRAME_MODULATE.envelope);  }
    function panel_animation_keyframe_randomize()      { CALL("animation_randomize");               PANEL_ANIMATION.modulateKeys(KEYFRAME_MODULATE.randomize); }
    
    function panel_animation_dopesheet_folder()        { CALL("animation_new_folder");              PANEL_ANIMATION.dopesheet_new_folder();        }
    function panel_animation_dopesheet_folder_select() { CALL("animation_new_folder_select");       PANEL_ANIMATION.dopesheet_new_folder_select(); }
    function panel_animation_dopesheet_expand()        { CALL("animation_dopesheet_expand");        PANEL_ANIMATION.dopesheet_expand();            }
    function panel_animation_dopesheet_collapse()      { CALL("animation_dopesheet_collapse");      PANEL_ANIMATION.dopesheet_collapse();          }
    
    function panel_animation_group_rename()            { CALL("animation_rename_group");            PANEL_ANIMATION.group_rename();          }
    function panel_animation_group_remove()            { CALL("animation_remove_group");            PANEL_ANIMATION.group_remove();          }
    function panel_animation_toggle_axis()             { CALL("animation_toggle_axis");             PANEL_ANIMATION.toggle_axis();           }
    function panel_animation_separate_axis()           { CALL("animation_separate_axis");           PANEL_ANIMATION.separate_axis();         }
    function panel_animation_combine_axis()            { CALL("animation_combine_axis");            PANEL_ANIMATION.combine_axis();          }
    
    function panel_animation_range_set_start()         { CALL("animation_range_set_start");         PANEL_ANIMATION.range_set_start();       }
    function panel_animation_range_set_end()           { CALL("animation_range_set_end");           PANEL_ANIMATION.range_set_end();         }
    function panel_animation_range_reset()             { CALL("animation_range_reset");             PANEL_ANIMATION.range_reset();           }
    
    function panel_animation_reset_view()              { CALL("animation_view_reset");              PANEL_ANIMATION.resetView();             }
    
    function panel_animation_new_folder()               { CALL("animation_new_folder");               PANEL_ANIMATION.newFolder();              }
    function panel_animation_toggle_NodeNameType(d=1)   { CALL("animation_toggle_NodeNameType");      PANEL_ANIMATION.toggleNodeNameType(d);    }
    function panel_animation_toggle_NodeLabel()         { CALL("animation_toggle_NodeLabel");         PANEL_ANIMATION.toggleNodeLabel();        }
    function panel_animation_toggle_KeyframeOverride()  { CALL("animation_toggle_KeyframeOverride");  PANEL_ANIMATION.toggleKeyframeOverride(); }
    function panel_animation_toggle_OnionSkin()         { CALL("animation_toggle_OnionSkin");         PANEL_ANIMATION.toggleOnionSkin();        }
    
	function __fnInit_Animation() {
        registerFunction("",          "Play/Pause",         vk_space,   MOD_KEY.none,  panel_animation_play_pause     ).setMenu("play_pause")
        registerFunction("",          "Resume/Pause",       vk_space,   MOD_KEY.shift, panel_animation_resume         ).setMenu("resume_pause")
                                
        registerFunction("",          "First Frame",        vk_home,    MOD_KEY.none,  panel_animation_first_frame    ).setMenu("first_frame")
        registerFunction("",          "Last Frame",         vk_end,     MOD_KEY.none,  panel_animation_last_frame     ).setMenu("last_frame")
        registerFunction("",          "Previous Frame",     vk_left,    MOD_KEY.none,  panel_animation_prev_frame     ).setMenu("previous_frame")
        registerFunction("",          "Next Frame",         vk_right,   MOD_KEY.none,  panel_animation_next_frame     ).setMenu("next_frame")
        registerFunction("",          "Previous Keyframe",  vk_pageup,  MOD_KEY.none,  panel_animation_prev_keyframe  ).setMenu("previous_keyframe")
        registerFunction("",          "Next Keyframe",      vk_pagedown,MOD_KEY.none,  panel_animation_next_keyframe  ).setMenu("next_keyframe")
    
        registerFunction("Animation", "Delete keys",        vk_delete,  MOD_KEY.none,  panel_animation_delete_key     ).setMenu("animation_delete_keys")
        registerFunction("Animation", "Duplicate",          "D",        MOD_KEY.ctrl,  panel_animation_duplicate      ).setMenu("animation_duplicate", THEME.duplicate)
        registerFunction("Animation", "Copy",               "C",        MOD_KEY.ctrl,  panel_animation_copy           ).setMenu("animation_copy",      THEME.copy)
        registerFunction("Animation", "Paste",              "V",        MOD_KEY.ctrl,  panel_animation_paste          ).setMenu("animation_paste",     THEME.paste)
        registerFunction("Animation", "Collapse Toggle",    "C",        MOD_KEY.none,  panel_animation_collapseToggle ).setMenu("animation_collapse_toggle")
        registerFunction("Animation", "Toggle Nodes",       "H",        MOD_KEY.none,  panel_animation_show_nodes     ).setMenu("animation_toggle_nodes")
        
        registerFunction("Animation", "Animation Settings...", "S",    MOD_KEY.ctrl | MOD_KEY.shift, panel_animation_settings_call ).setMenu("animation_settings", THEME.animation_setting )
        registerFunction("Animation", "Animation Scaler...",   "",     MOD_KEY.none,                 panel_animation_scale_call    ).setMenu("animation_scaler",   THEME.animation_timing  )
        
        registerFunction("Animation", "Edit Keyframe Value","",  MOD_KEY.none, panel_animation_edit_keyframe_value    ).setMenu("animation_edit_keyframe_value", )
        registerFunction("Animation", "Toggle Keyframe Y",  "",  MOD_KEY.none, panel_animation_edit_keyframe_lock_y   ).setMenu("animation_lock_keyframe_y",     )
        registerFunction("Animation", "Driver...",          "",  MOD_KEY.none, panel_animation_keyframe_driver        ).setMenu("animation_driver",              )
        
        registerFunction("Animation", "Align Left",         "A", MOD_KEY.none, panel_animation_keyframe_align_left    ).setMenu("animation_align_left"   )
        registerFunction("Animation", "Align Center",       "",  MOD_KEY.none, panel_animation_keyframe_align_center  ).setMenu("animation_align_center" )
        registerFunction("Animation", "Align Right",        "",  MOD_KEY.none, panel_animation_keyframe_align_right   ).setMenu("animation_align_right"  )
        
        registerFunction("Animation", "Quantize Keys",      "Q", MOD_KEY.none, panel_animation_quantize               ).setMenu("animation_quantize")
        registerFunction("Animation", "Stagger Keys",       "",  MOD_KEY.none, panel_animation_edit_keyframe_stagger  ).setMenu("animation_stagger",     )
        registerFunction("Animation", "Repeat Keys",        "R", MOD_KEY.none, panel_animation_keyframe_repeat        ).setMenu("animation_repeat"       )
        registerFunction("Animation", "Distribute Keys",    "D", MOD_KEY.none, panel_animation_keyframe_distribute    ).setMenu("animation_distribute"   )
        registerFunction("Animation", "Reverse Keys",       "I", MOD_KEY.none, panel_animation_keyframe_reverse       ).setMenu("animation_reverse"      )
        registerFunction("Animation", "Envelope Keys",      "",  MOD_KEY.none, panel_animation_keyframe_envelope      ).setMenu("animation_envelope"     )
        registerFunction("Animation", "Randomize Keys",     "",  MOD_KEY.none, panel_animation_keyframe_randomize     ).setMenu("animation_randomize"    )
        
        registerFunction("Animation", "New Folder",                "", MOD_KEY.none, panel_animation_dopesheet_folder        ).setMenu("animation_new_folder",          THEME.folder)
        registerFunction("Animation", "New Folder From Selection", "", MOD_KEY.none, panel_animation_dopesheet_folder_select ).setMenu("animation_new_folder_select",   THEME.folder)
        registerFunction("Animation", "Dopesheet Expand",          "", MOD_KEY.none, panel_animation_dopesheet_expand        ).setMenu("animation_dopesheet_expand",    )
        registerFunction("Animation", "Dopesheet Collapse",        "", MOD_KEY.none, panel_animation_dopesheet_collapse      ).setMenu("animation_dopesheet_collapse",  )
        
        registerFunction("Animation", "Rename Group",       "", MOD_KEY.none, panel_animation_group_rename          ).setMenu("animation_rename_group",        )
        registerFunction("Animation", "Remove Group",       "", MOD_KEY.none, panel_animation_group_remove          ).setMenu("animation_remove_group",        THEME.cross)
        registerFunction("Animation", "Separate/Combine Axis",        "", MOD_KEY.none, panel_animation_toggle_axis           ).setMenu("animation_toggle_axis",         )
        registerFunction("Animation", "Separate Axis",      "", MOD_KEY.none, panel_animation_separate_axis         ).setMenu("animation_separate_axis",       )
        registerFunction("Animation", "Combine Axis",       "", MOD_KEY.none, panel_animation_combine_axis          ).setMenu("animation_combine_axis",        )
        
        registerFunction("Animation", "Set Range Start",    "", MOD_KEY.none, panel_animation_range_set_start       ).setMenu("animation_set_range_start",     [ THEME.frame_range, 0 ])
        registerFunction("Animation", "Set Range End",      "", MOD_KEY.none, panel_animation_range_set_end         ).setMenu("animation_set_range_end",       [ THEME.frame_range, 1 ])
        registerFunction("Animation", "Reset Range",        "", MOD_KEY.none, panel_animation_range_reset           ).setMenu("animation_reset_range",         )
        
        registerFunction("Animation", "Reset View",        "F", MOD_KEY.none, panel_animation_reset_view            ).setMenu("animation_reset_view",          )
        
        registerFunction("Animation", "Node Name Display", "", MOD_KEY.none, panel_animation_toggle_NodeNameType    )
        	.setMenu("animation_toggle_NodeNameType",     THEME.node_name_type    ).setSpriteInd(function() /*=>*/ {return PANEL_ANIMATION.node_name_type} )
        	.setTooltip(new tooltipSelector("Name Display", [
	            __txtx("panel_animation_name_full", "Full name"),
	            __txtx("panel_animation_name_type", "Node type"),
	            __txtx("panel_animation_name_only", "Node name"),
	        ])).setScroll()
	        
        registerFunction("Animation", "Show Node Name",    "", MOD_KEY.none, panel_animation_toggle_NodeLabel       )
        	.setMenu("animation_toggle_NodeLabel",        THEME.visible           ).setSpriteInd(function() /*=>*/ {return PANEL_ANIMATION.show_nodes}     )
        	
        registerFunction("Animation", "Override Keyframe", "", MOD_KEY.none, panel_animation_toggle_KeyframeOverride)
        	.setMenu("animation_toggle_KeyframeOverride", THEME.keyframe_override ).setSpriteInd(function() /*=>*/ {return global.FLAG.keyframe_override}  )
        	
        registerFunction("Animation", "Onion Skin",        "", MOD_KEY.none, panel_animation_toggle_OnionSkin       )
        	.setMenu("animation_toggle_OnionSkin",        THEME.onion_skin        ).setSpriteInd(function() /*=>*/ {return PROJECT.onion_skin.enabled}     )
        
        registerFunction("Animation", "Edit Sidebar...",   "", MOD_KEY.none, function() /*=>*/ {return menuItemEdit("animation_sidebar")}).setMenu("animation_edit_sidebar");
        
        __fnGroupInit_Animation();
    }
    
    function __fnGroupInit_Animation() {
    	var s = THEME.timeline_ease;
        var t = "panel_animation_ease";
        
        MENU_ITEMS.animation_group_ease_in = menuItemGroup(__txtx($"{t}_in", "Ease in"),  [ 
			[ [s,0], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_in_type = CURVE_TYPE.linear; k.ease_in = [0, 1]; }) }, __txtx($"{t}_linear",    "Linear")    ],
			[ [s,1], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_in_type = CURVE_TYPE.bezier; k.ease_in = [1, 1]; }) }, __txtx($"{t}_smooth",    "Smooth")    ],
			[ [s,2], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_in_type = CURVE_TYPE.bezier; k.ease_in = [1, 2]; }) }, __txtx($"{t}_overshoot", "Overshoot") ],
			[ [s,3], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_in_type = CURVE_TYPE.bezier; k.ease_in = [0, 0]; }) }, __txtx($"{t}_sharp",     "Sharp")     ],
			[ [s,4], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_in_type = CURVE_TYPE.cut;    k.ease_in = [0, 0]; }) }, __txtx($"{t}_hold",      "Hold")      ],
        ], [ "Animation", "Ease In" ]);
        registerFunction("Animation", "Ease In", "", MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.animation_group_ease_in ]); });
        
        MENU_ITEMS.animation_group_ease_out = menuItemGroup(__txtx($"{t}_out", "Ease out"),  [ 
            [ [s,0], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_out_type = CURVE_TYPE.linear; k.ease_out = [0, 0]; }) }, __txtx($"{t}_linear",    "Linear")    ],
            [ [s,1], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_out_type = CURVE_TYPE.bezier; k.ease_out = [1, 0]; }) }, __txtx($"{t}_smooth",    "Smooth")    ],
            [ [s,2], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_out_type = CURVE_TYPE.bezier; k.ease_out = [1,-1]; }) }, __txtx($"{t}_overshoot", "Overshoot") ],
            [ [s,3], function() /*=>*/ { array_foreach(PANEL_ANIMATION.keyframe_selecting, function(k) /*=>*/ { k.ease_out_type = CURVE_TYPE.bezier; k.ease_out = [0, 1]; }) }, __txtx($"{t}_sharp",     "Sharp")     ],
        ], [ "Animation", "Ease Outs" ]);
        registerFunction("Animation", "Ease Out", "", MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.animation_group_ease_out ]); });
        
        MENU_ITEMS.animation_group_align = menuItemGroup(__txt("Align"),  [ 
            [ [THEME.object_halign, 0], function() /*=>*/ { PANEL_ANIMATION.alignKeys(fa_left);   } ],
            [ [THEME.object_halign, 1], function() /*=>*/ { PANEL_ANIMATION.alignKeys(fa_center); } ],
            [ [THEME.object_halign, 2], function() /*=>*/ { PANEL_ANIMATION.alignKeys(fa_right);  } ],
        ], [ "Animation", "Align" ]);
        registerFunction("Animation", "Align", "", MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.animation_group_align ]); });
        
        var _clrs = COLORS.labels;
        var _item = array_create(array_length(_clrs));
        
        for( var i = 0, n = array_length(_clrs); i < n; i++ )
            _item[i] = [ [ THEME.timeline_color, i > 0, _clrs[i] ], function(_data) /*=>*/ { PANEL_ANIMATION.setSelectingItemColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] } ];
        
        array_push(_item, [ 
            [ THEME.timeline_color, 2 ], 
            function(_data) /*=>*/ { colorSelectorCall(PANEL_ANIMATION.context_selecting_item? PANEL_ANIMATION.context_selecting_item.item.getColor() : c_white, PANEL_ANIMATION.setSelectingItemColor); }
        ]);
        
        MENU_ITEMS.animation_group_label_color = menuItemGroup(__txt("Color"), _item, ["Animation", "Label Color"]).setSpacing(ui(24));
        registerFunction("Animation", "Label Color", "", MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.animation_group_label_color ]); });
    }
#endregion

function Panel_Animation() : PanelContent() constructor {
    title        = __txt("Animation");
    context_str  = "Animation";
    icon         = THEME.panel_animation_icon;
    
	#region ---- Dimension ----
	    min_w = ui(40);
	    min_h = ui(48);
	    
	    tool_width = ui(224);
	    timeline_w = w - tool_width - ui(68);
	    timeline_h = ui(28);
	#endregion

    Panel_Animation_Dopesheet();
    
    #region ---- Timeline ----
    	timeline_surface = noone;
	    timeline_mask    = noone;
	    
        timeline_scubbing = false;
        timeline_scub_st  = 0;
        timeline_scale    = 20;
        timeline_separate = 5;
        timeline_sep_line = 1;
        _scrub_frame      = -1;
        
        timeline_shift      = 0;
        timeline_shift_to   = 0;
        timeline_dragging   = false;
        timeline_drag_sx    = 0;
        timeline_drag_sy    = 0;
        timeline_drag_mx    = 0;
        timeline_drag_my    = 0;
        
        timeline_show_time  = -1;
        timeline_preview    = noone;
        
        timeline_contents   = [];
        
        node_name_type    = 0;
    #endregion
    
    #region ++++ Control Buttons ++++
        tooltip_toggle_nodes = new tooltipHotkey(__txtx("panel_animation_show_node", "Toggle node label"), "Animation", "Toggle Nodes");
        tooltip_resume       = new tooltipHotkey(__txt("Resume"), "", "Resume/Pause");
        tooltip_pause        = new tooltipHotkey(__txt("Pause"),  "", "Resume/Pause");
        tooltip_fr_first     = new tooltipHotkey(__txtx("panel_animation_go_to_first_frame", "Go to first frame"),  "", "First Frame");
        tooltip_fr_last      = new tooltipHotkey(__txtx("panel_animation_go_to_last_frame", "Go to last frame"),    "", "Last Frame");
        tooltip_fr_prev      = new tooltipHotkey(__txtx("panel_animation_previous_frame", "Previous frame"),        "", "Previous Frame");
        tooltip_fr_next      = new tooltipHotkey(__txtx("panel_animation_next_frame", "Next frame"),                "", "Next Frame");
    
        control_buttons = [ 
            [ 
              function() /*=>*/ {return __txt("Stop")},
              function() /*=>*/ {return 4},
              function() /*=>*/ {return PROJECT.animator.is_playing? COLORS._main_accent : COLORS._main_icon},
              function() /*=>*/ { PROJECT.animator.stop(); }  
            ],
            [ 
              function() /*=>*/ {return PROJECT.animator.is_playing? tooltip_pause : tooltip_resume},
              function() /*=>*/ {return !PROJECT.animator.is_playing},
              function() /*=>*/ {return PROJECT.animator.is_playing? COLORS._main_accent : COLORS._main_icon},
              function() /*=>*/ { if(PROJECT.animator.is_playing) PROJECT.animator.pause(); else PROJECT.animator.resume(); } 
            ],
            [ 
              function() /*=>*/ {return tooltip_fr_first},
              function() /*=>*/ {return 3},
              function() /*=>*/ {return COLORS._main_icon},
              function() /*=>*/ { PROJECT.animator.firstFrame(); } 
            ],
            [ 
              function() /*=>*/ {return tooltip_fr_last},
              function() /*=>*/ {return 2},
              function() /*=>*/ {return COLORS._main_icon},
              function() /*=>*/ { PROJECT.animator.lastFrame(); } 
            ],
            [ 
              function() /*=>*/ {return tooltip_fr_prev},
              function() /*=>*/ {return 5},
              function() /*=>*/ {return COLORS._main_icon},
              function() /*=>*/ { PROJECT.animator.setFrame(PROJECT.animator.real_frame - 1); } 
            ],
            [ 
              function() /*=>*/ {return tooltip_fr_next},
              function() /*=>*/ {return 6},
              function() /*=>*/ {return COLORS._main_icon},
              function() /*=>*/ { PROJECT.animator.setFrame(PROJECT.animator.real_frame + 1); } 
            ],
        ];
    #endregion
    
    #region ++++ Menu ++++
    	global.menuItems_animation_summary = [
    		"animation_set_range_start",
			"animation_set_range_end",
			"animation_reset_range",
		];
    	
    	global.menuItems_animation_sidebar = [
    		"animation_new_folder",
			"animation_toggle_NodeNameType",
			"animation_toggle_NodeLabel",
			"animation_toggle_KeyframeOverride",
			"animation_toggle_OnionSkin",
		];
		
    	global.menuItems_animation_sidebar_context = [
    		"animation_edit_sidebar", 
		];
    #endregion
    
    function onFocusBegin() { PANEL_ANIMATION = self; }
    
    ////- Interaction
    
    function timelineScrub() {
    	var bar_x = tool_width + ui(16);
        var bar_y = h - timeline_h - ui(10);
        var bar_w = timeline_w;
        var bar_h = timeline_h;
        
        var bar_total_w = GLOBAL_TOTAL_FRAMES * timeline_scale;
    	var bar_line_w  = GLOBAL_TOTAL_FRAMES * timeline_scale + timeline_shift;
        var bar_int_x   = min(bar_x + bar_w, bar_x + bar_line_w);
        
        timeline_shift = lerp_float(timeline_shift, timeline_shift_to, 4);
        
        if(timeline_scubbing) {
            var rfrm = (mx - bar_x - timeline_shift) / timeline_scale - 1;
            if(!key_mod_press(CTRL)) rfrm = clamp(rfrm, 0, GLOBAL_TOTAL_FRAMES - 1);
            
            PROJECT.animator.setFrame(rfrm, !key_mod_press(ALT));
            
            timeline_show_time = GLOBAL_CURRENT_FRAME;
            if(timeline_show_time != _scrub_frame)
                _scrub_frame = timeline_show_time;
                
	        if(mouse_release(mb_left))
	            timeline_scubbing = false;
        }
        
        if(timeline_dragging) {
            timeline_shift_to = timeline_drag_sx + mx - timeline_drag_mx;
            timeline_shift    = timeline_shift_to;
            dopesheet_y_to   = clamp(timeline_drag_sy + my - timeline_drag_my, -dopesheet_y_max, 0);
                
            if(mouse_release(mb_middle))
                timeline_dragging = false;
        }
        
        if(!pHOVER) return;
        
        if(point_in_rectangle(mx, my, bar_x, ui(16), bar_x + bar_w, bar_y + bar_h)) {
            var sca = timeline_scale;
            
            if(MOUSE_WHEEL != 0) timeline_scale = clamp(timeline_scale + MOUSE_WHEEL, 1, 100);
            
            timeline_separate = 5;
            timeline_sep_line = 1;
            
                 if(timeline_scale <=  1) { timeline_separate =  50; timeline_sep_line = 10; }
            else if(timeline_scale <=  3) { timeline_separate =  20; timeline_sep_line =  5; }
            else if(timeline_scale <= 10) { timeline_separate =  10; timeline_sep_line =  2; }
            
            if(sca != timeline_scale) {
                var mfb = (mx - bar_x - timeline_shift) / timeline_scale;
                var mfa = (mx - bar_x - timeline_shift) / sca;
                
                timeline_shift_to = timeline_shift_to - (mfa - mfb) * timeline_scale;
                timeline_shift    = timeline_shift_to;
            }
            
            if(mouse_press(mb_middle, pFOCUS)) {
                timeline_dragging = true;
                
                timeline_drag_sx = timeline_shift;
                timeline_drag_sy = dopesheet_y_to;
                timeline_drag_mx = mx;
                timeline_drag_my = my;
            }
        }
            
        if(point_in_rectangle(mx, my, bar_x, bar_y, bar_x + bar_w, bar_y + bar_h)) {
        	if(DOUBLE_CLICK) {
				timeline_frame_typing = true;
        		KEYBOARD_RESET
        		
        	} else if(mouse_press(mb_left, pFOCUS) && mx < bar_int_x) {
                timeline_scubbing = true;
                timeline_scub_st  = GLOBAL_CURRENT_FRAME;
                _scrub_frame      = timeline_scub_st;
                KEYBOARD_RESET
        	}
            
            if(mouse_press(mb_right, pFOCUS)) {
                __selecting_frame = clamp(round((mx - bar_x - timeline_shift) / timeline_scale), 0, GLOBAL_TOTAL_FRAMES - 1);
                menuCall("animation_summary", menuItems_gen("animation_summary"));
            }
        }
        
    }
    
    ////- Draw
    
    function resetTimelineMask() {
    	timeline_w = w - tool_width - ui(64);
	    timeline_h = ui(28);
	    
        timeline_mask    = surface_verify(timeline_mask, timeline_w, timeline_h);
        timeline_surface = surface_verify(timeline_surface, timeline_w, timeline_h);
            
        surface_set_target(timeline_mask);
        draw_clear(c_black);
    	BLEND_SUBTRACT
        	draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, timeline_w, timeline_h);
		BLEND_NORMAL
        surface_reset_target();
    } 
    
    function getTimelineContentFolder(folder, _context = [], _depth = 0, _show = true) {
        var _ind = 0;
        
        for( var i = 0, n = array_length(folder.contents); i < n; i++ ) {
            var _cont = folder.contents[i];
            if(!_cont.active) continue;
            
            var _content = {
                y: 0,
                h: 0,
                item:     _cont,
                parent:   _cont.parent,
                index:    _ind,
                contexts: _context,
                depth:    _depth,
                show:     _show,
            };
            
            if(is(_cont, timelineItemNode)) {
                var _node = _cont.node;
                if(!is_struct(_node)) continue;
                if(_node.instanceBase != undefined) continue;
                
                var _anim = [];
                var _prop = [];
                
                for( var j = 0, m = array_length(_node.inputs); j < m; j++ ) {
                    var prop = _node.inputs[j];
                    if(!prop.isTimelineVisible()) continue;
                    
                    var anim = prop.sep_axis? prop.animators : [ prop.animator ];
                    array_append(_anim, anim);
                    array_push(_prop, { prop, animators: anim, y: 0 });
                }
                
                _content.type      = "node";
                _content.node      = _node;
                _content.props     = _prop;
                _content.animators = _anim;
                
                array_push(timeline_contents, _content);
                
            } else if(is(_cont, timelineItemGroup)) {
                _content.type = "folder";
                array_push(timeline_contents, _content);
                
                var _context_folder = array_create(array_length(_context) + 1);
                for( var j = 0, m = array_length(_context); j < m; j++ ) 
                    _context_folder[j] = _context[j];
                _context_folder[m] = _content;
                
                if(item_dragging == noone || item_dragging.item != _cont)
                    getTimelineContentFolder(_cont, _context_folder, _depth + 1, _show && _cont.show || !show_nodes);
                    
            }
            
            if(item_dragging == noone || item_dragging.item != _cont) _ind++;
        }
        
    }
    
    function getTimelineContent() {
        timeline_contents = [];
        getTimelineContentFolder(PROJECT.timelines);
    }
    
    function drawTimeline() { // Draw summary
    	var bar_x       = tool_width + ui(16);
        var bar_y       = h - timeline_h - ui(10);
        var bar_w       = timeline_w;
        var bar_h       = timeline_h;
        var bar_total_w = GLOBAL_TOTAL_FRAMES * timeline_scale;
        var inspecting  = PANEL_INSPECTOR.getInspecting();
        
        var msx = mx - bar_x;
        var msy = my - bar_y;
        
        resetTimelineMask();
        timeline_surface = surface_verify(timeline_surface, timeline_w, timeline_h);
            
        surface_set_target(timeline_surface);    
	        draw_clear_alpha(COLORS.panel_bg_clear, 0);
	        
	        draw_sprite_stretched(THEME.ui_panel_bg, 1, 0, 0, bar_w, bar_h);
	        draw_sprite_stretched_ext(THEME.ui_panel_bg, 2, 0, 0, bar_w, bar_h, COLORS.panel_animation_timeline_blend, 1);
	        
	        #region BG & Lines
		        if(inspecting && inspecting.use_cache) { //cache
		        	draw_set_alpha(0.05);
		            for(var i = 0, n = min(GLOBAL_TOTAL_FRAMES, array_length(inspecting.cache_result)); i < n; i++) {
		                var x0 = (i + 0) * timeline_scale + timeline_shift;
		                var x1 = (i + 1) * timeline_scale + timeline_shift;
		                
		                draw_set_color(inspecting.getAnimationCacheExist(i)? c_lime : c_red);
		                draw_rectangle(x0, 0, x1 - 1, bar_h, false);
		            }
	                draw_set_alpha(1);
		        }
	        
	            var _stW = timeline_separate * timeline_scale;
	            var _st  = ceil(-timeline_shift / _stW);
	            var _fr  = _st + ceil(bar_w / _stW);
	            
	            for(var i = _st; i <= _fr; i++) {
	                var bar_frame  = i * timeline_separate;
	                var bar_line_x = bar_frame * timeline_scale + timeline_shift;
	                var ln_a = (bar_frame < 0 || bar_frame > GLOBAL_TOTAL_FRAMES)? .5 : 1;
	                
	                draw_set_alpha(ln_a);
	                draw_set_color(COLORS.panel_animation_frame_divider);
	                draw_line(bar_line_x, ui(12), bar_line_x, bar_h - PANEL_PAD);
	                    
	                draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text_sub);
	                draw_text_add(bar_line_x, ui(16), string(bar_frame));
	            }
	            
	            draw_set_alpha(1);
	            
                var bar_line_x = GLOBAL_TOTAL_FRAMES * timeline_scale + timeline_shift;
                
                draw_set_text(f_p2, fa_center, fa_bottom, CDEF.main_mdwhite);
                draw_text_add(bar_line_x, ui(16), GLOBAL_TOTAL_FRAMES);
                
	            draw_set_color_alpha(COLORS.panel_animation_end_line, .5);
                draw_line_width(bar_line_x, ui(12), bar_line_x, bar_h, 2);
                
                var bar_line_x = 0 * timeline_scale + timeline_shift;
                
                draw_set_text(f_p2, fa_center, fa_bottom, CDEF.main_mdwhite);
                draw_text_add(bar_line_x, ui(16), 0);
                
                draw_set_color_alpha(COLORS.panel_animation_end_line, .5);
                draw_line_width(bar_line_x, ui(12), bar_line_x, bar_h, 2);
	            	
	            draw_set_alpha(1);
	            
	            if(GLOBAL_FRAME_RANGE_START || GLOBAL_FRAME_RANGE_END) {
	                var _fr_x0 = GLOBAL_FRAME_RANGE_START * timeline_scale + timeline_shift - 6;
	                var _fr_x1 = GLOBAL_FRAME_RANGE_END   * timeline_scale + timeline_shift + 2;
	                var _rng_spr = PROJECT.animator.is_simulating? THEME.ui_selection_range_sim_hori : THEME.ui_selection_range_hori;
	                var _rng_clr = PROJECT.animator.is_simulating? COLORS.panel_animation_range_sim  : COLORS.panel_animation_range;
	                
	                draw_sprite_stretched_ext(_rng_spr, 0, _fr_x0, 0, _fr_x1 - _fr_x0, bar_h, _rng_clr, 1);
	            }
	            
	            if(pHOVER && point_in_rectangle(mx, my, 0, 0, w, h)) {
	            	var _frame_hover   = round((msx - timeline_shift) / timeline_scale);
	            	var _frame_hover_x = _frame_hover * timeline_scale + timeline_shift;
	            	
	            	draw_set_alpha(0.5);
	            	draw_set_color(COLORS._main_text_sub);
	            	draw_line(_frame_hover_x, ui(15), _frame_hover_x, bar_h - PANEL_PAD);
		            draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text_sub);
		            draw_text_add(_frame_hover_x, ui(16), _frame_hover);
		            draw_set_alpha(1);
	            }
	            
	            var bar_line_x = (GLOBAL_CURRENT_FRAME + 1) * timeline_scale + timeline_shift;
	            var cc = PROJECT.animator.is_playing? COLORS._main_value_positive : COLORS._main_accent;
	            
	            draw_set_color(cc);
	            draw_set_alpha((GLOBAL_CURRENT_FRAME >= 0 && GLOBAL_CURRENT_FRAME < GLOBAL_TOTAL_FRAMES) * .5 + .5);
	            draw_line(bar_line_x, ui(15), bar_line_x, bar_h - PANEL_PAD);
	            draw_set_alpha(1);
	            
	            draw_set_text(f_p2, fa_center, fa_bottom, cc);
	            var cf = string(GLOBAL_CURRENT_FRAME + 1);
            	var tx = string_width(cf) + ui(4);
            	
	            draw_text_add(bar_line_x, ui(16), cf);
	            
	            if(inspecting) inspecting.drawAnimationTimeline(timeline_shift, bar_w, bar_h, timeline_scale);
	        #endregion
	            
	        #region Summary \\\ Set X for all keyframes
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
	            
	        BLEND_SUBTRACT
	        draw_surface_safe(timeline_mask);
	        BLEND_NORMAL
        surface_reset_target(); //timeline_surface
        
        draw_surface_safe(timeline_surface, bar_x, bar_y);
        
    }
    
    function drawAnimationSettings() {
    	var bSpr = THEME.button_hide_fill;
    	
        var bs = ui(28);
    	var by = h - (bs + ui(8));
        var bx = w - (bs + ui(8));
        var bc = COLORS._main_icon;
        var m  = [mx, my];
        
		var foc = pFOCUS;
		var hov = pHOVER;
        
        var bt = __txtx("panel_animation_animation_settings", "Animation settings");
        var b  = buttonInstant(bSpr, bx, by, bs, bs, m, hov, foc, bt, THEME.gear, 2, bc, 1, .9);
        if(b == 2) dialogPanelCall(new Panel_Animation_Setting(), x + bx + bs, y + by - ui(8), { anchor: ANCHOR.right | ANCHOR.bottom }); 
        
        by -= bs + ui(4); if(by < 8) return;
        var b = buttonInstant(bSpr, bx, by, bs, bs, m, hov, foc, __txt("Animation Tools"), THEME.animation_timing, 2, bc, 1, .9);
        if(b == 2) {
        	var _dx = x + bx + ui(32);
        	var _dy = y + by - ui(8);
        	
        	menuCall("animation_tools", [
        		menuItem(__txtx("panel_animation_scale_animation", "Scaler"),  function(d) /*=>*/ { dialogPanelCall(new Panel_Animation_Scaler(),  d.x, d.y, 
        			{ anchor: ANCHOR.right | ANCHOR.bottom }); }, noone, noone, noone, { x : _dx, y : _dy }),
        			
        		menuItem(__txtx("panel_animation_clean_animation", "Cleaner"), function(d) /*=>*/ { dialogPanelCall(new Panel_Animation_Cleaner(), d.x, d.y, 
        			{ anchor: ANCHOR.right | ANCHOR.bottom }); }, noone, noone, noone, { x : _dx, y : _dy }),
        			
    		], _dx, _dy);
        
        }
        
        var max_y = by - ui(4); 
        if(by < bs) return;
        
        var scis = gpu_get_scissor();
        gpu_set_scissor(bx, 0, bs + ui(8), max_y);
        hov = hov && point_in_rectangle(mx, my, bx, 0, w, max_y);
        by  = ui(8);
        
        if(mouse_press(mb_right, hov && foc)) menuCallGen("animation_sidebar_context");
        
        var _side_b = menuItems_gen("animation_sidebar");
        for( var i = 0, n = array_length(_side_b); i < n; i++ ) {
			var _menu = _side_b[i];
			if(_menu == -1) {
				draw_set_color(CDEF.main_mdblack);
				draw_line_width(bx, by + ui(3), bx + bs, by + ui(3), 2);
				
				by += ui(8);
				continue;
			} 
			
			_menu.draw(bx, by, bs, bs, m, hov, foc);
			by += bs + ui(2);
		}
		
		gpu_set_scissor(scis);
    }
    
    function drawAnimationControl() {
        var mini = w < ui(348);
        
        var amo = array_length(control_buttons);
        var col = floor((w - ui(8)) / ui(36));
        var row = ceil(amo / col);
        if(col < 1) return;
        
        var bx = tool_width / 2 - ui(36) * amo / 2 + ui(8);
        var by = h - ui(40);
        var bs = ui(32);
        var ss = THEME.button_hide_fill;
        var m  = [mx, my];
        
        var focus = pFOCUS && !GLOBAL_IS_RENDERING;
        var hover = pHOVER && !GLOBAL_IS_RENDERING;
        
        for( var i = 0; i < row; i++ ) {
            var colAmo = min(amo - i * col, col);
            if(mini) bx = w / 2 - ui(36) * colAmo / 2;
            
            for( var j = 0; j < colAmo; j++ ) {
                var ind = i * col + j;
                if(ind >= amo) return;
                var but = control_buttons[ind];
                var txt = but[0]();
                var ind = but[1]();
                var cc  = GLOBAL_IS_RENDERING? COLORS._main_icon_dark : but[2]();
                var fnc = but[3];
            	
                if(buttonInstant(ss, bx, by, bs, bs, m, hover, focus, txt, THEME.sequence_control, ind, cc) == 2)
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
            var px = ui(8) + pw * (GLOBAL_CURRENT_FRAME / GLOBAL_TOTAL_FRAMES);
            draw_set_color(COLORS._main_accent);
            draw_line(px, y0, px, y1);
            
            if(point_in_rectangle(mx, my, ui(8), y0, w - ui(16), y1) && timeline_stretch == 0) {
                if(mouse_click(mb_left, pFOCUS)) {
                    var rfrm = (mx - ui(8)) / (w - ui(16)) * GLOBAL_TOTAL_FRAMES;
                    if(!key_mod_press(CTRL)) rfrm = clamp(rfrm, 0, GLOBAL_TOTAL_FRAMES - 1);                 // clamp to animating region
                    PROJECT.animator.setFrame(rfrm);
                }
            }
            
            var txt = string(GLOBAL_CURRENT_FRAME + 1) + "/" + string(GLOBAL_TOTAL_FRAMES);
            
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
        }
    }
    
    function drawContent(panel) {
        draw_clear_alpha(COLORS.panel_bg_clear, 1);
        if(!PROJECT.active) return;
        
        resetTimelineMask();
        drawDopesheet_ResetTimelineMask();
        
        getTimelineContent();
        
        if(w >= ui(348)) {
            drawTimeline();
            timelineScrub();
            
            if(dopesheet_h > ui(8)) drawDopesheet();
        	drawAnimationSettings();
        }
        
        drawAnimationControl();
        
        if(timeline_show_time > -1) {
            TOOLTIP = $"{__txt("Frame")} {timeline_show_time + 1}/{GLOBAL_TOTAL_FRAMES}";
            timeline_show_time = -1;
        }
    }
    
    ////- Actions
    
	function resetView() {
		var _sca = timeline_w / (GLOBAL_TOTAL_FRAMES + 2);
		var _shf = _sca;
		
		timeline_scale    = _sca;
		timeline_shift    = _shf;
		timeline_shift_to = _shf;
	}
	
    function focusTimeline() {
    	var bar_w       = timeline_w;
    	var bar_line_x  = (GLOBAL_CURRENT_FRAME + 1) * timeline_scale;
    	var bar_line_sx = bar_line_x + timeline_shift;
    	
    	if(bar_line_sx < 0 || bar_line_sx > bar_w) {
    		timeline_shift_to = bar_w / 2 - bar_line_x;
    		timeline_shift    = timeline_shift_to;
    	}
    }
    
    function newFolder() { PROJECT.timelines.addItem(new timelineItemGroup()); }
    
    function toggleNodeNameType(_d = 1) { node_name_type = (node_name_type + _d + 3) % 3; }
    function toggleNodeLabel()          { show_nodes = !show_nodes; }
    function toggleKeyframeOverride()   { global.FLAG.keyframe_override = !global.FLAG.keyframe_override; }
    function toggleOnionSkin()          { PROJECT.onion_skin.enabled = !PROJECT.onion_skin.enabled; }
    
}
