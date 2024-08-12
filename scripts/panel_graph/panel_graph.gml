#region // function calls
    function panel_graph_add_node()                { CALL("graph_add_node");            PANEL_GRAPH.callAddDialog();                                                            }
    function panel_graph_focus_content()           { CALL("graph_focus_content");       PANEL_GRAPH.fullView();                                                                 }
    function panel_graph_preview_focus()           { CALL("graph_preview_focus");       PANEL_GRAPH.setCurrentPreview();                                                        }
    
    function panel_graph_import_image()            { CALL("graph_import_image");        PANEL_GRAPH.createNodeHotkey("Node_Image");                                             }
    function panel_graph_import_image_array()      { CALL("graph_import_image_array");  PANEL_GRAPH.createNodeHotkey("Node_Image_Sequence");                                    }
    function panel_graph_add_number()              { CALL("graph_add_number");          PANEL_GRAPH.createNodeHotkey("Node_Number");                                            }
    function panel_graph_add_vec2()                { CALL("graph_add_vec2");            PANEL_GRAPH.createNodeHotkey("Node_Vector2");                                           }
    function panel_graph_add_vec3()                { CALL("graph_add_vec3");            PANEL_GRAPH.createNodeHotkey("Node_Vector3");                                           }
    function panel_graph_add_vec4()                { CALL("graph_add_vec4");            PANEL_GRAPH.createNodeHotkey("Node_Vector4");                                           }
    function panel_graph_add_display()             { CALL("graph_add_disp");            PANEL_GRAPH.createNodeHotkey("Node_Display_Text");                                      }
    
    function panel_graph_add_math_add()            { CALL("graph_add_math_add");        PANEL_GRAPH.createNodeHotkey(Node_create_Math, { query: "add" });                       }
    
    function panel_graph_select_all()              { CALL("graph_select_all");          PANEL_GRAPH.nodes_selecting = PANEL_GRAPH.nodes_list;                                   }
    function panel_graph_toggle_grid()             { CALL("graph_toggle_grid");         PANEL_GRAPH.display_parameter.show_grid = !PANEL_GRAPH.display_parameter.show_grid;     }
                                                                                                                            
    function panel_graph_export()                  { CALL("graph_export");              PANEL_GRAPH.setCurrentExport();                                                         }
    
    function panel_graph_add_transform()           { CALL("graph_add_transform");       PANEL_GRAPH.doTransform();                                                              }
    function panel_graph_blend()                   { CALL("graph_blend");               PANEL_GRAPH.doBlend();                                                                  }
    function panel_graph_compose()                 { CALL("graph_compose");             PANEL_GRAPH.doCompose();                                                                }
    function panel_graph_array()                   { CALL("graph_array");               PANEL_GRAPH.doArray();                                                                  }
    function panel_graph_group()                   { CALL("graph_group");               PANEL_GRAPH.doGroup();                                                                  }
    function panel_graph_ungroup()                 { CALL("graph_ungroup");             PANEL_GRAPH.doUngroup();                                                                }
                                                                                                                            
    function panel_graph_canvas_copy()             { CALL("graph_canvas_copy");         PANEL_GRAPH.setCurrentCanvas();                                                         }
    function panel_graph_canvas_blend()            { CALL("graph_canvas_blend");        PANEL_GRAPH.setCurrentCanvasBlend();                                                    }
                                                                                                                            
    function panel_graph_frame()                   { CALL("graph_frame");               PANEL_GRAPH.doFrame();                                                                  }
    function panel_graph_delete_break()            { CALL("graph_delete_break");        PANEL_GRAPH.doDelete(false);                                                            }
    function panel_graph_delete_merge()            { CALL("graph_delete_merge");        PANEL_GRAPH.doDelete(true);                                                             }
    function panel_graph_duplicate()               { CALL("graph_duplicate");           PANEL_GRAPH.doDuplicate();                                                              }
    function panel_graph_copy()                    { CALL("graph_copy");                PANEL_GRAPH.doCopy();                                                                   }
    function panel_graph_paste()                   { CALL("graph_paste");               PANEL_GRAPH.doPaste();                                                                  }
    
    function panel_graph_auto_align()              { CALL("graph_auto_align");          node_auto_align(PANEL_GRAPH.nodes_selecting);                                           }
    function panel_graph_search()                  { CALL("graph_search");              PANEL_GRAPH.toggleSearch();                                                             }
    function panel_graph_toggle_minimap()          { CALL("graph_toggle_minimap");      PANEL_GRAPH.minimap_show = !PANEL_GRAPH.minimap_show;                                   }
                                                                                                                            
    function panel_graph_pan()                     { CALL("graph_pan");  if(PANEL_GRAPH.node_hovering || PANEL_GRAPH.value_focus) return; PANEL_GRAPH.graph_dragging_key = true;}
    function panel_graph_zoom()                    { CALL("graph_zoom"); if(PANEL_GRAPH.node_hovering || PANEL_GRAPH.value_focus) return; PANEL_GRAPH.graph_zooming_key  = true;}
    
    function panel_graph_send_to_preview()         { CALL("graph_send_to_preview");     PANEL_GRAPH.send_to_preview();                                                          }
    function panel_graph_preview_window()          { CALL("graph_preview_window");      create_preview_window(PANEL_GRAPH.getFocusingNode());                                   }
    function panel_graph_inspector_panel()         { CALL("graph_inspector_panel");     PANEL_GRAPH.inspector_panel();                                                          }
    function panel_graph_send_to_export()          { CALL("graph_send_to_export");      PANEL_GRAPH.send_hover_to_export();                                                     }
    function panel_graph_toggle_preview()          { CALL("graph_toggle_preview");      PANEL_GRAPH.setTriggerPreview();                                                        }
    function panel_graph_toggle_render()           { CALL("graph_toggle_render");       PANEL_GRAPH.setTriggerRender();                                                         }
    function panel_graph_toggle_parameter()        { CALL("graph_toggle_parameter");    PANEL_GRAPH.setTriggerParameter();                                                      }
    function panel_graph_enter_group()             { CALL("graph_enter_group");         PANEL_GRAPH.enter_group();                                                              }
    function panel_graph_hide_disconnected()       { CALL("graph_hide_disconnected");   PANEL_GRAPH.hide_disconnected();                                                        }
    
    function panel_graph_open_group_tab()          { CALL("graph_open_group_tab");      PANEL_GRAPH.open_group_tab();                                                           }
    function panel_graph_set_as_tool()             { CALL("graph_open_set_as_tool");    PANEL_GRAPH.set_as_tool();                                                              }
    
    function panel_graph_doCopyProp()              { CALL("graph_doCopyProp");          PANEL_GRAPH.doCopyProp();                                                               }
    function panel_graph_doPasteProp()             { CALL("graph_doPasteProp");         PANEL_GRAPH.doPasteProp();                                                              }
    function panel_graph_createTunnel()            { CALL("graph_createTunnel");        PANEL_GRAPH.createTunnel();                                                             }
    
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
        
        registerFunction("Graph", "Blend",                 "B", MOD_KEY.ctrl,                    panel_graph_blend               ).setMenu("graph_blend")
        registerFunction("Graph", "Compose",               "B", MOD_KEY.ctrl | MOD_KEY.shift,    panel_graph_compose             ).setMenu("graph_compose")
        registerFunction("Graph", "Array",                 "A", MOD_KEY.ctrl | MOD_KEY.shift,    panel_graph_array               ).setMenu("graph_array")
        registerFunction("Graph", "Frame",                 "F", MOD_KEY.shift,                   panel_graph_frame               ).setMenu("graph_frame")
        
        registerFunction("Graph", "Canvas",                "",  MOD_KEY.none,                    
            function(_dat) { return submenuCall(_dat, [ MENU_ITEMS.graph_canvas_copy, MENU_ITEMS.graph_canvas_blend ]); }        ).setMenu("graph_canvas",, true)
        registerFunction("Graph", "Copy to Canvas",        "C", MOD_KEY.ctrl | MOD_KEY.shift,    panel_graph_canvas_copy         ).setMenu("graph_canvas_copy")
        registerFunction("Graph", "Blend Canvas",          "C", MOD_KEY.ctrl | MOD_KEY.alt,      panel_graph_canvas_blend        ).setMenu("graph_canvas_blend")
                                                    
    
        registerFunction("Graph", "Delete (break)",        vk_delete, MOD_KEY.shift,             panel_graph_delete_break        ).setMenu("graph_delete_break",    THEME.cross)
        registerFunction("Graph", "Delete (merge)",        vk_delete, MOD_KEY.none,              panel_graph_delete_merge        ).setMenu("graph_delete_merge",    THEME.cross)
    
        registerFunction("Graph", "Duplicate",             "D", MOD_KEY.ctrl,                    panel_graph_duplicate           ).setMenu("graph_duplicate",       THEME.duplicate)
        registerFunction("Graph", "Copy",                  "C", MOD_KEY.ctrl,                    panel_graph_copy                ).setMenu("graph_copy",            THEME.copy)
        registerFunction("Graph", "Paste",                 "V", MOD_KEY.ctrl,                    panel_graph_paste               ).setMenu("graph_paste",           THEME.paste)
        
        registerFunction("Graph", "Pan",                   "", MOD_KEY.ctrl,                     panel_graph_pan                 ).setMenu("graph_pan")
        registerFunction("Graph", "Zoom",                  "", MOD_KEY.alt | MOD_KEY.ctrl,       panel_graph_zoom                ).setMenu("graph_zoom")
        
        registerFunction("Graph", "Auto Align",            "L", MOD_KEY.none,                    panel_graph_auto_align          ).setMenu("graph_auto_align")
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
                                                                                    
        if(!DEMO) {
            registerFunction("Graph", "Export Selected",   "E", MOD_KEY.ctrl,                    panel_graph_export              ).setMenu("graph_export_selected")
            registerFunction("Graph", "Export Hover",      "",  MOD_KEY.none,                    panel_graph_send_to_export      ).setMenu("graph_export_hover")
        }
        
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
                function(_data) {  PANEL_GRAPH.setSelectingNodeColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
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
                function(_data) { PANEL_GRAPH.setSelectingJuncColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
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
    cur_layer = 1;
        
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

//// ========== Graph Panel ==========
    
function Panel_Graph(project = PROJECT) : PanelContent() constructor {
    title       = __txt("Graph");
    title_raw   = "";
    context_str = "Graph";
    icon        = THEME.panel_graph_icon;
    
    function setTitle() {
        title_raw = project.path == ""? "New project" : filename_name_only(project.path);
        title = title_raw + (project.modified? "*" : ""); 
    }
    
    static reset = function() {
        onFocusBegin();
        resetContext();
    }
    
    #region // ---- display ----
        display_parameter = {
            show_grid        : true,
            show_dimension  : true,
            show_compute    : true,
        
            avoid_label     : true,
            preview_scale   : 100,
            highlight       : false,
            
            show_control    : false,
        }
        
        connection_param  = new connectionParameter();
        show_view_control = 1;
        
        bg_color = c_black;
        
        slider_width = 0;
    #endregion
    
    #region // ---- position ----
        graph_x  = 0;
        graph_y  = 0;
        graph_cx = 0;
        graph_cy = 0;
        
        graph_autopan  = false;
        graph_pan_x_to = 0;
        graph_pan_y_to = 0;
        
        scale            = [ 0.01, 0.02, 0.05, 0.10, 0.15, 0.20, 0.25, 0.33, 0.50, 0.65, 0.80, 1, 1.2, 1.35, 1.5, 2.0 ];
        graph_s            = 1;
        graph_s_to        = graph_s;
        
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
        mouse_graph_x  = 0;
        mouse_graph_y  = 0;
        mouse_grid_x   = 0;
        mouse_grid_y   = 0;
        
        mouse_create_x  = undefined;
        mouse_create_y  = undefined;
        mouse_create_sx = undefined;
        mouse_create_sy = undefined;
        
        mouse_on_graph   = false;
        node_bg_hovering = false;
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
    
        selection_block        = 0;
        nodes_selecting        = [];
        nodes_selecting_jun = [];
        nodes_select_anchor = noone;
        nodes_select_drag   = 0;
        nodes_select_frame  = 0;
        nodes_select_mx     = 0;
        nodes_select_my     = 0;
    
        nodes_junction_d    = noone;
        nodes_junction_dx   = 0;
        nodes_junction_dy   = 0;
    
        node_hovering        = noone;
        node_hover            = noone;
        
        junction_hovering      = noone;
        add_node_draw_junc      = false;
        add_node_draw_x_fix   = 0;
        add_node_draw_y_fix   = 0;
        add_node_draw_x = 0;
        add_node_draw_y = 0;
        
        connection_aa = 2;
        connection_surface    = surface_create(1, 1);
        connection_surface_aa = surface_create(1, 1);
        
        connection_draw_mouse  = noone;
        connection_draw_target = noone;
        
        value_focus     = noone;
        _value_focus    = noone;
        value_dragging  = noone;
        value_draggings = [];
        value_drag_from = noone;
        
        frame_hovering  = noone;
        _frame_hovering = noone;
    #endregion
    
    #region // ---- minimap ----
        minimap_show = false;
        minimap_w = ui(160);
        minimap_h = ui(160);
        minimap_surface = -1;
    
        minimap_panning  = false;
        minimap_dragging = false;
        minimap_drag_sx = 0;
        minimap_drag_sy = 0;
        minimap_drag_mx = 0;
        minimap_drag_my = 0;
    #endregion
    
    #region // ---- context frame ----
        context_framing = false;
        context_frame_progress = 0;
        context_frame_direct   = 0;
        context_frame_sx = 0; context_frame_ex = 0;
        context_frame_sy = 0; context_frame_ey = 0;
    #endregion
    
    #region // ---- search ----
        is_searching  = false;
        search_string = "";
        search_index  = 0;
        search_result = [];
        
        tb_search                = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_string = string(str); searchNodes(); });
        tb_search.align            = fa_left;
        tb_search.auto_update    = true;
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
            
            if(!is_instanceof(_node, Node))                     continue;
            if(is_instanceof(_node, Node_Collection_Inline))    continue;
            if(is_instanceof(_node, Node_Feedback_Inline))        continue;
            if(!_node.active)                                    continue;
            
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
        tooltip_center   = new tooltipHotkey(__txtx("panel_graph_center_to_nodes", "Center to nodes"), "Graph", "Focus content");
        tooltip_search   = new tooltipHotkey(__txt("Search"), "Graph", "Search");
        tooltip_minimap  = new tooltipHotkey(__txtx("panel_graph_toggle_minimap", "Toggle minimap"), "Graph", "Toggle Minimap");
    
        toolbars_general = [
            [ 
                THEME.icon_preview_export,
                function() /*=>*/ {return 0}, function() /*=>*/ {return __txtx("panel_graph_export_image", "Export graph as image")}, 
                function(param) /*=>*/ { dialogPanelCall(new Panel_Graph_Export_Image(self)); }
            ],
            [ 
                THEME.search_24,
                function() /*=>*/ {return 0}, function() /*=>*/ {return tooltip_search}, 
                function(param) /*=>*/ { toggleSearch(); }
            ],
            [ 
                THEME.icon_center_canvas,
                function() /*=>*/ {return 0}, function() /*=>*/ {return tooltip_center}, 
                function(param) /*=>*/ { toCenterNode(); } 
            ],
            [ 
                THEME.icon_minimap,
                function() /*=>*/ {return minimap_show}, function() /*=>*/ {return tooltip_minimap}, 
                function(param) /*=>*/ { minimap_show = !minimap_show; } 
            ],
            [ 
                THEME.icon_curve_connection,
                function() /*=>*/ {return PREFERENCES.curve_connection_line}, function() /*=>*/ {return __txtx("panel_graph_connection_line", "Connection render settings")}, 
                function(param) /*=>*/ { dialogPanelCall(new Panel_Graph_Connection_Setting(), param.x, param.y, { anchor: ANCHOR.bottom | ANCHOR.left }); } 
            ],
            [ 
                THEME.icon_grid_setting,
                function() /*=>*/ {return 0}, function() /*=>*/ {return __txtx("grid_title", "Grid settings")}, 
                function(param) /*=>*/ { dialogPanelCall(new Panel_Graph_Grid_Setting(), param.x, param.y, { anchor: ANCHOR.bottom | ANCHOR.left }); } 
            ],
            [ 
                THEME.icon_visibility,
                function() /*=>*/ {return 0}, function() /*=>*/ {return __txtx("graph_visibility_title", "Visibility settings")}, 
                function(param) /*=>*/ { dialogPanelCall(new Panel_Graph_View_Setting(self, display_parameter), param.x, param.y, { anchor: ANCHOR.bottom | ANCHOR.left }); } 
            ],
        ]; 
        
        toolbars_halign = [
            [ THEME.object_halign, function() /*=>*/ {return 2}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_halign(nodes_selecting, fa_right);  } ],
            [ THEME.object_halign, function() /*=>*/ {return 1}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_halign(nodes_selecting, fa_center); } ],
            [ THEME.object_halign, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_halign(nodes_selecting, fa_left);   } ],
        ];
        
        toolbars_valign = [
            [ THEME.object_valign, function() /*=>*/ {return 2}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_valign(nodes_selecting, fa_bottom); } ],
            [ THEME.object_valign, function() /*=>*/ {return 1}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_valign(nodes_selecting, fa_middle); } ],
            [ THEME.object_valign, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_valign(nodes_selecting, fa_top);    } ],
        ];
        
        toolbars_distrib = [
            [ THEME.obj_distribute_h, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_hdistribute(nodes_selecting); } ],
            [ THEME.obj_distribute_v, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_vdistribute(nodes_selecting); } ],
        ];
        
        distribution_spacing = 0;
        toolbars_distrib_space = [
            [ THEME.obj_distribute_h, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_hdistribute_dist(nodes_selecting, nodes_select_anchor, distribution_spacing); } ],
            [ THEME.obj_distribute_v, function() /*=>*/ {return 0}, function() /*=>*/ {return ""}, function(param) /*=>*/ { node_vdistribute_dist(nodes_selecting, nodes_select_anchor, distribution_spacing); } ],
            [ new textBox(TEXTBOX_INPUT.number, function(val) { distribution_spacing = value_snap(val, 4); } ).setPadding(4), function() /*=>*/ {return distribution_spacing} ],
        ];
        
        toolbars = [ toolbars_general ];
    #endregion
    
    //// =========== Get Set ===========
    
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
            node.previewable = __temp_show;
            node.refreshNodeDisplay();
        });
    }

    function setTriggerParameter() {
        __temp_show = false;
        array_foreach(nodes_selecting, function(node, index) {
            if(index == 0) __temp_show = !node.show_parameter;
            node.show_parameter = __temp_show;
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
    
    function getFocusingNode() { return array_empty(nodes_selecting)? noone : nodes_selecting[0]; }
    
    //// =========== Menus ===========
    
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
    
    // node color
        function setSelectingNodeColor(color) { 
            __temp_color = color;
            
            if(node_hover) node_hover.attributes.color = __temp_color;
            array_foreach(nodes_selecting, function(node) { node.attributes.color = __temp_color; });
        }
        
        menu_node_color = MENU_ITEMS.graph_group_node_color;
    
    
    // junction color
        __junction_hovering = noone;
        
        function setSelectingJuncColor(color) { 
            if(__junction_hovering == noone) return; 
            __junction_hovering.setColor(color);
            
            for(var i = 0; i < array_length(nodes_selecting); i++) {
                var _node = nodes_selecting[i];
                
                for( var j = 0, m = array_length(_node.inputs); j < m; j++ ) {
                    var _input = _node.inputs[j];
                    if(_input.value_from == noone) continue;
                    _input.setColor(color);
                }
            }
        }
        
        menu_junc_color = MENU_ITEMS.graph_group_junction_color;
    
    
    //// ============ Project ============
    
    static setProject = function(project) {
        self.project = project;
        nodes_list   = project.nodes;
        
        setTitle();
        run_in(2, function() /*=>*/ { 
            setSlideShow(0); 
            struct_override(display_parameter, project.graph_display_parameter);
        });
    } 
    
    //// ============ Views ============
    
    function onFocusBegin() { //
        PANEL_GRAPH = self; 
        PROJECT = project;
        
        nodes_select_drag = 0;
    } 
    
    function focusNode(_node) { //
        if(_node == noone) {
            nodes_selecting = [];
            return;
        }
        
        nodes_selecting = [ _node ];
        fullView();
    } 
    
    function fullView() {
        INLINE
        toCenterNode(array_empty(nodes_selecting)? nodes_list : nodes_selecting);
    }
    
    function dragGraph() {
        if(graph_autopan) {
            graph_x = lerp_float(graph_x, graph_pan_x_to, 32, 1);
            graph_y = lerp_float(graph_y, graph_pan_y_to, 32, 1);
            
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
    
    function autoPanTo(_x, _y) {
        graph_autopan  = true;
        graph_pan_x_to = _x;
        graph_pan_y_to = _y;
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
            autoPanTo(_tx, _ty, skip);
    }
    
    //// =========== Context ==========
    
    
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
    
    //// ============ Step ============
    
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
    
    //// ============ Draw ============
    
    function drawGrid() { //
        if(!display_parameter.show_grid) return;
        var gls = project.graphGrid.size;
        while(gls * graph_s < 8) gls *= 5;
        
        var gr_x  = graph_x * graph_s;
        var gr_y  = graph_y * graph_s;
        var gr_ls = gls * graph_s;
        var xx = -gr_ls, xs = safe_mod(gr_x, gr_ls);
        var yy = -gr_ls, ys = safe_mod(gr_y, gr_ls);
        
        draw_set_color(project.graphGrid.color);
        var aa = 0.5;
        if(graph_s < 0.25) 
            aa = 0.3;
        var oa  = project.graphGrid.opacity;
        var ori = project.graphGrid.show_origin;
        var hig = project.graphGrid.highlight;
        
        while(xx < w + gr_ls) { 
            draw_set_alpha( oa * aa * (1 + (round((xx + xs - gr_x) / gr_ls) % hig == 0) * 2) );
            draw_line(xx + xs, 0, xx + xs, h);
            
            if(ori && xx + xs - gr_x == 0) draw_line_width(xx + xs, 0, xx + xs, h, 3);
            xx += gr_ls;
        }
        
        while(yy < h + gr_ls) {
            draw_set_alpha( oa * aa * (1 + (round((yy + ys - gr_y) / gr_ls) % hig == 0) * 2) );
            draw_line(0, yy + ys, w, yy + ys);
            
            if(ori && yy + ys - gr_y == 0) draw_line_width(0, yy + ys, w, yy + ys, 3);
            yy += gr_ls;
        }
        draw_set_alpha(1);
    } 
    
    function drawViewControl() { //
        if(h < ui(96)) return;
    
        view_hovering = false;
        if(!show_view_control) return;
        
        var _side = show_view_control == 1? 1 : -1;
        var _hab  = pHOVER && !view_pan_tool && !view_zoom_tool;
        
        var d3_view_wz = ui(16);
        
        var _d3x = show_view_control == 1? 
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
        
        draw_circle_ui(_d3x, _d3y, d3_view_wz, _hv? 0 : 0.04, COLORS._main_icon, 0.3);
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
                
                view_zoom_tool  = true;
            }
        }
        
        if(view_zoom_tool)
            _hv = true;
        
        draw_circle_ui(_d3x, _d3y, d3_view_wz, _hv? 0 : 0.04, COLORS._main_icon, 0.3);
        draw_sprite_ui(THEME.view_zoom, 0, _d3x, _d3y, 1, 1, 0, view_zoom_tool? COLORS._main_accent : COLORS._main_icon, 1);
        
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
    
    function drawNodes() { //
        if(selection_block-- > 0) return;
        var _focus = pFOCUS && !view_hovering;
        
        display_parameter.highlight = 
            !array_empty(nodes_selecting) && (
                (PREFERENCES.connection_line_highlight == 1 && key_mod_press(ALT)) || 
                 PREFERENCES.connection_line_highlight == 2
            );
        
        var gr_x = graph_x * graph_s;
        var gr_y = graph_y * graph_s;
        
        var log = false;
        var t   = get_timer();
        printIf(log, "============ Draw start ============");
        
        _frame_hovering = frame_hovering;
        frame_hovering  = noone;
        
        for(var i = 0; i < array_length(nodes_list); i++) {
            var _node = nodes_list[i];
            if(!display_parameter.show_control && _node.is_controller) continue;
            
            _node.cullCheck(gr_x, gr_y, graph_s, -32, -32, w + 32, h + 64);
            _node.preDraw(gr_x, gr_y, graph_s, gr_x, gr_y);
        }
        printIf(log, $"Predraw time: {get_timer() - t}"); t = get_timer();
        
        // draw frame
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                if(!display_parameter.show_control && _node.is_controller) continue;
                
                if(_node.drawNodeBG(gr_x, gr_y, mx, my, graph_s, display_parameter, self))
                    frame_hovering = _node;
            }
        
        printIf(log, $"Frame draw time: {get_timer() - t}"); t = get_timer();
        
        // hover
            node_hovering = noone;
            if(pHOVER)
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                if(!display_parameter.show_control && _node.is_controller) continue;
                
                _node.branch_drawing = false;
                
                if(_node.pointIn(gr_x, gr_y, mx, my, graph_s))
                    node_hovering = _node;
            }
            
            if(node_hovering != noone)
                _HOVERING_ELEMENT = node_hovering;
            
            if(DOUBLE_CLICK) {
                // print($"Double click {node_hovering} || {_focus} || {instanceof(node_hovering)}");
                
                if(node_hovering != noone && _focus && node_hovering.onDoubleClick != -1)
                if(node_hovering.onDoubleClick(self)) {
                    DOUBLE_CLICK  = false;
                    node_hovering = noone;
                }
            }
            
            if(node_hovering) node_hovering.onDrawHover(gr_x, gr_y, mx, my, graph_s);
        
        printIf(log, $"Hover time: {get_timer() - t}"); t = get_timer();
        
        // ++++++++++++ interaction ++++++++++++
            if(mouse_on_graph && pHOVER) {
                
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
                            if(is_instanceof(node_hovering, Node_Frame)) {
                                var fx0 = (node_hovering.x + graph_x) * graph_s;
                                var fy0 = (node_hovering.y + graph_y) * graph_s;
                                var fx1 = fx0 + node_hovering.w * graph_s;
                                var fy1 = fy0 + node_hovering.h * graph_s;
                            
                                nodes_selecting = [ node_hovering ];
                                
                                if(!key_mod_press(CTRL))
                                for(var i = 0; i < array_length(nodes_list); i++) { //select content
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
                    
                    if(value_focus) {
                        // print($"Right click value focus {value_focus}");
                        
                        __junction_hovering = value_focus;
                        
                        var menu = [ menu_junc_color ];
                        
                        if(value_focus.connect_type == JUNCTION_CONNECT.output) {
                            var sep = false;
                            
                            for( var i = 0, n = array_length(value_focus.value_to); i < n; i++ ) {
                                if(!sep) { array_push(menu, -1); sep = true; }
                                
                                var _to = value_focus.value_to[i];
                                var _lb = $"[{_to.node.display_name}] {_to.getName()}";
                                array_push(menu, menuItem(_lb, function(data) /*=>*/ { data.params.juncTo.removeFrom(); }, THEME.cross, noone, noone, { juncTo: _to }));
                            }
                            
                            for( var i = 0, n = array_length(value_focus.value_to_loop); i < n; i++ ) {
                                if(!sep) { array_push(menu, -1); sep = true; }
                                
                                var _to = value_focus.value_to_loop[i];
                                var _lb = $"[{_to.junc_in.node.display_name}] {_to.junc_in.getName()}";
                                array_push(menu, menuItem(_lb, function(data) /*=>*/ { data.params.juncTo.destroy(); }, _to.icon_24, noone, noone, { juncTo: _to }));
                            }
                        } else {
                            var sep = false;
                                
                            if(value_focus.value_from) {
                                if(!sep) { array_push(menu, -1); sep = true; }
                                
                                var _jun = value_focus.value_from;
                                var _lb  = $"[{_jun.node.display_name}] {_jun.getName()}";
                                array_push(menu, menuItem(_lb, function(data) /*=>*/ { __junction_hovering.removeFrom(); }, THEME.cross));
                            }
                                
                            if(value_focus.value_from_loop) {
                                if(!sep) { array_push(menu, -1); sep = true; }
                                
                                var _jun = value_focus.value_from_loop.junc_out;
                                var _lb  = $"[{_jun.node.display_name}] {_jun.getName()}";
                                array_push(menu, menuItem(_lb, function(data) /*=>*/ { __junction_hovering.removeFromLoop(); }, value_focus.value_from_loop.icon_24));
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
            for(var i = 0; i < array_length(nodes_selecting); i++) {
                var _node = nodes_selecting[i];
                if(!_node) continue;
                _node.drawActive(gr_x, gr_y, graph_s);
            }
            
            if(nodes_select_anchor) nodes_select_anchor.active_draw_anchor = true;
        
        printIf(log, $"Draw active: {get_timer() - t}"); t = get_timer();
        
        // draw connections
            var aa = floor(min(8192 / w, 8192 / h, PREFERENCES.connection_line_aa));
            
            connection_surface    = surface_verify(connection_surface, w * aa, h * aa);
            connection_surface_aa = surface_verify(connection_surface_aa, w, h);
            surface_set_target(connection_surface);
            DRAW_CLEAR
        
            var hov       = noone;
            var hoverable = !bool(node_dragging) && pHOVER;
            var param     = connection_param;
            
            param.active    = hoverable;
            param.setPos(gr_x, gr_y, graph_s, mx, my);
            param.setBoundary(-64, -64, w + 64, h + 64);
            param.setProp(array_length(nodes_list), display_parameter.highlight);
            param.setDraw(aa, bg_color);
            
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                if(!display_parameter.show_control && _node.is_controller) continue;
                
                param.cur_layer = i + 1;
                
                var _hov = _node.drawConnections(param);
                if(_hov != noone && is_struct(_hov)) hov = _hov;
            }
        
            if(value_dragging && connection_draw_mouse != noone && !key_mod_press(SHIFT)) {
                var _cmx = connection_draw_mouse[0];
                var _cmy = connection_draw_mouse[1];
                var _cmt = connection_draw_target;
                
                if(array_empty(value_draggings))
                    value_dragging.drawConnectionMouse(param, _cmx, _cmy, _cmt);
                else {
                    var _stIndex = array_find(value_draggings, value_dragging);
                
                    for( var i = 0, n = array_length(value_draggings); i < n; i++ ) {
                        var _dmx = _cmx;
                        var _dmy = value_draggings[i].connect_type == JUNCTION_CONNECT.output? _cmy + (i - _stIndex) * 24 * graph_s : _cmy;
                    
                        value_draggings[i].drawConnectionMouse(param, _dmx, _dmy, _cmt);
                    }
                }
            }
            
            surface_reset_target();
            
            gpu_set_texfilter(true);
            surface_set_shader(connection_surface_aa, sh_downsample);
                shader_set_f("down", aa);
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
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                
                if(!display_parameter.show_control && _node.is_controller) continue;
                nodes_list[i].drawNodeBehind(gr_x, gr_y, mx, my, graph_s);
            }
            
            for( var i = 0, n = array_length(value_draggings); i < n; i++ )
                value_draggings[i].graph_selecting = true;
            
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                
                if(!display_parameter.show_control && _node.is_controller) continue;
                if(is_instanceof(_node, Node_Frame)) continue;
                try {
                    var val = _node.drawNode(gr_x, gr_y, mx, my, graph_s, display_parameter, self);
                    if(val) {
                        value_focus = val;
                        if(key_mod_press(SHIFT)) TOOLTIP = [ val.getValue(), val.type ];
                    }
                } catch(e) {
                    log_warning("NODE DRAW", exception_print(e));
                }
            }
            
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                
                if(!display_parameter.show_control && _node.is_controller) continue;
                if(!is_instanceof(nodes_list[i], Node_Frame)) 
                    nodes_list[i].drawBadge(gr_x, gr_y, graph_s);
            }
                
            for(var i = 0; i < array_length(nodes_list); i++) {
                var _node = nodes_list[i];
                
                if(!display_parameter.show_control && _node.is_controller) continue;
                nodes_list[i].drawNodeFG(gr_x, gr_y, mx, my, graph_s, display_parameter, self);
            }
            
            if(PANEL_INSPECTOR && PANEL_INSPECTOR.prop_hover != noone)
                value_focus = PANEL_INSPECTOR.prop_hover;
        
        printIf(log, $"Draw node: {get_timer() - t}"); t = get_timer();
        
        // dragging
            if(mouse_press(mb_left))
                node_dragging = noone;
            
            for(var i = 0; i < array_length(nodes_list); i++)
                nodes_list[i].groupCheck(gr_x, gr_y, graph_s, mx, my);
            
            if(node_dragging && !key_mod_press(ALT)) {
                var nx = node_drag_sx + (mouse_graph_x - node_drag_mx);
                var ny = node_drag_sy + (mouse_graph_y - node_drag_my);
                    
                if(!key_mod_press(CTRL) && project.graphGrid.snap) {
                    nx = round(nx / project.graphGrid.size) * project.graphGrid.size;
                    ny = round(ny / project.graphGrid.size) * project.graphGrid.size;
                }
                    
                if(node_drag_ox == -1 || node_drag_oy == -1) {
                    node_drag_ox = nx;
                    node_drag_oy = ny;
                } else if(nx != node_drag_ox || ny != node_drag_oy) {
                    var dx = nx - node_drag_ox;
                    var dy = ny - node_drag_oy;
                        
                    for(var i = 0; i < array_length(nodes_selecting); i++) {
                        var _node = nodes_selecting[i];
                        var _nx = _node.x + dx;
                        var _ny = _node.y + dy;
                            
                        if(!key_mod_press(CTRL) && project.graphGrid.snap) {
                            _nx = round(_nx / project.graphGrid.size) * project.graphGrid.size;
                            _ny = round(_ny / project.graphGrid.size) * project.graphGrid.size;
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
            
            if(mouse_release(mb_left))
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
                var _mx = round(mouse_graph_x / project.graphGrid.size) * project.graphGrid.size;
                var _my = round(mouse_graph_y / project.graphGrid.size) * project.graphGrid.size;
                        
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
                    
                    for(var i = 0; i < array_length(nodes_list); i++) {
                        var _node = nodes_list[i];
                        
                        if(!display_parameter.show_control && _node.is_controller) continue;
                        if(!_node.selectable) continue;
                        if(is_instanceof(_node, Node_Frame) && !nodes_select_frame) continue;
                        
                        var _x = (_node.x + graph_x) * graph_s;
                        var _y = (_node.y + graph_y) * graph_s;
                        var _w = _node.w * graph_s;
                        var _h = _node.h * graph_s;
                        
                        var _sel = _w && _h && rectangle_in_rectangle(_x, _y, _x + _w, _y + _h, nodes_select_mx, nodes_select_my, mx, my);
                        
                        if(!array_exists(nodes_selecting, _node) && _sel)
                            array_push(nodes_selecting, _node);    
                        if(array_exists(nodes_selecting, _node) && !_sel)
                            array_remove(nodes_selecting, _node);    
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
                    nodes_select_mx        = mx;
                    nodes_select_my        = my;
                    nodes_junction_d    = junction_hovering;
                    nodes_junction_dx    = junction_hovering.draw_line_shift_x;
                    nodes_junction_dy    = junction_hovering.draw_line_shift_y;
                    
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
        
        if(is_instanceof(PANEL_INSPECTOR, Panel_Inspector) && PANEL_INSPECTOR.attribute_hovering != noone) {
            PANEL_INSPECTOR.attribute_hovering(value_dragging);
            
        } else if(target != noone && target != value_dragging) {
            
            if(target.connect_type == value_dragging.connect_type) {
                
                if(value_dragging.connect_type == JUNCTION_CONNECT.input) {
                    if(target.value_from) {
                        value_dragging.setFrom(target.value_from);
                        target.removeFrom();
                    }
                    
                } else if(value_dragging.connect_type == JUNCTION_CONNECT.output) {
                    var _tos = target.getJunctionTo();
                    
                    for (var i = 0, n = array_length(_tos); i < n; i++)
                        _tos[i].setFrom(value_dragging);
                }
                
            } else {
                var _addInput = target.value_from == noone && target.connect_type == JUNCTION_CONNECT.input && target.node.auto_input;
                
                if(value_dragging.connect_type == JUNCTION_CONNECT.input) {
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
            if(value_dragging.connect_type == JUNCTION_CONNECT.input)
                value_dragging.removeFrom();
            value_dragging.node.triggerRender();
            
            if(value_focus != value_dragging) {
                var ctx = is_instanceof(frame_hovering, Node_Collection_Inline)? frame_hovering : getCurrentContext();
                if(value_dragging.node.inline_context && !key_mod_press(SHIFT))
                    ctx = value_dragging.node.inline_context;
                
                with(dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8, { context: ctx })) {    
                    node_target_x     = other.mouse_grid_x;
                    node_target_y     = other.mouse_grid_y;
                    node_target_x_raw = other.mouse_grid_x;
                    node_target_y_raw = other.mouse_grid_y;
                    node_called       = other.value_dragging;
                    
                    alarm[0] = 1;
                }
            }
        }
        
        if(_connect[0] == -7 && !is_instanceof(value_dragging.node, Node_Pin)) {
            if(_connect[1].value_from_loop != noone)
                _connect[1].value_from_loop.destroy();
                
            var menu = [
                menuItem("Feedback", function(data) {
                    var junc_in  = data.params.junc_in;
                    var junc_out = data.params.junc_out;
                    
                    var feed = nodeBuild("Node_Feedback_Inline", 0, 0).skipDefault();
                    // feed.connectJunctions(junc_in, junc_out);
                    feed.attributes.junc_in  = [ junc_in .node.node_id, junc_in .index ];
                    feed.attributes.junc_out = [ junc_out.node.node_id, junc_out.index ];
                    feed.scanJunc();
                    
                }, THEME.feedback_24,,, { junc_in : _connect[1], junc_out : _connect[2] }),
                
                menuItem("Loop", function(data) {
                    var junc_in  = data.params.junc_in;
                    var junc_out = data.params.junc_out;
                    
                    var feed = nodeBuild("Node_Iterate_Inline", 0, 0).skipDefault();
                    feed.attributes.junc_in  = [ junc_in .node.node_id, junc_in .index ];
                    feed.attributes.junc_out = [ junc_out.node.node_id, junc_out.index ];
                    feed.scanJunc();
                    
                }, THEME.loop_24,,, { junc_in : _connect[1], junc_out : _connect[2] }),
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
        
        if(key_mod_double(SHIFT)) {
            var _n = value_dragging.node;
            var _l = value_dragging.connect_type == JUNCTION_CONNECT.input? _n.inputs : _n.outputs;
            var _i = value_dragging.connect_type == JUNCTION_CONNECT.input? _n.inputs_index : _n.outputs_index;
            
            array_push_unique(value_draggings, value_dragging);
            
            for (var i = 0, n = array_length(_i); i < n; i++) {
                var _j = _l[| _i[i]];
                if(_j.type == value_dragging.type)
                    array_push_unique(value_draggings, _j);
            }
            
        } else if(key_mod_press(SHIFT)) {
            array_push_unique(value_draggings, value_dragging);
            
            if(value_focus) 
                array_push_unique(value_draggings, value_focus);
            
            for (var i = 0, n = array_length(value_draggings); i < n; i++) {
                var _v = value_draggings[i];
                var xx = _v.x - 1;
                var yy = _v.y - 1;
                
                shader_set(sh_node_circle);
                    shader_set_color("color", COLORS._main_accent);
                    shader_set_f("thickness", 0.05);
                    shader_set_f("antialias", 0.05);
                    draw_rectangle(xx - 12 * graph_s, yy - 12 * graph_s, xx + 12 * graph_s, yy + 12 * graph_s, false);
                shader_reset();
            }
            
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
                if(value_dragging.connect_type == JUNCTION_CONNECT.input) {
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
            
            value_dragging.drawJunction(graph_s, value_dragging.x, value_dragging.y);
            if(target) target.drawJunction(graph_s, target.x, target.y);
            
            var _inline_ctx = value_dragging.node.inline_context;
            
            if(_inline_ctx) {
                if(is_instanceof(value_dragging.node, _inline_ctx.input_node_type) && value_dragging.connect_type == JUNCTION_CONNECT.input)
                    _inline_ctx = noone;
                else if(is_instanceof(value_dragging.node, _inline_ctx.output_node_type) && value_dragging.connect_type == JUNCTION_CONNECT.output)
                    _inline_ctx = noone;
                
                if(!_inline_ctx.modifiable)
                    _inline_ctx = noone;
            }
                
            if(_inline_ctx && !key_mod_press(SHIFT))
                _inline_ctx.addPoint(mouse_graph_x, mouse_graph_y);
            
            if(mouse_release(mb_left)) 
                connectDraggingValueTo(target);
        } 
        
        if(mouse_release(mb_left)) value_draggings = [];
    }
    
    function drawJunctionConnect() {
        var _focus = pFOCUS && !view_hovering;
        
        if(value_dragging)
            draggingValue();
        
        if(value_dragging == noone && value_focus && mouse_press(mb_left, _focus) && !key_mod_press(ALT)) {
            value_dragging  = value_focus;
            value_draggings = [];
            value_drag_from = noone;
            
            if(value_dragging.connect_type == JUNCTION_CONNECT.output) {
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
            
            if(value_dragging.connect_type == JUNCTION_CONNECT.input) {
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
            junction_hovering = other.junction_hovering;
            
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
        
        for(var i = -1; i < array_length(node_context); i++) {
            if(i == -1) {
                tt = __txt("Global");
            } else {
                var _cnt = node_context[i];
                tt = _cnt.renamed? _cnt.display_name : _cnt.name;
            }
            
            tw = string_width(tt);
            th = string_height(tt);
            
            if(i < array_length(node_context) - 1) {
                if(buttonInstant(THEME.button_hide_fill, xx - ui(6), tbh - bh / 2, tw + ui(12), bh, [mx, my], pFOCUS, pHOVER) == 2) {
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
            draw_text(xx, tbh, tt);
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
                    
                    var b = buttonInstant(THEME.button_hide, tbx - bs, tby - bs / 2, bs, bs, _m, pFOCUS, pHOVER, tbTooltip, tbObj, tbInd);
                    if(b == 2) tb[3]( { x: x + tbx - bs, y: y + tby - bs / 2 } );
                    tbx -= bs + ui(4);
                }
                
            }
            
            tbx -= ui(2);
            
            draw_set_color(COLORS.panel_toolbar_separator);
            draw_line_width(tbx, tby - toolbar_height / 2 + ui(8), tbx, tby + toolbar_height / 2 - ui(8), 2);
            
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
        draw_clear_alpha(COLORS.panel_bg_clear_inner, 0.75);
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
            
            draw_set_alpha(0.4);
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
            draw_set_alpha(1);
            
            var gx = minimap_w / 2 - (graph_x + cx) * ss;
            var gy = minimap_h / 2 - (graph_y + cy) * ss;
            var gw = w / graph_s * ss;
            var gh = h / graph_s * ss;
            
            draw_set_color(COLORS.panel_graph_minimap_focus);
            draw_rectangle(gx, gy, gx + gw, gy + gh, 1);
            
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
        
        surface_reset_target();
        
        draw_surface_ext_safe(minimap_surface, mx0, my0, 1, 1, 0, c_white, 0.5 + 0.35 * hover);
        draw_set_color(COLORS.panel_graph_minimap_outline);
        draw_rectangle(mx0, my0, mx1 - 1, my1 - 1, true);
        
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
            draw_sprite_ui(THEME.node_resize, 0, mx0 + ui(10), my0 + ui(10), 0.5, 0.5, 180, c_white, 0.75);
            if(mouse_press(mb_left, pFOCUS)) {
                minimap_dragging = true;
                minimap_drag_sx = minimap_w;
                minimap_drag_sy = minimap_h;
                minimap_drag_mx = mx;
                minimap_drag_my = my;
            }
        } else 
            draw_sprite_ui(THEME.node_resize, 0, mx0 + ui(10), my0 + ui(10), 0.5, 0.5, 180, c_white, 0.3);
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
        draw_sprite_stretched_add(THEME.ui_panel, 1, x0, y0, ww, hh, c_white, 0.25);
        draw_sprite_stretched(    THEME.button_hide_fill, 1, x0 + pd, y0 + pd, tw, th);
        
        tb_search.font = f_p2;
        tb_search.setFocusHover(pFOCUS, pHOVER);
        tb_search.draw(x0 + pd, y0 + pd, tw, th, search_string, [ mx, my ]);
        
        var bs = ui(24);
        var bx = x1 - bs - pd;
        var by = y0 + pd;
        if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pFOCUS, pHOVER, "", THEME.cross_16) == 2
        || keyboard_check_pressed(vk_escape)
        || keyboard_check_pressed(vk_enter))
            is_searching = false;
        
        bx -= bs + ui(4);
        if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pFOCUS, pHOVER, "", THEME.arrow_wire_16, 0) == 2) {
            if(!array_empty(search_result)) {
                search_index    = safe_mod(search_index + 1, array_length(search_result));
                nodes_selecting = [ search_result[search_index] ];
                toCenterNode(nodes_selecting);
            }
        }
        
        bx -= bs + ui(4);
        if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, [ mx, my ], pFOCUS, pHOVER, "", THEME.arrow_wire_16, 2) == 2) {
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
        
        draw_sprite_stretched(THEME.ui_panel_bg, 3, _sl_x, _sl_y, slider_width, _sl_h);
        
        if(cur != noone) draw_text_add(round(w / 2), round(_sl_y + ui(8)), cur.slide_title);
        
        var _hv = false;
        
        for(var i = 0; i < amo; i++) {
            var _sx = _ss_x + ui(16) + i * ui(16);
            var _sy = _ss_y;
            
            var cc = i == ind? COLORS._main_accent : COLORS._main_icon;
            var aa = i == ind? 1 : .5;
            var ss = i == ind? 1 : .8;
            
            var slid = struct_try_get(project.slideShow, project.slideShow_keys[i], noone);
            
            if(pHOVER && point_in_circle(mx, my, _sx, _sy, ui(8))) {
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
    }
    
    function drawContent(panel) { // //// Main Draw
        if(!project.active) return;
        
        dragGraph();
        
        toolbars = [ toolbars_general ];
        if(array_length(nodes_selecting) > 1) {
            if(array_exists(nodes_selecting, nodes_select_anchor))
                array_push(toolbars, toolbars_halign, toolbars_valign, toolbars_distrib_space);
            else 
                array_push(toolbars, toolbars_halign, toolbars_valign, toolbars_distrib);
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
        if(show_view_control == 2)    ovy += ui(36);
        // if(is_searching)            ovy += line_get_height(f_p2, 20);
        
        drawNodes();
        
        draw_set_text(f_p2, fa_right, fa_top, COLORS._main_text_sub);
        draw_text_add(w - ui(8), ovy, $"x{graph_s_to}");
        
        drawJunctionConnect();
        drawContextFrame();
        
        mouse_on_graph = true;
        drawToolBar();
        drawMinimap();
        
        drawViewControl();
        
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
        
        ////////////////////////////////// File drop //////////////////////////////////
        
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
                
            if(DRAGGING || FILE_IS_DROPPING)
                draw_sprite_stretched_ext(THEME.ui_panel_selection, 0, 8, 8, w - 16, h - 16, COLORS._main_value_positive, 1);
                
            if(DRAGGING) { // file dropping
                if(_node_hover && _node_hover.droppable(DRAGGING)) {
                    _node_hover.draw_droppable = true;
                    if(mouse_release(mb_left)) _node_hover.onDrop(DRAGGING);
                    
                } else {
                    if(mouse_release(mb_left)) checkDropItem();
                }
            }
            
            if(FILE_IS_DROPPING && _node_hover && _node_hover.dropPath != noone)
                _node_hover.draw_droppable = true;
            
            if(FILE_DROPPED && !array_empty(FILE_DROPPING)) {
                if(_node_hover && _node_hover.dropPath != noone) 
                    _node_hover.dropPath(FILE_DROPPING);
                else
                    run_in(1, load_file_path, [ FILE_DROPPING, _gx, _gy ]);
            }
        }
        
    } 
    
    //// ============ Action ============
    
    function createNodeHotkey(_node, _param = noone) {
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
            
        if(value_dragging.connect_type == JUNCTION_CONNECT.output) {
            if(node.input_display_list != -1) {
                for (var i = 0, n = array_length(node.input_display_list); i < n; i++) {
                    if(!is_real(node.input_display_list[i])) continue;
                    if(node.inputs[node.input_display_list[i]].setFrom(value_dragging)) break;
                }
                    
            } else {
                for (var i = 0, n = array_length(node.inputs); i < n; i++)
                    if(node.inputs[i].setFrom(value_dragging)) break;
            }
            
        } else if(value_dragging.connect_type == JUNCTION_CONNECT.input) {
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
        
        for(var i = 0; i < array_length(nodes_selecting); i++) {
            var _orignal = nodes_selecting[i];
            if(!_orignal.clonable) continue;
            
            var _cloned     = ds_map_try_get(APPEND_MAP, _orignal.node_id, "");
            var _inline_ctx = _orignal.inline_context;
            
            if(_inline_ctx != noone && _cloned != "") {
                _inline_ctx = ds_map_try_get(APPEND_MAP, _inline_ctx.node_id, _inline_ctx);
                _inline_ctx.addNode(PROJECT.nodeMap[? _cloned]);
            }
        }
        
        var x0 = 99999999;
        var y0 = 99999999;
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

    function doCopy() { //
        if(array_empty(nodes_selecting)) return;
        clipboard_set_text("");
    
        var _map   = {};
        _map.nodes = [];
        for(var i = 0; i < array_length(nodes_selecting); i++)
            SAVE_NODE(_map.nodes, nodes_selecting[i],,,, getCurrentContext());
        
        clipboard_set_text(json_stringify_minify(_map));
    } 

    function doPaste() { //
        var txt  = clipboard_get_text();
        var _map = json_try_parse(txt, noone);
        
        if(txt == "") return;
        
        if(is_struct(_map)) {
            ds_map_clear(APPEND_MAP);
            APPENDING = true;
            CLONING      = true;
            var _app  = __APPEND_MAP(_map);
            APPENDING = false;
            CLONING      = false;
            
            if(_app == noone) 
                return;
        
            if(array_empty(_app))
                return;
        
            var x0 = 99999999;
            var y0 = 99999999;
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
        
        var _ext = filename_ext_raw(txt);
        
        if(_ext == "pxc")
            APPEND(txt);
            
        else if(_ext == "pxcc")
            APPEND(txt);
            
        else if(_ext == "png") {
            if(file_exists_empty(txt)) {
                Node_create_Image_path(0, 0, txt);
                return;
            }
    
            var path = TEMPDIR + "url_pasted_" + string(irandom_range(100000, 999999)) + ".png";
            var img = http_get_file(txt, path);
            CLONING = true;
            var node = Node_create_Image(0, 0);
            CLONING = false;
            var args = [node, path];
    
            global.FILE_LOAD_ASYNC[? img] = [ function(args) {
                args[0].inputs[0].setValue(args[1]);
                args[0].doUpdate();
            }, args];
        }
    } 

    function doBlend() { //
        if(array_length(nodes_selecting) != 2) return;
        
        var _n0 = nodes_selecting[0].y < nodes_selecting[1].y? nodes_selecting[0] : nodes_selecting[1];
        var _n1 = nodes_selecting[0].y < nodes_selecting[1].y? nodes_selecting[1] : nodes_selecting[0];
        
        var cx = max(_n0.x, _n1.x) + 160;
        var cy = round((_n0.y + _n1.y) / 2 / 32) * 32;
        
        var _j0 = _n0.outputs[0]; 
        var _j1 = _n1.outputs[0]; 
            
        if(_j0.type == VALUE_TYPE.surface && _j1.type == VALUE_TYPE.surface) {
            var _blend = nodeBuild("Node_Blend", cx, cy, getCurrentContext()).skipDefault().skipDefault();
            _blend.inputs[0].setFrom(_j0);
            _blend.inputs[1].setFrom(_j1);
            
        } else if((_j0.type == VALUE_TYPE.integer || _j0.type == VALUE_TYPE.float) && (_j1.type == VALUE_TYPE.integer || _j1.type == VALUE_TYPE.float)) {
            var _blend = nodeBuild("Node_Math", cx, cy, getCurrentContext()).skipDefault().skipDefault();
            _blend.inputs[1].setFrom(_j0);
            _blend.inputs[2].setFrom(_j1);
            
        }
        
        nodes_selecting = [];
    } 
    
    function doCompose() { //
        if(array_empty(nodes_selecting)) return;
    
        var cx   = nodes_selecting[0].x;
        var cy   = 0;
        var pr   = ds_priority_create();
        var amo  = array_length(nodes_selecting);
        var len  = 0;
        
        for(var i = 0; i < amo; i++) {
            var _node = nodes_selecting[i];
            if(array_length(_node.outputs) == 0) continue;
            
            if(_node.outputs[0].type != VALUE_TYPE.surface) continue;
            
            cx = max(cx, _node.x);
            cy += _node.y;
            
            ds_priority_add(pr, _node, _node.y);
            len++;
        }
        
        cx = cx + 160;
        cy = round(cy / len / 32) * 32;
        
        var _compose = nodeBuild("Node_Composite", cx, cy, getCurrentContext()).skipDefault();
        
        repeat(len) {
            var _node = ds_priority_delete_min(pr);
            _compose.addInput(_node.outputs[0]);
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
                    _jun.visible_manual = -1;
            }
            
            for(var j = 0; j < array_length(_node.outputs); j++) {
                var _jun = _node.outputs[j];
                if(!_jun.isVisible()) continue;
                
                if(array_empty(_jun.getJunctionTo()))
                    _jun.visible_manual = -1;
            }
            
            _node.will_setHeight = true;
        }
    }
    
    function createTunnel() {
        if(__junction_hovering == noone) return;
        if(__junction_hovering.value_from == noone) return;
        
        var _jo = __junction_hovering.value_from;
        var _ji = __junction_hovering;
        
        var _key = $"{__junction_hovering.name} {seed_random(3)}";
        
        var _ti = nodeBuild("Node_Tunnel_In",  _jo.rx + 32, _jo.ry).skipDefault();
        var _to = nodeBuild("Node_Tunnel_Out", _ji.rx - 32, _ji.ry).skipDefault();
        
        _to.inputs[0].setValue(_key);
        _ti.inputs[0].setValue(_key);
        
        _ti.inputs[1].setFrom(_jo);
        _ji.setFrom(_to.outputs[0]);
    }
    
    function createAction() {
        if(array_empty(nodes_selecting)) return;
        
        var pan = new Panel_Action_Create();
            pan.setNodes(nodes_selecting);
            pan.spr = PANEL_PREVIEW.getNodePreviewSurface();
            
        var dia = dialogPanelCall(pan);
    }
    
    //// =========== Serialize ===========
    
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

//// ========== File Drop ==========
    
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
        with(dialogCall(o_dialog_add_multiple_images)) setPath(path);
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
                    if(keyboard_check_direct(vk_shift)) with(dialogCall(o_dialog_add_image)) setPath(p);
                    else                                node = Node_create_Image_path(_x, _y, p);
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
                    node = new Node_Palette(_x, _y, PANEL_GRAPH.getCurrentContext()).skipDefault();
                    node.inputs[0].setValue(loadPalette(p));
                    break;
            }
            
            if(!IS_CMD) PANEL_GRAPH.mouse_grid_y += 160;
        }
        
        // if(node && !IS_CMD) PANEL_GRAPH.toCenterNode();
    }
}