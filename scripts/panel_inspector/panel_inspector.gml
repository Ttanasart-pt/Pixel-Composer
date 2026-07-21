#region ___function calls
    function global_filter_anim() { CALL("global_filter_anim"); FILTER_ANIMATION = !FILTER_ANIMATION; GraphRefresh(); }
    
    function panel_inspector_copy_prop()                 { CALL("inspector_copy_property");          PANEL_INSPECTOR.propSelectCopy();                 }
    function panel_inspector_paste_prop()                { CALL("inspector_paste_property");         PANEL_INSPECTOR.propSelectPaste();                }
    
    function panel_inspector_color_pick()                { CALL("color_picker"); if(!PREFERENCES.alt_picker&& !MOUSE_BLOCK) return; PANEL_INSPECTOR.color_picking = true; }
    
    function panel_inspector_section_expand_all()        { CALL("inspector_section_expand_all");     PANEL_INSPECTOR.section_expand_all();             }
    function panel_inspector_section_collapse_all()      { CALL("inspector_section_collapse_all");   PANEL_INSPECTOR.section_collapse_all();           }
    
    function panel_inspector_reset()                     { CALL("inspector_reset");                  PANEL_INSPECTOR.junction_reset();                 }
    function panel_inspector_animation_toggle()          { CALL("inspector_animation_toggle");       PANEL_INSPECTOR.junction_animation_toggle();      }
    function panel_inspector_array_toggle()              { CALL("inspector_array_toggle");           PANEL_INSPECTOR.junction_array_toggle();          }
    function panel_inspector_axis_toggle()               { CALL("inspector_axis_toggle");            PANEL_INSPECTOR.junction_axis_toggle();           }
    function panel_inspector_expression_toggle()         { CALL("inspector_expression_toggle");      PANEL_INSPECTOR.junction_expression_toggle();     }
    function panel_inspector_extract_global()            { CALL("inspector_extract_global");         PANEL_INSPECTOR.junction_extract_global();        }
    function panel_inspector_extract_single()            { CALL("inspector_extract_single");         PANEL_INSPECTOR.junction_extract_single();        }
    function panel_inspector_junction_bypass_toggle()    { CALL("inspector_junc_bypass");            PANEL_INSPECTOR.junction_bypass_toggle();         }
    function panel_inspector_visible_toggle()            { CALL("inspector_junc_visible");           PANEL_INSPECTOR.junction_visible_toggle();        }
    function panel_inspector_mini_timeline_toggle()      { CALL("inspector_mini_timeline");          PANEL_INSPECTOR.junction_mini_timeline_toggle();  }
    
    function panel_inspector_trigger_1()                 { CALL("inspector_trigger_1");              PANEL_INSPECTOR.triggerInspectingNode(1);        }
    function panel_inspector_trigger_2()                 { CALL("inspector_trigger_2");              PANEL_INSPECTOR.triggerInspectingNode(2);        }
    function panel_inspector_trigger_cache()             { CALL("inspector_trigger_cache");          PANEL_INSPECTOR.triggerInspectingNode(3);        }
    
    function panel_inspector_search_toggle()             { CALL("inspector_search_toggle");
    	PANEL_INSPECTOR.filtering = !PANEL_INSPECTOR.filtering;
		if(PANEL_INSPECTOR.filtering) PANEL_INSPECTOR.tb_prop_filter.activate();
		else                          PANEL_INSPECTOR.tb_prop_filter.deactivate();
    }
    
    #macro INSP_JUNCTION var j = PANEL_INSPECTOR.__dialog_junction; return j == noone? false : 
    
    function __fnInit_Inspector() {
    	var i = "Inspector";
    	var n = MOD_KEY.none;
    	var c = MOD_KEY.ctrl;
    	var a = MOD_KEY.alt;
    	var s = MOD_KEY.shift;
    	
        registerFunction("", "Filter Animation",     "F", a, global_filter_anim                     ).setMenu("global_filter_anim");
        registerFunction("", "Color Picker",         "",  a, panel_inspector_color_pick             ).setMenu("color_picker");
        
        registerFunction(i, "Copy Value",            "C", c, panel_inspector_copy_prop              ).setMenu("inspector_copy_property",  THEME.copy)
        registerFunction(i, "Paste Value",           "V", c, panel_inspector_paste_prop             ).setMenu("inspector_paste_property", THEME.paste)
        
        registerFunction(i, "Expand All Sections",   "",  n, panel_inspector_section_expand_all     ).setMenu("inspector_expand_all_sections")
        registerFunction(i, "Collapse All Sections", "",  n, panel_inspector_section_collapse_all   ).setMenu("inspector_collapse_all_sections")
        
        registerFunction(i, "Search Toggle",        "F",  c, panel_inspector_search_toggle          ).setMenu("inspector_search_toggle")
        registerFunction(i, "Reset",                 "",  n, panel_inspector_reset                  ).setMenu("inspector_reset")
        
        registerFunction(i, "Toggle Animation",      "",  n, panel_inspector_animation_toggle       ).setMenu("inspector_animate_toggle"      ).setToggle(function() /*=>*/ { INSP_JUNCTION j.is_anim;            });
        registerFunction(i, "Toggle Separate Axis",  "",  n, panel_inspector_axis_toggle            ).setMenu("inspector_axis_toggle"         ).setToggle(function() /*=>*/ { INSP_JUNCTION j.sep_axis;           });
        registerFunction(i, "Toggle Expression",     "",  n, panel_inspector_expression_toggle      ).setMenu("inspector_expression_toggle"   ).setToggle(function() /*=>*/ { INSP_JUNCTION j.expUse;             });
        registerFunction(i, "Toggle Array Process",  "",  n, panel_inspector_array_toggle           ).setMenu("inspector_toggle_array"        ).setToggle(function() /*=>*/ { INSP_JUNCTION j.ign_array;          });   
        registerFunction(i, "Toggle Bypass",         "",  n, panel_inspector_junction_bypass_toggle ).setMenu("inspector_bypass_toggle"       ).setToggle(function() /*=>*/ { INSP_JUNCTION j.bypass_use;         });
        registerFunction(i, "Toggle Visible",        "",  n, panel_inspector_visible_toggle         ).setMenu("inspector_visible_toggle"      ).setToggle(function() /*=>*/ { INSP_JUNCTION j.visible_manual;     });
        registerFunction(i, "Toggle Mini Timeline",  "",  n, panel_inspector_mini_timeline_toggle   ).setMenu("inspector_mini_timeline_toggle").setToggle(function() /*=>*/ { INSP_JUNCTION j.inspector_timeline; });
        registerFunction(i, "Extract to Globalvar",  "",  n, panel_inspector_extract_global         ).setMenu("inspector_extract_global")
        registerFunction(i, "Extract Value",         "",  n, panel_inspector_extract_single         ).setMenu("inspector_extract_value" )
        registerFunction("", "Primary Action",    vk_f2,  n, panel_inspector_trigger_1              ).setMenu("inspector_trigger_1"     )
        registerFunction("", "Secondary Action",  vk_f3,  n, panel_inspector_trigger_2              ).setMenu("inspector_trigger_2"     )
        registerFunction("", "Clear Cache",       vk_f4,  n, panel_inspector_trigger_cache          ).setMenu("inspector_trigger_3"     )
        
        registerFunction("Property", "Extract To...", "E", n, function(_dat) /*=>*/ {
        	var jun = PANEL_INSPECTOR.prop_hover;
        	if(jun == noone) jun = PANEL_INSPECTOR.__dialog_junction;
        	if(jun == noone) return;
        	
        	PANEL_INSPECTOR.__dialog_junction = jun;
            var ext = jun.extract_node;
            if(ext == "") return;
            if(!is_array(ext)) ext = [ext];
            
            var arr = [];
            for( var i = 0, n = array_length(ext); i < n; i++ ) {
            	var _nod = ext[i];
            	var _nam = ALL_NODES[$ _nod].name;
            	
                array_push(arr, menuItem(_nam, method(jun, jun.extractNode),,,, _nod));
            }
                
	        return array_empty(arr)? noone : submenuCall(_dat, arr);
        }).setMenu("inspector_extract", noone, true);
        
        registerFunction("Property", "Quick Anim...", "Q", s, function(_dat) /*=>*/ {
        	var jun = PANEL_INSPECTOR.prop_hover;
        	if(jun == noone) jun = PANEL_INSPECTOR.__dialog_junction;
        	if(jun == noone) return;
        	
        	PANEL_INSPECTOR.__dialog_junction = jun;
            var anim = jun.anim_presets;
            if(!is_array(anim)) return;
            
            var arr = [];
        	for( var i = 0, n = array_length(jun.anim_presets); i < n; i++ ) {
        		var _pres = jun.anim_presets[i];
        		if(_pres == -1) { array_push(arr, -1); continue; }
        		
        		var _name = _pres[0];
        		var _data = _pres[1];
        		var _spr  = array_safe_get_fast(_pres, 2, noone);
        		
        		array_push(arr, menuItem(_name, method(jun, jun.setQuickAnim), _spr).setParam(_data));
        	}
            
	        return array_empty(arr)? noone : submenuCall(_dat, arr);
        }).setMenu("inspector_quick_anim", noone, true);
        
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
	    node    = noone;
	    panel   = noone;
	    name    = "";
		padName = false;
	    
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
	    
	    ////- =Setters
	    
	    static setName    = function(n) /*=>*/ { name = n;       return self; }
	    static setPadName = function( ) /*=>*/ { padName = true; return self; }
	    static setNode    = function(n) /*=>*/ { node = n;       return self; }
	    static toString   = function( ) /*=>*/ { return $"Custon renderer: {name}"; }
	    
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
	    
	    ////- =Step
	    
	    static step = function() {
	        b_toggle.icon_blend = popupPanel == noone? COLORS._main_icon : COLORS._main_accent;
	    }
	    
	    ////- =Draw
	    
	    draw = drawFn;
	    
	    static fetchHeight = function(params) { return drawParam(params); }
		static drawParam   = function(params) { 
			return draw(params.x, params.y, params.w, params.m, params.hover ?? hover, params.focus ?? active);
		}
	    
	    ////- =Actions
	    
	    static clone    = function() { 
	        var _n = new Inspector_Custom_Renderer(draw, register);
	        var _key = variable_instance_get_names(self);
	        
	        for( var i = 0, n = array_length(_key); i < n; i++ ) 
	            _n[$ _key[i]] = self[$ _key[i]];
	        
	        return _n;
	    }
	}
	
	function Inspector_Label(_text = "", _font = f_p3) constructor { 
	    text = _text; 
	    font = _font; 
	    open = true;
	}
	
	function __inspc(_h = ui(6),  _line =  true, _coll = true, _shf = ui(2)) { return new Inspector_Spacer(_h, _line, _coll, _shf); }
	function Inspector_Spacer(_h, _line = false, _coll = true, _shf = ui(2)) constructor { 
		active = true;
	    h      = _h;  
	    line   = _line;
	    coll   = _coll;
	    lshf   = _shf;
	}
	
	function Inspector_Sprite() constructor {
		type  = "Inspector_Sprite";
		data  = "";
		spr   = undefined;
		subimages = 1;
		
		static setPath = function(p) /*=>*/ { 
			if(spr != undefined && sprite_exists(spr)) 
				sprite_delete(spr);
			
			var _buff = buffer_load(p);
			var _base64_data = buffer_base64_encode(_buff, 0, buffer_get_size(_buff));
			buffer_delete(_buff);
			
			subimages = 1;
			if(string_pos("strip", p)) {
				var _spl = string_split(p, "strip");
				var _num = toNumber(array_safe_get(_spl, 1, ""));
				if(_num) subimages = _num;
			}
			
			data = $"data:image/png;base64,{_base64_data}";
			spr  = sprite_add(data, subimages);
			return self; 
		}
		
		static getSpr = function() /*=>*/ {
			if(spr != undefined) return spr;
			if(data != "") spr = sprite_add(data, subimages);
			return spr;
		}
		
		////- Serialize
	
		static serialize = function() {
			return { data, subimages };
		}
		
		static deserialize = function(_m) { 
			if(!is_struct(_m)) return self;
			data      = _m[$ "data"]      ?? data;
			subimages = _m[$ "subimages"] ?? subimages;
			return self;
		}

	}
#endregion

enum INSPECTOR_FLAG { 
	show_all   = 0, 
	input_only = 1, 
}

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
        top_bar_h    = ui(92);
        
        content_w = 0;
        content_h = 0;
        
        view_mode_tooltip = new tooltipSelector("View Settings...", [ "Compact", "Spacious" ])
        
    	drawWidgetInit();
    #endregion
    
    #region ---- Properties ----
        prop_hover          = noone;
        prop_selecting      = noone;
        prop_selecting_y    = 0;
        prop_selecting_y_to = 0;
        prop_selecting_h    = 0;
        prop_selecting_h_to = 0;
        
        prop_highlight      = noone;
        prop_highlight_time = 0;
    
        prop_dragging       = noone;
        prop_sel_drag_x     = 0;
        prop_sel_drag_y     = 0;
    	
        color_picking       = false;
        picker_index        = 0;
        picker_change       = false;
        
        attribute_hovering  = noone;
        
        timeline_scrubbing  = false;
        inline_expands      = false;
        
        renaming  = undefined;
		tb_rename = textBox_Text(function(_n) /*=>*/ { if(renaming != undefined) renaming.setName(_n, false); renaming = undefined; });
    #endregion
    
    #region ---- Header Tabs ----
        tb_node_name = textBox_Text(function(txt) /*=>*/ { if(inspecting) inspecting.setDisplayName(txt); })
                             .setFont(f_h5).setHide(1).setAlign(fa_center);
        tb_node_name.format = TEXT_AREA_FORMAT.node_title;
        
        filter_text      = "";
        filtering        = false;
        
        tb_prop_filter = textBox_Text(function(txt) /*=>*/ { filter_text = txt; }).setEmpty(false).setAutoUpdate()
                             .setFont(f_p2).setAlign(fa_center);
    	
        prop_page   = "Node";
        
        prop_page_a = [ "Properties", "Settings", THEME.message_16 ];
        prop_page_p = [ "Node", "Settings", "Log" ];
        prop_page_b = new buttonGroup(prop_page_a, function(val) /*=>*/ { prop_page = prop_page_p[val]; })
   						.setButton([ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ]).iconPad(ui(8))
   						.setFont(f_p2, COLORS._main_text_sub)
        
        prop_page_panel_a = [ "Panel", "Properties", "Settings", THEME.message_16 ];
        prop_page_panel_p = [ "Panel", "Properties", "Settings", "Log" ];
        prop_page_panel_b = new buttonGroup(prop_page_panel_a, function(val) /*=>*/ { prop_page = prop_page_panel_p[val]; })
   						.setButton([ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ]).iconPad(ui(8))
   						.setFont(f_p2, COLORS._main_text_sub)
        
        proj_prop_page   = 0;
        proj_prop_page_b = new buttonGroup([ "PXC", "GM" ], function(val) /*=>*/ { proj_prop_page = val; })
        					.setButton([ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ])
        					.setFont(f_p2, COLORS._main_text_sub)
        
        tooltip_primary   = new tooltipHotkey("", "", "Primary Action");
        tooltip_secondary = new tooltipHotkey("", "", "Secondary Action");
        tooltip_cache     = new tooltipHotkey("", "", "Clear Cache");
    #endregion
    
    #region ---- Metadata ----
        uploading_thumbnail = false;
        
        current_meta   = -1; 
        tb_meta_desc   = textArea_Text( function(s) /*=>*/ { current_meta.description = s; PROJECT.setModified(); } ).setVAlign(ui(4));
        tb_meta_author = textArea_Text( function(s) /*=>*/ { current_meta.author      = s; PROJECT.setModified(); } ).setVAlign(ui(4));
        
        meta_edit[0] = tb_meta_desc
        meta_edit[1] = tb_meta_author;
        meta_edit[2] = textArea_Text( function(s) /*=>*/ { current_meta.contact     = s; PROJECT.setModified(); } ).setVAlign(ui(4));
        meta_edit[3] = textArea_Text( function(s) /*=>*/ { current_meta.alias       = s; PROJECT.setModified(); } ).setVAlign(ui(4));
        meta_edit[4] = new textArrayBox(noone, META_TAGS).setAddable(true);
        
        if(STEAM_ENABLED) {
        	var b_steam_name = button(function() /*=>*/ { current_meta.author = STEAM_USERNAME; })
				.setIcon(THEME.steam_invert_24, 0, COLORS._main_icon_light)
				.setTooltip("Use Steam username");
				
        	tb_meta_author.setSideButton(b_steam_name);
			b_steam_name.iconPad(ui(6));
        }
        
        meta_display = [ 
            [ __txt("Project Settings"),     false, "settings"   ], 
            [ __txt("Metadata"),             true , "metadata"   ], 
            [ __txt("Global Layer"),         true,  "layers"     ], 
            [ __txt("Custom Panels"),        false, "panels"     ], 
            [ __txt("Global Variables"),     false, "globalvar"  ], 
            [ __txt("Group Properties"),     false, "group prop" ], 
            [ __txt("Favorited Properties"), false, "favorites"  ], 
        ];
        
        meta_steam_avatar = new checkBox(function() /*=>*/ { STEAM_UGC_ITEM_AVATAR = !STEAM_UGC_ITEM_AVATAR; });
        
        global_button_edit  = button(function() /*=>*/ { meta_display[3][1] = false; global_drawer.editing = true;     }).setIcon(THEME.gear_16,   0, COLORS._main_icon_light);
        global_button_apply = button(function() /*=>*/ { meta_display[3][1] = false; global_drawer.editing = false;    }).setIcon(THEME.accept_16, 0, COLORS._main_value_positive);
        global_button_new   = button(function() /*=>*/ { meta_display[3][1] = false; PROJECT.globalNode.createValue(); }).setIcon(THEME.add_16,    0, COLORS._main_value_positive);
        global_button_pop   = button(function() /*=>*/ {return dialogPanelCall(new Panel_Globalvar())} ).setIcon(THEME.text_popup, 1, COLORS._main_icon_light, .75);
        
        global_buttons         = [ global_button_new, global_button_edit,  global_button_pop ];
        global_buttons_editing = [ global_button_new, global_button_apply, global_button_pop ];
        global_drawer          = new GlobalVarDrawer();
        
        GM_Explore_draw_init();
        
        variables_buttons = [ 
        	button(function() /*=>*/ {return dialogPanelCall(new Panel_Project_Info())})
        		.setIcon(THEME.info, 0, COLORS._main_icon_light, .75)
        		.setTooltip(__txt("Project Info")),
        	
        	button(function() /*=>*/ {return dialogPanelCall(new Panel_Project_Var())})
        		.setIcon(THEME.gear_16, 0, COLORS._main_icon_light)
        		.setTooltip(__txt("Project Variables")),
        		
    	];
        
        metadata_buttons = [ button(function() /*=>*/ { json_save_struct(DIRECTORY + "meta.json", PROJECT.meta.serialize()); })
        	.setIcon(THEME.save,  0, COLORS._main_icon_light, .75)
        	.setTooltip(__txt("panel_inspector_set_default", "Set as default")) ];
        
        global_layer_drawer = new Panel_Global_Layer_Drawer();
        globallayer_buttons = [ button(function() /*=>*/ {return dialogPanelCall(new Panel_Global_Layer())} )
        	.setIcon(THEME.text_popup, 1, COLORS._main_icon_light, .75)
        	.setTooltip(__txt("Pop-up")) ];
    	
        customPanel_buttons = [ button(function() /*=>*/ {
        	var _panelData = new Panel_Custom_Data();
        	array_push(PROJECT.customPanels, _panelData);
        	dialogPanelCall(new Panel_Custom_Editor(_panelData));
        	
    	}).setIcon(THEME.add_16,  0, COLORS._main_value_positive).setTooltip(__txt("New Custom Panel")) ];
    #endregion
    
    #region ---- Panel ---- 
    	panelData = {};
    	
    	panel_rename    = undefined;
    	panel_rename_tb = textBox_Text(function(t) /*=>*/ {
    		if(panel_rename == undefined) return;
    		panel_rename.name = t;
    		panel_rename = undefined;
    	});
    	
		_hovering_frame   = undefined; hovering_frame   = undefined;
		_hovering_scroll  = undefined; hovering_scroll  = undefined;
		_hovering_element = undefined; hovering_element = undefined;
    #endregion
    
    #region ---- Workshop ----
        workshop_uploading = 0;
    #endregion
    
    #region ---- History ----
    	inspect_history_undo = [];
    	inspect_history_redo = [];
    	
    #endregion
    
    #region ++++ Menus ++++
    	tSearch     = new tooltipHotkey(__txt("Search"), "Inspector", "Search Toggle");
    	tFilteranim = new tooltipHotkey(__txt("Filter Animated"), "", "Filter Animation");
    	
        static nodeExpandAll = function(node) {
            if(node.input_display_list == -1) return;
            
            var  dlist  = node.input_display_list;
            var _colMap = node.inspector_collapse;
            
            for( var i = 0, n = array_length(dlist); i < n; i++ ) {
                if(!is_array(dlist[i])) continue;
                
                var _key = array_safe_get_fast(dlist[i], 0, "");
                var ikey = _key + $"_{i}"
                
                dlist[i][@ 1]   = false;
                _colMap[$ ikey] = false;
            }
        }
        
        static nodeCollapseAll = function(node) {
            if(node.input_display_list == -1) return;
            
            var  dlist  = node.input_display_list;
            var _colMap = node.inspector_collapse;
            
            for( var i = 0, n = array_length(dlist); i < n; i++ ) {
                if(!is_array(dlist[i])) continue;
                
                var _key = array_safe_get_fast(dlist[i], 0, "");
                var ikey = _key + $"_{i}"
                
                dlist[i][@ 1]   = true;
                _colMap[$ ikey] = true;
            }
        }
        
        function section_expand_all() {
            if(inspecting != noone) nodeExpandAll(inspecting);
            for( var i = 0, n = array_length(inspectings); i < n; i++ ) 
                nodeExpandAll(inspectings[i]);
            contentPane.scroll_y_to = 0;
        }
        
        function section_collapse_all() {
            if(inspecting != noone) nodeCollapseAll(inspecting);
            for( var i = 0, n = array_length(inspectings); i < n; i++ ) 
                nodeCollapseAll(inspectings[i]);
            contentPane.scroll_y_to = 0;
        }
        
        function junction_reset()                { var d = __dialog_junction; if(d == noone) return; d.resetValue();                        }
        function junction_animation_toggle()     { var d = __dialog_junction; if(d == noone) return; d.setAnim(!d.is_anim, true);           }
        function junction_axis_toggle()          { var d = __dialog_junction; if(d == noone) return; d.sep_axis = !d.sep_axis;              }
        function junction_expression_toggle()    { var d = __dialog_junction; if(d == noone) return; d.expUse   = !d.expUse;                }
        function junction_extract_global()       { var d = __dialog_junction; if(d == noone) return; d.extractGlobal();                     }
        function junction_extract_single()       { var d = __dialog_junction; if(d == noone) return; d.extractNode();                       }
        function junction_visible_toggle()       { var d = __dialog_junction; if(d == noone) return; d.setVisibleManual(!d.visible_manual); }
        function junction_array_toggle()         { var d = __dialog_junction; if(d == noone) return; d.toggleArray();                       }
        function junction_mini_timeline_toggle() { var d = __dialog_junction; if(d == noone) return; d.inspector_timeline = !d.inspector_timeline; }
        
        function junction_bypass_toggle() { 
        	var d = __dialog_junction;
        	if(d == noone) return; 
            if(d.connect_type != CONNECT_TYPE.input) return;
        	
        	d.setBypass(!d.bypass_use);
            d.node.refreshNodeDisplay(); 
        }
        
        __dialog_junction = noone;
        function setSelectingItemColor(c) { 
            if(__dialog_junction == noone) return; 
            
            __dialog_junction.setColor(c);
            
            var _val_to = __dialog_junction.getJunctionTo();
            for( var i = 0, n = array_length(_val_to); i < n; i++ ) 
                _val_to[i].setColor(c);
        }
        
        MENUITEM_CONDITIONS[$ "inspector_value_separable"] = function() /*=>*/ {return prop_selecting && prop_selecting.sepable};
        
        global.menuItems_inspector_value_input = [
        	"inspector_group_set_color", 
        	-1, 
        	"inspector_animate_toggle",
        	{ cond  : "inspector_value_separable", items : [ "inspector_axis_toggle" ] },
        	"inspector_visible_toggle",
        	"inspector_bypass_toggle",
        	"inspector_expression_toggle", 
        	"inspector_toggle_array", 
        	"inspector_mini_timeline_toggle", 
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
    
    ////- Actions
    
    function clearInspecting() {
    	inspecting = noone;
    	contentPane.scroll_y_to = 0;
    }
    
    function setInspecting(_inspecting, _lock = false, _focus = true, _record = true) {
        if(locked) return;
        if(inspecting == _inspecting) return;
        if(_inspecting == noone) {
        	clearInspecting();
        	return;
        }
        
        if(_record) {
	        array_push(inspect_history_undo, inspecting);
	        inspect_history_redo = [];
        }
        
        inspecting = _inspecting;
        locked     = locked || _lock;
        focusable  = _focus;
        
        if(inspecting != noone) {
        	if(inspecting.onInspect) inspecting.onInspect();
        	contentPane.scroll_y_to = inspecting.inspector_scroll;
        	
        } else 
        	contentPane.scroll_y_to = 0;
        
    	contentPane.scrollReset();
        contentPane.scroll_y     = contentPane.scroll_y_to;
        contentPane.scroll_y_raw = contentPane.scroll_y_to;
        contentPane.scroll_wait  = 2;
            
        picker_index = 0;
    }
    
    function getInspecting() { return inspecting != noone && inspecting.active? inspecting : noone; }
    
    function onFocusBegin() { if(!focusable) return; PANEL_INSPECTOR = self; }
    
    function triggerInspectingNode(index = 1) {
    	__index = index;
    	array_foreach(inspectings, function(ins,i) /*=>*/ {return ins.triggerInsp(__index)});
    }
    
    ////- Property actions
    
    static highlightProp = function(prop) {
        prop_highlight      = prop;
        prop_highlight_time = 1;
    }
    
    function propSelectCopy()  { if(prop_selecting) clipboard_set_text(prop_selecting.getString()); }
    function propSelectPaste() { if(prop_selecting) prop_selecting.setString(clipboard_get_text()); }
    
    function propRightClick(jun, wdgt = false) {
    	if(!is(jun, NodeValue)) return noone;
    	
          prop_selecting  = jun;
        __dialog_junction = jun;
        
        if(jun.connect_type == CONNECT_TYPE.output) 
        	return menuCall("inspector_value_output", menuItems_gen("inspector_value_output"));
        
        var _menuItem = [];
        
        if(wdgt) {
    		var _widget = jun.getEditWidget();
        	if(_widget && !array_empty(_widget.context_menu)) {
        		for( var i = 0, n = array_length(_widget.context_menu); i < n; i++ )
        			_widget.context_menu[i].setColor(COLORS._main_accent)
        		
        		array_append(_menuItem, _widget.context_menu);
        		array_push(  _menuItem, -1);
        	}
        }
        
        array_append(_menuItem, menuItems_gen("inspector_value_input"));
        
        if(jun.connect_type == CONNECT_TYPE.input && jun.value_from != noone)
        	array_push(_menuItem, menuItem(__txt("Disconnect"), function() /*=>*/ {return __dialog_junction.removeFrom()}));
        
        if(jun.globalExtractable()) {
    		array_push(_menuItem, menuItemShelf(__txt("panel_inspector_use_global", "Use Globalvar"), function(_dat) /*=>*/ { 
    			var arr = [];
                for( var i = 0, n = array_length(PROJECT.globalNode.inputs); i < n; i++ ) {
            		var _glInp = PROJECT.globalNode.inputs[i];
            		if(!typeCompatible(_glInp.type, __dialog_junction.type)) continue;
            		
            		array_push(arr, menuItem(_glInp.name, function(d) /*=>*/ {return __dialog_junction.setExpression(d.name)})).setParam({ name : _glInp.name });
            	}
            	
            	array_push(arr, -1, menuItem(__txt("New Globalvar..."), function() /*=>*/ {
            		var tb = textboxCall("globalvar", function(txt) /*=>*/ {
            			if(txt == "") return;
            			
            			var _inp = PROJECT.globalNode.createValue(txt);
            			_inp.setType(__dialog_junction.type);
            			_inp.setDisplay(__dialog_junction.display_type, __dialog_junction.display_data);
            			_inp.refreshTypeIndex();
            			
            			__dialog_junction.setExpression(txt);
            		});
            	}, THEME.add));
            	
                return submenuCall(_dat, arr);
            }));
            
        	array_push(_menuItem, MENU_ITEMS.inspector_extract_global);
        }
        
        array_push(_menuItem, MENU_ITEMS.inspector_extract);
        
        if(jun.isAnimable() && !array_empty(jun.anim_presets)) {
        	array_push(_menuItem, -1);
        	array_push(_menuItem, MENU_ITEMS.inspector_quick_anim);
        }
        
        return menuCall("inspector_value_input", _menuItem);
    }
    
    ////- Draw Content
    
    contentPane = new scrollPane(content_w, content_h, function(_y, _m) { 
    	draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
        return inspecting == noone? drawContentMeta(_y, _m) : drawContentNode(_y, _m);
    }).setScrollUnclamp();
    
    function drawContent(panel) { 
    	var pad = ui(6);
    	draw_clear_alpha(COLORS.panel_bg_clear, 1);
        draw_sprite_stretched(THEME.ui_panel_bg, 1, pad, top_bar_h, w - pad * 2, h - top_bar_h - pad);
        
     //   if(inspecting) { // 
	    // 	var _colr = inspecting.getColor();
	    // 	COLORS._main_accent = _colr == -1 || _colr == c_white? COLOR_ACCENT : _colr;
    	// } else COLORS._main_accent = COLOR_ACCENT;
    	
        if(inspecting && !inspecting.active) clearInspecting();
        var mse = [mx,my];
        var pd = ui(8);
        var bs = ui(24);
        var bb = THEME.button_hide_fill;
        var tt = view_mode_tooltip;
        
        view_mode_tooltip.index = viewMode;
        var bx = pd;
        var by = pd + (bs + ui(2)) * 2;
        var b = buttonInstant_Pad(bb, bx, by, bs, bs, mse, pHOVER, pFOCUS, tt, THEME.inspector_view, viewMode,,, ui(6));
        if(b == 2) dialogPanelCall(new Panel_Inspector_View_Settings(), x - ui(8), y, { anchor: ANCHOR.top | ANCHOR.right });
        if(b == 1 && key_mod_press(SHIFT) && MOUSE_WHEEL != 0) { 
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
            
            if(is(inspecting, __Node_Cache))
            	inspecting.insp1button.icon_blend = PANEL_GRAPH.cache_group_edit == inspecting? COLORS._main_value_positive : COLORS._main_icon;
            
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
	            	var _stxt = __txt("View on Workshop") + "...";
	            	if(buttonInstant_Icon(sx0, ty, ui(10), mse, pHOVER, pFOCUS, _stxt, THEME.steam_invert_24, 0, .8) == 2)
	                	dialogPanelCall(new Panel_Steam_Workshop().navigate({ type: "fileid", fileid: PROJECT.meta.file_id }));
	            }
	            
	            if(buttonInstant_Icon(sx1, ty, ui(10), mse, pHOVER, pFOCUS, __txt("Rename"), THEME.rename, 0, .8) == 2) {
	            	textboxCall(txt, function(t) /*=>*/ {
	            		if(t == "") return;
	            		
	            		var _opth = PROJECT.path;
	            		var _dir = filename_dir(PROJECT.path);
	            		var _pth = filename_ext_verify(filename_combine(_dir, t), ".pxc");
	            		
	            		SAVE_AT(PROJECT, _pth);
	            		PROJECT.path = _pth;
	            		// file_delete_safe(_opth);
	            	});
	            }
            }
            
            var _scis = gpu_get_scissor();
            gpu_set_scissor(sx0 + ui(16), ty - ui(16), sx1 - sx0 - ui(32), ui(32));
            draw_text_add(tx, ty, txt, ss);
            gpu_set_scissor(_scis);
            
            var bb = THEME.button_hide_fill;
            var bx = w - ui(44);
            var by = ui(12);
            var bs = ui(32);
            var hov = pHOVER;
            var foc = pFOCUS;
            
            by += ui(36);
            if(STEAM_ENABLED && workshop_uploading == 0) {
                if(!sav) { // unsaved project
                	var _txt = __txt("panel_inspector_workshop_save", "Save file before upload");
                    buttonInstant(noone, bx, by, bs, bs, mse, hov, foc, _txt, THEME.workshop_upload, 0, c_white);
                    
                } else if(PROJECT.meta.file_id == 0) { // project made locally
                    var s = PANEL_PREVIEW.getNodePreviewSurface();
                    if(!is_surface(s)) {
                    	var _txt = __txt("panel_inspector_workshop_no_thumbnail", "Send node to preview to be use as project thumbnail before uploading.");
                    	buttonInstant(bb, bx, by, bs, bs, mse, hov, foc, _txt, THEME.workshop_no_file, 0, c_white);
                    	
                    } else {
	                	var _txt = __txt("panel_inspector_workshop_upload", "Upload to Steam Workshop");
	                	var b = buttonInstant(bb, bx, by, bs, bs, mse, hov, foc, _txt, THEME.workshop_upload, 0, c_white);
	                    if(b == 2) {
                            steam_ugc_create_project();
                            workshop_uploading = 2;
                            
                    	} else if(b == 3) {
                    		menuCall("", [
                    			menuItem("Upload to Steam Workshop",   function() /*=>*/ { 
                    				steam_ugc_create_project(); 
                    				workshop_uploading = 2; 
                    			}),
                    				
                    			menuItem("Override Steam Workshop...", function() /*=>*/ { 
                    				dialogPanelCall(new Panel_Steam_Workshop_Selector(function(_f) /*=>*/ {
                    					workshop_uploading = 2; 
                    					
                    					var _fid = _f.file_id;
                    					PROJECT.meta.file_id         = _fid;
                    					PROJECT.meta.author_steam_id = STEAM_USER_ID;
                    					
                    					steam_ugc_update_project(false, "Overrided");
                    				}));
                				}),
                			]);
                    	}
                    }
                    
                } else if(PROJECT.meta.author_steam_id == STEAM_USER_ID) { // user-owned steam project
                	var _txt = __txt("panel_inspector_workshop_upload_new", "Upload as a new Steam Workshop submission");
                    if(buttonInstant(bb, bx, by - ui(36), bs, bs, mse, hov, foc, _txt, THEME.workshop_add, 0, c_white) == 2) {
                        steam_ugc_create_project();
                        workshop_uploading = 1;
                	}
                	
                	var _txt = __txt("panel_inspector_workshop_update",  "Update Steam Workshop content");
                	if(buttonInstant(bb, bx, by, bs, bs, mse, hov, foc, _txt, THEME.workshop_update, 0, c_white) == 2)
                        dialogCall(o_dialog_steam_project_update, mouse_mx + 8, mouse_my + 8).activate("Update note");
                }
            }
            
            if(workshop_uploading) {
            	var _by = ui(12) + (workshop_uploading - 1) * ui(36);
                draw_sprite_ui_uniform(THEME.loading_s, 0, bx + ui(16), _by + ui(16), 1, COLORS._main_icon, 1, current_time / 5);
                if(STEAM_UGC_UPLOADING == false)
                    workshop_uploading = 0;
            }
        }
        
        content_w = w - pad * 4;
        content_h = h - top_bar_h - pad * 3;
        
        contentPane.verify(content_w, content_h);
        contentPane.setFocusHover(pFOCUS, pHOVER);
        contentPane.drawOffset(pad * 2, top_bar_h + pad, mx, my);
        
        if(prop_hover != noone) {
        	_HIGHLIGHT_PROP = prop_hover;
        	ds_stack_push(FOCUS_STACK, "Property");
        }
        
        /// focus 
        var _foc = PANEL_GRAPH.getFocusingNode();
        if(!locked && _foc && inspecting != _foc) setInspecting(_foc);
    }
    
    ////- DRAW NODE
    
    __chainItemConnect = undefined;
    
    static drawNodeProperties = function(_x, _y, _w, _m, _inspecting = inspecting, _flag = INSPECTOR_FLAG.show_all, _blend = c_white) { 
    	if(!is(_inspecting, Node)) return 0;
    	
        var _hover   = pHOVER && contentPane.hover;
        var _focus   = pFOCUS || PANEL_GRAPH.pFOCUS;
        var nodeName = instanceof(_inspecting);
        
    	var hh = 0;
    	
		var _tre = _inspecting.treeItem;
    	if(_flag == INSPECTOR_FLAG.show_all && PREFERENCES.inspector_show_node_chain && _tre != undefined && _tre.nodeChain != undefined) {
    		var _cha = _tre.nodeChain;
    		
    		var _lbh = ui(22);
    		var _amo = array_length(_cha);
    		var _thh = _lbh * _amo;
    		
    		if(_amo > 0) {
	    		draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x, _y, _w, _thh, COLORS._main_icon_dark, 1);
	    		draw_sprite_stretched_add(THEME.box_r5,     1, _x, _y, _w, _thh, c_white, .1);
    		}
    		
			var toInspect        = undefined;
			var toInspectPreview = false;
    		
    		for( var i = 0; i < _amo; i++ ) {
    			var _cx = _x + ui(4);
    			var _cy = _y + i * _lbh;
    			
    			var _chainItem = _cha[i];
    			var _chainNode = _chainItem.node;
    			var _curr = _chainNode == _inspecting;
    			
    			var _nodeActive = _chainNode.active_index == -1 || _chainNode.active_value;
    			
    			var _prx = _cx;
    			var _pry = _cy  + ui(2);
    			var _prs = _lbh - ui(4);
    			
    			var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _cy, _x + _w, _cy + _lbh);
    			
    			if(_hov) draw_sprite_stretched_add(THEME.box_r5_clr, 0, _x, _cy, _w, _lbh, COLORS.section_hover, .5);
    			
    			var _prev = _chainNode.getGraphPreviewSurface();
				if(is_surface(_prev)) {
					var _sw = surface_get_width(_prev);
					var _sh = surface_get_height(_prev);
					var _ss = _prs / max(_sw, _sh);
					
					draw_surface_ext(_prev, _prx + _prs/2 - _sw*_ss/2, _pry + _prs/2 - _sh*_ss/2, _ss, _ss, 0, c_white, 1);
				}
				
				var _name = _chainNode.getDisplayName();
				var  tc   = _curr? COLORS._main_text_accent : (_hov? COLORS._main_text : COLORS._main_text_sub);
				var  tx   = _cx + _prs + ui(4);
				var  ty   = _cy + _lbh / 2;
				
				draw_set_text(f_p4, fa_left, fa_center, tc);
				draw_text_add(tx, ty, _name);
				if(!_nodeActive) draw_line(tx - ui(2), ty, tx + string_width(_name) + ui(2), ty)
				
				if(_chainNode.active_index > -1) {
					var _as = _prs;
					var _ax = _x + _w - ui(2) - _as;
					var _ay = _cy + _lbh / 2 - _as / 2;
					
					var _asp = THEME.circle_toggle_8;
					var _asi = _chainNode.active_value;
					var b = buttonInstant(THEME.button_hide, _ax, _ay, _as, _as, _m, _hover, _focus, "", _asp, _asi,, .8);
					if(b) _hov = false;
					if(b == 2) _chainNode.inputs[_chainNode.active_index].setValue(!_asi);
				}
				
				if(_hov) {
					if(mouse_lpress(_focus)) {
						toInspect = _chainNode;
						toInspectPreview = DOUBLE_CLICK;
					}
					
					if(mouse_rpress(_focus)) {
						__chainItemConnect = _chainItem;
						
						var _menu = [
							menuItem(__txt("Add Node..."), function(_insp) /*=>*/ {
								var dx  = mouse_mx + 8;
								var dy  = mouse_my + 8;
								var dia = instance_create_depth(dx, dy, 0, o_dialog_add_node, { context: _insp.group });
								
								if(dia) dia.buildCallback = function(newNode) /*=>*/ {
									var _node = __chainItemConnect.node;
									if(!is(_node, Node)) return;
									
									newNode.x = _node.x + _node.w + 32;
									newNode.y = _node.y;
									
									var _inp = newNode.getInput();
									var _out = _node.outputs[0];
									_inp.setFrom(_out);
									
									var _par = __chainItemConnect.parent;
									if(_par != noone) {
										var _pnode = _par.node;
										var _otp   = newNode.getOutput();
										
										if(_otp)
										for( var i = 0, n = array_length(_pnode.inputs); i < n; i++ ) {
											var _inpp = _pnode.inputs[i];
											if(_inpp.value_from != noone) {
												_inpp.setFrom(_otp);
												break;
											}
										}
									}
									
									panelFocusNode(newNode, false);
								}
								
							}).setParam(_inspecting), 
							
							menuItem(__txt("Delete Node"), function(_insp) /*=>*/ { 
								var _node = __chainItemConnect.node;
								if(!is(_node, Node)) return;
								
								_node.destroy(true); 
								if(_node == _insp) {
									var _newInsp = noone;
									
									if(_newInsp == noone && __chainItemConnect.parent != noone)
										_newInsp = __chainItemConnect.parent.node;
									
									var _child = array_safe_get(__chainItemConnect.children, 0);
									if(_newInsp == noone && is(_child, NodeTreeItem))
										_newInsp = _child.node;
									
									if(_newInsp) panelFocusNode(_newInsp);
								}
								
							}, THEME.cross).setParam(_inspecting),
						];
						
						menuCall("inspector_node_chain_node", _menu);
					}
				}
    		}
    		
    		if(toInspect) run_in(1, function(i,p) /*=>*/ {return panelFocusNode(i,p)}, [toInspect, toInspectPreview]);
    		
    		if(_amo > 0) 
    			hh += _thh + ui(4);
    	}
    	
    	if(is(_inspecting.inline_context, Node_Collection_Inline)) {
    		var _inl = _inspecting.inline_context;
    		var _col = _inl.getColor();
    		var _lbh = ui(22);
    		
			var _inh = _inl.group_height ?? 0;
    		if(inline_expands) {
	    		if(_inh) draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x, _y, _w, _inh + _lbh + ui(10), _col, .5);
	    		
	    		var _h = drawNodeProperties(_x + ui(8), _y + _lbh + ui(8), _w - ui(16), _m, _inl, INSPECTOR_FLAG.input_only, _col);
	    		_inl.group_height = _h;
	    		hh += _h + ui(14);
    		}
    		
    		var _name = _inl.getDisplayName();
    		draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x, _y, _w, _lbh, _col, 1);
    		draw_sprite_stretched_add(THEME.box_r5, 1, _x, _y, _w, _lbh, c_white, .1);
    		draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
    		draw_text_add(_x + ui(24), _y + _lbh/2, _name);
    		
    		var _ic = _inl.icon == noone? THEME.arrow : _inl.icon;
    		draw_sprite_ui(_ic, inline_expands * 3, _x + ui(12), _y + _lbh / 2, 1, 1, 0, _col);
    		if(inline_expands && _inh) draw_sprite_stretched_add(THEME.box_r5, 1, _x, _y, _w, _inh + _lbh + ui(10), c_white, .2);
    		
    		var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _lbh);
    		if(_hov) {
    			draw_sprite_stretched_add(THEME.box_r5, 1, _x, _y, _w, _lbh, c_white, .2);
    			if(mouse_lpress(_focus)) inline_expands = !inline_expands;
    		}
    		
    		hh += _lbh + ui(4);
    	}
    	
    	if(_inspecting.instanceBase) {
    		var _lbh = ui(24);
    		
    		draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _x, _y, _w, _lbh, COLORS._main_accent, 1);
    		draw_sprite_stretched_add(THEME.box_r5, 1, _x, _y, _w, _lbh, c_white, .1);
    		draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
    		
    		var _txt = $"{__txt("Instance of")}: {_inspecting.instanceBase.getDisplayName()}";
    		
    		draw_sprite_ui(THEME.node_instance_icon, 0, _x + _lbh/2, _y + _lbh/2, 1, 1, 0, c_white, 1);
    		draw_text_add(_x + _lbh, _y + _lbh/2, _txt);
    		
    		var bs = _lbh;
    		var bx = _x + _w - bs;
    		var by = _y;
    		
    		if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, _hover, _focus, __txt("Uninstance"), THEME.node_instance_remove, 0, c_white, .8, ui(6)) == 2) 
    			_inspecting.setInstance();
    		
    		var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w - bs, _y + _lbh);
    		if(_hov) {
    			draw_sprite_stretched_add(THEME.box_r5, 1, _x, _y, _w, _lbh, c_white, .2);
    			if(mouse_lpress(_focus)) panelFocusNode(_inspecting.instanceBase);
    		}
    		
    		hh += _lbh + ui(4)
    	}
    	
        var con_w   = _w 
        var con_h   = contentPane.surface_h;
        
        var _viewSpac = viewMode == INSP_VIEW_MODE.spacious;
        var _font     = _viewSpac? f_p2 : f_p3;
        var xc        = con_w / 2;
        
        var amoIn   = is_array(_inspecting.input_display_list)?  array_length(_inspecting.input_display_list)  : array_length(_inspecting.inputs);
        var amoAttr = array_length(_inspecting.attributes_properties);
        
        var amoOut  = is_array(_inspecting.output_display_list)? array_length(_inspecting.output_display_list) : array_length(_inspecting.outputs);
        var amoMeta = _inspecting.attributes.outp_meta? array_length(_inspecting.junc_meta) : 0;
        
        var amo     = inspectGroup == 0? amoIn + amoAttr + 1 + amoOut + amoMeta : amoIn + amoAttr;
        if(_flag == INSPECTOR_FLAG.input_only) amo = amoIn;
        
        var jun     = noone;
        
        var _colMap = _inspecting.inspector_collapse;
        var _edtMap = _inspecting.inspector_edited;
        var _aniMap = _inspecting.inspector_animated;
        var currSec = "";
        var _cAll   = 0;
        
        var con_ww  = con_w - ui(12);
        var padd    = ui(THEME_VALUE.panel_inspector_prop_paddding);
        var rrx     = x + contentPane.x;
        var rry     = y + contentPane.y;
        
        var showAll = filtering || FILTER_ANIMATION;
        var showHig = false;
        
        var secFnt = _viewSpac? f_p1 : f_p3;
        var segHei = _viewSpac? ui(26) : ui(22);
        var segPad = _viewSpac? ui(8) : ui(4);
        
        var defPreset = PRESETS_MAP[$ nodeName];
        
        for( var i = 0, n = array_length(_inspecting.inputs); i < n; i++ ) 
        	_inspecting.inputs[i].visible_in_inspector = false;
        
        ////- =Draw Properties
        
        for(var i = 0; i < amo; i++) {
            var yy    = _y + hh;
            var _draw = yy + ui(8) < con_h && yy > -ui(8);
            
            if(i < amoIn) { // inputs
                var _dsl = _inspecting.input_display_list;
                var _dsp = array_safe_get_fast(_dsl, i);
                
                     if(!is_array(_dsl))  jun = array_safe_get_fast(_inspecting.inputs, i);
                else if(is_real(_dsp))    jun = array_safe_get_fast(_inspecting.inputs, _dsp);
                else                      jun = _dsp;
                
            } else if(i <  amoIn + amoAttr) { // attributes
            	jun = _inspecting.attributes_properties[i - amoIn];
            	
            } else if(i == amoIn + amoAttr) { // output label
                hh += ui(8 + 32 + 8);
                
                draw_sprite_stretched_ext(THEME.box_r5_clr, 0, 0, yy + ui(8), con_w, ui(32), COLORS.panel_inspector_output_label, 0.8);
                draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
                draw_text_add(xc, yy + ui(8 + 16), __txt("Outputs"));
                continue;
            
            } else if(i <  amoIn + amoAttr + 1 + amoOut) { // outputs
                var _oi = i - (amoIn + amoAttr + 1);
                var _dsl = _inspecting.output_display_list;
                var _dsp = array_safe_get_fast(_dsl, _oi);
                
                     if(!is_array(_dsl)) jun = array_safe_get_fast(_inspecting.outputs, _oi);
                else if(is_real(_dsp))   jun = array_safe_get_fast(_inspecting.outputs, _dsp);
                else                     jun = _dsp;
                
            } else { // metadata
                jun = _inspecting.junc_meta[i - (amoIn + amoAttr + 1 + amoOut)];
            }
            
            if(is_handle(jun)) {
            	if((filtering && filter_text != "") || FILTER_ANIMATION) continue;
                
            	if(_flag == INSPECTOR_FLAG.input_only) continue;
            	
            	var _type = asset_get_type(jun);
            	if(_type == asset_sprite) {
	                draw_sprite(jun, 0, xc, yy);
	                hh += sprite_get_height(jun) + padd;
	                continue;	
            	}
            	
            } else if(is(jun, Inspector_Spacer)) {                    // SPACER
            	if((filtering && filter_text != "") || FILTER_ANIMATION) continue;
                
            	if(!jun.active) continue;
                var _hh = ui(jun.h);
                var _yy = yy + _hh / 2 - jun.lshf;
                
                if(jun.line) {
                    draw_set_color(COLORS.panel_inspector_key_separator);
                    draw_line(ui(8), _yy, con_w - ui(8), _yy);
                }
                
                hh += _hh;
                continue;
                
            } else if(is(jun, Inspector_Label)) {            // TEXT
            	if((filtering && filter_text != "") || FILTER_ANIMATION) continue;
                
                var _txt = jun.text;
                if(_txt == "") continue;
                
                draw_set_text(jun.font, fa_left, fa_top, COLORS._main_text_sub);
                var _sh = string_height_ext(_txt, -1, con_w - ui(16)) + ui(16);
                draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, yy, con_w, _sh, COLORS._main_icon_light);
                draw_text_ext_add(ui(8), yy + ui(8), _txt, -1, con_w - ui(16));
                
                hh += _sh + padd;
                continue;
                
            } else if(is(jun, Inspector_Custom_Renderer)) {
                if((filtering && filter_text != "") || FILTER_ANIMATION) continue;
                
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
                
                var widX = ui(6);
                var widY = yy;
                var widW = con_w - ui(12);
                
                if(jun.padName && widgPrevX && widgPrevW) {
                	widX = widgPrevX;
					widW = widgPrevW;
					
					var nx = widgNameX;
					var ny = yy + ui(4);
					
					draw_set_text(_font, fa_left, fa_top, COLORS._main_text);
					draw_text_add(nx, ny, jun.name);
                }
                
                jun.setInteract(true);
                jun.setFocusHover(_hover, pFOCUS);
                
                var _wdh = jun.draw(widX, widY, widW, _m, _hover, pFOCUS, self);
                if(_wdh > 0) _wdh += ui(8);
                hh += _wdh;
                continue;
              
            } else if(is(jun, Inspector_Sprite)) {
            	var _spr = jun.getSpr();
            	if(!sprite_exists(_spr)) continue;
            	
            	var sprW = sprite_get_width(_spr);
            	var sprH = sprite_get_height(_spr);
            	
            	draw_sprite(_spr, 0, xc - sprW / 2, yy);
                hh += sprH + padd;
                continue;	
            	
            } else if(is(jun, widget)) {
            	if((filtering && filter_text != "") || FILTER_ANIMATION) continue;
            	if(!jun.visible) continue;
            	
                var param = new widgetParam(ui(6), yy, con_w - ui(12), TEXTBOX_HEIGHT, noone, undefined, _m, x, y)
                	.setFont(_font);
                	
                jun.setFocusHover(pFOCUS, pHOVER);
                var _wdh = jun.drawParam(param);
                if(!is_undefined(_wdh)) hh += _wdh + padd;
                continue;
                
            } else if(is_array(jun)) { // Section
                if((filtering && filter_text != "") || FILTER_ANIMATION) continue;
                
                var _key = array_safe_get_fast(jun, 0, "");
                var _keyJunc = is_real(_key);
                
                var coll;
                
                if(_keyJunc) {
                	var kjun = array_safe_get_fast(_inspecting.inputs, _key);
                	kjun.isSection = true;
                	if(kjun.sectionCollapse == undefined)
                		kjun.sectionCollapse = array_safe_get_fast(jun, 1, false);
                		
                	coll = kjun.sectionCollapse;
                	_key = kjun.getName();
                	
                } else {
	                var ikey = _key + $"_{i}"
	                var subk = string_starts_with(_key, "/");
	                var name = __txt(subk? string_trim_start(_key, ["/"]) : _key);
	                
	                if(!subk) currSec = ikey;
	                
	                coll = _colMap[$ ikey] ?? array_safe_get_fast(jun, 1, false);
	                var togl = array_safe_get_fast(jun, 2, noone);
	                var righ = array_safe_get_fast(jun, 3, noone);
	                
	                if(subk) {
	                	var lbw = con_w  - ui(2) - (togl != noone) * (segHei) - (righ != noone) * ui(24);
		                var lbx = _x     + ui(2) + (togl != noone) * (segHei);
		                var lbh = segHei - ui(6);
		                
	                } else {
	                	var lbw = con_w - (togl != noone) * (segHei + segPad) - (righ != noone) * ui(32);
		                var lbx = _x    + (togl != noone) * (segHei + segPad);
		                var lbh = segHei;
	                }
		                
	                #region Draw Base 
		                var hov = _hover && point_in_rectangle(_m[0], _m[1], lbx, yy, lbx + lbw, yy + lbh);
	                	var scw = con_w - lbx;
		                
		                if(!subk) {
		                	var scc = hov? COLORS.section_hover : COLORS.section_bg;
		                	
			                          draw_sprite_stretched_ext(THEME.section_separator, 0, lbx, yy, scw, lbh, colorMultiply(_blend, scc));
			                if(!coll) draw_sprite_stretched_ext(THEME.section_separator, 2, lbx, yy, scw, lbh, colorMultiply(_blend, COLORS.section_selected));
			                if(hov)   draw_sprite_stretched_ext(THEME.section_separator, 1, lbx, yy, scw, lbh, colorMultiply(_blend, COLORS.section_hover));
		                }
		                
		                if(hov) {
		                    contentPane.hover_content = true;
		                	
		                	if(pFOCUS) {
								if(DOUBLE_CLICK && !subk) _cAll = jun[@ 1]? -1 : 1;
								else if(mouse_lpress()) { 
									if(key_mod_press(CTRL)) {
										_cAll = jun[@ 1]? 1 : -1;
										
									} else {
				                       	jun[@ 1] = !coll; 
				                       	coll = !coll; 
									}
			                       	
								} else if(mouse_rpress(pFOCUS)) {
									var _menu = [
							            MENU_ITEMS.inspector_expand_all_sections,
							            MENU_ITEMS.inspector_collapse_all_sections,
							            menuItem(__txt("Collapse Other"), function(m) /*=>*/ {
							            	if(inspecting == noone) return;
							            	var cmap = inspecting.inspector_collapse;
							            	var carr = struct_get_names(cmap);
								            
								            for( var i = 0, n = array_length(carr); i < n; i++ ) 
								                cmap[$ carr[i]] = true;
								            cmap[$ m] = false;
								            
							            }).setParam(ikey)
							        ];
							        
									menuCall("inspector_group_menu", _menu, 0, 0, fa_left);
								}
		                	}
		                }
		                
		                if(!showAll) {
		                	var _anim = _aniMap[$ currSec] ?? false;
		                	var cc = !subk && _anim? COLORS._main_value_positive : COLORS._main_icon;
		                	var ss = subk? .8 : 1;
		                	
		                	draw_sprite_ui(THEME.arrow, !coll * 3, lbx + ui(16 + subk * 2), yy + lbh / 2, ss, ss, 0, cc, 1);
		                }
		                
		                _colMap[$ ikey] = coll;
		        	#endregion
	                
	                #region Draw Right Buttons
		                if(righ != noone) {
		                    var _bx = lbx + lbw;
		                    var _by = yy;
		                    var _bw = ui(32);
		                    var _bh = lbh;
		                    
		                    righ.setFocusHover(pFOCUS, pHOVER);
		                    righ.draw(_bx + ui(2), _by + ui(2), _bw - ui(4), _bh - ui(4), _m, THEME.button_hide_fill);
		                }
	                #endregion
	                
	                #region Draw Toggle button
		                var cc, aa = 1;
		                
		                if(togl != noone) {
			                var toging = togl != noone? _inspecting.getInputData(togl) : false;
			                if(is_array(toging)) toging = false;
		                
		                	var tgx = _x + subk * ui(6);
		                	var tgy = yy;
		                	var tgp = subk? ui(3) : ui(4);
		                
		                	var jun   = _inspecting.inputs[togl];
		                	var tgHov = _hover && point_in_rectangle(_m[0], _m[1], tgx, tgy, tgx + lbh, tgy + lbh);
		                	
		                    draw_sprite_stretched_ext(THEME.section_separator, 0, tgx, tgy, lbh, lbh, hov? COLORS.section_hover : COLORS.section_bg);
		                    if(tgHov) {
		                        draw_sprite_stretched_ext(THEME.section_separator, 1, tgx, tgy, lbh, lbh, COLORS.section_hover);
		                        contentPane.hover_content = true;
		                    	hov = false;
		                        
		                        if(mouse_lpress(pFOCUS)) jun.setValue(!toging);
		                        if(mouse_rpress(pFOCUS)) propRightClick(jun);
		                    }
		                    
		                    cc = toging? COLORS._main_accent : COLORS.section_bg;
		                    aa = 0.5 + toging * 0.5;
		                    
		                               draw_sprite_stretched_ext(THEME.box_r2, 1, tgx + tgp, tgy + tgp, lbh - tgp*2, lbh - tgp*2, cc, 1);
		                    if(toging) draw_sprite_stretched_ext(THEME.box_r2, 0, tgx + tgp, tgy + tgp, lbh - tgp*2, lbh - tgp*2, cc, 1);
		                }
		            #endregion
		            
		            #region Draw Name
		                var ltx = lbx + ui(32);
		                var txy = yy + lbh / 2;
		                
		                draw_set_text(secFnt, fa_left, fa_center, COLORS._main_text, aa * (subk? .8 : 1));
		                draw_text_add(ltx, txy, name);
		                draw_set_alpha(1);
		                
		                var txw = string_width(name);
		                if(subk) {
		                	draw_set_color_alpha(hov? COLORS._main_text : COLORS._main_text_sub, .75 + hov * .1);
		                	draw_line_width(ltx + txw + ui(8), txy, con_ww, txy, 1);
		                	draw_set_alpha(1);
		                }
		        	#endregion
	                
	                #region Section stat [edit counts, animations]
	                	if(!subk) {
			                var edt = _edtMap[$ ikey] ?? 0;
			                if(edt > 0) {
			                	draw_set_color(COLORS._main_text_sub);
			                	draw_text_add(ltx + txw + ui(4), txy, $"[{edt}*]");
			                }
			                
			                _edtMap[$ ikey] = 0;
			                _aniMap[$ ikey] = false;
	                	}
		        	#endregion
	                
	                hh += lbh + padd;
                }
                
                if(!showAll && coll) { // Skip 
                    if(i == amoIn) { // Skip attribute
                    	i = amoIn + amoAttr - 1;
                    	
                    } else {
	                    var j    = i + 1;
	                    var _edt = subk? (_edtMap[$ currSec] ?? 0) : 0;
	                    var _ani = subk? (_aniMap[$ currSec] ?? 0) : 0;
	                    
	                    while(j < amoIn) {
	                        var j_jun = array_safe_get_fast(_inspecting.input_display_list, j, noone);
	                        if(j_jun == noone) break;
	                        
	                        if(is_array(j_jun)) {
	                        	if(subk) break;
	                        	
	                        	var _jkey = array_safe_get_fast(j_jun, 0, "");
	                        	var _jkJn = is_real(_jkey);
	                        	var _subk = string_starts_with(_jkey, "/");
	                        	if(!_subk && !_jkJn) break;
	                        	
	                        	else { j++; continue; }
	                        }
	                        
	                        if(is(j_jun, Inspector_Spacer) && !j_jun.coll) break;
	                        
	                        jun = array_safe_get_fast(_inspecting.inputs, j_jun)
	                        if(is(jun, NodeValue) && jun.show_in_inspector) {
	                        	_edt += jun.is_modified;
	                        	_ani |= jun.is_anim;
	                        }
	                        
	                        j++;
	                    }
	                    
	                    i = j - 1;
	                    _edtMap[$ currSec] = _edt;
	                    _aniMap[$ currSec] = _ani;
                    }
                } // Skip 
                
                if(_keyJunc) jun = kjun;
                else continue;
            }
        	
        	if(is(jun, attribute_property)) {
        		if(filtering && filter_text != "" || FILTER_ANIMATION) continue;
        		if(filtering && filter_text != "" && !string_match_lower(filter_text, jun.name)) continue;
        		
        		var _name = jun.name;
        		var _key  = jun.key;
				var _val  = jun.getter();
				var _wdgt = jun.editWidget;
				
				var bs    = ui(15 + viewMode * 5);
				var lb_h  = line_get_height(_font, 4 + viewMode * 2);
				var lb_y  = yy + lb_h / 2;
				var padx  = ui(16);
				
				draw_set_text(_font, fa_left, fa_center, COLORS._main_text);
				draw_text_add(_x + padx, lb_y, _name);
				var ds_w = padx + string_width(_name);
		
				var labelWidth = max(ds_w, min(con_ww * 0.4, ui(200)));
				var editBoxX   = _x + ui(16) + labelWidth;
				var editBoxY   = yy;
				var editBoxW   = con_ww - labelWidth - ui(4);
				var editBoxH   = lb_h;
				
				#region Default
					var bb = THEME.button_hide_fill;
					var bx = editBoxX + editBoxW - bs;
					var by = editBoxY + editBoxH / 2. - bs / 2;
					
					var _hasDef = defPreset && has(defPreset, "_values") 
					                        && has(defPreset._values.content, "attr") 
					                        && has(defPreset._values.content.attr, _key);
					
					var ics = _viewSpac? .9 : .75;
					var bs  = _viewSpac? ui(20) : ui(15);
					var ba  = .25 + _hasDef * .5;
					var cc  = _hasDef? COLORS._main_accent : COLORS._main_icon_light;
					var bt  = __txt("panel_inspector_default", "Set default");
					
					b = buttonInstant(bb, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.icon_default, 0, cc, ba, ics); 
					
					if(b == 2) _inspecting.setDefaultAttr(_key);
					if(b == 3) menuCall("", [ new MenuItem(__txt("Reset Default"), function(k) /*=>*/ {return k[0].removeDefaultAttr(k[1])}).setParam([_inspecting, _key]) ]);
					
					bx -= ui(4);
					editBoxW -= bs + ui(4);
				#endregion
				
				#region Reset
					bx -= bs;
					var bt = __txt("panel_inspector_reset", "Reset");
					var ba = .8;
					var cc = COLORS._main_icon_light;
					b = buttonInstant(bb, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.refresh_16, 0, cc, ba, ics); 
					
					if(b == 2) _inspecting.resetDefaultAttr(_key);
					
					bx -= ui(4);
					editBoxW -= bs + ui(4);
				#endregion
				
                var param = new widgetParam(editBoxX, editBoxY, editBoxW, editBoxH, _val, undefined, _m, rrx, rry)
                	.setFont(_font);
                	
            	_wdgt.setFocusHover(_focus, _hover);
				var _widH = _wdgt.drawParam(param) ?? 0;
				hh += _widH + padd;
        		continue;
        	}
        	
            if(!is(jun, NodeValue))    continue;
            if(!jun.show_in_inspector) continue;
            
            if(currSec != "") {
            	_edtMap[$ currSec] += jun.is_modified;
            	_aniMap[$ currSec] |= jun.is_anim;
            }
            
            if(FILTER_ANIMATION && !jun.isAnimated()) continue;
            if(filtering && filter_text != "" && !string_match_lower(filter_text, jun.getName())) continue;
            
            #region ++++ Draw Widget ++++
            	var _wdgt = jun.getEditWidget();
            	if(jun.latest_height != undefined)
            		_draw = yy + ui(8) < con_h && yy + jun.latest_height > -ui(8);
            	
                var widg    = _draw? drawWidget(   _x + ui(8), yy, con_ww, _m, jun, 0, _hover, _focus, contentPane, rrx, rry, undefined, _blend ) : 
                                     fetchWidgetH( _x + ui(8), yy, con_ww, _m, jun, 0, _hover, _focus, contentPane, rrx, rry, undefined, _blend );
                var widH    = widg[0];
                var mbRight = widg[1];
                var widHov  = widg[2];
                var lbHov   = widg[3];
                var lb_x    = widg[4];
                
                jun.latest_height = widH;
                
                if(widHov || lbHov) contentPane.hover_content = true;
                hh += widH + padd;
                
                if(jun == prop_highlight && prop_highlight_time > 0) {
                    contentPane.setScroll(_y - yy);
                    var aa  = min(1, prop_highlight_time * 2);
                    var hgp = max(0, prop_highlight_time * 8 - 7) * ui(4);
                    
                    var hgx = _x + ui(4)     - hgp;
                    var hgy = yy             - hgp;
                    var hgw = con_w - ui(4)  + hgp * 2;
                    var hgh = widH           + hgp * 2;
                    
                    draw_sprite_stretched_add(THEME.ui_panel, 2, hgx, hgy, hgw, hgh, COLORS._main_accent, aa);
                }
                
                if(_hover && lbHov && prop_dragging == noone && mouse_lpress(pFOCUS)) {
                    prop_dragging = jun;
                        
                    prop_sel_drag_x = mouse_mx;
                    prop_sel_drag_y = mouse_my;
                }
                
                if(lbHov && DOUBLE_CLICK) {
                	renaming = jun;
					tb_rename.activate(jun.getName());
                }
                
                if(renaming == jun) {
                	var pdx = ui(12 + 4 * viewMode);
                	var wdx = lb_x - pdx / 2;
                	var wdy = yy;
                	
                	var wdw = con_ww * .4;
                	var wdh = line_get_height(_font, 4 + viewMode * 2);
                	
                	tb_rename.setFocusHover(_focus, _hover);
                	tb_rename.drawParam(new widgetParam(wdx, wdy, wdw, wdh, jun.getName(), undefined, _m).setFont(_font));
                }
            #endregion
            
            // Selection highlight
            if(_wdgt && _wdgt.temp_hovering) {
            	showHig = true;
            	prop_selecting_y_to = yy - _y;
            	prop_selecting_h_to = widH;
            	_wdgt.temp_hovering = false;
            }
            
            // Mouse interaction
            var wdx = _x + ui(4);
            var wdy = yy;
            var wdw = con_w - ui(8);
            var wdh = widH;
            
            if(_hover && point_in_rectangle(_m[0], _m[1], _x, yy, _x + con_w, yy + widH)) {
                _HOVERING_ELEMENT = jun;
                
                var hov = PANEL_GRAPH.value_dragging != noone 
                	|| (NODE_DROPPER_TARGET != noone && NODE_DROPPER_TARGET != jun)
                	|| DRAGGING != noone;
                
                if(hov) {
                    draw_sprite_stretched_ext(THEME.ui_panel, 1, wdx, wdy, wdw, wdh, COLORS._main_value_positive, 1);
                    
                    if(NODE_DROPPER_TARGET_CAN && mouse_lpress()) {
                        NODE_DROPPER_TARGET.expression += $"{jun.node.internalName}.{jun.connect_type == CONNECT_TYPE.input? "inputs" : "outputs"}.{jun.internalName}";
                        NODE_DROPPER_TARGET.expressionUpdate(); 
                    }
                    
                    if(mouse_lrelease() && DRAGGING != noone) {
                    	if(DRAGGING.type == "Globalvar")
                    		jun.setExpression(DRAGGING.data);
                    	else {
	                    	var _from = DRAGGING[$ "from"];
	                    	if(is(_from, NodeValue) && jun != _from) {
	                    		var _exp = jun != _from? $"self.{_from.internalName}" : "value";
	                    		jun.setExpression(jun.expression == ""? _exp : jun.expression + "\n" + _exp);
	                    	}
                    	}
                    }
                    
                } else {
                	showHig = true;
                	prop_selecting_y_to = wdy - _y;
                	prop_selecting_h_to = wdh;
                }
                
                prop_hover = jun;
                    
                if(mouse_lpress(pFOCUS))
                    prop_selecting = jun;
                        
                if(mouse_rpress(pFOCUS && mbRight))
                    propRightClick(jun, widHov);
            } 
            
            if(HIGHLIGHT_PROP == jun) {
            	showHig = true;
            	prop_selecting_y_to = wdy - _y;
            	prop_selecting_h_to = wdh;
            }
            
            // Mini timeline
            if(jun.inspector_timeline) {
            	var _tlx = _x + ui(4);
            	var _tly = _y + hh;
            	var _tlw = con_w - ui(8);
            	var _tlh = ui(20);
            	
        		draw_sprite_stretched_ext(THEME.ui_panel_bg, 2, _tlx, _tly, _tlw, _tlh, COLORS.panel_animation_timeline_blend, 1);
        		draw_sprite_stretched_add(THEME.ui_panel,    1, _tlx, _tly, _tlw, _tlh, COLORS._main_icon, .25);
        		
        		var hhov = _hover && point_in_rectangle(_m[0], _m[1], _tlx, _tly, _tlx + _tlw, _tly + _tlh);
            	var scis = gpu_get_scissor();
            	gpu_set_scissor(_tlx + ui(2), _tly + ui(2), _tlw - ui(4), _tlh - ui(4));
            	
            	var _fTotal = jun.node.project.animator.frames_total;
            	var _fw = _tlw - ui(4);
            	var _fs = (_fw - 2) / _fTotal;
            	var _fx = _tlx + 1 + ui(2);
            	
            	var vx, vy = _tly + _tlh / 2;
            	var cc = COLORS.panel_animation_keyframe_unselected;
            	var aa = .5 + jun.is_anim * .5;
            	
            	draw_set_color(jun.is_anim? COLORS._main_icon : COLORS._main_icon_dark);
            	draw_set_alpha(.5);
            	draw_line(_tlx, vy, _tlx + _tlw, vy);
            	draw_set_alpha(1);
            	
            	if(jun.sep_axis) {
            		var _anis = jun.getAnimators();
            		for( var k = 0, p = array_length(_anis); k < p; k++ ) 
            		for( var j = 0, m = array_length(_anis[k].values); j < m; j++ ) {
            			var _keyf = _anis[k].values[j];
            			vx = _fx + _keyf.time * _fs;
            			
            			var _hv = hhov && point_in_circle(_m[0], _m[1], vx, vy, ui(8));
            			var _cc = _hv? COLORS._main_icon_light : COLORS._main_icon;
            			
            			draw_sprite_ui_uniform(THEME.timeline_keyframe, 0, vx, vy, 1, _cc, aa);
            		}
            		
            	} else {
            		var _ani = jun.animator;
            		for( var j = 0, m = array_length(_ani.values); j < m; j++ ) {
            			var _keyf = _ani.values[j];
            			vx = _fx + _keyf.time * _fs;
            			
            			var _hv = hhov && point_in_circle(_m[0], _m[1], vx, vy, ui(8));
            			var _cc = _hv? COLORS._main_icon_light : COLORS._main_icon;
            			
            			draw_sprite_ui_uniform(THEME.timeline_keyframe, 0, vx, vy, 1, _cc, aa);
            		}
            	}
            	
            	var _fCurr = jun.node.project.animator.current_frame;
            	vx = _fx + _fCurr * _fs;
            	draw_set_color(COLORS._main_accent);
            	draw_line(vx, _tly, vx, _tly+_tlh);
            	
            	if(hhov) {
            		if(mouse_lpress(_focus)) timeline_scrubbing = true;
            	}
            	
            	if(timeline_scrubbing) {
        			if(mouse_lrelease()) timeline_scrubbing = false;
        			
        			var rfrm = round((_m[0] - _fx) / _fs);
        			    rfrm = clamp(rfrm, 0, _fTotal);
        			    
        			jun.node.project.animator.setFrame(rfrm);
        		}
            	
            	gpu_set_scissor(scis);
            	
            	hh += _tlh + ui(8);
            }
            
        }
        
        	 if(_cAll ==  1) section_expand_all();  
		else if(_cAll == -1) section_collapse_all();
		
		if(_inspecting.input_display_deco != undefined)
			_inspecting.input_display_deco(_x, _y, _w, _m, _hover, _focus, self);
		
        color_picking = false;
        
        if(prop_dragging) { //drag
            if(DRAGGING == noone && point_distance(prop_sel_drag_x, prop_sel_drag_y, mouse_mx, mouse_my) > 16) {
                prop_dragging.dragValue();
                prop_dragging = noone;
            }
            
            if(mouse_lrelease())
                prop_dragging = noone;
        }
        
        if(prop_highlight_time > 0) {
            prop_highlight_time -= DELTA_TIME;
            
            if(prop_highlight_time <= 0) {
            	prop_highlight_time = 0;
                prop_highlight = noone;
            }
        }
        
        _inspecting.inspector_draw_height = hh;
        
    	if(showHig && prop_selecting_y_to != undefined) { // Selection highlight
	        prop_selecting_y = lerp_float(prop_selecting_y, prop_selecting_y_to, 2);
	        prop_selecting_h = lerp_float(prop_selecting_h, prop_selecting_h_to, 2);
	        
	        var _px = _x + ui(4);
	        var _py = _y + prop_selecting_y;
	        var _pw = con_w - ui(8);
	        var _ph = prop_selecting_h;
	        // if(pHOVER) 
	        draw_sprite_stretched_ext(THEME.prop_selecting, 0, _px, _py, _pw, _ph, COLORS._main_accent, 1);
    	}
    	
    	prop_selecting_y_to = undefined;
    	
        return hh;
    }
    
    static drawNodeAttribute = function(_x, _y, _w, _m, _inspecting = inspecting, _flag = INSPECTOR_FLAG.show_all) { 
        var con_w = _w - ui(4); 
        var con_h = contentPane.surface_h;
        
        var _hover = pHOVER && contentPane.hover;
        var _focus = pFOCUS || PANEL_GRAPH.pFOCUS;
        
        var xc    = con_w / 2;
        var _font = viewMode == INSP_VIEW_MODE.spacious? f_p2 : f_p3;
    
        var hh  = ui(8);
        var hg  = ui(32);
        var yy  = _y + hh;
        var wx1 = con_w - ui(8);
        var ww  = max(ui(180), con_w / 3);
        var wx0 = wx1 - ww;
        
        var _att_h = viewMode == INSP_VIEW_MODE.spacious? hg : line_get_height(_font, 6);
        var _pd    = viewMode == INSP_VIEW_MODE.spacious? ui(8) : ui(6);
        
        var _att_name, _att_val, _att_wid, _att_key;

        for( var i = 0, n = array_length(_inspecting.attributeEditors); i < n; i++ ) {
            var edt = _inspecting.attributeEditors[i];
            
            if(is_string(edt)) { // label
            	var txt = __txt(edt);
                var lby = yy + ui(12);
                draw_set_alpha(0.5);
                draw_set_text(viewMode == INSP_VIEW_MODE.spacious? f_p1 : f_p3, fa_center, fa_center, COLORS._main_text_sub);
                draw_text_add(xc, lby, txt);
                
                var lbw = string_width(txt) / 2;
                draw_set_color(COLORS._main_text_sub);
                draw_line_round(xc + lbw + ui(16), lby,   wx1, lby, 2);
                draw_line_round(xc - lbw - ui(16), lby, ui(8), lby, 2);
                draw_set_alpha(1.0);
                
                yy += _att_h;
                hh += _att_h;
                continue;
            }
            
            if(is(edt, __Node_Attribute)) {
                _att_name = edt.name;
                _att_val  = edt.get();
                _att_wid  = edt.getEditWidget();
                _att_key  = edt.hotkey;
            	
            } else if(is_array(edt)) {
                _att_name = __txt(edt[0]);
                _att_val  = edt[1]();
                _att_wid  = edt[2];
                _att_key  = array_safe_get(edt, 3, 0);
            }
            
            _att_wid.font = _font;
            _att_wid.register(contentPane);
            _att_wid.setFocusHover(pFOCUS, pHOVER);
            
            if(is(_att_wid, buttonClass)) {
                _att_wid.text = _att_name;
                _att_wid.draw(ui(8), yy, con_w - ui(16), _att_h, _m); 
                
                if(_att_wid.inBBOX(_m)) contentPane.hover_content = true;
                yy += _att_h + _pd;
                hh += _att_h + _pd;
                continue;
            } 
            
            draw_set_text(_font, fa_left, fa_center, COLORS._main_text);
            draw_text_add(ui(8), yy + _att_h / 2, _att_name);
            
            if(_att_key != 0) {
                draw_set_text(_font, fa_right, fa_center, COLORS._main_text_sub);
                draw_text_add(wx0 - ui(8), yy + _att_h / 2, _att_key.toString());
            }
            
            var _param = new widgetParam(wx0, yy, ww, _att_h, _att_val, undefined, _m, x + contentPane.x, y + contentPane.y);
                _param.s    = _att_h;
                _param.font = _font;
                
            if(is(_att_wid, checkBox)) _param.halign = fa_center;
            
            var _wh = _att_wid.drawParam(_param);
            
            if(_att_wid.inBBOX(_m)) contentPane.hover_content = true;
            
            var _hg = max(_att_h, _wh);
            yy += _hg + _pd;
            hh += _hg + _pd;
        }
        
        return hh; 
    }
    
    static drawNodeLog = function(_x, _y, _w, _m, _inspecting = inspecting, _flag = INSPECTOR_FLAG.show_all) { 
        _inspecting.messages_bub = false;
        
        var _hover = pHOVER && contentPane.hover;
        var _focus = pFOCUS || PANEL_GRAPH.pFOCUS;
        
        var _logs  = _inspecting.messages;
        var _tmw   = ui(64);
        var yy = _y;
        var hh = ui(64);
        
        var con_w = _w;
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
    
    static drawNodePanel = function(_x, _y, _w, _m, _inspecting = inspecting) {
    	if(!is(_inspecting, Node)) return 0;
    	if(!is(_inspecting.panel_custom_data, Panel_Custom_Data)) return 0;
    	
        var _hover  = pHOVER && contentPane.hover;
        var _focus  = pFOCUS || PANEL_GRAPH.pFOCUS;
        
    	var _pan = _inspecting.panel_custom_data;
    	var _hh  = _pan.h;
    	
		_hovering_frame   = hovering_frame;
		_hovering_scroll  = hovering_scroll;
		_hovering_element = hovering_element;
		
		hovering_frame    = undefined;
		hovering_scroll   = undefined;
		hovering_element  = undefined;
		
		var _rx = x + contentPane.x;
		var _ry = y + contentPane.y;
		
		_pan.setSize(_x, _y, _w, _hh, _rx, _ry);
		_pan.setFocusHover(_focus, _hover, true);
		_pan.root.checkMouse(self, _m);
		_pan.draw(self, _m);
    	
    	return _hh;
    }
    
    static drawNodeData = function(_x, _y, _w, _m, _inspecting = inspecting, _flag = INSPECTOR_FLAG.show_all) { 
    	_inspecting.inspecting       = true;
        _inspecting.inspector_scroll = contentPane.scroll_y_to;
        
        prop_hover  = noone;
        widgPrevX   = 0;
        widgPrevW   = 0;
        widgNameX   = 0;
        
    	switch(prop_page) {
    		case "Node": 
    			if(is(_inspecting.panel_custom_data, Panel_Custom_Data)) 
    				 return drawNodePanel(_x, _y, _w, _m, _inspecting, _flag);
    			else return drawNodeProperties(_x, _y, _w, _m, _inspecting, _flag);
    			
    		case "Panel":      return drawNodePanel(_x, _y, _w, _m, _inspecting, _flag);
    		case "Properties": return drawNodeProperties(_x, _y, _w, _m, _inspecting, _flag);
    		case "Settings":   return drawNodeAttribute(_x, _y, _w, _m, _inspecting, _flag);
    		case "Log":        return drawNodeLog(_x, _y, _w, _m, _inspecting, _flag);
    	}
    	
    	return 0;
    }
    
    static drawContentNode = function(_y, _m) {
        var con_w  = contentPane.surface_w - ui(4);
        if(point_in_rectangle(_m[0], _m[1], 0, 0, con_w, content_h) && mouse_lpress(pFOCUS))
            prop_selecting = noone;
        
        var _hh = 0;
        var th = ui(24);
    	var bs = th;
    	
        var ww = contentPane.surface_w;
        var tw = clamp(ww * .75, ui(280), ww - ui(64));
        
    	var tx = contentPane.w / 2 - tw / 2 + th / 2;
    	var ty = _y + ui(4);
    	
    	var bx = tx - bs - ui(4);
    	var by = ty;
    	var cc = filtering? COLORS._main_value_positive : COLORS._main_icon;
    	
    	if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, pHOVER, pFOCUS, tSearch, THEME.search, 0, cc, 1, ui(8)) == 2) {
    		filtering = !filtering;
    		if(filtering) tb_prop_filter.activate();
    		else          tb_prop_filter.deactivate();
    		
    	} bx -= bs + 1;
    	
    	if(bx > ui(4)) {
    		var bspr = THEME.filter_animation;
    		var bi   = FILTER_ANIMATION;
    		var bc   = FILTER_ANIMATION? COLORS._main_value_positive : COLORS._main_icon;
    		
	    	if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, pHOVER, pFOCUS, tFilteranim, bspr, bi, bc, 1, ui(8)) == 2) {
	    		FILTER_ANIMATION = !FILTER_ANIMATION;
	    		GraphRefresh();
	    	}
	    	bx -= bs + 1;
    	}
    	
    	if(filtering) {
	        tb_prop_filter.register(contentPane);
	        tb_prop_filter.setFocusHover(pHOVER, pFOCUS);
	        tb_prop_filter.draw(tx, ty, tw, th, filter_text, _m);
	        
    	} else if(is(inspecting.panel_custom_data, Panel_Custom_Data))  {
    		var ipage = 0;
    		switch(prop_page) {
    			case "Panel":      ipage = 0; break;
    			case "Properties": ipage = 1; break;
    			case "Settings":   ipage = 2; break;
    			case "Log":        ipage = 3; break;
    		}
    		
    		prop_page_panel_a[3] = inspecting.messages_bub? THEME.message_16_grey_bubble : THEME.message_16_grey;
	        prop_page_panel_b.setFocusHover(pFOCUS, pHOVER);
	        prop_page_panel_b.draw(tx, ty, tw, th, ipage, _m, x + contentPane.x, y + contentPane.y);
	        
    	} else {
    		var ipage = 0;
    		switch(prop_page) {
    			case "Panel":      ipage = 0; prop_page = "Node"; break;
    			case "Properties": ipage = 0; break;
    			case "Settings":   ipage = 1; break;
    			case "Log":        ipage = 2; break;
    		}
    		
	        prop_page_a[2] = inspecting.messages_bub? THEME.message_16_grey_bubble : THEME.message_16_grey;
	        prop_page_b.setFocusHover(pFOCUS, pHOVER);
	        prop_page_b.draw(tx, ty, tw, th, ipage, _m, x + contentPane.x, y + contentPane.y);
    	}
    	
    	_hh += th + ui(16);
        _y  += th + ui(16);
	    
        if(inspectGroup >= 0 || is(inspecting, Node_Frame)) return _hh + drawNodeData(0, _y, contentPane.surface_w, _m, inspecting);
        
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
            
            var _h = drawNodeData(0, _y, contentPane.surface_w, _m, inspectings[i]);
            _y  += _h;
            _hh += _h;
        }
        
        return _hh + ui(64);
    }
    
    static drawHeader_Node = function() {
    	var amo = array_length(PANEL_GRAPH.nodes_selecting);
        var txt = inspecting.getDisplayName();
             if(inspectGroup ==  1) txt = $"[{amo}] {txt}"; 
        else if(inspectGroup == -1) txt = $"[{amo}] Multiple nodes"; 
        
        var tb_x = ui(64);
        var tb_y = ui(14);
        var tb_w = w - ui(128);
        var tb_h = ui(32);
        
        var pd = ui(8);
        var bs = ui(24);
        var m   = [mx, my];
        
        var hov = pHOVER;
        var foc = pFOCUS;
        
        tb_node_name.setFocusHover(foc, hov);
        tb_node_name.draw(tb_x, tb_y, tb_w, tb_h, txt, m);
        
        if(is(inspecting, Node) && inspectGroup == 0) {
        	draw_set_font(f_h5);
        	var icx = tb_x + tb_w / 2 - string_width(txt) / 2 - tb_h / 2;
	        var icy = tb_y + tb_h / 2;
	        
        	var _col = inspecting.attributes.color;
        	if(_col != -1) {
        		draw_sprite_ui(THEME.timeline_color, 1, icx, icy, 1, 1, 0, _col, 1);
        		icx -= tb_h / 2 + ui(4);
        	}
        	
        	if(inspecting.instanceBase) {
        		draw_sprite_ui(THEME.node_instance_icon, 0, icx, icy, 1, 1, 0, c_white, 1);
        		icx -= tb_h / 2 + ui(4);
        	}
        }
        
        if(inspectGroup >= 0) {
            draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text_sub);
            draw_text_add(w / 2, ui(56), inspecting.name);
        
            draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
            draw_set_alpha(0.65);
            draw_text_add(w / 2, ui(76), inspecting.internalName);
            draw_set_alpha(1);
            
            var _txt_w = string_width(inspecting.internalName);
            
	        var his_x = w / 2 - _txt_w / 2 - ui(16);
	        var his_y = ui(68);
	        
	        var targ     = array_empty(inspect_history_undo)? noone : array_last(inspect_history_undo);
	        var targName = targ == noone? "Project" : targ.getDisplayName();
	        var _hov     = hov && point_in_rectangle(mx, my, his_x, his_y, w / 2, his_y + ui(16));
	        
	        var cc = _hov? c_white : COLORS._main_text_sub;
	        var aa = _hov? 1 : .75;
	        draw_sprite_ui_uniform(THEME.arrow_wire_16, 2, his_x + ui(8), his_y + ui(8), 1, cc, aa);
	        
	        if(_hov && mouse_lpress(foc)) {
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
	        	var _hov     = hov && point_in_rectangle(mx, my, his_x, his_y, w, his_y + ui(16));
	        	
		        var cc = _hov? c_white : COLORS._main_text_sub;
		        var aa = _hov? 1 : .75;
		        draw_sprite_ui_uniform(THEME.arrow_wire_16, 0, his_x + ui(8), his_y + ui(8), 1, cc, aa);
		        
		        if(_hov && mouse_lpress(foc)) {
		        	array_pop(inspect_history_redo);
		        	
		        	setInspecting(targ, false, true);
		        	PANEL_GRAPH.nodes_selecting = [];
		        	PANEL_PREVIEW.setNodePreview(targ);
		        }
	        }
	        
	        if(inspecting == noone) return;
        }
        
        var bx = pd;
        var by = pd;
        var bb = THEME.button_hide_fill;
        
        if(inspectGroup == 0) {
        	var bc = locked? COLORS._main_accent : COLORS._main_icon;
            if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Lock"), THEME.lock_12, !locked, bc, 1, ui(8)) == 2)
                locked = !locked;
            
            by += bs + ui(2);
            var _over = inspecting.overwrited_default;
            var _txt  = _over? __txt("Presets (Default Overwited)") : __txt("Presets");
            if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, _txt, THEME.preset, 0, COLORS._main_icon, 1, ui(8)) == 2)
                dialogPanelCall(new Panel_Presets(inspecting), x + bx, y + by + ui(36));
                
            if(_over) {
            	BLEND_SUBTRACT
            	draw_sprite_ui(THEME.circle, 0, bx + bs - ui(6), by + bs - ui(6), 1, 1, 0, COLORS._main_accent);
            	BLEND_NORMAL
            	draw_sprite_ui(THEME.circle, 0, bx + bs - ui(6), by + bs - ui(6), .75, .75, 0, COLORS._main_accent);
            }
                
        } else {
            draw_sprite_ui_uniform(THEME.preset, 1, bx + bs / 2, by + bs / 2, 1, COLORS._main_icon_dark);
        }
        
        ////- INSPECTOR ACTIONS
        
        var bx = w - pd - bs;
        var by = pd;
        
        var b = inspecting.insp1button;
        if(b && b.visible) {
        	b.icon_padd = ui(8);
        	b.setFocusHover(foc, hov);
        	b.draw(bx, by, bs, bs, m);
        	
        	if(b.hovering) {
        		TOOLTIP      = tooltip_primary;
        		TOOLTIP.text = b.tooltip;
        	}
        }
        
        by += bs + ui(2);
        var b = inspecting.insp2button;
        if(b && b.visible) {
        	b.icon_padd = ui(8);
        	b.setFocusHover(foc, hov);
        	b.draw(bx, by, bs, bs, m);
        	
        	if(b.hovering) {
        		TOOLTIP      = tooltip_secondary;
        		TOOLTIP.text = b.tooltip;
        	}
        }
        
        by += bs + ui(2);
        var b = inspecting.buttonCacheClear;
        if(b && b.visible) {
        	b.icon_padd = ui(8);
        	b.setFocusHover(foc, hov);
        	b.draw(bx, by, bs, bs, m);
        	
        	if(b.hovering) {
        		TOOLTIP      = tooltip_cache;
        		TOOLTIP.text = b.tooltip;
        	}
        }
    }
    
    ////- DRAW META
    
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
	    	var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, undefined, _m, rx, ry)
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
        var _focus = pFOCUS && contentPane.active;
        var  spac  = viewMode == INSP_VIEW_MODE.spacious;
        
        var hh  = ui(40);
        var yy  = _y + hh;
        var rx  = x + ui(16);
        var ry  = y + top_bar_h;
        var _cAll = 0;
        
        var fnt   = spac? f_p1 : f_p3;
        var _font = spac? f_p2 : f_p3;
        var lbh   = spac? ui(26) : ui(22);
        
        var padd  = ui(THEME_VALUE.panel_inspector_prop_paddding);
        
        attribute_hovering = noone;
        
        for( var i = 0, n = array_length(meta_display); i < n; i++ ) {
            var _meta  = meta_display[i];
            var _txt   = array_safe_get_fast(_meta, 0);
            var _col   = array_safe_get_fast(_meta, 1);
            var _tag   = array_safe_get_fast(_meta, 2);
            
            if(_tag == "group prop" && PANEL_GRAPH.getCurrentContext() == noone) continue;
            if(_tag == "layers" && !PROJECT.attributes.global_layer)             continue;
            
            var _x1 = con_w;
            var _y1 = yy + ui(2);
            
            /// Buttons
            
            var _butts = noone;
            switch(_tag) { // buttons
            	case "settings"  : _butts = variables_buttons;   break;
            	case "panels"    : _butts = customPanel_buttons; break;
            	case "layers"    : _butts = globallayer_buttons; break;
            	case "metadata"  : _butts = metadata_buttons;    break;
                case "globalvar" : _butts = global_drawer.editing? global_buttons_editing : global_buttons; break;
            }
            
            if(is_array(_butts)) {
            	var _bw = ui(28);
                var _bh = lbh - ui(4);
                
                var _amo = array_length(_butts);
                var _tw  = (_bw + ui(4)) * _amo;
                draw_sprite_stretched_ext(THEME.section_separator, 0, con_w - _tw, yy, _tw, lbh, COLORS.section_bg);
                
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
            
            var hv = _hover && point_in_rectangle(_m[0], _m[1], 0, yy, _x1, yy + lbh);
            draw_sprite_stretched_ext(THEME.section_separator, 0, 0, yy, _x1, lbh, hv? COLORS.section_hover : COLORS.section_bg);
            if(!_col) draw_sprite_stretched_ext(THEME.section_separator, 2, 0, yy, _x1, lbh, COLORS.section_selected);
            
            if(hv) {
                draw_sprite_stretched_ext(THEME.section_separator, 1, 0, yy, _x1, lbh, COLORS.section_hover);
                
                if(pFOCUS) {
                    	 if(DOUBLE_CLICK) _cAll = _meta[1]? -1 : 1;
                    else if(mouse_lpress()) _meta[1] = !_meta[1];
                }
            }
            
            draw_sprite_ui(THEME.arrow, _col? 0 : 3, ui(16), yy + lbh / 2, 1, 1, 0, COLORS._main_icon, 1);    
            draw_set_text(fnt, fa_left, fa_center, COLORS._main_text);
            
            var tx = ui(32);
            draw_text_add(tx, yy + lbh / 2, _txt);
            tx += string_width(_txt) + ui(4);
    		draw_set_color(COLORS._main_text_sub);
    		
            switch(_tag) {
            	case "globalvar": 
            		var amo = array_length(PROJECT.globalNode.inputs);
            		if(amo == 0) break;
            		
            		draw_text_add(tx, yy + lbh / 2, $"[{amo}]");
            		break;
            		
            	case "favorites": 
            		var  amo  = 0;
            		var _favs = PROJECT.favoritedValues;
            		
            		for( var j = 0, m = array_length(_favs); j < m; j++ ) {
						var _fv = _favs[j];
            			if(is_array(_fv)) {
							var _nid = _fv[0];
							var _ind = _fv[1];
							
							var _nod = PROJECT.nodeMap[? _nid];
							if(!is(_nod, Node) || !_nod.active) continue;
							
							var _inp = array_safe_get_fast(_nod.inputs, _ind);
							if(is(_inp, NodeValue))
								_favs[j] = _inp;
            			}
            			
						var _fv = _favs[j];
						if(!is(_fv, NodeValue) || !_fv.node.active) continue;
						
						amo++;
            		}
            		
            		if(amo == 0) break;
            		draw_text_add(tx, yy + lbh / 2, $"[{amo}]");
            		break;
            		
            	case "panels": 
            		var amo = array_length(PROJECT.customPanels);
            		if(amo == 0) break;
            		
            		draw_text_add(tx, yy + lbh / 2, $"[{amo}]");
            		break;
            		
            }
            
            /// Content
            
            yy += lbh + padd;
            hh += lbh + padd;
            
            if(_col) continue;
            
            switch(_tag) {
                case "settings" :
                    var _edt = PROJECT.attributeEditor;
                    var _lh, wh;
                    
                    for( var j = 0, mlen = array_length(_edt); j < mlen; j++ ) {
                        var title = array_safe_get(_edt[j], 0, noone);
                        var param = array_safe_get(_edt[j], 1, noone);
                        var editW = array_safe_get(_edt[j], 2, noone);
                        var drpFn = array_safe_get(_edt[j], 3, noone);
                        
                        if(param == "slideshow_render_only" && !PROJECT.useSlideShow) continue;
                        
                        var widx = ui(8);
                        var widy = yy;
                        
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text);
                        draw_text_add(ui(16), spac? yy : yy + ui(3), __txt(title));
                        
                        if(spac) {
                            _lh = line_get_height();
                            yy += _lh + padd;
                            hh += _lh + padd;
                            
                        } else if(viewMode == INSP_VIEW_MODE.compact) {
                            _lh = line_get_height() + padd;
                        }
                        
                        var wh = 0;
                        var _data = PROJECT.attributes[$ param];
                        var _wdx  = spac? ui(16) : ui(140);
                        var _wdy  = yy;
                        var _wdw  = w - ui(48) - _wdx;
                        var _wdh  = spac? TEXTBOX_HEIGHT  : _lh;
                        
                        var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, undefined, _m, rx, ry)
                        					.setFont(_font).setScrollpane(contentPane);
					    if(is(editW, checkBox)) _param.setHalign(fa_center);
					    					
                        editW.setFocusHover(pFOCUS, _hover);
                        wh = editW.drawParam(_param);
                        
                        var jun  = PANEL_GRAPH.value_dragging;
                        var widw = con_w - ui(16);
                        var widh = spac? _lh + padd + wh + ui(4) : max(wh, _lh);
                        var drop = jun != noone && drpFn != noone;
                        
                        if(_hover && point_in_rectangle(_m[0], _m[1], widx, widy, widx + widw, widy + widh)) {
                        	if(drop) {
                            	draw_sprite_stretched_ext(THEME.ui_panel, 1, widx, widy, widw, widh, COLORS._main_value_positive, 1);
                            	attribute_hovering  = drpFn;
                        	}
                        	
                            prop_selecting_y_to = widy - _y;
                        	prop_selecting_h_to = widh;
                        }
                        
				    	var _wdhh = spac? wh + padd + ui(2) : max(wh, _lh) + padd;
			        	yy += _wdhh; 
			        	hh += _wdhh;
                    }
                    
			        #region selection highlight
			        	if(prop_selecting_y_to != undefined) {
					        prop_selecting_y = lerp_float(prop_selecting_y, prop_selecting_y_to, 2);
					        prop_selecting_h = lerp_float(prop_selecting_h, prop_selecting_h_to, 2);
					        
					        var _px = ui(4);
					        var _py = _y + prop_selecting_y;
					        var _pw = con_w - ui(4);
					        var _ph = prop_selecting_h;
					        if(pHOVER) draw_sprite_stretched_ext(THEME.prop_selecting, 0, _px, _py, _pw, _ph, COLORS._main_accent, 1);
			        	}
			        	
			        	prop_selecting_y_to = undefined;
			    	#endregion
			        
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
                    var _whh = TEXTBOX_HEIGHT;
                    var _edt = PROJECT.meta.file_id == 0 || PROJECT.meta.author_steam_id == STEAM_USER_ID;
                        
                    for( var j = 0; j < array_length(meta.displays); j++ ) {
                        var display = meta.displays[j];
                        var _wdgt   = meta_edit[j];
                        
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text);
                        draw_text_add(ui(16), spac? yy : yy + ui(3), __txt(display[0]));
                        
                        if(spac) {
                            _lh = line_get_height();
                            yy += _lh + padd;
                            hh += _lh + padd;
                            
                        } else if(viewMode == INSP_VIEW_MODE.compact) {
                            _lh = line_get_height() + padd;
                        }
                        
                        var _dataFunc = display[1];
                        var _data = _dataFunc(meta);
                        var _wdy  = yy;
                        var _wdh  = _whh * display[2];
                        
                        var _param = new widgetParam(_wdx, _wdy, _wdw, _wdh, _data, undefined, _m, rx, ry)
                        					.setFont(_font)
					    					.setFocusHover(pFOCUS, _hover, _edt)
					    					.setScrollpane(contentPane);
                        
                        if(is(_wdgt, textArrayBox)) _wdgt.arraySet = current_meta.tags;
                        wh = _wdgt.drawParam(_param);
                        
				    	var _wdhh = spac? wh + padd + ui(2) : max(wh, _lh) + padd;
			        	yy += _wdhh; 
			        	hh += _wdhh;
                    }
                    
                    if(STEAM_ENABLED && _edt) {
                        var pad = ui(6 + spac * 2);
                        var lpd = spac * (line_get_height() + padd);
                        
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text);
                        draw_text_add(ui(16), spac? yy : yy + ui(3), __txt("Show Avatar"));
                        yy += lpd; hh += lpd;
                        
                        var _param = new widgetParam(_wdx, yy, _wdw, TEXTBOX_HEIGHT, STEAM_UGC_ITEM_AVATAR, undefined, _m, rx, ry)
                        					.setFont(_font).setFocusHover(pFOCUS, _hover).setScrollpane(contentPane);
                        wh = meta_steam_avatar.drawParam(_param);
			        	yy += wh + pad; 
			        	hh += wh + pad;
			        	
                        draw_set_text(_font, fa_left, fa_top, COLORS._main_text);
                        draw_text_add(ui(16), spac? yy : yy + ui(3), __txt("Thumbnail"));
                        yy += lpd; hh += lpd;
                        wh  = ui(80);
                        
                        var hv  = _hover && point_in_rectangle(_m[0], _m[1], _wdx, yy, _wdx + _wdw, yy + wh);
                        var thm = PROJECT.getThumbnail();
                        
                        draw_sprite_stretched(THEME.textbox, 3, _wdx, yy, _wdw, wh);
                        if(thm && sprite_exists(thm)) {
                        	var sw = sprite_get_width(thm);
                        	var sh = sprite_get_height(thm);
                        	var ss = min((_wdw - ui(8)) / sw, (wh - ui(8)) / sh);
                        	var sx = _wdx + _wdw/2;
                        	var sy =   yy +   wh/2;
                        	
                        	draw_sprite_ext(thm, current_time / 30, sx, sy, ss, ss);
                        }
                        
                        if(uploading_thumbnail)
                        	draw_sprite_ui(THEME.loading_s, 0, _wdx + _wdw - ui(16), yy + wh - ui(16), 1, 1, current_time / 2, COLORS._main_icon);
                        
                        if(PROJECT.path != "") {
	                        var brx = _wdx + ui(4);
	                        var bry = yy + ui(4);
	                        var brs = ui(20);
	                        var _bt = __txt("Refresh");
	                        
	                        var b = buttonInstant_Pad(THEME.button_hide, brx, bry, brs, brs, _m, _hover, _focus, _bt, THEME.refresh_icon);
	                        if(b) hv = false;
	                        if(b == 2) {
	                        	sprite_delete_safe(PROJECT.thumbnailSpr);
	                        	file_delete_safe(PROJECT.thumbnailPath);
	                        	
	                        	PROJECT.thumbnailPath = "";
	                        	PROJECT.thumbnailSpr  = undefined;
	                        }
                        }
                        
                        if(hv) {
                        	TOOLTIP = __txt("Change Thumbnail") + "...";
                        	draw_sprite_stretched(THEME.textbox, 1, _wdx, yy, _wdw, wh);
                        	
                        	if(mouse_lpress(pFOCUS)) {
                        		var _path = get_open_filename_compat("Image (.png, .gif)|.png;.gif", "thumbnail")
                        		if(_path != "") steam_ugc_update_project_preview(_path, "Update Thumbnail");
                        	}
                        }
                        
                        yy += wh + pad; 
			        	hh += wh + pad;
                    }
                    
                    break;
                    
                case "panels":
                	var gw    = contentPane.surface_w - ui(24);
                	var bb    = THEME.button_hide;
                	var _pans = PROJECT.customPanels;
                	var _ph   = ui(24);
                	var pbw   = ui(128);
                	var toDel = undefined;
                	var _padx = ui(4);
                	
                	var pbx, pby, pbh;
                	
                	for( var j = 0, m = array_length(_pans); j < m; j++ ) {
                		var _p = _pans[j];
                		
                		var fhv = _hover && point_in_circle(_m[0], _m[1], ui(16), yy + _ph / 2, _ph / 2);
                		var fc  = _p.open_start? COLORS._main_value_positive : COLORS._main_icon;
                		draw_sprite_ui(THEME.favorite, _p.open_start, ui(16), yy + _ph / 2, .75, .75, 0, fc, .75 + fhv*.25);
                		if(fhv) {
                			TOOLTIP = __txt("Open on Project load");
                			if(mouse_lpress(_focus)) _p.open_start = !_p.open_start;
                		}
                		
                		draw_set_font(_font);
                		var _txt = _p.name;
                		var _txw = string_width(_txt) + ui(8);
                		var _txh = _ph - ui(4);
                		var _tx0 = ui(32) - _padx / 2;
                		var _ty0 = yy + ui(2);
                		
                		if(panel_rename == _p) {
                			var tbw = w - pbw - _tx0 - ui(104);
                			panel_rename_tb.setFocusHover(_focus, _hover)
                			panel_rename_tb.drawParam(new widgetParam(_tx0, yy + 1, tbw, _ph - 2, _txt, undefined, _m)
                				.setFont(_font));
	                		
                		} else {
                			var lbHov = _hover && point_in_rectangle(_m[0], _m[1], _tx0, _ty0, _tx0 + _txw, _ty0 + _txh);
							if(lbHov) draw_sprite_stretched_ext(THEME.box_r2_clr, 0, _tx0, _ty0, _txw, _txh, c_white, 1);
							
							draw_set_text(_font, fa_left, fa_center, COLORS._main_text);
	                		draw_text_add(ui(32), yy + _ph / 2, _txt);
	                		
	                		if(lbHov && _focus && DOUBLE_CLICK) {
	                			panel_rename = _p;
	                			panel_rename_tb.activate(_txt);
	                		}
	                		
                		}
                		
                		pbx  = con_w - _ph;
                		pby  = yy;
                		pbh  = _ph;
                		
                		if(_p.willDel) {
	                		var bt = __txt("Cancel Deletion");
	                		var bc = COLORS._main_value_negative;
	                		if(buttonInstant_Pad(bb, pbx, pby, _ph, _ph, _m, _hover, _focus, bt, THEME.cross, 0, bc, 1, ui(6)) == 2)
	                			_p.willDel = false;
	                		
	                		pbx -= _ph + ui(1);
	                		var bt = __txt("Comfirm Deletion");
	                		var bc = COLORS._main_value_positive;
	                		if(buttonInstant_Pad(bb, pbx, pby, _ph, _ph, _m, _hover, _focus, bt, THEME.accept_16, 0, bc, 1, ui(6)) == 2)
	                			toDel = _p;
	                			
                		} else {
	                		var bt = __txt("Delete Panel");
	                		var bc = CARRAY.button_negative;
	                		if(buttonInstant_Pad(bb, pbx, pby, _ph, _ph, _m, _hover, _focus, bt, THEME.cross, 0, bc, 1, ui(6)) == 2)
	                			_p.willDel = true;
                		
	                		pbx -= _ph + ui(1);
	                		var bt = __txt("Edit");
	                		var bc = COLORS._main_icon;
	                		if(buttonInstant_Pad(bb, pbx, pby, _ph, _ph, _m, _hover, _focus, bt, THEME.gear, 0, bc, 1, ui(6)) == 2)
	                			dialogPanelCall(new Panel_Custom_Editor(_p));
                		}
                		
                		pbx -= pbw + ui(4);
                		draw_set_font(_font);
                		var bt = __txt("Open");
                		if(buttonTextInstant(true, THEME.button_def, pbx, pby, pbw, pbh, _m, _hover, _focus, "", bt) == 2) 
                			dialogPanelCall(new Panel_Custom(_p));
                		
	                    yy += _ph + ui(4);
	                    hh += _ph + ui(4);
                	}
                	
                	if(toDel != undefined) array_remove(_pans, toDel);
                	
                	if(!array_empty(_pans)) {
	                    yy += ui(4);
	                    hh += ui(4);
                	}
                	break;
                	
                case "globalvar" : 
                    if(_m[1] > yy) contentPane.hover_content = true;
                    if(array_empty(PROJECT.globalNode.inputs)) break;
                    
					var gx = ui(8);
					var gy = yy;
					var gw = contentPane.surface_w - ui(8 + 8);
					
					var rx = ui(16) + x;
					var ry = top_bar_h + y;
					
                    global_drawer.viewMode = viewMode;
                    var glPar = global_drawer.draw(gx, gy, gw, _m, pFOCUS, _hover, contentPane, rx, ry);
                    var gvh   = glPar[0];
                    
                    yy += gvh + ui(8);
                    hh += gvh + ui(8);
                    break;
                    
                case "group prop" :
                    var context = PANEL_GRAPH.getCurrentContext();
                    var _h = drawNodeData(0, yy, contentPane.surface_w, _m, context);
                    
                    yy += _h;
                    hh += _h;
                    break;
                    	
				case "favorites" :
					var con_ww = contentPane.surface_w - ui(16);
					var rrx    = x + contentPane.x;
    		        var rry    = y + contentPane.y;
	                
					var _favs = PROJECT.favoritedValues;
					for( var j = 0, m = array_length(_favs); j < m; j++ ) {
						var _fv = _favs[j];
						if(is_array(_fv)) {
							var _nid = _fv[0];
							var _ind = _fv[1];
							
							var _nod = PROJECT.nodeMap[? _nid];
							if(!is(_nod, Node) || !_nod.active) continue;
							
							var _inp = array_safe_get_fast(_nod.inputs, _ind);
							if(is(_inp, NodeValue))
								_favs[j] = _inp;
						}
						
						var _fv = _favs[j];
						if(!is(_fv, NodeValue) || !_fv.node.active) continue;
						
						var widg = drawWidget(ui(8), yy, con_ww, _m, _fv, false, _hover, _focus, contentPane, rrx, rry);
                		var widH = widg[0];
                		
	                    yy += widH + padd;
	                    hh += widH + padd;
					}
					
                    yy += padd + ui(2);
                    hh += padd + ui(2);
            		break;
            }
            
            // yy += ui(2);
            // hh += ui(2);
        }
        
        	 if(_cAll ==  1) { for( var i = 0, n = array_length(meta_display); i < n; i++ ) meta_display[i][1] = false; }
		else if(_cAll == -1) { for( var i = 0, n = array_length(meta_display); i < n; i++ ) meta_display[i][1] =  true; }
		
        return hh;
    }
    
    static drawContentMeta = function(_y, _m) {
    	var _tab_width = min(contentPane.w - ui(128), ui(240));
    	var _tab_x     = (contentPane.w - ui(12)) / 2 - _tab_width / 2;
    	
        proj_prop_page_b.setFocusHover(pFOCUS, pHOVER);
        proj_prop_page_b.draw(_tab_x, _y + ui(4), _tab_width, ui(24), proj_prop_page, _m, x + contentPane.x, y + contentPane.y);
        
    	var bs = ui(24);
    	var bx = _tab_x - bs - ui(4);
    	var by = _y + ui(4);
    	
		var bspr = THEME.filter_animation;
		var bi   = FILTER_ANIMATION;
		var bc   = FILTER_ANIMATION? COLORS._main_value_positive : COLORS._main_icon;
		
    	if(buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, pHOVER, pFOCUS, tFilteranim, bspr, bi, bc, 1, ui(8)) == 2) {
    		FILTER_ANIMATION = !FILTER_ANIMATION;
    		GraphRefresh();
    	}
    	
        switch(proj_prop_page) {
        	case 0 : return drawContentMeta_PXC(_y, _m);
        	case 1 : return drawContentMeta_GM(_y, _m);
        }
        
        return 0;
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