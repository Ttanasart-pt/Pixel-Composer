#region global
	#region ___function calls
	    
	    function panel_preview_clear_tool()                 { CALL("preview_clear_tool");                PANEL_PREVIEW.clearTool();               }
	    
	    function panel_preview_focus_content()              { CALL("preview_focus_content");             PANEL_PREVIEW.fullView();                }
	    function panel_preview_save_current_frame()         { CALL("preview_save_current_frame");        PANEL_PREVIEW.saveCurrentFrame();        }
	    function panel_preview_saveCurrentFrameToFocus()    { CALL("preview_save_to_focused_file");      PANEL_PREVIEW.saveCurrentFrameToFocus(); }
	    function panel_preview_saveCurrentFrameProject()    { CALL("preview_save_to_project");           PANEL_PREVIEW.saveCurrentFrameProject(); }
	    function panel_preview_save_all_current_frame()     { CALL("preview_save_all_current_frame");    PANEL_PREVIEW.saveAllCurrentFrames();    }
	    function panel_preview_preview_window()             { CALL("preview_preview_window");            PANEL_PREVIEW.create_preview_window(PANEL_PREVIEW.getNodePreview());     }
	    function panel_preview_cycle_channel()              { CALL("preview_cycle_channel");             PANEL_PREVIEW.cyclePreviewChannel();     }
	    
	    function panel_preview_pan()                  { CALL("preview_pan");                       PANEL_PREVIEW.canvas_dragging_key = true; }
	    function panel_preview_zoom()                 { CALL("preview_zoom");                      PANEL_PREVIEW.canvas_zooming_key  = true; }
	    
	    function panel_preview_3d_view_front()        { CALL("preview_3d_front_view");             PANEL_PREVIEW.d3_view_action_front();  }
	    function panel_preview_3d_view_back()         { CALL("preview_3d_back_view");              PANEL_PREVIEW.d3_view_action_back();   }
	    function panel_preview_3d_view_right()        { CALL("preview_3d_right_view");             PANEL_PREVIEW.d3_view_action_right();  }
	    function panel_preview_3d_view_left()         { CALL("preview_3d_left_view");              PANEL_PREVIEW.d3_view_action_left();   }
	    function panel_preview_3d_view_top()          { CALL("preview_3d_top_view");               PANEL_PREVIEW.d3_view_action_top();    }
	    function panel_preview_3d_view_bottom()       { CALL("preview_3d_bottom_view");            PANEL_PREVIEW.d3_view_action_bottom(); }
	    function panel_preview_3d_view_projection()   { CALL("preview_3d_projection_toggle");      PANEL_PREVIEW.d3_view_projection();    }
	    
	    function panel_preview_set_zoom(zoom)         { CALL("preview_preview_set_zoom");          PANEL_PREVIEW.fullViewNoTool(zoom);    }
	    
	    function panel_preview_set_tile_off()         { CALL("preview_set_tile_off");              PANEL_PREVIEW.tileMode = 0; }
	    function panel_preview_set_tile_horizontal()  { CALL("preview_set_tile_horizontal");       PANEL_PREVIEW.tileMode = 1; }
	    function panel_preview_set_tile_vertical()    { CALL("preview_set_tile_vertical");         PANEL_PREVIEW.tileMode = 2; }
	    function panel_preview_set_tile_both()        { CALL("preview_set_tile_both");             PANEL_PREVIEW.tileMode = 3; }
	    function panel_preview_set_tile_toggle(d=1)   { CALL("preview_set_tile_toggle");           mod_del_mf0 PANEL_PREVIEW.tileMode mod_del_mf1 PANEL_PREVIEW.tileMode mod_del_mf2  4 mod_del_mf3  4 mod_del_mf4; }
	    
	    function panel_preview_set_split_off()        { CALL("preview_set_split_off");             PANEL_PREVIEW.splitView = 0;        }
	    function panel_preview_set_split_horizontal() { CALL("preview_set_split_horizontal");      PANEL_PREVIEW.splitView = 1;        }
	    function panel_preview_set_split_vertical()   { CALL("preview_set_split_vertical");        PANEL_PREVIEW.splitView = 2;        } 
	    function panel_preview_toggle_split_view(d=1) { CALL("preview_toggle_split_view");         mod_del_mf0 PANEL_PREVIEW.splitView mod_del_mf1 PANEL_PREVIEW.splitView mod_del_mf2  3 mod_del_mf3  3 mod_del_mf4 }
	    
	    function panel_preview_new_preview_window()   { CALL("preview_new_preview_window");        PANEL_PREVIEW.new_preview_window();    }
	    function panel_preview_saveCurrentFrame()     { CALL("preview_saveCurrentFrame");          PANEL_PREVIEW.saveCurrentFrame();      }
	    function panel_preview_saveAllCurrentFrames() { CALL("preview_saveAllCurrentFrames");      PANEL_PREVIEW.saveAllCurrentFrames();  }
	    function panel_preview_copyCurrentFrame()     { CALL("preview_copyCurrentFrame");          PANEL_PREVIEW.copyCurrentFrame();      }
	    function panel_preview_copy_color()           { CALL("preview_copy_color");                PANEL_PREVIEW.copy_color();            }
	    function panel_preview_copy_color_hex()       { CALL("preview_copy_color_hex");            PANEL_PREVIEW.copy_color_hex();        }
	    
	    function panel_preview_toggle_grid_pixel()    { CALL("preview_toggle_grid_pixel");         PROJECT.previewGrid.pixel = !PROJECT.previewGrid.pixel;                  }
	    function panel_preview_toggle_grid_visible()  { CALL("preview_toggle_grid_visible");       PROJECT.previewGrid.show  = !PROJECT.previewGrid.show;                   }
	    function panel_preview_toggle_grid_snap()     { CALL("preview_toggle_grid_snap");          PROJECT.previewGrid.snap  = !PROJECT.previewGrid.snap;                   }
	    
	    function panel_preview_onion_enabled()        { CALL("preview_onion_enabled");             PROJECT.onion_skin.enabled = !PROJECT.onion_skin.enabled;                }
	    function panel_preview_onion_on_top()         { CALL("preview_onion_on_top");              PROJECT.onion_skin.on_top  = !PROJECT.onion_skin.on_top;                 }
	    
	    function panel_preview_set_reset_view_off()   { CALL("preview_set_reset_view_off");        PANEL_PREVIEW.set_reset_view_off();               }
	    function panel_preview_set_reset_view_on()    { CALL("preview_set_reset_view_on");         PANEL_PREVIEW.set_reset_view_on();                }
	    function panel_preview_toggle_reset_view(d=1) { CALL("preview_toggle_reset_view");         mod_del_mf0 PANEL_PREVIEW.resetViewOnDoubleClick mod_del_mf1 PANEL_PREVIEW.resetViewOnDoubleClick mod_del_mf2  2 mod_del_mf3  2 mod_del_mf4; }
	    
	    function panel_preview_set_mode_2d()          { CALL("preview_set_mode_2d"); PANEL_PREVIEW.preview_mode = PREV_MODE.D2; }
	    function panel_preview_set_mode_3d()          { CALL("preview_set_mode_3d"); PANEL_PREVIEW.preview_mode = PREV_MODE.D3; }
	    function panel_preview_toggle_mode(d=1)       { CALL("preview_toggle_mode"); PANEL_PREVIEW.preview_mode = !PANEL_PREVIEW.preview_mode;  }
	    
	    function panel_preview_toggle_lock()          { CALL("preview_toggle_lock");               PANEL_PREVIEW.toggle_lock();  }
	    function panel_preview_toggle_mini()          { CALL("preview_toggle_mini");               PANEL_PREVIEW.toggle_mini();  }
	    function panel_preview_toggle_gizmo()         { CALL("preview_toggle_gizmo");              PANEL_PREVIEW.toggle_gizmo(); }
	    
	    function panel_preview_toggle_tool_lock_l()   { CALL("preview_toggle_tool_lock_l");        PANEL_PREVIEW.tool_always_l = !PANEL_PREVIEW.tool_always_l; }
	    function panel_preview_toggle_tool_lock_r()   { CALL("preview_toggle_tool_lock_r");        PANEL_PREVIEW.tool_always_r = !PANEL_PREVIEW.tool_always_r; }
	    
		function panel_preview_view_control_toggle()  { PANEL_PREVIEW.view_control_toggle(); }
		function panel_preview_view_control_show()    { PANEL_PREVIEW.view_control_show();   }
		function panel_preview_view_control_hide()    { PANEL_PREVIEW.view_control_hide();   }
		
		function panel_preview_select_all()           { PANEL_PREVIEW.selectAll();           }
		function panel_preview_blend_selection()      { PANEL_PREVIEW.blendAtSelection();    }
		                                                         
	    function __fnInit_Preview() {
	    	var p = "Preview";
	    	var n = MOD_KEY.none;
	    	var s = MOD_KEY.shift;
	    	var c = MOD_KEY.ctrl;
	    	var a = MOD_KEY.alt;
	    	var cs = MOD_KEY.ctrl | MOD_KEY.shift;
	    	
	        registerFunction(p, "Clear Tool",               vk_escape, n, panel_preview_clear_tool         ).setMenu("preview_focus_content");
	        
	        registerFunction(p, "Focus Content",            "F", n, panel_preview_focus_content            ).setMenu("preview_focus_content",      THEME.icon_center_canvas)
	        registerFunction(p, "Save Current Frame",       "S", s, panel_preview_save_current_frame       ).setMenu("preview_save_current_frame", THEME.icon_preview_export)
	        registerFunction(p, "Save All Current Frames",  "",  n, panel_preview_saveAllCurrentFrames     ).setMenu("preview_save_all_current_frames")
	        registerFunction(p, "Save to Focused File",     "",  n, panel_preview_saveCurrentFrameToFocus  ).setMenu("preview_save_to_focused_file")
	        registerFunction(p, "Save to Project",          "",  n, panel_preview_saveCurrentFrameProject  ).setMenu("preview_save_to_project")
	        registerFunction(p, "Save all Current Frames",  "",  n, panel_preview_save_all_current_frame   ).setMenu("preview_save_all_current_frame")
	        registerFunction(p, "Preview Window",           "P", c, panel_preview_preview_window           ).setMenu("preview_preview_window")
	        registerFunction(p, "Cycle Channel",            vk_tab, n, panel_preview_cycle_channel         ).setMenu("preview_cycle_channel")
	    
	        registerFunction(p, "Pan",                      "", c,     panel_preview_pan                   ).setMenu("preview_pan")
	        registerFunction(p, "Zoom",                     "", a | c, panel_preview_zoom                  ).setMenu("preview_zoom")
	        
	        registerFunction(p, "3D Front View",            vk_numpad1, n, panel_preview_3d_view_front     ).setMenu("preview_3d_front_view")
	        registerFunction(p, "3D Back View",             vk_numpad1, a, panel_preview_3d_view_back      ).setMenu("preview_3d_back_view")
	        registerFunction(p, "3D Right View",            vk_numpad3, n, panel_preview_3d_view_right     ).setMenu("preview_3d_right_view")
	        registerFunction(p, "3D Left View",             vk_numpad3, a, panel_preview_3d_view_left      ).setMenu("preview_3d_left_view")
	        registerFunction(p, "3D Top View",              vk_numpad7, n, panel_preview_3d_view_top       ).setMenu("preview_3d_top_view")
	        registerFunction(p, "3D Bottom View",           vk_numpad7, a, panel_preview_3d_view_bottom    ).setMenu("preview_3d_bottom_view")
	        registerFunction(p, "3D Projection Toggle",     vk_numpad5, n, panel_preview_3d_view_projection).setMenu("preview_3d_toggle_projection")
	        
	        registerFunction(p, "Scale x1",                 "1", n, function() /*=>*/ { panel_preview_set_zoom(1) }    ).setMenu("preview_scale_x1")
	        registerFunction(p, "Scale x2",                 "2", n, function() /*=>*/ { panel_preview_set_zoom(2) }    ).setMenu("preview_scale_x2")
	        registerFunction(p, "Scale x4",                 "3", n, function() /*=>*/ { panel_preview_set_zoom(4) }    ).setMenu("preview_scale_x4")
	        registerFunction(p, "Scale x8",                 "4", n, function() /*=>*/ { panel_preview_set_zoom(8) }    ).setMenu("preview_scale_x8")
	        
	        registerFunction(p, "Tile Off",                 "", n, panel_preview_set_tile_off              ).setMenu("preview_set_tile_off")
	        registerFunction(p, "Tile Horizontal",          "", n, panel_preview_set_tile_horizontal       ).setMenu("preview_set_tile_horizontal")
	        registerFunction(p, "Tile Vertical",            "", n, panel_preview_set_tile_vertical         ).setMenu("preview_set_tile_vertical")
	        registerFunction(p, "Tile Both",                "", n, panel_preview_set_tile_both             ).setMenu("preview_set_tile_both")
	        registerFunction(p, "Toggle Tile",              "", n, panel_preview_set_tile_toggle           )
	        	.setMenu("preview_toggle_tile", THEME.icon_tile_view).setSpriteInd(function() /*=>*/ {return PANEL_PREVIEW.tileMode} )
	        	.setTooltip(new tooltipSelector(__txt("Tiling"), [ __txt("Off"), __txt("Horizontal"), __txt("Vertical"), __txt("Both") ]))
	        	.setContext([ 
	                 MENU_ITEMS.preview_set_tile_off,
	                 MENU_ITEMS.preview_set_tile_horizontal,
	                 MENU_ITEMS.preview_set_tile_vertical,
	                 MENU_ITEMS.preview_set_tile_both,
	             ])
	        registerFunction(p, "Tiling Settings",          "", n, function(_dat) /*=>*/ { submenuCall(_dat, [
	                 MENU_ITEMS.preview_set_tile_off,
	                 MENU_ITEMS.preview_set_tile_horizontal,
	                 MENU_ITEMS.preview_set_tile_vertical,
	                 MENU_ITEMS.preview_set_tile_both,
	             ]) }).setMenu("preview_tiling_settings", noone, true)
	        
	        registerFunction(p, "Split View Off",           "", n, panel_preview_set_split_off             ).setMenu("preview_set_split_off")
	        registerFunction(p, "Split View Horizontal",    "", n, panel_preview_set_split_horizontal      ).setMenu("preview_set_split_horizontal")
	        registerFunction(p, "Split View Vertical",      "", n, panel_preview_set_split_vertical        ).setMenu("preview_set_split_vertical")
	        registerFunction(p, "Toggle Split View",        "", n, panel_preview_toggle_split_view         )
	        	.setMenu("preview_toggle_split_view", THEME.icon_split_view).setSpriteInd(function() /*=>*/ {return PANEL_PREVIEW.splitView} )
	        	.setTooltip(new tooltipSelector(__txt("Split view"), [ __txt("Off"), __txt("Horizontal"), __txt("Vertical"), ]))
	        	.setContext([ 
	                 MENU_ITEMS.preview_set_split_off,
		             MENU_ITEMS.preview_set_split_horizontal,
		             MENU_ITEMS.preview_set_split_vertical,
	             ])
	        registerFunction(p, "Split View Settings",      "", n, function(_dat) /*=>*/ { submenuCall(_dat, [
		             MENU_ITEMS.preview_set_split_off,
		             MENU_ITEMS.preview_set_split_horizontal,
		             MENU_ITEMS.preview_set_split_vertical,
		         ]) }).setMenu("preview_split_view_settings", noone, true)
	                                                                                                        
	        registerFunction(p, "Set Reset View Off",       "", n, panel_preview_set_reset_view_off        ).setMenu("preview_set_reset_view_off")
	        registerFunction(p, "Set Reset View On",        "", n, panel_preview_set_reset_view_on         ).setMenu("preview_set_reset_view_on")
	        registerFunction(p, "Toggle Reset View",        "", n, panel_preview_toggle_reset_view         )
	        	.setMenu("preview_toggle_reset_view", THEME.icon_reset_when_preview).setSpriteInd(function() /*=>*/ {return !PANEL_PREVIEW.resetViewOnDoubleClick} )
	        	.setTooltip(new tooltipSelector(__txtx("panel_preview_on_preview", "On preview"), [ __txt("Center view"), __txt("Keep view") ]))
	                                                               
	        registerFunction(p, "Set Mode 2D",  "", n, panel_preview_set_mode_2d ).setMenu("preview_set_mode_2d")
	        registerFunction(p, "Set Mode 3D",  "", n, panel_preview_set_mode_3d ).setMenu("preview_set_mode_3d")
	        registerFunction(p, "Toggle Mode",  "", n, panel_preview_toggle_mode )
	        	.setMenu("preview_toggle_mode", THEME.icon_preview_mode).setSpriteInd(function() /*=>*/ {return PANEL_PREVIEW.preview_lock? 2 : bool(PANEL_PREVIEW.d3_active)} )
	        	.setTooltip(new tooltipSelector(__txt("Mode"), [ __txt("2D"), __txt("3D"), __txt("3D Locked") ]))
	        
	        registerFunction(p, "Set Preview Object", "", n, function(_dat) /*=>*/ { 
	        	var _indx = PANEL_PREVIEW.d3_preview_objects;
	        	var _menu = [];
	        	for( var i = 0, n = array_length(_indx); i < n; i++ ) 
	        		_menu[i] = new MenuItem(_indx[i][0], function(i) /*=>*/ { PANEL_PREVIEW.d3_preview_object_index = i; }, _indx[i][1]).setParam(i);
	        	submenuCall(_dat, _menu);
	        }).setMenu("preview_set_3d_object", function() /*=>*/ {return PANEL_PREVIEW.d3_preview_objects[PANEL_PREVIEW.d3_preview_object_index][1]}, true)
	                                   
	        registerFunction(p, "New Preview Window",       "",  n, panel_preview_new_preview_window        ).setMenu("preview_new_preview_window")
	        registerFunction(p, "Copy Current Frame",       "C", c, panel_preview_copyCurrentFrame          ).setMenu("preview_copy_current_frame", THEME.copy)
	        registerFunction(p, "Copy Color",               "",  n, panel_preview_copy_color                ).setMenu("preview_copy_color")
	        registerFunction(p, "Copy Color Hex",           "",  n, panel_preview_copy_color_hex            ).setMenu("preview_copy_color_hex")
	        
	        registerFunction(p, "Toggle Grid",              "G", c,  panel_preview_toggle_grid_visible     ).setMenu("preview_toggle_grid_visible")
	        registerFunction(p, "Toggle Pixel Grid",        "G", cs, panel_preview_toggle_grid_pixel       ).setMenu("preview_toggle_grid_pixel")
	        registerFunction(p, "Toggle Snap to Grid",      "",  n,  panel_preview_toggle_grid_snap        ).setMenu("preview_toggle_grid_snap")
	        
	        registerFunction(p, "Toggle Onion Skin",        "", n, panel_preview_onion_enabled             ).setMenu("preview_onion_enabled")
	        registerFunction(p, "Toggle Onion Skin view",   "", n, panel_preview_onion_on_top              ).setMenu("preview_onion_on_top")
	        registerFunction(p, "Toggle Lock",              "", n, panel_preview_toggle_lock               ).setMenu("preview_toggle_lock",   THEME.lock         ).setSpriteInd(function() /*=>*/ {return !PANEL_PREVIEW.locked}       )
	        registerFunction(p, "Toggle Minimap",           "", n, panel_preview_toggle_mini               ).setMenu("preview_toggle_mini",   THEME.icon_minimap ).setSpriteInd(function() /*=>*/  {return PANEL_PREVIEW.minimap_show} )
	        registerFunction(p, "Toggle Gizmo",             "", n, panel_preview_toggle_gizmo              ).setMenu("preview_toggle_gizmo",  THEME.icon_gizmo   ).setSpriteInd(function() /*=>*/  {return PANEL_PREVIEW.gizmo_show}   )
	        registerFunction(p, "Lock Left Toolbar",        "", n, panel_preview_toggle_tool_lock_l        ).setMenu("preview_toggle_tool_l", THEME.lock         ).setSpriteInd(function() /*=>*/ {return !PANEL_PREVIEW.tool_always_l} )
	        registerFunction(p, "Lock Right Toolbar",       "", n, panel_preview_toggle_tool_lock_r        ).setMenu("preview_toggle_tool_r", THEME.lock         ).setSpriteInd(function() /*=>*/ {return !PANEL_PREVIEW.tool_always_r} )
	        
	        registerFunction(p, "Popup",            		"", n, function() /*=>*/ { create_preview_window(PANEL_PREVIEW.getNodePreview());         }).setMenu("preview_popup",          THEME.node_goto_thin    )
	        registerFunction(p, "Grid Settings...",         "", n, function() /*=>*/ { PANEL_PREVIEW.subDialogCall(new Panel_Preview_Grid_Setting())  }).setMenu("preview_grid_settings",  THEME.icon_grid_setting ).setSpriteInd(function() /*=>*/ {return PROJECT.previewGrid.show} )
	        registerFunction(p, "Onion Skin Settings...",   "", n, function() /*=>*/ { PANEL_PREVIEW.subDialogCall(new Panel_Preview_Onion_Setting()) }).setMenu("preview_onion_settings", THEME.onion_skin        ).setSpriteInd(function() /*=>*/ {return PROJECT.onion_skin.enabled} )
	        registerFunction(p, "3D View Settings...",      "", n, function() /*=>*/ { PANEL_PREVIEW.subDialogCall(new Panel_Preview_3D_Setting(PANEL_PREVIEW))     }).setMenu("preview_3D_settings",    THEME.d3d_preview_settings )
	        registerFunction(p, "3D SDF View Settings...",  "", n, function() /*=>*/ { PANEL_PREVIEW.subDialogCall(new Panel_Preview_3D_SDF_Setting(PANEL_PREVIEW)) }).setMenu("preview_3D_SDF_settings",THEME.d3d_preview_settings )
	        registerFunction(p, "3D Snap Settings...",      "", n, function() /*=>*/ { PANEL_PREVIEW.subDialogCall(new Panel_Preview_Snap_Setting(PANEL_PREVIEW))   }).setMenu("preview_snap_settings",  THEME.d3d_snap_settings )
	        registerFunction(p, "View Settings...",         "", n, function() /*=>*/ { PANEL_PREVIEW.subDialogCall(new Panel_Preview_View_Setting(PANEL_PREVIEW))   }).setMenu("preview_view_settings",  THEME.icon_visibility   )
	        
			registerFunction(p, "Toggle View Control",      "", n, panel_preview_view_control_toggle  ).setMenu("preview_view_control_toggle", noone, false, function() /*=>*/ {return PROJECT.previewSetting.show_view_control});
			registerFunction(p, "Show View Control",        "", n, panel_preview_view_control_show    ).setMenu("preview_view_control_show");
			registerFunction(p, "Hide View Control",        "", n, panel_preview_view_control_hide    ).setMenu("preview_view_control_hide");
			
			registerFunction(p, "Select All",               "A", c, panel_preview_select_all          ).setMenu("preview_select_all");
			registerFunction(p, "Blend at Selection",       "",  n, panel_preview_blend_selection     ).setMenu("preview_blend_selection");
			
			registerFunction(p, "Edit Preview Toolbar...",        "", n, function() /*=>*/ {return menuItemEdit("preview_toolbar"        )}).setMenu("preview_edit_toolbar");
			registerFunction(p, "Edit Preview 3D Toolbar...",     "", n, function() /*=>*/ {return menuItemEdit("preview_toolbar_3d"     )}).setMenu("preview_edit_toolbar_3d");
			registerFunction(p, "Edit Preview 3D SDF Toolbar...", "", n, function() /*=>*/ {return menuItemEdit("preview_toolbar_3d_sdf" )}).setMenu("preview_edit_toolbar_3d_sdf");
			registerFunction(p, "Edit Preview Actions...",        "", n, function() /*=>*/ {return menuItemEdit("preview_actions"        )}).setMenu("preview_edit_preview_actions");
			
			registerFunction(p, "Reset Preview Toolbar",          "", n, function() /*=>*/ {return menuItemReset("preview_toolbar"        )}).setMenu("preview_reset_toolbar");
			registerFunction(p, "Reset Preview 3D Toolbar",       "", n, function() /*=>*/ {return menuItemReset("preview_toolbar_3d"     )}).setMenu("preview_reset_toolbar_3d");
			registerFunction(p, "Reset Preview 3D SDF Toolbar",   "", n, function() /*=>*/ {return menuItemReset("preview_toolbar_3d_sdf" )}).setMenu("preview_reset_toolbar_3d_sdf");
			registerFunction(p, "Reset Preview Actions",          "", n, function() /*=>*/ {return menuItemReset("preview_actions"        )}).setMenu("preview_reset_preview_actions");
			
	        __fnGroupInit_Preview();
	    }
	    
	    function __fnGroupInit_Preview() {
	        MENU_ITEMS.preview_group_preview_bg = menuItemGroup(__txtx("panel_menu_preview_background", "Preview background"), [
	            [ THEME.preview_bg_transparent, function() /*=>*/ { PANEL_PREVIEW.canvas_bg = -1;      } ],
	            [ THEME.preview_bg_white,       function() /*=>*/ { PANEL_PREVIEW.canvas_bg = c_white; } ],
	            [ THEME.preview_bg_black,       function() /*=>*/ { PANEL_PREVIEW.canvas_bg = c_black; } ],
	        ], ["Preview", "Background"]);
	        registerFunction("Preview", "Background", "",  MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.menu_group_preview_bg ]); });
	        
	    }
	#endregion

	enum PREV_MODE {
		D2,
		D3
	}
#endregion

function Panel_Preview() : PanelContent() constructor {
    title = __txt("Preview");
    icon  = THEME.panel_preview_icon;
    context_str = "Preview";
    
    last_focus = noone;
    
    #region ---- canvas control & sample ----
        initSize = function() /*=>*/ { canvas_x = w / 2; canvas_y = h / 2; }
        run_in(1, function() /*=>*/ {return initSize()});
        
        canvas_x    = 0;
        canvas_y    = 0;
        canvas_s    = 1;
        canvas_w    = ui(128);
        canvas_h    = ui(128);
        canvas_a    = 0;
        canvas_bg   = -1;
        canvas_mx   = 0;
        canvas_my   = 0;
        do_fullView = false;
        
        canvas_hover        = true;
        canvas_dragging_key = false;
        canvas_dragging     = false;
        canvas_drag_key     = 0;
        canvas_drag_mx      = 0;
        canvas_drag_my      = 0;
        canvas_drag_sx      = 0;
        canvas_drag_sy      = 0;
    
        canvas_zooming_key  = false;
        canvas_zooming      = false;
        canvas_zoom_mx      = 0;
        canvas_zoom_my      = 0;
        canvas_zoom_m       = 0;
        canvas_zoom_s       = 0;
        
        view_pan_tool       = false;
        view_zoom_tool      = false;
        
        sample_data         = noone;
        sample_color_raw    = noone;
        sample_color        = noone;
        sample_x            = noone;
        sample_y            = noone;
   #endregion
    
    #region ---- selection ----
    	selection_selecting = 0;
    	selection_mx = 0;
    	selection_my = 0;
    	selection_sx = 0;
    	selection_sy = 0;
    	selecting_w  = 0;
    	selecting_h  = 0;
    	
    	selection_active = false;
    	selection_x0 = 0; 
    	selection_y0 = 0; 
    	selection_x1 = 0; 
    	selection_y1 = 0; 
    	
    	hoveringContent = false;
        hoveringGizmo   = false;
    #endregion
    
    #region ---- preview ----
    	preview_mode        = PREV_MODE.D2;
    	preview_lock        = false;
        locked              = false;
    	
        preview_node        = [ noone, noone ];
        preview_data        = [ noone, noone ];
        preview_surfaces    = [ 0, 0 ];
        
        preview_junction    = noone;
        tile_surface        = noone;
        __temp_preview      = undefined;
        
        preview_x           = 0;
        preview_x_to        = 0;
        preview_x_max       = 0;
        preview_sequence    = [ 0, 0 ];
        _preview_sequence   = preview_sequence;
        preview_rate        = 10;
        preview_selecting   = false;
        
        right_menu_x        = 0;
        right_menu_y        = 8;
        mouse_on_preview    = 0;
        _mouse_on_preview   = 0;
        
        splitView           = 0;
        splitPosition       = 0.5;
        splitSelection      = 0;
    
        splitViewDragging   = false;
        splitViewStart      = 0;
        splitViewMouse      = 0;
    
        tileMode            = 0;
        bg_color            = COLORS.panel_bg_clear;
        
        array_preview_size  = ui(48);
        
        resetViewOnDoubleClick = true;
        
	    tb_framerate  = textBox_Number(function(v) /*=>*/ { preview_rate = real(v); });
        tb_zoom_level = textBox_Number(function(z) /*=>*/ { 
        	var _s = canvas_s;
        	canvas_s = clamp(z, 0.10, 64);
            if(_s == canvas_s) return;
        	
            var dx = (canvas_s - _s) * ((w / 2 - canvas_x) / _s);
            var dy = (canvas_s - _s) * ((h / 2 - canvas_y) / _s);
            canvas_x -= dx;
            canvas_y -= dy;   
            
        }).setColor(c_white).setAlign(fa_right).setHide(3).setFont(f_p2);
        
	    mouse_pos_string    = "";
	    tooltip_action      = "";
        tooltip_action_time = 0;
        
        preview_shader_alpha = true;
        preview_shader       = 0;
        preview_shaders      = [
        	new scrollItem( "Raw"        ).setData(undefined), 
        	-1,
        	new scrollItem( "Red"        ).setData(sh_channel_R), 
        	new scrollItem( "Green"      ).setData(sh_channel_G), 
        	new scrollItem( "Blue"       ).setData(sh_channel_B), 
        	-1,
        	new scrollItem( "Hue"        ).setData(sh_channel_H), 
        	new scrollItem( "Saturation" ).setData(sh_channel_S), 
        	new scrollItem( "Value"      ).setData(sh_channel_V), 
        	-1,
        	new scrollItem( "Alpha"      ).setData(sh_channel_A), 
    	];
    	
    	sb_shader = new scrollBox(preview_shaders, function(i) /*=>*/ { preview_shader = i; }).setFont(f_p3);
    	bb_shader = new buttonGroup(array_create(8, THEME.preview_channels), function(i) /*=>*/ { preview_shader = i; }).setFont(f_p3);
    #endregion
    
    #region ---- tool ----
    	tool_always_l  = false;
    	tool_always_r  = false;
    	
        tool_x       = 0;
        tool_x_to    = 0;
        tool_x_max   = 0;
        
        tool_y       = 0;
        tool_y_to    = 0;
        tool_y_max   = 0;
        
        tool_ry      = 0;
        tool_ry_to   = 0;
        tool_ry_max  = 0;
        
        tool_current   = noone;
        toolbar_width  = ui(40);
        toolbar_height = ui(40);
        
        tool_hovering       = noone;
        tool_side_draw_l    = false;
        tool_side_draw_r    = false;
        overlay_hovering    = false;
        view_hovering       = false;
        
        tool_show_key       = false;
        tool_clearable      = false;
        tool_clearKey       = FUNCTIONS[$ string_to_var2("Preview", "Clear tool")];
        
        hk_editing          = noone;
        
        sbChannel = new scrollBox([], function(i) /*=>*/ {
            var node = __getNodePreview();
            if(node == noone)  return;
            if(!is_numeric(i)) return;
            
            var _ind = array_safe_get(sbChannelIndex, i, -1);
            if(_ind == -1) return;
            
            node.preview_channel = _ind; 
            node.setHeight();
        });
        
        sbChannelIndex  = [];
        sbChannel.font  = f_p2;
        sbChannel.align = fa_left;
    #endregion
    
    #region ---- 3d ----
        d3_active            = NODE_3D.none;
        d3_active_transition = 0;
        
        d3_surface           = noone;
        d3_surface_normal    = noone;
        d3_surface_depth     = noone;
        d3_surface_uv        = noone;
        
        d3_surface_outline   = noone;
        d3_surface_bg        = noone;
        d3_preview_channel   = 0;
        
        d3_deferData         = noone;
        d3_drawBG            = false;
        
        global.SKY_SPHERE    = new __3dUVSphere(0.5, 16, 8, true);
        
        #region camera
            d3_camera            = new __3dCamera();
        	d3_camera.projection = CAMERA_PROJECTION.perspective;
            d3_camera_preview    = d3_camera;
            d3_camera.setFocusAngle(135, 45, 4);
            
            d3_camW          = 1;
            d3_camH          = 1;
        
            d3_camLerp       = 0;
            d3_camLerp_x     = 0;
            d3_camLerp_y     = 0;
    
            d3_camTarget     = new __vec3();
        
            d3_camPanning    = false;
            d3_camPan_mx     = 0;
            d3_camPan_my     = 0;
            
            d3_zoom_speed    = 0.2;
            d3_pan_speed     = 2;
            d3_cam_projection_lock = d3_camera.projection;
        #endregion
        
        #region scene
            d3_scene               = new __3dScene(d3_camera, "Preview panel");
            d3_scene.lightAmbient  = $404040;
            d3_scene.cull_mode     = cull_counterclockwise;
            d3_scene_preview       = d3_scene;
            d3_shader              = 0;
            
            d3_scene_light_enabled = true;
            
            d3_scene_light0        = new __3dLightDirectional();
            d3_scene_light0_ha     = 45;
            d3_scene_light0_va     = 45;
            d3_scene_light0.transform.setPolar(d3_scene_light0_ha, d3_scene_light0_va, 4);
            
            d3_scene_light0.color  = $FFFFFF;
            d3_scene_light0.shadow_active    = false;
            d3_scene_light0.shadow_map_scale = 4;
            
            d3_scene_light1        = new __3dLightDirectional();
            d3_scene_light1_ha     = 45 + 180;
            d3_scene_light1_va     = 45;
            d3_scene_light1.transform.setPolar(d3_scene_light1_ha, d3_scene_light1_va, 4);
            
            d3_scene_light1.color  = $202020;
        #endregion
        
        #region object
        	d3_preview_object_index = 2;
        	d3_preview_objects = [
        		[ "Plane",    s_node_3d_mesh_plane,     undefined, function() /*=>*/ {return new __3dPlane(2)} ], 
        		[ "Cube",     s_node_3d_mesh_cube,      undefined, function() /*=>*/ {return new __3dCube()}   ], 
        		[ "Sphere",   s_node_3d_mesh_sphere_uv, undefined, function() /*=>*/ {return new __3dUVSphere(.5, 64, 32, true)} ], 
        		[ "Cylinder", s_node_3d_mesh_cylinder,  undefined, function() /*=>*/ {return new __3dCylinder(.5,  1, 32, true)} ], 
    		];
        	
        	d3_preview_material = new __d3dMaterial();
        #endregion
    #endregion
    
    #region ---- gizmo ----
    	gizmo_show       = true;
    #endregion
    
    #region ---- minimap ----
        minimap_show     = false;
        minimap_w        = ui(160);
        minimap_h        = ui(160);
        minimap_surface  = -1;
    
        minimap_panning  = false;
        minimap_dragging = false;
        minimap_drag_sx  = 0;
        minimap_drag_sy  = 0;
        minimap_drag_mx  = 0;
        minimap_drag_my  = 0;
    #endregion
    
    #region ++++ Toolbars & Actions ++++
    	MENUITEM_CONDITIONS[$ "preview_3d_is_unlock"] = function() /*=>*/ {return !preview_lock};
    	
    	function subDialogCall(_dia) {
	    	dialogPanelCall(_dia, x + w - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.right });
	    }
	     
        static new_preview_window  = function() /*=>*/ { create_preview_window(getNodePreview()); } 
        static copy_color          = function() /*=>*/ { clipboard_set_text(sample_color); }
        static copy_color_hex      = function() /*=>*/ { clipboard_set_text(color_get_hex(sample_color)); }
        
        static set_reset_view_off  = function() /*=>*/ { resetViewOnDoubleClick = 0; } 
        static set_reset_view_on   = function() /*=>*/ { resetViewOnDoubleClick = 1; } 
        
        static toggle_lock         = function() /*=>*/ { locked = !locked }
        static toggle_mini         = function() /*=>*/ { minimap_show = !minimap_show; }
        static toggle_gizmo        = function() /*=>*/ { gizmo_show   = !gizmo_show; }
        
        static d3_view_action_front  = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x =   0; d3_camLerp_y =   0; d3_camera.projection = 1; }
        static d3_view_action_back   = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x = 180; d3_camLerp_y =   0; d3_camera.projection = 1; }
        static d3_view_action_right  = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x =  90; d3_camLerp_y =   0; d3_camera.projection = 1; }
        static d3_view_action_left   = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x = -90; d3_camLerp_y =   0; d3_camera.projection = 1; }
        static d3_view_action_bottom = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x =   0; d3_camLerp_y = -89; d3_camera.projection = 1; }
        static d3_view_action_top    = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x =   0; d3_camLerp_y =  89; d3_camera.projection = 1; }
        static d3_view_projection    = function() /*=>*/ { 
        	d3_camera.projection = !d3_camera.projection;
        	d3_cam_projection_lock = d3_camera.projection;
        }
        
		function view_control_toggle() { PROJECT.previewSetting.show_view_control = !PROJECT.previewSetting.show_view_control; }
		function view_control_show()   { PROJECT.previewSetting.show_view_control =  true; }
		function view_control_hide()   { PROJECT.previewSetting.show_view_control = false; }
		
        hk_editing     = noone;
        hk_selecting   = noone;
        
        topbar_height  = ui(32);
        toolbar_height = ui(32);
        
    	global.menuItems_preview_toolbar_context = [ "preview_edit_toolbar", "preview_edit_preview_actions" ];
        global.menuItems_preview_toolbar = [
        	"preview_toggle_mode",
        	-1, 
        	"preview_toggle_reset_view",
        	"preview_toggle_split_view",
        	"preview_toggle_tile",
        	"preview_grid_settings",
        	"preview_onion_settings",
    	];
    	
    	global.menuItems_preview_toolbar_3d_context = [ "preview_edit_toolbar_3d", "preview_edit_preview_actions" ];
    	global.menuItems_preview_toolbar_3d = [
    		"preview_toggle_mode",
    		{ cond : "preview_3d_is_unlock", items : [ "preview_set_3d_object" ] },
        	-1, 
    		"preview_3D_settings",
    		"preview_snap_settings",
		];
        
        global.menuItems_preview_toolbar_3d_sdf_context = [ "preview_edit_toolbar_3d_sdf", "preview_edit_preview_actions" ];
    	global.menuItems_preview_toolbar_3d_sdf = [
    		"preview_toggle_mode",
        	-1, 
    		"preview_3D_SDF_settings",
    		"preview_snap_settings",
		];
        
        global.menuItems_preview_actions_context = [ "preview_edit_preview_actions" ];
        global.menuItems_preview_actions = [
        	"preview_save_current_frame",
        	"preview_toggle_lock",
        	"preview_focus_content",
        	"preview_toggle_gizmo",
        	"preview_toggle_mini",
        	"preview_view_settings",
        	"preview_popup", 
    	];
        
        global.menuItems_preview_context_menu = [
        	"graph_add_node", 
            "preview_new_preview_window", 
            -1,
            "preview_focus_content",
            -1,
            "preview_select_all",
            "preview_blend_selection",
            -1,
            "preview_save_current_frame", 
            "preview_save_all_current_frames", 
            "preview_save_to_project", 
            -1,
            "preview_copy_current_frame", 
            "preview_copy_color", 
            "preview_copy_color_hex", 
            -1,
            "preview_group_preview_bg",
    	];
        
    #endregion
    
    ////- DATA
    
    function setNodePreview(_node, _lock = locked, _view = true) {
        if(locked) return self;
        
        if(_view && resetViewOnDoubleClick)
            do_fullView = true;
        
        resetTool();
        preview_node[splitView? splitSelection : 0] = _node;
        locked = _lock;
        
        return self;
    }
    
    function removeNodePreview(_node) {
        if(locked) return;
        
        if(preview_node[0] == _node) preview_node[0] = noone;
        if(preview_node[1] == _node) preview_node[1] = noone;
    }
    
    function resetNodePreview() {
        preview_node = [ noone, noone ]; 
        locked = false;
    }
    
    function __getNodePreview() { return preview_node[splitView? splitSelection : 0]; }
    function   getNodePreview() { 
        var _node = __getNodePreview();
        if(_node == noone) return noone;
        
        if(!_node.project.active) {
            resetNodePreview();
            return noone;
        }
        
        if(is_instanceof(_node, Node)) 
            _node = _node.getPreviewingNode();
            
        return _node;
    }
    
    function getNodePreviewData()     { return preview_data[     splitView? splitSelection : 0 ]; }
    function getNodePreviewSurface()  { return preview_surfaces[ splitView? splitSelection : 0 ]; }
    function getNodePreviewSequence() { return preview_sequence[ splitView? splitSelection : 0 ]; }
    
    function getPreviewData() {
    	preview_junction = noone;
    	
        var _prevNode = preview_node[0];
        if(is(_prevNode, Node) && _prevNode.active)
	        preview_junction = array_safe_get(_prevNode.outputs, _prevNode.preview_channel, noone);
        
        preview_data     = [ noone, noone ];
        preview_surfaces = [ noone, noone ];
        preview_sequence = [ noone, noone ];
            
        for( var i = 0; i < 2; i++ ) {
            var node = preview_node[i];
            if(node == noone) continue;
            if(!node.active) { resetNodePreview(); continue; }
            
            var value = node.getPreviewValues();
            
            if(is_array(value)) {
                preview_sequence[i] = value;
                canvas_a = array_length(value);
                
            } else {
                preview_data[i] = value;
                canvas_a = 0;
            }
            
            if(preview_sequence[i] != noone) {
                if(array_length(preview_sequence[i]) == 0) return;
                preview_data[i] = preview_sequence[i][safe_mod(node.preview_index, array_length(preview_sequence[i]))];
            }
            
            preview_surfaces[i] = has(preview_data[i], "getSurface")? preview_data[i].getSurface() : preview_data[i];
        }
        
        var prevS = getNodePreviewSurface();
        if(is_surface(prevS)) {
            canvas_w = surface_get_width_safe(prevS);
            canvas_h = surface_get_height_safe(prevS);    
        }
    }
    
    function onFocusBegin() { PANEL_PREVIEW = self; }
    
    function cyclePreviewChannel(_forward = true) {
    	var node = __getNodePreview();
        if(node == noone) return;
        
        var _chanCurr = node.preview_channel;
        var _chanList = sbChannelIndex;
        var _chanInfd = array_find(_chanList, _chanCurr);
        if(array_empty(_chanList)) return;
        
        if(_chanInfd < 0 ) {
        	node.preview_channel = _chanList[0];
        	return;
        }
        
        _chanInfd = (_chanInfd + (_forward? 1 : -1) + array_length(_chanList)) % array_length(_chanList);
        node.preview_channel = _chanList[_chanInfd];
    }
    
    ////- VIEW
    
    function dragCanvas() {
        if(canvas_dragging) {
            if(!MOUSE_WRAPPING) {
                var dx = mx - canvas_drag_mx;
                var dy = my - canvas_drag_my;
                
                canvas_x += dx;
                canvas_y += dy;
            }
            
            canvas_drag_mx = mx;
            canvas_drag_my = my;
            setMouseWrap();
            
            if(mouse_release(canvas_drag_key)) {
                canvas_dragging = false;
                view_pan_tool   = false;
            }
        }
        
        if(canvas_zooming) {
            if(!MOUSE_WRAPPING) {
                // var mdx = mx - canvas_zoom_mx;
                var mdy = my - canvas_zoom_m;
                
                var dd = -(mdy) / 200;
                
                var _s = canvas_s;
                canvas_s = clamp(canvas_s * (1 + dd), 0.10, 64);
                
                if(_s != canvas_s) {
                    var dx = (canvas_s - _s) * ((canvas_zoom_mx - canvas_x) / _s);
                    var dy = (canvas_s - _s) * ((canvas_zoom_my - canvas_y) / _s);
                    canvas_x -= dx;
                    canvas_y -= dy;
                }
            }
                
            canvas_zoom_m = my;
            setMouseWrap();
            
            if(mouse_release(canvas_drag_key)) {
                canvas_zooming = false;
                view_zoom_tool = false;
            }
        }
        
        if(pHOVER && canvas_hover) {
            var _doDragging = false;
            var _doZooming  = false;
            
            if(mouse_press(PREFERENCES.pan_mouse_key, pFOCUS)) {
                _doDragging = true;
                canvas_drag_key = PREFERENCES.pan_mouse_key;
                
            } else if(mouse_press(mb_left, pFOCUS) && canvas_dragging_key) {
                _doDragging = true;
                canvas_drag_key = mb_left;
                
            } else if(mouse_press(mb_left, pFOCUS) && canvas_zooming_key) {
                _doZooming = true;
                canvas_drag_key = mb_left;
            }
            
            if(_doDragging) {
                canvas_dragging = true;    
                canvas_drag_mx  = mx;
                canvas_drag_my  = my;
                canvas_drag_sx  = canvas_x;
                canvas_drag_sy  = canvas_y;
            }
            
            if(_doZooming) {
                canvas_zooming  = true;    
                canvas_zoom_mx  = mx;
                canvas_zoom_my  = my;
                canvas_zoom_m   = my;
                canvas_zoom_s   = canvas_s;
            }
            
            var _canvas_s = canvas_s;
            var inc = 0.1;
            if(canvas_s > 16)        inc = 2;
            else if(canvas_s > 8)    inc = 1;
            else if(canvas_s > 3)    inc = 0.5;
            else if(canvas_s > 1)    inc = 0.25;
            
            if(!key_mod_press_any() && MOUSE_WHEEL != 0) {
            	if(frac(MOUSE_WHEEL) == 0) canvas_s = clamp(value_snap(canvas_s + MOUSE_WHEEL * inc, inc), 0.10, 1024);
            	else                       canvas_s = clamp(canvas_s + MOUSE_WHEEL * inc, 0.10, 1024);
            }
            	
            if(_canvas_s != canvas_s) {
                var dx = (canvas_s - _canvas_s) * ((mx - canvas_x) / _canvas_s);
                var dy = (canvas_s - _canvas_s) * ((my - canvas_y) / _canvas_s);
                canvas_x -= dx;
                canvas_y -= dy;
            }
        }
        
        canvas_dragging_key = false;
        canvas_zooming_key  = false;
        canvas_hover = point_in_rectangle(mx, my, 0, toolbar_height, w, h - toolbar_height);
    }
    
    function dragCanvas3D() {
        if(d3_camLerp) {
            d3_camera.focus_angle_x = lerp_float(d3_camera.focus_angle_x, d3_camLerp_x, 3, 1);
            d3_camera.focus_angle_y = lerp_float(d3_camera.focus_angle_y, d3_camLerp_y, 3, 1);
            
            if(d3_camera.focus_angle_x == d3_camLerp_x && d3_camera.focus_angle_y == d3_camLerp_y)
                d3_camLerp = false;
        }
        
        if(d3_camPanning) {
            if(!MOUSE_WRAPPING) {
                var dx = mx - d3_camPan_mx;
                var dy = my - d3_camPan_my;
                
                var px = d3_camera.focus_angle_x;
                var py = d3_camera.focus_angle_y;
                var ax = px + dx * 0.2 * d3_pan_speed;
                var ay = py + dy * 0.1 * d3_pan_speed;
                
                d3_camera.focus_angle_x = ax;
                d3_camera.focus_angle_y = ay;
                d3_camera.projection = d3_cam_projection_lock;
            }
            
            d3_camPan_mx = mx;
            d3_camPan_my = my;
            setMouseWrap();
            
            if(mouse_release(canvas_drag_key)) {
                d3_camPanning = false;
                view_pan_tool = false;
            }
        }
        
        if(canvas_zooming) {
            if(!MOUSE_WRAPPING) {
                var dy = -(my - canvas_zoom_m) / 200;
                d3_camera.focus_dist = clamp(d3_camera.focus_dist + dy, 1, 1000);
            }
                
            canvas_zoom_m = my;
            setMouseWrap();
            
            if(mouse_release(canvas_drag_key)) {
                canvas_zooming = false;
                view_zoom_tool = false;
            }
        }
        
        if(pHOVER && canvas_hover) {
            var _doDragging = false;
            var _doZooming  = false;
            
            if(mouse_press(PREFERENCES.pan_mouse_key, pFOCUS)) {
                _doDragging = true;
                canvas_drag_key = PREFERENCES.pan_mouse_key;
                
            } else if(mouse_press(mb_left, pFOCUS) && canvas_dragging_key) {
                _doDragging = true;
                canvas_drag_key = mb_left;
                
            } else if(mouse_press(mb_left, pFOCUS) && canvas_zooming_key) {
                _doZooming = true;
                canvas_drag_key = mb_left;
                
            }
            
            if(_doDragging) {
                d3_camPanning = true;
                d3_camPan_mx  = mx;
                d3_camPan_my  = my;
            }
            
            if(_doZooming) {
                canvas_zooming  = true;    
                canvas_zoom_m   = my;
            }
            
            if(!key_mod_press_any() && MOUSE_WHEEL != 0)
            	d3_camera.focus_dist = clamp(d3_camera.focus_dist * (1 - d3_zoom_speed * MOUSE_WHEEL), 1, 1000);
        }
        
        canvas_dragging_key = false;
        canvas_zooming_key  = false;
        canvas_hover = point_in_rectangle(mx, my, 0, toolbar_height, w, h - toolbar_height);
    }
    
    function fullView(scale = 0, gizmo = false) {
        var bbox = noone;
        
        var node = getNodePreview();
        if(node != noone) bbox = gizmo? node.getPreviewBoundingBoxExpanded() : node.getPreviewBoundingBox();
        if(bbox == noone) bbox = BBOX().fromWH(0, 0, PROJECT.attributes.surface_dimension[0], PROJECT.attributes.surface_dimension[1]);
        
        var _x = bbox.x0, _y = bbox.y0;
        var _w = bbox.w,  _h = bbox.h;
        
        if(_w == 0 || _h == 0) { 
            _x = 0; 
            _y = 0;
            _w = DEF_SURF_W;
            _h = DEF_SURF_H;
        }
        
        var tl = tool_side_draw_l * ui(40);
        var tr = tool_side_draw_r * ui(40);
        var ss = scale == 0? min((w - ui(32) - tl - tr) / _w, (h - ui(32) - toolbar_height * 2) / _h) : scale;
        
        canvas_s = ss;
        canvas_x = w / 2 - _w * canvas_s / 2 - _x * canvas_s + (tl - tr) / 2;
        canvas_y = h / 2 - _h * canvas_s / 2 - _y * canvas_s;
    }
    
    function fullViewNoTool(scale = 0) {
    	if(tool_current == noone || tool_current.getToolObject() == noone)
    		fullView(scale);
    }
    
    function drawNodeChannel(_node, _x, _y) {
    	var _chAmo = _node.getOutputChannelAmount();
    	_node.preview_channel = min(_node.preview_channel, _chAmo - 1);
    	if(_chAmo <= 1) return 0;
        
        sbChannelIndex = [];
        var chName     = [];
        var currName   = _node.getOutputChannelName(_node.preview_channel);
        
        draw_set_text(sbChannel.font, fa_center, fa_center);
        var ww  = 0;
        var hh  = TEXTBOX_HEIGHT - ui(2);
        var amo = _node.getOutputJunctionAmount();
        
        for( var i = 0; i < amo; i++ ) {
            var _outi = _node.getOutputJunctionIndex(i);
            var _name = _node.getOutputChannelName(_outi);
            
            array_push(sbChannelIndex, _outi);
            array_push(chName, _name);
            
            ww = max(ww, string_width(_name) + ui(40));
        }
        
        if(!array_empty(chName)) {
            sbChannel.data_list = chName;
            sbChannel.setFocusHover(pFOCUS, pHOVER);
            sbChannel.draw(_x - ww, _y - hh / 2, ww, hh, currName, [mx, my], x, y);
            right_menu_y += ui(40);
        }
        
        return ww + ui(4);
    }
    
    function selectAll() {
    	var prevN = getNodePreview();
    	if(!is(prevN, Node)) return;
    	
    	var prevS = prevN.preview_select_surface && !array_empty(prevN.outputs) && prevN.outputs[0].type == VALUE_TYPE.surface;
    	if(prevS) {
    		var surf = prevN.outputs[0].getValue();
    		
        	selection_x0 = 0;
	    	selection_y0 = 0;
	    	selection_x1 = surface_get_width_safe(surf);
	    	selection_y1 = surface_get_height_safe(surf);
	    	
    		selection_active = true;
    		
    	} 
    	
    	if(prevN.selectAll != undefined) prevN.selectAll();
    	
    }
    
    function d3dGetUVFromMouse(_mx, _my) {
    	if(d3_active != NODE_3D.polygon)             return undefined;
    	if(!is_just_surface(d3_surface_uv))          return undefined;
    	if(_mx < 0 || _mx > w || _my < 0 || _my > h) return undefined;
    	
    	var _data = surface_getpixel_ext(d3_surface_uv, _mx, _my);
    	return is_array(_data) && _data[3] > 0? [ _data[1], _data[2] ] : undefined;
    }
    
    static onFullScreen = function() { run_in(1, fullView); }
    
    ////- TOOL
    
    function clearSelection() {
    	selection_active = false;
        var prevN = getNodePreview();
        if(is(prevN, Node) && prevN.selectClear != undefined) prevN.selectClear();
    }
    
    function resetTool() {
    	if(tool_current == noone) return;
    	var _tobj = tool_current.getToolObject();
    	
		if(_tobj) {
    		if(!_tobj.escapable()) return;
			_tobj.disable();
		}
		
        tool_current = noone;
    }
    
    function clearTool(_bypass_clearable = false) { 
    	if(!tool_clearable && !_bypass_clearable) return;
    	resetTool();
    }
    
    function drawToolsLeft(_node) {
    	var _tool = tool_hovering;
        var  ts   = ui(32);
        var  ts2  = ts / 2;
        var  pd   = 2;
        
        tool_clearable = true;
        tool_hovering  = noone;
        
        if(!tool_always_l) {
        	if(!_node.showTool()) { tool_current = noone; return; } 
        	
	        var aa = d3_active? 0.8 : 1;
	        draw_sprite_stretched_ext(THEME.tool_side, 0, 0, ui(32), toolbar_width, h - toolbar_height - ui(32), c_white, aa);
        }
        
        tool_y_max = 0; 
        tool_y   = lerp_float(tool_y, tool_y_to, 5);
        var xx   = ui(1)  + toolbar_width / 2;
        var yy   = ui(34) + ts2 + tool_y;
        var thov = pHOVER && point_in_rectangle(mx, my, 0, toolbar_height, toolbar_width, h - toolbar_height);
        if(thov) {
        	canvas_hover = false;
        	mouse_on_preview = 0;
        	if(mouse_rpress(pFOCUS)) menuCall("", [ MENU_ITEMS.preview_toggle_tool_l ]);
        }
        
        if(pFOCUS && key_mod_double(ALT)) tool_show_key = !tool_show_key;
        var __tool_show_key = tool_show_key || hk_editing != noone || key_mod_press(ALT);
        
        ////- Left tools
        
        var bs = ui(16);
        var bx = toolbar_width / 2 - bs / 2;
        var by = yy - ui(12);
        if(buttonInstant_Pad(THEME.button_hide, bx, by, bs, bs, [mx, my], thov, pFOCUS, "", THEME.lock, !tool_always_l) == 2)
        	tool_always_l = !tool_always_l;
        yy         += bs + ui(8);
        tool_y_max += bs + ui(8);
        
        var _draw_sep = true;
       
        for( var i = 0, n = array_length(_node.tools); i < n; i++ ) {
            var tool = _node.tools[i];
            
            var _x0  = xx - ts2;
            var _y0  = yy - ts2;
            var _x1  = xx + ts2;
            var _y1  = yy + ts2;
                
            var _bx = _x0 + pd;
            var _by = _y0 + pd;
            var _bs = ts - pd * 2;
            
            if(tool == -1) {
                draw_set_color(COLORS._main_icon_dark);
                draw_line_round(xx + ui(8), _y0 + ui(3), xx - ui(9), _y0 + ui(3), 2);
                
                yy          += ui(8);
                tool_y_max  += ui(8);
                continue;
            }
            
            if(thov && point_in_rectangle(mx, my, _x0, _y0 + 1, _x1, _y1 - 1))
                tool_hovering = tool;
            
            if(tool.subtools > 0 && _tool == tool) { // hovering subtools
                var s_ww = ts * tool.subtools;
                var s_hh = ts;
                draw_sprite_stretched(THEME.box_r2_clr, 0, _x0 - pd, _y0 - pd, s_ww + pd * 2, s_hh + pd * 2);
                    
                var stool = tool.spr;
                        
                for( var j = 0; j < array_length(stool); j++ ) {
                    var _sxx = xx + j * ts;
                    var _syy = yy;
                            
                    var _sx0  = _sxx - ts2;
                    var _sy0  = _syy - ts2;
                    var _sx1  = _sxx + ts2;
                    var _sy1  = _syy + ts2;
                    
                    if(point_in_rectangle(mx, my, _sx0, _sy0 + 1, _sx1, _sy1 - 1)) {
                        TOOLTIP = tool.getDisplayName(j);
                        draw_sprite_stretched(THEME.button_hide_fill, 1, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2);
                            
                        if(mouse_lpress(pFOCUS)) tool.toggle(j);
                    	if(mouse_rpress(pFOCUS)) tool.rightClick();
                    } 
                            
                    if(tool_current == tool && tool.selecting == j) {
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 2, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2, COLORS.panel_preview_grid, 1);
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 3, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2, COLORS._main_accent, 1);
                    }
                    
                    draw_sprite_colored(stool[j], 0, _sxx, _syy);
                }
                    
                if(point_in_rectangle(mx, my, _x0, _y0 + 1, _x0 + s_ww, _y1 - 1))
                    tool_hovering = tool;
            
            } else { // single tools
                if(tool_hovering == tool) {
                    draw_sprite_stretched(THEME.button_hide_fill, 1, _bx, _by, _bs, _bs);
                    TOOLTIP = tool.getDisplayName();
                    
                    if(mouse_lpress(pFOCUS)) tool.toggle();
                    if(mouse_rpress(pFOCUS)) tool.rightClick();
                }
                
                if(tool_current == tool) {
                    draw_sprite_stretched_ext(THEME.button_hide_fill, 2, _bx, _by, _bs, _bs, COLORS.panel_preview_grid, 1);
                    draw_sprite_stretched_ext(THEME.button_hide_fill, 3, _bx, _by, _bs, _bs, COLORS._main_accent, 1);
                }
                
                var _spr = tool.subtools > 0? tool.spr[tool.selecting] : tool.spr;
                draw_sprite_colored(_spr, 0, xx, yy);
            }
            
            var _key = tool.checkHotkey();
            if(_key != noone && pFOCUS && WIDGET_CURRENT == undefined) {
            	if(tool_clearKey.hotkey.equal(_key)) tool_clearable = false;
                if(_key.isPressing()) {
                	tool.toggleKeyboard();
                	HOTKEY_BLOCK = true;
                }
                
                var _hkstr = _key.getName();
                if(_hkstr != "" && __tool_show_key) {
                	draw_set_text(f_p4, fa_right, fa_center, COLORS._main_text);
                	var _hks  = string_width(_hkstr) + ui(8);
                	var _hkx0 = _x1 - _hks;
                	var _hky0 = _y1 - ui(16);
                	
                	draw_sprite_stretched_ext(THEME.ui_panel, 0, _hkx0, _hky0, _hks, ui(16), COLORS.panel_bg_clear_inner);
                	draw_text_add(_hkx0 + _hks - ui(4), _hky0 + ui(16) / 2, _hkstr);
                }
            }
            
            if(tool == hk_editing) {
            	draw_sprite_stretched_ext(THEME.button_hide, 3, _bx, _by, _bs, _bs, COLORS._main_accent, 1);
            	
            	if(KEYBOARD_ENTER)  hk_editing = noone;
				else hotkey_editing(tool.hk_object);
					
				if(keyboard_check_pressed(vk_escape)) hk_editing = noone;
            }
            
            yy         += ts;
            tool_y_max += ts;
            
            _draw_sep = false;
        }
        
        for( var i = 0, n = array_length(_node.inputs); i < n; i++ ) {
        	var _in = _node.inputs[i];
        	if(_in.preview_hotkey == undefined) continue;
        	
        	if(_draw_sep == false) {
            	var _y0  = yy - ts2;
        		draw_set_color(COLORS._main_icon_dark);
                draw_line_round(xx + ui(8), _y0 + ui(3), xx - ui(9), _y0 + ui(3), 2);
                
                yy          += ui(8);
                tool_y_max  += ui(8);
        		_draw_sep    = true;
        	}
        	
            var _x0  = xx - ts2;
            var _y0  = yy - ts2;
            var _x1  = xx + ts2;
            var _y1  = yy + ts2;
                
            var _bx = _x0 + pd;
            var _by = _y0 + pd;
            var _bs = ts - pd * 2;
            
        	var _key = _in.preview_hotkey;
        	var _spr = _in.preview_hotkey_spr;
        	var _hov = thov && point_in_rectangle(mx, my, _x0, _y0 + 1, _x1, _y1 - 1);
        	
        	if(_hov) {
        		TOOLTIP = new tooltipKey($"Set {_in.name}", _key.toString());
        		
        		if(_in.drawOverlayToggle != noone) {
	        		draw_sprite_stretched(THEME.button_hide_fill, 1, _bx, _by, _bs, _bs);
	        		if(mouse_lpress(pFOCUS)) _in.drawOverlayToggle();
        		}
        	}
        	
            draw_sprite_colored(_spr, 0, xx, yy);
        	
            var _hkstr = _key.toString();
        	if(_hkstr != "") {
            	draw_set_text(f_p4, fa_right, fa_center, COLORS._main_text);
            	var _hks  = string_width(_hkstr) + ui(8);
            	var _hkx0 = _x1 - _hks;
            	var _hky0 = _y1 - ui(16);
            	
            	draw_sprite_stretched_ext(THEME.ui_panel, 0, _hkx0, _hky0, _hks, ui(16), COLORS.panel_bg_clear_inner);
            	draw_text_add(_hkx0 + _hks - ui(4), _hky0 + ui(16) / 2, _hkstr);
            }
        	
            yy         += ts;
            tool_y_max += ts;
        }
        
        var _h = _node.drawTools == noone? 0 : _node.drawTools(mx, my, xx, yy - ts2, ts, thov, pFOCUS);
        yy         += _h;
        tool_y_max += _h;
        
        tool_y_max = max(0, tool_y_max - h + toolbar_height * 2);            
        if(thov && !key_mod_press_any() && MOUSE_WHEEL != 0)
            tool_y_to = clamp(tool_y_to + ui(64) * MOUSE_WHEEL, -tool_y_max, 0);
    }
    
    function drawToolsRight(_node) {
        var _tool = tool_hovering;
    	var  ts   = ui(32);
        var  ts2  = ts / 2;
        var  pd   = 2;
        
        if(!tool_always_r) {
        	if(_node.rightTools == -1) return;
        	
	        var aa = d3_active? 0.8 : 1;
	        draw_sprite_stretched_ext(THEME.tool_side, 1, w + 1 - toolbar_width, ui(32), toolbar_width, h - toolbar_height - ui(32), c_white, aa);
        }
        
        right_menu_x = w - toolbar_width - ui(8);
        tool_ry_max  = 0; 
        tool_ry      = lerp_float(tool_ry, tool_ry_to, 5);
        
        var tbx  = w - toolbar_width;
        var xx   = tbx + toolbar_width / 2;
        var yy   = ui(34) + ts  / 2 + tool_ry;
        var thov = pHOVER && point_in_rectangle(mx, my, tbx, toolbar_height, w, h - toolbar_height);
        if(thov) {
        	canvas_hover = false;
        	mouse_on_preview = 0;
        	if(mouse_rpress(pFOCUS)) menuCall("", [ MENU_ITEMS.preview_toggle_tool_r ]);
        }
        
        var __tool_show_key = tool_show_key || hk_editing != noone || key_mod_press(ALT);
        
        ////- Right tools
        
        var bs = ui(16);
        var bx = w + 1 - toolbar_width / 2 - bs / 2;
        var by = yy - ui(12);
        if(buttonInstant_Pad(THEME.button_hide, bx, by, bs, bs, [mx, my], thov, pFOCUS, "", THEME.lock, !tool_always_r) == 2)
        	tool_always_r = !tool_always_r;
        yy          += bs + ui(8);
        tool_ry_max += bs + ui(8);
        
        for(var i = 0; i < array_length(_node.rightTools); i++) {
            var tool = _node.rightTools[i];
            
            var _x0  = xx - ts2;
            var _y0  = yy - ts2;
            var _x1  = xx + ts2;
            var _y1  = yy + ts2;
             
            var _bx  = _x0 + pd;
            var _by  = _y0 + pd;
            var _bs  = ts - pd * 2;
            
            if(tool == -1) {
                draw_set_color(COLORS._main_icon_dark);
                draw_line_round(xx + ui(8), _y0 + ui(3), xx - ui(9), _y0 + ui(3), 2);
                
                yy          += ui(8);
                tool_ry_max += ui(8);
                continue;
            }
            
            if(thov && point_in_rectangle(mx, my, _x0, _y0 + 1, _x1, _y1 - 1))
                tool_hovering = tool;
        
            if(tool.subtools > 0 && _tool == tool) { // hovering subtools
                
                var stool = tool.spr;
                var s_ww  = ts * tool.subtools;
                var s_hh  = ts;
                var tx    = _x0 - s_ww + ts;
                draw_sprite_stretched(THEME.box_r2_clr, 0, tx - pd, _y0 - pd, s_ww + pd * 2, s_hh + pd * 2);
                
                var _am = array_length(stool);
                
                for( var j = 0; j < _am; j++ ) {
                    var _sind = _am - 1 - j;
                    var _sxx = tx + j * ts + ts2;
                    var _syy = yy;
                        
                    var _sx0  = _sxx - ts2;
                    var _sy0  = _syy - ts2;
                    var _sx1  = _sxx + ts2;
                    var _sy1  = _syy + ts2;
                    
                    if(point_in_rectangle(mx, my, _sx0, _sy0 + 1, _sx1, _sy1 - 1)) {
                        TOOLTIP = tool.getDisplayName(_sind);
                        draw_sprite_stretched(THEME.button_hide_fill, 1, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2);
                        
                        if(mouse_lpress(pFOCUS)) tool.toggle(_sind);
                    	if(mouse_rpress(pFOCUS)) tool.rightClick();
                    }
                        
                    if(tool_current == tool && tool.selecting == _sind) {
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 2, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2, COLORS.panel_preview_grid, 1);
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 3, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2, COLORS._main_accent, 1);
                    }
                    
                    draw_sprite_colored(stool[_sind], 0, _sxx, _syy);
                    
                }
                
                if(point_in_rectangle(mx, my, tx, _y0 + 1, tx + s_ww, _y1 - 1))
                    tool_hovering = tool;
            
            } else { // single tools
                if(tool_hovering == tool) {
                    draw_sprite_stretched(THEME.button_hide_fill, 1, _bx, _by, _bs, _bs);
                    TOOLTIP = tool.getDisplayName();
                	
                    if(mouse_lpress(pFOCUS)) tool.toggle();
                    if(mouse_rpress(pFOCUS)) tool.rightClick();
                }
                
                if(tool_current == tool) {
                    draw_sprite_stretched_ext(THEME.button_hide_fill, 2, _bx, _by, _bs, _bs, COLORS.panel_preview_grid, 1);
                    draw_sprite_stretched_ext(THEME.button_hide_fill, 3, _bx, _by, _bs, _bs, COLORS._main_accent, 1);
                }
            
                var _spr = tool.subtools > 0? tool.spr[tool.selecting] : tool.spr;
                draw_sprite_colored(_spr, 0, xx, yy);
                
            }
            
            var _key = tool.checkHotkey();
            if(_key != noone && pFOCUS && WIDGET_CURRENT == undefined) {
            	if(tool_clearKey.hotkey.equal(_key)) tool_clearable = false;
                if(_key.isPressing()) {
                	tool.toggleKeyboard();
                	HOTKEY_BLOCK = true;
                }
                
                var _hkstr = _key.getName();
                if(_hkstr != "" && __tool_show_key) {
                	draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
                	var _hks  = string_width(_hkstr) + ui(8);
                	var _hkx0 = _x0;
                	var _hky0 = _y1 - ui(16);
                	
                	draw_sprite_stretched_ext(THEME.ui_panel, 0, _hkx0, _hky0, _hks, ui(16), COLORS.panel_bg_clear_inner);
                	draw_text_add(_hkx0 + ui(4), _hky0 + ui(16) / 2, _hkstr);
                }
            }
            
            if(tool == hk_editing) {
            	draw_sprite_stretched_ext(THEME.button_hide, 3, _bx, _by, _bs, _bs, COLORS._main_accent, 1);
            	
            	if(KEYBOARD_ENTER)  hk_editing = noone;
				else hotkey_editing(tool.hk_object);
					
				if(keyboard_check_pressed(vk_escape)) hk_editing = noone;
            }
            
            yy          += ts;
            tool_ry_max += ts;
        } 
        
        tool_ry_max = max(0, tool_ry_max - h + toolbar_height * 2);            
        if(thov && !key_mod_press_any() && MOUSE_WHEEL != 0)
            tool_ry_to = clamp(tool_ry_to + ui(64) * MOUSE_WHEEL, -tool_ry_max, 0);
    }
    
    function drawToolSettings(_node) {
    	var settings = array_merge(_node.getToolSettings(), tool_current.settings);
    	
    	var _toolObj = tool_current.getToolObject();
    	if(is(_toolObj, canvas_tool_with_selector))
    		array_append(settings, _toolObj.tool.settings);
    	
        tool_x = lerp_float(tool_x, tool_x_to, 5);
        
        var tolx  = tool_x + ui(8);
        var toly  = ui(5);
        var tolw  = ui(48);
        var tolh  = topbar_height - ui(10);
        var tol_max_w = ui(16);
        
        for( var i = 0, n = array_length(settings); i < n; i++ ) {
            var sett = settings[i];
            
            if(is_callable(sett)) {
            	var _data = sett();
            	if(!surface_exists(_data)) continue;
            	
            	var _sw = surface_get_width(_data);
            	var _sh = surface_get_height(_data);
            	var _ss = (topbar_height - ui(16)) / _sh;
            	
            	draw_surface_ext(_data, tolx, ui(8), _ss, _ss, 0, c_white, 1);
            	
            	tolx      += _sw * _ss + ui(8);
            	tol_max_w += _sw * _ss + ui(8);
            	continue;
            }
            
            var nme  = sett[0];
            var wdg  = sett[1];
            var key  = array_safe_get_fast(sett, 2);
            var atr  = array_safe_get_fast(sett, 3, {});
            var ttip = array_safe_get_fast(sett, 4, "");
            
            draw_set_text(f_p3, fa_left, fa_center, COLORS._main_icon_light);
            if(nme != "") {
            	if(is_string(nme)) {
            		tolx      += ui(4);
                	tol_max_w += ui(4);
                	
	                draw_text(tolx, topbar_height / 2, nme);
	                tolx      += string_width(nme) + ui(8);
	                tol_max_w += string_width(nme) + ui(8);
	                
            	} else if(sprite_exists(nme)) {
            		draw_sprite_ui(nme, 0, tolx + ui(8), topbar_height / 2, 1, 1, 0, COLORS._main_icon_light);
            		if(ttip != "" && pHOVER && point_in_rectangle(mx, my, tolx, 0, tolx + ui(20), topbar_height))
            			TOOLTIP = ttip;
            		
	                tolx      += ui(20);
	                tol_max_w += ui(20);
	                
            	}
            }
            
            wdg.register();
            wdg.setFocusHover(pFOCUS, pHOVER);
            
            var _tool_font = f_p3;
            
            switch(instanceof(wdg)) {
                case "textBox"       : tolw = max(wdg.minWidth, ui(32)) + (wdg.side_button != noone) * (tolh + ui(8));          break;
                case "vectorBox"     : tolw = max(wdg.minWidth, ui(32)) * wdg.size;                                             break;
                case "buttonGroup"   : 
                case "checkBoxGroup" : tolw = tolh * wdg.size;                                                                  break;
                case "checkBox"      : tolw = tolh;                                                                             break;
                case "scrollBox"     : tolw = max(wdg.minWidth, ui(96)); _tool_font = f_p3;                                     break;
                case "buttonClass"   : tolw = wdg.text == ""? tolh : tolw;                                                      break;
                case "buttonAnchor"  : tolw = ui(28);                                                                           break;
            }
            
            var params = new widgetParam(tolx, toly, tolw, tolh, atr[$ key], {}, [ mx, my ], x, y)
            				.setS(tolh)
            				.setFont(_tool_font);
            
            wdg.drawParam(params);
            
            tolx      += tolw + ui(8);
            tol_max_w += tolw + ui(8);
        }
        
        tol_max_w = max(0, tol_max_w - w);            
        if(point_in_rectangle(mx, my, 0, 0, w, topbar_height) && !key_mod_press_any() && MOUSE_WHEEL != 0)
            tool_x_to = clamp(tool_x_to + ui(64) * MOUSE_WHEEL, -tol_max_w, 0);
    }
    
    ////- DRAW
    
    function drawOnionSkin(node, psx, psy, ss) {
        var _surf = preview_surfaces[0];
        var _rang = PROJECT.onion_skin.range;
        
        var _alph = PROJECT.onion_skin.alpha;
        var _colr = PROJECT.onion_skin.color;
        
        var _step = PROJECT.onion_skin.step;
        var _top  = PROJECT.onion_skin.on_top;
        
        var fr = GLOBAL_CURRENT_FRAME;
        var st = min(_rang[0], _rang[1]);
        var ed = max(_rang[0], _rang[1]);
        var surf, aa, cc;
            
        st = floor(fr / _step) * _step - abs(st);
        ed = floor(fr / _step) * _step + abs(ed);
        
        if(!_top) {
            draw_surface_ext_safe(_surf, psx, psy, ss, ss);
            BLEND_ADD
        }
        
        for( var i = st; i <= ed; i += _step ) {
            surf = node.getCacheFrame(i);
            if(!is_surface(surf)) continue;
                
            aa = power(_alph, abs((i - fr) / _step));
            cc = i < fr? _colr[0] : _colr[1];
            
            draw_surface_ext_safe(surf, psx, psy, ss, ss, 0, cc, aa);
        }
        
        BLEND_NORMAL
        
        if(_top) draw_surface_ext_safe(_surf, psx, psy, ss, ss);
        
    }
    
    preview_surface_width  = 0;
    preview_surface_height = 0;
    
    function drawNodePreview() {
        var ss   = canvas_s;
        var psx  = 0, psy  = 0;
        var psw  = 0, psh  = 0;
        var psx1 = 0, psy1 = 0;
        
        preview_surface_width  = DEF_SURF_W * ss;
    	preview_surface_height = DEF_SURF_H * ss;
        
        var ssx = 0, ssy = 0;
        var ssw = 0, ssh = 0;
        
		var _ps0 = is_surface(preview_surfaces[0]);
        var _ps1 = is_surface(preview_surfaces[1]);
    	
        if(_ps0) {
            psx = canvas_x + preview_node[0].preview_x * ss;
            psy = canvas_y + preview_node[0].preview_y * ss;
            
            psw = surface_get_width_safe(preview_surfaces[0]);
            psh = surface_get_height_safe(preview_surfaces[0]);
            preview_surface_width  = psw * ss;
            preview_surface_height = psh * ss;
            
            psx1 = psx + preview_surface_width;
            psy1 = psy + preview_surface_height;    
        }
        
        if(_ps1) {
            var ssx = canvas_x + preview_node[1].preview_x * ss;
            var ssy = canvas_y + preview_node[1].preview_y * ss;
            
            var ssw = surface_get_width_safe(preview_surfaces[1]);
            var ssh = surface_get_height_safe(preview_surfaces[1]);
        }
        
        var _node = getNodePreview();
        if(_node) title = _node.renamed? _node.display_name : _node.name;
        
		#region >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Draw Surfaces <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	    	var _shader_data = array_safe_get_fast(preview_shaders, preview_shader);
	    	var _shader_prev = struct_try_get(_shader_data, "data");
    		if(_shader_prev) {
    			shader_set(_shader_prev);
    			shader_set_i("keepAlpha", preview_shader_alpha);
    		}
    	
	        if(!_ps0 && !_ps1) {
				draw_surface_ext_safe(PROJECT.getOutputSurface(), canvas_x, canvas_y, canvas_s, canvas_s); 
				draw_set_color_alpha(COLORS.panel_preview_surface_outline, .75);
				draw_rectangle(canvas_x, canvas_y, canvas_x + DEF_SURF_W * canvas_s - 1, canvas_y + DEF_SURF_H * canvas_s - 1, true);
				draw_set_alpha(1);
	        }
	        
            if(splitView == 0 && _ps0) {
                preview_node[0].previewing = 1;
                
                switch(tileMode) {
                    case 0 :
                        if(PROJECT.onion_skin.enabled) drawOnionSkin(_node, psx, psy, ss); 
                        else draw_surface_ext(preview_surfaces[0], psx, psy, ss, ss, 0, c_white, preview_node[0].preview_alpha); 
                        break;
                        
                    case 1 : 
                        tile_surface = surface_verify(tile_surface, w, surface_get_height_safe(preview_surfaces[0]) * ss);
                        surface_set_target(tile_surface);
                            DRAW_CLEAR
                            draw_surface_tiled_ext_safe(preview_surfaces[0], psx, 0, ss, ss, 0, c_white, 1); 
                        surface_reset_target();
                        draw_surface_safe(tile_surface, 0, psy);
                        break;
                        
                    case 2 : 
                        tile_surface = surface_verify(tile_surface, surface_get_width_safe(preview_surfaces[0]) * ss, h);
                        surface_set_target(tile_surface);
                            DRAW_CLEAR
                            draw_surface_tiled_ext_safe(preview_surfaces[0], 0, psy, ss, ss, 0, c_white, 1); 
                        surface_reset_target();
                        draw_surface_safe(tile_surface, psx, 0);
                        break;
                        
                    case 3 : 
                        draw_surface_tiled_ext_safe(preview_surfaces[0], psx, psy, ss, ss, 0, c_white, 1); break;
                }
            }
            
            switch(splitView) {
                case 1 :
                    var sp = splitPosition * w;
                	
                    if(_ps0) {
                        preview_node[0].previewing = 2;
                        var maxX = min(sp, psx1);
                        var sW   = min(psw, (maxX - psx) / ss);
                    
                        if(sW > 0)
                            draw_surface_part_ext_safe(preview_surfaces[0], 0, 0, sW, psh, psx, psy, ss, ss, 0, c_white, 1);
                    }
                	
                    if(_ps1) {
                        preview_node[1].previewing = 3;
                        var minX = max(ssx, sp);
                        var sX   = (minX - ssx) / ss;
                        var spx  = max(sp, ssx);
                    
                        if(sX >= 0 && sX < ssw)
                            draw_surface_part_ext_safe(preview_surfaces[1], sX, 0, ssw - sX, ssh, spx, ssy, ss, ss, 0, c_white, 1);
                    }
                    break;
                    
                case 2 :
                    var sp = splitPosition * h;
                    
                    if(_ps0) {
                        preview_node[0].previewing = 4;
                        var maxY = min(sp, psy1);
                        var sH   = min(psh, (maxY - psy) / ss);
                    
                        if(sH > 0)
                            draw_surface_part_ext_safe(preview_surfaces[0], 0, 0, psw, sH, psx, psy, ss, ss, 0, c_white, 1);
                    }
                	
                    if(_ps1) {
                        preview_node[1].previewing = 5;
                        var minY = max(ssy, sp);
                        var sY   = (minY - ssy) / ss;
                        var spy  = max(sp, ssy);
                    
                        if(sY >= 0 && sY < ssh) 
                            draw_surface_part_ext_safe(preview_surfaces[1], 0, sY, ssw, ssh - sY, ssx, spy, ss, ss, 0, c_white, 1);
                    }
                    break;
            } 
            
            if(preview_junction != noone) {
            	preview_junction.drawPreviewOverlay(canvas_x, canvas_y, canvas_s, self);
            	preview_junction.node.previewing = 1;
            }
        	
        	if(_shader_prev) shader_reset();
        #endregion
        
        if(!instance_exists(o_dialog_menubox)) { // color sample
            sample_color_raw = noone;
            sample_color     = noone;
            sample_x         = noone;
            sample_y         = noone;
        	var _sampleable  = !is(_node, Node) || _node.preview_surface_sample;
        
            if(_sampleable && mouse_on_preview && (mouse_press(mb_right) || key_mod_press(CTRL))) {
                var _sx = sample_x;
                var _sy = sample_y;
                
                sample_x = floor((mx - canvas_x) / canvas_s);
                sample_y = floor((my - canvas_y) / canvas_s);
                
                var surf = getNodePreviewSurface();
                
                if(is_surface(surf) && surface_exists(surf)) {
	                sample_color_raw = surface_getpixel_ext(surf, sample_x, sample_y);
	                sample_color     = is_array(sample_color_raw)? make_color_rgba(clamp(sample_color_raw[0] * 255, 0, 255), 
	                															   clamp(sample_color_raw[1] * 255, 0, 255), 
	                															   clamp(sample_color_raw[2] * 255, 0, 255), 
	                															   clamp(sample_color_raw[3] * 255, 0, 255)) : sample_color_raw;
					
					sample_data = {
						type:  "color",
						data:  sample_color_raw,
						color: sample_color,
					};
                }
            }
        }
        
        if(_ps0) { // outline
            if(PROJECT.previewGrid.pixel && canvas_s >= 16) {
                
                var gw = preview_surface_width  / canvas_s;
                var gh = preview_surface_height / canvas_s;
                
                var cx = canvas_x;
                var cy = canvas_y;
                
                draw_set_color(PROJECT.previewGrid.color);
                draw_set_alpha(PROJECT.previewGrid.opacity * 0.5 * clamp((canvas_s - 16) / 16, 0, 1));
                
                for( var i = 1; i < gw; i++ ) {
                    var _xx = cx + i * canvas_s;
                    draw_line(_xx, cy, _xx, cy + preview_surface_height);
                }
            
                for( var i = 1; i < gh; i++ ) {
                    var _yy = cy + i * canvas_s;
                    draw_line(cx, _yy - 1, cx + preview_surface_width, _yy - 1);
                }
                
                draw_set_alpha(1);
            }
            
            draw_set_color(COLORS.panel_preview_surface_outline);
            draw_rectangle(psx, psy, psx + preview_surface_width - 1, psy + preview_surface_height - 1, true);
            
        } else {
        	draw_set_color_alpha(COLORS.panel_preview_surface_outline, .75);
            draw_rectangle(canvas_x, canvas_y, canvas_x + DEF_SURF_W * canvas_s - 1, canvas_y + DEF_SURF_H * canvas_s - 1, true);
            draw_set_alpha(1);
        }
        
        if(!struct_try_get(_node, "bypass_grid", false)) drawNodeGrid();
    }
    
    function drawNodeGrid() {
        if(!PROJECT.previewGrid.show) return;
        
        var _gw = PROJECT.previewGrid.size[0] * canvas_s;
        var _gh = PROJECT.previewGrid.size[1] * canvas_s;
        
        var gw = preview_surface_width  / _gw;
        var gh = preview_surface_height / _gh;
    	
        var cx = canvas_x;
        var cy = canvas_y;
    
        draw_set_color(PROJECT.previewGrid.color);
        draw_set_alpha(PROJECT.previewGrid.opacity);
        
        for( var i = 1; i < gw; i++ ) {
            var _xx = cx + i * _gw;
            draw_line(_xx, cy, _xx, cy + preview_surface_height);
        }
    
        for( var i = 1; i < gh; i++ ) {
            var _yy = cy + i * _gh;
            draw_line(cx, _yy, cx + preview_surface_width, _yy);
        }
        
        draw_set_alpha(1);
    }
    
    function draw3DPolygon(_node) {
        surface_depth_disable(false);
        
        _node.previewing = 1;
        d3_scene.shader  = d3_shader == 0? _node.project.attributes.shader : d3_shader--;
        d3_scene_preview = _node[$ "scene"] ?? d3_scene;
        d3_scene_preview.camera = d3_camera;
        
        d3_surface         = surface_verify(d3_surface,         w, h);
        d3_surface_normal  = surface_verify(d3_surface_normal,  w, h);
        d3_surface_depth   = surface_verify(d3_surface_depth,   w, h);
        d3_surface_uv      = surface_verify(d3_surface_uv,      w, h, surface_rgba16float);
        d3_surface_outline = surface_verify(d3_surface_outline, w, h);
        
        #region view
            var _pos, targ, _blend = 1;
            
            targ = d3_camTarget;
            _pos = d3d_PolarToCart(targ.x, targ.y, targ.z, d3_camera.focus_angle_x, d3_camera.focus_angle_y, d3_camera.focus_dist);
            
            if(d3_active_transition == 1) {
                var _up  = new __vec3(0, 0, -1);
                
                d3_camera.position._lerp_float(_pos, 5, 0.1);
                d3_camera.focus._lerp_float(   targ, 5, 0.1);
                d3_camera.up._lerp_float(       _up, 5, 0.1);
                
                if(d3_camera.position.equal(_pos) && d3_camera.focus.equal(targ))
                    d3_active_transition = 0;
                    
            } else if(d3_active_transition == -1) {
                var _pos = new __vec3(0, 0, 8);
                var targ = new __vec3(0, 0, 0);
                var _up  = new __vec3(0, 1, 0);
                
                d3_camera.position._lerp_float(_pos, 5, 0.1);
                d3_camera.focus._lerp_float(   targ, 5, 0.1);
                d3_camera.up._lerp_float(       _up, 5, 0.1);
                
                _blend = d3_camera.position.distance(_pos) / 2;
                _blend = clamp(_blend, 0, 1);
                
                if(d3_camera.position.equal(_pos) && d3_camera.focus.equal(targ))
                    d3_active_transition = 0;
                    
            } else {
                d3_camera.position.set(_pos);
                d3_camera.focus.set(targ);
            }
            
            if(d3_camera.projection == CAMERA_PROJECTION.perspective)
            	d3_camera.setViewSize(w, h);
            	
            else if(d3_camera.projection == CAMERA_PROJECTION.orthograph) {
            	var _orth = d3_camera.focus_dist;
            	d3_camera.setViewSize(1 * _orth, h / w * _orth);
            }
            	
            d3_camera.setMatrix();
        #endregion
        
        #region background
        	d3_surface_bg = surface_verify(d3_surface_bg, w, h);
            if(d3_scene_preview != d3_scene) d3_scene_preview.renderBackground(d3_surface_bg);
        #endregion
    	
    	#region preview objects
    		var _prev_obj  = noone;
    		var _prev_objs = [];
    		
    		if(has(_node, "getPreviewObject"))
    			_prev_obj = _node.getPreviewObject();
    		else {
    			var _data = getNodePreviewData();
    			var _prev = d3_preview_objects[d3_preview_object_index];
    			if(_prev[2] == undefined) _prev[2] = _prev[3]();
    			var _obj = _prev[2];
    			
    			var _mat = d3_preview_material;
    			if(is(_data, __d3dMaterial))
    				 _mat = _data;
    			else _mat.surface = _data;
    			
    			for( var i = 0, n = _obj.object_counts; i < n; i++ ) 
    				_obj.materials[i] = _mat;
    			_prev_obj = _obj;
    		}
    		
    		if(has(_node, "getPreviewObjects"))
    			_prev_objs = _node.getPreviewObjects();
    		else
    			_prev_objs = [ _prev_obj ];
    	#endregion
    	
        #region shadow
            if(d3_scene_preview == d3_scene) {
                d3_scene_light0.shadow_map_scale = d3_camera.focus_dist * 2;
                
                if(_prev_obj != noone) {
                    d3_scene_light0.submitShadow(d3_scene_preview, _prev_obj);
                    _prev_obj.submitShadow(d3_scene_preview, _prev_obj);
                }
            }
        
            if(_prev_obj) 
            	d3_deferData  = d3_scene_preview.deferPass(_prev_obj, w, h, d3_deferData);
        #endregion
        
        #region render
        	surface_clear( d3_surface, bg_color );
        	surface_clear( d3_surface_normal    );
        	surface_clear( d3_surface_depth     );
        	surface_clear( d3_surface_uv        );
        	
            surface_set_target_ext(0, d3_surface);
            surface_set_target_ext(1, d3_surface_normal);
            surface_set_target_ext(2, d3_surface_depth);
            surface_set_target_ext(3, d3_surface_uv);
            
            d3_camera_preview.applyCamera();
            
            gpu_set_ztestenable(true);
            gpu_set_zwriteenable(false);
            gpu_set_cullmode(cull_noculling); 
            
            shader_set(sh_d3d_grid_view);
                var _dist = round(d3_camera_preview.focus.distance(d3_camera_preview.position));
                var _tx   = round(d3_camera_preview.focus.x);
                var _ty   = round(d3_camera_preview.focus.y);
            
                var _scale = _dist * 2;
                while(_scale > 32) _scale /= 2;
                
                shader_set_f("axisBlend", _blend);
                shader_set_f("scale", _scale);
                shader_set_f("shift", _tx / _dist / 2, _ty / _dist / 2);
                draw_sprite_stretched(s_fx_pixel, 0, _tx - _dist, _ty - _dist, _dist * 2, _dist * 2);
            shader_reset();
            
            gpu_set_zwriteenable(true);
            
            d3_scene_preview.reset();
            d3_scene_preview.setRendering();
            
            if(d3_scene_preview == d3_scene) {
                if(d3_scene_light_enabled) d3_scene_preview.addLightDirectional(d3_scene_light0);
            }
            
            for( var i = 0, n = array_length(_prev_objs); i < n; i++ ) {
                var _prev = _prev_objs[i];
                if(_prev == noone) continue;
                 
                _prev.submitShader(d3_scene_preview);
            }
                
            d3_scene_preview.apply(d3_deferData);
            
            for( var i = 0, n = array_length(_prev_objs); i < n; i++ ) {
                var _prev = _prev_objs[i];
                if(_prev == noone) continue;
                
                _prev.submit(d3_scene_preview);
            }
            
            d3_scene_preview.resetRendering();
            surface_reset_target();
        #endregion
        
        #region draw
            draw_clear(bg_color);
            
            switch(d3_preview_channel) {
                case 0 : 
                    if(d3_scene_preview.draw_background) 
                    	draw_surface_safe(d3_surface_bg);    
                    
                    draw_surface_safe(d3_surface);
                    
                    if(is_struct(d3_deferData) && d3_scene_preview.ssao_enabled) {
                        BLEND_MULTIPLY
                        draw_surface_safe(d3_deferData.ssao);
                        BLEND_NORMAL
                    }
                    break;
                case 1 : draw_surface_safe(d3_surface_normal); break;
                case 2 : draw_surface_safe(d3_surface_depth);  break;
            }
            
        #endregion
        
        #region outline
            var inspect_node = PANEL_INSPECTOR.getInspecting();
            
            if(inspect_node && inspect_node.is_3D == NODE_3D.polygon) {
                var _inspect_obj = inspect_node.getPreviewObjectOutline();
                
                surface_set_target(d3_surface_outline);
                draw_clear(c_black);
                    
                d3_scene_preview.camera.applyCamera();
                    
                gpu_set_ztestenable(false);
                    for( var i = 0, n = array_length(_inspect_obj); i < n; i++ ) {
                        if(_inspect_obj[i] == noone) continue;
                        _inspect_obj[i].submitSel(d3_scene_preview);
                    }
                surface_reset_target();
                    
                shader_set(sh_d3d_outline);
                    shader_set_dim("dimension", d3_surface_outline);
                    shader_set_color("outlineColor", COLORS._main_accent);
                    draw_surface_safe(d3_surface_outline);
                shader_reset();
            }
        #endregion
        
        d3_scene_preview.camera.resetCamera();
        
        surface_depth_disable(true);
    }
    
    function draw3DSdf(_node) {
        _node.previewing = 1;
        
        var _env = _node.environ; 
        var _obj = _node.object; 
        
        d3_scene_preview = d3_scene;
        d3_scene_preview.camera = d3_camera;
        
        #region view
            d3_camera.fov = max(1, _env.fov * 1.23);
            var _pos, targ, _blend = 1;
            
            targ = d3_camTarget;
            _pos = d3d_PolarToCart(targ.x, targ.y, targ.z, d3_camera.focus_angle_x, d3_camera.focus_angle_y, d3_camera.focus_dist);
            
            if(d3_active_transition == 1) {
                var _up  = new __vec3(0, 0, -1);
                
                d3_camera.position._lerp_float(_pos, 5, 0.1);
                d3_camera.focus._lerp_float(   targ, 5, 0.1);
                d3_camera.up._lerp_float(       _up, 5, 0.1);
                
                if(d3_camera.position.equal(_pos) && d3_camera.focus.equal(targ))
                    d3_active_transition = 0;
                    
            } else if(d3_active_transition == -1) {
                var _pos = new __vec3(0, 0, 8);
                var targ = new __vec3(0, 0, 0);
                var _up  = new __vec3(0, 1, 0);
                
                d3_camera.position._lerp_float(_pos, 5, 0.1);
                d3_camera.focus._lerp_float(   targ, 5, 0.1);
                d3_camera.up._lerp_float(       _up, 5, 0.1);
                
                _blend = d3_camera.position.distance(_pos) / 2;
                _blend = clamp(_blend, 0, 1);
                
                if(d3_camera.position.equal(_pos) && d3_camera.focus.equal(targ))
                    d3_active_transition = 0;
                    
            } else {
                d3_camera.position.set(_pos);
                d3_camera.focus.set(targ);
            }
            
            d3_camera.setViewSize(w, h);
            d3_camera.setMatrix();
        #endregion
        
        draw_clear(bg_color);
            
        gpu_set_texfilter(true);
        shader_set(sh_rm_primitive);
            var zm = 4 / d3_camera.focus_dist;
            
            shader_set_f("camRotation", [ d3_camera.focus_angle_y, -d3_camera.focus_angle_x, 0 ]);
            shader_set_f("camScale",    zm);
            shader_set_f("camRatio",    w / h);
            shader_set_i("shapeAmount", 0);
            
            _env.apply();
            if(_obj) _obj.apply();
            
            shader_set_i("drawBg",      d3_drawBG);
            shader_set_f("depthInt",    0);
            
            var _scale = zm / 2;
            var _step  = 1;
            while(_scale > 32) {
                _scale /= 2;
                _step  /= 2;
            }
            
            shader_set_i("drawGrid",    true);
            shader_set_f("gridStep",    _step);
            shader_set_f("gridScale",   zm / 2);
            shader_set_f("axisBlend",   1);
            shader_set_f("viewRange",   [ d3_camera.view_near, d3_camera.view_far ]);
            
            draw_sprite_stretched(s_fx_pixel, 0, 0, 0, w, h);
        shader_reset();
        gpu_set_texfilter(false);
    }
    
    function draw3D() {
        var _node = getNodePreview();
        if(_node == noone) return;
        
        switch(d3_active) {
            case NODE_3D.polygon :    draw3DPolygon(_node);    break;
            case NODE_3D.sdf :        draw3DSdf(_node);        break;
        }
    }
    
    function drawPreviewOverlay() {
        right_menu_y = toolbar_height;
        if(PROJECT.previewSetting.show_view_control == 2) {
            if(d3_active) right_menu_y += ui(72);
            else          right_menu_y += ui(40);
        } 
        
        toolbar_draw = false;
        var _node = getNodePreview();
        
        #region status texts (top right)
            draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text);
            var _lh = line_get_height();
            
            if(right_menu_x == 0) right_menu_x = w - ui(8);
            
            if(PROJECT.previewSetting.show_info && !CAPTURING) {
                if(PANEL_PREVIEW == self) {
                    draw_set_color(COLORS._main_text_accent);
                    draw_text(right_menu_x, right_menu_y, __txt("Active"));
                    right_menu_y += _lh;
                }
                
                var txt = $"{__txt("fps")} {fps}";
                if(PREFERENCES.panel_preview_show_real_fps)
                    txt += $" / {FPS_REAL}";
                
                var cc = fps >= PROJECT.animator.framerate? COLORS._main_text_sub : COLORS._main_value_negative;
                if(!window_has_focus()) cc = COLORS._main_text_sub; 
                
                draw_set_color(cc);
                draw_text(right_menu_x, right_menu_y, txt);
                right_menu_y += _lh;
            
                var _cur_frame = GLOBAL_CURRENT_FRAME + 1;
                draw_set_color(frac(_cur_frame) == 0? COLORS._main_text_sub : COLORS._main_value_negative);
                draw_text(right_menu_x, right_menu_y, $"{__txt("Frame")} {_cur_frame}/{GLOBAL_TOTAL_FRAMES}");
            	
                if(d3_active == NODE_3D.none) {
                    right_menu_y += _lh;
                    
                    var _zmsl = tb_zoom_level.selecting || tb_zoom_level.hovering || tb_zoom_level.sliding;
                    var _zms  = $"x{canvas_s}";
                    var _zmw  = string_width(_zms) + ui(16);
                    var _zmx  = right_menu_x + ui(8);
                    var _zmc  = _zmsl? COLORS._main_text : COLORS._main_text_sub;
                    
                    if(_zmsl) draw_sprite_stretched(THEME.textbox, 3, _zmx - _zmw + ui(4), right_menu_y + ui(2), _zmw - ui(10), _lh - ui(2));
                    
                    tb_zoom_level.postBlend = _zmc;
                    tb_zoom_level.setFocusHover(pFOCUS, pHOVER);
                    tb_zoom_level.draw(_zmx, right_menu_y, _zmw, _lh, string(canvas_s), [mx,my], fa_right);
                    if(tb_zoom_level.hovering) {
                    	mouse_on_preview = false;
                    	CURSOR_SPRITE    = THEME.view_zoom;
                    }
                    
                	draw_set_text(f_p2, fa_right, fa_top, _zmc);
                    if(!tb_zoom_level.selecting && !tb_zoom_level.sliding)
	                	draw_text(_zmx - _zmw + ui(14), right_menu_y, "x");
                    
                	draw_set_color(COLORS._main_text_sub);
                	
                    if(pHOVER) {
                        right_menu_y += _lh;
                        var mpx = floor((mx - canvas_x) / canvas_s);
                        var mpy = floor((my - canvas_y) / canvas_s);
                        draw_text(right_menu_x, right_menu_y, $"[{mpx}, {mpy}]");
                        
                        if(selection_selecting) {
                        	right_menu_y += _lh;
				        	draw_text(right_menu_x, right_menu_y, $"[{selecting_w}, {selecting_h}]");
				        	
                        } else if(selection_active) {
                        	right_menu_y += _lh;
				        	draw_text(right_menu_x, right_menu_y, $"[{selection_x1 - selection_x0}, {selection_y1 - selection_y0}]");
                        }
                        
                        if(mouse_pos_string != "") {
                            right_menu_y += _lh;
                            draw_text(right_menu_x, right_menu_y, $"{mouse_pos_string}");
                        }
                        
                    }
                    
                    if(_node != noone) {
                        right_menu_y += _lh;
                        var txt = $"{canvas_w} x {canvas_h}px";
                        if(canvas_a) txt = $"{canvas_a} x {txt}";
                        
                        draw_text(right_menu_x, right_menu_y, txt);
                    
                        right_menu_x = w - ui(8);
                        right_menu_y += _lh;
                    }
                }
                
                mouse_pos_string = "";
            }
            
            right_menu_x = w - ui(8);
        #endregion
        
        drawDataArray();
    }
    
    function drawDataArray() {
        if(mouse_release(mb_left)) preview_selecting = false;
        var _preview_x_max = preview_x_max;
        preview_x_max = 0;
        
        var _node = getNodePreview();
        var  pseq = getNodePreviewSequence();
        if(_node == noone || pseq == noone) return;
        
        if(!array_equals(pseq, _preview_sequence)) {
            _preview_sequence = pseq;
            preview_x    = 0;
            preview_x_to = 0;
        }
        
        preview_x = lerp_float(preview_x, preview_x_to, 4);
            
        if(pHOVER && my > h - toolbar_height - array_preview_size - ui(16) && my > toolbar_height) {
            canvas_hover = false;
            
            if(MOUSE_WHEEL != 0 && !key_mod_press_any()) 
            	preview_x_to = clamp(preview_x_to + array_preview_size * MOUSE_WHEEL, -_preview_x_max, 0);
        }
        
        var pseql = array_length(pseq);
        if(pseql <= 1) return;
        
        var siz = array_preview_size;
        var _xx = tool_side_draw_l * ui(40);
        var sx  = _xx + preview_x + ui(8);
        var yy  = h - toolbar_height - siz - ui(8);
    	
        if(my > yy - 8) mouse_on_preview = 0;
        var hoverable = pHOVER && point_in_rectangle(mx, my, _xx, ui(32), w, h - toolbar_height);
    	
        for( var i = 0, n = pseql; i < n; i++ ) {
            var prev = pseq[i];
        	var xx   = sx + (siz + ui(8)) * i;
        	
        	if(xx + siz < -ui(16)) continue;
        	if(xx > w + ui(16)) break;
            
            if(is(prev, __3dObject))    prev = array_safe_get(prev.materials, 0);
            if(is(prev, __d3dMaterial)) prev = prev.surface;
        	
        	draw_sprite_stretched_ext(THEME.box_r2, 1, xx, yy, siz, siz, COLORS.panel_preview_surface_outline, .5);
    		var hov = hoverable && point_in_rectangle(mx, my, xx, yy, xx + siz, yy + siz);
    		var sel = i == _node.preview_index;
    		
            if(is_surface(prev)) {
	            var prev_w  = surface_get_width_safe(prev);
	            var prev_h  = surface_get_height_safe(prev);
	            var ss = siz / max(prev_w, prev_h);
	            var pw = prev_w * ss;
	            var ph = prev_h * ss;
	            
	            var ssx = xx + siz / 2 - pw / 2;
	            var ssy = yy + siz / 2 - ph / 2;
	            
	            draw_sprite_stretched_ext(THEME.box_r2, 1, ssx, ssy, pw, ph, COLORS.panel_preview_surface_outline, 1.);
	        	draw_surface_ext_safe(prev, ssx, ssy, ss, ss, 0, c_white, .5 + .5 * (sel || hov));
	        	
	        	if(sel) draw_sprite_stretched_ext(THEME.box_r2, 1, ssx, ssy, pw, ph, COLORS._main_accent);
	        	
            } else if(sel) draw_sprite_stretched_ext(THEME.box_r2, 1, xx, yy, siz, siz, COLORS._main_accent);
            
            if((hov && mouse_press(mb_left, pFOCUS)) || (preview_selecting && mx > xx && mx <= xx + siz)) {
                _node.preview_index = i;
                _node.onValueUpdate(0);
                if(resetViewOnDoubleClick) do_fullView = true;
                PANEL_GRAPH.refreshDraw();
                
                preview_selecting = true;
            }
        }
        
        preview_x_max = max((siz + ui(8)) * pseql - ui(100), 0);
    }
    
    function drawViewController() {
        if(!PROJECT.previewSetting.show_view_control) return;
        if(CAPTURING) return;
        
        var _side   = PROJECT.previewSetting.show_view_control == 1? 1 : -1;
        var _view_x = PROJECT.previewSetting.show_view_control == 1? 
                tool_side_draw_l * toolbar_width + ui(8) : 
            w - tool_side_draw_r * toolbar_width - ui(8);
            
        var _view_y = topbar_height + ui(8);
        var _hab    = pHOVER && tool_hovering == noone && !view_pan_tool && !view_zoom_tool;
        view_hovering = false;
        
        if(d3_active) { 
            var d3_view_wr = ui(32);
            
            var _d3x = _view_x + d3_view_wr * _side;
            var _d3y = _view_y + d3_view_wr;
            var _hv  = false;
            
            if(_hab && point_in_circle(mx, my, _d3x, _d3y, d3_view_wr)) {
                _hv = true;
                view_hovering = true;
                
                if(mouse_press(mb_left, pFOCUS)) {
                    canvas_drag_key = mb_left;
                    d3_camPanning   = true;
                    d3_camPan_mx    = mx;
                    d3_camPan_my    = my;
                    
                    view_pan_tool = true;
                }
            }
            
            if(view_pan_tool)
                _hv = true;
            
            draw_circle_ui(_d3x, _d3y, d3_view_wr, _hv? 0 : 0.01, COLORS._main_icon, 0.3);
            
            var _qview = new BBMOD_Quaternion().FromEuler(d3_camera.focus_angle_y, -d3_camera.focus_angle_x, 0);
            var _as = [
                new BBMOD_Vec3(-1, 0, 0),
                new BBMOD_Vec3(0,  0, 1),
                new BBMOD_Vec3(0, -1, 0),
            ];
            
            for(var i = 0; i < 3; i++) {
                _as[i] = _qview.Rotate(_as[i]);
                
                draw_set_color(COLORS.axis[i]);
                draw_line_round(_d3x, _d3y, _d3x + _as[i].X * (d3_view_wr * 0.75), _d3y + _as[i].Y * (d3_view_wr * 0.75), 3);
            }
            
            var d3_view_wz = ui(16);
            var _d3x = _view_x + (d3_view_wr * 2 + ui(20)) * _side;
            var _d3y = _view_y + d3_view_wz;
            var _hv  = false;
            
            if(_hab && point_in_circle(mx, my, _d3x, _d3y, d3_view_wz)) {
                _hv = true;
                view_hovering = true;
                
                if(mouse_press(mb_left, pFOCUS)) {
                    canvas_drag_key = mb_left;
                    canvas_zooming  = true;    
                    canvas_zoom_m   = my;
                    view_zoom_tool  = true;
                }
            }
            
            if(view_zoom_tool)
                _hv = true;
            
            draw_circle_ui(_d3x, _d3y, d3_view_wz, _hv? 0 : 0.02, COLORS._main_icon, 0.3);
            draw_sprite_ui(THEME.view_zoom, 0, _d3x, _d3y, 1, 1, 0, view_zoom_tool? COLORS._main_accent : COLORS._main_icon, 1);
            
        } else {
            var d3_view_wz = ui(16);
            
            var _d3x = _view_x + d3_view_wz * _side;
            var _d3y = _view_y + d3_view_wz;
            var _hv  = false;
            
            if(_hab && point_in_circle(mx, my, _d3x, _d3y, d3_view_wz)) {
                _hv = true;
                view_hovering = true;
                
                if(mouse_press(mb_left, pFOCUS)) {
                    canvas_drag_key = mb_left;
                    canvas_dragging = true;
                    canvas_drag_mx  = mx;
                    canvas_drag_my  = my;
                    canvas_drag_sx  = canvas_x;
                    canvas_drag_sy  = canvas_y;
                    
                    view_pan_tool = true;
                }
            }
            
            if(view_pan_tool)
                _hv = true;
            
            draw_circle_ui(_d3x, _d3y, d3_view_wz, _hv? 0 : 0.02, COLORS._main_icon, 0.3);
            draw_sprite_ui(THEME.view_pan, 0, _d3x, _d3y, 1, 1, 0, view_pan_tool? COLORS._main_accent : COLORS._main_icon, 1);
            
            _d3x += (d3_view_wz + ui(4) + d3_view_wz) * _side;
            _d3y =  _view_y + d3_view_wz;
            _hv  =  false;
            
            if(_hab && point_in_circle(mx, my, _d3x, _d3y, d3_view_wz)) {
                _hv = true;
                view_hovering = true;
                
                if(mouse_press(mb_left, pFOCUS)) {
                    canvas_drag_key = mb_left;
                    canvas_zooming  = true;    
                    canvas_zoom_mx  = w / 2;
                    canvas_zoom_my  = h / 2;
                    canvas_zoom_m   = my;
                    canvas_zoom_s   = canvas_s;
                    
                    view_zoom_tool  = true;
                }
            }
            
            if(view_zoom_tool)
                _hv = true;
            
            draw_circle_ui(_d3x, _d3y, d3_view_wz, _hv? 0 : 0.02, COLORS._main_icon, 0.3);
            draw_sprite_ui(THEME.view_zoom, 0, _d3x, _d3y, 1, 1, 0, view_zoom_tool? COLORS._main_accent : COLORS._main_icon, 1);
        }
        
        if(view_hovering && mouse_press(mb_right, pFOCUS)) {
        	mouse_on_preview = false;
        	menuCall("preview_view_controller", [ menuItem("Hide view controllers", function() /*=>*/ { PROJECT.previewSetting.show_view_control = 0; }) ]);
        }
    }
    
    function drawAllNodeGizmo(active) {
    	var _mx = mx;
        var _my = my;
        var overHover = pHOVER && mouse_on_preview == 1;
        var tool_size  = ui(32);
        
        var cx = canvas_x;
        var cy = canvas_y;
        var _snx = 0, _sny = 0;
        
        if(key_mod_press(CTRL)) {
            _snx = PROJECT.previewGrid.show? PROJECT.previewGrid.size[0] : 1;
            _sny = PROJECT.previewGrid.show? PROJECT.previewGrid.size[1] : 1;
            
        } else if(PROJECT.previewGrid.snap) {
            _snx = PROJECT.previewGrid.size[0];
            _sny = PROJECT.previewGrid.size[1];
        }
            
        overHover = overHover && !view_hovering;
        overHover = overHover && tool_hovering == noone && !overlay_hovering;
        overHover = overHover && !canvas_dragging && !canvas_zooming;
        overHover = overHover && point_in_rectangle(mx, my, 0, toolbar_height, w, h - toolbar_height);
        overHover = overHover && !key_mod_press(CTRL);
        
        var overActive = active && overHover;
        var params = { w, h, toolbar_height };
        params.panel = self;
        
        var _nlist = PANEL_GRAPH.nodes_list;
        if(gizmo_show && !CAPTURING)
        for( var i = 0, n = array_length(_nlist); i < n; i++ ) {
        	var _n = _nlist[i];
        	if(!is(_n, Node))     continue;
        	if(!_n.isGizmoGlobal) continue;
        	
        	var _h = _n.doDrawOverlay(overHover, overActive, cx, cy, canvas_s, _mx, _my, _snx, _sny, params);
        	
        	if(_h == true) {
        		overHover  = false;
        		overActive = false;
        	}
        }
    }
    
    function drawNodeActions(active, _node) {
        var _mx = mx;
        var _my = my;
        var overHover = pHOVER && mouse_on_preview == 1, overActive;
        
        var cx = canvas_x + _node.preview_x * canvas_s;
        var cy = canvas_y + _node.preview_y * canvas_s;
        var _snx = 0, _sny = 0;
        
        tool_side_draw_l = tool_always_l || _node.showTool();
        tool_side_draw_r = tool_always_r || _node.rightTools != -1;
        
        if(_node.showTool() && point_in_rectangle(_mx, _my, 0, 0, toolbar_width, h))
            overHover = false;
        
        overHover = overHover && !view_hovering;
        overHover = overHover && tool_hovering == noone && !overlay_hovering;
        overHover = overHover && !canvas_dragging && !canvas_zooming;
        overHover = overHover && point_in_rectangle(mx, my, (_node.showTool()) * toolbar_width, toolbar_height, w, h - toolbar_height);
        
        overActive = active && overHover;
        overHover  = overHover && !key_mod_press(CTRL);
        hoveringContent = overHover;
        
        var _params = { w, h, toolbar_height };
            _params.panel = self;
            _params.scene = d3_scene;
        
        if(gizmo_show && !CAPTURING) {
	        if(_node.is_3D == NODE_3D.none) {
	            if(key_mod_press(CTRL)) {
	                _snx = PROJECT.previewGrid.show? PROJECT.previewGrid.size[0] : 1;
	                _sny = PROJECT.previewGrid.show? PROJECT.previewGrid.size[1] : 1;
	                
	            } else if(PROJECT.previewGrid.snap) {
	                _snx = PROJECT.previewGrid.size[0];
	                _sny = PROJECT.previewGrid.size[1];
	            }
	            
	            var _ovx = cx;
	            var _ovy = cy;
	            var _ovs = canvas_s;
	            
	            var _prevNode = getNodePreview();
	            if(_prevNode != _node && is(_prevNode, Node)) {
	            	var _trans = _prevNode.drawOverlayChainTransform(_node);
	            	_ovx += _trans[0] * _ovs;
					_ovy += _trans[1] * _ovs;
					_ovs *= _trans[2];
	            }
	            
	            hoveringGizmo = _node.doDrawOverlay(overHover, overActive, _ovx, _ovy, _ovs, _mx, _my, _snx, _sny, _params);
		    	 
	        } else {
	            if(key_mod_press(CTRL) || PROJECT.previewSetting.d3_tool_snap) {
	                _snx = PROJECT.previewSetting.d3_tool_snap_position;
	                _sny = PROJECT.previewSetting.d3_tool_snap_rotation;
	            }
	            
	            hoveringGizmo = _node.drawOverlay3D(overActive, _mx, _my, _snx, _sny, _params) ?? true;
	        }
        }
        
        overlay_hovering = false;
        
        if(_node.drawPreviewToolOverlay != undefined) {
        	var _param = { x, y, w, h, toolbar_height, 
	            x0: _node.showTool() * ui(40),
	            x1: w,
	            y0: toolbar_height - ui(8), 
	            y1: h - toolbar_height 
	        };
        	
	        if(_node.drawPreviewToolOverlay(pHOVER, pFOCUS, _mx, _my, _param)) {
	            canvas_hover     = false;
	            overlay_hovering = true;
	        }
        }
        
        drawToolsLeft(_node);
        drawToolsRight(_node);
    }
    
    function drawTopbar(_node) {
    	var aa = d3_active? 0.8 : 1;
    	
    	draw_sprite_stretched_ext(THEME.toolbar, 1, 0,  0, w, topbar_height, c_white, aa);
    	
        if(sample_data != noone) {
            var cx = ui(6);
            var cy = ui(6);
            var cw = ui(32);
            var ch = topbar_height - ui(10);
            
            var _ty = sample_data.type;
            
            if(_ty == "color") {
            	var _da = sample_data.data;
            	var _cc = sample_data.color;
	            drawColor(_cc, cx, cy, cw, ch);
	            draw_sprite_stretched_add(THEME.box_r2, 1, cx, cy, cw, ch, c_white, 0.3);
	            
	            var tx = cx + cw + ui(8);
	            draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
	            
	            if(is_array(_da)) {
	            	draw_text(tx, cy + ch / 2, _da);
	            	
	            } else {
	                var hx = color_get_hex(_cc);
	                draw_text(tx, cy + ch / 2, hx);
	            
	                tx += string_width(hx) + ui(8);
	                draw_set_color(COLORS._main_text_sub);
	                draw_text(tx, cy + ch / 2, $"({color_get_alpha(_cc)})");
	            }
	            
            } else if(_ty == "tileset") {
            	cw = ch;
            	
            	var _dr = sample_data.drawFn;
				var _in = sample_data.index;
				
				_dr(_in, cx, cy, cw, ch);
				draw_sprite_stretched_add(THEME.box_r2, 1, cx, cy, cw, ch, c_white, 0.3);
				
				var tx = cx + cw + ui(8);
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				
				draw_text(tx, cy + ch / 2, $"Tile {_in}");
            }
            
        } else if(_node && tool_current) {
            drawToolSettings(_node);
            
		} else {
			var m  = [mx,my];
			
			var cw = ui(120);
			var ch = topbar_height - ui(11);
			var cx = w - ui(6) - cw;
			var cy = ui(6);
            
			sb_shader.setFocusHover(pFOCUS, pHOVER);
			sb_shader.setTextColor(preview_shader? COLORS._main_accent : COLORS._main_text);
			sb_shader.draw(cx, cy, cw, ch, preview_shader, m, x, y);
			
			// var cw = ui(240);
			// var ch = topbar_height - ui(11);
			// var cx = w - ui(6) - cw;
			// var cy = ui(6);

   //         bb_shader.setFocusHover(pFOCUS, pHOVER);
			// bb_shader.draw(cx, cy, cw, ch, preview_shader, m, x, y);
			
			if(preview_shader) {
				var bs = ch;
				var bx = cx - ui(4) - bs;
				var by = cy;
				var bb = THEME.button_hide;
				
				if(buttonInstant_Pad(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Apply Alpha", THEME.shader_alpha, preview_shader_alpha) == 2)
					preview_shader_alpha = !preview_shader_alpha;
			}
			
		}
        
        sample_data = noone;
        
    }
    
    function drawToolBar(_node) {
        var ty = h - toolbar_height;
        var aa = d3_active? 0.8 : 1;
        
        draw_sprite_stretched_ext(THEME.toolbar, 0, 0, ty, w, toolbar_height, c_white, aa);
        
        var toolbar_right = w - ui(4);
        var scs = gpu_get_scissor();
        var tbx = w - ui(4);
        var tby = ty + toolbar_height / 2;
        var _m  = [ mx, my ];
        
        var _nodeRaw = __getNodePreview();
        if(_nodeRaw) tbx -= drawNodeChannel(_nodeRaw, tbx, tby);
        toolbar_right = tbx;
        
        if(toolbar_right < ui(6)) return;
        
        var tbx = ui(4);
        var bs  = toolbar_height - ui(8);
        var bsc = 1;
        
        var toolbar_left = 0;
    	var hov = pHOVER && point_in_rectangle(mx, my, 0, ty, toolbar_right - ui(4), h);
    	var foc = pFOCUS;
    	
    	var _toolbars    = "preview_toolbar";
        switch(d3_active) {
            case NODE_3D.none :     _toolbars = "preview_toolbar";        break;
            case NODE_3D.polygon :  _toolbars = "preview_toolbar_3d";     break;
            case NODE_3D.sdf :      _toolbars = "preview_toolbar_3d_sdf"; break;
        }
        
        if(mouse_press(mb_right, hov && foc)) menuCallGen($"{_toolbars}_context");
    	var _tool_b = menuItems_gen(_toolbars);
        for( var i = 0, n = array_length(_tool_b); i < n; i++ ) {
			var _menu = _tool_b[i];
			if(_menu == -1) {
				draw_set_color(COLORS.panel_toolbar_separator);
				draw_line_width(tbx + ui(2), by + ui(2), tbx + ui(2), by + bs - ui(2), 2);
				
				tbx += ui(6);
				continue;
			} 
			
			var bx = tbx;
            var by = tby - bs / 2;
            
			_menu.draw(bx, by, bs, bs, _m, hov, foc, _toolbars);
			tbx += bs + ui(2);
		}
		
        toolbar_left = tbx + ui(2);
        gpu_set_scissor(scs);
        
        if(toolbar_right < toolbar_left) return;
        
        tbx = toolbar_right - bs;
        gpu_set_scissor(toolbar_left, ty, w - toolbar_left, toolbar_height);
        var hov = pHOVER && point_in_rectangle(mx, my, toolbar_left, ty, w, h);
        
        var _action_b = menuItems_gen("preview_actions");
        for( var i = 0, n = array_length(_action_b); i < n; i++ ) {
        	var _menu = _action_b[i];
			if(_menu == -1) {
				draw_set_color(COLORS.panel_toolbar_separator);
				draw_line_width(tbx - ui(2), by + ui(2), tbx - ui(2), by + bs - ui(2), 2);
				
				tbx -= ui(6);
				continue;
			} 
			
			var bx = tbx;
            var by = tby - bs / 2;
            
			_menu.draw(bx, by, bs, bs, _m, hov, foc, _toolbars);
			tbx -= bs + ui(2);
        }
        
        gpu_set_scissor(scs);
        
        var _lx = max(toolbar_left - ui(4), tbx + bs - ui(2));
        var _ly = tby;
        var _lh = toolbar_height / 2 - ui(8);
        
        draw_set_color(COLORS.panel_toolbar_separator);
        draw_line_width(_lx, _ly - _lh, _lx, _ly + _lh, 2);
    }
    
    function drawSplitView() {
        if(splitView == 0) return;
        
        draw_set_color(COLORS.panel_preview_split_line);
        
        if(splitViewDragging) {
            if(splitView == 1) {
                var cx = splitViewStart + (mx - splitViewMouse);
                splitPosition = clamp(cx / w, .1, .9);
            } else if(splitView == 2) {
                var cy = splitViewStart + (my - splitViewMouse);
                splitPosition = clamp(cy / h, .1, .9);
            }
            
            if(mouse_release(mb_left))
                splitViewDragging = false;
        }
        
        if(splitView == 1) {
            var sx = w * splitPosition;
            
            if(mouse_on_preview && point_in_rectangle(mx, my, sx - ui(4), 0, sx + ui(4), h)) {
                draw_line_width(sx, 0, sx, h, 2);
                if(mouse_press(mb_left, pFOCUS)) {
                    splitViewDragging = true;
                    splitViewStart = sx;
                    splitViewMouse = mx;
                }
            } else 
                draw_line_width(sx, 0, sx, h, 1);
            
            draw_sprite_ui_uniform(THEME.icon_active_split, 0, splitSelection? sx + ui(16) : sx - ui(16), toolbar_height + ui(16),, COLORS._main_accent);
            
            if(mouse_on_preview && mouse_press(mb_left, pFOCUS)) {
                if(point_in_rectangle(mx, my, 0, 0, sx, h))
                    splitSelection = 0;
                else if(point_in_rectangle(mx, my, sx, 0, w, h))
                    splitSelection = 1;
            }
        } else {
            var sy = h * splitPosition;
            
            if(mouse_on_preview && point_in_rectangle(mx, my, 0, sy - ui(4), w, sy + ui(4))) {
                draw_line_width(0, sy, w, sy, 2);
                if(mouse_press(mb_left, pFOCUS)) {
                    splitViewDragging = true;
                    splitViewStart = sy;
                    splitViewMouse = my;
                }
            } else
                draw_line_width(0, sy, w, sy, 1);
            draw_sprite_ui_uniform(THEME.icon_active_split, 0, ui(16), splitSelection? sy + ui(16) : sy - ui(16),, COLORS._main_accent);
            
            if(mouse_on_preview && mouse_press(mb_left, pFOCUS)) {
                if(point_in_rectangle(mx, my, 0, 0, w, sy))
                    splitSelection = 0;
                else if(point_in_rectangle(mx, my, 0, sy, w, h))
                    splitSelection = 1;
            }
        }
    }
    
    function setActionTooltip(txt, time = 1) { tooltip_action = txt; tooltip_action_time = time; return self; }
    function drawActionTooltip() {
    	if(tooltip_action_time <= 0) return;
    	
    	tooltip_action_time -= DELTA_TIME;
    	var aa = clamp(tooltip_action_time * 2, 0, 1);
    	
    	draw_set_text(f_p3, fa_right, fa_bottom, COLORS._main_text_sub);
    	var txt = tooltip_action;
    	var tw  = string_width(txt)  + ui(6 * 2);
    	var th  = string_height(txt) + ui(3 * 2);
    	
    	var tx1 = w - ui(6 + 2);
    	var ty1 = h - toolbar_height - ui(3);
    	var tx0 = tx1 - tw;
		var ty0 = ty1 - th;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, tx0, ty0, tw, th, c_white, aa);
		draw_set_alpha(aa);
		draw_text(tx1 - ui(6), ty1 - ui(3), txt);
		draw_set_alpha(1);
    }
    
    function drawMinimap() { //
        if(!minimap_show) return;
        
        var mx1 = w - ui(8);
        var my1 = h - toolbar_height - ui(8);
        var mx0 = mx1 - minimap_w;
        var my0 = my1 - minimap_h;
        
        minimap_w = min(minimap_w, w - ui(16));
        minimap_h = min(minimap_h, h - ui(16) - toolbar_height);
        
        var mini_hover = false;
        if(pHOVER && point_in_rectangle(mx, my, mx0, my0, mx1, my1)) {
            mouse_on_preview = false;
            mini_hover = true;
        }
        
        var hover = mini_hover && !point_in_rectangle(mx, my, mx0, my0, mx0 + ui(16), my0 + ui(16)) && !minimap_dragging;
        minimap_surface = surface_verify(minimap_surface, minimap_w, minimap_h);
        
        surface_set_target(minimap_surface);
        DRAW_CLEAR
    	draw_sprite_stretched_ext(THEME.ui_panel, 0, 0, 0, minimap_w, minimap_h, COLORS.panel_bg_clear_inner, .75 + .25 * hover);
    	
        	var _surf = getNodePreviewSurface();
            var _dim  = [ 1, 1 ];
        	var minx, maxx, miny, maxy;
            
        	if(is_surface(_surf)) {
        		_dim = surface_get_dimension(_surf);
        		
        		minx = -32;
	            maxx =  32 + _dim[0];
	            miny = -32;
	            maxy =  32 + _dim[1];
	            
        	} else {
        		minx = -32;
        		maxx =  32;
        		miny = -32;
        		maxy =  32;
        	}
        	
        	var cx  = (minx + maxx) / 2;
            var cy  = (miny + maxy) / 2;
            var spw = maxx - minx;
            var sph = maxy - miny;
            var ss  = min(minimap_w / spw, minimap_h / sph);
            
            var nx0 = minimap_w / 2 + (0       - cx) * ss;
            var ny0 = minimap_h / 2 + (0       - cy) * ss;
            var nx1 = minimap_w / 2 + (_dim[0] - cx) * ss;
            var ny1 = minimap_h / 2 + (_dim[1] - cy) * ss;
            
            var vx0 = (-canvas_x    ) / canvas_s;
			var vy0 = (-canvas_y    ) / canvas_s;
			var vx1 = (-canvas_x + w) / canvas_s;
			var vy1 = (-canvas_y + h) / canvas_s;
			
            var gx0 = minimap_w / 2 + (vx0 - cx) * ss;
            var gy0 = minimap_h / 2 + (vy0 - cy) * ss;
            var gx1 = minimap_w / 2 + (vx1 - cx) * ss;
            var gy1 = minimap_h / 2 + (vy1 - cy) * ss;
            var gw  = gx1 - gx0;
            var gh  = gy1 - gy0;
            
            if(is_surface(_surf))
            	draw_surface_ext(_surf, nx0, ny0, ss, ss, 0, c_white, 1);
            	
            draw_sprite_stretched_ext(THEME.ui_panel, 1, gx0, gy0, gw, gh, COLORS._main_icon_light, 1);
		     
	        var _mini_mx = minx + (mx - mx0) / minimap_w * spw;
	        var _mini_my = miny + (my - my0) / minimap_h * sph;
	        
	        if(minimap_panning) {
	            canvas_x = w / 2 - _mini_mx * canvas_s;
	            canvas_y = h / 2 - _mini_my * canvas_s;
	            
	            if(mouse_release(mb_left))
	                minimap_panning = false;
	        }
	        
	        if(mouse_click(mb_left, hover))
	            minimap_panning = true;
	            
        BLEND_MULTIPLY
        draw_sprite_stretched_ext(THEME.ui_panel, 0, 0, 0, minimap_w, minimap_h, c_white, 1);
        BLEND_NORMAL
        
        surface_reset_target();
                
        draw_surface_ext_safe(minimap_surface, mx0, my0, 1, 1, 0, c_white, 1);
        draw_sprite_stretched_add(THEME.ui_panel, 1, mx0, my0, minimap_w, minimap_h, COLORS.panel_graph_minimap_outline, .5);
        
        if(minimap_dragging) {
            mouse_on_graph = false;
            var sw = minimap_drag_sx + minimap_drag_mx - mx;
            var sh = minimap_drag_sy + minimap_drag_my - my;
            
            minimap_w = max(ui(64), sw);
            minimap_h = max(ui(64), sh);
            
            if(mouse_release(mb_left))
                minimap_dragging = false;
        }
        
        if(pHOVER && point_in_rectangle(mx, my, mx0, my0, mx0 + ui(16), my0 + ui(16))) {
            draw_sprite_ui(THEME.node_resize, 0, mx0 + ui(4), my0 + ui(4), 0.5, 0.5, 180, c_white, 0.75);
            if(mouse_press(mb_left, pFOCUS)) {
                minimap_dragging = true;
                minimap_drag_sx = minimap_w;
                minimap_drag_sy = minimap_h;
                minimap_drag_mx = mx;
                minimap_drag_my = my;
            }
        } else 
            draw_sprite_ui(THEME.node_resize, 0, mx0 + ui(4), my0 + ui(4), 0.5, 0.5, 180, c_white, 0.3);
    } 
    
    function drawSelection() {
    	var prevN = getNodePreview();
    	var prevS = is(prevN, Node) && prevN.preview_select_surface && 
    	            !array_empty(prevN.outputs) && prevN.outputs[0].type == VALUE_TYPE.surface;
    	
    	if(!prevS) selection_active = false;
    	
    	var mmx = mx;
    	var mmy = my;
    	
    	if(PROJECT.previewGrid.snap || key_mod_press(CTRL)) {
	    	var _snx = PROJECT.previewGrid.show? PROJECT.previewGrid.size[0] : 1;
	        var _sny = PROJECT.previewGrid.show? PROJECT.previewGrid.size[1] : 1;
	        
	        mmx = value_snap(mmx, _snx);
			mmy = value_snap(mmy, _sny);
    	}
    	
    	if(hoveringContent && !hoveringGizmo) {
        	if(mouse_lpress(pFOCUS)) {
        		selection_active    = false;
        		selection_selecting = 1;
        		selection_sx = mmx;
        		selection_sy = mmy;
        	}
        }
        
        if(selection_selecting) {
        	selection_mx = mmx;
    		selection_my = mmy;
    		
	    	var _x0 = (selection_sx - canvas_x) / canvas_s;
	    	var _y0 = (selection_sy - canvas_y) / canvas_s;
    		var _x1 = (selection_mx - canvas_x) / canvas_s;
	    	var _y1 = (selection_my - canvas_y) / canvas_s;
    		
    		var _px0 = min(_x0, _x1);
			var _py0 = min(_y0, _y1);
			var _px1 = max(_x0, _x1);
			var _py1 = max(_y0, _y1);

    		if(prevS) {
    			_px0 = floor( _px0 );
    			_py0 = floor( _py0 );
				_px1 = ceil(  _px1 );
				_py1 = ceil(  _py1 );
    		}
    		
    		var _xx0 = canvas_x + _px0 * canvas_s;
        	var _yy0 = canvas_y + _py0 * canvas_s;
        	var _xx1 = canvas_x + _px1 * canvas_s;
        	var _yy1 = canvas_y + _py1 * canvas_s;
        	
        	selecting_w  = _px1 - _px0;
    		selecting_h  = _py1 - _py0;
        	
        	selection_x0 = _px0;
	    	selection_y0 = _py0;
	    	selection_x1 = _px1;
	    	selection_y1 = _py1;
	    	
	    	var _dragDist = point_distance(selection_sx, selection_sy, selection_mx, selection_my);
        	if(_dragDist > canvas_s) selection_selecting = max(selection_selecting, 2);
        	
    		if(selection_selecting > 1)
    			draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, _xx0, _yy0, _xx1, _yy1, COLORS._main_accent);
        	
    		if(mouse_lrelease()) {
    			if(prevS && selection_selecting > 1) selection_active = true;
    			selection_selecting = 0;
    		}
        }
        
        if(selection_active) {
        	var sx0 = canvas_x + selection_x0 * canvas_s;
        	var sy0 = canvas_y + selection_y0 * canvas_s;
        	var sx1 = canvas_x + selection_x1 * canvas_s;
        	var sy1 = canvas_y + selection_y1 * canvas_s;
        	
        	draw_set_color(COLORS._main_accent);
        	draw_rectangle(sx0, sy0, sx1, sy1, true);
        	draw_set_color(c_white);
        	draw_rectangle_dashed(sx0 - 1, sy0 - 1, sx1, sy1);
        	
        }
    }
    
    function drawTemp() {
    	draw_clear(c_black);
    	
    	var surf = __temp_preview;
    	var sw = surface_get_width_safe(surf);
    	var sh = surface_get_height_safe(surf);
    	var ss = min((w - ui(32)) / sw, (h - ui(32)) / sh);
    	
    	var x0 = w / 2 - sw * ss / 2;
    	var y0 = h / 2 - sh * ss / 2;
    	
    	draw_surface_ext(surf, x0, y0, ss, ss, 0, c_white, 1);
    }
    
    ////- DRAW MAIN
    
    function drawContent(panel) { // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIN DRAW <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    	if(__temp_preview != undefined) { 
    		drawTemp(); 
    		if(pHOVER && pFOCUS && mouse_lpress()) __temp_preview = undefined; 
    		return; 
    	}
		
    	mouse_on_preview = pHOVER && point_in_rectangle(mx, my, 0, topbar_height, w, h - toolbar_height);
        
        if(do_fullView) run_in(1, fullView);
        do_fullView = false;
        
        var _prev_node = getNodePreview();
        if(_prev_node && _prev_node.is_3D) {
        	preview_lock = true;
        	d3_active    = _prev_node.is_3D;
        	
        } else {
        	preview_lock = false;
        	d3_active    = preview_mode? NODE_3D.polygon : NODE_3D.none;
        }
        
        bg_color = lerp_color(bg_color, d3_active? COLORS.panel_3d_bg : COLORS.panel_bg_clear, 0.3);
        draw_clear(canvas_bg == -1? bg_color : canvas_bg);
        if(canvas_bg == -1 && canvas_s >= 0.1) 
        	draw_sprite_tiled_ext(s_transparent, 0, canvas_x, canvas_y, canvas_s, canvas_s, COLORS.panel_preview_transparent, 1);
        
        draw_set_color(COLORS._main_icon_dark);
        draw_line_width(canvas_x, 0, canvas_x, h, 1);
        draw_line_width(0, canvas_y, w, canvas_y, 1);
        
        title = __txt("Preview");
        getPreviewData();
        
        if(_prev_node) {
            if(d3_active) {
                dragCanvas3D();
                draw3D();
                
            } else {
                dragCanvas();
                drawNodePreview();
            }
            
        } else {
        	dragCanvas();
        	
        	draw_surface_ext_safe(PROJECT.getOutputSurface(), canvas_x, canvas_y, canvas_s, canvas_s); 
        	draw_set_color_alpha(COLORS.panel_preview_surface_outline, .75);
            draw_rectangle(canvas_x, canvas_y, canvas_x + DEF_SURF_W * canvas_s - 1, canvas_y + DEF_SURF_H * canvas_s - 1, true);
            draw_set_alpha(1);
        }
        
        var inspect_node = PANEL_INSPECTOR.getInspecting();
        var toolNode = noone;
        
        drawPreviewOverlay();
        drawViewController();
        
        hoveringGizmo    = false;
        tool_side_draw_l = false;
        tool_side_draw_r = false;
        
        canvas_mx = (mx - canvas_x) / canvas_s;
        canvas_my = (my - canvas_y) / canvas_s;
        
        if(tool_always_l) {
        	tool_side_draw_l = true;
        	var tw = toolbar_width;
        	var th = h - toolbar_height - ui(32);
        	var aa = d3_active? .8 : 1;
        	draw_sprite_stretched_ext(THEME.tool_side, 0, 0, ui(32), tw, th, c_white, aa);
        }
        
        if(tool_always_r) {
        	tool_side_draw_r = true;
        	var tw = toolbar_width;
        	var th = h - toolbar_height - ui(32);
        	var aa = d3_active? .8 : 1;
        	draw_sprite_stretched_ext(THEME.tool_side, 1, w + 1 - toolbar_width, ui(32), tw, th, c_white, aa);
        }
        
        if(PANEL_PREVIEW == self) { //only draw overlay once
            if(inspect_node) {
                toolNode = inspect_node; 
                if(inspect_node.getTool) toolNode = inspect_node.getTool();
                if(toolNode) drawNodeActions(pFOCUS, toolNode);
                
            } else {
            	if(tool_current != noone) {
	                var _tobj = tool_current.getToolObject();
	        		if(struct_has(_tobj, "disable")) _tobj.disable();
	                tool_current = noone;
            	}
	        	
                drawAllNodeGizmo(pFOCUS);
            }
        }
        
        if(d3_active == NODE_3D.none)
        	drawSplitView();
        
    	drawSelection();
        drawTopbar(toolNode);
        drawToolBar(toolNode);
        
        if(hk_editing != noone) { 
			if(key_press(vk_enter)) hk_editing = noone;
			else hotkey_editing(hk_editing);
			if(key_press(vk_escape)) hk_editing = noone;
		}
		
        drawMinimap();
        drawActionTooltip();
        
        ////////////////////////////////// Actions //////////////////////////////////
        
        if(mouse_on_preview && mouse_press(mb_right, pFOCUS) && !key_mod_press(SHIFT))
            menuCall("preview_context_menu", menuItems_gen("preview_context_menu"), 0, 0, fa_left, getNodePreview());
        
        if(pFOCUS && keyboard_check_pressed(vk_escape))
        	clearTool(true);
        
        ////////////////////////////////// File drop //////////////////////////////////
        
        if(pHOVER) {
            var _node = getNodePreview();
            
            if(_node && _node.dropPath != noone) {
                
                if(DRAGGING && DRAGGING.type == "Asset") {
                    draw_sprite_stretched_ext(THEME.ui_panel_selection, 0, 8, 8, w - 16, h - 16, COLORS._main_value_positive, 1);
                    
                    if(mouse_release(mb_left))
                        _node.dropPath(DRAGGING.data.path);
                }
                
                if(FILE_IS_DROPPING) 
                    draw_sprite_stretched_ext(THEME.ui_panel_selection, 0, 8, 8, w - 16, h - 16, COLORS._main_value_positive, 1);
                    
                if(FILE_DROPPED && !array_empty(FILE_DROPPING)) 
                    _node.dropPath(FILE_DROPPING[0]);
            }
        }
        
    }
    
    ////- ACTION
    
    function blendAtSelection() {
    	if(!selection_active) return;
    	
    	var node  = getNodePreview();
    	var surf  = getNodePreviewSurface();
    	if(!node || !is_just_surface(surf)) return;
    	
    	var sel_x = selection_x0;
    	var sel_y = selection_y0;
    	var sel_w = selection_x1 - selection_x0;
    	var sel_h = selection_y1 - selection_y0;
    	
    	var bx = node.x + node.w + 32;
    	var by = node.y;
    	
    	var sx = node.x;
    	var sy = node.y + node.h + 32;
    	
    	var ori_w = surface_get_width(surf);
    	var ori_h = surface_get_height(surf);
    	
    	var pos_x = (sel_x + sel_w / 2) / ori_w;
    	var pos_y = (sel_y + sel_h / 2) / ori_h;
    	
    	var _blend = nodeBuild("Node_Blend", bx, by).skipDefault();
    	var _solid = nodeBuild("Node_Solid", sx, sy).skipDefault();
    	
    	_blend.inputs[0].setFrom(node.outputs[node.preview_channel]);
    	_blend.inputs[1].setFrom(_solid.outputs[0]);
    	
    	_solid.inputs[0].attributes.use_project_dimension = 0;
    	_solid.inputs[0].setValue([sel_w, sel_h]);
    	
    	_blend.inputs[14].setValue([pos_x, pos_y]);
    }
    
    function copyCurrentFrame() {
        var prevS = getNodePreviewSurface();
        if(!is_surface(prevS)) return;
        
    	if(selection_active) {
        	var x0 = selection_x0;
        	var y0 = selection_y0;
        	var x1 = selection_x1;
        	var y1 = selection_y1;
        	
        	var ww = x1 - x0;
        	var hh = y1 - y0;
        	var _s = surface_create(ww, hh);
        	surface_set_shader(_s);
        	draw_surface(prevS, -x0, -y0);
        	surface_reset_shader();
        	
        	clipboard_set_surface(_s);
        	surface_free(_s);
        	
        } else 
        	clipboard_set_surface(prevS);
    }
    
    function saveCurrentFrameToFocus() {
        var prevS = getNodePreviewSurface();
        if(!is_surface(prevS))     return;
        if(!is_struct(PANEL_FILE)) return;
        
        var _fileO = PANEL_FILE.file_focus;
        if(_fileO == noone) return;
        
        var path = _fileO.path;
        if(path == "") return;
        
        if(filename_ext(path) != ".png") path += ".png";
        
        surface_save_safe(prevS, path);
        _fileO.refreshThumbnail();
    }
    
    function saveCurrentFrameProject(_max_size = undefined, _path = undefined) {
    	var prevS = getNodePreviewSurface();
        if(!is_surface(prevS)) return;
        
        var path = _path ?? PROJECT.path; 
        if(!file_exists_empty(path)) { noti_warning("Save the project first."); return; }
        path = filename_ext_verify(path, ".png");
        
        if(_max_size == undefined) {
        	surface_save_safe(prevS, path);
        	return;
        }
        
        var _sw = surface_get_width_safe(prevS);
        var _sh = surface_get_height_safe(prevS);
        var _ss = max(1, min(_max_size / _sw, _max_size / _sh));
        
        var _surf = surface_create(_ss * _sw, _ss * _sh);
        surface_set_shader(_surf, sh_sample, true, BLEND.over);
        	draw_surface_ext(prevS, 0, 0, _ss, _ss, 0, c_white, 1);
        surface_reset_shader();
        
        surface_save_safe(_surf, path);
        surface_free(_surf);
    }
    
    function saveCurrentFrame() {
        var prevS = getNodePreviewSurface();
        var _node = getNodePreview();
        if(_node == noone || !is_surface(prevS)) return;
        
        var fname = filename_name_only(PROJECT.path);
        var path  = get_save_filename_compat("image|*.png;*.jpg", fname, "Save surface as"); 
        key_release();
        
        if(path == "") return;
        path = filename_ext_verify(path, ".png");
        surface_save_safe(prevS, path);
    }
    
    function saveAllCurrentFrames() {
        var _node = getNodePreview();
        
        if(_node == noone) return;
        
        var fname = filename_name_only(PROJECT.path);
        var path  = get_save_filename_compat("image|*.png;*.jpg", fname, "Save surfaces as"); 
        key_release();
        
        if(path == "") return;
        
        var ext = ".png";
        var name = string_replace_all(path, ext, "");
        var ind  = 0;
        
        var pseq = getNodePreviewSequence();
        for(var i = 0; i < array_length(pseq); i++) {
            var prev   = pseq[i];
            if(!is_surface(prev)) continue;
            var _name = name + string(ind) + ext;
            surface_save_safe(prev, _name);
            ind++;
        }
    }
    
    function callAddDialog() {
    	var  ctx = PANEL_GRAPH.getCurrentContext();
    	var _dia = dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: ctx });
    	
    	_dia.buildCallback = addNodeCallback;
    }
    
    function addNodeCallback(_node) {
    	if(!is(_node, Node)) return;
    	
    	var _baseNode = getNodePreview();
    	
		var _outp = _node.getOutput();
		if(_outp == noone) return;
		
    	if(is(_baseNode, Node_Composite) && _outp.type == VALUE_TYPE.surface)
    		_baseNode.addInput(_outp);
    }
    
    ////- Serialize
    
    static serialize   = function() { 
        return { 
            name:          instanceof(self), 
            preview_node : [ node_get_id(preview_node[0]), node_get_id(preview_node[1]) ],
            
            canvas_x,
            canvas_y,
            canvas_s,
            
            locked,
        }; 
    }
    
    static deserialize = function(data) { 
        if(struct_has(data, "preview_node"))
            preview_node = [ node_from_id(data.preview_node[0]), node_from_id(data.preview_node[1]) ];
        
        canvas_x = struct_try_get(data, "canvas_x", canvas_x);
        canvas_y = struct_try_get(data, "canvas_y", canvas_y);
        canvas_s = struct_try_get(data, "canvas_s", canvas_s);
        
        locked   = struct_try_get(data, "locked", locked);
        
        run_in(1, fullView)
        return self; 
    }
    
}