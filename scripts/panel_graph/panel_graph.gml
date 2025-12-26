#region ___function calls
	globalvar GRAPH_ADD_NODE_KEYS, GRAPH_ADD_NODE_MAPS;
	
    #macro PANEL_GRAPH_PROJECT_CHECK if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
	#macro GRAPH_FOCUS var _n = PANEL_GRAPH.getFocusStr(); if(_n == noone) return;
	#macro GRAPH_FOCUS_NUMBER var _n = PANEL_GRAPH.getFocusStr(); if(_n == noone || KEYBOARD_NUMBER == undefined) return;
	
	#macro FN_NODE_CONTEXT_INVOKE if(!variable_global_exists("__FN_NODE_CONTEXT") || variable_global_get("__FN_NODE_CONTEXT") == undefined) variable_global_set("__FN_NODE_CONTEXT", []); \
	array_push(global.__FN_NODE_CONTEXT, function()
	
    function panel_graph_add_node() { 
		CALL("graph_add_node");
		if(FOCUS_CONTENT == PANEL_PREVIEW) PANEL_PREVIEW.callAddDialog(); 
		else PANEL_GRAPH.callAddDialog();
	}
    
    function panel_graph_replace_node()            { CALL("graph_replace_node");        PANEL_GRAPH.callReplaceDialog();     }
    function panel_graph_focus_content()           { CALL("graph_focus_content");       PANEL_GRAPH.fullView();              }
    function panel_graph_preview_focus()           { CALL("graph_preview_focus");       PANEL_GRAPH.setCurrentPreview();     }
    
    function panel_graph_select_all()              { CALL("graph_select_all");          PANEL_GRAPH.nodes_selecting = PANEL_GRAPH.nodes_list; }
    function panel_graph_select_none()             { CALL("graph_select_none");         PANEL_GRAPH.nodes_selecting = []; 
                                                                                        PANEL_INSPECTOR.inspecting  = PANEL_GRAPH.getCurrentContext(); }
    
    function panel_graph_toggle_grid()             { CALL("graph_toggle_grid");         PANEL_GRAPH.project.graphDisplay.show_grid      = !PANEL_GRAPH.project.graphDisplay.show_grid;        }
    function panel_graph_toggle_meta_view()        { CALL("graph_toggle_meta_view");    PANEL_GRAPH.project.graphDisplay.node_meta_view = !PANEL_GRAPH.project.graphDisplay.node_meta_view;   }
    function panel_graph_toggle_dimension()        { CALL("graph_toggle_dimension");    PANEL_GRAPH.project.graphDisplay.show_dimension = !PANEL_GRAPH.project.graphDisplay.show_dimension;   }
    function panel_graph_toggle_compute()          { CALL("graph_toggle_compute");      PANEL_GRAPH.project.graphDisplay.show_compute   = !PANEL_GRAPH.project.graphDisplay.show_compute;     }
    function panel_graph_toggle_control()          { CALL("graph_toggle_control");      PANEL_GRAPH.project.graphDisplay.show_control   = !PANEL_GRAPH.project.graphDisplay.show_control;     }
    function panel_graph_toggle_avoid_label()      { CALL("graph_toggle_avoid_label");  PANEL_GRAPH.project.graphDisplay.avoid_label    = !PANEL_GRAPH.project.graphDisplay.avoid_label;      }
    
    function panel_graph_group()                   { CALL("graph_group");               PANEL_GRAPH.doGroup();                }
    function panel_graph_ungroup()                 { CALL("graph_ungroup");             PANEL_GRAPH.doUngroup();              }
    function panel_graph_uninstance()              { CALL("graph_uninstance");          PANEL_GRAPH.doGroupRemoveInstance();  }
    function panel_graph_update()                  { CALL("graph_update");              PANEL_GRAPH.doGroupUpdate();          }
	
    function panel_graph_canvas_copy()             { CALL("graph_canvas_copy");         PANEL_GRAPH.setCurrentCanvas();       }
    function panel_graph_canvas_blend()            { CALL("graph_canvas_blend");        PANEL_GRAPH.setCurrentCanvasBlend();  }
    
    function panel_graph_rename()                  { CALL("graph_rename");              PANEL_GRAPH.doRename();               }
    function panel_graph_delete_break()            { CALL("graph_delete_break");        PANEL_GRAPH.doDelete(false);          }
    function panel_graph_delete_merge()            { CALL("graph_delete_merge");        PANEL_GRAPH.doDelete(true);           }
    function panel_graph_duplicate()               { CALL("graph_duplicate");           PANEL_GRAPH.doDuplicate();            }
    function panel_graph_instance()                { CALL("graph_instance");            PANEL_GRAPH.doInstance();             }
    function panel_graph_copy()                    { CALL("graph_copy");                PANEL_GRAPH.doCopy();                 }
    function panel_graph_paste()                   { CALL("graph_paste");               PANEL_GRAPH.doPaste();                }
    function panel_graph_mass_connect()            { CALL("graph_mass_connect");        PANEL_GRAPH.doMassConnect();          }
    
	function panel_graph_halign_right()            { CALL("graph_halign_right");        node_halign(PANEL_GRAPH.nodes_selecting, fa_right);  }
	function panel_graph_halign_center()           { CALL("graph_halign_center");       node_halign(PANEL_GRAPH.nodes_selecting, fa_center); }
	function panel_graph_halign_left()             { CALL("graph_halign_left");         node_halign(PANEL_GRAPH.nodes_selecting, fa_left);   }
	                                    
	function panel_graph_valign_bottom()           { CALL("graph_valign_bottom");       node_valign(PANEL_GRAPH.nodes_selecting, fa_bottom); }
	function panel_graph_valign_middle()           { CALL("graph_valign_middle");       node_valign(PANEL_GRAPH.nodes_selecting, fa_middle); }
	function panel_graph_valign_top()              { CALL("graph_valign_top");          node_valign(PANEL_GRAPH.nodes_selecting, fa_top);    }
	
	function panel_graph_hdistribute()             { CALL("graph_hdistribute");         node_hdistribute(PANEL_GRAPH.nodes_selecting);       }
	function panel_graph_vdistribute()             { CALL("graph_vdistribute");         node_vdistribute(PANEL_GRAPH.nodes_selecting);       }
	
    function panel_graph_auto_organize_all()       { CALL("graph_auto_organize_all");   node_auto_organize(PANEL_GRAPH.nodes_list);      }
    function panel_graph_auto_organize()           { CALL("graph_auto_organize");       node_auto_organize(PANEL_GRAPH.nodes_selecting); }
    function panel_graph_auto_align()              { CALL("graph_auto_align");          node_auto_align(PANEL_GRAPH.nodes_selecting);    }
    function panel_graph_snap_nodes()              { CALL("graph_snap_nodes");          node_snap_grid(PANEL_GRAPH.nodes_selecting, PANEL_GRAPH.project.graphGrid.size);                }
    function panel_graph_search()                  { CALL("graph_search");              PANEL_GRAPH.toggleSearch();                                                                     }
    function panel_graph_toggle_minimap()          { CALL("graph_toggle_minimap");      PANEL_GRAPH.minimap_show = !PANEL_GRAPH.minimap_show;                                           }
                                                                                                                            
    function panel_graph_pan()                     { CALL("graph_pan");  if(PANEL_GRAPH.node_hovering || PANEL_GRAPH.value_focus) return; PANEL_GRAPH.graph_dragging_key = true;        }
    function panel_graph_zoom()                    { CALL("graph_zoom"); if(PANEL_GRAPH.node_hovering || PANEL_GRAPH.value_focus) return; PANEL_GRAPH.graph_zooming_key  = true;        }
    
    function panel_graph_send_to_preview()         { CALL("graph_send_to_preview");     PANEL_GRAPH.send_to_preview();                        }
    function panel_graph_preview_window()          { CALL("graph_preview_window");      create_preview_window(PANEL_GRAPH.getFocusingNode()); }
    function panel_graph_inspector_panel()         { CALL("graph_inspector_panel");     PANEL_GRAPH.inspector_panel();                        }
    function panel_graph_send_to_export()          { CALL("graph_send_to_export");      PANEL_GRAPH.send_hover_to_export();                   }
    function panel_graph_toggle_preview()          { CALL("graph_toggle_preview");      PANEL_GRAPH.setTriggerPreview();                      }
    function panel_graph_toggle_render()           { CALL("graph_toggle_render");       PANEL_GRAPH.setTriggerRender();                       }
    function panel_graph_toggle_parameter()        { CALL("graph_toggle_parameter");    PANEL_GRAPH.setTriggerParameter();                    }
    function panel_graph_enter_group()             { CALL("graph_enter_group");         PANEL_GRAPH.enter_group();                            }
    function panel_graph_exit_group()              { CALL("graph_exit_group");          PANEL_GRAPH.exitContext();                            }
    function panel_graph_hide_disconnected()       { CALL("graph_hide_disconnected");   PANEL_GRAPH.hide_disconnected();                      }
    
    function panel_graph_open_group_tab()          { CALL("graph_open_group_tab");      PANEL_GRAPH.open_group_tab();                         }
    function panel_graph_set_as_tool()             { CALL("graph_open_set_as_tool");    PANEL_GRAPH.set_as_tool();                            }
    
    function panel_graph_doCopyProp()              { CALL("graph_doCopyProp");          PANEL_GRAPH.doCopyProp();                             }
    function panel_graph_doPasteProp()             { CALL("graph_doPasteProp");         PANEL_GRAPH.doPasteProp();                            }
    function panel_graph_createTunnel()            { CALL("graph_createTunnel");        PANEL_GRAPH.createTunnel();                           }
    
    function panel_graph_grid_snap()               { CALL("graph_grid_snap");           PANEL_GRAPH_PROJECT_CHECK PANEL_GRAPH.project.graphGrid.snap = !PANEL_GRAPH.project.graphGrid.snap;               }
    function panel_graph_show_origin()             { CALL("graph_grid_show_origin");    PANEL_GRAPH_PROJECT_CHECK PANEL_GRAPH.project.graphGrid.show_origin = !PANEL_GRAPH.project.graphGrid.show_origin; }
    function panel_graph_searchWiki()              { CALL("graph_searchWiki");          PANEL_GRAPH.searchWiki();                               }
    function panel_graph_viewSource()              { CALL("graph_viewSource");          PANEL_GRAPH.viewSource();                               }
    function panel_graph_swapConnection()          { CALL("graph_swapConnection");      PANEL_GRAPH.swapConnection();                           }
    function panel_graph_transferConnection()      { CALL("graph_transferConnection");  PANEL_GRAPH.transferConnection();                       }
				                    
	function panel_graph_topbar_toggle()           { PANEL_GRAPH.topbar_toggle();       }
	function panel_graph_topbar_show()             { PANEL_GRAPH.topbar_show();         }
	function panel_graph_topbar_hide()             { PANEL_GRAPH.topbar_hide();         }
	                                                         
	function panel_graph_view_control_toggle()     { PANEL_GRAPH.view_control_toggle(); }
	function panel_graph_view_control_show()       { PANEL_GRAPH.view_control_show();   }
	function panel_graph_view_control_hide()       { PANEL_GRAPH.view_control_hide();   }
	
    function panel_graph_set_node_display_mini() { 
    	var nodes = PANEL_GRAPH.nodes_selecting; 
    	
    	for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			if(!is(nodes[i], Node)) return;
			
			nodes[i].setPreviewable(false);
	    	nodes[i].refreshNodeDisplay();
    	}
    	
    	PANEL_GRAPH.refreshDraw(2);
	}
    
    function panel_graph_set_node_display_default() { 
    	var nodes = PANEL_GRAPH.nodes_selecting; 
    	
    	for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			if(!is(nodes[i], Node)) return;
			
			nodes[i].setPreviewable(true);
			nodes[i].setShowParameter(false);
	    	nodes[i].refreshNodeDisplay();
    	}
    	
    	PANEL_GRAPH.refreshDraw(2);
	}
    
    function panel_graph_set_node_display_parameter() { 
    	var nodes = PANEL_GRAPH.nodes_selecting; 
    	
    	for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			if(!is(nodes[i], Node)) return;
			
			nodes[i].setPreviewable(true);
			nodes[i].setShowParameter(true);
	    	nodes[i].refreshNodeDisplay();
    	}
    	
    	PANEL_GRAPH.refreshDraw(2);
	}
    
    function __fnInit_Graph() {
    	var g = "Graph";
    	var n = MOD_KEY.none;
    	var c = MOD_KEY.ctrl;
    	var s = MOD_KEY.shift;
    	var a = MOD_KEY.alt;
    	
    	registerFunction("", "Add Node",             "A", s, panel_graph_add_node      ).setMenu("graph_add_node", THEME.add_20)
        registerFunction(g, "Replace Node",          "R", c, panel_graph_replace_node  ).setMenu("graph_replace_node")
        registerFunction(g, "Focus Content",         "F", n, panel_graph_focus_content ).setMenu("graph_focus_content", THEME.icon_center_canvas)
        registerFunction(g, "Preview Focusing Node", "P", n, panel_graph_preview_focus ).setMenu("graph_preview_focusing_node")
		
        registerFunction(g, "Select All",            "A", c, panel_graph_select_all          ).setMenu("graph_select_all")
        registerFunction(g, "Select None",     vk_escape, n, panel_graph_select_none         ).setMenu("graph_select_none")
        
        registerFunction(g, "Toggle Grid",           "G", n, panel_graph_toggle_grid         ).setMenu("graph_toggle_grid")
        registerFunction(g, "Toggle Meta View",      "",  n, panel_graph_toggle_meta_view    ).setMenu("graph_toggle_meta_view")
        registerFunction(g, "Toggle Dimension",      "",  n, panel_graph_toggle_dimension    ).setMenu("graph_toggle_dimension")
        registerFunction(g, "Toggle Compute",        "",  n, panel_graph_toggle_compute      ).setMenu("graph_toggle_compute")
        registerFunction(g, "Toggle Control",        "",  n, panel_graph_toggle_control      ).setMenu("graph_toggle_control")
        registerFunction(g, "Toggle Avoid Label",    "",  n, panel_graph_toggle_avoid_label  ).setMenu("graph_toggle_avoid_label")
        
        registerFunction(g, "Copy to Canvas",        "C", c|s, panel_graph_canvas_copy       ).setMenu("graph_canvas_copy")
        registerFunction(g, "Blend Canvas",          "C", c|a, panel_graph_canvas_blend      ).setMenu("graph_canvas_blend")
        registerFunction(g, "Canvas",                "",  n,                    
        	function(d) /*=>*/ {return submenuCall(d, [ MENU_ITEMS.graph_canvas_copy, MENU_ITEMS.graph_canvas_blend ])}).setMenu("graph_canvas", noone, true)
		
        registerFunction(g, "Rename",                vk_f2,     n, panel_graph_rename        ).setMenu("graph_rename")
        registerFunction(g, "Delete (break)",        vk_delete, s, panel_graph_delete_break  ).setMenu("graph_delete_break",    THEME.cross)
        registerFunction(g, "Delete (merge)",        vk_delete, n, panel_graph_delete_merge  ).setMenu("graph_delete_merge",    THEME.cross)
    
        registerFunction(g, "Duplicate",             "D", c, panel_graph_duplicate           ).setMenu("graph_duplicate",       THEME.duplicate)
        registerFunction(g, "Instance",              "D", a, panel_graph_instance            ).setMenu("graph_instance",        THEME.duplicate)
        registerFunction(g, "Copy",                  "C", c, panel_graph_copy                ).setMenu("graph_copy",            THEME.copy)
        registerFunction(g, "Paste",                 "V", c, panel_graph_paste               ).setMenu("graph_paste",           THEME.paste)
        registerFunction(g, "Mass Connect",          "",  n, panel_graph_mass_connect        ).setMenu("graph_mass_connect",    THEME.obj_auto_organize)
        
        registerFunction(g, "Pan",                   "", c,  panel_graph_pan                 ).setMenu("graph_pan")
        registerFunction(g, "Zoom",                  "", a|c,panel_graph_zoom                ).setMenu("graph_zoom")
        
        registerFunction(g, "Auto Align",            "L", n, panel_graph_auto_align          ).setMenu("graph_auto_align", THEME.obj_auto_align)
        registerFunction(g, "Auto Organize...",      "L", c, function() /*=>*/ { 
        	var l = array_empty(PANEL_GRAPH.nodes_selecting)? PANEL_GRAPH.nodes_list : PANEL_GRAPH.nodes_selecting;
        	dialogPanelCall(new Panel_Graph_Auto_Organize(l)) 
        } ).setMenu("graph_auto_organize", THEME.obj_auto_organize);
        registerFunction(g, "Auto Organize All",     "",  n, panel_graph_auto_organize_all   ).setMenu("graph_auto_organize_all", THEME.obj_auto_organize)
        registerFunction(g, "Snap Nodes to Grid",    "",  n, panel_graph_snap_nodes          ).setMenu("graph_snap_nodes")
        registerFunction(g, "Node Multiplier...",    "",  n, function() /*=>*/ { 
        	if(array_empty(PANEL_GRAPH.nodes_selecting)) return;
        	dialogPanelCall(new Panel_Graph_Node_Multiplier(PANEL_GRAPH.nodes_selecting[0]));
    	} ).setMenu("graph_node_multiply", THEME.obj_auto_organize);
        
        registerFunction(g, "Search",                "F", c, panel_graph_search              ).setMenu("graph_search", THEME.search_24)
        registerFunction(g, "Toggle Minimap",        "M", c, panel_graph_toggle_minimap      ).setMenu("graph_toggle_minimap", THEME.icon_minimap).setSpriteInd(function() /*=>*/ {return PANEL_GRAPH.minimap_show} )
        
        registerFunction(g, "Align Horizontal Right", "", n, panel_graph_halign_right        ).setMenu("graph_halign_right",  THEME.object_halign ).setSpriteInd(function() /*=>*/ {return 2})
        registerFunction(g, "Align Horizontal Center","", n, panel_graph_halign_center       ).setMenu("graph_halign_center", THEME.object_halign ).setSpriteInd(function() /*=>*/ {return 1})
        registerFunction(g, "Align Horizontal Left",  "", n, panel_graph_halign_left         ).setMenu("graph_halign_left",   THEME.object_halign ).setSpriteInd(function() /*=>*/ {return 0})
        
        registerFunction(g, "Align Vertical Top",    "",  n, panel_graph_valign_bottom       ).setMenu("graph_valign_bottom", THEME.object_valign ).setSpriteInd(function() /*=>*/ {return 2})
        registerFunction(g, "Align Vertical Middle", "",  n, panel_graph_valign_middle       ).setMenu("graph_valign_middle", THEME.object_valign ).setSpriteInd(function() /*=>*/ {return 1})
        registerFunction(g, "Align Vertical Bottom", "",  n, panel_graph_valign_top          ).setMenu("graph_valign_top",    THEME.object_valign ).setSpriteInd(function() /*=>*/ {return 0})
        
        registerFunction(g, "Distribute Horizontal", "",  n, panel_graph_hdistribute         ).setMenu("graph_hdistribute",   THEME.obj_distribute_h ).setSpriteInd(function() /*=>*/ {return 0})
        registerFunction(g, "Distribute Vertical",   "",  n, panel_graph_vdistribute         ).setMenu("graph_vdistribute",   THEME.obj_distribute_v ).setSpriteInd(function() /*=>*/ {return 0})
        
        registerFunction(g, "Send To Preview",       "",  n, panel_graph_send_to_preview     ).setMenu("graph_preview_hovering_node")
        registerFunction(g, "Send To Preview Window","P", c, panel_graph_preview_window      ).setMenu("graph_preview_window")
        registerFunction(g, "Send To Inspector",     "",  n, panel_graph_inspector_panel     ).setMenu("graph_inspect")
        registerFunction(g, "Toggle Preview",        "H", n, panel_graph_toggle_preview      ).setMenu("graph_toggle_preview")
        registerFunction(g, "Toggle Render",         "R", n, panel_graph_toggle_render       ).setMenu("graph_toggle_render")
        registerFunction(g, "Toggle Parameters",     "M", n, panel_graph_toggle_parameter    ).setMenu("graph_toggle_parameters")
        registerFunction(g, "Node Display",          "",  n, function(d) /*=>*/ {return submenuCall(d, [ 
        	menuItem( "Minimized", panel_graph_set_node_display_mini      ), 
        	menuItem( "Default",   panel_graph_set_node_display_default   ), 
        	menuItem( "Parameter", panel_graph_set_node_display_parameter ), 
    	])}).setMenu("graph_node_display", noone, true)
        
        registerFunction(g, "Hide Disconnected",     "",  n, panel_graph_hide_disconnected   ).setMenu("graph_hide_disconnected")
        
        registerFunction(g, "Enter Group",           "",  n, panel_graph_enter_group         ).setMenu("graph_enter_group",     THEME.group)
        registerFunction(g, "Exit Group",           192,  n, panel_graph_exit_group          ).setMenu("graph_exit_group",      THEME.group)
        registerFunction(g, "Open Group In New Tab", "",  n, panel_graph_open_group_tab      ).setMenu("graph_open_in_new_tab", THEME.group)
        registerFunction(g, "Group",                 "G", c, panel_graph_group               ).setMenu("graph_group",           THEME.group)
        registerFunction(g, "Ungroup",               "G", c|s,panel_graph_ungroup            ).setMenu("graph_ungroup",         THEME.group)
        registerFunction(g, "Uninstance",            "",  n, panel_graph_uninstance          ).setMenu("graph_uninstance")
        registerFunction(g, "Set As Group Tool",     "",  n, panel_graph_set_as_tool         ).setMenu("graph_set_as_tool")
        registerFunction(g, "Update Group",          "",  n, panel_graph_update              ).setMenu("graph_update")
        
        registerFunction(g, "Copy Value",            "",  n, panel_graph_doCopyProp          ).setMenu("graph_copy_value")
        registerFunction(g, "Paste Value",           "",  n, panel_graph_doPasteProp         ).setMenu("graph_paste_value")
        registerFunction(g, "Create Tunnel",         "",  n, panel_graph_createTunnel        ).setMenu("graph_create_tunnel")
        
        registerFunction(g, "Toggle Grid Snap",      "",  n, panel_graph_grid_snap           ).setMenu("graph_grid_snap")
        registerFunction(g, "Toggle Show Origin",    "",  n, panel_graph_show_origin         ).setMenu("graph_show_origin")
        registerFunction(g, "Search Wiki",         vk_f1, n, panel_graph_searchWiki          ).setMenu("graph_search_wiki")
        registerFunction(g, "View Source",        vk_f12, c, panel_graph_viewSource          ).setMenu("graph_view_source")
        registerFunction(g, "Swap Connections",      "S", a, panel_graph_swapConnection      ).setMenu("graph_swap_connection")
        registerFunction(g, "Transfer Connections",  "T", a, panel_graph_transferConnection  ).setMenu("graph_transfer_connection")
		
		registerFunction(g, "Export Hovering Node",   "",  n, panel_graph_send_to_export ).setMenu("graph_export_hover")
        registerFunction(g, "Export As Image...",     "",  n, function() /*=>*/ { PANEL_GRAPH.subDialogCall(new Panel_Graph_Export_Image(PANEL_GRAPH)) }).setMenu("graph_export_image",        THEME.icon_preview_export   )
        registerFunction(g, "Connection Settings...", "",  n, function() /*=>*/ { PANEL_GRAPH.subDialogCall(new Panel_Graph_Connection_Setting())      }).setMenu("graph_connection_settings", THEME.icon_curve_connection ).setSpriteInd(function() /*=>*/ {return PANEL_GRAPH.project.graphConnection.type})
        registerFunction(g, "Grid Settings...",       "",  n, function() /*=>*/ { PANEL_GRAPH.subDialogCall(new Panel_Graph_Grid_Setting())            }).setMenu("graph_grid_settings",       THEME.icon_grid_setting     ).setSpriteInd(function() /*=>*/ {return 1})
        registerFunction(g, "View Settings...",       "",  n, function() /*=>*/ { PANEL_GRAPH.subDialogCall(new Panel_Graph_View_Setting(PANEL_GRAPH, PROJECT.graphDisplay)) }).setMenu("graph_view_settings", THEME.icon_visibility )
        
		registerFunction(g, "Toggle Topbar",       "", n, panel_graph_topbar_toggle  ).setMenu("graph_topbar_toggle", noone, false, function() /*=>*/ {return PROJECT.graphDisplay.show_topbar});
		registerFunction(g, "Show Topbar",         "", n, panel_graph_topbar_show    ).setMenu("graph_topbar_show");
		registerFunction(g, "Hide Topbar",         "", n, panel_graph_topbar_hide    ).setMenu("graph_topbar_hide");
		registerFunction(g, "Edit Topbar...",      "", n, function() /*=>*/ {return menuItemEdit("graph_topbar_menu")}  ).setMenu("graph_topbar_edit");
		registerFunction(g, "Reset Topbar",        "", n, function() /*=>*/ {return menuItemReset("graph_topbar_menu")} ).setMenu("graph_topbar_reset", THEME.refresh_20);
		
		registerFunction(g, "Toggle View Control", "", n, panel_graph_view_control_toggle  ).setMenu("graph_view_control_toggle", noone, false, function() /*=>*/ {return PROJECT.graphDisplay.show_view_control});
		registerFunction(g, "Show View Control",   "", n, panel_graph_view_control_show    ).setMenu("graph_view_control_show");
		registerFunction(g, "Hide View Control",   "", n, panel_graph_view_control_hide    ).setMenu("graph_view_control_hide");
		
		registerFunction(g, "Edit Graph Toolbar...",       "", n, function() /*=>*/ {return menuItemEdit("graph_toolbars_general")}  ).setMenu("graph_edit_toolbar"                          );
		registerFunction(g, "Reset Graph Toolbar",         "", n, function() /*=>*/ {return menuItemReset("graph_toolbars_general")} ).setMenu("graph_reset_toolbar",       THEME.refresh_20 );
		
        __fnGroupInit_Graph();
        
        for( var i = 0, n = array_length(global.__FN_NODE_CONTEXT); i < n; i++ ) 
        	global.__FN_NODE_CONTEXT[i]();
        
        __fnInit_Graph_Nodes();
    }
    
    function __fnGraph_BuildNode(_k, _key = "", _mod = MOD_KEY.none) {
    	if(struct_has(GRAPH_ADD_NODE_MAPS, _k)) 
    		return GRAPH_ADD_NODE_MAPS[$ _k];
    	
    	var _h = new Hotkey("Add Node", _k, _key, _mod, function(k) /*=>*/ { PANEL_GRAPH.createNodeHotkey(k) }).setParam(_k);
		array_push(GRAPH_ADD_NODE_KEYS, _h);
		GRAPH_ADD_NODE_MAPS[$ _k] = _h;
		
		return _h;
    }
    
    function __fnInit_Graph_Nodes() {
    	GRAPH_ADD_NODE_KEYS = [];
    	GRAPH_ADD_NODE_MAPS = {};
    	
    	__fnGraph_BuildNode("Node_Number",    "1", MOD_KEY.none);
    	__fnGraph_BuildNode("Node_Vector2",   "2", MOD_KEY.none);
    	__fnGraph_BuildNode("Node_Vector3",   "3", MOD_KEY.none);
    	__fnGraph_BuildNode("Node_Vector4",   "4", MOD_KEY.none);
    	
    	__fnGraph_BuildNode("Node_Transform", "T", MOD_KEY.ctrl);
    	__fnGraph_BuildNode("Node_Blend",     "B", MOD_KEY.ctrl);
    	__fnGraph_BuildNode("Node_Composite", "B", MOD_KEY.ctrl | MOD_KEY.shift);
    	__fnGraph_BuildNode("Node_Array",     "A", MOD_KEY.ctrl | MOD_KEY.shift);
    	__fnGraph_BuildNode("Node_Frame",     "F", MOD_KEY.shift);
    	__fnGraph_BuildNode("Node_Export",    "E", MOD_KEY.ctrl);
    	
        if(struct_has(HOTKEYS_DATA, "graph")) {
        	var _grps = HOTKEYS_DATA.graph;
        	var _keys = struct_get_names(_grps);
        	
        	for( var i = 0, n = array_length(_keys); i < n; i++ )
        		__fnGraph_BuildNode(_keys[i]).deserialize(_grps[$ _keys[i]]);
        }
    }
    
    function __fnGroupInit_Graph() {
        
        MENU_ITEMS.graph_group_align = menuItemGroup(__txtx("panel_graph_align_nodes", "Align"), [
                [ [THEME.inspector_surface_halign, 0], function() /*=>*/ {return node_halign(PANEL_GRAPH.nodes_selecting, fa_left)}   ],
                [ [THEME.inspector_surface_halign, 1], function() /*=>*/ {return node_halign(PANEL_GRAPH.nodes_selecting, fa_center)} ],
                [ [THEME.inspector_surface_halign, 2], function() /*=>*/ {return node_halign(PANEL_GRAPH.nodes_selecting, fa_right)}  ],
                
                [ [THEME.inspector_surface_valign, 0], function() /*=>*/ {return node_valign(PANEL_GRAPH.nodes_selecting, fa_top)}    ],
                [ [THEME.inspector_surface_valign, 1], function() /*=>*/ {return node_valign(PANEL_GRAPH.nodes_selecting, fa_middle)} ],
                [ [THEME.inspector_surface_valign, 2], function() /*=>*/ {return node_valign(PANEL_GRAPH.nodes_selecting, fa_bottom)} ],
                
                [ [THEME.obj_distribute_h, 0],         function() /*=>*/ {return node_hdistribute(PANEL_GRAPH.nodes_selecting)}       ],
                [ [THEME.obj_distribute_v, 0],         function() /*=>*/ {return node_vdistribute(PANEL_GRAPH.nodes_selecting)}       ],
        ], ["Graph", "Align Nodes"]);
        registerFunction("Graph", "Align Nodes", "",  MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.graph_group_align ]); });
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        var _clrs = COLORS.labels;
        var _item = array_create(array_length(_clrs));

        for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
            _item[i] = [ 
                [ THEME.timeline_color, i > 0, _clrs[i] ], 
                function(_data) /*=>*/ {  PANEL_GRAPH.setSelectingNodeColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
            ];
        }

        array_push(_item, [ [ THEME.timeline_color, 2 ], function() /*=>*/ { 
        	colorSelectorCall(PANEL_GRAPH.node_hover? PANEL_GRAPH.node_hover.attributes.color : c_white, PANEL_GRAPH.setSelectingNodeColor); 
        }]);
        
        MENU_ITEMS.graph_group_node_color = menuItemGroup(__txt("Node Color"), _item, ["Graph", "Set Node Color"]).setSpacing(ui(24));
        registerFunction("Graph", "Set Node Color", "",  MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.graph_group_node_color ]); });
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        var _clrs = COLORS.labels;
        var _item = array_create(array_length(_clrs));

        for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
            _item[i] = [ 
                [ THEME.timeline_color, i > 0, _clrs[i] ], 
                function(_data) /*=>*/ { PANEL_GRAPH.setSelectingJuncColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
            ];
        }

        array_push(_item, [ [ THEME.timeline_color, 2 ], function() /*=>*/ { 
        	colorSelectorCall(PANEL_GRAPH.__junction_hovering? PANEL_GRAPH.__junction_hovering.color : c_white, PANEL_GRAPH.setSelectingJuncColor); 
        }]);
        
        MENU_ITEMS.graph_group_junction_color = menuItemGroup(__txt("Connection Color"), _item, ["Graph", "Set Junction Color"]).setSpacing(ui(24));
        registerFunction("Graph", "Set Junction Color", "",  MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.graph_group_junction_color ]); });
    }
#endregion

function connectionParameter() constructor {
    log    = false;
    active = true;
    
    x  = 0;
    y  = 0;
    s  = 0;
    mx = 0;
    my = 0;
    aa = 0;
    bg = 0;
    
    minx = 0;
    miny = 0;
    maxx = 0;
    maxy = 0;
    
    max_layer = 0;
    highlight = 0;
    checkNode = noone;
    
    static setPos = function(_x, _y, _s, _mx, _my) { 
        self.x = _x;
        self.y = _y;
        self.s = _s;
        self.mx = _mx;
        self.my = _my;
    }

    static setBoundary = function(_minx, _miny, _maxx, _maxy) { 
        self.minx = _minx;
        self.miny = _miny;
        self.maxx = _maxx;
        self.maxy = _maxy;
    }

    static setProp = function(_max_layer, _highlight) { 
        self.max_layer = _max_layer;
        self.highlight = _highlight;
    }

    static setDraw = function(_aa, _bg = c_black) { 
        self.aa = _aa;
        self.bg = _bg;
    }
} 

	////- Graph

function Panel_Graph(_project = PROJECT) : PanelContent() constructor {
    title       = __txt("Graph");
    title_raw   = "";
    context_str = "Graph";
    icon        = THEME.panel_graph_icon;
    pause_when_rendering = true;
    
    auto_pin = true;
    w = ui(800);
    h = ui(640);
    
    applyGlobal = true; setLocalOnly = function() /*=>*/ { applyGlobal = false; return self; }
    hasGlobal   = true; noGlobal     = function() /*=>*/ { hasGlobal   = false; return self; }
    
    function setTitle() {
        title_raw = project.path == ""? "New project" : filename_name_only(project.path);
        title     = title_raw + (project.modified? "*" : ""); 
    }
    
    static reset = function() {
        onFocusBegin();
        resetContext();
    }
    
    #region // ---- display ----
        connection_param  = new connectionParameter();
        bg_color          = c_black;
        slider_width      = 0;
        tooltip_overlay   = {};
        toolbar_height    = ui(32);
        toolbar_left      = 0;
        
        topbar_height  = ui(32);
        top_scroll     = 0;
		top_scroll_to  = 0;
		top_scroll_max = 0;
		
        function addKeyOverlay(_title, _keys) {
        	if(struct_has(tooltip_overlay, _title)) {
        		array_append(tooltip_overlay[$ _title], _keys);
        		return;
        	}
        	
        	tooltip_overlay[$ _title] = _keys;
        }
        
        tb_zoom_level = new textBox(TEXTBOX_INPUT.number, function(z) /*=>*/ { 
        	var _s = graph_s;
                
            graph_s_to = clamp(z, 0.01, 4); 
        	graph_s    = graph_s_to; 
            
            if(_s != graph_s) {
				graph_x += w / 2 * ((1 / graph_s) - (1 / _s));
				graph_y += h / 2 * ((1 / graph_s) - (1 / _s));
            }
            
        }).setColor(c_white).setAlign(fa_right).setHide(3).setFont(f_p2);
        
        tooltip_action      = "";
        tooltip_action_time = 0;
    #endregion
    
    #region // ---- position ----
        graph_x  = 0;
        graph_y  = 0;
        graph_cx = 0;
        graph_cy = 0;
        
        graph_autopan   = false;
        graph_pan_x_to  = 0;
        graph_pan_y_to  = 0;
        graph_pan_s_to  = 0;
        graph_pan_speed = 32;
        
        scale      = [ 0.01, 0.02, 0.05, 0.10, 0.15, 0.20, 0.25, 0.33, 0.50, 0.65, 0.80, 1, 1.2, 1.35, 1.5, 2.0, 2.5, 3.0, 4.0 ];
        graph_s    = 1;
        graph_s_to = graph_s;
        
        graph_dragging_key = false;
        graph_zooming_key  = false;
        
        graph_draggable= true;
        graph_dragging = false;
        graph_drag_mx  = 0;
        graph_drag_my  = 0;
        graph_drag_sx  = 0;
        graph_drag_sy  = 0;
        
        graph_zooming  = false;
        graph_zoom_mx  = 0;
        graph_zoom_my  = 0;
        graph_zoom_m   = 0;
        graph_zoom_s   = 0;
        
        view_hovering  = false;
        view_pan_tool  = false;
        view_zoom_tool = false;
        
        drag_key       = PREFERENCES.pan_mouse_key;
        drag_locking   = false;
    #endregion
    
    #region // ---- mouse ----
        mouse_graph_x    = 0;
        mouse_graph_y    = 0;
        mouse_grid_x     = 0;
        mouse_grid_y     = 0;
         
        mouse_create_x   = undefined;
        mouse_create_y   = undefined;
        mouse_create_sx  = undefined;
        mouse_create_sy  = undefined;
        
        mouse_on_graph   = false;
        node_bg_hovering = false;
        
        file_drop_tooltip = new Panel_Graph_Drop_tooltip(self);
        
        mouse_glow_rad    = 0;
        mouse_glow_rad_to = 0;
    #endregion
    
    #region // ---- nodes ----
        node_context         = [];
        nodes_list           = [];
        
        node_dragging        = noone;
        node_drag_mx         = 0;
        node_drag_my         = 0;
        node_drag_sx         = 0;
        node_drag_sy         = 0;
        node_drag_ox         = 0;
        node_drag_oy         = 0;
        node_drag_add        = false;
    	node_drag_connect    = noone;
    	node_drag_removing   = false;
    	node_drag_remove     = [];
    	frame_draggings      = [];
    	
    	node_resize          = noone;
    	node_resize_mx       = 0;
    	node_resize_my       = 0;
    	node_resize_sx       = 0;
    	node_resize_sy       = 0;
    	
        selection_block      = 0;
        nodes_selecting      = [];
        nodes_selecting_jun  = [];
        nodes_select_anchor  = noone;
        nodes_select_drag    = 0;
        nodes_select_frame   = 0;
        nodes_select_mx      = 0;
        nodes_select_my      = 0;
     
        nodes_junction_d     = noone;
        nodes_junction_dx    = 0;
        nodes_junction_dy    = 0;
    
        node_hovering        = noone;
        node_hover           = noone;
        
        junction_hovering    = noone;
        add_node_draw_junc   = noone;
        add_node_draw_x      = 0;
        add_node_draw_y      = 0;
        
        draw_refresh           = true;   static refreshDraw = function(t=1) /*=>*/ { draw_refresh = max(draw_refresh, t); }
        node_surface           = noone;
        node_surface_update    = true;
        
        connection_aa          = 2;
        connection_surface     = noone;
        connection_surface_cc  = noone;
        connection_surface_aa  = noone;
        
        connection_draw_mouse  = noone;
        connection_draw_target = noone;
        connection_draw_update = true;
        connection_cache       = {};
        
        value_focus     = noone;
        _value_focus    = noone;
        value_dragging  = noone;
        value_draggings = [];
        value_drag_from = noone;
        
        node_drag_search = false;
        
        frame_hovering   = noone;
        frame_hoverings  = [];
        _frame_hovering  = noone;
        
        cache_group_edit = noone;
        connect_related  = noone;
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
    
    #region // ---- context frame ----
        context_framing        = false;
        context_frame_progress = 0;
        context_frame_direct   = 0;
        context_frame_sx       = 0; 
        context_frame_ex       = 0;
        context_frame_sy       = 0; 
        context_frame_ey       = 0;
    #endregion
    
    #region // ---- search ----
        is_searching  = false;
        search_string = "";
        search_index  = 0;
        search_result = [];
        
        tb_search             = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_string = string(str); searchNodes(); });
        tb_search.align       = fa_left;
        tb_search.auto_update = true;
    #endregion
    
    function toCenterNode(_arr = nodes_list, _zoom = true) {
        if(!project.active) return; 
        
        graph_s    = 1;
        graph_s_to = 1;
        
        if(array_empty(_arr)) {
            graph_x = round(w / 2 / graph_s);
            graph_y = round(h / 2 / graph_s);
            return;
        }
        
        var minx =  infinity;
        var miny =  infinity;
        var maxx = -infinity;
        var maxy = -infinity;
        
        for(var i = 0; i < array_length(_arr); i++) {
            var _node = _arr[i];
            
            if(!is(_node, Node)) continue;
            if(!_node.active)    continue;
            
            if(is(_node, Node_Feedback_Inline))    continue;
            
            if(is(_node, Node_Collection_Inline)) {
            	var _bbox = _node.bbox;
            	minx = min(minx, _bbox[0] - 32);
	            maxx = max(maxx, _bbox[2] + 32);
	                
	            miny = min(miny, _bbox[1] - 32);
	            maxy = max(maxy, _bbox[3] + 32);
            	continue;
            }
            
            minx = min(minx, _node.x - 32);
            maxx = max(maxx, _node.x + _node.w + 32);
                
            miny = min(miny, _node.y - 32);
            maxy = max(maxy, _node.y + _node.h + 32);
        }
        
        var cx = (minx + maxx) / 2;
        var cy = (miny + maxy) / 2;
        
        var ww = maxx - minx;
        var hh = maxy - miny;
        
        var _w = w;
        var _h = h - toolbar_height - project.graphDisplay.show_topbar * topbar_height;
        
        var sc = min(_w / ww, _h / hh);
            sc = clamp(sc, array_first(scale), array_last(scale));
        if(!_zoom) sc = 1;
        
        graph_s    = sc;
        graph_s_to = sc;
        
        graph_x = (_w / 2) / graph_s - cx;
        graph_y = (_h / 2) / graph_s - cy;
        
    }
    
    function initSize() { toCenterNode(); }
    
    #region // ++++ toolbars ++++
	    function subDialogCall(_dia) {
	    	dialogPanelCall(_dia, x + w - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.right });
	    }
	    
        hk_editing = noone;
        
        global.menuItems_graph_toolbars_general_context = ["graph_edit_toolbar", "graph_reset_toolbar"];
        global.menuItems_graph_toolbars_general = [
        	"graph_export_image", 
        	"graph_search",
        	"graph_focus_content",
        	"graph_toggle_minimap",
        	"graph_connection_settings",
        	"graph_grid_settings",
        	"graph_view_settings",
        	{ cond : "graph_select_multiple", items : [ 
        		-1, 
        		"graph_halign_right",
	            "graph_halign_center",
	            "graph_halign_left",
	            -1, 
	            "graph_valign_bottom",
	            "graph_valign_middle",
	            "graph_valign_top",
	            -1, 
	            "graph_hdistribute",
	            "graph_vdistribute",
	            -1, 
	            "graph_auto_align",
	            "graph_auto_organize"
            ] },
    	];
        
        function topbar_toggle() { project.graphDisplay.show_topbar = !project.graphDisplay.show_topbar; }
		function topbar_show()   { project.graphDisplay.show_topbar =  true; }
		function topbar_hide()   { project.graphDisplay.show_topbar = false; }
		
		function view_control_toggle() { project.graphDisplay.show_view_control = !project.graphDisplay.show_view_control; }
		function view_control_show()   { project.graphDisplay.show_view_control =  true; }
		function view_control_hide()   { project.graphDisplay.show_view_control = false; }
		
	    global.menuItems_graph_topbar_context_menu = [
	    	"graph_topbar_hide", 
	    	"graph_topbar_edit", 
	    	"graph_topbar_reset", 
		];
		
        global.menuItems_graph_topbar_menu = [	
			"graph_auto_organize_all",
			-1,
			"graph_add_Node_Number",
			"graph_add_Node_Counter",
	    	"graph_add_Node_Path",
			-1,
			"graph_add_Node_Shape",
	    	"graph_add_Node_Text",
	    	"graph_add_Node_Line", 
	    	"graph_add_Node_Solid",
	    	"graph_add_Node_Gradient",
	    	-1, 
	    	"graph_add_Node_Level",
	    	"graph_add_Node_Color_adjust",
	    	"graph_add_Node_Colorize",
	    	"graph_add_Node_Posterize",
	    	"graph_add_Node_Dither", 
	    	{ cond : "graph_context_group",    items : [ -1, "graph_add_Node_Group_Input", "graph_add_Node_Group_Output" ] },
	    	{ cond : "graph_context_group_pb", items : [ "graph_add_Node_PB_Output", -1, "graph_add_Node_PB_Box" ] },
		];
    #endregion
    
    ////- Get
    
    function setCurrentPreview(_node = getFocusingNode()) {
        if(!_node) return;
    
        PANEL_PREVIEW.setNodePreview(_node);
    }

    function setTriggerPreview() {
        __temp_show = false;
        array_foreach(nodes_selecting, function(node, index) {
            if(index == 0) __temp_show = !node.previewable;
            node.setPreviewable(__temp_show);
            node.refreshNodeDisplay();
        });
    }

    function setTriggerParameter() {
        __temp_show = false;
        array_foreach(nodes_selecting, function(node, index) {
            if(index == 0) __temp_show = !node.show_parameter;
            node.setShowParameter(__temp_show);
            node.refreshNodeDisplay();
        });
    }

    function setTriggerRender() {
        __temp_active = false;
        array_foreach(nodes_selecting, function(node, index) {
            if(index == 0) __temp_active = !node.renderActive;
            node.renderActive = __temp_active;
        });
    }

    function setCurrentCanvas(_node = getFocusingNode()) {
        if(!_node) return;
    
        var _outp = -1;
        var surf  = -1;
    
        for( var i = 0; i < array_length(_node.outputs); i++ ) {
            if(_node.outputs[i].type != VALUE_TYPE.surface) continue;
            
            _outp = _node.outputs[i];
            surf  = _outp.getValue();
            break;
        }
    
        if(_outp == -1) return;
        if(!is_array(surf)) surf = [ surf ];
        
        var _canvas = nodeBuild("Node_Canvas", _node.x + _node.w + 64, _node.y).skipDefault();
        var _dim    = surface_get_dimension(surf[0]);
        
        _canvas.inputs[0].setValue(_dim);
        _canvas.attributes.dimension = _dim;
        _canvas.attributes.frames    = array_length(surf);
        _canvas.canvas_surface       = surface_array_clone(surf);
        
        _canvas.apply_surfaces();
    }

    function setCurrentCanvasBlend(_node = getFocusingNode()) {
        if(!_node) return;
    
        var _outp = -1;
        var surf = -1;
    
        for( var i = 0; i < array_length(_node.outputs); i++ ) {
            if(_node.outputs[i].type == VALUE_TYPE.surface) {
                _outp = _node.outputs[i];
                var _val = _node.outputs[i].getValue();
                if(is_array(_val))
                    surf  = _val[_node.preview_index];
                else
                    surf  = _val;
                break;
            }
        }
    
        if(_outp == -1) return;
    
        var _canvas = nodeBuild("Node_Canvas", _node.x, _node.y + _node.h + 64).skipDefault();
    
        _canvas.inputs[0].setValue([surface_get_width_safe(surf), surface_get_height_safe(surf)]);
        _canvas.inputs[5].setValue(true);
    
        var _blend = nodeBuild("Node_Blend", _node.x + _node.w + 64, _node.y).skipDefault();
        _blend.inputs[0].setFrom(_outp);
        _blend.inputs[1].setFrom(_canvas.outputs[0]);
    }
    
    function setFocusingNode(_node) { nodes_selecting = [ _node ]; refreshDraw(); return self; }
    
    function getFocusingNode() { return array_empty(nodes_selecting)? noone : nodes_selecting[0]; }
    
    function getFreeY(_x, _y) {
    	var gls = project.graphGrid.size;
    	var fre = [];
    	var _node;
    	
    	for( var i = 0, n = array_length(nodes_list); i < n; i++ ) {
    		_node = nodes_list[i];
    		if(!_node.active || _node.x + _node.w < _x || _node.x > _x) continue;
    		
    		_y = max(_y, _node.y + _node.h);
    	}
    	
    	return _y;
    }
    
    ////- Menus
    
    #region ++++++++++++++++ Actions +++++++++++++++
        function send_to_preview()    { setCurrentPreview(node_hover); }
        
        function inspector_panel()    {
            var pan = panelAdd("Panel_Inspector", true);
            pan.destroy_on_click_out = false;
            pan.content.setInspecting(node_hover);
            pan.content.locked = true;
        }
        
        function send_hover_to_export()  { doExport(node_hover); }
        function enter_group()           { PANEL_GRAPH.addContext(node_hover); }
        function hide_disconnected()     { hideDisconnected(); }
        
        
        function open_group_tab(group = node_hover) {
            if(group == noone) return;
            
            var graph = new Panel_Graph(project);
            panel.setContent(graph, true);
                                
            for( var i = 0; i < array_length(node_context); i++ ) 
                graph.addContext(node_context[i]);
            graph.addContext(group);
            
            setFocus(panel);
        }
        
        function set_as_tool() {
            if(node_hover == noone || node_hover.group == noone) return;
            node_hover.group.setTool(node_hover);
            refreshDraw();
        }
    #endregion
    
    #region ++++++++++++ Colors Setters ++++++++++++
    	__junction_hovering = noone;
        
        function setSelectingNodeColor(c) { 
            __temp_color = c;
            
            if(node_hover) node_hover.attributes.color = __temp_color;
            array_foreach(nodes_selecting, function(node) /*=>*/ { node.attributes.color = __temp_color; });
            
            refreshDraw();
        }
        
        function setSelectingJuncColor(c) {
            if(__junction_hovering == noone) return; 
            __junction_hovering.setColor(c);
            
            if(__junction_hovering.value_from != noone)
            	__junction_hovering.value_from.setColor(c);
            	
            refreshDraw();
        }
    #endregion
    
    #region ++++++++++++++++ Menus +++++++++++++++++
	    MENUITEM_CONDITIONS[$ "graph_select_node"]     = function() /*=>*/ {return array_length(PANEL_GRAPH.nodes_selecting) > 0};
	    MENUITEM_CONDITIONS[$ "graph_select_group"]    = function() /*=>*/ {return is(PANEL_GRAPH.node_hover, Node_Collection)};
	    MENUITEM_CONDITIONS[$ "graph_select_instance"] = function() /*=>*/ {return is(PANEL_GRAPH.node_hover, Node_Collection) && PANEL_GRAPH.node_hover.instanceBase != undefined};
    	MENUITEM_CONDITIONS[$ "graph_select_in_group"] = function() /*=>*/ {return PANEL_GRAPH.node_hover.group != noone};
    	MENUITEM_CONDITIONS[$ "graph_select_multiple"] = function() /*=>*/ {return array_length(PANEL_GRAPH.nodes_selecting) > 1};
    	
    	MENUITEM_CONDITIONS[$ "graph_context_group"]    = function() /*=>*/ {return is(PANEL_GRAPH.getCurrentContext(), Node_Collection)};
    	MENUITEM_CONDITIONS[$ "graph_context_group_pb"] = function() /*=>*/ {return is(PANEL_GRAPH.getCurrentContext(), Node_Pixel_Builder)};
    	
	    global.menuItems_graph_node_select = [
	    	"graph_group_node_color", 
	    	-1, 
	    	"graph_preview_hovering_node", 
	    	"graph_preview_window", 
	    	"graph_inspect",
	    	"graph_export_hover",
	    	-1, 
	    	"graph_node_display", 
	    	"graph_toggle_render", 
	    	"graph_hide_disconnected",
	    	{ cond : "graph_select_group",    items : [ -1, "graph_enter_group", "graph_open_in_new_tab", "graph_ungroup", "graph_update" ] },
	    	{ cond : "graph_select_instance", items : [     "graph_uninstance"  ] },
	    	{ cond : "graph_select_in_group", items : [     "graph_set_as_tool" ] },
	    	{ cond : "graph_select_multiple", items : [ -1, "graph_group", "graph_add_Node_Frame" ] },
	    	-1, 
	    	"graph_rename", 
	    	"graph_delete_merge", 
	    	"graph_delete_break", 
	    	"graph_duplicate", 
	    	"graph_copy",
	    	-1, 
	    	"graph_replace_node", 
	    	"graph_add_Node_Transform", 
	    	"graph_canvas",
	    	{ cond : "graph_select_multiple", items : [ -1, "graph_group_align", "graph_add_Node_Blend", "graph_add_Node_Composite", "graph_add_Node_Array" ] },
    	];
    	
	    global.menuItems_graph_junction_select = [
	    	"graph_group_junction_color",
    	];
    	
	    global.menuItems_graph_connection_select = [
	    	"graph_group_junction_color",
	    	"graph_create_tunnel",
	    	-1,
	    	"graph_copy", 
			"graph_paste", 
    	];
    	
	    global.menuItems_graph_empty = [
	    	"graph_copy", 
			"graph_paste", 
    	];
    	
	#endregion
    
    ////- Project
    
    static setProject = function(_project) {
        project         = _project;
        nodes_list      = _project.nodes;
        refreshDraw();
        connect_related = noone;
        connection_draw_update = true;
        
        setTitle();
        run_in(10, function() /*=>*/ { setSlideShow(0); });
    } 
    
    ////- Views
    
    function onFocusBegin() {
        PANEL_GRAPH = self; 
        if(applyGlobal)
        	PROJECT = project;
        
        nodes_select_drag = 0;
    } 
    
    function focusNode(_node) {
        if(_node == noone) { nodes_selecting = []; return; }
        
        setContext(_node);
        nodes_selecting = [ _node ];
        fullView();
    } 
    
    fullView_zoom = false;
    function fullView() { 
    	toCenterNode(array_empty(nodes_selecting)? nodes_list : nodes_selecting); 
    	fullView_zoom = !fullView_zoom;
    }
    
    function dragGraph() {
        if(graph_autopan) {
            graph_x = lerp_float(graph_x, graph_pan_x_to, graph_pan_speed, 1);
            graph_y = lerp_float(graph_y, graph_pan_y_to, graph_pan_speed, 1);
            
            if(graph_pan_s_to > 0) {
            	var _s = graph_s;
            	var cx = w/2;
            	var cy = h/2;
            	
            	graph_s  = lerp_float(graph_s, graph_pan_s_to, graph_pan_speed);
            	graph_x += (cx - graph_x * graph_s) / graph_s - (cx - graph_x * _s) / _s;
            	graph_y += (cy - graph_y * graph_s) / graph_s - (cy - graph_y * _s) / _s;
            	
            	graph_s_to = graph_pan_s_to;
            }
            
            if(graph_x == graph_pan_x_to && graph_y == graph_pan_y_to)
                graph_autopan = false;
            return;
        }
        
        if(graph_dragging) {
            if(!MOUSE_WRAPPING) {
                var dx = mx - graph_drag_mx; 
                var dy = my - graph_drag_my;
            
                graph_x += dx / graph_s;
                graph_y += dy / graph_s;
            }
                
            graph_drag_mx = mx;
            graph_drag_my = my;
            setMouseWrap();
            
            if(mouse_release(drag_key)) { 
                graph_dragging = false;
                view_pan_tool  = false;
            }
        }
        
        if(graph_zooming) {
            if(!MOUSE_WRAPPING) {
                var dy = -(my - graph_zoom_m) / 200;
                
                var _s = graph_s;
                
                graph_s_to = clamp(graph_s_to * (1 + dy), scale[0], array_last(scale));
                graph_s    = graph_s_to;
                
                if(_s != graph_s) {
                    var mb_x = (graph_zoom_mx - graph_x * _s) / _s;
                    var ma_x = (graph_zoom_mx - graph_x * graph_s) / graph_s;
                    var md_x = ma_x - mb_x;
                    graph_x += md_x;
                
                    var mb_y = (graph_zoom_my - graph_y * _s) / _s;
                    var ma_y = (graph_zoom_my - graph_y * graph_s) / graph_s;
                    var md_y = ma_y - mb_y;
                    graph_y += md_y;
                }
            }
                
            graph_zoom_m = my;
            setMouseWrap();
            
            if(mouse_release(drag_key)) {
                graph_zooming  = false;
                view_zoom_tool = false;
            }
        }
        
        if(mouse_on_graph && pFOCUS && graph_draggable) {
            var _doDragging = false;
            var _doZooming  = false;
            
            if(mouse_press(PREFERENCES.pan_mouse_key)) {
                _doDragging = true;
                drag_key = PREFERENCES.pan_mouse_key;
                
            } else if(mouse_press(mb_left) && graph_dragging_key) {
                _doDragging = true;
                drag_key = mb_left;
                
            } else if(mouse_press(mb_left) && graph_zooming_key) {
                _doZooming = true;
                drag_key = mb_left;
            }
            
            if(_doDragging) {
                graph_dragging = true;    
                graph_drag_mx  = mx;
                graph_drag_my  = my;
                graph_drag_sx  = graph_x;
                graph_drag_sy  = graph_y;
            }
            
            if(_doZooming) {
                graph_zooming  = true;    
                graph_zoom_mx  = mx;
                graph_zoom_my  = my;
                graph_zoom_m   = my;
                graph_zoom_s   = graph_s;
            }
        }
        
        var _s = graph_s;
        
        if(mouse_on_graph && pHOVER && graph_draggable) {
            if((!key_mod_press_any() || key_mod_press(CTRL)) && MOUSE_WHEEL != 0) {
	            if(MOUSE_WHEEL == -1) {
	            	if(graph_s_to > array_last(scale)) graph_s_to = array_last(scale);
	            	
	                for( var i = 1, n = array_length(scale); i < n; i++ ) {
	                    if(scale[i - 1] < graph_s_to && graph_s_to <= scale[i]) {
	                        graph_s_to = scale[i - 1];
	                        break;
	                    }
	                }
	                
	            } else if(MOUSE_WHEEL == 1) { 
	                if(graph_s_to < array_first(scale)) graph_s_to = array_first(scale);
	            	
	            	for( var i = 1, n = array_length(scale); i < n; i++ ) {
	                    if(scale[i - 1] <= graph_s_to && graph_s_to < scale[i]) {
	                        graph_s_to = scale[i];
	                        break;
	                    }
	                }
	            } else
	            	graph_s_to = clamp(graph_s_to + MOUSE_WHEEL * .1, scale[0], array_last(scale));
            }
            
            graph_s = lerp_float(graph_s, graph_s_to, PREFERENCES.graph_zoom_smoooth);
        }
        
        if(_s != graph_s) {
            graph_x += (mx - graph_x * graph_s) / graph_s - (mx - graph_x * _s) / _s;
            graph_y += (my - graph_y * graph_s) / graph_s - (my - graph_y * _s) / _s;
            
        } else {
	        graph_x = round(graph_x);
	        graph_y = round(graph_y);
        }
        
        graph_draggable = true;
    }
    
    function autoPanTo(_x, _y, _speed = 32, _zoom = 0) {
        graph_autopan   = true;
        graph_pan_x_to  = _x;
        graph_pan_y_to  = _y;
        graph_pan_s_to  = _zoom;
        graph_pan_speed = _speed;
    }
    
    function setSlideShow(index, skip = false) {
        var _targ = project.slideShowSet(index);
    	if(_targ == noone) return;
        
        setContext(_targ);
        
        var _tz = _targ.slide_zoom;
        var _gs = _tz > 0? _tz : graph_s;
        var _gx = w / 2 / _gs;
        var _gy = h / 2 / _gs;
        
        var _tx = _gx;
        var _ty = _gy;
        
        switch(_targ.slide_anchor) {
            case 0 :
                _tx = _gx - _targ.x;
                _ty = _gy - _targ.y;
                break;
                
            case 1 :
                _tx = 64 * _gs - _targ.x;
                _ty = 64 * _gs - _targ.y;
                break;
                
        }
        
        if(skip) {
            graph_x = _tx;
            graph_y = _ty;
            
        } else
            autoPanTo(_tx, _ty, _targ.slide_speed, _tz);
    }
    
    ////- Context
    
    function getCurrentContext() { return array_empty(node_context)? noone : array_last(node_context); }
    
    function getNodeList(cont = getCurrentContext()) { return cont == noone? project.nodes : cont.getNodeList(); }
    
    function setContext(context) {
        if(context.group == getCurrentContext()) return;
        
        node_context = [];
        nodes_list   = project.nodes;
        refreshDraw();
        
        var _ctxs = [];
        var _ctx  = context;
        
        while(_ctx.group != noone) {
            array_insert(_ctxs, 0, _ctx.group);
            _ctx = _ctx.group;
        }
        
        for (var i = 0, n = array_length(_ctxs); i < n; i++) 
            addContext(_ctxs[i]);
    }
    
    function resetContext() {
        node_context = [];
        nodes_list   = project.nodes;
        refreshDraw();
        
        toCenterNode();
    }
    
    function addContext(_node) {
        nodes_list = _node.nodes;
        array_push(node_context, _node);
        
        node_dragging   = noone;
        nodes_selecting = [];
        selection_block = 1;
        
        setContextFrame(false, _node);
        toCenterNode();
        
        return self;
    }
    
    function setContextFrame(dirr, node) {
        context_framing = true;
        
        context_frame_direct    = dirr;
        context_frame_progress    = 0;
        
        context_frame_sx        = w / 2 - 8;
        context_frame_sy        = h / 2 - 8;
        context_frame_ex        = context_frame_sx + 16;
        context_frame_ey        = context_frame_sy + 16;
        
        var gr_x = graph_x * graph_s;
        var gr_y = graph_y * graph_s;
        
        context_frame_sx        = gr_x + node.x * graph_s;
        context_frame_sy        = gr_y + node.y * graph_s;
        context_frame_ex        = context_frame_sx + node.w * graph_s;
        context_frame_ey        = context_frame_sy + node.h * graph_s;
    }
    
    function exitContext() {
    	if(getCurrentContext() == noone) return;
    	
    	array_pop(node_context);
    	nodes_list = getNodeList();
    	
        node_dragging   = noone;
        nodes_selecting = [];
        selection_block = 1;
        
        toCenterNode();
    }
    
    ////- Step
    
    function stepBegin() { //
        var gr_x = graph_x * graph_s;
        var gr_y = graph_y * graph_s;
        var m_x  = (mx - gr_x) / graph_s;
        var m_y  = (my - gr_y) / graph_s;
        mouse_graph_x = m_x;
        mouse_graph_y = m_y;
        
        mouse_grid_x = round(m_x / project.graphGrid.size) * project.graphGrid.size;
        mouse_grid_y = round(m_y / project.graphGrid.size) * project.graphGrid.size;
        
        setTitle();
    } 
    
    function nodeWrangler() {
    	var _focus = pFOCUS && !view_hovering;
    	
        if(node_drag_connect) {
        	node_drag_connect.drawActive(2);
        	connection_param.setDraw(1, bg_color);
        	
    		var _from = node_drag_connect.getOutput(), _to;
    		var _draw = true;
    		
    		if(_from) {
	        	if(node_hovering != noone) {
	        		_to = node_hovering.getInput(mouse_graph_y, _from, 0, true);
	        		
	        		if(_to && _to.isConnectable(_from)) {
	        			node_hovering.drawActive(2);
	        			
	        			_from.drawConnectionMouse(connection_param, _to.x, _to.y, _to);
	        			_draw = false;
	        			
	        			if(mouse_release(mb_left))
	        				_to.setFrom(_from);
	        		}
	        	} 
	        	
	        	if(_draw) {
	        		draw_set_color(COLORS.node_border_file_drop);
	    			draw_line(_from.x, _from.y, mx, my);
	        	}
    		}
        	
        	if(mouse_release(mb_left))
            	node_drag_connect = noone;
        }
        
        if(node_drag_removing) {
        	draw_circle_ui(mx, my, ui(8), 0, COLORS._main_value_negative, .25);
        	
        	if(junction_hovering != noone)
        		junction_hovering.removeFrom();
        	
        	if(mouse_release(mb_right))
            	node_drag_removing = false;
        }
        
        if(!_focus || !mouse_on_graph) return;
        if(value_focus != noone)       return;
        
        var _node = getFocusingNode();
        if(_node && mouse_press(mb_left) && key_mod_check(MOD_KEY.ctrl))
        	node_drag_connect = _node;
        
        if(mouse_press(mb_right) && key_mod_check(MOD_KEY.ctrl)) {
        	node_drag_removing = true;
        	node_drag_remove   = [];
        }
    }
    
    ////- Draw
    
    function dragNodes() {
    	var _focus = pFOCUS && !view_hovering;
        var gr_x   = graph_x * graph_s;
        var gr_y   = graph_y * graph_s;
        
    	if(mouse_press(mb_left)) {
            if(node_drag_add && node_dragging && junction_hovering != noone) {
            	var _jfr = junction_hovering.value_from;
            	var _jto = junction_hovering;
            	var _shy = undefined;
            	
            	for( var i = 0, n = array_length(node_dragging.inputs); i < n; i++ ) {
            		var _inp = node_dragging.inputs[i];
            		if((value_bit(_inp.type) & value_bit(_jfr.type) != 0) && _inp.setFrom(_jfr)) { 
            			_shy = _jfr.node.y; 
            			break; 
            		}
            	}
            	
            	for( var i = 0, n = array_length(node_dragging.outputs); i < n; i++ ) {
            		if(_jto.setFrom(node_dragging.outputs[i])) {
            			_shy = _shy == undefined? _jto.node.y : (_shy + _jto.node.y) / 2;
            			break;
            		}
            	}
            	
            }
            
            if(node_dragging) nodes_selecting = [ node_dragging ];
            node_dragging   = noone;
            node_drag_add   = false;
        }
        
        for( var i = 0, n = array_length(nodes_list); i < n; i++ ) {
        	var _node = nodes_list[i];
            if(is(_node, Node_Collection_Inline)) 
            	_node.groupCheck(gr_x, gr_y, graph_s, mx, my);
        }
        
        if(node_dragging) {
            addKeyOverlay("Dragging node(s)", [[ "Ctrl", "Disable snapping" ]]);
            refreshDraw(2);
            
            var _mgx = mouse_graph_x;
            var _mgy = mouse_graph_y;
            var _grd = project.graphGrid.size;
            
            var nx = node_drag_sx + (_mgx - node_drag_mx);
            var ny = node_drag_sy + (_mgy - node_drag_my);
            
            var sn = !key_mod_press(CTRL) && project.graphGrid.snap;
            
            if(sn) {
                nx = value_snap(nx, _grd);
                ny = value_snap(ny, _grd);
            }
            
            if(node_drag_ox == -1 || node_drag_oy == -1) {
                node_drag_ox = nx;
                node_drag_oy = ny;
                
            } else if(nx != node_drag_ox || ny != node_drag_oy) {
                var dx = nx - node_drag_ox;
                var dy = ny - node_drag_oy;
                
                for( var i = 0, n = array_length(nodes_selecting); i < n; i++ ) {
                    var _node = nodes_selecting[i];
                    _node.moved = false;
                }
                
                for( var i = 0, n = array_length(nodes_selecting); i < n; i++ ) {
                    var _node = nodes_selecting[i];
                    var _nx   = _node.x + dx;
                    var _ny   = _node.y + dy;
                    
                    if(sn) {
		                _nx = value_snap(_nx, _grd);
		                _ny = value_snap(_ny, _grd);
		            }
                    
                    if(!_node.moved) _node.move(_nx, _ny);
                }
                   
                node_drag_ox = nx;
                node_drag_oy = ny;
            }
            
            if(!key_mod_press(SHIFT)) array_foreach(frame_draggings, function(f) /*=>*/ {return f.reFrame()});
            
            if(mouse_release(mb_left) && (nx != node_drag_sx || ny != node_drag_sy)) {
                var shfx = node_drag_sx - nx;
                var shfy = node_drag_sy - ny;
                
                UNDO_HOLDING = false;    
                for( var i = 0, n = array_length(nodes_selecting); i < n; i++ ) {
                    var _n = nodes_selecting[i];
                    if(_n == noone) continue;
                    recordAction(ACTION_TYPE.var_modify, _n, [ _n.x + shfx, "x", "node x position" ]);
                    recordAction(ACTION_TYPE.var_modify, _n, [ _n.y + shfy, "y", "node y position" ]);
                }
            }
            
            if(!node_drag_add && mouse_release(mb_left)) {
            	node_dragging   = noone;
            	frame_draggings = [];
            }
        }
        
        ////- Start Drag
        
		if(!_focus || !mouse_on_graph) return;
		if(cache_group_edit != noone)  return;
		if(value_focus != noone)       return;
		
        var _node = getFocusingNode();
		if(_node == noone || !_node.draggable)          return;
		if(key_mod_press(CTRL) || key_mod_press(SHIFT)) return;
        
        if(mouse_press(mb_left)) {
            node_dragging = _node;
            node_drag_mx  = mouse_graph_x;
            node_drag_my  = mouse_graph_y;
            node_drag_sx  = _node.x;
            node_drag_sy  = _node.y;
            
            node_drag_ox  = -1;
            node_drag_oy  = -1;
            
            frame_draggings = frame_hoverings;
        }
    }
    
    function drawBGBase() { //
    	draw_clear(bg_color);
    	
    	var gls = project.graphGrid.size;
        while(gls * graph_s < 8) gls *= 5;
        
    	if(OS == os_windows) {
        
	        shader_set(sh_panel_graph_grid);	
	        	shader_set_2("dimension", surface_get_dimension(surface_get_target()));
	        	shader_set_c("bgColor",   bg_color);
	        	
	        	shader_set_i("gridShow",      project.graphDisplay.show_grid);
	        	shader_set_f("gridSize",      gls);
	        	shader_set_c("gridColor",     project.graphGrid.color);
	        	shader_set_f("gridAlpha",     project.graphGrid.opacity);
	        	shader_set_i("gridOrigin",    project.graphGrid.show_origin);
	        	shader_set_f("gridHighlight", project.graphGrid.highlight);
	        	
	        	shader_set_2("graphPos",   [graph_x, graph_y]);
	        	shader_set_f("graphScale", graph_s);
	        	
	        	shader_set_i("glowShow", mouse_glow_rad > 0);
	        	shader_set_2("glowPos",  [ mouse_graph_x, mouse_graph_y ]);
	        	shader_set_f("glowRad",  mouse_glow_rad / graph_s);
	        	
	        	draw_empty();
	        shader_reset();
	        
	        mouse_glow_rad    = lerp_float(mouse_glow_rad, mouse_glow_rad_to, 5);
	        mouse_glow_rad_to = 0;
	        
	        return;
    	}
    	
        var gr_x  = graph_x * graph_s;
        var gr_y  = graph_y * graph_s;
        var gr_ls = gls * graph_s;
        var xx = -gr_ls - 1, xs = safe_mod(gr_x, gr_ls);
        var yy = -gr_ls - 1, ys = safe_mod(gr_y, gr_ls);
        
        draw_set_color(project.graphGrid.color);
        var aa  = graph_s < 0.25? .3 : .5;
        var oa  = project.graphGrid.opacity;
        var ori = project.graphGrid.show_origin;
        var hig = project.graphGrid.highlight;
        
        while(xx < w + gr_ls) { 
            draw_set_alpha( oa * aa * (1 + (round((xx + xs - gr_x) / gr_ls) % hig == 0) * 2) );
            draw_line(xx + xs, 0, xx + xs, h);
            xx += gr_ls;
        }
        
        while(yy < h + gr_ls) {
            draw_set_alpha( oa * aa * (1 + (round((yy + ys - gr_y) / gr_ls) % hig == 0) * 2) );
            draw_line(0, yy + ys, w, yy + ys);
            yy += gr_ls;
        }
        
        draw_set_alpha(.2);
        if(ori) {
        	draw_line(gr_x, 0, gr_x, h);
        	draw_line(0, gr_y, w, gr_y);
        }
        
        draw_set_alpha(1);
    } 
    
    function drawViewController() { //
        if(h < ui(96)) return;
        if(CAPTURING)  return;
    	
        view_hovering = false;
        if(!project.graphDisplay.show_view_control) return;
        
        var _side = project.graphDisplay.show_view_control == 1? 1 : -1;
        var _hab  = pHOVER && !view_pan_tool && !view_zoom_tool;
        
        var d3_view_wz = ui(16);
        
        var _d3x = project.graphDisplay.show_view_control == 1? 
                            ui(8) + d3_view_wz : 
                        w - ui(8) - d3_view_wz;
                        
        var _d3y = ui(8) + d3_view_wz + project.graphDisplay.show_topbar * topbar_height;
        var _hv  = false;
        
        if(_hab && point_in_circle(mx, my, _d3x, _d3y, d3_view_wz)) {
            _hv = true;
            view_hovering = true;
            
            if(mouse_press(mb_left, pFOCUS)) {
                drag_key = mb_left;
                graph_dragging = true;    
                graph_drag_mx  = mx;
                graph_drag_my  = my;
                graph_drag_sx  = graph_x;
                graph_drag_sy  = graph_y;
                
                view_pan_tool = true;
            }
        }
        
        if(view_pan_tool)
            _hv = true;
        
        draw_circle_ui(_d3x, _d3y, d3_view_wz, _hv? 0 : 0.02, COLORS._main_icon, 0.3);
        draw_sprite_ui(THEME.view_pan, 0, _d3x, _d3y, 1, 1, 0, view_pan_tool? COLORS._main_accent : COLORS._main_icon, 1);
        
        _d3x += (d3_view_wz + ui(4) + d3_view_wz) * _side;
        _hv  =  false;
        
        if(_hab && point_in_circle(mx, my, _d3x, _d3y, d3_view_wz)) {
            _hv = true;
            view_hovering = true;
            
            if(mouse_press(mb_left, pFOCUS)) {
                drag_key = mb_left;
                graph_zooming  = true;    
                graph_zoom_mx  = w / 2;
                graph_zoom_my  = h / 2;
                graph_zoom_m   = my;
                graph_zoom_s   = graph_s;
                
                view_zoom_tool = true;
            }
        }
        
        if(view_zoom_tool)
            _hv = true;
        
        draw_circle_ui(_d3x, _d3y, d3_view_wz, _hv? 0 : 0.02, COLORS._main_icon, 0.3);
        draw_sprite_ui(THEME.view_zoom, 0, _d3x, _d3y, 1, 1, 0, view_zoom_tool? COLORS._main_accent : COLORS._main_icon, 1);
        
        if(view_hovering && mouse_press(mb_right, pFOCUS)) {
        	mouse_on_graph = false;
        	menuCall("preview_view_controller", [ menuItem("Hide view controllers", function() /*=>*/ { project.graphDisplay.show_view_control = 0; }) ]);
        }
    } 
    
    function drawBasePreview() { //
        var gr_x = graph_x * graph_s;
        var gr_y = graph_y * graph_s;
        var _hov = false;
        
        for( var i = 0, n = array_length(nodes_list); i < n; i++ ) {
        	if(nodes_list[i].drawPreviewBackground == undefined) continue;
            var hh = nodes_list[i].drawPreviewBackground(gr_x, gr_y, mx, my, graph_s);
            _hov = _hov || hh;
        }
        
        return _hov;
    } 
    
    function drawCacheCheck(_x, _y, _s, _w, _h) {
    	var _upd = false;
    	
    	_upd = _upd || (pFOCUS && (mouse_click(mb_any) || mouse_release(mb_any) || keyboard_check_pressed(vk_anykey)));
    	_upd = _upd || draw_refresh; if(draw_refresh) draw_refresh--;
    	
    	_upd = _upd || connection_cache[$ "_x"] != _x; connection_cache[$ "_x"] = _x;
		_upd = _upd || connection_cache[$ "_y"] != _y; connection_cache[$ "_y"] = _y;
		_upd = _upd || connection_cache[$ "_s"] != _s; connection_cache[$ "_s"] = _s;
		_upd = _upd || connection_cache[$ "_w"] != _w; connection_cache[$ "_w"] = _w;
		_upd = _upd || connection_cache[$ "_h"] != _h; connection_cache[$ "_h"] = _h;
		
		_upd = _upd || connection_cache[$ "type"]        != project.graphConnection.type;
		               connection_cache[$ "type"]        =  project.graphConnection.type;
		        
		_upd = _upd || connection_cache[$ "line_width"]  != project.graphConnection.line_width;
		               connection_cache[$ "line_width"]  =  project.graphConnection.line_width;
		        
		_upd = _upd || connection_cache[$ "line_corner"] != project.graphConnection.line_corner;
		               connection_cache[$ "line_corner"] =  project.graphConnection.line_corner;
		        
		_upd = _upd || connection_cache[$ "line_extend"] != project.graphConnection.line_extend;
		               connection_cache[$ "line_extend"] =  project.graphConnection.line_extend;
		        
		_upd = _upd || connection_cache[$ "line_aa"]     != project.graphConnection.line_aa;
		               connection_cache[$ "line_aa"]     =  project.graphConnection.line_aa;
		
		connection_draw_update = connection_draw_update || _upd;
		
		_upd = _upd || connection_cache[$ "frame"]     != GLOBAL_CURRENT_FRAME;
				       connection_cache[$ "frame"]     =  GLOBAL_CURRENT_FRAME;
				       
    	_upd = _upd || key_mod_up(ALT) || key_mod_press(ALT);
		node_surface_update    = node_surface_update || _upd;
    }
    
    function drawNodes() { 
        if(selection_block-- > 0) return;
        
        #region data
        	var log = 0, t = get_timer();
        	
	        var _highType   = project.graphConnection.line_highlight;
	        var _highlight  = !array_empty(nodes_selecting);
	        	_highlight &= (_highType == 1 && key_mod_press(ALT)) || _highType == 2;
	        project.graphDisplay.highlight = _highlight;
	        
	        var _focus = pFOCUS && !view_hovering;
	        var gr_x   = graph_x * graph_s;
	        var gr_y   = graph_y * graph_s;
	        
	        __gr_x = gr_x; 
			__gr_y = gr_y;
			__gr_s = graph_s;
			__gr_w = w;
			__gr_h = h;
			
			__mx = mx;
			__my = my;
			
			__self = self;
			
			drawCacheCheck(__gr_x, __gr_y, __gr_s, __gr_w, __gr_h);
		#endregion
		
        #region node list filter
	        var _node_active = nodes_list;
	        array_foreach(_node_active, function(_n) /*=>*/ { _n.is_selecting = false; });
	        if(project.graphDisplay.show_control) _node_active = array_filter(nodes_list, function(_n) /*=>*/ {return _n.active && _n.visible});
	        else _node_active = array_filter(nodes_list, function(_n) /*=>*/ {return _n.active && _n.visible && !_n.is_controller});
        
	        var _node_draw = array_filter( _node_active, function(_n) /*=>*/ {
	        	_n.preDraw(__gr_x, __gr_y, __mx, __my, __gr_s);
	        	var _cull = _n.cullCheck(__gr_x, __gr_y, __gr_s, -32, -32, __gr_w + 32, __gr_h + 64);
	        	return _n.active && _cull;
	    	});
	    #endregion
        
        #region drawNodeBG
	        _frame_hovering  = frame_hovering;
	         frame_hovering  = noone;
	         frame_hoverings = [];
	        _node_frames     = array_filter(_node_draw, function(_n) /*=>*/ {return is(_n, Node_Frame)});
	        
	        array_foreach(_node_frames, function(_n) /*=>*/ { 
	        	var _hov = _n.drawNodeBG(__gr_x, __gr_y, __mx, __my, __gr_s, __self);
	        	if(_hov) {
	        		frame_hovering = _n; 
	        		array_push(frame_hoverings, _n);
	        	}
	        });
	        
	        array_foreach(_node_draw, function(_n) /*=>*/ { 
	        	if(is(_n, Node_Frame)) return;
	        	
	        	_n.active_draw_index = -1;
	        	if(array_length(_n.inputDisplayGroup))
	        		_n.drawInputGroup(__gr_x, __gr_y, __mx, __my, __gr_s);
	        	
	        	if(_n.drawNodeBG != undefined && _n.drawNodeBG(__gr_x, __gr_y, __mx, __my, __gr_s)) 
	        		frame_hovering = _n; 
	        });
        #endregion
        
        #region node_hovering
	        node_hovering = noone;
	        if(pHOVER) array_foreach(_node_draw, function(_n) /*=>*/ { 
	        	_n.branch_drawing = false;
	        	if(_n.pointIn(__gr_x, __gr_y, __mx, __my, __gr_s))
	                node_hovering = _n;
	        });
	        
	        if(node_hovering != noone) {
	            _HOVERING_ELEMENT = node_hovering;
	            
	            if(_focus && node_hovering.onDoubleClick != -1) {
	            	if(PREFERENCES.panel_graph_group_require_shift && key_mod_press(SHIFT))
	            		CURSOR_SPRITE = THEME.group_s;
	            	
		        	if(DOUBLE_CLICK && node_hovering.onDoubleClick(self)) {
		                DOUBLE_CLICK  = false;
		                node_hovering = noone;
		            }
	            }
	        }
	        
	        if(node_hovering && node_hovering.onDrawHover) node_hovering.onDrawHover(gr_x, gr_y, mx, my, graph_s);
        #endregion
        
        #region ++++++++++++ interaction ++++++++++++
        	if(value_focus && !value_focus.node.active) value_focus = noone;
        	
	        if(mouse_on_graph && pHOVER) {
	        	if(node_dragging == noone && value_dragging == noone) {
	    			     if(value_focus)   addKeyOverlay("Select junction(s)", [[ "Shift", "Peek content"     ]]);
	        		else if(node_hovering) addKeyOverlay("Select node(s)",     [[ "Shift", "Toggle selection" ]]);
	        	}
            	
	            // Select
                var _anc = nodes_select_anchor;
                if(mouse_press(mb_left, _focus)) _anc = noone;
                
                if(NODE_DROPPER_TARGET != noone && node_hovering) {
                    node_hovering.draw_droppable = true;
                    if(mouse_press(mb_left, NODE_DROPPER_TARGET_CAN)) {
                        NODE_DROPPER_TARGET.expression += node_hovering.internalName;
                        NODE_DROPPER_TARGET.expressionUpdate(); 
                    }
                    
                } else if(mouse_press(mb_left, _focus)) {
                	if(array_valid(frame_hovering)) array_foreach(frame_hovering, function(f) /*=>*/ {return f.getCoveringNodes(nodes_list)});
                	if(is(node_hovering, Node_Frame)) node_hovering.getCoveringNodes(nodes_list);
                	
                    if(key_mod_press(SHIFT)) { // Select Multiple
                        if(node_hovering) array_toggle(nodes_selecting, node_hovering);
                        else nodes_selecting = [];
                            
                    } else if(value_focus || node_hovering == noone) { // Select Nothing
                        nodes_selecting = [];
                        
                        if(DOUBLE_CLICK) {
                        	var _ctx = getCurrentContext();
                        	
                        	if(!PANEL_INSPECTOR.locked) PANEL_INSPECTOR.inspecting = _ctx; 
                        	if(_ctx || !array_empty(project.globalLayer_nodes)) PANEL_PREVIEW.setNodePreview(_ctx);
                        }
                    
                    } else if(cache_group_edit != noone) { // Edit Cache Group
                    	var _cache = cache_group_edit;
                    	if(node_hovering == _cache) {
                    		cache_group_edit = noone;
                    		
                    	} else {
	                    	if(_cache.containNode(node_hovering))
	                    		_cache.removeNode(node_hovering);
	                    	else 
	                    		_cache.addNode(node_hovering);
	                    		
	                    	_cache.refreshCacheGroup();
	                    	_cache.refreshGroupBG(true);
                    	}
                    	
                    } else if(DOUBLE_CLICK) { // Double Click on Node
                        PANEL_PREVIEW.setNodePreview(node_hovering);
                        
                        if(PREFERENCES.inspector_focus_on_double_click) {
                            if(PANEL_INSPECTOR.panel && struct_has(PANEL_INSPECTOR.panel, "switchContent"))
                                PANEL_INSPECTOR.panel.switchContent(PANEL_INSPECTOR);
                        }
                        
                    } else { // Single Click on Node
                    	var hover_selected = array_exists(nodes_selecting, node_hovering);
                        if(!hover_selected) nodes_selecting = [ node_hovering ];
                        
                        if(array_length(nodes_selecting) > 1)
                            _anc = nodes_select_anchor == node_hovering? noone : node_hovering;
                            
                        if(is(node_hovering, Node_Frame) && key_mod_press(CTRL)) { // Select Everything in Frame
                        	nodes_selecting = [ node_hovering ];
                        	array_append(nodes_selecting, node_hovering.__nodes);
                        }
                        
                        if(key_mod_press(ALT) && !array_empty(nodes_selecting)) { // Alt copy
	                    	var cln = nodeClone(nodes_selecting);
                    		nodes_selecting = array_clone(cln, 1);
	                    } 
                    }
                    
                    if(WIDGET_CURRENT) WIDGET_CURRENT.deactivate();
                    if(array_valid(nodes_selecting)) array_foreach(nodes_selecting, function(n) /*=>*/ { bringNodeToFront(n) });
                }
                
                nodes_select_anchor = _anc;
            
	            if(mouse_press(mb_right, _focus) && !key_mod_press_any()) {
	                node_hover = node_hovering;    
	                __junction_hovering = noone;
	                
	                if(value_focus) {
	                    // print($"Right click value focus {value_focus}");
	                    
	                    __junction_hovering = value_focus;
	                    
	                    var menu = menuItems_gen("graph_junction_select");
	                    
	                    if(value_focus.connect_type == CONNECT_TYPE.output) {
	                        var sep = false;
	                        
	                        for( var i = 0, n = array_length(value_focus.value_to); i < n; i++ ) {
	                            if(!sep) { array_push(menu, -1); sep = true; }
	                            
	                            var _to = value_focus.value_to[i];
	                            var _lb = $"[{_to.node.display_name}] {_to.getName()}";
	                            array_push(menu, menuItem(_lb, function(data) /*=>*/ { data.juncTo.removeFrom(); }, THEME.cross, noone, noone, { juncTo: _to }));
	                        }
	                        
	                        for( var i = 0, n = array_length(value_focus.value_to_loop); i < n; i++ ) {
	                            if(!sep) { array_push(menu, -1); sep = true; }
	                            
	                            var _to = value_focus.value_to_loop[i];
	                            var _lb = $"[{_to.junc_in.node.display_name}] {_to.junc_in.getName()}";
	                            array_push(menu, menuItem(_lb, function(data) /*=>*/ { data.juncTo.destroy(); }, _to.icon_24, noone, noone, { juncTo: _to }));
	                        }
	                    } else {
	                        var sep = false;
	                            
	                        if(value_focus.value_from) {
	                            if(!sep) { array_push(menu, -1); sep = true; }
	                            
	                            var _jun = value_focus.value_from;
	                            var _lb  = $"[{_jun.node.display_name}] {_jun.getName()}";
	                            array_push(menu, menuItem(_lb, function() /*=>*/ { __junction_hovering.removeFrom(); }, THEME.cross));
	                        }
	                            
	                        if(value_focus.value_from_loop) {
	                            if(!sep) { array_push(menu, -1); sep = true; }
	                            
	                            var _jun = value_focus.value_from_loop.junc_out;
	                            var _lb  = $"[{_jun.node.display_name}] {_jun.getName()}";
	                            array_push(menu, menuItem(_lb, function() /*=>*/ { __junction_hovering.removeFromLoop(); }, value_focus.value_from_loop.icon_24));
	                        }
	                    }
	                    
	                    menuCall("graph_junction_select", menu);
	                    
	                } else if(node_hover && node_hover.draggable) {
	                    menuCall("graph_node_select", menuItems_gen("graph_node_select"));
	                    
	                } else if(node_hover == noone && junction_hovering == noone) {
	                    var ctx     = is(frame_hovering, Node_Collection_Inline)? frame_hovering : getCurrentContext();
	                    var _diaAdd = callAddDialog(ctx);
	                    
	                	var menu = menuItems_gen("graph_empty");
	                    var _dia = menuCall("graph_empty", menu, o_dialog_add_node.dialog_x - ui(8), 
	                                                             o_dialog_add_node.dialog_y + ui(4), fa_right );
	                    _dia.passthrough = true;
	                    setFocus(_diaAdd, "Dialog");
	                    
	                } else if(node_hover == noone) {
	                    __junction_hovering = junction_hovering;
	                    
	                    var ctx     = is(frame_hovering, Node_Collection_Inline)? frame_hovering : getCurrentContext();
	                    var _diaAdd = callAddDialog(ctx);
	                    
	                    var menu = menuItems_gen("graph_connection_select");
	                    if(is(junction_hovering, Node_Feedback_Inline)) {
	                        var _jun = junction_hovering.junc_out;
	                        array_push(menu, menuItem($"[{_jun.node.display_name}] {_jun.getName()}", 
	                        	function(j) /*=>*/ { j.destroy(); }, THEME.feedback).setParam(__junction_hovering));
	                        
	                    } else {
	                        var _jun = junction_hovering.value_from;
	                        array_push(menu, menuItem($"[{_jun.node.display_name}] {_jun.getName()}", 
	                        	function(j) /*=>*/ { j.removeFrom(); }, THEME.cross).setParam(__junction_hovering));
	                    }
	                    
	                    var _dia = menuCall("graph_connection_select", menu, o_dialog_add_node.dialog_x - ui(8), 
	                                                                         o_dialog_add_node.dialog_y + ui(4), fa_right );
	                    _dia.passthrough = true;
	                    setFocus(_diaAdd, "Dialog");
	                }
	            } 
	            
	            if(is(frame_hovering, Node_Collection_Inline) && DOUBLE_CLICK && array_empty(nodes_selecting)) { //
	                nodes_selecting = [ frame_hovering ];
	                
	                if(frame_hovering.previewable) PANEL_PREVIEW.setNodePreview(frame_hovering);
	            } 
	        }
	        
	        dragNodes();
	        nodeWrangler();
	        
	        if(_focus && mouse_on_graph && junction_hovering != noone && DOUBLE_CLICK) {
                var _mx = value_snap(mouse_graph_x,   project.graphGrid.size);
                var _my = value_snap(mouse_graph_y-8, project.graphGrid.size);
                
                var _pin = nodeBuild("Node_Pin", _mx, _my).skipDefault();
                _pin.inputs[0].setFrom(junction_hovering.value_from);
                junction_hovering.setFrom(_pin.outputs[0]);
	        } 
        #endregion
        
        #region drawActive
	        array_foreach(nodes_selecting, function(_n) /*=>*/ { _n.drawActive(instanceof(_n) == FOCUS_STR); _n.is_selecting = true; });
	        if(nodes_select_anchor) nodes_select_anchor.active_draw_anchor = true;
		#endregion
        
		#region draw connections
	        var aa = floor(min(8192 / w, 8192 / h, project.graphConnection.line_aa));
	        
	        connection_draw_update |= !surface_valid(connection_surface_cc, w * aa, h * aa);
	        connection_surface    = surface_verify(connection_surface,    w * aa, h * aa);
	        connection_surface_cc = surface_verify(connection_surface_cc, w * aa, h * aa);
	        connection_surface_aa = surface_verify(connection_surface_aa, w,      h     );
	        
	        __hov = noone;
	        
	        connection_param.setPos(gr_x, gr_y, graph_s, mx, my);
	        connection_param.setBoundary(-64, -64, w + 64, h + 64);
	        connection_param.setDraw(aa, bg_color);
	        
	        if(connection_draw_update || pHOVER) {
				connection_param.active    = pHOVER && (node_dragging == noone || node_drag_add);
				connection_param.checkNode = node_dragging != noone && node_drag_add? node_dragging : noone;
		        connection_param.setProp(array_length(_node_active), project.graphDisplay.highlight);
		        
		        surface_set_target(connection_surface_cc);
		        	if(connection_draw_update) DRAW_CLEAR
			    	
			        array_foreach(_node_active, function(n) /*=>*/ {
			        	var _hov = n.drawConnections(connection_param, connection_draw_update);
			            if(is_struct(_hov)) __hov = _hov;
			        });
			        
			        connection_draw_update--;
			    surface_reset_target();
	        }
	        
	        surface_set_target(connection_surface);
		        DRAW_CLEAR
		    	
		    	draw_surface(connection_surface_cc, 0, 0);
		        if(__hov) drawJuncConnection(__hov.value_from, __hov, connection_param, 1 + (node_drag_add && node_dragging));
		        
		        if(value_dragging && connection_draw_mouse != noone && !key_mod_press(SHIFT)) {
		            var _cmx = connection_draw_mouse[0];
		            var _cmy = connection_draw_mouse[1];
		            var _cmt = connection_draw_target;
		            
		            if(array_empty(value_draggings)) {
		                value_dragging.drawConnectionMouse(connection_param, _cmx, _cmy, _cmt);
		                
		            } else {
		                var _stIndex = array_find(value_draggings, value_dragging);
		            	var _hh = 16 * graph_s;
		            	
		                for( var i = 0, n = array_length(value_draggings); i < n; i++ ) {
		                    var _dmx = _cmx;
		                    var _dmy = value_draggings[i].connect_type == CONNECT_TYPE.output? _cmy + (i - _stIndex) * _hh : _cmy;
		                
		                    value_draggings[i].drawConnectionMouse(connection_param, _dmx, _dmy, _cmt);
		                }
		            }
		            
		        } else if(add_node_draw_junc != noone) {
		        	
		        	if(!instance_exists(o_dialog_add_node))
		        		add_node_draw_junc = noone;
		        	else {
		        		var _amx = gr_x + add_node_draw_x * graph_s;
		        		var _amy = gr_y + add_node_draw_y * graph_s;
		        		
		        		add_node_draw_junc.drawConnectionMouse(connection_param, _amx, _amy);
		        	}
		        } 
		        
	        surface_reset_target();
	        
	        gpu_set_texfilter(true);
	        surface_set_shader(connection_surface_aa, sh_downsample);
	            shader_set_f("down", aa);
	            shader_set_f("dimension",  w, h);
				shader_set_f("cornerDis",  0.5);
				shader_set_f("mixAmo",     1);
				
	            shader_set_dim("dimension", connection_surface);
	            draw_surface_safe(connection_surface);
	        surface_reset_shader();
	        gpu_set_texfilter(false);
	        
	        BLEND_ALPHA_MULP
	        	draw_surface_safe(connection_surface_aa);
	        BLEND_NORMAL
	        
	        junction_hovering = __hov;
	        if(node_hovering != noone && node_hovering != node_dragging)
	        	junction_hovering = noone;
        #endregion
        
        #region draw node
	        _value_focus = value_focus;
	         value_focus = noone;
	        
	        var t = get_timer();
	        
	        node_surface_update = node_surface_update
	        	|| !surface_valid(node_surface, w, h)
	        	|| (node_hovering != noone && (node_hovering.reactive_on_hover || node_hovering.show_parameter));
	        node_surface = surface_verify(node_surface, w, h);
	        
	        if(pHOVER)
	        array_foreach(_node_draw, function(_n) /*=>*/ {
	            try { 
	            	var hov = node_hovering == noone || node_hovering == _n;
	            	if(!hov) return;
	            	
	            	var _xx = __gr_x + _n.x * __gr_s;
	                var _yy = __gr_y + _n.y * __gr_s;
	                var val = _n.checkJunctions(_xx, _yy, __mx, __my, __gr_s, __gr_s <= 0.5 || !_n.previewable);
	                if(val) value_focus = val;
	            }
	            catch(e) { log_warning("NODE DRAW", exception_print(e)); }
	        });
	        
	        if(node_surface_update) {
		        surface_set_target(node_surface);
	        	draw_clear_alpha(bg_color, 0.);
	        	
	        	array_foreach(_node_draw, function(_n) /*=>*/ { if(_n.drawNodeBehind) _n.drawNodeBehind(__gr_x, __gr_y, __mx, __my, __gr_s); });
	        	if(array_length(value_draggings) > 1) array_foreach(value_draggings, function(_v) /*=>*/ { _v.graph_selecting = true; });
		        
		        array_foreach(_node_draw, function(_n) /*=>*/ {
		            try { 
		            	_n.drawNode(node_surface_update, __gr_x, __gr_y, __mx, __my, __gr_s, __self); 
		            	
		            	var _xx = __gr_x + _n.x * __gr_s;
		                var _yy = __gr_y + _n.y * __gr_s;
		                var _fs = __gr_s <= 0.5 || !_n.previewable;
		                
		                gpu_set_texfilter(true);
		                if(_fs) {
		                	_n.drawJunctionsFast(_xx, _yy, __mx, __my, __gr_s);
			                
		                } else {
		                	if(!array_empty(_n.inputDisplayGroup)) 
		                		_n.drawJunctionGroups(_xx, _yy, __mx, __my, __gr_s);
			                _n.drawJunctions(_xx, _yy, __mx, __my, __gr_s);
		                }
		                
		                gpu_set_texfilter(false);
		                
		                if(CAPTURING) return;
						if(_n.drawDimension) _n.drawDimension(_n.x * __gr_s + __gr_x, _n.y * __gr_s + __gr_y, __gr_s);
		            }
		            catch(e) { log_warning("NODE DRAW", exception_print(e)); }
		        });
		        
		        array_foreach(_node_draw, function(_n) /*=>*/ { _n.drawBadge(__gr_x, __gr_y, __gr_s); });
		        array_foreach(_node_draw, function(_n) /*=>*/ { if(_n.drawNodeFG) _n.drawNodeFG(__gr_x, __gr_y, __mx, __my, __gr_s, __self); });
				surface_reset_target();
	        }
	        
	        BLEND_ALPHA_MULP
	        	draw_surface_safe(node_surface);
		        array_foreach(_node_draw, function(_n) /*=>*/ { _n.drawJunctionNames(__gr_x, __gr_y, __mx, __my, __gr_s, self); });
	        BLEND_NORMAL
	        
	        if(value_focus != noone && key_mod_press(SHIFT)) {
            	TOOLTIP = [ value_focus.getValue(), value_focus.type ];
            	if(pFOCUS && DOUBLE_CLICK) value_focus.drawValue = !value_focus.drawValue;
            }
            
            if(_value_focus != value_focus) refreshDraw();
	        	
	        if(PANEL_INSPECTOR && PANEL_INSPECTOR.prop_hover != noone)
            	value_focus = PANEL_INSPECTOR.prop_hover;
	        
	        node_surface_update = false;
	    #endregion
	        
        #region draw selection frame
	        if(nodes_select_drag) {
	            if(point_distance(nodes_select_mx, nodes_select_my, mx, my) > 16)
	                nodes_select_drag = 2;
	            
	            if(nodes_select_drag == 2) {
	                draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, nodes_select_mx, nodes_select_my, mx, my, COLORS._main_accent);
	                
	                for( var i = 0, n = array_length(nodes_list); i < n; i++ ) {
	                    var _node = nodes_list[i];
	                    
	                    if(!_node.selectable) continue;
	                    if(!project.graphDisplay.show_control && _node.is_controller) continue;
	                    if(is(_node, Node_Frame) && !nodes_select_frame)           continue;
	                    
	                    var _x = (_node.x + graph_x) * graph_s;
	                    var _y = (_node.y + graph_y) * graph_s;
	                    var _w = (_node.w) * graph_s;
	                    var _h = (_node.h + _node.showMeta() * 16) * graph_s;
	                    
	                    var _sel = _w && _h && rectangle_in_rectangle(_x, _y, _x + _w, _y + _h, nodes_select_mx, nodes_select_my, mx, my);
	                    var _selecting = array_exists(nodes_selecting, _node);
	                    
	                    if(!_selecting &&  _sel) array_push(  nodes_selecting, _node);
	                    if( _selecting && !_sel) array_remove(nodes_selecting, _node);    
	                }
	                
	                for( var i = 0, n = array_length(nodes_list); i < n; i++ ) { //select inline parent
	                    var _node = nodes_list[i];
	                	if(!is(_node, Node_Collection_Inline)) continue;
	                	
	                	if(array_contains_ext(nodes_selecting, _node.nodes, true))
	                		array_push_unique(nodes_selecting, _node);
	                }
	            }
	        
	            if(mouse_release(mb_left))
	                nodes_select_drag = 0;
	        }
        #endregion
        
        if(nodes_junction_d != noone) {
            var shx = nodes_junction_dx + (mx - nodes_select_mx) / graph_s;
            var shy = nodes_junction_dy + (my - nodes_select_my) / graph_s;
            
            shx = value_snap(shx, key_mod_press(CTRL)? 1 : 4);
            shy = value_snap(shy, key_mod_press(CTRL)? 1 : 4);
            
            nodes_junction_d.draw_line_shift_x = shx;
            nodes_junction_d.draw_line_shift_y = shy;
            
            if(mouse_release(mb_left))
                nodes_junction_d = noone;
        }
        
        if(mouse_on_graph && !node_bg_hovering && mouse_press(mb_left, _focus) && !graph_dragging_key && !graph_zooming_key) {
            if(is(junction_hovering, NodeValue) && junction_hovering.draw_line_shift_hover) {
                nodes_select_mx   = mx;
                nodes_select_my   = my;
                nodes_junction_d  = junction_hovering;
                nodes_junction_dx = junction_hovering.draw_line_shift_x;
                nodes_junction_dy = junction_hovering.draw_line_shift_y;
                
                recordAction(ACTION_TYPE.var_modify, junction_hovering, [ junction_hovering.draw_line_shift_x, "draw_line_shift_x", "junction anchor x position" ]);
        		recordAction(ACTION_TYPE.var_modify, junction_hovering, [ junction_hovering.draw_line_shift_y, "draw_line_shift_y", "junction anchor y position" ]);
        		
            } else if(array_empty(nodes_selecting) && !value_focus && !drag_locking) {
                nodes_select_drag  = 1;
                nodes_select_frame = frame_hovering == noone;
                
                nodes_select_mx = mx;
                nodes_select_my = my;
            }
            drag_locking = false;
        }
        
    } 
    
    function connectDraggingValueTo(target) {
        var _connect = [ 0, noone, noone ];
        if(array_length(value_draggings) == 1) {
        	value_dragging  = value_draggings[0];
        	value_draggings = [];
        }
        
        if(is(PANEL_INSPECTOR, Panel_Inspector) && PANEL_INSPECTOR.attribute_hovering != noone) {
            PANEL_INSPECTOR.attribute_hovering(value_dragging);
            
        } else if(target != noone && target != value_dragging) {
            
            if(target.connect_type == value_dragging.connect_type) {
                
                if(value_dragging.connect_type == CONNECT_TYPE.input) {
                    if(target.value_from) {
                        value_dragging.setFrom(target.value_from);
                        target.removeFrom();
                    }
                    
                } else if(value_dragging.connect_type == CONNECT_TYPE.output) {
                    var _tos = target.getJunctionTo();
                    
                    for (var i = 0, n = array_length(_tos); i < n; i++)
                        _tos[i].setFrom(value_dragging);
                }
                
            } else {
                var _addInput = target.value_from == noone && target.connect_type == CONNECT_TYPE.input && target.node.auto_input;
                
                if(value_dragging.connect_type == CONNECT_TYPE.input) {
                    if(array_empty(value_draggings))
                        _connect = [ value_dragging.setFrom(target), value_dragging, target ];
                    
                    else {
                        for( var i = 0, n = array_length(value_draggings); i < n; i++ )
                            value_draggings[i].setFrom(target);
                    }
                   
                } else if(_addInput && !array_empty(value_draggings)) {
                    for( var i = 0, n = array_length(value_draggings); i < n; i++ )
                        target.node.addInput(value_draggings[i]);
                        
                } else {
                    if(value_drag_from && target.value_from && value_drag_from.node == target.node)
                        value_drag_from.setFrom(target.value_from);
                    
                    if(array_empty(value_draggings))
                        _connect = [ target.setFrom(value_dragging), target, value_dragging ];
                    
                    else {
                        var _node = target.node;
                        var _indx = target.index;
                        
                        for( var i = 0, n = array_length(value_draggings); i < n; i++ ) {
                        	if(_indx < 0 || _indx > array_length(_node.inputs)) break;
                        	_node.inputs[_indx].setFrom(value_draggings[i]);
                        	_indx++;
                        }
                    }
                }
            }
            
        } else {
            if(value_dragging.connect_type == CONNECT_TYPE.input)
                value_dragging.removeFrom();
            value_dragging.node.triggerRender();
            
            if(value_focus != value_dragging) {
                var ctx   = is(frame_hovering, Node_Collection_Inline)? frame_hovering : getCurrentContext();
                var inCtx = value_dragging.node.inline_context;
                
                if(inCtx && inCtx.junctionIsInside(value_dragging)) {
                	addKeyOverlay("Connecting (inline)", [[ "Alt", "Connect to outside" ]]);
                	
					if(!key_mod_press(ALT)) ctx = inCtx;
                }
                
                callAddDialog(ctx, value_dragging);
                add_node_draw_junc = value_dragging;
                add_node_draw_x    = mouse_grid_x;
                add_node_draw_y    = mouse_grid_y;
            }
        }
        
        var _node     = value_dragging.node;
        var _loopable = !is(_node, Node_Pin) && _connect[1] != noone && _connect[2] != noone && 
                             _connect[1].node.loopable && _connect[2].node.loopable;
        
        if(_connect[0] == -7 && _loopable) {
            if(_connect[1].value_from_loop != noone)
                _connect[1].value_from_loop.destroy();
			
            var menu = [
                menuItem("Feedback", function(d) /*=>*/ { 
                    nodeBuild("Node_Feedback_Inline", 0, 0).skipDefault().connectJunctions(d.junc_in, d.junc_out);
                }, THEME.feedback_24, noone, noone, { junc_in : _connect[1], junc_out : _connect[2] }),
                
                menuItem("Loop", function(d) /*=>*/ {
                    nodeBuild("Node_Iterate_Inline", 0, 0).skipDefault().connectJunctions(d.junc_in, d.junc_out);
                }, THEME.loop_24, noone, noone, { junc_in : _connect[1], junc_out : _connect[2] }),
            ];
            
            menuCall("", menu);
        }
        
        value_dragging        = noone;
        connection_draw_mouse = noone;
    }
    
    function draggingValue() {
        if(!value_dragging.node.active) { 
            value_dragging  = noone; 
            value_draggings = [];
            return; 
        }
        
        addKeyOverlay("Connecting", [[ "Ctrl", "Disable auto connect" ], [ "Shift", "Select multiple" ], [ "Double Shift", "Select all of same type" ]]);
								
        if(key_mod_double(SHIFT)) {
            var _n    = value_dragging.node;
        	var _type = value_dragging.type;
        	var _conn = value_dragging.connect_type;
        	
        	var _list = _conn == CONNECT_TYPE.input? _n.inputDisplayList : _n.outputDisplayList;
            
            array_push_unique(value_draggings, value_dragging);
            
            for (var i = 0, n = array_length(_list); i < n; i++) {
                var _j = _list[i];
                if(_j.type == _type) array_push_unique(value_draggings, _j);
            }
        	
        } else if(key_mod_press(SHIFT)) {
            array_push_unique(value_draggings, value_dragging);
            
            if(value_focus) 
                array_push_unique(value_draggings, value_focus);
            
            if(mouse_release(mb_left)) {
                value_dragging        = noone;
                connection_draw_mouse = noone;
            }
            
        } else {
            var xx     = value_dragging.x;
            var yy     = value_dragging.y;
            var _mx    = mx;
            var _my    = my;
            var target = noone;
            
            if(value_focus && value_focus != value_dragging)
                target = value_focus;
                
            else if(!key_mod_press(CTRL) && node_hovering != noone) {
                if(value_dragging.connect_type == CONNECT_TYPE.input) {
                    target = node_hovering.getOutput(my, value_dragging);
                    if(target != noone) node_hovering.drawActive(1);
                        
                } else {
                    target = node_hovering.getInput(my, value_dragging, 0);
                    if(target != noone) node_hovering.drawActive(1);
                        
                }
            }
            
            var _mmx = target != noone? target.x : _mx;
            var _mmy = target != noone? target.y : _my;
            
            connection_draw_mouse  = [ _mmx, _mmy ];
            connection_draw_target = target;
			
            value_dragging.drawJunction(graph_s, value_dragging.x, value_dragging.y);
            if(target) {
            	target.ghost_hover = value_dragging;
            	target.drawJunction(graph_s, target.x, target.y);
            }
            
            var _inline_ctx = value_dragging.node.inline_context;
            
            if(_inline_ctx && !_inline_ctx.junctionIsInside(value_dragging))
                _inline_ctx = noone;
            
            if(_inline_ctx && !key_mod_press(SHIFT))
                _inline_ctx.addPoint(mouse_graph_x, mouse_graph_y);
            
            if(mouse_release(mb_left)) 
                connectDraggingValueTo(target);
                
        } 
        
        if(mouse_release(mb_left)) value_draggings = [];
    }
    
    function drawJunctionConnect() {
        var _focus = pFOCUS && !view_hovering;
        
        if(value_dragging) draggingValue();
		else node_drag_search = false;
        
        if(value_dragging == noone && value_focus && mouse_lpress(_focus) && !key_mod_press(ALT)) {
            value_dragging  = value_focus;
            value_draggings = [];
            value_drag_from = noone;
            
            if(value_dragging.connect_type == CONNECT_TYPE.output) {
                if(key_mod_press(CTRL)) {
                    var _to = value_dragging.getJunctionTo();
                    
                    if(array_length(_to)) {
                        value_dragging  = _to[0];
                        value_draggings = array_create(array_length(_to));
                        
                        for( var i = 0, n = array_length(_to); i < n; i++ ) {
                            value_draggings[i] = _to[i];
                            _to[i].removeFrom();
                        }
                    }
                } else if(array_exists(nodes_selecting_jun, value_dragging.node)) {
                    var _jlist = ds_priority_create();
                    
                    for( var i = 0, n = array_length(nodes_selecting_jun); i < n; i++ ) {
                        var _node = nodes_selecting_jun[i];
                        
                        if(_node == value_focus.node) {
                            ds_priority_add(_jlist, value_focus, value_focus.y);
                            
                        } else {
                            for( var j = 0, m = array_length(_node.outputs); j < m; j++ ) {
                                var _junction = _node.outputs[j];
                                if(!_junction.visible) continue;
                                if(value_bit(_junction.type) & value_bit(value_dragging.type) == 0) continue;
                            
                                ds_priority_add(_jlist, _junction, _junction.y);
                                break;
                            }
                        }
                    }
                    
                    while(!ds_priority_empty(_jlist))
                        array_push(value_draggings, ds_priority_delete_min(_jlist));
                    
                    ds_priority_destroy(_jlist);
                }
            } 
            
            if(value_dragging.connect_type == CONNECT_TYPE.input) {
                if(key_mod_press(CTRL) && value_dragging.value_from) {
                    value_drag_from = value_dragging;
                    
                    var fr = value_dragging.value_from;
                    value_dragging.removeFrom();
                    value_dragging = fr;
                }
            }
        }
        
        nodes_selecting_jun = array_clone(nodes_selecting, 1);
        
    }
    
    function callAddDialog(ctx = getCurrentContext(), conn = junction_hovering) { //
        var _dia = dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: ctx });
        connect_related = noone;
        
        if(pFOCUS) {
	        with(_dia) {    
	            node_target_x     = other.mouse_grid_x;
	            node_target_y     = other.mouse_grid_y;
	            node_target_x_raw = other.mouse_grid_x;
	            node_target_y_raw = other.mouse_grid_y;
	            junction_called   = conn;
	            
	            resetPosition();
	            alarm[0] = 1;
	        }
	        
	        if(is(conn, NodeValue)) {
	        	var _rel = nodeReleatedQuery("connectFrom", conn.type);
	        	connect_related = conn;
	        	
	        	var menu = [];
	        	for( var i = 0, n = array_length(_rel); i < n; i++ ) {
	        		var _r = _rel[i]
	        		var _k = $"graph_add_{_r}";
	        		
	        		if(struct_has(MENU_ITEMS, _k)) array_push(menu, MENU_ITEMS[$ _k]);
	        	}
	        	
	        	var _dx  = o_dialog_add_node.dialog_x - ui(8);
	        	var _dy  = o_dialog_add_node.dialog_y + ui(4);
	        	var _dme = menuCall("graph_connection_releated", menu, _dx, _dy, fa_right );
	        	if(_dme) _dme.passthrough = true;
	        	
	            setFocus(_dia, "Dialog");
	        }
	        
        }
        
        return _dia;
    } 
    
    function callReplaceDialog(ctx = getCurrentContext()) { 
    	var _target = array_safe_get(nodes_selecting, 0, noone);
    	if(!is(_target, Node)) return;
    	
    	var _dia = dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: ctx });
        
        with(_dia) {    
            node_target_x     = _target.x;
            node_target_y     = _target.y;
            node_target_x_raw = _target.x;
            node_target_y_raw = _target.y;
            node_replace      = _target;
            
            resetPosition();
            alarm[0] = 1;
        }
        
        return _dia;
    }
    
    function drawContext() { //
        draw_set_text(f_p2, fa_left, fa_center);
        var xx  = ui(10), tt, tw, th;
        var bh  = toolbar_height - ui(8);
        var tbh = h - toolbar_height / 2;
        var cnt = noone;
        
        for(var i = hasGlobal? -1 : 0, n = array_length(node_context); i < n; i++) {
            if(i == -1) {
            	cnt = noone;
                tt  = __txt("Global");
                
            } else {
                cnt = node_context[i];
                tt  = cnt.getDisplayName();
            }
            
            tw = string_width(tt);
            th = string_height(tt);
            
            if(i < n - 1) {
                if(buttonInstant(THEME.button_hide_fill, xx - ui(6), tbh - bh / 2, tw + ui(12), bh, [mx, my], pHOVER, pFOCUS) == 2) {
                    node_hover      = noone;
                    nodes_selecting = [];
                    PANEL_PREVIEW.resetNodePreview();
                    
                    var _ctx = node_context[i + 1];
                    var _nodeFocus = _ctx;
                    
                    if(i == -1) 
                        resetContext();
                    else {
                        array_resize(node_context, i + 1);
                        nodes_list = node_context[i].getNodeList();
                    }
                    
                    nodes_selecting = [ _nodeFocus ];
                    toCenterNode(nodes_selecting);
                    setContextFrame(true, _ctx);
                    break;
                }
                
                draw_sprite_ui_uniform(THEME.arrow, 0, xx + tw + ui(12), tbh + ui(1), .75, COLORS._main_icon);
            }
            
            var _aa = i < n - 1? 0.33 : 1;
            draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text, _aa);
            draw_text_add(xx, tbh, tt);
            draw_set_alpha(1);
            xx += tw + ui(4);
            
            if(is(cnt, Node_Collection) && cnt.show_instance) {
            	draw_set_text(f_p2b, fa_left, fa_center, COLORS._main_text_accent);
            	tt = __txt("[base]");
            	tw = string_width(tt);
            	
            	draw_text_add(xx, tbh, tt);
            	xx += tw + ui(4);
            }
            
            xx += ui(20);
        }
        
        return xx;
    } 
    
    function drawContextFrame() { 
        if(!context_framing) return;
        context_frame_progress = lerp_float(context_frame_progress, 1, 8);
        if(context_frame_progress == 1) 
            context_framing = false;
        
        var _fr_x0 = 0; 
        var _fr_y0 = 0;
        var _fr_x1 = w;
        var _fr_y1 = h - toolbar_height;
        
        var _to_x0 = context_frame_sx;
        var _to_y0 = context_frame_sy;
        var _to_x1 = context_frame_ex;
        var _to_y1 = context_frame_ey;
        
        var prog = context_frame_direct? context_frame_progress : 1 - context_frame_progress;
        var frm_x0 = lerp(_fr_x0, _to_x0, prog);
        var frm_y0 = lerp(_fr_y0, _to_y0, prog);
        var frm_x1 = lerp(_fr_x1, _to_x1, prog);
        var frm_y1 = lerp(_fr_y1, _to_y1, prog);
        
        draw_set_color(COLORS._main_accent);
        draw_set_alpha(0.8);
        draw_roundrect_ext(frm_x0, frm_y0, frm_x1, frm_y1, THEME_VALUE.panel_corner_radius, THEME_VALUE.panel_corner_radius, true);
        draw_set_alpha(1);
    } 
    
    function drawToolBar() { //
    	var tx = 0;
        var ty = h - toolbar_height;
        var tw = w;
        var th = toolbar_height;
        
        if(pHOVER && point_in_rectangle(mx, my, tx, ty, tx + tw, ty + th))
            mouse_on_graph = false;
        
        draw_sprite_stretched(THEME.toolbar, 0, tx, ty, tw, th);
        var cont_x = drawContext();
        
        var bs  = toolbar_height - ui(8);
        var bsc = 1;
        var tbx = w - ui(4) - bs;
        var tby = ty + th / 2;
        var _m  = [ mx, my ];
        var _lh = toolbar_height / 2 - ui(8);
        
        var scs = gpu_get_scissor();
        gpu_set_scissor(cont_x, ty, w - cont_x, th);
        var hov = pHOVER && point_in_rectangle(mx, my, cont_x, ty, w, h);
        var foc = pFOCUS;
        
        var tbs = "graph_toolbars_general";
        var tbb = menuItems_gen(tbs);
        for( var i = 0, n = array_length(tbb); i < n; i++ ) {
        	var _menu = tbb[i];
			if(_menu == -1) {
				draw_set_color(COLORS.panel_toolbar_separator);
				draw_line_width(tbx + bs - ui(2), tby - _lh, tbx + bs - ui(2), tby + _lh, 2);
				
				tbx -= ui(6);
				continue;
			} 
			
			var bx = tbx;
            var by = tby - bs / 2;
            
			_menu.draw(bx, by, bs, bs, _m, hov, foc, tbs);
			tbx -= bs + ui(2);
			
			if(i == n - 1) {
				draw_set_color(COLORS.panel_toolbar_separator);
				draw_line_width(tbx + bs - ui(2), tby - _lh, tbx + bs - ui(2), tby + _lh, 2);
			}
        }
        
        tbx -= ui(6);
        gpu_set_scissor(scs);
        
        if(hk_editing != noone) { 
			if(key_press(vk_enter)) hk_editing = noone;
			else hotkey_editing(hk_editing);
			
			if(key_press(vk_escape)) hk_editing = noone;
		}
    } 
    
    function drawTopbar() { 
    	if(!project.graphDisplay.show_topbar) {
    		return;
    		
    		var cx = w / 2;
    		var ww = ui(20);
    		var hh = ui(16);
    		
    		var x0 = cx - ww / 2;
    		var x1 = cx + ww / 2;
    		var y0 = 0;
    		var y1 = hh;
    		var aa = .5;
    		
    		// draw_sprite_stretched_ext(THEME.box_r2, 0, x0, y0, ww, hh, COLORS._main_icon_dark);
    		
    		if(pHOVER && point_in_rectangle(mx, my, x0, y0, x1, y1)) {
    			aa = 1;
				mouse_on_graph = false;
				if(mouse_lpress(pFOCUS)) project.graphDisplay.show_topbar = true;
    		}
    		
    		draw_sprite_ui_uniform(THEME.arrow, 3, x0 + ww / 2, y0 + hh / 2 + ui(2), 1, COLORS._main_icon, aa);
    		return;
    	}
    	
    	var tx = 0;
        var ty = 0;
        var tw = w;
        var th = topbar_height;
        
    	draw_sprite_stretched(THEME.toolbar, 1, tx, ty, tw, th);
    	
    	var _side_m = menuItems_gen("graph_topbar_menu");
    	var _pad = ui(4);
		var _mus = th - _pad * 2;
		var _mux = top_scroll + _pad;
		var _muy = ty + _pad;
		var _ww  = ui(16);
		
		var _cc  = [COLORS._main_icon, c_white];
		var _m   = [mx, my];
		
		for( var i = 0, n = array_length(_side_m); i < n; i++ ) {
			var _menu = _side_m[i];
			if(_menu == -1) {
				draw_set_color(CDEF.main_mdblack);
				draw_line_width(_mux + ui(1), _muy, _mux + ui(1), _muy + _mus, 2);
				
				_mux += ui(6);
				_ww  += ui(6);
				continue;
			} 
			
			var _name = _menu.name;
			var _spr  = _menu.getSpr();
			if(!sprite_exists(_spr)) _spr = THEME.pxc_hub;
			
			if(buttonInstant_Pad(THEME.button_hide_fill, _mux, _muy, _mus, _mus, _m, pHOVER, pFOCUS, _name, _spr, 0, _cc, 1, ui(6)) == 2) {
				var _res = _menu.toggleFunction();
				if(is(_res, Node)) selectDragNode(_res, true);
			}
			
			_mux += _mus + ui(2);
			_ww  += _mus + ui(2);
		}
		
		top_scroll_max = max(_ww - tw + ui(16), 0);
		top_scroll = lerp_float(top_scroll, top_scroll_to, 5);
		
		if(pHOVER && point_in_rectangle(mx, my, tx, ty, tx + tw, ty + th)) {
			mouse_on_graph = false;
			
			top_scroll_to = top_scroll_to + MOUSE_WHEEL * (_mus + ui(2));
			top_scroll_to = clamp(top_scroll_to, -top_scroll_max, 0);
			
			if(mouse_press(mb_right, pFOCUS)) menuCall("graph_topbar_context_menu", menuItems_gen("graph_topbar_context_menu"));
		}
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
            mouse_on_graph = false;
            mini_hover     = true;
        }
        
        var hover = mini_hover && !point_in_rectangle(mx, my, mx0, my0, mx0 + ui(16), my0 + ui(16)) && !minimap_dragging;
        
        if(!is_surface(minimap_surface) || surface_get_width_safe(minimap_surface) != minimap_w || surface_get_height_safe(minimap_surface) != minimap_h) {
            minimap_surface = surface_create_valid(minimap_w, minimap_h);
        }
        
        surface_set_target(minimap_surface);
        DRAW_CLEAR
    	draw_sprite_stretched_ext(THEME.ui_panel, 0, 0, 0, minimap_w, minimap_h, COLORS.panel_bg_clear_inner, .75 + .25 * hover);
    	
        if(!array_empty(nodes_list)) {
            var minx =  99999;
            var maxx = -99999;
            var miny =  99999;
            var maxy = -99999;
            
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                minx = min(_node.x - 32, minx);
                maxx = max(_node.x + _node.w + 32, maxx);
                
                miny = min(_node.y - 32, miny);
                maxy = max(_node.y + _node.h + 32, maxy);
            }
            
            var cx  = (minx + maxx) / 2;
            var cy  = (miny + maxy) / 2;
            var spw = maxx - minx;
            var sph = maxy - miny;
            var ss  = min(minimap_w / spw, minimap_h / sph);
            
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                
                var nx = minimap_w / 2 + (_node.x - cx) * ss;
                var ny = minimap_h / 2 + (_node.y - cy) * ss;
                var nw = _node.w * ss;
                var nh = _node.h * ss;
                
                draw_set_color(_node.getColor());
                draw_set_alpha(0.2 + 0.8 * (!is(_node, Node_Frame)));
                draw_rectangle(nx, ny, nx + nw, ny + nh, false);
                draw_set_alpha(1);
            }
            
            var gx = minimap_w / 2 - (graph_x + cx) * ss;
            var gy = minimap_h / 2 - (graph_y + cy) * ss;
            var gw = w / graph_s * ss;
            var gh = h / graph_s * ss;
            
            draw_sprite_stretched_ext(THEME.ui_panel, 1, gx, gy, gw, gh, COLORS._main_icon_light, 1);
		    
            if(minimap_panning) {
                graph_x = -((mx - mx0 - gw / 2) - minimap_w / 2) / ss - cx;
                graph_y = -((my - my0 - gh / 2) - minimap_h / 2) / ss - cy;
                
                graph_x = round(graph_x);
                graph_y = round(graph_y);
                
                if(mouse_release(mb_left))
                    minimap_panning = false;
            }
            
            if(mouse_click(mb_left, hover))
                minimap_panning = true;
        }
        
        BLEND_MULTIPLY
        draw_sprite_stretched_ext(THEME.ui_panel, 0, 0, 0, minimap_w, minimap_h, c_white, 1);
        BLEND_NORMAL
        
        surface_reset_target();
        
        draw_surface_ext_safe(minimap_surface, mx0, my0, 1, 1, 0, c_white, .75 + .25 * hover);
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
    
    function drawSearch() {
        if(!is_searching) return;
        
        var tw = ui(200);
        var th = line_get_height(f_p2, 6);
        
        var pd = ui(6);
        var ww = tw + pd * 2 + (ui(4) + ui(24)) * 3;
        var hh = th + pd * 2;
        
        var x1 = w - ui(8);
        var x0 = x1 - ww;
        
        var y0 = ui(8);
        var y1 = y0 + hh;
        
        draw_sprite_stretched(    THEME.ui_panel_bg, 3, x0, y0, ww, hh);
        // draw_sprite_stretched_add(THEME.ui_panel, 1, x0, y0, ww, hh, c_white, 0.1);
        draw_sprite_stretched(    THEME.button_hide_fill, 1, x0 + pd, y0 + pd, tw, th);
        
        tb_search.font = f_p2;
        tb_search.setFocusHover(pFOCUS, pHOVER);
        tb_search.draw(x0 + pd, y0 + pd, tw, th, search_string, [ mx, my ]);
        
        var bs = ui(24);
        var bx = x1 - bs - pd;
        var by = y0 + pd;
        if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, "", THEME.cross_16) == 2
        || keyboard_check_pressed(vk_escape)
        || KEYBOARD_ENTER)
            is_searching = false;
        
        bx -= bs + ui(4);
        if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, "", THEME.arrow_wire_16, 0) == 2) {
            if(!array_empty(search_result)) {
                search_index    = safe_mod(search_index + 1, array_length(search_result));
                nodes_selecting = [ search_result[search_index] ];
                toCenterNode(nodes_selecting);
            }
        }
        
        bx -= bs + ui(4);
        if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pHOVER, pFOCUS, "", THEME.arrow_wire_16, 2) == 2) {
            if(!array_empty(search_result)) {
                search_index    = safe_mod(search_index - 1 + array_length(search_result), array_length(search_result));
                nodes_selecting = [ search_result[search_index] ];
                toCenterNode(nodes_selecting);
            }
        }
        
        if(point_in_rectangle(mx, my, x0, y0, x1, y1))
            mouse_on_graph = false;
    }
    
    function drawSlideShow() {
        if(!project.useSlideShow) return;
        
        var amo = project.slideShow_amount;
        var ind = project.slideShow_index;
        var cur = project.slideShow_current;
        
        var _sl_w = (amo - 1) * ui(16) + ui(16 * 2);
        var _sl_h = ui(32);
        
        var _sl_x = w / 2 - _sl_w / 2;
        var _ss_x = _sl_x;
        
        var _sl_y = h - toolbar_height - ui(8) - _sl_h;
        var _ss_y = _sl_y + _sl_h - ui(16);
        
        if(cur != noone && cur.slide_title != "") {
            draw_set_text(f_p2, fa_center, fa_top, COLORS._main_icon_light);
            var _txtw = string_width(cur.slide_title) + ui(32);
            _sl_w = max(_sl_w, _txtw);
            _sl_h = _sl_h + ui(8 + 12);
        }
        
        slider_width = slider_width == 0? _sl_w : lerp_float(slider_width, _sl_w, 10);
        _sl_x = w / 2 - slider_width / 2;
        _sl_y = h - toolbar_height - ui(8) - _sl_h;
        
        var _dpd = 12;
        // draw_sprite_stretched(THEME.dialog, 0, _sl_x - _dpd, _sl_y - _dpd, slider_width + _dpd * 2, _sl_h + _dpd * 2);
        draw_sprite_stretched(THEME.ui_panel_bg, 3, _sl_x, _sl_y, slider_width, _sl_h);
        
        if(cur != noone) draw_text_add(round(w / 2), round(_sl_y + ui(8)), cur.slide_title);
        
        var _hv = false;
        var _sn = ui(8);
        
        for(var i = 0; i < amo; i++) {
            var _sx = _ss_x + ui(16) + i * ui(16);
            var _sy = _ss_y;
            
            var cc = i == ind? COLORS._main_accent : COLORS._main_icon;
            var aa = i == ind? 1 : .5;
            var ss = i == ind? 1 : .8;
            
            var slid = struct_try_get(project.slideShow, project.slideShow_keys[i], noone);
            
            if(pHOVER && point_in_rectangle(mx, my, _sx - _sn, _sy - _sn, _sx + _sn, _sy + _sn)) {
                if(slid) TOOLTIP = slid.slide_title;
                _hv = true;
                aa  = 1;
                
                if(mouse_press(mb_left, pFOCUS)) 
                    setSlideShow(i);
            }
            
            draw_sprite_ui(THEME.circle, 0, _sx, _sy, ss, ss, 0, cc, aa);
        }
        
        if(point_in_rectangle(mx, my, _sl_x, _sl_y, _sl_x + slider_width, _sl_y + _sl_h)) { 
            mouse_on_graph = false;
            
            if(pHOVER && !_hv) {
                draw_sprite_stretched_add(THEME.ui_panel_bg, 4, _sl_x, _sl_y, slider_width, _sl_h, COLORS._main_icon, 0.05);
                draw_sprite_stretched_add(THEME.ui_panel, 1, _sl_x, _sl_y, slider_width, _sl_h, c_white, 0.1);
                
                if(mouse_press(mb_left, pFOCUS)) 
                    setSlideShow((ind + 1) % amo);
            }
        }
        
        var _dir = filename_name_only(filename_dir(project.path));
        if(_dir == "Getting started") {
        	var _spx1 = _sl_x - ui(8);
        	var _spx0 = _spx1 - ui(40);
        	
        	var _spy0 = _sl_y;
        	var _spy1 = _sl_y + _sl_h;
        	
        	var _spw = _spx1 - _spx0;
        	var _sph = _spy1 - _spy0;
        	
        	draw_sprite_stretched(THEME.ui_panel_bg, 3, _spx0, _spy0, _spw, _sph);
        	
        	if(point_in_rectangle(mx, my, _spx0, _spy0, _spx1, _spy1)) { 
	            mouse_on_graph = false;
	            
	            if(pHOVER && !_hv) {
	            	TOOLTIP = __txt("Splash screen");
	                draw_sprite_stretched_add(THEME.ui_panel_bg, 4, _spx0, _spy0, _spw, _sph, COLORS._main_icon, 0.05);
	                draw_sprite_stretched_add(THEME.ui_panel, 1, _spx0, _spy0, _spw, _sph, c_white, 0.1);
	                
	                if(mouse_press(mb_left, pFOCUS)) 
	                    dialogCall(o_dialog_splash);
	            }
	        }
	        
	        draw_sprite_ui(THEME.hamburger_s, 0, _spx0 + _spw / 2, _spy0 + _sph / 2, 1, 1, 0, COLORS._main_icon);
        }
    }
    
    function drawTooltipHints() {
    	if(!project.graphDisplay.show_tooltip) { tooltip_overlay = {}; return; }
		if(CAPTURING) return;
		
        var _over = variable_struct_get_names(tooltip_overlay);
    	var _tx   = ui(16);
    	var _ty   = h - toolbar_height - ui(10);
    	
    	for( var j = 0, m = array_length(_over); j < m; j++ ) {
    		var _title = _over[j];
        	var _keys  = tooltip_overlay[$ _title];
        	
        	draw_set_text(f_p2b, fa_left, fa_bottom, COLORS._main_text, .75);
			var _tw = 0;
			for( var i = 0, n = array_length(_keys); i < n; i++ ) 
				_tw = max(_tw, string_width(_keys[i][0]));
				
			var _ttx = _tx + _tw + ui(16);
			
			for( var i = array_length(_keys) - 1; i >= 0; i-- ) {
				draw_set_font(f_p2b);
				draw_set_color(CDEF.main_mdwhite);
				draw_text_add(_tx, _ty, _keys[i][0]);
				
				draw_set_font(f_p2);
				draw_set_color(COLORS._main_text);
				draw_text_add(_ttx, _ty, _keys[i][1]);
				
				_ty -= line_get_height();
			}
			
			_ty -= ui(4);
			draw_set_text(f_p1b, fa_left, fa_bottom, COLORS._main_text, .75);
			draw_text_add(_tx, _ty, _title);
			
			_ty -= line_get_height() + ui(8);
    	}
    	
    	if(getFocusStr() != noone) {
    		var _list = HOTKEYS[$ FOCUS_STR];
    		var _node = ALL_NODES[$ FOCUS_STR];
    		
    		draw_set_text(f_p2b, fa_left, fa_bottom, COLORS._main_text, .75);
			var _tw = 0;
			for( var i = 0, n = array_length(_list); i < n; i++ ) 
				_tw = max(_tw, string_width(_list[i].getName()));
    		
			var _ttx = _tx + _tw + ui(16);
			
    		for(var i = array_length(_list) - 1; i >= 0; i--) {
				var hotkey = _list[i];
				var _title = hotkey.name;
				var _key   = hotkey.getName();
				
				draw_set_font(f_p2b);
				draw_set_color(CDEF.main_mdwhite);
				draw_text_add(_tx, _ty, _key);
				
				draw_set_font(f_p2);
				var _ttxx = _ttx;
				if(string_pos(">", _title)) {
    				var _sp = string_split(_title, ">");
    				
	    			draw_set_color(COLORS._main_text);
	    			draw_text_add(_ttxx, _ty, _sp[1]);
	    			_ttxx += string_width(_sp[1]) + ui(4);
	    			
	    			draw_set_color(CDEF.main_mdwhite);
    				draw_text_add(_ttxx, _ty, _sp[0]);
    				_ttxx += string_width(_sp[0]) + ui(4);
    				
    			} else {
	    			draw_set_color(COLORS._main_text);
	    			draw_text_add(_ttxx, _ty, _title);
	    			_ttxx += string_width(_title) + ui(4);
    			}
    			
    			if(hotkey.key == KEY_GROUP.numeric) {
    				var _curr_val = KEYBOARD_NUMBER == undefined? "[-]" : $"[{KEYBOARD_NUMBER}]";
    				
    				draw_set_color(CDEF.main_mdwhite);
	    			draw_text_add(_ttxx, _ty, _curr_val);
    			}
				
				_ty -= line_get_height();
			}
			
			_ty -= ui(4);
			draw_set_text(f_p1b, fa_left, fa_bottom, COLORS._main_text, .75);
			draw_text_add(_tx, _ty, _node? _node.name : string_replace_all(FOCUS_STR, "_", " "));
			
			_ty -= line_get_height() + ui(8);
			
			if(pHOVER) {
				if(key_press(vk_space) || key_press(vk_enter) || key_press(vk_escape)) 
					setFocus(panel, context_str);
			}
    	}
		
		draw_set_alpha(1);
        
        tooltip_overlay = {};
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
    
    ////- Main Draw
    
    function drawContent(panel) { 
        if(!project.active) return;
        
        dragGraph();
        
        graph_cx = (w / 2) / graph_s - graph_x;
        graph_cy = (h / 2) / graph_s - graph_y;
        
        var context = getCurrentContext();
        if(context != noone) {
        	title_raw += " > " + (context.renamed? context.display_name : context.name);
        	if(!context.active) {
        		resetContext();
        		context = noone;
        	}
        }
        
        bg_color = context == noone? COLORS.panel_bg_clear : merge_color(COLORS.panel_bg_clear, context.getColor(), 0.05);
        drawBGBase();
        
        node_bg_hovering = drawBasePreview();
        
        var ovy = ui(2);
        if(project.graphDisplay.show_view_control == 2) ovy += ui(36);
        if(project.graphDisplay.show_topbar)            ovy += topbar_height;
        
        drawNodes();
        drawJunctionConnect();
        drawContextFrame();
        mouse_on_graph = true;
        
        if(!CAPTURING) {
	        draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text_sub);
	        
	        var _zmsl = tb_zoom_level.selecting || tb_zoom_level.hovering || tb_zoom_level.sliding;
	        var _zms  = $"x{graph_s_to}";
	        var _zmw  = string_width(_zms) + ui(16);
	        var _zmh  = string_height(_zms);
	        var _zmx  = w;
	        var _zmc  = _zmsl? COLORS._main_text : COLORS._main_text_sub;
	        if(tb_zoom_level.hovering) mouse_on_graph = false;
	        
            if(_zmsl) draw_sprite_stretched(THEME.textbox, 3, _zmx - _zmw + ui(4), ovy + ui(2), _zmw - ui(10), _zmh - ui(2));
                    
	        tb_zoom_level.rx = x;
	        tb_zoom_level.ry = y;
	        tb_zoom_level.setFocusHover(pFOCUS, pHOVER);
	        tb_zoom_level.postBlend = _zmc;
	        tb_zoom_level.draw(_zmx, ovy, _zmw, _zmh, string(graph_s_to), [ mx, my ], fa_right);
	        if(tb_zoom_level.hovering) {
            	mouse_on_graph = false;
            	CURSOR_SPRITE  = THEME.view_zoom;
            }
            
	    	draw_set_text(f_p2, fa_right, fa_top, _zmc);
	        if(!tb_zoom_level.selecting && !tb_zoom_level.sliding)
		    	draw_text(_zmx - _zmw + ui(14), ovy, "x");
        }
    	
        drawToolBar();
        drawTopbar();
        drawMinimap();
        
        drawViewController();
        
        if(pFOCUS && !view_hovering) array_foreach(nodes_selecting, function(n) /*=>*/ {return n.focusStep()});
        
        graph_dragging_key = false;
        graph_zooming_key  = false;
        
        drawSearch()
        
        if(LIVE_UPDATE) {
            draw_set_text(f_p0b, fa_right, fa_bottom, COLORS._main_value_negative);
            draw_text(w - 8, h - toolbar_height, "Live Update");
        }
        
        drawSlideShow();
        drawActionTooltip();
        
        if(project.safeMode) {
			draw_set_text(f_sdf, fa_right, fa_bottom, COLORS._main_text_sub);
			draw_text_transform_add(w - ui(8), h - toolbar_height, __txtx("safe_mode", "SAFE MODE"), .5);
		}
		
        ///////////////////////////////////// File drop /////////////////////////////////////
        
        if(pHOVER) {
            var gr_x = graph_x * graph_s;
            var gr_y = graph_y * graph_s;
            var _gx  = mx / graph_s - graph_x;
            var _gy  = my / graph_s - graph_y;
            var _node_hover = noone;
            
            var _mx = mouse_mxs - x;
            var _my = mouse_mys - y;
            
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _n = nodes_list[i];
                if(is(_n, Node_Frame)) continue;
                
                if(_n.pointIn(gr_x, gr_y, _mx, _my, graph_s))
                    _node_hover = _n;
            }
            
            var _tip = "";
                
            if(DRAGGING || FILE_IS_DROPPING)
                draw_sprite_stretched_ext(THEME.ui_panel_selection, 0, 8, 8, w - 16, h - 16, COLORS._main_value_positive, 1);
            
            if(FILE_IS_DROPPING)
            	addKeyOverlay("Droping file(s)", [[ "Shift", "Options..." ]]);
                
            if(DRAGGING) { // file dropping
            	refreshDraw();
            	mouse_glow_rad_to = 80;
            	
                if(_node_hover && _node_hover.droppable(DRAGGING)) {
                    _node_hover.draw_droppable = true;
                    _tip = "Drop on node";
                    if(mouse_release(mb_left)) _node_hover.onDrop(DRAGGING);
                    
                } else {
                    if(mouse_release(mb_left)) checkDropItem();
                }
            }
            
            if(FILE_IS_DROPPING && _node_hover && _node_hover.dropPath != noone) {
            	refreshDraw();
                _node_hover.draw_droppable = true;
                _tip = "Drop on node";
            }
            
            if(FILE_DROPPED && !array_empty(FILE_DROPPING)) {
                if(_node_hover && _node_hover.dropPath != noone) 
                    _node_hover.dropPath(FILE_DROPPING);
                else
                    run_in(1, load_file_path, [ FILE_DROPPING, _gx, _gy ]);
            }
            
            if(_tip != "") TOOLTIP = _tip;
        }
        
        drawTooltipHints();
        
        if(LOADING) {
        	draw_set_color(CDEF.main_dkblack);
        	draw_set_alpha(0.3);
        	draw_rectangle(0, 0, w, h, false);
        	draw_set_alpha(1);
        	
        	gpu_set_tex_filter(true);
        	draw_sprite_ui(THEME.loading, 0, w / 2, h / 2, 1, 1, current_time / 2, COLORS._main_icon);
        	gpu_set_tex_filter(false);
        }
    } 
    
    ////- Action
    
    function createNodeHotkey(_node, _select = true, _connect = false) {
    	var _nodeType = _node;
    	var _preset   = "";
    	
    	if(string_pos(">", _node)) {
    		var _sp   = string_split(_node, ">");
    		_nodeType = _sp[0];
			_preset   = _sp[1];
    	}
    	
    	var node  = noone;
        var _drag = false;
        
    	switch(_nodeType) {
	    	case "Node_Blend" :     node = doBlend();                   break;
	    	case "Node_Math" :      node = doBlend("Node_Math");        break;
	    	
	    	case "Node_Composite" : node = doCompose();                 break;
	    	case "Node_Logic" :     node = doCompose("Node_Logic");     break;
	    	case "Node_Statistic" : node = doCompose("Node_Statistic"); break;
	    	case "Node_3D_Scene" :  node = doCompose("Node_3D_Scene");  break;
	    	
	    	case "Node_Array" :     node = doArray();                   break;
	    	case "Node_Export" :    node = doExport();                  break;
	    	case "Node_Frame" :     node = doFrame();                   break;
	    	
	    	case "Node_Transform" : 
	    		if(!array_empty(nodes_selecting) && !array_empty(nodes_selecting[0].outputs)) {
	    			var _outT = nodes_selecting[0].outputs[0].type;
	    			if(_outT == VALUE_TYPE.d3Mesh || _outT == VALUE_TYPE.d3Scene) 
	    				_nodeType = "Node_3D_Transform";
	    		}
	    		
	    		node  = doNewNode(_nodeType);
	    		break;
	    	
	    	default : 
	    		node  = doNewNode(_nodeType); 
	    		_drag = _select; 
	    		break;
    	}
    	
        if(!is(node, Node)) return undefined;
        
        if(_preset != "") {
        	node.skipDefault();
        	node.setPreset(_preset);
        }
        
        if(_select) {
        	nodes_selecting = [node];
        	if(pFOCUS) FOCUS_STR = instanceof(node);
        }
        
        if(_connect && is(connect_related, NodeValue) && connect_related.node.group == getCurrentContext()) {
        	var _inp = node.getInput(0, connect_related);
        	if(_inp) _inp.setFrom(connect_related);
        	
        	_drag = false;
        }
        
        if(_drag) selectDragNode(node, true);
        connect_related = noone;
        return node;
    }
    
    function doBlend(_base = "") {
    	var _ty = _base == ""? "Node_Blend" : _base;
    	
        if(array_empty(nodes_selecting) || array_empty(nodes_selecting[0].outputs))
        	return nodeBuild(_ty, mouse_grid_x, mouse_grid_y, getCurrentContext()).skipDefault();
    	
    	var _jj = nodes_selecting[0].outputs[0];
    	var _ty = _base;
    	
    	if(_base == "") {
				 if(value_bit(_jj.type) & (1 << 15) || is(nodes_selecting[0], Node_Path)) return doCompose();
			else if(value_bit(_jj.type) & (1 <<  3)) return doCompose();
			else if(value_bit(_jj.type) & (1 << 29)) return doCompose();
			else if(value_bit(_jj.type) & (1 <<  1)) _ty = "Node_Math";
			else if(value_bit(_jj.type) & (1 <<  5)) _ty = "Node_Blend";
			else if(value_bit(_jj.type) & (1 << 28)) _ty = "Node_Blend";
			
    	} 
    	
        if(array_length(nodes_selecting) == 1) {
	        var _nodex = nodes_selecting[0].x + 160;
	        var _nodey = nodes_selecting[0].y;
	        var _blend = nodeBuild(_ty, _nodex, _nodey, getCurrentContext()).skipDefault();
            
            switch(_ty) {
            	case "Node_Blend" : _blend.inputs[0].setFrom(_jj); break;
            	case "Node_Math" :  _blend.inputs[1].setFrom(_jj); break;
            }
        	
        	return _blend;
        }
        
        var _n0 = nodes_selecting[0].y < nodes_selecting[1].y? nodes_selecting[0] : nodes_selecting[1];
        var _n1 = nodes_selecting[0].y < nodes_selecting[1].y? nodes_selecting[1] : nodes_selecting[0];
        
        var _nodex = max(_n0.x, _n1.x) + 160;
        var _nodey = round((_n0.y + _n1.y) / 2 / 32) * 32;
        var _blend = nodeBuild(_ty, _nodex, _nodey, getCurrentContext()).skipDefault();
        
        if(array_empty(_n0.outputs)) return _blend;
        if(array_empty(_n1.outputs)) return _blend;
        
        var _j0 = _n0.outputs[0]; 
        var _j1 = _n1.outputs[0]; 
        
        switch(_ty) {
        	case "Node_Blend" :    
        		var i0 = 0;
        		var i1 = 0;
        		
        		while(i0 < array_length(_n0.outputs) && value_bit(_n0.outputs[i0].type) & (1 << 5) == 0) i0++;
        		if(i0 < array_length(_n0.outputs)) _blend.inputs[0].setFrom(_n0.outputs[i0]);
        		
        		while(i1 < array_length(_n1.outputs) && value_bit(_n1.outputs[i1].type) & (1 << 5) == 0) i1++;
            	if(i1 < array_length(_n1.outputs)) _blend.inputs[1].setFrom(_n1.outputs[i1]);
            	break;
        		
        	case "Node_Math" :    
	            _blend.inputs[1].setFrom(_j0);
	            _blend.inputs[2].setFrom(_j1); 
        		break;
        		
        }
    	
        nodes_selecting = [ _blend ];
        FOCUS_STR = instanceof(_blend);
        
        return _blend;
    } 
    
    function doCompose(_base = "") { //
    	var _ty = _base == ""? "Node_Composite" : _base;
    	
        if(array_empty(nodes_selecting) || array_empty(nodes_selecting[0].outputs)) {
        	var _compose = nodeBuild(_ty, mouse_grid_x, mouse_grid_y, getCurrentContext()).skipDefault();
        	nodes_selecting = [];
        	return _compose;
        }
    	
    	var _jj = nodes_selecting[0].outputs[0];
    	
    	if(_base == "") {
	    	     if(value_bit(_jj.type) & (1 << 15) || is(nodes_selecting[0], Node_Path)) _ty = "Node_Path_Array";
			else if(value_bit(_jj.type) & (1 <<  5))   _ty = "Node_Composite";
			else if(value_bit(_jj.type) & (1 <<  3))   _ty = "Node_Logic";
			else if(value_bit(_jj.type) & (1 <<  1))   _ty = "Node_Statistic";
			else if(value_bit(_jj.type) & (1 << 29))   _ty = "Node_3D_Scene";
    	}
    	
        var cx   = nodes_selecting[0].x;
        var cy   = 0;
        var pr   = ds_priority_create();
        var amo  = array_length(nodes_selecting);
        var len  = 0;
        
        for(var i = 0; i < amo; i++) {
            var _node = nodes_selecting[i];
            if(array_empty(_node.outputs)) continue;
            
            var _jj = _node.outputs[0];
            
            switch(_ty) {
	        	case "Node_Composite" : if((value_bit(_jj.type) & (1 <<  5)) == 0) continue; break;
	        	case "Node_Logic"     : if((value_bit(_jj.type) & (1 <<  3)) == 0) continue; break;
	        	case "Node_Statistic" : if((value_bit(_jj.type) & (1 <<  1)) == 0) continue; break;
	        	case "Node_3D_Scene"  : if((value_bit(_jj.type) & (1 << 29)) == 0) continue; break;
	        	
	        	case "Node_Path_Array": 
	        		if(is(nodes_selecting[0], Node_Path)) _jj = _node.outputs[1];
	        		if((value_bit(_jj.type) & (1 << 15)) == 0) continue; 
        		break;
	        }
            
            cx = max(cx, _node.x);
            cy += _node.y;
            
            ds_priority_add(pr, _jj, _node.y);
            len++;
        }
        
        cx = cx + 160;
        cy = value_snap(cy / len, 16);
        
        var _compose = nodeBuild(_ty, cx, cy, getCurrentContext()).skipDefault();
        
        repeat(len) {
            var _outp = ds_priority_delete_min(pr);
            _compose.addInput(_outp);
        }
        
        nodes_selecting = [];
        ds_priority_destroy(pr);
        
        return _compose;
    } 

    function doArray() { //
        if(array_empty(nodes_selecting)) 
        	return nodeBuild("Node_Array", mouse_grid_x, mouse_grid_y, getCurrentContext()).skipDefault();
    	
        var cx  = nodes_selecting[0].x;
        var cy  = 0;
        var pr  = ds_priority_create();
        var amo = array_length(nodes_selecting);
        var len = 0;
        
        for(var i = 0; i < amo; i++) {
            var _node = nodes_selecting[i];
            if(array_length(_node.outputs) == 0) continue;
            
            cx = max(cx, _node.x);
            cy += _node.y;
            
            ds_priority_add(pr, _node, _node.y);
            len++;
        }
        
        cx = cx + 160;
        cy = round(cy / len / 32) * 32;
    
        var _array = nodeBuild("Node_Array", cx, cy).skipDefault();
        
        repeat(len) {
            var _node = ds_priority_delete_min(pr);
            _array.addInput(_node.outputs[0]);
        }
        
        nodes_selecting = [];
        ds_priority_destroy(pr);
        
        return _array;
    } 

    function doFrame() { //
        var x0 = infinity, y0 = infinity, x1 = -infinity, y1 = -infinity;
        
        for( var i = 0; i < array_length(nodes_selecting); i++ )  {
            var _node = nodes_selecting[i];
            x0 = min(x0, _node.x);
            y0 = min(y0, _node.y);
            x1 = max(x1, _node.x + _node.w);
            y1 = max(y1, _node.y + _node.h);
        }
        
        x0 -= 32;
        y0 -= 32;
        x1 += 32;
        y1 += 32;
    
        var _frame = nodeBuild("Node_Frame", x0, y0, getCurrentContext()).skipDefault();
        _frame.inputs[0].setValue([x1 - x0, y1 - y0]);
        _frame.tb_name.activate("Frame");
        
        _frame.setCoveringNodes(nodes_selecting);
        _frame.reFrame();
        
        return _frame;
    } 
	
    function doExport(_node = getFocusingNode()) {
        if(!_node) return noone;
    
        var _outp = -1;
        var _path = -1;
    
        for( var i = 0; i < array_length(_node.outputs); i++ ) {
            if(_node.outputs[i].type == VALUE_TYPE.path)
                _path = _node.outputs[i];
            if(_node.outputs[i].type == VALUE_TYPE.surface && _outp == -1)
                _outp = _node.outputs[i];
        }
    
        if(_outp == -1) return noone;
    
        var _export = nodeBuild("Node_Export", _node.x + _node.w + 64, _node.y);
        if(_path != -1) _export.inputs[1].setFrom(_path);
    
        _export.inputs[0].setFrom(_outp);
        return _export;
    }
	
	function doNewNode(_nodeType) {
		
		if(pFOCUS) {
			if(mouse_create_x == undefined || mouse_create_sx != mouse_grid_x || mouse_create_sy != mouse_grid_y) {
	            mouse_create_sx = mouse_grid_x;
	            mouse_create_sy = mouse_grid_y;
	            
	            mouse_create_x = mouse_grid_x;
	            mouse_create_y = mouse_grid_y;
	        } 
		} else {
			mouse_create_x = graph_cx;
			mouse_create_y = graph_cy;
		}
        
        var _mx = mouse_create_x;
        var _my = mouse_create_y;
        var _gs = project.graphGrid.size;
        
        var node = nodeBuild(_nodeType, _mx, _my);
        if(node == noone) return noone;
        
        mouse_create_y = ceil((mouse_create_y + node.h + _gs / 2) / _gs) * _gs;
        
        if(value_dragging != noone) {
	        if(value_dragging.connect_type == CONNECT_TYPE.output) {
	            if(node.input_display_list != -1) {
	                for (var i = 0, n = array_length(node.input_display_list); i < n; i++) {
	                    if(!is_real(node.input_display_list[i])) continue;
	                    if(node.inputs[node.input_display_list[i]].setFrom(value_dragging)) break;
	                }
	                    
	            } else {
	                for (var i = 0, n = array_length(node.inputs); i < n; i++)
	                    if(node.inputs[i].setFrom(value_dragging)) break;
	            }
	            
	        } else if(value_dragging.connect_type == CONNECT_TYPE.input) {
	            for (var i = 0, n = array_length(node.outputs); i < n; i++)
	                if(value_dragging.setFrom(node.outputs[i])) break;
	                
	        }
	        
	        value_dragging = noone;
	        return node;
        }
        
        if(array_length(nodes_selecting) == 1) {
        	var sNode = nodes_selecting[0];
        	var _jOut = sNode.getOutput();
        	var _jIn  = node.getInput();
        	
        	if(_jOut != noone && _jIn != noone && _jIn.setFrom(_jOut)) {
        		node.x = sNode.x + sNode.w + 64;
        		node.y = sNode.y;
        	}
        	
        	return node;
        }
        
        return node;
	}
	
    function getFocusStr() {
    	var _n = array_safe_get(nodes_selecting, 0);
    	return instanceof(_n) == FOCUS_STR? _n : noone;
    }
    
    function doDuplicate() {
        if(array_empty(nodes_selecting)) return;
        
        var _c = nodeClone(nodes_selecting);
        
        if(array_empty(APPEND_LIST)) return;
        
        for( var i = 0, n = array_length(nodes_selecting); i < n; i++ ) {
            var _orignal = nodes_selecting[i];
            
            var _cloned = ds_map_try_get(APPEND_MAP, _orignal.node_id, "");
            if(_cloned == "") continue;
            
            var _inline_ctx = _orignal.inline_context;
            if(_inline_ctx == noone) continue;
            
            _inline_ctx = ds_map_try_get(APPEND_MAP, _inline_ctx.node_id, _inline_ctx.node_id);
            _inline_ctx = project.nodeMap[? _inline_ctx]
            _inline_ctx.addNode(project.nodeMap[? _cloned]);
        }
        
        var x0 = infinity, y0 = infinity;
        for(var i = 0, n = array_length(APPEND_LIST); i < n; i++) {
            var _node = APPEND_LIST[i];
            
            x0 = min(x0, _node.x);
            y0 = min(y0, _node.y);
        }
    	
        node_dragging = APPEND_LIST[0];
        node_drag_mx  = x0; node_drag_my  = y0;
        node_drag_sx  = x0; node_drag_sy  = y0;
        node_drag_ox  = x0; node_drag_oy  = y0;
        
        nodes_selecting = APPEND_LIST;
    }

    function doInstance() {
        var node = getFocusingNode();
        if(!is(node, Node_Group)) return;
    	
        var _nodeNew  = new Node_Group(0, 0, PANEL_GRAPH.getCurrentContext()).setInstance(node);
    	
        nodes_selecting = [_nodeNew];
        node_dragging = _nodeNew;
        node_drag_mx  = _nodeNew.x; node_drag_my  = _nodeNew.y;
        node_drag_sx  = _nodeNew.x; node_drag_sy  = _nodeNew.y;
        node_drag_ox  = _nodeNew.x; node_drag_oy  = _nodeNew.y;
        
    }

    function doCopy() {
        if(array_empty(nodes_selecting)) return;
        clipboard_set_text("");
    	LOADING_VERSION = SAVE_VERSION;
    	
        var _map = { version: SAVE_VERSION, nodes: [] };
        
        for( var i = 0, n = array_length(nodes_selecting); i < n; i++ )
            SAVE_NODE(_map.nodes, nodes_selecting[i], 0, 0, false, getCurrentContext());
        
        clipboard_set_text(json_stringify_minify(_map));
    } 

    function doPasteSurface() {
    	var s = clipboard_get_surface();
    	if(s == noone) return false;
    	
    	var n = nodeBuild("Node_Image_Buffer", mouse_grid_x, mouse_grid_y).skipDefault();
    	n.attributes.data   = s.buffer;
		n.attributes.width  = s.w;
		n.attributes.height = s.h;
		surface_free_safe(s.surface);
		return true;
    }
    
    function doPasteNode(_map) {
    	ds_map_clear(APPEND_MAP);
        CLONING  = true;
        var _app = __APPEND_MAP(_map, getCurrentContext(), [], true);
        recordAction(ACTION_TYPE.collection_loaded, array_clone(_app));
        CLONING  = false;
        
        if(_app == noone || array_empty(_app)) return;
    	
        for( var i = 0, n = array_length(_app); i < n; i++ ) {
            var _sel = _app[i];
            
            var _inline_ctx_id = _sel[$ "ictx"] ?? "";
            if(_inline_ctx_id == "") continue;
            
            _inline_ctx_id  = ds_map_try_get(APPEND_MAP, _inline_ctx_id, _inline_ctx_id);
            var _inline_ctx = ds_map_try_get(project.nodeMap, _inline_ctx_id, noone);
            
        	if(_inline_ctx == noone) continue;
            _inline_ctx.addNode(_sel);
        }
        
        var x0 = infinity, y0 = infinity;
        for(var i = 0; i < array_length(_app); i++) {
            var _node = _app[i];
        
            x0 = min(x0, _node.x);
            y0 = min(y0, _node.y);
        }
		
        node_dragging = _app[0];
        node_drag_mx  = x0; node_drag_my  = y0;
        node_drag_sx  = x0; node_drag_sy  = y0;
        node_drag_ox  = x0; node_drag_oy  = y0;
    
        nodes_selecting = _app;
    }
    
    function doPaste() {
    	if(doPasteSurface()) return;
    	
        var txt  = clipboard_get_text();
        var _map = json_try_parse(txt, noone);
        if(txt == "") return;
        
        if(is_struct(_map)) { doPasteNode(_map); return; }
        
        var _ext = filename_ext_raw(string_trim(txt, ["\""]));
        
        switch(_ext) {
        	case "pxc" : 
        	case "pxcc" : 
        		APPEND(txt); 
        		break;
        		
        	case "png" : 
        	case "jpg" : 
        		if(file_exists_empty(txt)) { 
        			Node_create_Image_path(0, 0, txt); 
        			break; 
        		}
        		
        		var path = $"{TEMPDIR}url_pasted_{seed_random()}.png";
	            var img  = http_get_file(txt, path);
	            var node = new Node_Image(0, 0);
	            node.skipDefault();
	            
	            var args = [ node, path ];
	    		
	            global.FILE_LOAD_ASYNC[? img] = [ function(a) /*=>*/ { a[0].inputs[0].setValue(a[1]); }, args];
	            break;
        	
        	case "gif" : 
        		if(file_exists_empty(txt))
        			Node_create_Image_gif_path(0, 0, txt); 
    			break; 
        }
        
    } 

    function doGroup() { //
        if(array_empty(nodes_selecting)) return;
        groupNodes(nodes_selecting);
    } 

    function doUngroup() { //
        var _node = getFocusingNode();
        if(_node == noone) return;
        if(!is(_node, Node_Collection) || !_node.ungroupable) return;
    
        upgroupNode(_node);
    } 
	
	function doGroupRemoveInstance() {
		var _node = getFocusingNode();
        if(!is(_node, Node_Collection)) return;
        
        _node.resetInstance();
	}
	
	function doGroupUpdate() {
		var _node = getFocusingNode();
        if(is(!_node, Node_Collection)) return;
        if(_node.collPath == "") return;
        
        saveCollection(_node, _node.collPath, false, _node.metadata);
	}
	
    function doDelete(_merge = false) { //
        __temp_merge = _merge;
        
        for(i = array_length(nodes_selecting) - 1; i >= 0; i--) {
            var _node = array_safe_get_fast(nodes_selecting, i, 0);
            if(_node && _node.manual_deletable) 
                _node.destroy(__temp_merge);
        }
        nodes_selecting = [];
    } 
    
    node_prop_clipboard = noone;
    function doCopyProp() { //
        if(node_hover == noone) return;
        node_prop_clipboard = node_hover;
    } 
        
    function doPasteProp() { //
        if(node_hover == noone) return;
        if(node_prop_clipboard == noone) return;
        if(!node_prop_clipboard.active) return;
        
        if(instanceof(node_prop_clipboard) != instanceof(node_hover)) return;
        
        var _vals = [];
        for( var i = 0, n = array_length(node_prop_clipboard.inputs); i < n; i++ ) {
            var _inp = node_prop_clipboard.inputs[i];
            _vals[i] = _inp.serialize();
        }
        
        for( var i = 0, n = array_length(node_hover.inputs); i < n; i++ ) {
            var _inp = node_hover.inputs[i];
            if(_inp.value_from != noone) continue;
            
            _inp.applyDeserialize(_vals[i]);
        }
        
        node_hover.clearInputCache();
        RENDER_PARTIAL
    } 
    
    function doRename() {
    	if(array_empty(nodes_selecting)) return;
    	
    	__renaming_node = nodes_selecting[0];
    	textboxCall(__renaming_node.getDisplayName(), function(txt) /*=>*/ {return __renaming_node.setDisplayName(txt)});
    }
    
    function doMassConnect() {
    	if(nodes_select_anchor == noone) return;
    	
    	var anc = nodes_select_anchor;
    	if(array_empty(anc.outputs)) return;
    	
    	var out = anc.outputs[0];
    	
    	for( var i = 0, n = array_length(nodes_selecting); i < n; i++ ) {
    		var node = nodes_selecting[i];
    		if(node == anc) continue;
    		
    		var inp = node.getInput(0, out);
    		if(inp == noone) continue;
    		
    		inp.setFrom(out);
    	}
    }
    
    function dropFile(path) { //
        if(node_hovering && is_callable(node_hovering.on_drop_file))
            return node_hovering.on_drop_file(path);
        return false;
    } 
    
    function selectDragNode(_node, _add = false) {
    	nodes_selecting = [ _node ];
    	node_dragging   = _node;
    	
    	_node.x = mouse_graph_x - _node.w / 2;
		_node.y = mouse_graph_y - _node.h / 2;
    	
        node_drag_mx = mouse_graph_x;
        node_drag_my = mouse_graph_y;
        node_drag_sx = _node.x;
        node_drag_sy = _node.y;
        node_drag_ox = -1;
        node_drag_oy = -1;
        
        node_drag_add = _add;
    }
    
    static checkDropItem = function() { //
        var node = noone;
        
        switch(DRAGGING.type) {
            case "Color":
                node = nodeBuild("Node_Color", mouse_grid_x, mouse_grid_y).skipDefault();
                node.inputs[0].setValue(DRAGGING.data);
                break;
                
            case "Palette":
                node = nodeBuild("Node_Palette", mouse_grid_x, mouse_grid_y).skipDefault();
                node.inputs[0].setValue(DRAGGING.data);
                break;
                
            case "Gradient":
                node = nodeBuild("Node_Gradient_Out", mouse_grid_x, mouse_grid_y).skipDefault();
                node.inputs[0].setValue(DRAGGING.data);
                break;
            
            case "Number":
                if(is_array(DRAGGING.data) && array_length(DRAGGING.data) <= 4) {
                    switch(array_length(DRAGGING.data)) {
                        case 2 : node = nodeBuild("Node_Vector2", mouse_grid_x, mouse_grid_y).skipDefault(); break;
                        case 3 : node = nodeBuild("Node_Vector3", mouse_grid_x, mouse_grid_y).skipDefault(); break;
                        case 4 : node = nodeBuild("Node_Vector4", mouse_grid_x, mouse_grid_y).skipDefault(); break;
                    }
                    
                    for( var i = 0, n = array_length(DRAGGING.data); i < n; i++ )
                        node.inputs[i].setValue(DRAGGING.data[i]);
                } else {
                    node = nodeBuild("Node_Number", mouse_grid_x, mouse_grid_y).skipDefault();
                    node.inputs[0].setValue(DRAGGING.data);
                }
                break;
                
            case "Bool":
                node = nodeBuild("Node_Boolean", mouse_grid_x, mouse_grid_y).skipDefault();
                node.inputs[0].setValue(DRAGGING.data);
                break;
                
            case "Text":
                node = nodeBuild("Node_String", mouse_grid_x, mouse_grid_y).skipDefault();
                node.inputs[0].setValue(DRAGGING.data);
                break;
                
            case "Path":
                node = nodeBuild("Node_Path", mouse_grid_x, mouse_grid_y).skipDefault();
                break;
                
            case "Struct":
                node = nodeBuild("Node_Struct", mouse_grid_x, mouse_grid_y).skipDefault();
                break;
                
            case "Asset":
                var app = Node_create_Image_path(mouse_grid_x, mouse_grid_y, DRAGGING.data.path);
                break;
                
            case "Collection":
                nodes_selecting = [];
                
            	var data = DRAGGING.data;
                var path = data.path;
                var app  = APPEND(data.path, getCurrentContext());
            
                if(is_array(app)) {
                    var cx = 0;
                    var cy = 0;
                    var amo = array_length(app);
                    
                    for( var i = 0; i < amo; i++ ) {
                        cx += app[i].x;
                        cy += app[i].y;
                    }
                    
                    cx /= amo;
                    cy /= amo;
                    
                    for( var i = 0; i < amo; i++ ) {
                        app[i].x = app[i].x - cx + mouse_grid_x;
                        app[i].y = app[i].y - cy + mouse_grid_y;
                    }
                    
                } else if(is_struct(app) && is(app, Node)) {
                    if(is(app, Node_Collection)) {
                    	app.metadata = data.getMetadata();
                    	app.collPath = path;
                    }
                    
                    app.x = mouse_grid_x;
                    app.y = mouse_grid_y;
                }
                break;
            
            case "Project":
                run_in(1, function(_data) /*=>*/ {
                	var _path = _data.path;
                	var _read = _data[$ "readonly"] ?? false;
                	
                	LOAD_PATH(_path, _read);
            	}, [ DRAGGING.data ]);
                break;
                
            case "Node":
                node = DRAGGING.data.build(mouse_grid_x, mouse_grid_y, getCurrentContext());
                nodes_selecting = [ node ];
                break;
                
            case "GMSprite" :
				node = Node_create_Image_path(mouse_grid_x, mouse_grid_y, DRAGGING.data.thumbnailPath);
				break;
				
            case "GMTileSet" :
				node = nodeBuild("Node_Tile_Tileset", mouse_grid_x, mouse_grid_y).skipDefault();
				node.bindTile(DRAGGING.data);
				break;
				
            case "GMRoom" :
				node = nodeBuild("Node_GMRoom", mouse_grid_x, mouse_grid_y).skipDefault();
				node.bindRoom(DRAGGING.data);
				break;
        }
            
        if(!key_mod_press(SHIFT) && node && struct_has(DRAGGING, "from") && DRAGGING.from.value_from == noone) {
            for( var i = 0; i < array_length(node.outputs); i++ )
                if(DRAGGING.from.setFrom(node.outputs[i])) break;
        }
    } 
    
    static bringNodeToFront = function(node) { //
        if(!array_exists(nodes_list, node)) return;
        
        array_remove(nodes_list, node);
        array_push(nodes_list, node);
    } 
    
    static onFullScreen = function() { run_in(1, fullView); }
    
    function searchNodes() {
        nodes_selecting = [];
        search_result   = [];
        search_index    = 0;
        
        if(search_string == "") return;
        
        var _search = string_lower(search_string);
        
        for(var i = 0; i < array_length(nodes_list); i++) {
            var _nl   = nodes_list[i];
            var _name = string_lower(_nl.getDisplayName());
            
            var _match = string_full_match(_name, _search);
            _nl.search_match = _match;
            
            if( _match == -9999) continue;
            
            array_push(nodes_selecting, _nl);
            array_push(search_result,   _nl);
        }
        
        if(!array_empty(nodes_selecting))
            toCenterNode(nodes_selecting);
    }
    
    function toggleSearch() { 
        is_searching = !is_searching; 
        
        if(is_searching) {
            search_string  = "";
            WIDGET_CURRENT = tb_search;
            KEYBOARD_RESET
        }
    }
    
    function hideDisconnected() {
        var _list = array_empty(nodes_selecting)? nodes_list : nodes_selecting;
        
        for (var i = 0, n = array_length(_list); i < n; i++) {
            var _node = _list[i];
            
            for(var j = 0; j < array_length(_node.inputs); j++) {
                var _jun = _node.inputs[j];
                if(!_jun.isVisible()) continue;
                
                if(_jun.value_from == noone)
                    _jun.setVisibleManual(-1);
            }
            
            for(var j = 0; j < array_length(_node.outputs); j++) {
                var _jun = _node.outputs[j];
                if(!_jun.isVisible()) continue;
                
                if(array_empty(_jun.getJunctionTo()))
                    _jun.setVisibleManual(-1);
            }
            
            _node.refreshNodeDisplay();
        }
    }
    
    function createTunnel() {
        if(__junction_hovering == noone) return;
        if(__junction_hovering.value_from == noone) return;
        
        var _jo = __junction_hovering.value_from;
        var _ji = __junction_hovering;
        
        var _key = $"{__junction_hovering.name} {seed_random(3)}";
        
        var _ti = nodeBuild("Node_Tunnel_In",  _jo.rx + 32, _jo.ry - 8).skipDefault();
        var _to = nodeBuild("Node_Tunnel_Out", _ji.rx - 32, _ji.ry - 8).skipDefault();
        
        _to.inputs[0].setValue(_key);
        _ti.inputs[0].setValue(_key);
        
        _ti.inputs[1].setFrom(_jo);
        _ji.setFrom(_to.outputs[0]);
        
        _to.inputs[0].updateColor();
        _ti.inputs[1].updateColor();
        
        run_in(1, function() /*=>*/ { RENDER_ALL_REORDER });
    }
    
    function createAction() {
        if(array_empty(nodes_selecting)) return;
        
        var pan = new Panel_Action_Create();
            pan.setNodes(nodes_selecting);
            pan.spr = PANEL_PREVIEW.getNodePreviewSurface();
            
        var dia = dialogPanelCall(pan);
    }
    
    function searchWiki() {
    	if(array_empty(nodes_selecting)) return;
    	
    	var dia = dialogCall(o_dialog_generic)
    		.setContent("Open URL", "Open documentation in browser?")
    		.setButtons([
				[ __txt("Open"),   function() /*=>*/ {
			    	var _node = nodes_selecting[0];
			    	var _type = string_replace(string_lower(instanceof(_node)), "node_", "");
			    	var _url  = $"https://docs.pixel-composer.com/nodes/_index/{_type}.html";
			    	URL_open(_url);
			    } ],
				[ __txt("Cancel"), function() /*=>*/ {} ],
			]);
    }
    
    function viewSource() {
    	if(array_empty(nodes_selecting)) return;
    	
    	var dia = dialogCall(o_dialog_generic)
    		.setContent("Open URL", "Open source code in browser?")
    		.setButtons([
				[ __txt("Open"),   function() /*=>*/ {
			    	var _node = nodes_selecting[0];
			    	var _type = string_lower(instanceof(_node));
			    	var _url  = $"https://github.com/Ttanasart-pt/Pixel-Composer/blob/main/scripts/{_type}/{_type}.gml";
			    	URL_open(_url);
			    } ],
				[ __txt("Cancel"), function() /*=>*/ {} ],
			]);
    }
    
    function swapConnection() { 
    	
    	if(array_length(nodes_selecting) == 1) {
    		var _n = nodes_selecting[0];
    		
    		if(array_length(_n.inputs) >= 2 && _n.inputs[0].type == _n.inputs[1].type) {
	    		var _f0 = _n.inputs[0].value_from;
	    		var _f1 = _n.inputs[1].value_from;
	    		
	    		_n.inputs[0].setFrom(_f1);
	    		_n.inputs[1].setFrom(_f0);
	    	}
	    	
    	} else if(array_length(nodes_selecting) == 2) {
    		
	    	var _n0 = nodes_selecting[0];
			var _n1 = nodes_selecting[1];
	    	
	    	var _o0 = _n0.getOutput();
			var _o1 = _n1.getOutput();
			if(_o0 == noone || _o1 == noone) return;
			
			var _t0 = _o0.getJunctionTo();
			var _t1 = _o1.getJunctionTo();
			
			for( var i = 0, n = array_length(_t0); i < n; i++ ) _t0[i].setFrom(_o1);
			for( var i = 0, n = array_length(_t1); i < n; i++ ) _t1[i].setFrom(_o0);
    	}
    }
    
    function transferJunction(nFrom, nTo) {
    	var _toTarg = nTo.getOutput();
    	if(_toTarg == noone) return;
    	
    	for( var i = 0, n = array_length(nFrom.outputs); i < n; i++ ) {
    		var _ot = nFrom.outputs[i];
    		var _to = _ot.getJunctionTo();
    		
    		for( var j = 0, m = array_length(_to); j < m; j++ ) {
    			var _jto = _to[j];
    			if(_jto.node == nTo) continue;
    			
    			_jto.setFrom(_toTarg);
    		}
    	}
    }
    
    function transferConnection() { 
    	if(array_length(nodes_selecting) != 2) return;
    	
    	var _n0 = nodes_selecting[0];
		var _n1 = nodes_selecting[1];
    		
		     if(array_exists(_n1.getNodeFrom(), _n0)) transferJunction(_n0, _n1);
		else if(array_exists(_n0.getNodeFrom(), _n1)) transferJunction(_n1, _n0);
		else transferJunction(_n0, _n1);
    }
    
    ////- Serialize
    
    static serialize = function() { 
        _map = { 
            name: instanceof(self), 
            
            graph_x,
            graph_y,
            
            graph_s,
            graph_s_to,
        }; 
        
        if(!SAVING) _map.project = project;
        
        return _map;
    }
    
    static deserialize = function(data) { 
        if(struct_has(data, "project")) setProject(data.project);
        
        graph_x = struct_try_get(data, "graph_x", graph_x);
        graph_y = struct_try_get(data, "graph_y", graph_y);
        
        graph_s    = struct_try_get(data, "graph_s",    graph_s);
        graph_s_to = struct_try_get(data, "graph_s_to", graph_s_to);
        
        return self; 
    }
    
    function close() { //
        var panels = findPanels("Panel_Graph");
        
        for( var i = 0, n = array_length(panels); i < n; i++ ) {
            var _pan = panels[i];
            
            if(_pan == self) continue;
            
            if(_pan.project == project) { //Not the last panel with that project, hence not closing the project just a panel.
                panel.remove(self);
                return;
            }
        }
        
        if(!project.modified || project.readonly) {
            closeProject(project);
            return;
        }
        
        var dia = dialogCall(o_dialog_save);
        dia.project = project;
    } 
    
    setProject(_project);
    initSize();
}

	////- File
    
function load_file_path(path, _x = undefined, _y = undefined) {
    if(!is_array(path)) path = [ path ];
    if(array_length(path) == 0) return; 
    
    _x = _x == undefined? PANEL_GRAPH.graph_cx : _x;
    _y = _y == undefined? PANEL_GRAPH.graph_cy : _y;
    
    var type = "others";
    
    if(array_length(path) == 1 && directory_exists(path[0]))
        type = "image";
        
    for( var i = 0, n = array_length(path); i < n; i++ ) {
        var p = path[i];
        var ext = string_lower(filename_ext(p));
        
        switch(ext) {
            case ".png"     :
            case ".jpg"     :
            case ".jpeg" :
                type = "image";
                break;
        }
    }
    
    var is_multi = type == "image" && (array_length(path) > 1 || directory_exists(path[0]));
    if(is_multi) { dialogCall(o_dialog_add_multiple_images).setPath(path); return; } 
    
    if(!IS_CMD) PANEL_GRAPH.onStepBegin();
    
    var node = noone;
    for( var i = 0, n = array_length(path); i < n; i++ ) {
        var p = path[i];
        var ext = filename_ext_raw(p);
        
        switch(ext) {
            case "txt"  : node = Node_create_Text_File_Read_path(_x, _y, p); break;
            case "csv"  : node = Node_create_CSV_File_Read_path(_x, _y, p);  break;
            
            case "json" : 
            	if(keyboard_check_direct(vk_shift)) dialogCall(o_dialog_add_json).setPath(p);
                else node = Node_create_Json_File_Read_path(_x, _y, p);
            	break;
                
            case "ase"      :
            case "aseprite" : node = Node_create_ASE_File_Read_path(_x, _y, p);   break;
            
            case "kra"  : node = Node_create_Krita_File_Read_path(_x, _y, p); break;
            case "ora"  : node = Node_create_ORA_File_Read_path(_x, _y, p);   break;
            
            case "png"  :
            case "jpg"  :
            case "jpeg" : 
            case "bmp"  : 
            case "tga"  : 
                if(keyboard_check_direct(vk_shift)) dialogCall(o_dialog_add_image).setPath(p);
                else node = Node_create_Image_path(_x, _y, p);
                break;
                
            case "gif"  : node = Node_create_Image_gif_path(_x, _y, p);     break;
            case "obj"  : node = Node_create_3D_Obj_path(_x, _y, p);        break;
            case "wav"  : node = Node_create_WAV_File_Read_path(_x, _y, p); break;
            case "xml"  : node = Node_create_XML_File_Read_path(_x, _y, p); break;
            case "svg"  : node = Node_create_SVG_path(_x, _y, p);           break;
            
            case "pxc"  :
            case "cpxc" : LOAD_PATH(p); break;
            case "pxcc" : APPEND(p);    break;
            
            case "hex"  : 
            case "gpl"  : 
            case "pal"  : 
                node = new Node_Palette(_x, _y, PANEL_GRAPH.getCurrentContext());
                node.skipDefault()
                node.inputs[0].setValue(loadPalette(p));
                break;
                
        	default : 
        		if(string_starts_with(ext, "pxc")) LOAD_PATH(p);
        }
        
        if(!IS_CMD) PANEL_GRAPH.mouse_grid_y += 160;
    }
}

function Panel_Graph_Drop_tooltip(panel) constructor {
	self.panel   = panel;
	
	static drawTooltip = function() {
		var _drop = __txt("Import File");
		var _shft = __txt("Options") + "...";
		
		draw_set_font(f_p1);
		var w1 = string_width(_drop);
		var h1 = string_height(_drop);
		
		draw_set_font(f_p2);
		var w2 = string_width(_shft) + string_width("Shift") + ui(16);
		var h2 = string_height(_shft);
		
		var tw = max(w1, w2);
		var th = h1 + ui(8) + h2;
		
		var mx = min(mouse_mxs + ui(16), WIN_W - (tw + ui(16)));
		var my = min(mouse_mys + ui(16), WIN_H - (th + ui(16)));
		
		draw_sprite_stretched(THEME.textbox, 3, mx, my, tw + ui(16), th + ui(16));
		draw_sprite_stretched(THEME.textbox, 0, mx, my, tw + ui(16), th + ui(16));
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text);
		draw_text(mx + ui(8), my + ui(8), _drop);
		
		draw_set_font(f_p2);
		var _hx = mx + ui(12) + string_width("Shift");
		var _hy = my + ui(8) + h1 + ui(4) + h2 / 2 + ui(4);
		hotkey_draw("Shift", _hx, _hy);
		
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
		draw_text(_hx + ui(8), my + ui(8) + h1 + ui(6), _shft);
	}
}