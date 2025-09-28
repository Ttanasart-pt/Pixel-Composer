#region funtion calls
    
    function panel_inspector_copy_prop()                 { CALL("inspector_copy_property");          PANEL_INSPECTOR.propSelectCopy();                 }
    function panel_inspector_paste_prop()                { CALL("inspector_paste_property");         PANEL_INSPECTOR.propSelectPaste();                }
    function panel_inspector_toggle_animation()          { CALL("inspector_toggle_animation");       PANEL_INSPECTOR.anim_toggling = true;             }
    
    function panel_inspector_color_pick()                { CALL("color_picker"); if(!PREFERENCES.alt_picker&& !MOUSE_BLOCK) return; PANEL_INSPECTOR.color_picking = true; }
    
    function panel_inspector_section_expand_all()        { CALL("inspector_section_expand_all");     PANEL_INSPECTOR.section_expand_all();             }
    function panel_inspector_section_collapse_all()      { CALL("inspector_section_collapse_all");   PANEL_INSPECTOR.section_collapse_all();           }
    
    function panel_inspector_reset()                     { CALL("inspector_reset");                  PANEL_INSPECTOR.junction_reset();                 }
    function panel_inspector_animation_toggle()          { CALL("inspector_animation_toggle");       PANEL_INSPECTOR.junction_animation_toggle();      }
    function panel_inspector_axis_toggle()               { CALL("inspector_axis_toggle");            PANEL_INSPECTOR.junction_axis_toggle();           }
    function panel_inspector_expression_toggle()         { CALL("inspector_expression_toggle");      PANEL_INSPECTOR.junction_expression_toggle();     }
    function panel_inspector_extract_global()            { CALL("inspector_extract_global");         PANEL_INSPECTOR.junction_extract_global();        }
    function panel_inspector_extract_single()            { CALL("inspector_extract_single");         PANEL_INSPECTOR.junction_extract_single();        }
    function panel_inspector_junction_bypass_toggle()    { CALL("inspector_junc_bypass");            PANEL_INSPECTOR.junction_bypass_toggle();         }
    function panel_inspector_visible_bypass_toggle()     { CALL("inspector_junc_visible");           PANEL_INSPECTOR.junction_visible_toggle();        }
    
    function __fnInit_Inspector() {
    	var i = "Inspector";
    	
        registerFunction("", "Color Picker",         "",  MOD_KEY.alt,  panel_inspector_color_pick             ).setMenu("color_picker")
        
        registerFunction(i, "Copy Value",            "C", MOD_KEY.ctrl, panel_inspector_copy_prop              ).setMenu("inspector_copy_property",  THEME.copy)
        registerFunction(i, "Paste Value",           "V", MOD_KEY.ctrl, panel_inspector_paste_prop             ).setMenu("inspector_paste_property", THEME.paste)
        registerFunction(i, "Toggle Animation",      "I", MOD_KEY.none, panel_inspector_toggle_animation       ).setMenu("inspector_toggle_animation")
        
        registerFunction(i, "Expand All Sections",   "",  MOD_KEY.none, panel_inspector_section_expand_all     ).setMenu("inspector_expand_all_sections")
        registerFunction(i, "Collapse All Sections", "",  MOD_KEY.none, panel_inspector_section_collapse_all   ).setMenu("inspector_collapse_all_sections")
        
        registerFunction(i, "Reset",                 "",  MOD_KEY.none, panel_inspector_reset                  ).setMenu("inspector_reset")
        registerFunction(i, "Toggle Animation",      "",  MOD_KEY.none, panel_inspector_animation_toggle       ).setMenu("inspector_animate_toggle")
        registerFunction(i, "Separate/Combine Axis", "",  MOD_KEY.none, panel_inspector_axis_toggle            ).setMenu("inspector_axis_toggle")
        registerFunction(i, "Toggle Expression",     "",  MOD_KEY.none, panel_inspector_expression_toggle      ).setMenu("inspector_expression_toggle")
        registerFunction(i, "Extract to Globalvar",  "",  MOD_KEY.none, panel_inspector_extract_global         ).setMenu("inspector_extract_global")
        registerFunction(i, "Extract Value",         "",  MOD_KEY.none, panel_inspector_extract_single         ).setMenu("inspector_extract_value")
        registerFunction(i, "Toggle Bypass",         "",  MOD_KEY.none, panel_inspector_junction_bypass_toggle ).setMenu("inspector_bypass_toggle")
        registerFunction(i, "Toggle Visible",        "",  MOD_KEY.none, panel_inspector_visible_bypass_toggle  ).setMenu("inspector_visible_toggle")
        
        __fnGroupInit_Inspector();
    }
    
    function __fnGroupInit_Inspector() {
        var _clrs = COLORS.labels;
        var _item = array_create(array_length(_clrs));
    
        for( var i = 0, n = array_length(_clrs); i < n; i++ ) {
            _item[i] = [ 
                [ THEME.timeline_color, i > 0, _clrs[i] ], 
                function(_data) { PANEL_INSPECTOR.setSelectingItemColor(_data.color); }, "", { color: i == 0? -1 : _clrs[i] }
            ];
        }
        
        array_push(_item, [ 
            [ THEME.timeline_color, 2 ], 
            function(_data) { colorSelectorCall(PANEL_INSPECTOR.__dialog_junction? PANEL_INSPECTOR.__dialog_junction.color : c_white, PANEL_INSPECTOR.setSelectingItemColor); }
        ]);
        
        MENU_ITEMS.inspector_group_set_color = menuItemGroup(__txt("Color"), _item, ["Inspector", "Set Color"]).setSpacing(ui(24));
        registerFunction("Inspector", "Set Color", "", MOD_KEY.none, function() /*=>*/ { menuCall("", [ MENU_ITEMS.inspector_group_set_color ]); });
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
    }
#endregion

#region Elements
	function Inspector_Custom_Renderer(drawFn, registerFn = noone) : widget() constructor {
	    self.draw = drawFn;
	    node  = noone;
	    panel = noone;
	    name  = "";
	    
	    popupPanel  = noone;
	    popupDialog = noone;
	    
	    h = 64;
	    fixHeight = -1;
	    
	    if(registerFn != noone) register = registerFn;
	    else {
	        register = function(parent = noone) { 
	            if(!interactable) return;
	            self.parent = parent;
	        }
	    }
	    
	    b_toggle = button(function() /*=>*/ { togglePopup(name); }).setIcon(THEME.node_goto, 0, COLORS._main_icon, .75);
	    
	    static setName  = function(n) /*=>*/ { name = n; return self; }
	    static setNode  = function(n) /*=>*/ { node = n; return self; }
	    static toString = function( ) /*=>*/ { return $"Custon renderer: {name}"; }
	    
	    static step = function() {
	        b_toggle.icon_blend = popupPanel == noone? COLORS._main_icon : COLORS._main_accent;
	    }
	    
	    static togglePopup = function(_title) { 
	        if(popupPanel == noone) {
	            popupPanel  = new Panel_Custom_Inspector(_title, self);
	            popupDialog = dialogPanelCall(popupPanel);
	            return;
	        }
	        
	        if(instance_exists(popupDialog))
	            instance_destroy(popupDialog);
	            
	        if(is(popupPanel, PanelContent))
	            popupPanel.close();
	        
	        popupPanel = noone;
	    }
	    
	    static clone    = function() { 
	        var _n = new Inspector_Custom_Renderer(draw, register);
	        var _key = variable_instance_get_names(self);
	        
	        for( var i = 0, n = array_length(_key); i < n; i++ ) 
	            _n[$ _key[i]] = self[$ _key[i]];
	        
	        return _n;
	    }
	}
	
	function Inspector_Sprite(_spr) constructor { spr = _spr; }
	
	function Inspector_Label(_text = "", _font = f_p3) constructor { 
	    text = _text; 
	    font = _font; 
	    open = true;
	}
	
	function __inspc(_h, _line = false, _coll = true, _shf = ui(2)) { return new Inspector_Spacer(_h, _line, _coll, _shf); }
	function Inspector_Spacer(_h, _line = false, _coll = true, _shf = ui(2)) constructor { 
	    h    = _h;  
	    line = _line;
	    coll = _coll;
	    lshf = _shf;
	}
#endregion

function Panel_Inspector() : PanelContent() constructor {
    #region ---- Main ----
        context_str = "Inspector";
        title       = __txt("Inspector");
        icon        = THEME.panel_inspector_icon;
        pause_when_rendering = true;
    
        w     = ui(400);
        h     = ui(640);
        min_w = ui(160);
        
        locked       = false;
        focusable    = true;
        
        inspecting   = noone;
        inspectings  = [];
        inspectGroup = false;
        top_bar_h    = ui(100);
        
        static initSize = function() {
            content_w = w - ui(32);
            content_h = h - top_bar_h - ui(12);
        }
        initSize();
        
        view_mode_tooltip = new tooltipSelector("View", [ "Compact", "Spacious" ])
    #endregion
    
    #region ---- Properties ----
        prop_hover          = noone;
        prop_selecting      = noone;
        
        prop_highlight      = noone;
        prop_highlight_time = 0;
    
        prop_dragging       = noone;
        prop_sel_drag_x     = 0;
        prop_sel_drag_y     = 0;
    
        color_picking       = false;
        picker_index        = 0;
        picker_change       = false;
        
        attribute_hovering  = noone;
    #endregion
    
    drawWidgetInit();
    
    #region ---- Header Tabs ----
        tb_node_name = new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { if(inspecting) inspecting.setDisplayName(txt); })
                             .setFont(f_h5)
                             .setHide(1)
                             .setAlign(fa_center);
                             
        tb_node_name.format = TEXT_AREA_FORMAT.node_title;
        
        tb_prop_filter = new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { filter_text = txt; })
                             .setFont(f_p0)
                             .setHide(1)
                             .setAlign(fa_center)
                             .setColor(COLORS._main_text_sub)
                             .setEmpty(false)
                             .setAutoUpdate()
        filter_text = "";
    	
        prop_page   = 0;
        prop_page_b = new buttonGroup(__txts([ "Properties", "Settings", THEME.message_16 ]), function(val) /*=>*/ { prop_page = val; })
   							.setButton([ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ]).iconPad(ui(8))
   							.setFont(f_p2, COLORS._main_text_sub)
        
        proj_prop_page   = 0;
        proj_prop_page_b = new buttonGroup([ "PXC", "GM" ], function(val) /*=>*/ { proj_prop_page = val; })
        					.setButton([ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ])
        					.setFont(f_p2, COLORS._main_text_sub)
    #endregion
    
    #region ---- Metadata ----
        current_meta = -1; 
        meta_tb[0] = textArea_Text( function(s) /*=>*/ { current_meta.description = s; PROJECT.modified = true; } ).setVAlign(ui(4));
        meta_tb[1] = textArea_Text( function(s) /*=>*/ { current_meta.author      = s; PROJECT.modified = true; } ).setVAlign(ui(4));
        meta_tb[2] = textArea_Text( function(s) /*=>*/ { current_meta.contact     = s; PROJECT.modified = true; } ).setVAlign(ui(4));
        meta_tb[3] = textArea_Text( function(s) /*=>*/ { current_meta.alias       = s; PROJECT.modified = true; } ).setVAlign(ui(4));
        meta_tb[4] = new textArrayBox(noone, META_TAGS).setAddable(true);
        
        if(STEAM_ENABLED) meta_tb[1].setSideButton(button(function() /*=>*/ { current_meta.author = STEAM_USERNAME; })
        								.setIcon(THEME.steam, 0, COLORS._main_icon).iconPad(ui(12))
        								.setTooltip("Use Steam username"));
        
        meta_display = [ 
            [ __txt("Project Settings"),    false, "settings"   ], 
            [ __txt("Metadata"),            true , "metadata"   ], 
            [ __txt("Global Layer"),        true,  "layers"     ], 
            [ __txt("Global Variables"),    false, "globalvar"  ], 
            [ __txt("Group Properties"),    false, "group prop" ], 
        ];
        
        meta_steam_avatar = new checkBox(function() /*=>*/ { STEAM_UGC_ITEM_AVATAR = !STEAM_UGC_ITEM_AVATAR; });
        
        global_button_edit = button(function() /*=>*/ { meta_display[3][1] = false; global_drawer.editing = !global_drawer.editing; })
			.setIcon(THEME.gear_16, 0, COLORS._main_icon_light);
		
        global_button_new  = button(function() /*=>*/ { meta_display[3][1] = false; PROJECT.globalNode.createValue();               })
			.setIcon(THEME.add_16,  0, COLORS._main_value_positive);
        
        global_buttons         = [ global_button_edit ];
        global_buttons_editing = [ global_button_edit, global_button_new ];
        global_drawer          = new GlobalVarDrawer();
        
        GM_Explore_draw_init();
        
        variables_buttons = [ button(function() /*=>*/ {return dialogPanelCall(new Panel_Project_Var())})
        	.setIcon(THEME.gear_16, 0, COLORS._main_icon_light)
        	.setTooltip(__txt("Project Variables")) ];
        
        metadata_buttons = [ button(function() /*=>*/ { json_save_struct(DIRECTORY + "meta.json", PROJECT.meta.serialize()); })
        	.setIcon(THEME.save,  0, COLORS._main_icon_light, .75)
        	.setTooltip(__txtx("panel_inspector_set_default", "Set as default")) ];
        
        global_layer_drawer = new Panel_Global_Layer_Drawer();
        globallayer_buttons = [ button(function() /*=>*/ {return dialogPanelCall(new Panel_Global_Layer())} )
        	.setIcon(THEME.text_popup, 1, COLORS._main_icon_light, .75)
        	.setTooltip(__txt("Pop-up")) ];
    #endregion
    
    #region ---- Workshop ----
        workshop_uploading = 0;
    #endregion
    
    #region ---- History ----
    	inspect_history_undo = [];
    	inspect_history_redo = [];
    	
    #endregion
    
    #region ++++ Menus ++++
        static nodeExpandAll = function(node) {
            if(node.input_display_list == -1) return;
            
            var  dlist  = node.input_display_list;
            var _colMap = node.inspector_collapse;
            
            for( var i = 0, n = array_length(dlist); i < n; i++ ) {
                if(!is_array(dlist[i])) continue;
                
                dlist[i][@ 1] = false;
                _colMap[$ dlist[i][@ 0]] = false;
            }
        }
        
        static nodeCollapseAll = function(node) {
            if(node.input_display_list == -1) return;
            
            var  dlist  = node.input_display_list;
            var _colMap = node.inspector_collapse;
            
            for( var i = 0, n = array_length(dlist); i < n; i++ ) {
                if(!is_array(dlist[i])) continue;
                
                dlist[i][@ 1] = true;
                _colMap[$ dlist[i][@ 0]] = true;
            }
        }
        
        function section_expand_all() {
            if(inspecting != noone) nodeExpandAll(inspecting);
            for( var i = 0, n = array_length(inspectings); i < n; i++ ) 
                nodeExpandAll(inspectings[i]);
        }
        
        function section_collapse_all() {
            if(inspecting != noone) nodeCollapseAll(inspecting);
            for( var i = 0, n = array_length(inspectings); i < n; i++ ) 
                nodeCollapseAll(inspectings[i]);
        }
        
        function junction_reset()              { if(__dialog_junction == noone) return; __dialog_junction.resetValue();                                        }
        function junction_animation_toggle()   { if(__dialog_junction == noone) return; __dialog_junction.setAnim(!__dialog_junction.is_anim, true);           }
        function junction_axis_toggle()        { if(__dialog_junction == noone) return; __dialog_junction.sep_axis = !__dialog_junction.sep_axis;              }
        function junction_expression_toggle()  { if(__dialog_junction == noone) return; __dialog_junction.expUse   = !__dialog_junction.expUse;                }
        function junction_extract_global()     { if(__dialog_junction == noone) return; __dialog_junction.extractGlobal();                                     }
        function junction_extract_single()     { if(__dialog_junction == noone) return; __dialog_junction.extractNode();                                       }
        function junction_visible_toggle()     { if(__dialog_junction == noone) return; __dialog_junction.setVisibleManual(!__dialog_junction.visible_manual); }
        function junction_bypass_toggle()      { if(__dialog_junction == noone || __dialog_junction.bypass_junc == noone) return; 
            var b = __dialog_junction.bypass_junc; b.visible = !b.visible; __dialog_junction.node.refreshNodeDisplay(); }
        
        __dialog_junction = noone;
        function setSelectingItemColor(color) { 
            if(__dialog_junction == noone) return; 
            
            __dialog_junction.setColor(color);
            
            var _val_to = __dialog_junction.getJunctionTo();
            for( var i = 0, n = array_length(_val_to); i < n; i++ ) 
                _val_to[i].setColor(color);
        }
        
        group_menu = [
            MENU_ITEMS.inspector_expand_all_sections,
            MENU_ITEMS.inspector_collapse_all_sections,
        ]
        
        MENUITEM_CONDITIONS[$ "inspector_value_separable"] = function() /*=>*/ {return prop_selecting && prop_selecting.sepable};
        
        global.menuItems_inspector_value_input = [
        	"inspector_group_set_color", 
        	-1, 
        	"inspector_animate_toggle",
        	{ cond  : "inspector_value_separable", items : [ "inspector_axis_toggle" ] },
        	"inspector_visible_toggle",
        	"inspector_bypass_toggle",
        	"inspector_expression_toggle", 
        	-1,
        	"inspector_reset", 
        	"inspector_copy_property", 
        	"inspector_paste_property", 
        	-1,
        	
    	];
        global.menuItems_inspector_value_output = [
        	"inspector_group_set_color", 
        	-1, 
        	"inspector_copy_property", 
    	];
    #endregion
    
    function setInspecting(_inspecting, _lock = false, _focus = true, _record = true) {
        if(locked) return;
        if(inspecting == _inspecting) return;
        
        if(_record) {
	        array_push(inspect_history_undo, inspecting);
	        inspect_history_redo = [];
        }
        
        inspecting = _inspecting;
        locked     = locked || _lock;
        focusable  = _focus;
        
        if(inspecting != noone) {
        	inspecting.onInspect();
        	contentPane.scroll_y_to = inspecting.inspector_scroll;
        	
        } else 
        	contentPane.scroll_y_to = 0;
        
        contentPane.scroll_y     = contentPane.scroll_y_to;
        contentPane.scroll_y_raw = contentPane.scroll_y_to;
        contentPane.scroll_wait  = 2;
            
        picker_index = 0;
    }
    
    function getInspecting() { return inspecting != noone && inspecting.active? inspecting : noone; }
    
    function onFocusBegin() { if(!focusable) return; PANEL_INSPECTOR = self; }
    
    function onResize() {
        initSize();
        contentPane.resize(content_w, content_h);
    }
    
    ////- Property actions
    
    static highlightProp = function(prop) {
        prop_highlight      = prop;
        prop_highlight_time = 60;
    }
    
    function propSelectCopy()  { if(prop_selecting) clipboard_set_text(prop_selecting.getString()); }
    function propSelectPaste() { if(prop_selecting) prop_selecting.setString(clipboard_get_text()); }
    
    function propRightClick(jun) {
          prop_selecting  = jun;
        __dialog_junction = jun;
        
        if(jun.connect_type == CONNECT_TYPE.output) return menuCall("inspector_value_output", menuItems_gen("inspector_value_output"));
        
        var _menuItem = menuItems_gen("inspector_value_input");
        
        if(jun.globalExtractable()) {
    		array_push(_menuItem, menuItemShelf(__txtx("panel_inspector_use_global", "Use Globalvar"), function(_dat) /*=>*/ { 
    			var arr = [];
                for( var i = 0, n = array_length(PROJECT.globalNode.inputs); i < n; i++ ) {
            		var _glInp = PROJECT.globalNode.inputs[i];
            		if(!typeCompatible(_glInp.type, __dialog_junction.type)) continue;
            		array_push(arr, menuItem(_glInp.name, function(d) /*=>*/ { __dialog_junction.setExpression(d.name); }, noone, noone, noone, { name : _glInp.name }));
            	}
                return submenuCall(_dat, arr);
            }));
        	
        	array_push(_menuItem, MENU_ITEMS.inspector_extract_global);
        }
        
        if(jun.extract_node != "") {
            if(is_array(jun.extract_node)) {
                array_push(_menuItem, menuItemShelf(__txtx("panel_inspector_extract_multiple", "Extract to..."), function(_dat) /*=>*/ { 
                    var arr = [];
                    for(var i = 0; i < array_length(__dialog_junction.extract_node); i++)  {
                        var _rec = __dialog_junction.extract_node[i];
                        array_push(arr, menuItem(ALL_NODES[$ _rec].name, 
                        	function(d) /*=>*/ { __dialog_junction.extractNode(d.name); }, noone, noone, noone, { name : _rec }));
                    }
                        
                    return submenuCall(_dat, arr);
                }));
                
            } else array_push(_menuItem, MENU_ITEMS.inspector_extract_value);
        }
        
        return menuCall("inspector_value_input", _menuItem);
    }
    
    ////- DRAW
    
    contentPane = new scrollPane(content_w, content_h, function(_y, _m) { 
        draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
        
        if(inspecting == noone) 
        	return drawContentMeta(_y, _m);
        return drawContentNode(_y, _m);
    });
    
    static drawNodeProperties = function(_y, _m, _inspecting = inspecting) {
        var con_w  = contentPane.surface_w - ui(4); 
        var _hover = pHOVER && contentPane.hover;
        var _focus = pFOCUS || PANEL_GRAPH.pFOCUS/* || PANEL_PREVIEW.pFOCUS*/;
        
        _inspecting.inspecting       = true;
        _inspecting.inspector_scroll = contentPane.scroll_y_to;
        
        //tb_prop_filter.register(contentPane);
        //tb_prop_filter.setFocusHover(pHOVER, pFOCUS);
        //tb_prop_filter.draw(ui(32), _y + ui(4), con_w - ui(64), ui(28), filter_text, _m);
        //draw_sprite_ui(THEME.search, 0, ui(32 + 16), _y + ui(4 + 14), 1, 1, 0, COLORS._main_icon, 1);
        
        var hh = 0;
        var xc = con_w / 2;
        
        if(prop_page == 1) { // attribute/settings editor
            hh += ui(8);
            var hg  = ui(32);
            var yy  = _y + hh;
            var wx1 = con_w - ui(8);
            var ww  = max(ui(180), con_w / 3);
            var wx0 = wx1 - ww;
            var font  = viewMode == INSP_VIEW_MODE.spacious? f_p1 : f_p2;
            
            for( var i = 0, n = array_length(_inspecting.attributeEditors); i < n; i++ ) {
                var edt = _inspecting.attributeEditors[i];
                
                if(is_string(edt)) { // label
                	var txt = __txt(edt);
                    var lby = yy + ui(12);
                    draw_set_alpha(0.5);
                    draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
                    draw_text_add(xc, lby, txt);
                    
                    var lbw = string_width(txt) / 2;
                    draw_set_color(COLORS._main_text_sub);
                    draw_line_round(xc + lbw + ui(16), lby,   wx1, lby, 2);
                    draw_line_round(xc - lbw - ui(16), lby, ui(8), lby, 2);
                    draw_set_alpha(1.0);
                    
                    yy += ui(32);
                    hh += ui(32);
                    continue;
                }
                
                var _att_name = __txt(edt[0]);
                var _att_val  = edt[1]();
                var _att_wid  = edt[2];
                var _att_h    = viewMode == INSP_VIEW_MODE.spacious? hg : line_get_height(font, 8);
                
                _att_wid.font = font;
                _att_wid.setFocusHover(pFOCUS, pHOVER);
                
                if(is(_att_wid, buttonClass)) {
                    _att_wid.text = _att_name;
                    _att_wid.draw(ui(8), yy, con_w - ui(16), _att_h, _m); 
                    
                    if(_att_wid.inBBOX(_m)) contentPane.hover_content = true;
                    yy += _att_h + ui(8);
                    hh += _att_h + ui(8);
                    continue;
                } 
                
                draw_set_text(font, fa_left, fa_center, COLORS._main_text);
                draw_text_add(ui(8), yy + _att_h / 2, _att_name);
                
                var _param = new widgetParam(wx0, yy, ww, _att_h, _att_val, {}, _m, x + contentPane.x, y + contentPane.y);
                    _param.s    = _att_h;
                    _param.font = font;
                    
                if(is(_att_wid, checkBox)) _param.halign = fa_center;
                
                var _wh = _att_wid.drawParam(_param);
                
                if(_att_wid.inBBOX(_m)) contentPane.hover_content = true;
                
                var _hg = max(_att_h, _wh);
                yy += _hg + ui(8);
                hh += _hg + ui(8);
            }
            return hh;
            
        } 
        
        if(prop_page == 2) { 
            var _logs = _inspecting.messages;
            _inspecting.messages_bub = false;
            var _tmw  = ui(64);
            var yy = _y;
            var hh = ui(64);
            
            var con_w = contentPane.surface_w;
            var con_h = contentPane.surface_h - yy;
            
            draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, yy, con_w, con_h, merge_color(CDEF.main_ltgrey, CDEF.main_white, 0.5));
            yy += ui(8);
            
            for (var i = array_length(_logs) - 1; i >= 0; i--) {
                var _log = _logs[i];
                
                var _time = _log[0];
                var _text = _log[1];
                
                draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
                var _hg = string_height_ext(_text, -1, con_w - _tmw - ui(10 + 8)) + ui(4);
                if(i % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 4, ui(4), yy, con_w - ui(8), _hg, CDEF.main_dkblack, 0.25);
                
                draw_text_add(ui(10), yy + ui(2), _time);
                
                draw_set_color(COLORS._main_text);
                draw_text_ext_add(_tmw + ui(10), yy + ui(2), _text, -1, con_w - _tmw - ui(10 + 8));
                
                yy += _hg;
                hh += _hg;
            }
            
            return hh;
        }
        
        prop_hover  = noone;
        var jun     = noone;
        var amoIn   = is_array(_inspecting.input_display_list)?  array_length(_inspecting.input_display_list)  : array_length(_inspecting.inputs);
        var amoOut  = is_array(_inspecting.output_display_list)? array_length(_inspecting.output_display_list) : array_length(_inspecting.outputs);
        var amoMeta = _inspecting.attributes.outp_meta? array_length(_inspecting.junc_meta) : 0;
        var amo     = inspectGroup == 0? amoIn + 1 + amoOut + amoMeta : amoIn;
        
        var color_picker_index = 0;
        var pickers = [];
        var _colsp  = false;
        var _colMap = _inspecting.inspector_collapse;
        var _cAll   = 0;
        
        var padd    = ui(6);
        
        for(var i = 0; i < amo; i++) {
            var yy = hh + _y;
            
            if(i < amoIn) { // inputs
                var _dsl = _inspecting.input_display_list;
                var _dsp = array_safe_get_fast(_dsl, i);
                
                     if(!is_array(_dsl))  jun = array_safe_get_fast(_inspecting.inputs, i);
                else if(is_real(_dsp))    jun = array_safe_get_fast(_inspecting.inputs, _dsp);
                else                      jun = _dsp;
                
            } else if(i == amoIn) { // output label
                hh += ui(8 + 32 + 8);
                
                draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy + ui(8), con_w, ui(32), COLORS.panel_inspector_output_label, 0.8);
                draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
                draw_text_add(xc, yy + ui(8 + 16), __txt("Outputs"));
                continue;
            
            } else if(i < amoIn + 1 + amoOut) { // outputs
                var _oi = i - amoIn - 1;
                var _dsl = _inspecting.output_display_list;
                var _dsp = array_safe_get_fast(_dsl, _oi);
                
                     if(!is_array(_dsl)) jun = array_safe_get_fast(_inspecting.outputs, _oi);
                else if(is_real(_dsp))   jun = array_safe_get_fast(_inspecting.outputs, _dsp);
                else                     jun = _dsp;
                
            } else { // metadata
                jun = _inspecting.junc_meta[i - (amoIn + 1 + amoOut)];
            }
            
            if(is(jun, Inspector_Spacer)) {                    // SPACER
                var _hh = ui(jun.h);
                var _yy = yy + _hh / 2 - jun.lshf;
                
                if(jun.line) {
                    draw_set_color(COLORS.panel_inspector_key_separator);
                    draw_line(ui(8), _yy, con_w - ui(8), _yy);
                }
                
                hh += _hh;
                continue;
                
            } else if(is(jun, Inspector_Sprite)) {            // SPRITE
                var _spr = jun.spr;
                var _sh  = sprite_get_height(_spr);
                
                draw_sprite(_spr, 0, xc, yy);
                
                hh += _sh + padd;
                continue;
                
            } else if(is(jun, Inspector_Label)) {            // TEXT
                var _txt = jun.text;
                if(_txt == "") continue;
                
                draw_set_text(jun.font, fa_left, fa_top, COLORS._main_text_sub);
                var _sh = string_height_ext(_txt, -1, con_w - ui(16)) + ui(16);
                draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, yy, con_w, _sh, COLORS._main_icon_light);
                draw_text_ext_add(ui(8), yy + ui(8), _txt, -1, con_w - ui(16));
                
                hh += _sh + padd;
                continue;
                
            } else if(is(jun, Inspector_Custom_Renderer)) {
                if(jun.popupPanel != noone) {
        			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_icon, .5);
        			draw_text_add(con_w / 2, yy + ui(24) / 2 - ui(2), __txt("Pop-up content"));
        			draw_set_alpha(1);
        			
        			hh += ui(24 + 2);
                    continue;
                }
                
                jun.step();
                jun.fixHeight = -1;
                jun.panel     = self;
                jun.rx        = ui(16) + x;
                jun.ry        = top_bar_h + y;
                jun.register(contentPane);
                
                var _wdh = jun.draw(ui(6), yy, con_w - ui(12), _m, _hover, pFOCUS, self);
                if(_wdh > 0) _wdh += ui(8);
                hh += _wdh;
                continue;
                
            } else if(is(jun, widget)) {
            	if(!jun.visible) continue;
            	
                jun.setFocusHover(pFOCUS, pHOVER);
                var param = new widgetParam(ui(6), yy, con_w - ui(12), TEXTBOX_HEIGHT, noone, {}, _m, x, y);
                var _wdh = jun.drawParam(param);
                if(!is_undefined(_wdh)) hh += _wdh + padd;
                continue;
                
            } else if(is_array(jun)) { // Section
                
                _colsp   = false;
                var txt  = __txt(jun[0]);
                var coll = _colMap[$ jun[0]] ?? jun[1];
                
                var fnt = viewMode == INSP_VIEW_MODE.spacious? f_p1 : f_p3;
                var lbh = viewMode == INSP_VIEW_MODE.spacious? ui(26) : ui(22);
                var lbw = con_w;
                var lbx = 0;
                
                var togl   = array_safe_get_fast(jun, 2, noone);
                var toging = false;
                
                if(togl != noone) {
                	var _p = viewMode == INSP_VIEW_MODE.spacious? ui(8) : ui(4);
                    lbx += lbh + _p;
                    lbw -= lbh + _p;
                    toging = _inspecting.getInputData(togl);
                    if(is_array(toging)) toging = false;
                }
                
                var righ = array_safe_get_fast(jun, 3, noone);
                if(righ != noone) lbw -= ui(32);
                
                if(_hover && point_in_rectangle(_m[0], _m[1], lbx, yy, lbx + lbw, yy + lbh)) {
                    contentPane.hover_content = true;
                    draw_sprite_stretched_ext(THEME.box_r5_clr, 0, lbx, yy, con_w - lbx, lbh, COLORS.panel_inspector_group_hover, 1);
                	
                	if(pFOCUS) {
	                		if(DOUBLE_CLICK) _cAll = jun[@ 1]? -1 : 1;
                       else if(mouse_press(mb_left)) { jun[@ 1] = !coll; coll = !coll; }
		               else if(mouse_press(mb_right, pFOCUS)) menuCall("inspector_group_menu", group_menu, 0, 0, fa_left);
                	}
                } else
                    draw_sprite_stretched_ext(THEME.box_r5_clr, 0, lbx, yy, con_w - lbx, lbh, COLORS.panel_inspector_group_bg, 1);
            
                _colMap[$ jun[0]] = coll;
                
                if(righ != noone) {
                    var _bx = lbx + lbw;
                    var _by = yy;
                    var _bw = ui(32);
                    var _bh = lbh;
                    
                    righ.setFocusHover(pFOCUS, pHOVER);
                    righ.draw(_bx + ui(2), _by + ui(2), _bw - ui(4), _bh - ui(4), _m, THEME.button_hide_fill);
                }
                
                if(filter_text == "") 
                    draw_sprite_ui(THEME.arrow, 0, lbx + ui(16), yy + lbh / 2, 1, 1, -90 + coll * 90, COLORS.panel_inspector_group_bg, 1);
                
                var cc, aa = 1;
                
                if(togl != noone) {
                	var jun = _inspecting.inputs[togl];
                	
                    if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, lbh, yy + lbh)) {
                        contentPane.hover_content = true;
                        draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy, lbh, lbh, COLORS.panel_inspector_group_hover, 1);
                        
                        if(mouse_press(mb_left,  pFOCUS)) jun.setValue(!toging);
                        if(mouse_press(mb_right, pFOCUS)) propRightClick(jun);
                            
                    } else 
                        draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy, lbh, lbh, COLORS.panel_inspector_group_bg, 1);
                    
                    cc = toging? COLORS._main_accent : COLORS.panel_inspector_group_bg;
                    aa = 0.5 + toging * 0.5;
                    
                               draw_sprite_stretched_ext(THEME.inspector_checkbox, 0, ui(4), yy + ui(4), lbh - ui(8), lbh - ui(8), cc, 1);
                    if(toging) draw_sprite_stretched_ext(THEME.inspector_checkbox, 1, ui(4), yy + ui(4), lbh - ui(8), lbh - ui(8), cc, 1);
                }
                
                var ltx = lbx + ui(32);
                
                draw_set_text(fnt, fa_left, fa_center, COLORS._main_text, aa);
                draw_text_add(ltx, yy + lbh / 2, txt);
                draw_set_alpha(1);
                
                hh += lbh + padd;
                
                if(coll) { // skip 
                    _colsp   = true;
                    var j    = i + 1;
                    var _len = array_length(_inspecting.input_display_list);
                    
                    while(j < _len) {
                        var j_jun = _inspecting.input_display_list[j];
                        if(is_array(j_jun)) break;
                        if(is(j_jun, Inspector_Spacer) && !j_jun.coll) break;
                        
                        j++;
                    }
                    
                    i = j - 1;
                }
                
                continue;
            }
        	
            if(!is(jun, NodeValue)) continue;
            
            if(!jun.show_in_inspector) continue;
            if(filter_text != "") {
                var pos = string_pos(filter_text, string_lower(jun.getName()));
                if(pos == 0) continue;
            }
            
            #region ++++ draw widget ++++
                var _font = viewMode == INSP_VIEW_MODE.spacious? f_p2 : f_p3;
                var  bs   = viewMode == INSP_VIEW_MODE.spacious? ui(20) : ui(16);
                var _padx = viewMode == INSP_VIEW_MODE.spacious? ui(16) : ui(12);
                
                var lb_h = line_get_height(_font, 4 + viewMode * 2);
                var lb_w = line_get_width(jun.getName(), _font) + _padx;
                var lb_x = bs * 2 + ui(16) + (ui(24) * (jun.color != -1)) - _padx / 2;
                
                var lbHov = point_in_rectangle(_m[0], _m[1], lb_x, yy, lb_x + lb_w, yy + lb_h);
                if(lbHov) {
                    contentPane.hover_content = true;
                    draw_sprite_stretched_ext(THEME.box_r2_clr, 0, lb_x, yy, lb_w, lb_h, c_white, 1);
                }
                
                var widg    = drawWidget(ui(16), yy, con_w - ui(20), _m, jun, false, _hover, _focus, contentPane, ui(16) + x, top_bar_h + y);
                var widH    = widg[0];
                var mbRight = widg[1];
                var widHov  = widg[2];
                
                if(widHov) contentPane.hover_content = true;
                
            	var _selH = lb_h + widH;
                hh += _selH + padd;
                
                if(jun == prop_highlight && prop_highlight_time) {
                    if(prop_highlight_time == 60)
                        contentPane.setScroll(_y - yy);
                    var aa = min(1, prop_highlight_time / 30);
                    draw_sprite_stretched_ext(THEME.ui_panel, 1, ui(4), yy, con_w - ui(4), _selH, COLORS._main_accent, aa);
                }
                
                if(_hover && lbHov && prop_dragging == noone && mouse_press(mb_left, pFOCUS)) {
                    prop_dragging = jun;
                        
                    prop_sel_drag_x = mouse_mx;
                    prop_sel_drag_y = mouse_my;
                }
            #endregion
            
            if(jun.connect_type == CONNECT_TYPE.input && jun.type == VALUE_TYPE.color && jun.display_type == VALUE_DISPLAY._default) { // color picker
                pickers[color_picker_index] = jun;
                color_picker_index++;
            }
            
            if(jun.editWidget && jun.editWidget.temp_hovering) {
            	draw_sprite_stretched_ext(THEME.prop_selecting, 0, ui(4), yy, con_w - ui(4), _selH, COLORS._main_accent, 1);
            	jun.editWidget.temp_hovering = false;
            }
            
            if(_hover && point_in_rectangle(_m[0], _m[1], ui(4), yy, con_w - ui(4), yy + _selH)) { // mouse in widget
                _HOVERING_ELEMENT = jun;
                
                var hov = PANEL_GRAPH.value_dragging != noone || (NODE_DROPPER_TARGET != noone && NODE_DROPPER_TARGET != jun);
                
                if(hov) {
                    draw_sprite_stretched_ext(THEME.ui_panel, 1, ui(4), yy, con_w - ui(4), _selH, COLORS._main_value_positive, 1);
                    if(mouse_press(mb_left, NODE_DROPPER_TARGET_CAN)) {
                        NODE_DROPPER_TARGET.expression += $"{jun.node.internalName}.{jun.connect_type == CONNECT_TYPE.input? "inputs" : "outputs"}.{jun.internalName}";
                        NODE_DROPPER_TARGET.expressionUpdate(); 
                    }
                } else draw_sprite_stretched_ext(THEME.prop_selecting, 0, ui(4), yy, con_w - ui(4), _selH, COLORS._main_accent, 1);
                
                if(anim_toggling) {
                    jun.setAnim(!jun.is_anim, true);
                    anim_toggling = false;
                }
                
                prop_hover = jun;
                    
                if(mouse_press(mb_left, pFOCUS))
                    prop_selecting = jun;
                        
                if(mouse_press(mb_right, pFOCUS && mbRight))
                    propRightClick(jun);
            } 
        }
        
        	 if(_cAll ==  1) section_expand_all();  
		else if(_cAll == -1) section_collapse_all();
		
        
        if(MESSAGE != noone && MESSAGE.type == "Color") {
            var inp = array_safe_get_fast(pickers, picker_index, 0);
            if(is_struct(inp)) {
                inp.setValue(MESSAGE.data);
                MESSAGE = noone;
            }
        }
        
        color_picking = false;
        
        if(prop_dragging) { //drag
            if(DRAGGING == noone && point_distance(prop_sel_drag_x, prop_sel_drag_y, mouse_mx, mouse_my) > 16) {
                prop_dragging.dragValue();
                prop_dragging = noone;
            }
            
            if(mouse_release(mb_left))
                prop_dragging = noone;
        }
        
        if(prop_highlight_time) {
            prop_highlight_time--;
            if(prop_highlight_time == 0)
                prop_highlight = noone;
        }
        
        return hh;
    }
    
    static drawContentMeta_GM = function(_y, _m) {
    	var ww = contentPane.surface_w;
    	var hh = ui(40);
        var yy = _y + hh;
        var rx = x + ui(16);
        var ry = y + top_bar_h;
        
        var _hover = pHOVER && contentPane.hover;
        var  spac  = viewMode == INSP_VIEW_MODE.spacious;
    	var _font  = spac? f_p1 : f_p2;
        
        #region properties
	        var _wdx = 0;
	        var _wdy = yy;
	        var _wdw = ww;
	        var _wdh = TEXTBOX_HEIGHT;
	        
	        var _data  = PROJECT.attributes.bind_gamemaker_path;
	    	var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, {}, _m, rx, ry)
	    					.setFont(_font)
	    					.setFocusHover(pFOCUS, _hover)
	    					.setScrollpane(contentPane);
            
	        var wh = PROJECT.gamemaker_editWidget.drawParam(_param);
	    	
	    	var _wdhh = wh + ui(8);
        	yy += _wdhh; 
        	hh += _wdhh;
		#endregion
		
		var gmBinder = PROJECT.bind_gamemaker;
		if(gmBinder == noone) return hh;
		
		var _wdh = GM_Explore_draw(gmBinder, 0, yy, contentPane.surface_w, contentPane.surface_h, _m, _hover, pFOCUS);
		hh += _wdh;
		
		return hh;
    }
    
    static drawContentMeta_PXC = function(_y, _m) {
    	
        var context = PANEL_GRAPH.getCurrentContext();
        var meta    = context == noone? PROJECT.meta : context.metadata;
        if(meta == noone) return 0;
        current_meta = meta;
        
        var  con_w = contentPane.surface_w - ui(4);
        var _hover = pHOVER && contentPane.hover;
        var  spac  = viewMode == INSP_VIEW_MODE.spacious;
        
        var hh  = ui(40);
        var yy  = _y + hh;
        var rx  = x + ui(16);
        var ry  = y + top_bar_h;
        var lbh = ui(26);
        var _cAll = 0;
        var _font = spac? f_p1 : f_p2;
        
        attribute_hovering = noone;
        
        for( var i = 0, n = array_length(meta_display); i < n; i++ ) {
            var _meta  = meta_display[i];
            var _txt   = array_safe_get_fast(_meta, 0);
            var _tag   = array_safe_get_fast(_meta, 2);
            
            if(_tag == "group prop" && PANEL_GRAPH.getCurrentContext() == noone) continue;
            
            var _x1    = con_w;
            var _y1    = yy + ui(2);
            
            /// Buttons
            
            var _butts = noone;
            switch(_tag) { // buttons
            	case "settings"  : _butts = variables_buttons;   break;
            	case "layers"    : _butts = globallayer_buttons; break;
            	case "metadata"  : _butts = metadata_buttons;    break;
                case "globalvar" : _butts = global_drawer.editing? global_buttons_editing : global_buttons; break;
            }
            
            if(is_array(_butts)) {
            	var _bw = ui(28);
                var _bh = lbh - ui(4);
                
                var _amo = array_length(_butts);
                var _tw  = (_bw + ui(4)) * _amo;
                draw_sprite_stretched_ext(THEME.box_r5_clr, 0, con_w - _tw, yy, _tw, lbh, COLORS.panel_inspector_group_bg, 1);
                
                global_button_edit.icon       = global_drawer.editing? THEME.accept_16 : THEME.gear_16;
                global_button_edit.icon_blend = global_drawer.editing? COLORS._main_value_positive : COLORS._main_icon_light;
                
                for (var j = 0, m = array_length(_butts); j < m; j++) {
                    _x1 -= _bw + ui(4);
                    
                    var _b = _butts[j];
                        _b.setFocusHover(pFOCUS, _hover);
                        _b.draw(_x1 + ui(2), _y1, _bw, _bh, _m, THEME.button_hide_fill);
                    if(_b.inBBOX(_m)) contentPane.hover_content = true;
                }
                
                _x1 -= ui(4);
            }
            
            /// Section
            
            var cc = COLORS.panel_inspector_group_bg;
            if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, _x1, yy + lbh)) {
            	cc = COLORS.panel_inspector_group_hover;
                
                if(pFOCUS) {
                    	 if(DOUBLE_CLICK) _cAll = _meta[1]? -1 : 1;
                    else if(mouse_press(mb_left)) _meta[1] = !_meta[1];
                }
            }
            
            draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy, _x1, lbh, cc, 1);
            draw_sprite_ui(THEME.arrow, _meta[1]? 0 : 3, ui(16), yy + lbh / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);    
            draw_set_text(viewMode? f_p0 : f_p1, fa_left, fa_center, COLORS._main_text_inner);
            draw_text_add(ui(32), yy + lbh / 2, _txt);
            
            /// Content
            
            yy += lbh + ui(6);
            hh += lbh + ui(6);
            
            if(_meta[1]) continue;
            
            switch(_tag) {
                case "settings" :
                    var _edt = PROJECT.attributeEditor;
                    var _lh, wh;
                    
                    for( var j = 0; j < array_length(_edt); j++ ) {
                        var title = array_safe_get(_edt[j], 0, noone);
                        var param = array_safe_get(_edt[j], 1, noone);
                        var editW = array_safe_get(_edt[j], 2, noone);
                        var drpFn = array_safe_get(_edt[j], 3, noone);
                        
                        var widx = ui(8);
                        var widy = yy;
                        
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text_inner);
                        draw_text_add(ui(16), spac? yy : yy + ui(3), __txt(title));
                        
                        if(spac) {
                            _lh = line_get_height();
                            yy += _lh + ui(6);
                            hh += _lh + ui(6);
                            
                        } else if(viewMode == INSP_VIEW_MODE.compact) {
                            _lh = line_get_height() + ui(6);
                        }
                        
                        var wh = 0;
                        var _data = PROJECT.attributes[$ param];
                        var _wdx  = spac? ui(16) : ui(140);
                        var _wdy  = yy;
                        var _wdw  = w - ui(48) - _wdx;
                        var _wdh  = spac? TEXTBOX_HEIGHT  : _lh;
                        
                        var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, {}, _m, rx, ry)
                        					.setFont(_font).setScrollpane(contentPane);
					    					
                        editW.setFocusHover(pFOCUS, _hover);
                        wh = editW.drawParam(_param);
                        
                        var jun  = PANEL_GRAPH.value_dragging;
                        var widw = con_w - ui(16);
                        var widh = spac? _lh + ui(6) + wh + ui(4) : max(wh, _lh);
                        
                        if(jun != noone && drpFn != noone && _hover && point_in_rectangle(_m[0], _m[1], widx, widy, widx + widw, widy + widh)) {
                            draw_sprite_stretched_ext(THEME.ui_panel, 1, widx, widy, widw, widh, COLORS._main_value_positive, 1);
                            attribute_hovering = drpFn;
                        }
                        
				    	var _wdhh = spac? wh + ui(8) : max(wh, _lh) + ui(6);
			        	yy += _wdhh; 
			        	hh += _wdhh;
                    }
                    
                    break;
                    
                case "layers" : 
                	var _h = global_layer_drawer.drawHeader(ui(8), yy, con_w - ui(16), _m, _hover, pFOCUS);
                	
                	yy += _h; 
		        	hh += _h;
		        	
                	var _h = global_layer_drawer.draw(ui(8), yy, con_w - ui(16), 0, _m, _hover, pFOCUS);
                	
                	yy += _h + ui(8); 
		        	hh += _h + ui(8);
                	break;
                	
                case "metadata" :
                    var _wdx = spac? ui(16) : ui(140);
                    var _wdw = w - ui(48) - _wdx;
                    var _whh = line_get_height(_font);
                    var _edt = PROJECT.meta.file_id == 0 || PROJECT.meta.author_steam_id == STEAM_USER_ID;
                        
                    for( var j = 0; j < array_length(meta.displays); j++ ) {
                        var display = meta.displays[j];
                        var _wdgt   = meta_tb[j];
                        
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text_inner);
                        draw_text_add(ui(16), spac? yy : yy + ui(3), __txt(display[0]));
                        
                        if(spac) {
                            _lh = line_get_height();
                            yy += _lh + ui(6);
                            hh += _lh + ui(6);
                            
                        } else if(viewMode == INSP_VIEW_MODE.compact) {
                            _lh = line_get_height() + ui(6);
                        }
                        
                        var _dataFunc = display[1];
                        var _data = _dataFunc(meta);
                        var _wdy  = yy;
                        var _wdh  = _whh * display[2];
                        
                        var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, {}, _m, rx, ry)
                        					.setFont(_font)
					    					.setFocusHover(pFOCUS, _hover, _edt)
					    					.setScrollpane(contentPane);
                        
                        if(is(_wdgt, textArrayBox)) _wdgt.arraySet = current_meta.tags;
                        wh = _wdgt.drawParam(_param);
                        
				    	var _wdhh = spac? wh + ui(8) : max(wh, _lh) + ui(6);
			        	yy += _wdhh; 
			        	hh += _wdhh;
                    }
                    
                    if(STEAM_ENABLED && _edt) {
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text_inner);
                        draw_text_over(ui(16), spac? yy : yy + ui(3), __txt("Show Avatar"));
                        
                        if(spac) {
                            _lh = line_get_height();
                            yy += _lh + ui(6);
                            hh += _lh + ui(6);
                        }
                        
                        var _param = new widgetParam(_wdx, yy, _wdw, TEXTBOX_HEIGHT, STEAM_UGC_ITEM_AVATAR, {}, _m, rx, ry)
                        					.setFont(_font)
					    					.setFocusHover(pFOCUS, _hover)
					    					.setScrollpane(contentPane);
                        
                        wh = meta_steam_avatar.drawParam(_param);
                        
				    	var _wdhh = spac? wh + ui(8) : wh + ui(6);
			        	yy += _wdhh; 
			        	hh += _wdhh;
                    }
                    
                    break;
                    
                case "globalvar" : 
                    // if(findPanel("Panel_Globalvar")) { yy += ui(4); hh += ui(4); continue; }
                    if(_m[1] > yy) contentPane.hover_content = true;
                    
                    global_drawer.viewMode = viewMode;
                    var glPar = global_drawer.draw(ui(16), yy, contentPane.surface_w - ui(24), _m, pFOCUS, _hover, contentPane, ui(16) + x, top_bar_h + y);
                    var gvh   = glPar[0];
                    
                    yy += gvh + ui(8);
                    hh += gvh + ui(8);
                    break;
                    
                case "group prop" :
                    var context = PANEL_GRAPH.getCurrentContext();
                    var _h = drawNodeProperties(yy, _m, context);
                    
                    yy += _h;
                    hh += _h;
                    break;
            }
            
            yy += ui(2);
            hh += ui(2);
        }
        
        	 if(_cAll ==  1) { for( var i = 0, n = array_length(meta_display); i < n; i++ ) meta_display[i][1] = false; }
		else if(_cAll == -1) { for( var i = 0, n = array_length(meta_display); i < n; i++ ) meta_display[i][1] =  true; }
		
        return hh;
    }
    
    static drawContentMeta = function(_y, _m) {
    	var _tab_width = min(contentPane.w - ui(32), ui(280));
    	var _tab_x     = (contentPane.w - ui(12)) / 2 - _tab_width / 2;
    	
        proj_prop_page_b.setFocusHover(pFOCUS, pHOVER);
        proj_prop_page_b.draw(_tab_x, _y + ui(4), _tab_width, ui(24), proj_prop_page, _m, x + contentPane.x, y + contentPane.y);
        
        switch(proj_prop_page) {
        	case 0 : return drawContentMeta_PXC(_y, _m);
        	case 1 : return drawContentMeta_GM(_y, _m);
        }
        
        return 0;
    }
    
    static drawContentNode = function(_y, _m) {
        var con_w  = contentPane.surface_w - ui(4);
        if(point_in_rectangle(_m[0], _m[1], 0, 0, con_w, content_h) && mouse_press(mb_left, pFOCUS))
            prop_selecting = noone;
        
        var _tab_width = min(contentPane.w - ui(32), ui(280));
    	var _tab_x     = (contentPane.w - ui(12)) / 2 - _tab_width / 2;
    	
        prop_page_b.data[2] = inspecting.messages_bub? THEME.message_16_grey_bubble : THEME.message_16_grey;
        prop_page_b.setFocusHover(pFOCUS, pHOVER);
        prop_page_b.draw(_tab_x, _y + ui(4), _tab_width, ui(24), prop_page, _m, x + contentPane.x, y + contentPane.y);
        
        var _hh = ui(40);
        _y += _hh;
        
        if(inspectGroup >= 0 || is(inspecting, Node_Frame)) return _hh + drawNodeProperties(_y, _m, inspecting);
        
        for( var i = 0, n = min(10, array_length(inspectings)); i < n; i++ ) {
            if(i) {
                _y  += ui(8);
                _hh += ui(8);
            }
            
            if(n > 1) {
                draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, _y, con_w, ui(32), COLORS.panel_inspector_output_label, 0.9);
                draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
                
                var _tx = inspectings[i].getFullName();
                draw_text_add(con_w / 2, _y + ui(16), _tx);
                
                _y  += ui(32 + 8);
                _hh += ui(32 + 8);
            }
            
            var _h = drawNodeProperties(_y, _m, inspectings[i]);
            _y  += _h;
            _hh += _h;
        }
        
        return _hh + ui(64);
    }
    
    static drawHeader_Node = function() {
        
        var txt = inspecting.renamed? inspecting.display_name : inspecting.name;
             if(inspectGroup ==  1) txt = $"[{array_length(PANEL_GRAPH.nodes_selecting)}] {txt}"; 
        else if(inspectGroup == -1) txt = $"[{array_length(PANEL_GRAPH.nodes_selecting)}] Multiple nodes"; 
        
        var tb_x = ui(64);
        var tb_y = ui(14);
        var tb_w = w - ui(128);
        var tb_h = ui(32);
        
        tb_node_name.setFocusHover(pFOCUS, pHOVER);
        tb_node_name.draw(tb_x, tb_y, tb_w, tb_h, txt, [ mx, my ]);
        
        if(inspectGroup >= 0) {
            draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
            draw_text_add(w / 2 + ui(8), ui(56), inspecting.name);
        
            draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
            draw_set_alpha(0.65);
            draw_text_add(w / 2, ui(76), inspecting.internalName);
            draw_set_alpha(1);
            
            var _txt_w = string_width(inspecting.internalName);
            
	        var his_x = w / 2 - _txt_w / 2 - ui(16);
	        var his_y = ui(68);
	        
	        var targ     = array_empty(inspect_history_undo)? noone : array_last(inspect_history_undo);
	        var targName = targ == noone? "Project" : targ.getDisplayName();
	        var _hov     = pHOVER && point_in_rectangle(mx, my, his_x, his_y, w / 2, his_y + ui(16));
	        
	        var cc = _hov? c_white : COLORS._main_text_sub;
	        var aa = _hov? 1 : .75;
	        draw_sprite_ui_uniform(THEME.arrow_wire_16, 2, his_x + ui(8), his_y + ui(8), 1, cc, aa);
	        
	        if(_hov && mouse_lpress(pFOCUS)) {
	        	array_pop(inspect_history_undo);
	        	array_push(inspect_history_redo, inspecting);
	        	
	        	setInspecting(targ, false, true, false);
	        	PANEL_GRAPH.nodes_selecting = [];
	        	PANEL_PREVIEW.setNodePreview(targ);
	        }
	        
	        var his_x = w / 2 + _txt_w / 2;
	        
	        if(!array_empty(inspect_history_redo)) {
	        	var targ     = array_last(inspect_history_redo);
	        	var targName = targ == noone? "Project" : targ.getDisplayName();
	        	var _hov     = pHOVER && point_in_rectangle(mx, my, his_x, his_y, w, his_y + ui(16));
	        	
		        var cc = _hov? c_white : COLORS._main_text_sub;
		        var aa = _hov? 1 : .75;
		        draw_sprite_ui_uniform(THEME.arrow_wire_16, 0, his_x + ui(8), his_y + ui(8), 1, cc, aa);
		        
		        if(_hov && mouse_lpress(pFOCUS)) {
		        	array_pop(inspect_history_redo);
		        	
		        	setInspecting(targ, false, true);
		        	PANEL_GRAPH.nodes_selecting = [];
		        	PANEL_PREVIEW.setNodePreview(targ);
		        }
	        }
	        
	        if(inspecting == noone) return;
        }
        
        var bx = ui(8);
        var by = ui(12);
            
        if(inspectGroup == 0) {
            draw_set_font(f_p1);
            var lx = w / 2 - string_width(inspecting.name) / 2 - ui(10);
            var ly = ui(56 - 8);
            if(buttonInstant(THEME.button_hide_fill, lx, ly, ui(16), ui(16), [mx, my], pHOVER, pFOCUS, __txt("Lock"), THEME.lock_12, !locked, locked? COLORS._main_icon_light : COLORS._main_icon) == 2)
                locked = !locked;
            
            if(buttonInstant(THEME.button_hide_fill, bx, by, ui(32), ui(32), [mx, my], pHOVER, pFOCUS, __txt("Presets"), THEME.preset, 1) == 2)
                dialogPanelCall(new Panel_Presets(inspecting), x + bx, y + by + ui(36));
        } else {
            draw_sprite_ui_uniform(THEME.preset, 1, bx + ui(32) / 2, by + ui(32) / 2, 1, COLORS._main_icon_dark);
        }
        
        ////- INSPECTOR ACTIONS
        
        var bx = w - ui(44);
        var by = ui(12);
        var bs = ui(32);
        var m  = [mx, my];
        
        if(inspecting.hasInspector1Update(true)) {
            var icon = inspecting.insp1UpdateIcon;
            var ac = inspecting.insp1UpdateActive;
            var cc = ac? icon[2] : COLORS._main_icon_dark;
            var tt = inspecting.insp1UpdateTooltip;
            if(inspectGroup) tt += " [All]";
            
            if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, m, pHOVER && ac, pFOCUS && ac, tt, icon[0], icon[1], cc) == 2) {
                if(inspectGroup == 1) {
                    for( var i = 0, n = array_length(inspectings); i < n; i++ ) {
                    	if(inspectings[i].hasInspector1Update())
                    		inspectings[i].inspector1Update();
                    }
                    
                } else 
                    inspecting.inspector1Update();
            }
        } else 
            draw_sprite_ui(THEME.sequence_control, 1, bx + ui(16), by + ui(16),,,, COLORS._main_icon_dark);
        
        if(inspecting.hasInspector2Update()) {
            by += ui(36);
            
            var icon = inspecting.insp2UpdateIcon;
            var ac = inspecting.insp2UpdateActive;
            var cc = ac? icon[2] : COLORS._main_icon_dark;
            var tt = inspecting.insp2UpdateTooltip;
            if(inspectGroup) tt += " [All]";
            
            if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, m, pHOVER && ac, pFOCUS && ac, tt, icon[0], icon[1], cc) = 2) {
                if(inspectGroup) {
                    for( var i = 0, n = array_length(inspectings); i < n; i++ ) {
                    	if(inspectings[i].hasInspector2Update())
                    		inspectings[i].inspector2Update();
                    }
                    
                } else 
                    inspecting.inspector2Update();
            }
        }
    }
    
    function drawContent(panel) { 
    	draw_clear_alpha(COLORS.panel_bg_clear, 1);
        draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(8), top_bar_h - ui(8), w - ui(16), h - top_bar_h);
    	
        if(inspecting && !inspecting.active) inspecting = noone;
        var mse = [mx,my];
        
        view_mode_tooltip.index = viewMode;
        var b = buttonInstant(THEME.button_hide_fill,  ui(8), ui(48), ui(32), ui(32), mse, pHOVER, pFOCUS, view_mode_tooltip, THEME.inspector_view, viewMode);
        if(b == 2 || (b == 1 && key_mod_press(SHIFT) && MOUSE_WHEEL != 0)) { 
        	viewMode = !viewMode; 
        	PREFERENCES.inspector_view_default = viewMode;
        }
        
        if(inspecting) {
            var _nodes = PANEL_GRAPH.nodes_selecting;
            
            inspectGroup = array_length(_nodes) > 1;
            inspectings  = array_empty(_nodes)? [ inspecting ] : _nodes;
            
            for( var i = 1, n = array_length(_nodes); i < n; i++ ) {
            	if(instanceof(_nodes[i]) == instanceof(_nodes[0])) continue;
                inspectGroup = -1; 
                break; 
            }
            
            if(is(inspecting, Node_Frame)) inspectGroup = 0;
            
            title = inspecting.getDisplayName();
            inspecting.inspectorStep();
            drawHeader_Node();
            
        } else {
            title = __txt("Inspector");
            
            var txt = "Untitled";
            var ctx = PANEL_GRAPH.getCurrentContext();
            var sav = file_exists_empty(PROJECT.path);
            
            if(ctx == noone && sav) txt = filename_name_only(PROJECT.path);
            else if(is(ctx, Node))  txt = ctx.getDisplayName();
            
            draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
            var ww = w - ui(160);
            var ss = clamp(ww / string_width(txt), .25, .5);
            var tx = w / 2;
            var ty = ui(30);
            
            var tw  = string_width(txt) / 2 * ss;
            var sx0 = max(    ui(64), tx - tw - ui(20));
            var sx1 = min(w - ui(64), tx + tw + ui(20));
            
            if(sav) {
	            if(PROJECT.meta.file_id != 0) {
	            	if(buttonInstant_Icon(sx0, ty, ui(10), [mx,my], pHOVER, pFOCUS, __txt("View on Workshop..."), THEME.steam_invert_24, 0, .8) == 2) {
	                	var _p = new Panel_Steam_Workshop();
	                    _p.navigate({ type: "fileid", fileid: PROJECT.meta.file_id });
	                    dialogPanelCall(_p);
	                }
	            }
	            
	            if(buttonInstant_Icon(sx1, ty, ui(10), [mx,my], pHOVER, pFOCUS, __txt("Rename"), THEME.rename, 0, .8) == 2) {
	            	textboxCall(txt, function(t) /*=>*/ {
	            		if(t == "") return;
	            		
	            		var _opth = PROJECT.path;
	            		var _dir = filename_dir(PROJECT.path);
	            		var _pth = filename_ext_verify(filename_combine(_dir, t), ".pxc");
	            		
	            		SAVE_AT(PROJECT, _pth);
	            		PROJECT.path = _pth;
	            		file_delete_safe(_opth);
	            	});
	            }
            }
            
            var _scis = gpu_get_scissor();
            gpu_set_scissor(sx0 + ui(16), ty - ui(16), sx1 - sx0 - ui(32), ui(32));
            draw_text_add(tx, ty, txt, ss);
            gpu_set_scissor(_scis);
            
            var bx = w - ui(44);
            var by = ui(12);
            var bs = ui(32);
            
            by += ui(36);
            if(STEAM_ENABLED && workshop_uploading == 0) {
                if(!sav) { // unsaved project
                	var _txt = __txtx("panel_inspector_workshop_save", "Save file before upload");
                    buttonInstant(noone, bx, by, bs, bs, mse, pHOVER, pFOCUS, _txt, THEME.workshop_upload, 0, c_white);
                    
                } else if(PROJECT.meta.file_id == 0) { // project made locally
                    var s = PANEL_PREVIEW.getNodePreviewSurface();
                    if(!is_surface(s)) {
                    	var _txt = __txtx("panel_inspector_workshop_no_thumbnail", "Send node to preview to be use as project thumbnail before uploading.");
                    	buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mse, pHOVER, pFOCUS, _txt, THEME.workshop_no_file, 0, c_white);
                    	
                    } else {
	                	var _txt = __txtx("panel_inspector_workshop_upload", "Upload to Steam Workshop");
	                    if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mse, pHOVER, pFOCUS, _txt, THEME.workshop_upload, 0, c_white) == 2) {
                            steam_ugc_create_project();
                            workshop_uploading = 2;
                    	}
                    }
                    
                } else if(PROJECT.meta.author_steam_id == STEAM_USER_ID) { // user-owned steam project
                	var _txt = __txtx("panel_inspector_workshop_upload_new", "Upload as a new Steam Workshop submission");
                    if(buttonInstant(THEME.button_hide_fill, bx, by - ui(36), bs, bs, mse, pHOVER, pFOCUS, _txt, THEME.workshop_add, 0, c_white) == 2) {
                        steam_ugc_create_project();
                        workshop_uploading = 1;
                	}
                	
                	var _txt = __txtx("panel_inspector_workshop_update",  "Update Steam Workshop content");
                	if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, mse, pHOVER, pFOCUS, _txt, THEME.workshop_update, 0, c_white) == 2) {
                        dialogCall(o_dialog_steam_project_update, mouse_mx + 8, mouse_my + 8).activate("Update note");
                    }
                }
            }
            
            if(workshop_uploading) {
            	var _by = ui(12) + (workshop_uploading - 1) * ui(36);
                draw_sprite_ui(THEME.loading_s, 0, bx + ui(16), _by + ui(16),,, current_time / 5, COLORS._main_icon);
                if(STEAM_UGC_UPLOADING == false)
                    workshop_uploading = 0;
            }
        }
        
        contentPane.setFocusHover(pFOCUS, pHOVER);
        contentPane.draw(ui(16), top_bar_h, mx - ui(16), my - top_bar_h);
        
        /// focus 
        var _foc = PANEL_GRAPH.getFocusingNode();
        if(!locked && _foc && inspecting != _foc) setInspecting(_foc);
    }
    
    ////- Serialize
    
    static serialize   = function() { 
        return { 
            name: instanceof(self), 
            inspecting  : node_get_id(inspecting), 
            inspectings : array_map(inspectings, function(n) { return node_get_id(n) }),
            
            locked,
        }; 
    }
    
    static deserialize = function(data) { 
        inspecting  = node_from_id(data.inspecting);
        inspectings = array_map(data.inspectings, function(n) { return node_from_id(n); });
        
        locked      = struct_try_get(data, "locked", locked);
        
        return self; 
    }
    
    ////- Actions
    
}

function New_Inspect_Node_Panel(node, pin = true) {
    panel = panelAdd("Panel_Inspector", true, false);
	panel.content.setInspecting(node, true, false);
	panel.destroy_on_click_out = !pin;
	
	return panel;
}