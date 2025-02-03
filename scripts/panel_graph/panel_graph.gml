#region function calls
    #macro PANEL_GRAPH_PROJECT_CHECK if(PANEL_GRAPH.project == noone || !PANEL_GRAPH.project.active) return;
    
    function panel_graph_add_node()                { CALL("graph_add_node");            PANEL_GRAPH.callAddDialog();                                                                    }
    function panel_graph_focus_content()           { CALL("graph_focus_content");       PANEL_GRAPH.fullView();                                                                         }
    function panel_graph_preview_focus()           { CALL("graph_preview_focus");       PANEL_GRAPH.setCurrentPreview();                                                                }
    
    function panel_graph_import_image()            { CALL("graph_import_image");        PANEL_GRAPH.createNodeHotkey("Node_Image");                                                     }
    function panel_graph_import_image_array()      { CALL("graph_import_image_array");  PANEL_GRAPH.createNodeHotkey("Node_Image_Sequence");                                            }
    function panel_graph_add_number()              { CALL("graph_add_number");          PANEL_GRAPH.createNodeHotkey("Node_Number");                                                    }
    function panel_graph_add_vec2()                { CALL("graph_add_vec2");            PANEL_GRAPH.createNodeHotkey("Node_Vector2");                                                   }
    function panel_graph_add_vec3()                { CALL("graph_add_vec3");            PANEL_GRAPH.createNodeHotkey("Node_Vector3");                                                   }
    function panel_graph_add_vec4()                { CALL("graph_add_vec4");            PANEL_GRAPH.createNodeHotkey("Node_Vector4");                                                   }
    function panel_graph_add_display()             { CALL("graph_add_disp");            PANEL_GRAPH.createNodeHotkey("Node_Display_Text");                                              }
    function panel_graph_add_math_add()            { CALL("graph_add_math_add");        PANEL_GRAPH.createNodeHotkey(Node_create_Math, { query: "add" });                               }
    
    function panel_graph_select_all()              { CALL("graph_select_all");          PANEL_GRAPH.nodes_selecting = PANEL_GRAPH.nodes_list;                                           }
    function panel_graph_toggle_grid()             { CALL("graph_toggle_grid");         PANEL_GRAPH.display_parameter.show_grid      = !PANEL_GRAPH.display_parameter.show_grid;        }
    function panel_graph_toggle_dimension()        { CALL("graph_toggle_dimension");    PANEL_GRAPH.display_parameter.show_dimension = !PANEL_GRAPH.display_parameter.show_dimension;   }
    function panel_graph_toggle_compute()          { CALL("graph_toggle_compute");      PANEL_GRAPH.display_parameter.show_compute   = !PANEL_GRAPH.display_parameter.show_compute;     }
    function panel_graph_toggle_control()          { CALL("graph_toggle_control");      PANEL_GRAPH.display_parameter.show_control   = !PANEL_GRAPH.display_parameter.show_control;     }
    function panel_graph_toggle_avoid_label()      { CALL("graph_toggle_avoid_label");  PANEL_GRAPH.display_parameter.avoid_label    = !PANEL_GRAPH.display_parameter.avoid_label;      }
    
    function panel_graph_add_transform()           { CALL("graph_add_transform");       PANEL_GRAPH.doTransform();                                                                      }
    function panel_graph_blend()                   { CALL("graph_blend");               PANEL_GRAPH.doBlend();                                                                          }
    function panel_graph_compose()                 { CALL("graph_compose");             PANEL_GRAPH.doCompose();                                                                        }
    function panel_graph_array()                   { CALL("graph_array");               PANEL_GRAPH.doArray();                                                                          }
    function panel_graph_group()                   { CALL("graph_group");               PANEL_GRAPH.doGroup();                                                                          }
    function panel_graph_ungroup()                 { CALL("graph_ungroup");             PANEL_GRAPH.doUngroup();                                                                        }
    function panel_graph_export()                  { CALL("graph_export");              PANEL_GRAPH.setCurrentExport();                                                                 }
                                                                                                                            
    function panel_graph_canvas_copy()             { CALL("graph_canvas_copy");         PANEL_GRAPH.setCurrentCanvas();                                                                 }
    function panel_graph_canvas_blend()            { CALL("graph_canvas_blend");        PANEL_GRAPH.setCurrentCanvasBlend();                                                            }
                                                                                                                            
    function panel_graph_frame()                   { CALL("graph_frame");               PANEL_GRAPH.doFrame();                                                                          }
    function panel_graph_delete_break()            { CALL("graph_delete_break");        PANEL_GRAPH.doDelete(false);                                                                    }
    function panel_graph_delete_merge()            { CALL("graph_delete_merge");        PANEL_GRAPH.doDelete(true);                                                                     }
    function panel_graph_duplicate()               { CALL("graph_duplicate");           PANEL_GRAPH.doDuplicate();                                                                      }
    function panel_graph_copy()                    { CALL("graph_copy");                PANEL_GRAPH.doCopy();                                                                           }
    function panel_graph_paste()                   { CALL("graph_paste");               PANEL_GRAPH.doPaste();                                                                          }
    
    function panel_graph_auto_organize()           { CALL("graph_auto_organize");       node_auto_organize(PANEL_GRAPH.nodes_selecting);                                                }
    function panel_graph_auto_align()              { CALL("graph_auto_align");          node_auto_align(PANEL_GRAPH.nodes_selecting);                                                   }
    function panel_graph_snap_nodes()              { CALL("graph_snap_nodes");          node_snap_grid(PANEL_GRAPH.nodes_selecting, PANEL_GRAPH.project.graphGrid.size);                }
    function panel_graph_search()                  { CALL("graph_search");              PANEL_GRAPH.toggleSearch();                                                                     }
    function panel_graph_toggle_minimap()          { CALL("graph_toggle_minimap");      PANEL_GRAPH.minimap_show = !PANEL_GRAPH.minimap_show;                                           }
                                                                                                                            
    function panel_graph_pan()                     { CALL("graph_pan");  if(PANEL_GRAPH.node_hovering || PANEL_GRAPH.value_focus) return; PANEL_GRAPH.graph_dragging_key = true;        }
    function panel_graph_zoom()                    { CALL("graph_zoom"); if(PANEL_GRAPH.node_hovering || PANEL_GRAPH.value_focus) return; PANEL_GRAPH.graph_zooming_key  = true;        }
    
    function panel_graph_send_to_preview()         { CALL("graph_send_to_preview");     PANEL_GRAPH.send_to_preview();                                                                  }
    function panel_graph_preview_window()          { CALL("graph_preview_window");      create_preview_window(PANEL_GRAPH.getFocusingNode());                                           }
    function panel_graph_inspector_panel()         { CALL("graph_inspector_panel");     PANEL_GRAPH.inspector_panel();                                                                  }
    function panel_graph_send_to_export()          { CALL("graph_send_to_export");      PANEL_GRAPH.send_hover_to_export();                                                             }
    function panel_graph_toggle_preview()          { CALL("graph_toggle_preview");      PANEL_GRAPH.setTriggerPreview();                                                                }
    function panel_graph_toggle_render()           { CALL("graph_toggle_render");       PANEL_GRAPH.setTriggerRender();                                                                 }
    function panel_graph_toggle_parameter()        { CALL("graph_toggle_parameter");    PANEL_GRAPH.setTriggerParameter();                                                              }
    function panel_graph_enter_group()             { CALL("graph_enter_group");         PANEL_GRAPH.enter_group();                                                                      }
    function panel_graph_hide_disconnected()       { CALL("graph_hide_disconnected");   PANEL_GRAPH.hide_disconnected();                                                                }
    
    function panel_graph_open_group_tab()          { CALL("graph_open_group_tab");      PANEL_GRAPH.open_group_tab();                                                                   }
    function panel_graph_set_as_tool()             { CALL("graph_open_set_as_tool");    PANEL_GRAPH.set_as_tool();                                                                      }
    
    function panel_graph_doCopyProp()              { CALL("graph_doCopyProp");          PANEL_GRAPH.doCopyProp();                                                                       }
    function panel_graph_doPasteProp()             { CALL("graph_doPasteProp");         PANEL_GRAPH.doPasteProp();                                                                      }
    function panel_graph_createTunnel()            { CALL("graph_createTunnel");        PANEL_GRAPH.createTunnel();                                                                     }
    
    function panel_graph_grid_snap()               { CALL("graph_grid_snap");         PANEL_GRAPH_PROJECT_CHECK PANEL_GRAPH.project.graphGrid.snap = !PANEL_GRAPH.project.graphGrid.snap;               }
    function panel_graph_show_origin()             { CALL("graph_grid_show_origin");  PANEL_GRAPH_PROJECT_CHECK PANEL_GRAPH.project.graphGrid.show_origin = !PANEL_GRAPH.project.graphGrid.show_origin; }
				                                                                           
    function __fnInit_Graph() {
        registerFunction("Graph", "Add Node",              "A", MOD_KEY.none,                    panel_graph_add_node            ).setMenu("graph_add_node")
        registerFunction("Graph", "Focus Content",         "F", MOD_KEY.none,                    panel_graph_focus_content       ).setMenu("graph_focus_content")
        registerFunction("Graph", "Preview Focusing Node", "P", MOD_KEY.none,                    panel_graph_preview_focus       ).setMenu("graph_preview_focusing_node")
                                                                                        
        registerFunction("Graph", "Import Image",          "I", MOD_KEY.none,                    panel_graph_import_image        ).setMenu("graph_import_image")
        registerFunction("Graph", "Import Image Array",    "I", MOD_KEY.shift,                   panel_graph_import_image_array  ).setMenu("graph_import_image_array")
        registerFunction("Graph", "Add Number",            "1", MOD_KEY.none,                    panel_graph_add_number          ).setMenu("graph_add_number")
        registerFunction("Graph", "Add Vector2",           "2", MOD_KEY.none,                    panel_graph_add_vec2            ).setMenu("graph_add_vector2")
        registerFunction("Graph", "Add Vector3",           "3", MOD_KEY.none,                    panel_graph_add_vec3            ).setMenu("graph_add_vector3")
        registerFunction("Graph", "Add Vector4",           "4", MOD_KEY.none,                    panel_graph_add_vec4            ).setMenu("graph_add_vector4")
        registerFunction("Graph", "Add Display",           "D", MOD_KEY.none,                    panel_graph_add_display         ).setMenu("graph_add_display")
        registerFunction("Graph", "Transform Node",        "T", MOD_KEY.ctrl,                    panel_graph_add_transform       ).setMenu("graph_transform_node")
                                                                                        
        registerFunction("Graph", "Select All",            "A", MOD_KEY.ctrl,                    panel_graph_select_all          ).setMenu("graph_select_all")
        registerFunction("Graph", "Toggle Grid",           "G", MOD_KEY.none,                    panel_graph_toggle_grid         ).setMenu("graph_toggle_grid")
        registerFunction("Graph", "Toggle Dimension",      "",  MOD_KEY.none,                    panel_graph_toggle_dimension    ).setMenu("graph_toggle_dimension")
        registerFunction("Graph", "Toggle Compute",        "",  MOD_KEY.none,                    panel_graph_toggle_compute      ).setMenu("graph_toggle_compute")
        registerFunction("Graph", "Toggle Control",        "",  MOD_KEY.none,                    panel_graph_toggle_control      ).setMenu("graph_toggle_control")
        registerFunction("Graph", "Toggle Avoid Label",    "",  MOD_KEY.none,                    panel_graph_toggle_avoid_label  ).setMenu("graph_toggle_avoid_label")
        
        registerFunction("Graph", "Blend",                 "B", MOD_KEY.ctrl,                    panel_graph_blend               ).setMenu("graph_blend")
        registerFunction("Graph", "Compose",               "B", MOD_KEY.ctrl | MOD_KEY.shift,    panel_graph_compose             ).setMenu("graph_compose")
        registerFunction("Graph", "Array",                 "A", MOD_KEY.ctrl | MOD_KEY.shift,    panel_graph_array               ).setMenu("graph_array")
        registerFunction("Graph", "Frame",                 "F", MOD_KEY.shift,                   panel_graph_frame               ).setMenu("graph_frame")
        
        registerFunction("Graph", "Copy to Canvas",        "C", MOD_KEY.ctrl | MOD_KEY.shift,    panel_graph_canvas_copy         ).setMenu("graph_canvas_copy")
        registerFunction("Graph", "Blend Canvas",          "C", MOD_KEY.ctrl | MOD_KEY.alt,      panel_graph_canvas_blend        ).setMenu("graph_canvas_blend")
        registerFunction("Graph", "Canvas",                "",  MOD_KEY.none,                    
        	function(_dat) /*=>*/ {return submenuCall(_dat, [ MENU_ITEMS.graph_canvas_copy, MENU_ITEMS.graph_canvas_blend ])}).setMenu("graph_canvas",, true)
		
        registerFunction("Graph", "Delete (break)",        vk_delete, MOD_KEY.shift,             panel_graph_delete_break        ).setMenu("graph_delete_break",    THEME.cross)
        registerFunction("Graph", "Delete (merge)",        vk_delete, MOD_KEY.none,              panel_graph_delete_merge        ).setMenu("graph_delete_merge",    THEME.cross)
    
        registerFunction("Graph", "Duplicate",             "D", MOD_KEY.ctrl,                    panel_graph_duplicate           ).setMenu("graph_duplicate",       THEME.duplicate)
        registerFunction("Graph", "Copy",                  "C", MOD_KEY.ctrl,                    panel_graph_copy                ).setMenu("graph_copy",            THEME.copy)
        registerFunction("Graph", "Paste",                 "V", MOD_KEY.ctrl,                    panel_graph_paste               ).setMenu("graph_paste",           THEME.paste)
        
        registerFunction("Graph", "Pan",                   "", MOD_KEY.ctrl,                     panel_graph_pan                 ).setMenu("graph_pan")
        registerFunction("Graph", "Zoom",                  "", MOD_KEY.alt | MOD_KEY.ctrl,       panel_graph_zoom                ).setMenu("graph_zoom")
        
        registerFunction("Graph", "Auto Align",            "L", MOD_KEY.none,                    panel_graph_auto_align          ).setMenu("graph_auto_align")
        registerFunction("Graph", "Auto Organize",         "L", MOD_KEY.ctrl, function() /*=>*/ { dialogPanelCall(new Panel_Graph_Auto_Organize(PANEL_GRAPH.nodes_selecting)) } ).setMenu("graph_auto_organize")
        registerFunction("Graph", "Snap Nodes",            "",  MOD_KEY.none,                    panel_graph_snap_nodes          ).setMenu("graph_snap_nodes")
        registerFunction("Graph", "Search",                "F", MOD_KEY.ctrl,                    panel_graph_search              ).setMenu("graph_search")
        registerFunction("Graph", "Toggle Minimap",        "M", MOD_KEY.ctrl,                    panel_graph_toggle_minimap      ).setMenu("graph_toggle_minimap")
        
        registerFunction("Graph", "Send To Preview",       "",  MOD_KEY.none,                    panel_graph_send_to_preview     ).setMenu("graph_preview_hovering_node")
        registerFunction("Graph", "Send To Preview Window","P", MOD_KEY.ctrl,                    panel_graph_preview_window      ).setMenu("graph_preview_window")
        registerFunction("Graph", "Send To Inspector",     "",  MOD_KEY.none,                    panel_graph_inspector_panel     ).setMenu("graph_inspect")
        registerFunction("Graph", "Toggle Preview",        "H", MOD_KEY.none,                    panel_graph_toggle_preview      ).setMenu("graph_toggle_preview")
        registerFunction("Graph", "Toggle Render",         "R", MOD_KEY.none,                    panel_graph_toggle_render       ).setMenu("graph_toggle_render")
        registerFunction("Graph", "Toggle Parameters",     "M", MOD_KEY.none,                    panel_graph_toggle_parameter    ).setMenu("graph_toggle_parameters")
        registerFunction("Graph", "Hide Disconnected",     "",  MOD_KEY.none,                    panel_graph_hide_disconnected   ).setMenu("graph_hide_disconnected")
        
        registerFunction("Graph", "Enter Group",           "",  MOD_KEY.none,                    panel_graph_enter_group         ).setMenu("graph_enter_group",     THEME.group)
        registerFunction("Graph", "Open Group In New Tab", "",  MOD_KEY.none,                    panel_graph_open_group_tab      ).setMenu("graph_open_in_new_tab", THEME.group)
        registerFunction("Graph", "Group",                 "G", MOD_KEY.ctrl,                    panel_graph_group               ).setMenu("graph_group",           THEME.group)
        registerFunction("Graph", "Ungroup",               "G", MOD_KEY.ctrl | MOD_KEY.shift,    panel_graph_ungroup             ).setMenu("graph_ungroup",         THEME.group)
        registerFunction("Graph", "Set As Group Tool",     "",  MOD_KEY.none,                    panel_graph_set_as_tool         ).setMenu("graph_set_as_tool")
        
        registerFunction("Graph", "Copy Value",            "",  MOD_KEY.none,                    panel_graph_doCopyProp          ).setMenu("graph_copy_value")
        registerFunction("Graph", "Paste Value",           "",  MOD_KEY.none,                    panel_graph_doPasteProp         ).setMenu("graph_paste_value")
        registerFunction("Graph", "Create Tunnel",         "",  MOD_KEY.none,                    panel_graph_createTunnel        ).setMenu("graph_create_tunnel")
        
        registerFunction("Graph", "Toggle Grid Snap",      "",  MOD_KEY.none,                    panel_graph_grid_snap           ).setMenu("graph_grid_snap")
        registerFunction("Graph", "Toggle Show Origin",    "",  MOD_KEY.none,                    panel_graph_show_origin         ).setMenu("graph_show_origin")
                                                                                    
        if(!DEMO) {
            registerFunction("Graph", "Export Selected Node",   "E", MOD_KEY.ctrl,               panel_graph_export              ).setMenu("graph_export_selected")
            registerFunction("Graph", "Export Hovering Node",   "",  MOD_KEY.none,               panel_graph_send_to_export      ).setMenu("graph_export_hover")
        }
        
        registerFunction("Graph", "Export As Image",     "",  MOD_KEY.none,    function() /*=>*/ { dialogPanelCall(new Panel_Graph_Export_Image(PANEL_GRAPH)) }).setMenu("graph_export_image")
        registerFunction("Graph", "Connection Settings", "",  MOD_KEY.none,    function() /*=>*/ { dialogPanelCall(new Panel_Graph_Connection_Setting())      }).setMenu("graph_connection_settings")
        registerFunction("Graph", "Grid Settings",       "",  MOD_KEY.none,    function() /*=>*/ { dialogPanelCall(new Panel_Graph_Grid_Setting())            }).setMenu("graph_grid_settings")
        registerFunction("Graph", "View Settings",       "",  MOD_KEY.none,    function() /*=>*/ { dialogPanelCall(new Panel_Graph_View_Setting(PANEL_GRAPH, PANEL_GRAPH.display_parameter)) }).setMenu("graph_view_settings")
        
        __fnGroupInit_Graph()
    }
    
    function __fnGroupInit_Graph() {
        
        MENU_ITEMS.graph_group_align = menuItemGroup(__txtx("panel_graph_align_nodes", "Align"), [
                [ [THEME.inspector_surface_halign, 0], function() { node_halign(PANEL_GRAPH.nodes_selecting, fa_left);   } ],
                [ [THEME.inspector_surface_halign, 1], function() { node_halign(PANEL_GRAPH.nodes_selecting, fa_center); } ],
                [ [THEME.inspector_surface_halign, 2], function() { node_halign(PANEL_GRAPH.nodes_selecting, fa_right);  } ],
                
                [ [THEME.inspector_surface_valign, 0], function() { node_valign(PANEL_GRAPH.nodes_selecting, fa_top);    } ],
                [ [THEME.inspector_surface_valign, 1], function() { node_valign(PANEL_GRAPH.nodes_selecting, fa_middle); } ],
                [ [THEME.inspector_surface_valign, 2], function() { node_valign(PANEL_GRAPH.nodes_selecting, fa_bottom); } ],
                
                [ [THEME.obj_distribute_h, 0],         function() { node_hdistribute(PANEL_GRAPH.nodes_selecting);       } ],
                [ [THEME.obj_distribute_v, 0],         function() { node_vdistribute(PANEL_GRAPH.nodes_selecting);       } ],
        ], ["Graph", "Align Nodes"]);
        registerFunction("Graph", "Align Nodes",           "",  MOD_KEY.none,                    function() /*=>*/ { menuCall("", [ MENU_ITEMS.graph_group_align ]); });
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        var _clrs = COLORS.labels;
        var _item = array_create(array_length(_clrs));

        for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
            _item[i] = [ 
                [ THEME.timeline_color, i > 0, _clrs[i] ], 
                function(_data) /*=>*/ {  PANEL_GRAPH.setSelectingNodeColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
            ];
        }

        array_push(_item, [ [ THEME.timeline_color, 2 ], function() /*=>*/ { colorSelectorCall(PANEL_GRAPH.node_hover? PANEL_GRAPH.node_hover.attributes.color : c_white, PANEL_GRAPH.setSelectingNodeColor); } ]);
        
        MENU_ITEMS.graph_group_node_color = menuItemGroup(__txt("Node Color"), _item, ["Graph", "Set Node Color"]).setSpacing(ui(24));
        registerFunction("Graph", "Set Node Color",        "",  MOD_KEY.none,                    function() /*=>*/ { menuCall("", [ MENU_ITEMS.graph_group_node_color ]); });
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        var _clrs = COLORS.labels;
        var _item = array_create(array_length(_clrs));

        for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
            _item[i] = [ 
                [ THEME.timeline_color, i > 0, _clrs[i] ], 
                function(_data) /*=>*/ { PANEL_GRAPH.setSelectingJuncColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
            ];
        }

        array_push(_item, [ [ THEME.timeline_color, 2 ], function() /*=>*/ { colorSelectorCall(PANEL_GRAPH.__junction_hovering? PANEL_GRAPH.__junction_hovering.color : c_white, PANEL_GRAPH.setSelectingJuncColor); } ]);
        
        MENU_ITEMS.graph_group_junction_color = menuItemGroup(__txt("Connection Color"), _item, ["Graph", "Set Junction Color"]).setSpacing(ui(24));
        registerFunction("Graph", "Set Junction Color",    "",  MOD_KEY.none,                    function() /*=>*/ { menuCall("", [ MENU_ITEMS.graph_group_junction_color ]); });
        
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
    
function Panel_Graph(project = PROJECT) : PanelContent() constructor {
    title       = __txt("Graph");
    title_raw   = "";
    context_str = "Graph";
    icon        = THEME.panel_graph_icon;
    
    function setTitle() {
        title_raw = project.path == ""? "New project" : filename_name_only(project.path);
        title     = title_raw + (project.modified? "*" : ""); 
    }
    
    static reset = function() {
        onFocusBegin();
        resetContext();
    }
    
    #region // ---- display ----
        display_parameter = {
            show_grid       : true,
            show_dimension  : true,
            show_compute    : true,
            show_view_control : 1,
        
            avoid_label     : false,
            preview_scale   : 100,
            highlight       : false,
            
            show_control    : false,
            show_tooltip    : true, 
        }
        
        connection_param  = new connectionParameter();
        
        bg_color = c_black;
        
        slider_width = 0;
        
        tooltip_overlay = {};
        
        function addKeyOverlay(title, keys) {
        	if(struct_has(tooltip_overlay, title)) {
        		array_append(tooltip_overlay[$ title], keys);
        		return;
        	}
        	
        	tooltip_overlay[$ title] = keys;
        }
        
        tb_zoom_level = new textBox(TEXTBOX_INPUT.number, function(z) /*=>*/ { 
        	var _s = graph_s;
                
            graph_s_to = clamp(z, 0.01, 2); 
        	graph_s    = graph_s_to; 
            
            if(_s != graph_s) {
				graph_x += w / 2 * ((1 / graph_s) - (1 / _s));
				graph_y += h / 2 * ((1 / graph_s) - (1 / _s));
            }
        });
        tb_zoom_level.color  = c_white;
        tb_zoom_level.align  = fa_right;
        tb_zoom_level.hide   = 3;
        tb_zoom_level.font   = f_p2;
    #endregion
    
    #region // ---- position ----
        graph_x  = 0;
        graph_y  = 0;
        graph_cx = 0;
        graph_cy = 0;
        
        graph_autopan   = false;
        graph_pan_x_to  = 0;
        graph_pan_y_to  = 0;
        graph_pan_speed = 32;
        
        scale           = [ 0.01, 0.02, 0.05, 0.10, 0.15, 0.20, 0.25, 0.33, 0.50, 0.65, 0.80, 1, 1.2, 1.35, 1.5, 2.0 ];
        graph_s         = 1;
        graph_s_to      = graph_s;
        
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
    #endregion
    
    #region // ---- nodes ----
        node_context  = [];
        nodes_list    = [];
        
        node_dragging = noone;
        node_drag_mx  = 0;
        node_drag_my  = 0;
        node_drag_sx  = 0;
        node_drag_sy  = 0;
        node_drag_ox  = 0;
        node_drag_oy  = 0;
        node_drag_add = false;
    
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
        
        draw_refresh           = true;
        node_surface           = surface_create(1, 1);
        node_surface_update    = true;
        
        connection_aa          = 2;
        connection_surface     = surface_create(1, 1);
        connection_surface_cc  = surface_create(1, 1);
        connection_surface_aa  = surface_create(1, 1);
        
        connection_draw_mouse  = noone;
        connection_draw_target = noone;
        connection_draw_update = true;
        connection_cache  = {};
        
        value_focus     = noone;
        _value_focus    = noone;
        value_dragging  = noone;
        value_draggings = [];
        value_drag_from = noone;
        
        node_drag_search = false;
        
        frame_hovering  = noone;
        _frame_hovering = noone;
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
    
    toolbar_height = ui(40);
    
    function toCenterNode(_arr = nodes_list) {
        if(!project.active) return; 
        
        graph_s    = 1;
        graph_s_to = 1;
        
        if(array_empty(_arr)) {
            graph_x = round(w / 2 / graph_s);
            graph_y = round(h / 2 / graph_s);
            return;
        }
        
        var minx =  99999;
        var maxx = -99999;
        var miny =  99999;
        var maxy = -99999;
        
        for(var i = 0; i < array_length(_arr); i++) {
            var _node = _arr[i];
            
            if(!is_instanceof(_node, Node))                   continue;
            if(is_instanceof(_node, Node_Collection_Inline))  continue;
            if(is_instanceof(_node, Node_Feedback_Inline))    continue;
            if(!_node.active)                                 continue;
            
            minx = min(minx, _node.x - 32);
            maxx = max(maxx, _node.x + _node.w + 32);
                
            miny = min(miny, _node.y - 32);
            maxy = max(maxy, _node.y + _node.h + 32);
        }
        
        var cx = (minx + maxx) / 2;
        var cy = (miny + maxy) / 2;
        
        graph_x = (w                 ) / 2 - cx;
        graph_y = (h - toolbar_height) / 2 - cy;
        
        graph_x = round(graph_x * graph_s);
        graph_y = round(graph_y * graph_s);
        
        // print($"{cx}, {cy} / {graph_x}, {graph_y}");
    }
    
    function initSize() { toCenterNode(); }
    
    #region // ++++ toolbars ++++
        
        toolbars_general = [
            [ 
                THEME.icon_preview_export,
                function()  /*=>*/ {return 0}, 
                function()  /*=>*/ {return new tooltipHotkey(__txtx("panel_graph_export_image", "Export graph as image"), "Graph", "Export As Image")},
                function(p) /*=>*/ { dialogPanelCall(new Panel_Graph_Export_Image(self)); }
            ],
            [ 
                THEME.search_24,
                function()  /*=>*/ {return 0}, 
                function()  /*=>*/ {return new tooltipHotkey(__txt("Search"), "Graph", "Search")}, 
                function(p) /*=>*/ { toggleSearch(); }
            ],
            [ 
                THEME.icon_center_canvas,
                function()  /*=>*/ {return 0}, 
                function()  /*=>*/ {return new tooltipHotkey(__txtx("panel_graph_center_to_nodes", "Center to nodes"), "Graph", "Focus content")}, 
                function(p) /*=>*/ { toCenterNode(); } 
            ],
            [ 
                THEME.icon_minimap,
                function()  /*=>*/ {return minimap_show}, 
                function()  /*=>*/ {return new tooltipHotkey(__txtx("panel_graph_toggle_minimap", "Toggle minimap"), "Graph", "Toggle Minimap")}, 
                function(p) /*=>*/ { minimap_show = !minimap_show; } 
            ],
            [ 
                THEME.icon_curve_connection,
                function()  /*=>*/ {return project.graphConnection.type}, 
                function()  /*=>*/ {return new tooltipHotkey(__txtx("panel_graph_connection_line", "Connection render settings") + "...", "Graph", "Connection Settings")}, 
                function(p) /*=>*/ { dialogPanelCall(new Panel_Graph_Connection_Setting(), 
                								x + w - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.right }); } 
            ],
            [ 
                THEME.icon_grid_setting,
                function()  /*=>*/ {return 0}, 
                function()  /*=>*/ {return new tooltipHotkey(__txtx("grid_title", "Grid settings") + "...", "Graph", "Grid Settings")}, 
                function(p) /*=>*/ { dialogPanelCall(new Panel_Graph_Grid_Setting(), 
                								x + w - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.right }); } 
            ],
            [ 
                THEME.icon_visibility,
                function()  /*=>*/ {return 0}, 
                function()  /*=>*/ {return new tooltipHotkey(__txtx("graph_visibility_title", "Visibility settings") + "...", "Graph", "View Settiings")}, 
                function(p) /*=>*/ { dialogPanelCall(new Panel_Graph_View_Setting(self, display_parameter), 
                								x + w - ui(8), y + h - toolbar_height - ui(8), { anchor: ANCHOR.bottom | ANCHOR.right }); } 
            ],
        ]; 
        
        toolbars_halign = [
            [ THEME.object_halign, function() /*=>*/ {return 2}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_halign(nodes_selecting, fa_right);  } ],
            [ THEME.object_halign, function() /*=>*/ {return 1}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_halign(nodes_selecting, fa_center); } ],
            [ THEME.object_halign, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_halign(nodes_selecting, fa_left);   } ],
        ];
        
        toolbars_valign = [
            [ THEME.object_valign, function() /*=>*/ {return 2}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_valign(nodes_selecting, fa_bottom); } ],
            [ THEME.object_valign, function() /*=>*/ {return 1}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_valign(nodes_selecting, fa_middle); } ],
            [ THEME.object_valign, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_valign(nodes_selecting, fa_top);    } ],
        ];
        
        toolbars_distrib = [
            [ THEME.obj_distribute_h, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_hdistribute(nodes_selecting); } ],
            [ THEME.obj_distribute_v, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_vdistribute(nodes_selecting); } ],
        ];
        
        toolbars_auto_arrange = [
            [ THEME.obj_auto_align,    function() /*=>*/ {return 0}, function() /*=>*/ {return "Auto align"},    function(p) /*=>*/ { node_auto_align(nodes_selecting); } ],
            [ THEME.obj_auto_organize, function() /*=>*/ {return 0}, function() /*=>*/ {return "Auto organize"}, function(p) /*=>*/ { dialogPanelCall(new Panel_Graph_Auto_Organize(PANEL_GRAPH.nodes_selecting), p.x, p.y, { anchor: ANCHOR.bottom | ANCHOR.left }) } ],
        ];
        
        distribution_spacing = 0;
        toolbars_distrib_space = [
            [ THEME.obj_distribute_h, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_hdistribute_dist(nodes_selecting, nodes_select_anchor, distribution_spacing); } ],
            [ THEME.obj_distribute_v, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(p) /*=>*/ { node_vdistribute_dist(nodes_selecting, nodes_select_anchor, distribution_spacing); } ],
            [ new textBox(TEXTBOX_INPUT.number, function(val) { distribution_spacing = value_snap(val, 4); } ).setPadding(4), function() /*=>*/ {return distribution_spacing} ],
        ];
        
        toolbars = [ toolbars_general ];
    #endregion
    
    ////- Get
    
    function setCurrentPreview(_node = getFocusingNode()) {
        if(!_node) return;
    
        PANEL_PREVIEW.setNodePreview(_node);
    }

    function setCurrentExport(_node = getFocusingNode()) {
        if(DEMO) return;
        if(!_node) return;
    
        var _outp = -1;
        var _path = -1;
    
        for( var i = 0; i < array_length(_node.outputs); i++ ) {
            if(_node.outputs[i].type == VALUE_TYPE.path)
                _path = _node.outputs[i];
            if(_node.outputs[i].type == VALUE_TYPE.surface && _outp == -1)
                _outp = _node.outputs[i];
        }
    
        if(_outp == -1) return;
    
        var _export = nodeBuild("Node_Export", _node.x + _node.w + 64, _node.y);
        if(_path != -1)
            _export.inputs[1].setFrom(_path);
    
        _export.inputs[0].setFrom(_outp);
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
    
    function setFocusingNode(_node) { nodes_selecting = [ _node ]; return self; }
    
    function getFocusingNode() { return array_empty(nodes_selecting)? noone : nodes_selecting[0]; }
    
    ////- Menus
    
    #region ++++++++++++ Actions ++++++++++++
        function send_to_preview()    { setCurrentPreview(node_hover); }
        
        function inspector_panel()    {
            var pan = panelAdd("Panel_Inspector", true);
            pan.destroy_on_click_out = false;
            pan.content.setInspecting(node_hover);
            pan.content.locked = true;
        }
        
        function send_hover_to_export()  { setCurrentExport(node_hover); }
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
            if(node_hover == noone) return;
            node_hover.setTool(!node_hover.isTool);
        }
    #endregion
    
    menu_sent_to_preview    = MENU_ITEMS.graph_preview_hovering_node;
    menu_send_to_window     = MENU_ITEMS.graph_preview_window;
    menu_sent_to_inspector  = MENU_ITEMS.graph_inspect;
    menu_send_export        = MENU_ITEMS.graph_export_hover;
    menu_toggle_preview     = MENU_ITEMS.graph_toggle_preview;
    menu_toggle_render      = MENU_ITEMS.graph_toggle_render;
    menu_toggle_param       = MENU_ITEMS.graph_toggle_parameters;
    menu_hide_disconnect    = MENU_ITEMS.graph_hide_disconnected;
    
    menu_open_group         = MENU_ITEMS.graph_enter_group;
    menu_open_group_tab     = MENU_ITEMS.graph_open_in_new_tab;
    menu_group_group        = MENU_ITEMS.graph_group;
    menu_group_ungroup      = MENU_ITEMS.graph_ungroup;
    menu_group_tool         = MENU_ITEMS.graph_set_as_tool;
                
    menu_node_delete_cut    = MENU_ITEMS.graph_delete_break;
    menu_node_delete_merge  = MENU_ITEMS.graph_delete_merge;
    menu_node_duplicate     = MENU_ITEMS.graph_duplicate;
    menu_node_copy          = MENU_ITEMS.graph_copy;
    
    menu_nodes_align        = MENU_ITEMS.graph_group_align;
    
    menu_node_transform     = MENU_ITEMS.graph_transform_node;
    menu_nodes_blend        = MENU_ITEMS.graph_blend;
    menu_nodes_compose      = MENU_ITEMS.graph_compose;
    menu_nodes_array        = MENU_ITEMS.graph_array;
    menu_nodes_group        = MENU_ITEMS.graph_group;
    menu_nodes_frame        = MENU_ITEMS.graph_frame;
    menu_node_canvas        = MENU_ITEMS.graph_canvas;
    
    menu_node_copy_prop     = MENU_ITEMS.graph_copy_value;
    menu_node_paste_prop    = MENU_ITEMS.graph_paste_value;
    
    menu_connection_tunnel  = MENU_ITEMS.graph_create_tunnel;
    
    #region colors setters
    	__junction_hovering = noone;
        menu_node_color     = MENU_ITEMS.graph_group_node_color;
        menu_junc_color     = MENU_ITEMS.graph_group_junction_color;
        
        function setSelectingNodeColor(color) { 
            __temp_color = color;
            
            if(node_hover) node_hover.attributes.color = __temp_color;
            array_foreach(nodes_selecting, function(node) { node.attributes.color = __temp_color; });
        }
        
        function setSelectingJuncColor(color) {
            if(__junction_hovering == noone) return; 
            __junction_hovering.setColor(color);
            
            if(__junction_hovering.value_from != noone)
            	__junction_hovering.value_from.setColor(color);
        }
    #endregion
    
    ////- Project
    
    static setProject = function(project) {
        self.project = project;
        nodes_list   = project.nodes;
        connection_draw_update = true;
        
        setTitle();
        run_in(2, function() /*=>*/ { 
            setSlideShow(0); 
            struct_override(display_parameter, project.graphDisplay);
        });
    } 
    
    ////- Views
    
    function onFocusBegin() {
        PANEL_GRAPH = self; 
        PROJECT = project;
        
        nodes_select_drag = 0;
    } 
    
    function focusNode(_node) {
        if(_node == noone) {
            nodes_selecting = [];
            return;
        }
        
        nodes_selecting = [ _node ];
        fullView();
    } 
    
    function fullView() { INLINE toCenterNode(array_empty(nodes_selecting)? nodes_list : nodes_selecting); }
    
    function dragGraph() {
        if(graph_autopan) {
            graph_x = lerp_float(graph_x, graph_pan_x_to, graph_pan_speed, 1);
            graph_y = lerp_float(graph_y, graph_pan_y_to, graph_pan_speed, 1);
            
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
                
                graph_s_to = clamp(graph_s_to * (1 + dy), scale[0], scale[array_length(scale) - 1]);
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
        
        if(mouse_on_graph && pHOVER && graph_draggable) {
            var _s = graph_s;
            if(mouse_wheel_down() && !key_mod_press_any()) { //zoom out
                for( var i = 1, n = array_length(scale); i < n; i++ ) {
                    if(scale[i - 1] < graph_s_to && graph_s_to <= scale[i]) {
                        graph_s_to = scale[i - 1];
                        break;
                    }
                }
            }
            if(mouse_wheel_up() && !key_mod_press_any()) { // zoom in
                for( var i = 1, n = array_length(scale); i < n; i++ ) {
                    if(scale[i - 1] <= graph_s_to && graph_s_to < scale[i]) {
                        graph_s_to = scale[i];
                        break;
                    }
                }
            }
            
            graph_s = lerp_float(graph_s, graph_s_to, PREFERENCES.graph_zoom_smoooth);
            
            if(_s != graph_s) {
                var mb_x = (mx - graph_x * _s) / _s;
                var ma_x = (mx - graph_x * graph_s) / graph_s;
                var md_x = ma_x - mb_x;
                graph_x += md_x;
                
                var mb_y = (my - graph_y * _s) / _s;
                var ma_y = (my - graph_y * graph_s) / graph_s;
                var md_y = ma_y - mb_y;
                graph_y += md_y;
            }
        }
        
        graph_draggable = true;
        graph_x = round(graph_x);
        graph_y = round(graph_y);
    }
    
    function autoPanTo(_x, _y, _speed = 32) {
        graph_autopan   = true;
        graph_pan_x_to  = _x;
        graph_pan_y_to  = _y;
        graph_pan_speed = _speed;
    }
    
    function setSlideShow(index, skip = false) {
        var _targ = project.slideShowSet(index);
        if(_targ == noone) return;
        
        setContext(_targ);
        
        var _gx = w / 2 / graph_s;
        var _gy = h / 2 / graph_s;
        
        var _tx = _gx;
        var _ty = _gy;
        
        switch(_targ.slide_anchor) {
            case 0 :
                _tx = _gx - _targ.x;
                _ty = _gy - _targ.y;
                break;
                
            case 1 :
                _tx = 64 * graph_s - _targ.x;
                _ty = 64 * graph_s - _targ.y;
                break;
                
        }
        
        if(skip) {
            graph_x = _tx;
            graph_y = _ty;
            
        } else
            autoPanTo(_tx, _ty, _targ.slide_speed);
    }
    
    ////- Context
    
    
    function getCurrentContext() { return array_empty(node_context)? noone : node_context[array_length(node_context) - 1]; }
    
    function getNodeList(cont = getCurrentContext()) { return cont == noone? project.nodes : cont.getNodeList(); }
    
    function setContext(context) {
        if(context.group == getCurrentContext()) return;
        
        node_context = [];
        nodes_list   = project.nodes;
        
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
        nodes_list = project.nodes;
        toCenterNode();
    }
    
    function addContext(node) {
        var _node = node.getNodeBase();
        
        nodes_list = _node.nodes;
        array_push(node_context, _node);
        
        node_dragging     = noone;
        nodes_selecting = [];
        selection_block   = 1;
        
        setContextFrame(false, _node);
        toCenterNode();
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
    
    ////- Draw
    
    function drawGrid() { //
        if(!display_parameter.show_grid) return;
        var gls = project.graphGrid.size;
        while(gls * graph_s < 8) gls *= 5;
        
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
    	
        view_hovering = false;
        if(!display_parameter.show_view_control) return;
        
        var _side = display_parameter.show_view_control == 1? 1 : -1;
        var _hab  = pHOVER && !view_pan_tool && !view_zoom_tool;
        
        var d3_view_wz = ui(16);
        
        var _d3x = display_parameter.show_view_control == 1? 
                            ui(8) + d3_view_wz : 
                        w - ui(8) - d3_view_wz;
                        
        var _d3y = ui(8) + d3_view_wz;
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
        	menuCall("preview_view_controller", [ menuItem("Hide view controllers", function() /*=>*/ { display_parameter.show_view_control = 0; }) ]);
        }
    } 
    
    function drawBasePreview() { //
        var gr_x = graph_x * graph_s;
        var gr_y = graph_y * graph_s;
        var _hov = false;
        
        for(var i = 0; i < array_length(nodes_list); i++) {
            var h = nodes_list[i].drawPreviewBackground(gr_x, gr_y, mx, my, graph_s);
            _hov |= h;
        }
        
        return _hov;
    } 
    
    function drawCacheCheck(_x, _y, _s, _w, _h) {
    	var _upd = false;
    	
    	_upd |= pFOCUS && (mouse_click(mb_any) || keyboard_check_pressed(vk_anykey));
    	_upd |= draw_refresh; draw_refresh = false;
    	
    	_upd |= connection_cache[$ "_x"] != _x; connection_cache[$ "_x"] = _x;
		_upd |= connection_cache[$ "_y"] != _y; connection_cache[$ "_y"] = _y;
		_upd |= connection_cache[$ "_s"] != _s; connection_cache[$ "_s"] = _s;
		_upd |= connection_cache[$ "_w"] != _w; connection_cache[$ "_w"] = _w;
		_upd |= connection_cache[$ "_h"] != _h; connection_cache[$ "_h"] = _h;
		
		_upd |= connection_cache[$ "type"]        != project.graphConnection.type;
		        connection_cache[$ "type"]        =  project.graphConnection.type;
		        
		_upd |= connection_cache[$ "line_width"]  != project.graphConnection.line_width;
		        connection_cache[$ "line_width"]  =  project.graphConnection.line_width;
		        
		_upd |= connection_cache[$ "line_corner"] != project.graphConnection.line_corner;
		        connection_cache[$ "line_corner"] =  project.graphConnection.line_corner;
		        
		_upd |= connection_cache[$ "line_extend"] != project.graphConnection.line_extend;
		        connection_cache[$ "line_extend"] =  project.graphConnection.line_extend;
		        
		_upd |= connection_cache[$ "line_aa"]     != project.graphConnection.line_aa;
		        connection_cache[$ "line_aa"]     =  project.graphConnection.line_aa;
		        

		connection_draw_update |= _upd;
		
		_upd |= connection_cache[$ "frame"]     != CURRENT_FRAME;     connection_cache[$ "frame"]     = CURRENT_FRAME;
		node_surface_update    |= _upd;
    }
    
    function drawNodes() { //
        if(selection_block-- > 0) return;
        display_parameter.highlight = !array_empty(nodes_selecting) && 
        	((PROJECT.graphConnection.line_highlight == 1 && key_mod_press(ALT)) || PROJECT.graphConnection.line_highlight == 2);
        
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
		
        var log = 0;
        var t   = get_timer();
        printIf(log, "============ Draw start ============");
        
        _frame_hovering = frame_hovering;
        frame_hovering  = noone;
        
        var _node_active = nodes_list;
        if(display_parameter.show_control) _node_active = array_filter(nodes_list, function(_n) /*=>*/ {return _n.active});
        else                               _node_active = array_filter(nodes_list, function(_n) /*=>*/ {return _n.active && !_n.is_controller});
        
        var _node_draw = array_filter( _node_active, function(_n) /*=>*/ {
        	_n.preDraw(__gr_x, __gr_y, __gr_s, __gr_x, __gr_y);
        	var _cull = _n.cullCheck(__gr_x, __gr_y, __gr_s, -32, -32, __gr_w + 32, __gr_h + 64);
        	
        	return _n.active && _cull;
    	});
        
        printIf(log, $"Predraw time: {get_timer() - t}"); t = get_timer();
        
        // draw frame
        array_foreach(_node_draw, function(_n) /*=>*/ { if(_n.drawNodeBG(__gr_x, __gr_y, __mx, __my, __gr_s, display_parameter, __self)) frame_hovering = _n; });
        printIf(log, $"Frame draw time: {get_timer() - t}"); t = get_timer();
        
        // hover
        node_hovering = noone;
        if(pHOVER) array_foreach(_node_draw, function(_n) /*=>*/ { 
        	_n.branch_drawing = false;
        	if(_n.pointIn(__gr_x, __gr_y, __mx, __my, __gr_s))
                node_hovering = _n;
        });
        
        if(node_hovering != noone) {
            _HOVERING_ELEMENT = node_hovering;
            
        	if(_focus && DOUBLE_CLICK && node_hovering.onDoubleClick != -1 && node_hovering.onDoubleClick(self)) {
                DOUBLE_CLICK  = false;
                node_hovering = noone;
            }
        }
        
        if(node_hovering) node_hovering.onDrawHover(gr_x, gr_y, mx, my, graph_s);
        
        printIf(log, $"Hover time: {get_timer() - t}"); t = get_timer();
        
        // ++++++++++++ interaction ++++++++++++
        if(mouse_on_graph && pHOVER) {
        	if(node_dragging == noone && value_dragging == noone) {
    			if(value_focus)
        			addKeyOverlay("Select junction(s)", [[ "Shift", "Peek content" ]]);
        		else if(node_hovering)
            		addKeyOverlay("Select node(s)", [[ "Shift", "Toggle selection" ]]);
        	}
            	
            // select
                var _anc = nodes_select_anchor;
                if(mouse_press(mb_left, _focus)) _anc = noone;
                
                if(NODE_DROPPER_TARGET != noone && node_hovering) {
                    node_hovering.draw_droppable = true;
                    if(mouse_press(mb_left, NODE_DROPPER_TARGET_CAN)) {
                        NODE_DROPPER_TARGET.expression += node_hovering.internalName;
                        NODE_DROPPER_TARGET.expressionUpdate(); 
                    }
                } else if(mouse_press(mb_left, _focus)) {
                	
                    if(key_mod_press(SHIFT)) {
                        if(node_hovering) {
                            if(array_exists(nodes_selecting, node_hovering))
                                array_remove(nodes_selecting, node_hovering);
                            else 
                                array_push(nodes_selecting, node_hovering);
                        } else
                            nodes_selecting = [];
                            
                    } else if(value_focus || node_hovering == noone) {
                        nodes_selecting = [];
                        
                        if(DOUBLE_CLICK && !PANEL_INSPECTOR.locked)
                            PANEL_INSPECTOR.inspecting = noone;
                            
                    } else {
                        if(is(node_hovering, Node_Frame)) {
                        	addKeyOverlay("Frames selection", [[ "Ctrl", "Exclude contents" ]]);
			
                            var fx0 = (node_hovering.x + graph_x) * graph_s;
                            var fy0 = (node_hovering.y + graph_y) * graph_s;
                            var fx1 = fx0 + node_hovering.w * graph_s;
                            var fy1 = fy0 + node_hovering.h * graph_s;
                        
                            nodes_selecting = [ node_hovering ];
                            
                            if(!key_mod_press(CTRL)) {
	                            for( var i = 0, n = array_length(nodes_list); i < n; i++ ) { //select content
	                                var _node = nodes_list[i];
	                                if(_node == node_hovering) continue;
	                                if(!display_parameter.show_control && _node.is_controller) continue;
	                                if(!_node.selectable) continue;
	                                
	                                var _x = (_node.x + graph_x) * graph_s;
	                                var _y = (_node.y + graph_y) * graph_s;
	                                var _w = _node.w * graph_s;
	                                var _h = _node.h * graph_s;
	                                
	                                if(_w && _h && rectangle_inside_rectangle(fx0, fy0, fx1, fy1, _x, _y, _x + _w, _y + _h))
	                                    array_push_unique(nodes_selecting, _node);
	                            }
                            }
                            
                        } else if(DOUBLE_CLICK) {
                            PANEL_PREVIEW.setNodePreview(node_hovering);
                            
                            if(PREFERENCES.inspector_focus_on_double_click) {
                                if(PANEL_INSPECTOR.panel && struct_has(PANEL_INSPECTOR.panel, "switchContent"))
                                    PANEL_INSPECTOR.panel.switchContent(PANEL_INSPECTOR);
                            }
                            
                        } else {
                            var hover_selected = false;    
                            for( var i = 0; i < array_length(nodes_selecting); i++ ) {
                                if(nodes_selecting[i] != node_hovering) continue;
                                    
                                hover_selected = true;
                                break;
                            }
                            
                            if(!hover_selected)
                                nodes_selecting = [ node_hovering ];
                                
                            if(array_length(nodes_selecting) > 1)
                                _anc = nodes_select_anchor == node_hovering? noone : node_hovering;
                        }
                        
                        if(WIDGET_CURRENT) WIDGET_CURRENT.deactivate();
                        array_foreach(nodes_selecting, function(node) { bringNodeToFront(node); });
                    }
                }
                
                nodes_select_anchor = _anc;
            
            
            if(mouse_press(mb_right, _focus)) { //
                node_hover = node_hovering;    
                __junction_hovering = noone;
                
                if(value_focus) {
                    // print($"Right click value focus {value_focus}");
                    
                    __junction_hovering = value_focus;
                    
                    var menu = [ menu_junc_color ];
                    
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
                    
                    menuCall("graph_node_selected_menu", menu);
                    
                } else if(node_hover && node_hover.draggable) {
                    // print($"Right click node hover {node_hover}");
                    
                    var menu = [];
                    array_push(menu, menu_node_color, -1, menu_sent_to_preview, menu_send_to_window, menu_sent_to_inspector);
                    if(!DEMO) 
                        array_push(menu, menu_send_export);
                    array_push(menu, -1, menu_toggle_preview, menu_toggle_render, menu_toggle_param, menu_hide_disconnect);
                    
                    if(is_instanceof(node_hover, Node_Collection))
                        array_push(menu, -1, menu_open_group, menu_open_group_tab, menu_group_ungroup);
					
					if(node_hover.group != noone)
                    	array_push(menu, menu_group_tool);
                    
                    if(array_length(nodes_selecting) >= 2) 
                        array_push(menu, -1, menu_nodes_group, menu_nodes_frame);
                        
                    array_push(menu, -1, menu_node_delete_merge, menu_node_delete_cut, menu_node_duplicate, menu_node_copy);
                    if(array_empty(nodes_selecting)) array_push(menu, menu_node_copy_prop, menu_node_paste_prop);
                    
                    array_push(menu, -1, menu_node_transform, menu_node_canvas);
                    
                    if(array_length(nodes_selecting) >= 2) 
                        array_push(menu, -1, menu_nodes_align, menu_nodes_blend, menu_nodes_compose, menu_nodes_array);
                
                    menuCall("graph_node_selected_multiple_menu", menu );
                    
                } else if(node_hover == noone) {
                    // print($"Right click not node hover");
                    
                    var menu = [];
                    
                    __junction_hovering = junction_hovering;
                    if(junction_hovering != noone) 
                        array_push(menu, menu_junc_color, menu_connection_tunnel, -1);
                    
                    array_push(menu, MENU_ITEMS.graph_copy.setActive(array_length(nodes_selecting)));
                    array_push(menu, MENU_ITEMS.graph_paste.setActive(clipboard_get_text() != ""));
                    
                    if(junction_hovering != noone) {
                        array_push(menu, -1);
                        
                        if(is_instanceof(junction_hovering, Node_Feedback_Inline)) {
                            var _jun = junction_hovering.junc_out;
                            array_push(menu, menuItem($"[{_jun.node.display_name}] {_jun.getName()}", function(data) /*=>*/ { __junction_hovering.destroy(); }, THEME.feedback));
                            
                        } else {
                            var _jun = junction_hovering.value_from;
                            array_push(menu, menuItem($"[{_jun.node.display_name}] {_jun.getName()}", function(data) /*=>*/ { __junction_hovering.removeFrom(); }, THEME.cross));
                        }
                    }
                    
                    var ctx     = is_instanceof(frame_hovering, Node_Collection_Inline)? frame_hovering : getCurrentContext();
                    var _diaAdd = callAddDialog(ctx);
                    
                    var _dia = menuCall("graph_node_selected_menu", menu, o_dialog_add_node.dialog_x - ui(8), o_dialog_add_node.dialog_y + ui(4), fa_right );
                    _dia.passthrough = true;
                    setFocus(_diaAdd, "Dialog");
                }
            } 
                
            if(is_instanceof(frame_hovering, Node_Collection_Inline) && DOUBLE_CLICK && array_empty(nodes_selecting)) { //
                nodes_selecting = [ frame_hovering ];
                
                if(frame_hovering.onDoubleClick != -1) frame_hovering.onDoubleClick(self)
                if(frame_hovering.previewable)         PANEL_PREVIEW.setNodePreview(frame_hovering);
            } 
        }
        
        printIf(log, $"Node selection time: {get_timer() - t}"); t = get_timer();
        
        // draw active
        array_foreach(nodes_selecting, function(_n) /*=>*/ { _n.drawActive(__gr_x, __gr_y, __gr_s); });
        if(nodes_select_anchor) nodes_select_anchor.active_draw_anchor = true;
        
        printIf(log, $"Draw active: {get_timer() - t}"); t = get_timer();
        
        // draw connections
        var aa = floor(min(8192 / w, 8192 / h, project.graphConnection.line_aa));
        
        connection_draw_update |= !surface_valid(connection_surface_cc, w * aa, h * aa);
        
        connection_surface    = surface_verify(connection_surface,    w * aa, h * aa);
        connection_surface_cc = surface_verify(connection_surface_cc, w * aa, h * aa);
        connection_surface_aa = surface_verify(connection_surface_aa, w,      h     );
        
        hov = noone;
        
        if(connection_draw_update || pHOVER) {
	        surface_set_target(connection_surface_cc);
	        	if(connection_draw_update) { DRAW_CLEAR }
		    	
		        var hoverable  = pHOVER;
		            hoverable &= !node_dragging || node_drag_add;
						        
		        connection_param.active = hoverable;
		        connection_param.setPos(gr_x, gr_y, graph_s, mx, my);
		        connection_param.setBoundary(-64, -64, w + 64, h + 64);
		        connection_param.setProp(array_length(_node_active), display_parameter.highlight);
		        connection_param.setDraw(aa, bg_color);
		        
		        array_foreach(_node_active, function(n) /*=>*/ {
		        	var _hov = n.drawConnections(connection_param, connection_draw_update);
		            if(is_struct(_hov)) hov = _hov;
		        });
		        
		        connection_draw_update = false;
		    surface_reset_target();
        }
        
        surface_set_target(connection_surface);
	        DRAW_CLEAR
	    	
	    	draw_surface(connection_surface_cc, 0, 0);
	        if(hov) drawJuncConnection(hov.value_from, hov, connection_param, 1 + (node_drag_add && node_dragging));
	        
	        if(value_dragging && connection_draw_mouse != noone && !key_mod_press(SHIFT)) {
	            var _cmx = connection_draw_mouse[0];
	            var _cmy = connection_draw_mouse[1];
	            var _cmt = connection_draw_target;
	            
	            if(array_empty(value_draggings))
	                value_dragging.drawConnectionMouse(connection_param, _cmx, _cmy, _cmt);
	            else {
	                var _stIndex = array_find(value_draggings, value_dragging);
	            
	                for( var i = 0, n = array_length(value_draggings); i < n; i++ ) {
	                    var _dmx = _cmx;
	                    var _dmy = value_draggings[i].connect_type == CONNECT_TYPE.output? _cmy + (i - _stIndex) * 24 * graph_s : _cmy;
	                
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
        
        junction_hovering = node_hovering == noone? hov : noone;
        
        printIf(log, $"Draw connection: {get_timer() - t}"); t = get_timer();
        
        // draw node
        _value_focus = value_focus;
         value_focus = noone;
        
        var t = get_timer();
        
        // node_surface_update |= !surface_valid(node_surface, w, h);
        node_surface_update |= true;
        // node_surface = surface_verify(node_surface, w, h);
        
        // surface_set_target(node_surface);
        	// if(node_surface_update) draw_clear_alpha(bg_color, 0.);
        	
        	if(node_surface_update) array_foreach(_node_draw, function(_n) /*=>*/ { _n.drawNodeBehind(__gr_x, __gr_y, __mx, __my, __gr_s); });
	        array_foreach(value_draggings, function(_v) /*=>*/ { _v.graph_selecting = true; });
	        
	        array_foreach(_node_draw, function(_n) /*=>*/ {
	            try {
	                var val = _n.drawNode(node_surface_update, __gr_x, __gr_y, __mx, __my, __gr_s, display_parameter, __self);
	                if(val) {
	                    value_focus = val;
	                    if(key_mod_press(SHIFT)) TOOLTIP = [ val.getValue(), val.type ];
	                }
	            } catch(e) { log_warning("NODE DRAW", exception_print(e)); }
	        });
	        
	        if(node_surface_update) array_foreach(_node_draw, function(_n) /*=>*/ { _n.drawBadge(__gr_x, __gr_y, __gr_s); });
	        if(node_surface_update) array_foreach(_node_draw, function(_n) /*=>*/ { _n.drawNodeFG(__gr_x, __gr_y, __mx, __my, __gr_s, display_parameter, __self); });
		// surface_reset_target();
	       
		node_surface_update = false;
	       
        if(PANEL_INSPECTOR && PANEL_INSPECTOR.prop_hover != noone)
            value_focus = PANEL_INSPECTOR.prop_hover;
    
        // BLEND_ALPHA_MULP
        // 	draw_surface_safe(node_surface);
        // BLEND_NORMAL
        
        printIf(log, $"Draw node: {get_timer() - t}"); t = get_timer();
        
        // dragging
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
            	
            	if(_shy != undefined) {
            		node_dragging.x -= node_dragging.w / 2;
            		node_dragging.y  = _shy;
            	}
            }
            
            if(node_dragging) nodes_selecting = [ node_dragging ];
            node_dragging   = noone;
            node_drag_add   = false;
        }
        
        for(var i = 0; i < array_length(nodes_list); i++)
            nodes_list[i].groupCheck(gr_x, gr_y, graph_s, mx, my);
        
        if(node_dragging && !key_mod_press(ALT)) {
            addKeyOverlay("Dragging node(s)", [[ "Ctrl", "Disable snapping" ]]);
			connection_draw_update = true;
			node_surface_update    = true;
            
            var _mgx = mouse_graph_x;
            var _mgy = mouse_graph_y;
            var _grd = project.graphGrid.size;
            
            if(array_length(nodes_selecting) == 1) {
            	var _node = nodes_selecting[0];
            	if(_node.custom_grid) _grd = _node.custom_grid;
            }
            
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
                
                for(var i = 0; i < array_length(nodes_selecting); i++) {
                    var _node = nodes_selecting[i];
                    var _nx   = _node.x + dx;
                    var _ny   = _node.y + dy;
                    
                    if(sn) {
		                _nx = value_snap(_nx, _grd);
		                _ny = value_snap(_ny, _grd);
		            }
                    
                    _node.move(_nx, _ny, graph_s);
                }
                   
                node_drag_ox = nx;
                node_drag_oy = ny;
            }
                
            if(mouse_release(mb_left) && (nx != node_drag_sx || ny != node_drag_sy)) {
                var shfx = node_drag_sx - nx;
                var shfy = node_drag_sy - ny;
                
                UNDO_HOLDING = false;    
                for(var i = 0; i < array_length(nodes_selecting); i++) {
                    var _n = nodes_selecting[i];
                    if(_n == noone) continue;
                    recordAction(ACTION_TYPE.var_modify, _n, [ _n.x + shfx, "x", "node x position" ]);
                    recordAction(ACTION_TYPE.var_modify, _n, [ _n.y + shfy, "y", "node y position" ]);
                }
            }
        }
        
        if(!node_drag_add && mouse_release(mb_left))
            node_dragging = noone;
        
        printIf(log, $"Drag node time : {get_timer() - t}"); t = get_timer();
        
        if(mouse_on_graph && _focus) { //
            var _node = getFocusingNode();
            if(_node && _node.draggable && value_focus == noone) {
                if(mouse_press(mb_left) && !key_mod_press(ALT)) {
                    node_dragging = _node;
                    node_drag_mx  = mouse_graph_x;
                    node_drag_my  = mouse_graph_y;
                    node_drag_sx  = _node.x;
                    node_drag_sy  = _node.y;
                    
                    node_drag_ox  = -1;
                    node_drag_oy  = -1;
                }
            }
            
            if(DOUBLE_CLICK && junction_hovering != noone) {
                var _mx = value_snap(mouse_graph_x, project.graphGrid.size);
                var _my = value_snap(mouse_graph_y - 8, project.graphGrid.size);
                        
                var _pin = nodeBuild("Node_Pin", _mx, _my).skipDefault();
                _pin.inputs[0].setFrom(junction_hovering.value_from);
                junction_hovering.setFrom(_pin.outputs[0]);
            }
        } 
        
        // draw selection frame
        if(nodes_select_drag) {
            if(point_distance(nodes_select_mx, nodes_select_my, mx, my) > 16)
                nodes_select_drag = 2;
            
            if(nodes_select_drag == 2) {
                draw_sprite_stretched_points_clamp(THEME.ui_selection, 0, nodes_select_mx, nodes_select_my, mx, my, COLORS._main_accent);
                
                for( var i = 0, n = array_length(nodes_list); i < n; i++ ) {
                    var _node = nodes_list[i];
                    
                    if(!_node.selectable) continue;
                    if(!display_parameter.show_control && _node.is_controller) continue;
                    if(is(_node, Node_Frame) && !nodes_select_frame) continue;
                    
                    var _x = (_node.x + graph_x) * graph_s;
                    var _y = (_node.y + graph_y) * graph_s;
                    var _w = _node.w * graph_s;
                    var _h = _node.h * graph_s;
                    
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
            if(is_instanceof(junction_hovering, NodeValue) && junction_hovering.draw_line_shift_hover) {
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
        
        printIf(log, $"Draw selection frame : {get_timer() - t}"); t = get_timer();
    } 
    
    function connectDraggingValueTo(target) {
        var _connect = [ 0, noone, noone ];
        if(array_length(value_draggings) == 1) {
        	value_dragging  = value_draggings[0];
        	value_draggings = [];
        	
        }
        
        if(is_instanceof(PANEL_INSPECTOR, Panel_Inspector) && PANEL_INSPECTOR.attribute_hovering != noone) {
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
                            _node.inputs[_indx].setFrom(value_draggings[i]);
                            if(++_indx > array_length(_node.inputs)) break;
                        }
                    }
                }
            }
            
        } else {
            if(value_dragging.connect_type == CONNECT_TYPE.input)
                value_dragging.removeFrom();
            value_dragging.node.triggerRender();
            
            if(value_focus != value_dragging) {
            					
                var ctx = is_instanceof(frame_hovering, Node_Collection_Inline)? frame_hovering : getCurrentContext();
                
                if(value_dragging.node.inline_context) {
                	addKeyOverlay("Connecting (inline)", [[ "Alt", "Connect to outside" ]]);
                	
					if(!key_mod_press(ALT))
                    	ctx = value_dragging.node.inline_context;
                }
                
                if(is_instanceof(ctx, Node_Collection_Inline) && !ctx.junctionIsInside(value_dragging))
                	ctx = noone;
                
                with(dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: ctx })) {    
                    node_target_x     = other.mouse_grid_x;
                    node_target_y     = other.mouse_grid_y;
                    node_target_x_raw = other.mouse_grid_x;
                    node_target_y_raw = other.mouse_grid_y;
                    junction_called   = other.value_dragging;
                    
                    alarm[0] = 1;
                }
                
                add_node_draw_junc = value_dragging;
                add_node_draw_x    = mouse_grid_x;
                add_node_draw_y    = mouse_grid_y;
            }
        }
        
        if(_connect[0] == -7 && !is(value_dragging.node, Node_Pin)) {
            if(_connect[1].value_from_loop != noone)
                _connect[1].value_from_loop.destroy();
               
            var menu = [
                menuItem("Feedback", function(data) {
                    var junc_in  = data.junc_in;
                    var junc_out = data.junc_out;
                    
                    var feed = nodeBuild("Node_Feedback_Inline", 0, 0).skipDefault();
                    // feed.connectJunctions(junc_in, junc_out);
                    feed.attributes.junc_in  = [ junc_in .node.node_id, junc_in .index ];
                    feed.attributes.junc_out = [ junc_out.node.node_id, junc_out.index ];
                    feed.scanJunc();
                    
                }, THEME.feedback_24, noone, noone, { junc_in : _connect[1], junc_out : _connect[2] }),
                
                menuItem("Loop", function(data) {
                    var junc_in  = data.junc_in;
                    var junc_out = data.junc_out;
                    
                    var feed = nodeBuild("Node_Iterate_Inline", 0, 0).skipDefault();
                    feed.attributes.junc_in  = [ junc_in .node.node_id, junc_in .index ];
                    feed.attributes.junc_out = [ junc_out.node.node_id, junc_out.index ];
                    feed.scanJunc();
                    
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
            var _n = value_dragging.node;
            var _l = value_dragging.connect_type == CONNECT_TYPE.input? _n.inputs : _n.outputs;
            var _i = value_dragging.connect_type == CONNECT_TYPE.input? _n.inputs_index : _n.outputs_index;
            
            array_push_unique(value_draggings, value_dragging);
            
            for (var i = 0, n = array_length(_i); i < n; i++) {
                var _j = _l[_i[i]];
                if(_j.type == value_dragging.type)
                    array_push_unique(value_draggings, _j);
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
                    if(target != noone) node_hovering.active_draw_index = 1;
                        
                } else {
                    target = node_hovering.getInput(my, value_dragging, 0);
                    if(target != noone) 
                        node_hovering.active_draw_index = 1;
                        
                }
            }
            
            var _mmx = target != noone? target.x : _mx;
            var _mmy = target != noone? target.y : _my;
            
            connection_draw_mouse  = [ _mmx, _mmy ];
            connection_draw_target = target;
            
            value_dragging.drawJunction(true, graph_s, value_dragging.x, value_dragging.y);
            if(target) target.drawJunction(true, graph_s, target.x, target.y);
            
            var _inline_ctx = value_dragging.node.inline_context;
            
            if(_inline_ctx && !_inline_ctx.junctionIsInside(value_dragging))
                _inline_ctx = noone;
            
            if(_inline_ctx && !key_mod_press(SHIFT))
                _inline_ctx.addPoint(mouse_graph_x, mouse_graph_y);
            
            if(mouse_release(mb_left)) 
                connectDraggingValueTo(target);
        } 
        
        // if(keyboard_check_pressed(vk_anykey)) {
        // 	var k = keyboard_lastkey;
        	
        // 	if(k >= ord("A") && k <= ord("z") && !node_drag_search) {
        // 		node_drag_search = true;
        // 	}
        // }
        
        if(mouse_release(mb_left)) value_draggings = [];
    }
    
    function drawJunctionConnect() {
        var _focus = pFOCUS && !view_hovering;
        
        if(value_dragging)
            draggingValue();
		else 
			node_drag_search = false;
        
        if(value_dragging == noone && value_focus && mouse_press(mb_left, _focus) && !key_mod_press(ALT)) {
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
        
        var gr_x = graph_x * graph_s;
        var gr_y = graph_y * graph_s;
        for(var i = 0; i < array_length(nodes_list); i++) {
            var _node = nodes_list[i];
            
            if(!display_parameter.show_control && _node.is_controller) continue;
            _node.drawJunctionNames(gr_x, gr_y, mx, my, graph_s);    
        }
        
    }
    
    function callAddDialog(ctx = getCurrentContext()) { //
        var _dia = dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: ctx });
        
        with(_dia) {    
            node_target_x     = other.mouse_grid_x;
            node_target_y     = other.mouse_grid_y;
            node_target_x_raw = other.mouse_grid_x;
            node_target_y_raw = other.mouse_grid_y;
            junction_called   = other.junction_hovering;
            
            resetPosition();
            alarm[0] = 1;
        }
        
        return _dia;
    } 
    
    function drawContext() { //
        draw_set_text(f_p0, fa_left, fa_center);
        var xx  = ui(16), tt, tw, th;
        var bh  = toolbar_height - ui(12);
        var tbh = h - toolbar_height / 2;
        
        for(var i = -1, n = array_length(node_context); i < n; i++) {
            if(i == -1) {
                tt = __txt("Global");
                
            } else {
                var _cnt = node_context[i];
                tt = _cnt.renamed? _cnt.display_name : _cnt.name;
            }
            
            tw = string_width(tt);
            th = string_height(tt);
            
            if(i < array_length(node_context) - 1) {
                if(buttonInstant(THEME.button_hide_fill, xx - ui(6), tbh - bh / 2, tw + ui(12), bh, [mx, my], pHOVER, pFOCUS) == 2) {
                    node_hover          = noone;
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
                
                draw_sprite_ui_uniform(THEME.arrow, 0, xx + tw + ui(16), tbh, 1, COLORS._main_icon);
            }
            
            draw_set_color(COLORS._main_text);
            draw_set_alpha(i < array_length(node_context) - 1? 0.33 : 1);
            draw_text_add(xx, tbh, tt);
            draw_set_alpha(1);
            
            xx += tw + ui(32);
        }
        
        return xx;
    } 
    
    function drawToolBar() { //
        toolbar_height = ui(40);
        var ty = h - toolbar_height;
        
        if(pHOVER && point_in_rectangle(mx, my, 0, ty, w, h))
            mouse_on_graph = false;
        
        draw_sprite_stretched(THEME.toolbar, 0, 0, ty, w, h);
        var cont_x = drawContext();
        
        var tbx = w - ui(6);
        var tby = ty + toolbar_height / 2;
        var _m  = [ mx, my ];
        
        for( var i = 0, n = array_length(toolbars); i < n; i++ ) {
            var tbs   = toolbars[i];
            
            for (var j = 0, m = array_length(tbs); j < m; j++) {
                var tb    = tbs[j];
                var tbObj = tb[0];
                
                if(is_instanceof(tbObj, widget)) {
                    tbObj.setFocusHover(pFOCUS, pHOVER);
                    
                    var _wdw = ui(32);
                    var _wdx = tbx - _wdw;
                    if(_wdx < cont_x) break;
                    
                    var _param = new widgetParam(_wdx, ty + ui(8), _wdw, toolbar_height - ui(16), tb[1](), {}, _m, x, y);
                    _param.font = f_p3;
                    
                    tbObj.color = COLORS._main_text_sub;
                    tbObj.drawParam(_param);
                    
                    tbx -= _wdw + ui(4);
                    
                } else {
                    var tbInd     = tb[1]();
                    var tbTooltip = tb[2]();
                    
                    var bs = ui(28);
                    if(tbx - (bs + ui(4)) < cont_x) break;
                    
                    var b = buttonInstant(THEME.button_hide_fill, tbx - bs, tby - bs / 2, bs, bs, _m, pHOVER, pFOCUS, tbTooltip, tbObj, tbInd);
                    if(b == 2) tb[3]( { x: x + tbx - bs, y: y + tby - bs / 2 } );
                    tbx -= bs + ui(4);
                }
                
            }
            
            tbx -= ui(2);
            
            draw_set_color(COLORS.panel_toolbar_separator);
            draw_line_round(tbx, tby - toolbar_height / 2 + ui(8), tbx, tby + toolbar_height / 2 - ui(8), 2);
            
            if(tbx < cont_x) break;
            tbx -= ui(6);
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
                draw_set_alpha(0.2 + 0.8 * (!is_instanceof(_node, Node_Frame)));
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
        || keyboard_check_pressed(vk_enter))
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
            
            draw_sprite_ext(THEME.circle, 0, _sx, _sy, ss, ss, 0, cc, aa);
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
        
        var _dir = filename_name_only(filename_dir(PROJECT.path));
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
    
    function drawContent(panel) { ////- Main Draw
        if(!project.active) return;
        
        dragGraph();
        
        toolbars = [ toolbars_general ];
        if(array_length(nodes_selecting) > 1) {
            if(array_exists(nodes_selecting, nodes_select_anchor))
                array_push(toolbars, toolbars_halign, toolbars_valign, toolbars_distrib_space, toolbars_auto_arrange);
            else 
                array_push(toolbars, toolbars_halign, toolbars_valign, toolbars_distrib, toolbars_auto_arrange);
        }
        
        graph_cx = (w / 2) / graph_s - graph_x;
        graph_cy = (h / 2) / graph_s - graph_y;
        
        var context = getCurrentContext();
        if(context != noone) title_raw += " > " + (context.renamed? context.display_name : context.name);
        
        bg_color = context == noone? COLORS.panel_bg_clear : merge_color(COLORS.panel_bg_clear, context.getColor(), 0.05);
        draw_clear(bg_color);
        node_bg_hovering = drawBasePreview();
        drawGrid();
        
        var ovy = ui(8);
        if(display_parameter.show_view_control == 2)    ovy += ui(36);
        // if(is_searching)            ovy += line_get_height(f_p2, 20);
        
        drawNodes();
        
        drawJunctionConnect();
        drawContextFrame();
        mouse_on_graph = true;
        
        #region draw metadata
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
	        
	    	draw_set_text(f_p2, fa_right, fa_top, _zmc);
	        if(!tb_zoom_level.selecting && !tb_zoom_level.sliding)
		    	draw_text(_zmx - _zmw + ui(14), ovy + ui(1), "x");
    	#endregion
    	
        drawToolBar();
        drawMinimap();
        
        drawViewController();
        
        if(pFOCUS && !view_hovering) array_foreach(nodes_selecting, function(node) { node.focusStep(); });
        
             if(UPDATE == RENDER_TYPE.full)    draw_text(w - ui(8), ui(28), __txtx("panel_graph_rendering", "Rendering") + "...");
        else if(UPDATE == RENDER_TYPE.partial) draw_text(w - ui(8), ui(28), __txtx("panel_graph_rendering_partial", "Rendering partial") + "...");
        
        graph_dragging_key = false;
        graph_zooming_key  = false;
        
        drawSearch()
        
        if(LIVE_UPDATE) {
            draw_set_text(f_p0b, fa_right, fa_bottom, COLORS._main_value_negative);
            draw_text(w - 8, h - toolbar_height, "Live Update");
        }
        
        drawSlideShow();
        
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
                if(is_instanceof(_n, Node_Frame)) continue;
                
                if(_n.pointIn(gr_x, gr_y, _mx, _my, graph_s))
                    _node_hover = _n;
            }
            
            var _tip = "";
                
            if(DRAGGING || FILE_IS_DROPPING)
                draw_sprite_stretched_ext(THEME.ui_panel_selection, 0, 8, 8, w - 16, h - 16, COLORS._main_value_positive, 1);
            
            if(FILE_IS_DROPPING)
            	addKeyOverlay("Droping file(s)", [[ "Shift", "Options..." ]]);
                
            if(DRAGGING) { // file dropping
                if(_node_hover && _node_hover.droppable(DRAGGING)) {
                    _node_hover.draw_droppable = true;
                    _tip = "Drop on node";
                    if(mouse_release(mb_left)) _node_hover.onDrop(DRAGGING);
                    
                } else {
                    if(mouse_release(mb_left)) checkDropItem();
                }
            }
            
            if(FILE_IS_DROPPING && _node_hover && _node_hover.dropPath != noone) {
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
        
        ////////////////////////////////// Tooltip Overlay //////////////////////////////////
        
        if(display_parameter.show_tooltip) {
	        var _over = variable_struct_get_names(tooltip_overlay);
	        if(!array_empty(_over)) {
	        	var _tx    = ui(16);
	        	var _ty    = h - toolbar_height - ui(10);
	        	
	        	for( var j = 0, m = array_length(_over); j < m; j++ ) {
	        		var _title = _over[j];
		        	var _keys  = tooltip_overlay[$ _title];
		        	
		        	draw_set_text(f_p2, fa_left, fa_bottom, COLORS._main_text);
					
					var _tw = 0;
					for( var i = 0, n = array_length(_keys); i < n; i++ ) 
						_tw = max(_tw, string_width(_keys[i][0]));
					var _ttx = _tx + _tw + ui(16);
					
					for( var i = array_length(_keys) - 1; i >= 0; i-- ) {
						draw_set_color(COLORS._main_icon);
						draw_set_alpha(0.5);
						draw_text_add(_tx, _ty, _keys[i][0]);
						
						draw_set_color(COLORS._main_text);
						draw_set_alpha(0.5);
						draw_text_add(_ttx, _ty, _keys[i][1]);
						
						_ty -= line_get_height();
					}
					
					_ty -= ui(4);
					draw_set_text(f_p1b, fa_left, fa_bottom, COLORS._main_text);
					draw_set_alpha(0.5);
					draw_text_add(_tx, _ty, _title);
					
					_ty -= line_get_height() + ui(8);
	        	}
				
				draw_set_alpha(1);
	        }
        }
        
        tooltip_overlay = {};
        
        if(LOADING) {
        	draw_set_color(CDEF.main_dkblack);
        	draw_set_alpha(0.3);
        	draw_rectangle(0, 0, w, h, false);
        	draw_set_alpha(1);
        	
        	gpu_set_tex_filter(true);
        	draw_sprite_ext(THEME.loading, 0, w / 2, h / 2, 1, 1, current_time / 2, COLORS._main_icon);
        	gpu_set_tex_filter(false);
        }
    } 
    
    ////- Action
    
    function createNodeHotkey(_node, _param = noone) {
    	// if(value_dragging != noone) return;
    	
        var node;
        
        if(mouse_create_x == undefined || mouse_create_sx != mouse_grid_x || mouse_create_sy != mouse_grid_y) {
            mouse_create_sx = mouse_grid_x;
            mouse_create_sy = mouse_grid_y;
            
            mouse_create_x = mouse_grid_x;
            mouse_create_y = mouse_grid_y;
        } 
        
        var _mx = mouse_create_x;
        var _my = mouse_create_y;
        var _gs = project.graphGrid.size;
        
        if(is_string(_node)) node = nodeBuild(_node, _mx, _my);
        else                 node = _node(_mx, _my, getCurrentContext(), _param);
        
        if(node == noone) return;
        
        mouse_create_y = ceil((mouse_create_y + node.h + _gs / 2) / _gs) * _gs;
        
        if(value_dragging == noone) return;
            
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
    }
    
    function doTransform() {
        for( var i = 0; i < array_length(nodes_selecting); i++ ) {
            var node = nodes_selecting[i];
            if(array_empty(node.outputs)) continue;
            
            var _o = node.outputs[0];
            if(_o.type == VALUE_TYPE.surface || _o.type == VALUE_TYPE.dynaSurface) {
                var tr = nodeBuild("Node_Transform", node.x + node.w + 64, node.y).skipDefault();
                tr.inputs[0].setFrom(_o);
            }
        }
    }

    function doDuplicate() {
        if(array_empty(nodes_selecting)) return;
        
        var _map  = {};
        var _pmap = {};
        var _node = [];
        
        for(var i = 0; i < array_length(nodes_selecting); i++) {
            var _n = nodes_selecting[i];
            
            if(_n.inline_parent_object != "")
                _pmap[$ _n.inline_context.node_id] = _n.inline_parent_object;
                
            SAVE_NODE(_node, _n,,,, getCurrentContext());
        }
        
        _map.nodes = _node;
        
        ds_map_clear(APPEND_MAP);
        APPEND_LIST = [];
        LOADING_VERSION = SAVE_VERSION;
        
        CLONING    = true;
            var _pmap_keys = variable_struct_get_names(_pmap);
            for( var i = 0, n = array_length(_pmap_keys); i < n; i++ ) {
                var _pkey     = _pmap_keys[i];
                var _original = PROJECT.nodeMap[? _pkey];
                var _nodeS    = _pmap[$ _pkey];
                
                CLONING_GROUP = _original;
                var _newGroup = nodeBuild(_nodeS, _original.x, _original.y).skipDefault();
                APPEND_MAP[? _pkey] = _newGroup;
            }
            
            APPEND_LIST = __APPEND_MAP(_map,, APPEND_LIST);
            recordAction(ACTION_TYPE.collection_loaded, array_clone(APPEND_LIST));
        CLONING    = false;
        
        if(array_empty(APPEND_LIST)) return;
        
        for( var i = 0, n = array_length(nodes_selecting); i < n; i++ ) {
            var _orignal = nodes_selecting[i];
            
            var _cloned = ds_map_try_get(APPEND_MAP, _orignal.node_id, "");
            if(_cloned == "") continue;
            
            var _inline_ctx = _orignal.inline_context;
            if(_inline_ctx == noone) continue;
            
            _inline_ctx = ds_map_try_get(APPEND_MAP, _inline_ctx.node_id, _inline_ctx);
            _inline_ctx.addNode(project.nodeMap[? _cloned]);
        }
        
        var x0 = 99999999, y0 = 99999999;
        for(var i = 0; i < array_length(APPEND_LIST); i++) {
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
        if(node == noone) return;
    
        if(node.instanceBase == noone) {
            node.isInstancer = true;
        
            CLONING = true;
            var _type = instanceof(node);
            var _node = nodeBuild(_type, x, y).skipDefault();
            CLONING = false;
            
            _node.setInstance(node);
        }
    
        var _nodeNew  = _node.clone();
    
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
        
        for(var i = 0; i < array_length(nodes_selecting); i++)
            SAVE_NODE(_map.nodes, nodes_selecting[i],,,, getCurrentContext());
        
        clipboard_set_text(json_stringify_minify(_map));
    } 

    function doPaste() {
        var txt  = clipboard_get_text();
        var _map = json_try_parse(txt, noone);
        
        if(txt == "") return;
        
        if(is_struct(_map)) {
            ds_map_clear(APPEND_MAP);
            CLONING   = true;
            var _app  = __APPEND_MAP(_map);
            CLONING   = false;
            
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
	        
            var x0 = 99999999, y0 = 99999999;
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
            return;
        }
        
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

    function doBlend() {
        if(array_empty(nodes_selecting)) {
        	nodeBuild("Node_Blend", mouse_grid_x, mouse_grid_y, getCurrentContext()).skipDefault();
        	return;
        }
    	
    	if(array_empty(nodes_selecting[0].outputs)) return;
    	var _jj = nodes_selecting[0].outputs[0];
    	var _ty = "";
    	
			 if(value_bit(_jj.type) & (1 << 15) || is(nodes_selecting[0], Node_Path)) doCompose();
		else if(value_bit(_jj.type) & (1 << 5))  _ty = "Node_Blend";
		else if(value_bit(_jj.type) & (1 << 3))  doCompose();
		else if(value_bit(_jj.type) & (1 << 1))  _ty = "Node_Math";
		else if(value_bit(_jj.type) & (1 << 29)) doCompose();
        
        if(_ty = "") return;
        
        if(array_length(nodes_selecting) == 1) {
        	
	        var _nodex = nodes_selecting[0].x + 160;
	        var _nodey = nodes_selecting[0].y;
	        var _blend = nodeBuild(_ty, _nodex, _nodey, getCurrentContext()).skipDefault();
            
            switch(_ty) {
            	case "Node_Blend" :    _blend.inputs[0].setFrom(_jj); break;
            	case "Node_Math" :     _blend.inputs[1].setFrom(_jj); break;
            }
        	
        	return;
        }
        
        var _n0 = nodes_selecting[0].y < nodes_selecting[1].y? nodes_selecting[0] : nodes_selecting[1];
        var _n1 = nodes_selecting[0].y < nodes_selecting[1].y? nodes_selecting[1] : nodes_selecting[0];
        
        if(array_empty(_n0.outputs)) return;
        if(array_empty(_n1.outputs)) return;
        
        var _nodex = max(_n0.x, _n1.x) + 160;
        var _nodey = round((_n0.y + _n1.y) / 2 / 32) * 32;
        var _blend = nodeBuild(_ty, _nodex, _nodey, getCurrentContext()).skipDefault();
        
        var _j0 = _n0.outputs[0]; 
        var _j1 = _n1.outputs[0]; 
        
        switch(_ty) {
        	case "Node_Blend" :    
        		_blend.inputs[0].setFrom(_j0);
            	_blend.inputs[1].setFrom(_j1);
        		break;
        		
        	case "Node_Math" :    
	            _blend.inputs[1].setFrom(_j0);
	            _blend.inputs[2].setFrom(_j1); 
        		break;
        		
        }
    	
        nodes_selecting = [];
    } 
    
    function doCompose() { //
        if(array_empty(nodes_selecting)) {
        	nodeBuild("Node_Composite", mouse_grid_x, mouse_grid_y, getCurrentContext()).skipDefault();
        	nodes_selecting = [];
        	return;
        }
    
    	if(array_empty(nodes_selecting[0].outputs)) return;
    	var _jj = nodes_selecting[0].outputs[0];
    	var _ty = "";
    	
    	     if(value_bit(_jj.type) & (1 << 15) || is(nodes_selecting[0], Node_Path)) _ty = "Node_Path_Array";
		else if(value_bit(_jj.type) & (1 <<  5))   _ty = "Node_Composite";
		else if(value_bit(_jj.type) & (1 <<  3))   _ty = "Node_Logic";
		else if(value_bit(_jj.type) & (1 <<  1))   _ty = "Node_Statistic";
		else if(value_bit(_jj.type) & (1 << 29))   _ty = "Node_3D_Scene";
        
        if(_ty = "") return;
        
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
    } 

    function doArray() { //
        if(array_empty(nodes_selecting)) return;
    
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
    } 

    function doGroup() { //
        if(array_empty(nodes_selecting)) return;
        groupNodes(nodes_selecting);
    } 

    function doUngroup() { //
        var _node = getFocusingNode();
        if(_node == noone) return;
        if(!is_instanceof(_node, Node_Collection) || !_node.ungroupable) return;
    
        upgroupNode(_node);
    } 

    function doFrame() { //
        var x0 = 999999, y0 = 999999, x1 = -999999, y1 = -999999;
        
        for( var i = 0; i < array_length(nodes_selecting); i++ )  {
            var _node = nodes_selecting[i];
            x0 = min(x0, _node.x);
            y0 = min(y0, _node.y);
            x1 = max(x1, _node.x + _node.w);
            y1 = max(y1, _node.y + _node.h);
        }
        
        x0 -= 64;
        y0 -= 64;
        x1 += 64;
        y1 += 64;
    
        var f = nodeBuild("Node_Frame", x0, y0, getCurrentContext()).skipDefault();
        f.inputs[0].setValue([x1 - x0, y1 - y0]);
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
    
    function dropFile(path) { //
        if(node_hovering && is_callable(node_hovering.on_drop_file))
            return node_hovering.on_drop_file(path);
        return false;
    } 
    
    function selectDragNode(_node, _add = false) {
    	nodes_selecting = [ _node ];
    	node_dragging   = _node;
    	
    	_node.x = mouse_graph_x
		_node.y = mouse_graph_y
    	
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
                var path = DRAGGING.data.path;
                nodes_selecting = [];
                
                var app = APPEND(DRAGGING.data.path, getCurrentContext());
            
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
                    
                } else if(is_struct(app) && is_instanceof(app, Node)) {
                    app.x = mouse_grid_x;
                    app.y = mouse_grid_y;
                }
                break;
            
            case "Project":
                run_in(1, function(path) { LOAD_PATH(path); }, [ DRAGGING.data.path ]);
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
    
    setProject(project);
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
    
    if(is_multi) {
        dialogCall(o_dialog_add_multiple_images).setPath(path);
        
    } else {
        if(!IS_CMD) PANEL_GRAPH.onStepBegin();
        
        var node = noone;
        for( var i = 0, n = array_length(path); i < n; i++ ) {
            var p = path[i];
            var ext = filename_ext_raw(p);
            
            switch(ext) {
                case "txt"      : node = Node_create_Text_File_Read_path(_x, _y, p);                                break;
                case "csv"      : node = Node_create_CSV_File_Read_path(_x, _y, p);                                 break;
                case "json"     : node = Node_create_Json_File_Read_path(_x, _y, p);                                break;
                    
                case "ase"      :
                case "aseprite" : node = Node_create_ASE_File_Read_path(_x, _y, p);                                 break;
                
                case "png"      :
                case "jpg"      :
                case "jpeg"     : 
                    if(keyboard_check_direct(vk_shift)) dialogCall(o_dialog_add_image).setPath(p);
                    else node = Node_create_Image_path(_x, _y, p);
                    break;
                    
                case "gif"      : node = Node_create_Image_gif_path(_x, _y, p);                                     break;
                case "obj"      : node = Node_create_3D_Obj_path(_x, _y, p);                                        break;
                case "wav"      : node = Node_create_WAV_File_Read_path(_x, _y, p);                                 break;
                case "xml"      : node = Node_create_XML_File_Read_path(_x, _y, p);                                 break;
                case "svg"      : node = Node_create_SVG_path(_x, _y, p);                                           break;
                
                case "pxc"      :
                case "cpxc"     : LOAD_PATH(p);                                                                     break;
                case "pxcc"     : APPEND(p);                                                                        break;
                
                case "hex"      : 
                case "gpl"      : 
                case "pal"      : 
                    node = new Node_Palette(_x, _y, PANEL_GRAPH.getCurrentContext());
                    node.skipDefault()
                    node.inputs[0].setValue(loadPalette(p));
                    break;
                    
            	default : 
            		if(string_starts_with(ext, "pxc")) LOAD_PATH(p);
            }
            
            if(!IS_CMD) PANEL_GRAPH.mouse_grid_y += 160;
        }
        
        // if(node && !IS_CMD) PANEL_GRAPH.toCenterNode();
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
		
		var mx = min(__mouse_tx + ui(16), __win_tw - (tw + ui(16)));
		var my = min(__mouse_ty + ui(16), __win_th - (th + ui(16)));
		
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