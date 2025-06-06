#region function calls
    
    function panel_preview_clear_tool()                 { CALL("preview_clear_tool");                PANEL_PREVIEW.clearTool();                                                }
    
    function panel_preview_focus_content()              { CALL("preview_focus_content");             PANEL_PREVIEW.fullView();                                                }
    function panel_preview_save_current_frame()         { CALL("preview_save_current_frame");        PANEL_PREVIEW.saveCurrentFrame();                                        }
    function panel_preview_saveCurrentFrameToFocus()    { CALL("preview_save_to_focused_file");      PANEL_PREVIEW.saveCurrentFrameToFocus();                                 }
    function panel_preview_saveCurrentFrameProject()    { CALL("preview_save_to_project");           PANEL_PREVIEW.saveCurrentFrameProject();                                 }
    function panel_preview_save_all_current_frame()     { CALL("preview_save_all_current_frame");    PANEL_PREVIEW.saveAllCurrentFrames();                                    }
    function panel_preview_preview_window()             { CALL("preview_preview_window");            PANEL_PREVIEW.create_preview_window(PANEL_PREVIEW.getNodePreview());     }
    
    function panel_preview_pan()                        { CALL("preview_pan");                       PANEL_PREVIEW.canvas_dragging_key = true;                                }
    function panel_preview_zoom()                       { CALL("preview_zoom");                      PANEL_PREVIEW.canvas_zooming_key  = true;                                }
    
    function panel_preview_3d_view_front()              { CALL("preview_3d_front_view");             PANEL_PREVIEW.d3_view_action_front();                                    }
    function panel_preview_3d_view_back()               { CALL("preview_3d_back_view");              PANEL_PREVIEW.d3_view_action_back();                                     }
    function panel_preview_3d_view_right()              { CALL("preview_3d_right_view");             PANEL_PREVIEW.d3_view_action_right();                                    }
    function panel_preview_3d_view_left()               { CALL("preview_3d_left_view");              PANEL_PREVIEW.d3_view_action_left();                                     }
    function panel_preview_3d_view_top()                { CALL("preview_3d_top_view");               PANEL_PREVIEW.d3_view_action_top();                                      }
    function panel_preview_3d_view_bottom()             { CALL("preview_3d_bottom_view");            PANEL_PREVIEW.d3_view_action_bottom();                                   }
    
    function panel_preview_set_zoom(zoom)               { CALL("preview_preview_set_zoom");          PANEL_PREVIEW.fullView(zoom);                                            }
    
    function panel_preview_set_tile_off()               { CALL("preview_set_tile_off");              PANEL_PREVIEW.set_tile_off();                                            }
    function panel_preview_set_tile_horizontal()        { CALL("preview_set_tile_horizontal");       PANEL_PREVIEW.set_tile_horizontal();                                     }
    function panel_preview_set_tile_vertical()          { CALL("preview_set_tile_vertical");         PANEL_PREVIEW.set_tile_vertical();                                       }
    function panel_preview_set_tile_both()              { CALL("preview_set_tile_both");             PANEL_PREVIEW.set_tile_both();                                           }
    function panel_preview_set_tile_toggle()            { CALL("preview_set_tile_toggle");           PANEL_PREVIEW.toggle_tile();                                             }
    
    function panel_preview_set_split_off()              { CALL("preview_set_split_off");             PANEL_PREVIEW.set_split_off();                                           }
    function panel_preview_set_split_horizontal()       { CALL("preview_set_split_horizontal");      PANEL_PREVIEW.set_split_horizontal();                                    }
    function panel_preview_set_split_vertical()         { CALL("preview_set_split_vertical");        PANEL_PREVIEW.set_split_vertical();                                      }
    function panel_preview_toggle_split_view()          { CALL("preview_toggle_split_view");         PANEL_PREVIEW.toggle_split_view();                                       }
    
    function panel_preview_new_preview_window()         { CALL("preview_new_preview_window");        PANEL_PREVIEW.new_preview_window();                                      }
    function panel_preview_saveCurrentFrame()           { CALL("preview_saveCurrentFrame");          PANEL_PREVIEW.saveCurrentFrame();                                        }
    function panel_preview_saveAllCurrentFrames()       { CALL("preview_saveAllCurrentFrames");      PANEL_PREVIEW.saveAllCurrentFrames();                                    }
    function panel_preview_copyCurrentFrame()           { CALL("preview_copyCurrentFrame");          PANEL_PREVIEW.copyCurrentFrame();                                        }
    function panel_preview_copy_color()                 { CALL("preview_copy_color");                PANEL_PREVIEW.copy_color();                                              }
    function panel_preview_copy_color_hex()             { CALL("preview_copy_color_hex");            PANEL_PREVIEW.copy_color_hex();                                          }
    
    function panel_preview_toggle_grid_pixel()          { CALL("preview_toggle_grid_pixel");         PROJECT.previewGrid.pixel = !PROJECT.previewGrid.pixel;                  }
    function panel_preview_toggle_grid_visible()        { CALL("preview_toggle_grid_visible");       PROJECT.previewGrid.show  = !PROJECT.previewGrid.show;                   }
    function panel_preview_toggle_grid_snap()           { CALL("preview_toggle_grid_snap");          PROJECT.previewGrid.snap  = !PROJECT.previewGrid.snap;                   }
    
    function panel_preview_onion_enabled()              { CALL("preview_onion_enabled");             PROJECT.onion_skin.enabled = !PROJECT.onion_skin.enabled;                }
    function panel_preview_onion_on_top()               { CALL("preview_onion_on_top");              PROJECT.onion_skin.on_top  = !PROJECT.onion_skin.on_top;                 }
    
    function panel_preview_set_reset_view_off()         { CALL("preview_set_reset_view_off");        PANEL_PREVIEW.set_reset_view_off();                                      }
    function panel_preview_set_reset_view_on()          { CALL("preview_set_reset_view_on");         PANEL_PREVIEW.set_reset_view_on();                                       }
    function panel_preview_toggle_reset_view()          { CALL("preview_toggle_reset_view");         PANEL_PREVIEW.toggle_reset_view();                                       }
    
    function panel_preview_toggle_lock()                { CALL("preview_toggle_lock");               PANEL_PREVIEW.toggle_lock();                                             }
    function panel_preview_toggle_mini()                { CALL("preview_toggle_mini");               PANEL_PREVIEW.toggle_mini();                                             }
    
    function __fnInit_Preview() {
    	var p = "Preview";
    	var n = MOD_KEY.none;
    	var s = MOD_KEY.shift;
    	var c = MOD_KEY.ctrl;
    	var a = MOD_KEY.alt;
    	var cs = MOD_KEY.ctrl | MOD_KEY.shift;
    	
        registerFunction(p, "Clear Tool",               vk_escape, n, panel_preview_clear_tool         )
        
        registerFunction(p, "Focus Content",            "F", n, panel_preview_focus_content            ).setMenu("preview_focus_content", THEME.icon_center_canvas)
        registerFunction(p, "Save Current Frame",       "S", s, panel_preview_save_current_frame       ).setMenu("preview_save_current_frame")
        registerFunction(p, "Save to Focused File",     "",  n, panel_preview_saveCurrentFrameToFocus  ).setMenu("preview_save_to_focused_file")
        registerFunction(p, "Save to Project",          "",  n, panel_preview_saveCurrentFrameProject  ).setMenu("preview_save_to_project")
        registerFunction(p, "Save all Current Frames",  "",  n, panel_preview_save_all_current_frame   ).setMenu("preview_save_all_current_frame")
        registerFunction(p, "Preview Window",           "P", c, panel_preview_preview_window           ).setMenu("preview_preview_window")
    
        registerFunction(p, "Pan",                      "", c,     panel_preview_pan                   ).setMenu("preview_pan")
        registerFunction(p, "Zoom",                     "", a | c, panel_preview_zoom                  ).setMenu("preview_zoom")
        
        registerFunction(p, "3D Front View",            vk_numpad1, n, panel_preview_3d_view_front     ).setMenu("preview_3d_front_view")
        registerFunction(p, "3D Back View",             vk_numpad1, a, panel_preview_3d_view_back      ).setMenu("preview_3d_back_view")
        registerFunction(p, "3D Right View",            vk_numpad3, n, panel_preview_3d_view_right     ).setMenu("preview_3d_right_view")
        registerFunction(p, "3D Left View",             vk_numpad3, a, panel_preview_3d_view_left      ).setMenu("preview_3d_left_view")
        registerFunction(p, "3D Top View",              vk_numpad7, n, panel_preview_3d_view_top       ).setMenu("preview_3d_top_view")
        registerFunction(p, "3D Bottom View",           vk_numpad7, a, panel_preview_3d_view_bottom    ).setMenu("preview_3d_bottom_view")
        
        registerFunction(p, "Scale x1",                 "1", n, function() /*=>*/ { panel_preview_set_zoom(1) }    ).setMenu("preview_scale_x1")
        registerFunction(p, "Scale x2",                 "2", n, function() /*=>*/ { panel_preview_set_zoom(2) }    ).setMenu("preview_scale_x2")
        registerFunction(p, "Scale x4",                 "3", n, function() /*=>*/ { panel_preview_set_zoom(4) }    ).setMenu("preview_scale_x4")
        registerFunction(p, "Scale x8",                 "4", n, function() /*=>*/ { panel_preview_set_zoom(8) }    ).setMenu("preview_scale_x8")
        
        registerFunction(p, "Tile Off",                 "", n, panel_preview_set_tile_off              ).setMenu("preview_set_tile_off")
        registerFunction(p, "Tile Horizontal",          "", n, panel_preview_set_tile_horizontal       ).setMenu("preview_set_tile_horizontal")
        registerFunction(p, "Tile Vertical",            "", n, panel_preview_set_tile_vertical         ).setMenu("preview_set_tile_vertical")
        registerFunction(p, "Tile Both",                "", n, panel_preview_set_tile_both             ).setMenu("preview_set_tile_both")
        registerFunction(p, "Toggle Tile",              "", n, panel_preview_set_tile_toggle           ).setMenu("preview_toggle_tile")
        registerFunction(p, "Tiling Settings",          "", n, function(_dat) /*=>*/ { submenuCall(_dat, [
                                                                                                 MENU_ITEMS.preview_set_tile_off,
                                                                                                 MENU_ITEMS.preview_set_tile_horizontal,
                                                                                                 MENU_ITEMS.preview_set_tile_vertical,
                                                                                                 MENU_ITEMS.preview_set_tile_both,
                                                                                             ]) }).setMenu("preview_tiling_settings")
        
        registerFunction(p, "Split View Off",           "", n, panel_preview_set_split_off             ).setMenu("preview_set_split_off")
        registerFunction(p, "Split View Horizontal",    "", n, panel_preview_set_split_horizontal      ).setMenu("preview_set_split_horizontal")
        registerFunction(p, "Split View Vertical",      "", n, panel_preview_set_split_vertical        ).setMenu("preview_set_split_vertical")
        registerFunction(p, "Toggle Split View",        "", n, panel_preview_toggle_split_view         ).setMenu("preview_toggle_split_view")
        registerFunction(p, "Split View Settings",      "", n, function(_dat) /*=>*/ { submenuCall(_dat, [
                                                                                                 MENU_ITEMS.preview_set_split_off,
                                                                                                 MENU_ITEMS.preview_set_split_horizontal,
                                                                                                 MENU_ITEMS.preview_set_split_vertical,
                                                                                             ]) }).setMenu("preview_split_view_settings")
                                                                                                        
        registerFunction(p, "Set Reset View Off",       "", n, panel_preview_set_reset_view_off        ).setMenu("preview_set_reset_view_off")
        registerFunction(p, "Set Reset View On",        "", n, panel_preview_set_reset_view_on         ).setMenu("preview_set_reset_view_on")
        registerFunction(p, "Toggle Reset View",        "", n, panel_preview_toggle_reset_view         ).setMenu("preview_toggle_reset_view")
        
        registerFunction(p, "New Preview Window",       "", n, panel_preview_new_preview_window        ).setMenu("preview_new_preview_window")
        registerFunction(p, "Save Current Frame",       "", n, panel_preview_saveCurrentFrame          ).setMenu("preview_save_current_frame")
        registerFunction(p, "Save All Current Frames",  "", n, panel_preview_saveAllCurrentFrames      ).setMenu("preview_save_all_current_frames")
        registerFunction(p, "Copy Current Frame",       "", n, panel_preview_copyCurrentFrame          ).setMenu("preview_copy_current_frame", THEME.copy)
        registerFunction(p, "Copy Color",               "", n, panel_preview_copy_color                ).setMenu("preview_copy_color")
        registerFunction(p, "Copy Color Hex",           "", n, panel_preview_copy_color_hex            ).setMenu("preview_copy_color_hex")
        
        registerFunction(p, "Toggle Grid",              "G", c,  panel_preview_toggle_grid_visible     ).setMenu("preview_toggle_grid_visible")
        registerFunction(p, "Toggle Pixel Grid",        "G", cs, panel_preview_toggle_grid_pixel       ).setMenu("preview_toggle_grid_pixel")
        registerFunction(p, "Toggle Snap to Grid",      "",  n,  panel_preview_toggle_grid_snap        ).setMenu("preview_toggle_grid_snap")
        
        registerFunction(p, "Toggle Onion Skin",        "", n, panel_preview_onion_enabled             ).setMenu("preview_onion_enabled")
        registerFunction(p, "Toggle Onion Skin view",   "", n, panel_preview_onion_on_top              ).setMenu("preview_onion_on_top")
        registerFunction(p, "Toggle Lock",              "", n, panel_preview_toggle_lock               ).setMenu("preview_toggle_lock")
        registerFunction(p, "Toggle Minimap",           "", n, panel_preview_toggle_mini               ).setMenu("preview_toggle_mini")
        
        registerFunction(p, "Popup",            		"", n, function() /*=>*/ { create_preview_window(PANEL_PREVIEW.getNodePreview());           }).setMenu("preview_popup")
        registerFunction(p, "Grid Settings",            "", n, function() /*=>*/ { dialogPanelCall(new Panel_Preview_Grid_Setting())                }).setMenu("preview_grid_settings")
        registerFunction(p, "Onion Skin Settings",      "", n, function() /*=>*/ { dialogPanelCall(new Panel_Preview_Onion_Setting())               }).setMenu("preview_onion_settings")
        registerFunction(p, "3D View Settings",         "", n, function() /*=>*/ { dialogPanelCall(new Panel_Preview_3D_Setting(PANEL_PREVIEW))     }).setMenu("preview_3D_settings")
        registerFunction(p, "3D SDF View Settings",     "", n, function() /*=>*/ { dialogPanelCall(new Panel_Preview_3D_SDF_Setting(PANEL_PREVIEW)) }).setMenu("preview_3D_SDF_settings")
        registerFunction(p, "3D Snap Settings",         "", n, function() /*=>*/ { dialogPanelCall(new Panel_Preview_Snap_Setting(PANEL_PREVIEW))   }).setMenu("preview_snap_settings")
        registerFunction(p, "View Settings",            "", n, function() /*=>*/ { dialogPanelCall(new Panel_Preview_View_Setting(PANEL_PREVIEW))   }).setMenu("preview_view_settings")
        
        __fnGroupInit_Preview();
    }
    
    function __fnGroupInit_Preview() {
        MENU_ITEMS.preview_group_preview_bg = menuItemGroup(__txtx("panel_menu_preview_background", "Preview background"), [
            [ s_preview_transparent, function() /*=>*/ { PANEL_PREVIEW.canvas_bg = -1;      } ],
            [ s_preview_white,       function() /*=>*/ { PANEL_PREVIEW.canvas_bg = c_white; } ],
            [ s_preview_black,       function() /*=>*/ { PANEL_PREVIEW.canvas_bg = c_black; } ],
        ], ["Preview", "Background"]);
        registerFunction("Preview", "Background",               "",  MOD_KEY.none,                   function() /*=>*/ { menuCall("", [ MENU_ITEMS.menu_group_preview_bg ]); });
        
    }
#endregion

function Panel_Preview() : PanelContent() constructor {
    title = __txt("Preview");
    context_str = "Preview";
    icon  = THEME.panel_preview_icon;
    
    last_focus = noone;
    
    #region ---- canvas control & sample ----
        function initSize() { canvas_x = w / 2; canvas_y = h / 2; }
        run_in(1, function() /*=>*/ { initSize() });
        
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
    
    #region ---- preview ----
        locked              = false;
        preview_node        = [ noone, noone ];
        preview_surfaces    = [ 0, 0 ];
        preview_junction    = noone;
        tile_surface        = surface_create(1, 1);
        
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
        
        mouse_pos_string    = "";
        
        resetViewOnDoubleClick = true;
        
        tb_zoom_level = new textBox(TEXTBOX_INPUT.number, function(z) /*=>*/ { 
        	var _s = canvas_s;
        	canvas_s = clamp(z, 0.10, 64); 
        	
            if(_s != canvas_s) {
                var dx = (canvas_s - _s) * ((w / 2 - canvas_x) / _s);
                var dy = (canvas_s - _s) * ((h / 2 - canvas_y) / _s);
                canvas_x -= dx;
                canvas_y -= dy;
            }
        });
        tb_zoom_level.color  = c_white;
        tb_zoom_level.align  = fa_right;
        tb_zoom_level.hide   = 3;
        tb_zoom_level.font   = f_p2;
        
	    tb_framerate = new textBox(TEXTBOX_INPUT.number, function(val) { preview_rate = real(val); });
	    
	    tooltip_action      = "";
        tooltip_action_time = 0;
    #endregion
    
    #region ---- tool ----
        tool_x              = 0;
        tool_x_to           = 0;
        tool_x_max          = 0;
        
        tool_y              = 0;
        tool_y_to           = 0;
        tool_y_max          = 0;
        
        tool_ry             = 0;
        tool_ry_to          = 0;
        tool_ry_max         = 0;
        
        tool_current        = noone;
        
        toolbar_width       = ui(40);
        toolbar_height      = ui(40);
        
        tool_hovering       = noone;
        tool_side_draw_l    = false;
        tool_side_draw_r    = false;
        overlay_hovering    = false;
        view_hovering       = false;
        
        tool_show_key       = false;
        _tool_show_key      = false;
        tool_clearable      = false;
        tool_clearKey       = FUNCTIONS[$ string_to_var2("Preview", "Clear tool")];
        
        hk_editing          = noone;
        
        sbChannel = new scrollBox([], function(index) {
            var node = __getNodePreview();
            if(node == noone) return;
            
            var _ind = array_safe_get(sbChannelIndex, index, -1);
            if(_ind == -1) return;
            
            node.preview_channel = _ind; 
            node.setHeight();
        });
        
        sbChannelIndex  = [];
        sbChannel.font  = f_p1;
        sbChannel.align = fa_left;
    #endregion
    
    #region ---- 3d ----
        d3_active            = NODE_3D.none;
        d3_active_transition = 0;
        
        d3_surface           = noone;
        d3_surface_normal    = noone;
        d3_surface_depth     = noone;
        d3_surface_outline   = noone;
        d3_surface_bg        = noone;
        d3_preview_channel   = 0;
        
        d3_deferData         = noone;
        d3_drawBG            = false;
        
        global.SKY_SPHERE    = new __3dUVSphere(0.5, 16, 8, true);
        
        #region camera
            d3_view_camera   = new __3dCamera();
            d3_camW          = 1;
            d3_camH          = 1;
        
            d3_view_camera.setFocusAngle(135, 45, 4);
            d3_camLerp       = 0;
            d3_camLerp_x     = 0;
            d3_camLerp_y     = 0;
    
            d3_camTarget     = new __vec3();
        
            d3_camPanning    = false;
            d3_camPan_mx     = 0;
            d3_camPan_my     = 0;
            
            d3_zoom_speed    = 0.2;
            d3_pan_speed     = 2;
        #endregion
        
        #region scene
            d3_scene               = new __3dScene(d3_view_camera, "Preview panel");
            d3_scene.lightAmbient  = $404040;
            d3_scene.cull_mode     = cull_counterclockwise;
            d3_scene_preview       = d3_scene;
            
            d3_scene_light_enabled = true;
            
            d3_scene_light0        = new __3dLightDirectional();
            d3_scene_light0.color  = $FFFFFF;
            d3_scene_light0.shadow_active    = false;
            d3_scene_light0.shadow_map_scale = 4;
            d3_scene_light0.transform.position.set(-1, -2, 3);
            
            d3_scene_light1        = new __3dLightDirectional();
            d3_scene_light1.color  = $505050;
            d3_scene_light1.transform.position.set(1, 2, -3);
        #endregion
        
    #endregion
    
    #region // ---- minimap ----
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
    
    #region ++++ toolbars & actions ++++
        static set_tile_off        = function() /*=>*/ { tileMode = 0; }
        static set_tile_horizontal = function() /*=>*/ { tileMode = 1; }
        static set_tile_vertical   = function() /*=>*/ { tileMode = 2; }
        static set_tile_both       = function() /*=>*/ { tileMode = 3; }
        static toggle_tile         = function() /*=>*/ { tileMode = (tileMode + 1) % 4; }
        
        static new_preview_window  = function() /*=>*/ { create_preview_window(getNodePreview()); } 
        static copy_color          = function() /*=>*/ { clipboard_set_text(sample_color); }
        static copy_color_hex      = function() /*=>*/ { clipboard_set_text(color_get_hex(sample_color)); }
        
        static set_reset_view_off  = function() /*=>*/ { resetViewOnDoubleClick = 0; } 
        static set_reset_view_on   = function() /*=>*/ { resetViewOnDoubleClick = 1; } 
        static toggle_reset_view   = function() /*=>*/ { resetViewOnDoubleClick = !resetViewOnDoubleClick; } 
        
        static set_split_off       = function() /*=>*/ { splitView = 0; }
        static set_split_horizontal= function() /*=>*/ { splitView = 1; }
        static set_split_vertical  = function() /*=>*/ { splitView = 2; }
        static toggle_split_view   = function() /*=>*/ { splitView = (splitView + 1) % 3; }
        
        static toggle_lock         = function() /*=>*/ { locked = !locked }
        static toggle_mini         = function() /*=>*/ { minimap_show = !minimap_show; }
        
        hk_editing   = noone;
        hk_selecting = noone;
        
        topbar_height  = ui(32);
        toolbar_height = ui(40);
        toolbars = [
        	new panel_toolbar_icon("On preview", 
                THEME.icon_reset_when_preview,
                function() /*=>*/ {return !resetViewOnDoubleClick},
                new tooltipSelector(__txtx("panel_preview_on_preview", "On preview"), [ __txt("Center view"), __txt("Keep view") ]), 
                toggle_reset_view,
                function(data) /*=>*/ {
                    menuCall("preview_reset_view_menu", [
                        MENU_ITEMS.preview_set_reset_view_off,
                        MENU_ITEMS.preview_set_reset_view_on,
                    ], data.x + ui(28), data.y + ui(28));
                },
            ).setWheelFn(toggle_reset_view, toggle_reset_view),
            
            new panel_toolbar_icon("Split view", 
                THEME.icon_split_view,
                function() /*=>*/ {return splitView},
                new tooltipSelector(__txt("Split view"), [ __txt("Off"), __txt("Horizontal"), __txt("Vertical"), ]),
                toggle_split_view,
                function(data) /*=>*/ {
                    menuCall("preview_split_menu", [
                        MENU_ITEMS.preview_set_split_off,
                        MENU_ITEMS.preview_set_split_horizontal,
                        MENU_ITEMS.preview_set_split_vertical,
                    ], data.x + ui(28), data.y + ui(28));
                },
            ).setWheelFn(function() /*=>*/ { mod_dec_mf0 splitView mod_dec_mf1 splitView mod_dec_mf2  3 mod_dec_mf3  3 mod_dec_mf4 }, function() /*=>*/ { mod_inc_mf0 splitView mod_inc_mf1 splitView mod_inc_mf2  3 mod_inc_mf3 }),
            
            new panel_toolbar_icon("Tiling", 
                THEME.icon_tile_view,
                function() /*=>*/ {return tileMode},
                new tooltipSelector(__txt("Tiling"), [ __txt("Off"), __txt("Horizontal"), __txt("Vertical"), __txt("Both") ]),
                toggle_tile, 
                function(data) /*=>*/ { 
                    menuCall("preview_tile_menu", [
                        MENU_ITEMS.preview_set_tile_off,
                        MENU_ITEMS.preview_set_tile_horizontal,
                        MENU_ITEMS.preview_set_tile_vertical,
                        MENU_ITEMS.preview_set_tile_both,
                    ], data.x + ui(28), data.y + ui(28));
                },
            ).setWheelFn(function() /*=>*/ { mod_dec_mf0 tileMode mod_dec_mf1 tileMode mod_dec_mf2  4 mod_dec_mf3  4 mod_dec_mf4 }, function() /*=>*/ { mod_inc_mf0 tileMode mod_inc_mf1 tileMode mod_inc_mf2  4 mod_inc_mf3 }),
            
            new panel_toolbar_icon("Grid",  
                THEME.icon_grid_setting,
                function() /*=>*/ {return 0},
                function() /*=>*/ {return new tooltipHotkey(__txtx("grid_title", "Grid settings") + "...", "Preview", "Grid Settings")}, 
                function(data) /*=>*/ { dialogPanelCall(new Panel_Preview_Grid_Setting(), 
                									x + ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.left }); }, 
            ).setHotkey("Preview", "Grid Settings"),
            
            new panel_toolbar_icon("Onion Skin",   
                THEME.onion_skin,
                function() /*=>*/ {return 0},
                function() /*=>*/ {return new tooltipHotkey(__txt("Onion Skin") + "...", "Preview", "Onion Skin Settings")}, 
                function(data) /*=>*/ { dialogPanelCall(new Panel_Preview_Onion_Setting(), 
                									x + ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.left }); }, 
            ).setHotkey("Preview", "Onion Skin Settings"),
        ];
    
        toolbars_3d = [
            new panel_toolbar_icon("3D Preview Settings",  
                THEME.d3d_preview_settings,
                function() /*=>*/ {return 0},
                function() /*=>*/ {return new tooltipHotkey(__txt("3D Preview Settings") + "...", "Preview", "3D View Settings")},
                function(data) /*=>*/ { dialogPanelCall(new Panel_Preview_3D_Setting(), 
                									x - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.left }); }, 
            ).setHotkey("Preview", "3D View Settings"),
            
            new panel_toolbar_icon("3D Snap Settings",
                THEME.d3d_snap_settings,
                function() /*=>*/ {return 0},
                function() /*=>*/ {return new tooltipHotkey(__txt("3D Snap Settings") + "...", "Preview", "3D Snap Settings")},
                function(data) /*=>*/ { dialogPanelCall(new Panel_Preview_Snap_Setting(), 
                									x - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.left }); }, 
            ).setHotkey("Preview", "3D Snap Settings"),
        ];
        
        toolbars_3d_sdf = [
            new panel_toolbar_icon("SDF Preview",
                THEME.d3d_preview_settings,
                function() /*=>*/ {return 0},
                function() /*=>*/ {return new tooltipHotkey(__txt("3D SDF Preview Settings") + "...", "Preview", "3D SDF View Settings")},
                function(data) /*=>*/ { dialogPanelCall(new Panel_Preview_3D_SDF_Setting(), 
                									x - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.left }); }, 
            ).setHotkey("Preview", "3D SDF View Settings"),
            
            new panel_toolbar_icon("3D Snap Settings",
                THEME.d3d_snap_settings,
                function() /*=>*/ {return 0},
                function() /*=>*/ {return new tooltipHotkey(__txt("3D Snap Settings") + "...", "Preview", "3D Snap Settings")},
                function(data) /*=>*/ { dialogPanelCall(new Panel_Preview_Snap_Setting(), 
                									x - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.left }); }, 
            ).setHotkey("Preview", "3D Snap Settings"),
        ];
        
        actions = [
            new panel_toolbar_icon("Export Canvas",
                THEME.icon_preview_export,
                function() /*=>*/ {return 0},
                new tooltipHotkey(__txtx("panel_preview_export_canvas", "Export canvas"), "Preview", "Save current frame"), 
                function() /*=>*/ {return saveCurrentFrame()},
            ).setHotkey("Preview", "Save current frame"),
            
            new panel_toolbar_icon("Lock Preview",
                THEME.lock,
                function() /*=>*/ {return !locked},
                new tooltipHotkey(__txtx("panel_preview_lock_preview", "Lock previewing node"), "Preview", "Toggle Lock"), 
                toggle_lock,
            ).setHotkey("Preview", "Toggle Lock"),
            
            new panel_toolbar_icon("Center Canvas",
                THEME.icon_center_canvas,
                function() /*=>*/ {return 0},
                new tooltipHotkey(__txtx("panel_preview_center_canvas", "Center canvas"), "Preview", "Focus content"), 
                function() /*=>*/ {return fullView()},
            ).setHotkey("Preview", "Focus content"),
            
            new panel_toolbar_icon("Minimap",
                THEME.icon_minimap,
                function() /*=>*/ {return minimap_show}, 
                new tooltipHotkey(__txtx("panel_graph_toggle_minimap", "Toggle minimap"), "Preview", "Toggle Minimap"), 
                toggle_mini, 
            ).setHotkey("Preview", "Toggle Minimap"),
            
            new panel_toolbar_icon("Visibility Settings",
                THEME.icon_visibility,
                function() /*=>*/ {return 0},
                new tooltipHotkey(__txtx("graph_visibility_title", "Visibility settings") + "...", "Preview", "View Settings"), 
                function(param) /*=>*/ { dialogPanelCall(new Panel_Preview_View_Setting(self), 
                									x + w - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.right }); }, 
            ).setHotkey("Preview", "View Settings"),
            
            new panel_toolbar_icon("Popup",
                THEME.node_goto_thin,
                function() /*=>*/ {return 0},
                new tooltipHotkey(__txtx("panel_preview_windows", "Pop up as Preview window"), "Preview", "Popup"), 
                function() /*=>*/ { create_preview_window(PANEL_PREVIEW.getNodePreview()); },
            ).setHotkey("Preview", "Popup"),
        ];
        
        static d3_view_action_front  = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x =   0; d3_camLerp_y =   0; }
        static d3_view_action_back   = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x = 180; d3_camLerp_y =   0; }
        static d3_view_action_right  = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x =  90; d3_camLerp_y =   0; }
        static d3_view_action_left   = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x = -90; d3_camLerp_y =   0; }
        static d3_view_action_bottom = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x =   0; d3_camLerp_y = -89; }
        static d3_view_action_top    = function() /*=>*/ { d3_camLerp = 1; d3_camLerp_x =   0; d3_camLerp_y =  89; }
    #endregion
    
    ////- DATA
    
    function setNodePreview(_node, _lock = locked) {
        if(locked) return self;
        
        if(resetViewOnDoubleClick)
            do_fullView = true;
        
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
    
    function getNodePreviewSurface()  { return preview_surfaces[splitView? splitSelection : 0]; }
    function getNodePreviewSequence() { return preview_sequence[splitView? splitSelection : 0]; }
    
    function getPreviewData() {
    	preview_junction = noone;
    	
        var _prevNode = preview_node[0];
        if(is(_prevNode, Node) && _prevNode.active)
	        preview_junction = array_safe_get(_prevNode.outputs, _prevNode.preview_channel, noone);
        
        preview_surfaces = [ noone, noone ];
        preview_sequence = [ noone, noone ];
            
        for( var i = 0; i < 2; i++ ) {
            var node = preview_node[i];
            
            if(node == noone) continue;
            if(!node.active)  { resetNodePreview(); continue; }
            
            var value = node.getPreviewValues();
            
            if(is_array(value)) {
                preview_sequence[i] = value;
                canvas_a = array_length(value);
                
            } else {
                preview_surfaces[i] = value;
                canvas_a = 0;
            }
            
            if(preview_sequence[i] != noone) {
                if(array_length(preview_sequence[i]) == 0) return;
                preview_surfaces[i] = preview_sequence[i][safe_mod(node.preview_index, array_length(preview_sequence[i]))];
            }
        }
        
        var prevS = getNodePreviewSurface();
        
        if(is_surface(prevS)) {
            canvas_w = surface_get_width_safe(prevS);
            canvas_h = surface_get_height_safe(prevS);    
        }
    }
    
    function onFocusBegin() { PANEL_PREVIEW = self; }
    
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
            d3_view_camera.focus_angle_x = lerp_float(d3_view_camera.focus_angle_x, d3_camLerp_x, 3, 1);
            d3_view_camera.focus_angle_y = lerp_float(d3_view_camera.focus_angle_y, d3_camLerp_y, 3, 1);
            
            if(d3_view_camera.focus_angle_x == d3_camLerp_x && d3_view_camera.focus_angle_y == d3_camLerp_y)
                d3_camLerp = false;
        }
        
        if(d3_camPanning) {
            if(!MOUSE_WRAPPING) {
                var dx = mx - d3_camPan_mx;
                var dy = my - d3_camPan_my;
                
                var px = d3_view_camera.focus_angle_x;
                var py = d3_view_camera.focus_angle_y;
                var ax = px + dx * 0.2 * d3_pan_speed;
                var ay = py + dy * 0.1 * d3_pan_speed;
                
                //if(py < 90 && ay >= 90) ax -= 180;
                //if(py > 90 && ay <= 90) ax += 180;
                
                //print($"{ax},\t{ay}");
                
                d3_view_camera.focus_angle_x = ax;
                d3_view_camera.focus_angle_y = ay;
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
                d3_view_camera.focus_dist = clamp(d3_view_camera.focus_dist + dy, 1, 1000);
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
            
            if(MOUSE_WHEEL != 0) d3_view_camera.focus_dist = clamp(d3_view_camera.focus_dist * (1 - d3_zoom_speed * MOUSE_WHEEL), 1, 1000);
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
    
    static onFullScreen = function() { run_in(1, fullView); }
    
    ////- TOOL
    
    function clearTool(_bypass_clearable = false) { 
    	if(!tool_clearable && !_bypass_clearable) return;
    	if(tool_current == noone) return;
    	
    	var _tobj = tool_current.getToolObject();
		if(_tobj) _tobj.disable();
        tool_current = noone;
    }
    
    function drawTools(_node) {
    	var _mx   = mx;
        var _my   = my;
        var _tool = tool_hovering;
        var  ts   = ui(32);
        var  ts2  = ts / 2;
        
        tool_clearable = true;
        tool_hovering  = noone;
        
        if(_node.tools == -1) { tool_current = noone; return; } 
        
        var aa = d3_active? 0.8 : 1;
        draw_sprite_stretched_ext(THEME.tool_side, 0, 0, ui(32), toolbar_width, h - toolbar_height - ui(32), c_white, aa);
        
        tool_y_max = 0; 
        tool_y   = lerp_float(tool_y, tool_y_to, 5);
        var xx   = ui(1)  + toolbar_width / 2;
        var yy   = ui(34) + ts2 + tool_y;
        var pd   = 2;
        var thov = pHOVER && point_in_rectangle(mx, my, 0, toolbar_height, toolbar_width, h - toolbar_height);
        if(thov) {
        	canvas_hover = false;
        	mouse_on_preview = 0;
        }
        
        if(pFOCUS && key_mod_double(ALT)) tool_show_key = !tool_show_key;
        var __tool_show_key = _tool_show_key;
        _tool_show_key = tool_show_key;
        
        ////- Left tools
        
        for(var i = 0; i < array_length(_node.tools); i++) { 
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
            
            if(thov && point_in_rectangle(_mx, _my, _x0, _y0 + 1, _x1, _y1 - 1))
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
                    
                    if(point_in_rectangle(_mx, _my, _sx0, _sy0 + 1, _sx1, _sy1 - 1)) {
                        TOOLTIP = tool.getDisplayName(j);
                        draw_sprite_stretched(THEME.button_hide_fill, 1, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2);
                            
                        if(mouse_press(mb_left, pFOCUS))  tool.toggle(j);
                    	if(mouse_press(mb_right, pFOCUS)) tool.rightClick();
                    } 
                            
                    if(tool_current == tool && tool.selecting == j) {
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 2, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2, COLORS.panel_preview_grid, 1);
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 3, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2, COLORS._main_accent, 1);
                    }
                    
                    draw_sprite_colored(stool[j], 0, _sxx, _syy);
                }
                    
                if(point_in_rectangle(_mx, _my, _x0, _y0 + 1, _x0 + s_ww, _y1 - 1))
                    tool_hovering = tool;
            
            } else { // single tools
                if(tool_hovering == tool) {
                    draw_sprite_stretched(THEME.button_hide_fill, 1, _bx, _by, _bs, _bs);
                    TOOLTIP = tool.getDisplayName();
                    
                    if(mouse_press(mb_left, pFOCUS))  tool.toggle();
                    if(mouse_press(mb_right, pFOCUS)) tool.rightClick();
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
                if(_hkstr != "" && (key_mod_press(ALT) || __tool_show_key)) {
                	draw_set_text(f_p4, fa_right, fa_center, COLORS._main_text);
                	var _hks  = string_width(_hkstr) + ui(8);
                	var _hkx0 = _x1 - _hks;
                	var _hky0 = _y1 - ui(16);
                	
                	draw_sprite_stretched_ext(THEME.ui_panel, 0, _hkx0, _hky0, _hks, ui(16), COLORS.panel_bg_clear_inner);
                	draw_text_add(_hkx0 + _hks - ui(4), _hky0 + ui(16) / 2, _hkstr);
                }
            }
            
            if(tool == hk_editing) {
            	_tool_show_key = true;
            	draw_sprite_stretched_ext(THEME.button_hide, 3, _bx, _by, _bs, _bs, COLORS._main_accent, 1);
            	
            	if(keyboard_check_pressed(vk_enter))  hk_editing = noone;
				else hotkey_editing(tool.hk_object);
					
				if(keyboard_check_pressed(vk_escape)) hk_editing = noone;
            }
            
            yy         += ts;
            tool_y_max += ts;
        }
        
        var _h = _node.drawTools == noone? 0 : _node.drawTools(_mx, _my, xx, yy - ts2, ts, thov, pFOCUS);
        yy         += _h;
        tool_y_max += _h;
        
        tool_y_max = max(0, tool_y_max - h + toolbar_height * 2);            
        if(thov && !key_mod_press_any() && MOUSE_WHEEL != 0)
            tool_y_to = clamp(tool_y_to + ui(64) * MOUSE_WHEEL, -tool_y_max, 0);
        
        ////- Right tools
        
        if(_node.rightTools == -1) return;
        
        right_menu_x = w - toolbar_width - ui(8);
        tool_ry_max  = 0; 
        tool_ry      = lerp_float(tool_ry, tool_ry_to, 5);
        
        var _tbx = w - toolbar_width;
        var xx   = _tbx + toolbar_width / 2;
        var yy   = ui(34) + ts  / 2 + tool_ry;
        
        draw_sprite_stretched_ext(THEME.tool_side, 1, w + 1 - toolbar_width, ui(32), toolbar_width, h - toolbar_height - ui(32), c_white, aa);
        
        var thov = pHOVER && point_in_rectangle(mx, my, _tbx, toolbar_height, w, h - toolbar_height);
        if(thov) {
        	canvas_hover = false;
        	mouse_on_preview = 0;
        }
        
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
            
            if(thov && point_in_rectangle(_mx, _my, _x0, _y0 + 1, _x1, _y1 - 1))
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
                    
                    if(point_in_rectangle(_mx, _my, _sx0, _sy0 + 1, _sx1, _sy1 - 1)) {
                        TOOLTIP = tool.getDisplayName(_sind);
                        draw_sprite_stretched(THEME.button_hide_fill, 1, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2);
                        
                        if(mouse_press(mb_left, pFOCUS))  tool.toggle(_sind);
                    	if(mouse_press(mb_right, pFOCUS)) tool.rightClick();
                    }
                        
                    if(tool_current == tool && tool.selecting == _sind) {
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 2, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2, COLORS.panel_preview_grid, 1);
                        draw_sprite_stretched_ext(THEME.button_hide_fill, 3, _sx0 + pd, _sy0 + pd, ts - pd * 2, ts - pd * 2, COLORS._main_accent, 1);
                    }
                    
                    draw_sprite_colored(stool[_sind], 0, _sxx, _syy);
                    
                }
                
                if(point_in_rectangle(_mx, _my, tx, _y0 + 1, tx + s_ww, _y1 - 1))
                    tool_hovering = tool;
            
            } else { // single tools
                if(tool_hovering == tool) {
                    draw_sprite_stretched(THEME.button_hide_fill, 1, _bx, _by, _bs, _bs);
                    TOOLTIP = tool.getDisplayName();
                	
                    if(mouse_press(mb_left, pFOCUS))  tool.toggle();
                    if(mouse_press(mb_right, pFOCUS)) tool.rightClick();
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
                if(_hkstr != "" && (key_mod_press(ALT) || __tool_show_key)) {
                	draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
                	var _hks  = string_width(_hkstr) + ui(8);
                	var _hkx0 = _x0;
                	var _hky0 = _y1 - ui(16);
                	
                	draw_sprite_stretched_ext(THEME.ui_panel, 0, _hkx0, _hky0, _hks, ui(16), COLORS.panel_bg_clear_inner);
                	draw_text_add(_hkx0 + ui(4), _hky0 + ui(16) / 2, _hkstr);
                }
            }
            
            if(tool == hk_editing) {
            	_tool_show_key = true;
            	draw_sprite_stretched_ext(THEME.button_hide, 3, _bx, _by, _bs, _bs, COLORS._main_accent, 1);
            	
            	if(keyboard_check_pressed(vk_enter))  hk_editing = noone;
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
    	if(tool_current == noone) return;
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
        
        var fr = CURRENT_FRAME;
        var st = min(_rang[0], _rang[1]);
        var ed = max(_rang[0], _rang[1]);
            
        st = sign(st) * floor(abs(st) / _step) * _step;
        ed = sign(ed) * floor(abs(ed) / _step) * _step;
            
        st += fr;
        ed += fr;
        
        var surf, aa, cc;
            
        if(!_top) {
            draw_surface_ext_safe(_surf, psx, psy, ss, ss);
            BLEND_ADD
        }
        
        for( var i = st; i <= ed; i += _step ) {
            surf = node.getCacheFrame(i);
            if(!is_surface(surf)) continue;
                
            aa = power(_alph, abs((i - fr) / _step));
            cc = c_white;
            if(i < fr)        cc = _colr[0];
            else if(i > fr) cc = _colr[1];
                
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
        
        preview_surface_width  = 0;
    	preview_surface_height = 0;
        
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
                        else                           draw_surface_ext(preview_surfaces[0], psx, psy, ss, ss, 0, c_white, preview_node[0].preview_alpha); 
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
        #endregion
        
        if(!instance_exists(o_dialog_menubox)) { // color sample
            sample_color_raw = noone;
            sample_color     = noone;
            sample_x         = noone;
            sample_y         = noone;
        
            if(mouse_on_preview && (mouse_press(mb_right) || key_mod_press(CTRL))) {
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
        
        d3_scene_preview = struct_has(_node, "scene")? _node.scene : d3_scene;
        d3_scene_preview.camera = d3_view_camera;
        
        #region view
            var _pos, targ, _blend = 1;
            
            targ = d3_camTarget;
            _pos = d3d_PolarToCart(targ.x, targ.y, targ.z, d3_view_camera.focus_angle_x, d3_view_camera.focus_angle_y, d3_view_camera.focus_dist);
            
            if(d3_active_transition == 1) {
                var _up  = new __vec3(0, 0, -1);
                
                d3_view_camera.position._lerp_float(_pos, 5, 0.1);
                d3_view_camera.focus._lerp_float(   targ, 5, 0.1);
                d3_view_camera.up._lerp_float(       _up, 5, 0.1);
                
                if(d3_view_camera.position.equal(_pos) && d3_view_camera.focus.equal(targ))
                    d3_active_transition = 0;
            } else if(d3_active_transition == -1) {
                var _pos = new __vec3(0, 0, 8);
                var targ = new __vec3(0, 0, 0);
                var _up  = new __vec3(0, 1, 0);
                
                d3_view_camera.position._lerp_float(_pos, 5, 0.1);
                d3_view_camera.focus._lerp_float(   targ, 5, 0.1);
                d3_view_camera.up._lerp_float(       _up, 5, 0.1);
                
                _blend = d3_view_camera.position.distance(_pos) / 2;
                _blend = clamp(_blend, 0, 1);
                
                if(d3_view_camera.position.equal(_pos) && d3_view_camera.focus.equal(targ))
                    d3_active_transition = 0;
            } else {
                d3_view_camera.position.set(_pos);
                d3_view_camera.focus.set(targ);
            }
            
            d3_view_camera.setViewSize(w, h);
            d3_view_camera.setMatrix();
        #endregion
        
        #region background
            surface_free_safe(d3_surface_bg);
            
            if(d3_scene_preview != d3_scene)
                d3_surface_bg = d3_scene_preview.renderBackground(w, h);
        #endregion
     
        #region shadow
            if(d3_scene_preview == d3_scene) {
                d3_scene_light0.shadow_map_scale = d3_view_camera.focus_dist * 2;
                
                var _prev_obj = _node.getPreviewObject();
                if(_prev_obj != noone) {
                    d3_scene_light0.submitShadow(d3_scene_preview, _prev_obj);
                    _prev_obj.submitShadow(d3_scene_preview, _prev_obj);
                }
            }
        #endregion
        
        d3_surface           = surface_verify(d3_surface, w, h);
        d3_surface_normal  = surface_verify(d3_surface_normal, w, h);
        d3_surface_depth   = surface_verify(d3_surface_depth, w, h);
        d3_surface_outline = surface_verify(d3_surface_outline, w, h);
        
        #region defer
            var _prev_obj = _node.getPreviewObject();
            if(_prev_obj) d3_deferData  = d3_scene_preview.deferPass(_prev_obj, w, h, d3_deferData);
        #endregion
        
        #region grid
            surface_set_target_ext(0, d3_surface);
            surface_set_target_ext(1, d3_surface_normal);
            surface_set_target_ext(2, d3_surface_depth);
            
            draw_clear_alpha(bg_color, 0);
            
            d3_view_camera.applyCamera();
            
            gpu_set_ztestenable(true);
            gpu_set_zwriteenable(false);
            
            if(OS != os_macosx) {
                gpu_set_cullmode(cull_noculling); 
                
                shader_set(sh_d3d_grid_view);
                    var _dist = round(d3_view_camera.focus.distance(d3_view_camera.position));
                    var _tx   = round(d3_view_camera.focus.x);
                    var _ty   = round(d3_view_camera.focus.y);
                
                    var _scale = _dist * 2;
                    while(_scale > 32) _scale /= 2;
                    
                    shader_set_f("axisBlend", _blend);
                    shader_set_f("scale", _scale);
                    shader_set_f("shift", _tx / _dist / 2, _ty / _dist / 2);
                    draw_sprite_stretched(s_fx_pixel, 0, _tx - _dist, _ty - _dist, _dist * 2, _dist * 2);
                shader_reset();
            }
            
            gpu_set_zwriteenable(true);
        #endregion
        
        #region draw
            d3_scene_preview.reset();
            gpu_set_cullmode(d3_scene_preview.cull_mode); 
            
            var _prev_obj = _node.getPreviewObjects();
            
            if(d3_scene_preview == d3_scene) {
                if(d3_scene_light_enabled) {
                    d3_scene_preview.addLightDirectional(d3_scene_light0);
                    d3_scene_preview.addLightDirectional(d3_scene_light1);
                }
            }
            
            for( var i = 0, n = array_length(_prev_obj); i < n; i++ ) {
                var _prev = _prev_obj[i];
                if(_prev == noone) continue;
                 
                _prev.submitShader(d3_scene_preview);
            }
                
            d3_scene_preview.apply(d3_deferData);
            
            for( var i = 0, n = array_length(_prev_obj); i < n; i++ ) {
                var _prev = _prev_obj[i];
                if(_prev == noone) continue;
                
                _prev.submitUI(d3_scene_preview);
            }
            
            gpu_set_cullmode(cull_noculling); 
            surface_reset_target();
            
            draw_clear(bg_color);
            
            switch(d3_preview_channel) {
                case 0 : 
                    if(d3_scene_preview.draw_background)
                        draw_surface_safe(d3_surface_bg);    
                    
                    draw_surface_safe(d3_surface);
                    
                    if(is_struct(d3_deferData)) {
                        BLEND_MULTIPLY
                        draw_surface_safe(d3_deferData.ssao);
                        BLEND_NORMAL
                    }
                    break;
                case 1 : draw_surface_safe(d3_surface_normal);    break;
                case 2 : draw_surface_safe(d3_surface_depth);    break;
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
        d3_scene_preview.camera = d3_view_camera;
        
        #region view
            d3_view_camera.fov = max(1, _env.fov * 1.23);
            var _pos, targ, _blend = 1;
            
            targ = d3_camTarget;
            _pos = d3d_PolarToCart(targ.x, targ.y, targ.z, d3_view_camera.focus_angle_x, d3_view_camera.focus_angle_y, d3_view_camera.focus_dist);
            
            if(d3_active_transition == 1) {
                var _up  = new __vec3(0, 0, -1);
                
                d3_view_camera.position._lerp_float(_pos, 5, 0.1);
                d3_view_camera.focus._lerp_float(   targ, 5, 0.1);
                d3_view_camera.up._lerp_float(       _up, 5, 0.1);
                
                if(d3_view_camera.position.equal(_pos) && d3_view_camera.focus.equal(targ))
                    d3_active_transition = 0;
            } else if(d3_active_transition == -1) {
                var _pos = new __vec3(0, 0, 8);
                var targ = new __vec3(0, 0, 0);
                var _up  = new __vec3(0, 1, 0);
                
                d3_view_camera.position._lerp_float(_pos, 5, 0.1);
                d3_view_camera.focus._lerp_float(   targ, 5, 0.1);
                d3_view_camera.up._lerp_float(       _up, 5, 0.1);
                
                _blend = d3_view_camera.position.distance(_pos) / 2;
                _blend = clamp(_blend, 0, 1);
                
                if(d3_view_camera.position.equal(_pos) && d3_view_camera.focus.equal(targ))
                    d3_active_transition = 0;
            } else {
                d3_view_camera.position.set(_pos);
                d3_view_camera.focus.set(targ);
            }
            
            d3_view_camera.setViewSize(w, h);
            d3_view_camera.setMatrix();
        #endregion
        
        draw_clear(bg_color);
            
        gpu_set_texfilter(true);
        shader_set(sh_rm_primitive);
            var zm = 4 / d3_view_camera.focus_dist;
            
            shader_set_f("camRotation", [ d3_view_camera.focus_angle_y, -d3_view_camera.focus_angle_x, 0 ]);
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
            shader_set_f("viewRange",   [ d3_view_camera.view_near, d3_view_camera.view_far ]);
            
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
        right_menu_y = toolbar_height - ui(4);
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
            
                var _cur_frame = CURRENT_FRAME + 1;
                draw_set_color(frac(_cur_frame) == 0? COLORS._main_text_sub : COLORS._main_value_negative);
                draw_text(right_menu_x, right_menu_y, $"{__txt("Frame")} {_cur_frame}/{TOTAL_FRAMES}");
            
                if(d3_active == NODE_3D.none) {
                    right_menu_y += _lh;
                    
                    var _zmsl = tb_zoom_level.selecting || tb_zoom_level.hovering || tb_zoom_level.sliding;
                    var _zms  = $"x{canvas_s}";
                    var _zmw  = string_width(_zms) + ui(16);
                    var _zmx  = right_menu_x + ui(8);
                    var _zmc  = _zmsl? COLORS._main_text : COLORS._main_text_sub;
                    if(tb_zoom_level.hovering) mouse_on_preview = false;
                    
                    if(_zmsl) draw_sprite_stretched(THEME.textbox, 3, _zmx - _zmw + ui(4), right_menu_y + ui(2), _zmw - ui(10), _lh - ui(2));
                    
                    tb_zoom_level.rx = x;
                    tb_zoom_level.ry = y;
                    tb_zoom_level.setFocusHover(pFOCUS, pHOVER);
                    tb_zoom_level.postBlend = _zmc;
                    tb_zoom_level.draw(_zmx, right_menu_y, _zmw, _lh, string(canvas_s), [ mx, my ], fa_right);
                    
                	draw_set_text(f_p2, fa_right, fa_top, _zmc);
                    if(!tb_zoom_level.selecting && !tb_zoom_level.sliding)
	                	draw_text(_zmx - _zmw + ui(14), right_menu_y + ui(1), "x");
                    
                	draw_set_color(COLORS._main_text_sub);
                	
                    if(pHOVER) {
                        right_menu_y += _lh;
                        var mpx = floor((mx - canvas_x) / canvas_s);
                        var mpy = floor((my - canvas_y) / canvas_s);
                        draw_text(right_menu_x, right_menu_y, $"[{mpx}, {mpy}]");
                        
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
        
        var pseq = getNodePreviewSequence();
        if(pseq == noone) return;
        
        if(!array_equals(pseq, _preview_sequence)) {
            _preview_sequence = pseq;
            preview_x    = 0;
            preview_x_to = 0;
        }
        
        var prev_size = ui(48);
        preview_x = lerp_float(preview_x, preview_x_to, 4);
            
        if(pHOVER && my > h - toolbar_height - prev_size - ui(16) && my > toolbar_height) {
            canvas_hover = false;
            
            if(MOUSE_WHEEL != 0 && !key_mod_press_any()) 
            	preview_x_to = clamp(preview_x_to + prev_size * MOUSE_WHEEL, - preview_x_max, 0);
        }
        
        #region surface array
            preview_x_max = 0;
            
            if(mouse_release(mb_left)) preview_selecting = false;
            
            if(array_length(pseq) > 1) {
                var _xx = tool_side_draw_l * ui(40);
                var xx  = _xx + preview_x + ui(8);
                var yy  = h - toolbar_height - prev_size - ui(8);
            
                if(my > yy - 8) mouse_on_preview = 0;
                var hoverable = pHOVER && point_in_rectangle(mx, my, _xx, ui(32), w, h - toolbar_height);
            
                for(var i = 0; i < array_length(pseq); i++) {
                    var prev   = pseq[i];
                    if(is_instanceof(prev, __d3dMaterial))
                        prev = prev.surface;
                    if(!is_surface(prev)) continue;
                
                    var prev_w  = surface_get_width_safe(prev);
                    var prev_h  = surface_get_height_safe(prev);
                    var ss      = prev_size / max(prev_w, prev_h);
                    var prev_sw = prev_w * ss;
            		var _hov    = hoverable && point_in_rectangle(mx, my, xx, yy, xx + prev_sw, yy + prev_h * ss);
            		
                    draw_set_color(COLORS.panel_preview_surface_outline);
                    draw_rectangle(xx, yy, xx + prev_w * ss, yy + prev_h * ss, true);
                	draw_surface_ext_safe(prev, xx, yy, ss, ss, 0, c_white, .5 + .5 * _hov);
                	
                    if((_hov && mouse_press(mb_left, pFOCUS)) || (preview_selecting && mx > xx && mx <= xx + prev_sw)) {
                        _node.preview_index = i;
                        _node.onValueUpdate(0);
                        if(resetViewOnDoubleClick) do_fullView = true;
                        
                        preview_selecting = true;
                    }
                
                    if(i == _node.preview_index) {
                        draw_set_color(COLORS._main_accent);
                        draw_rectangle(xx, yy, xx + prev_sw, yy + prev_h * ss, true);
                    }
            
                    xx += prev_sw + ui(8);
                    preview_x_max += prev_sw + ui(8);
                }
            }
        #endregion
        
        preview_x_max = max(preview_x_max - ui(100), 0);
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
            
            var _qview = new BBMOD_Quaternion().FromEuler(d3_view_camera.focus_angle_y, -d3_view_camera.focus_angle_x, 0);
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
        
        var overActive = active && overHover;
        var params = { w, h, toolbar_height };
        params.panel = self;
        
        var _nlist = PANEL_GRAPH.nodes_list;
        if(!CAPTURING)
        for( var i = 0, n = array_length(_nlist); i < n; i++ ) {
        	var _n = _nlist[i];
        	if(!is(_n, Node))     continue;
        	if(!_n.isGizmoGlobal) continue;
        	
        	var _h = _n.doDrawOverlay(overHover, overActive, cx, cy, canvas_s, _mx, _my, _snx, _sny, params);
        	
        	if(_h == true) {
        		overHover = false;
        		overActive = false;
        	}
        }
    }
    
    function drawNodeActions(active, _node) {
        var _mx = mx;
        var _my = my;
        var overHover = pHOVER && mouse_on_preview == 1;
        
        var cx = canvas_x + _node.preview_x * canvas_s;
        var cy = canvas_y + _node.preview_y * canvas_s;
        var _snx = 0, _sny = 0;
        
        tool_side_draw_l = _node.tools != -1;
        tool_side_draw_r = _node.rightTools != -1;
        
        if(_node.tools != -1 && point_in_rectangle(_mx, _my, 0, 0, toolbar_width, h))
            overHover = false;
        
        overhover = overHover && !view_hovering;
        overhover = overHover && tool_hovering == noone && !overlay_hovering;
        overhover = overHover && !canvas_dragging && !canvas_zooming;
        overhover = overHover && point_in_rectangle(mx, my, (_node.tools != -1) * toolbar_width, toolbar_height, w, h - toolbar_height);
        
        var overActive = active && overHover;
        var params = { w, h, toolbar_height };
        params.panel = self;
        
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
            
            if(!CAPTURING) _node.doDrawOverlay(overHover, overActive, _ovx, _ovy, _ovs, _mx, _my, _snx, _sny, params);
            
        } else {
            if(key_mod_press(CTRL) || PROJECT.previewSetting.d3_tool_snap) {
                _snx = PROJECT.previewSetting.d3_tool_snap_position;
                _sny = PROJECT.previewSetting.d3_tool_snap_rotation;
            }
            
            if(!CAPTURING) _node.drawOverlay3D(overActive, d3_scene, _mx, _my, _snx, _sny, params);
        }
        
        overlay_hovering = false;
        
        if(_node.drawPreviewToolOverlay(pHOVER, pFOCUS, _mx, _my, { x, y, w, h, toolbar_height, 
            x0: _node.tools == -1? 0 : ui(40),
            x1: w,
            y0: toolbar_height - ui(8), 
            y1: h - toolbar_height 
        })) {
            canvas_hover     = false;
            overlay_hovering = true;
        }
        
        drawTools(_node);
    }
    
    function drawToolBar(_node) {
        var ty = h - toolbar_height;
        var aa = d3_active? 0.8 : 1;
        draw_sprite_stretched_ext(THEME.toolbar, 1, 0,  0, w, topbar_height, c_white, aa);
        draw_sprite_stretched_ext(THEME.toolbar, 0, 0, ty, w, toolbar_height, c_white, aa);
        
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
            
        } else if(_node) // tool settings
            drawToolSettings(_node);
        
        sample_data = noone;
        
        var tbx = toolbar_height / 2;
        var tby = ty + toolbar_height / 2;
        var _m  = [ mx, my ];
        
        var toolbar_left = 0;
        var _toolbars    = toolbars;
        
        switch(d3_active) {
            case NODE_3D.none :     _toolbars = toolbars;        break;
            case NODE_3D.polygon :  _toolbars = toolbars_3d;     break;
            case NODE_3D.sdf :      _toolbars = toolbars_3d_sdf; break;
        }
    	
        for( var i = 0, n = array_length(_toolbars); i < n; i++ ) {
            var tb = _toolbars[i];
            var tbSpr     = tb.sprite;
            var tbInd     = tb.index();
            var tbTooltip = is_method(tb.tooltip)? tb.tooltip() : tb.tooltip;
            var tbClick   = tb.onCilck;
            var tbRight   = tb.onRClick;
            var onWUp     = tb.onWUp;
            var onWDown   = tb.onWDown;
        	var hKey      = tb.hotkey;
            
            var tbData  = { x: x + tbx - ui(14), y: y + tby - ui(14) };
            
            if(is_instanceof(tbTooltip, tooltipSelector))
                tbTooltip.index = tbInd;
            
            var tooltip = instance_exists(o_dialog_menubox)? "" : tbTooltip;
            var _bx = tbx - ui(14);
            var _by = tby - ui(14);
            var _bw = ui(28);
            var _bh = ui(28);
            
            var b = buttonInstant(THEME.button_hide_fill, _bx, _by, _bw, _bh, _m, pHOVER, pFOCUS, tooltip, tbSpr, tbInd);
            switch(b) { 
            	case 1 : 
            		if(onWUp   != 0 && key_mod_press(SHIFT) && MOUSE_WHEEL > 0) onWUp();
            		if(onWDown != 0 && key_mod_press(SHIFT) && MOUSE_WHEEL < 0) onWDown();
            		break;
            		
            	case 2 : tbClick(tbData); break;
            	case 3 : 
            		if(tbRight != 0) tbRight(tbData); 
            		else if(hKey != noone) {
            			hk_selecting = hKey;
            			
            			menuCall("", [
							hKey.getNameFull(),
							menuItem(__txt("Edit Hotkey"), function() /*=>*/ { hk_editing = hk_selecting.modify(); }),
							menuItem(__txt("Reset Hotkey"), function() /*=>*/ {return hk_selecting.reset(true)}, THEME.refresh_20).setActive(hKey.isModified()),
						]);
            		}
            		break;
            }
            
            if(hKey != noone && hKey == hk_editing)
            	draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, COLORS._main_text_accent);
            
            tbx += ui(32);
        }
        
        toolbar_left = tbx;
        tbx = w - toolbar_height / 2;
        
        for( var i = 0, n = array_length(actions); i < n; i++ ) {
        	if(tbx - ui(8) <= toolbar_left) break;
        	
            var tb        = actions[i];
            var tbSpr     = tb.sprite;
            var tbInd     = tb.index();
            var tbTooltip = is_method(tb.tooltip)? tb.tooltip() : tb.tooltip;
            var tbClick   = tb.onCilck;
            var tbRight   = tb.onRClick;
            var onWUp     = tb.onWUp;
            var onWDown   = tb.onWDown;
        	var hKey      = tb.hotkey;
            
            var tbData    = { x: x + tbx - ui(14), y: y + tby - ui(14) };
            var _bx = tbx - ui(14);
            var _by = tby - ui(14);
            var _bw = ui(28);
            var _bh = ui(28);
            
            var b = buttonInstant(THEME.button_hide_fill, _bx, _by, _bw, _bh, _m, pHOVER, pFOCUS, tbTooltip, tbSpr, tbInd);
            switch(b) { 
            	case 1 : 
            		if(onWUp   != 0 && key_mod_press(SHIFT) && MOUSE_WHEEL > 0) onWUp();
            		if(onWDown != 0 && key_mod_press(SHIFT) && MOUSE_WHEEL < 0) onWDown();
            		break;
            		
            	case 2 : tbClick(tbData); break;
            	case 3 : 
            		if(tbRight != 0) tbRight(tbData); 
            		else if(hKey != noone) {
            			hk_selecting = hKey;
            			
            			menuCall("", [
							hKey.getNameFull(),
							menuItem(__txt("Edit Hotkey"), function() /*=>*/ { hk_editing = hk_selecting.modify(); }),
							menuItem(__txt("Reset Hotkey"), function() /*=>*/ {return hk_selecting.reset(true)}, THEME.refresh_20).setActive(hKey.isModified()),
						]);
            		}
            		break;
            }
            
            if(hKey != noone && hKey == hk_editing)
            	draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, COLORS._main_text_accent);
            
            tbx -= ui(32);
        }
        
        draw_set_color(COLORS.panel_toolbar_separator);
        draw_line_width(tbx + ui(12), tby - toolbar_height / 2 + ui(8), tbx + ui(12), tby + toolbar_height / 2 - ui(8), 2);
        
        var _nodeRaw = __getNodePreview();
        if(_nodeRaw) tbx -= drawNodeChannel(_nodeRaw, tbx, tby);
        
        if(hk_editing != noone) { 
			if(key_press(vk_enter)) hk_editing = noone;
			else hotkey_editing(hk_editing);
			
			if(key_press(vk_escape)) hk_editing = noone;
		}
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
    
    ////- DRAW MAIN
    
    function drawContent(panel) { // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MAIN DRAW <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    	mouse_on_preview = pHOVER && point_in_rectangle(mx, my, 0, topbar_height, w, h - toolbar_height);
        
        if(do_fullView) run_in(1, fullView);
        do_fullView = false;
        
        var _prev_node = getNodePreview();
        d3_active = _prev_node == noone? NODE_3D.none : _prev_node.is_3D;
        bg_color  = lerp_color(bg_color, d3_active? COLORS.panel_3d_bg : COLORS.panel_bg_clear, 0.3);
        
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
        
        drawPreviewOverlay();
        
        var inspect_node = PANEL_INSPECTOR.getInspecting();
        var toolNode = noone;
        
        drawViewController();
        
        tool_side_draw_l = false;
        tool_side_draw_r = false;
        
        canvas_mx = (mx - canvas_x) / canvas_s;
        canvas_my = (my - canvas_y) / canvas_s;
        
        if(PANEL_PREVIEW == self) { //only draw overlay once
            if(inspect_node) {
                toolNode = inspect_node.getTool();
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
        
        if(d3_active == NODE_3D.none) drawSplitView();
        
        drawToolBar(toolNode);
        drawMinimap();
        drawActionTooltip();
        
        ////////////////////////////////// Actions //////////////////////////////////
        
        if(mouse_on_preview && mouse_press(mb_right, pFOCUS) && !key_mod_press(SHIFT)) {
            menuCall("preview_context_menu", [ 
                MENU_ITEMS.graph_add_node, 
                MENU_ITEMS.preview_new_preview_window, 
                -1,
                MENU_ITEMS.preview_save_current_frame, 
                MENU_ITEMS.preview_save_all_current_frames, 
                MENU_ITEMS.preview_save_to_project, 
                -1,
                MENU_ITEMS.preview_copy_current_frame, 
                MENU_ITEMS.preview_copy_color, 
                MENU_ITEMS.preview_copy_color_hex, 
                -1,
                MENU_ITEMS.preview_group_preview_bg,
            ], 0, 0, fa_left, getNodePreview());
        }
        
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
    
    function copyCurrentFrame() {
        var prevS = getNodePreviewSurface();
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
        
        var path = get_save_filename_pxc("image|*.png;*.jpg", _node.display_name == ""? "export" : _node.display_name, "Save surface as"); 
        key_release();
        
        if(path == "") return;
        path = filename_ext_verify(path, ".png");
        surface_save_safe(prevS, path);
    }
    
    function saveAllCurrentFrames() {
        var _node = getNodePreview();
        
        if(_node == noone) return;
        
        var path  = get_save_filename_pxc("image|*.png;*.jpg", _node.display_name == ""? "export" : _node.display_name, "Save surfaces as"); 
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