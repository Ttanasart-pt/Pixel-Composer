function __Node_IsFileObject(path) {
    if(!directory_exists(path)) return false;
    return file_exists($"{path}/info.json");
}

function NodeFileObject(_path) : FileObject(_path) constructor {
    iconPath = _path + "/icon.png";
    icon     = s_node_icon;
    if(file_exists(iconPath)) icon = sprite_add(iconPath, 0, 0, 0, 0, 0);
    
    infoPath = _path + "/info.json";
    info     = json_load_struct(infoPath);
    
    static updateInfo = function() {
    	var _str = "{\n";
    	
    	_str += $"    \"name\":          \"{info.name}\",\n";
    	
    	if(struct_has(info, "tooltip"))
		_str += $"    \"tooltip\":       \"{info.tooltip}\",\n";
    		
    	_str += $"    \"spr\":           \"{info.spr}\",\n";
    	_str += $"    \"baseNode\":      \"{info.baseNode}\",\n";
    	
    	if(struct_has(info, "pxc_version"))
		_str += $"    \"pxc_version\":    {info.pxc_version},\n";
    	
    	if(struct_has(info, "io") && !array_empty(info.io))
		_str += $"    \"io\":             {json_stringify(info.io)},\n";
    		
    	if(struct_has(info, "show_in_recent"))
		_str += $"    \"show_in_recent\": {info.show_in_recent? "true" : "false"},\n";
    	
    	if(struct_has(info, "deprecated"))
		_str += $"    \"deprecated\":     {info.deprecated? "true" : "false"},\n";
    	
    	_str += "}\n";
    	
    	file_text_write_all(infoPath, _str);
    }
}

function Panel_Node_Custom_Import(_dirs) : PanelContent() constructor {
    title    = __txt("Import Resources");
	w        = ui(320);
	h        = ui(480);
	auto_pin = true;
    
    directory  = _dirs;
    dirContent = [];
    
    importing   = false;
    import_step = 0;
    import_full = 0;
    
    for( var i = 0, n = array_length(directory); i < n; i++ ) {
        var _dir = directory[i];
        dirContent[i] = __Node_IsFileObject(_dir)? new NodeFileObject(_dir) : 
                                                   new DirectoryObject(_dir).scan(["NodeObject"]);
    }
    
    sp_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) /*=>*/ {
        draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
        var ww = sp_content.surface_w;
        var hh = 0;
        var yy = _y;
        
        var lh = ui(18);
        var hg = ui(24);
        
        var _hover  = sp_content.hover;
        var _focus  = sp_content.active;
        import_full = 0;
        
        var _dir = ds_stack_create();
        for( var i = 0, n = array_length(dirContent); i < n; i++ )
            ds_stack_push(_dir, dirContent[i]);
        
        while(!ds_stack_empty(_dir)) {
            var _d = ds_stack_pop(_dir);
            
            if(is(_d, DirectoryObject)) {
                
                for( var i = 0, n = array_length(_d.subDir); i < n; i++ )
                    ds_stack_push(_dir, _d.subDir[i]);
                
                for( var i = 0, n = array_length(_d.content); i < n; i++ )
                    ds_stack_push(_dir, _d.content[i]);
                
                var cc = CDEF.main_ltgrey;
                
                draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
                draw_text_add(ui(8), yy + lh / 2, _d.name);
            	
                hh += lh + ui(4); yy += lh + ui(4);
                
            } else if(is(_d, NodeFileObject)) {
                
                var ss = hg - ui(4);
                var yc = yy + hg / 2;
                gpu_set_tex_filter(true);
                draw_sprite_stretched(_d.icon, 0, ui(8), yy + ui(2), ss, ss);
                gpu_set_tex_filter(false);
                
                var _cc   = COLORS._main_text;
                var _info = _d.info;
                
                if(struct_has(ALL_NODES, _info.iname)) {
                    _cc   = COLORS._main_text_accent;
                    
                    var _icx = ww - ui(8 + 10);
                    var _icy = yc;
                    
                    draw_sprite_ui(THEME.noti_icon_warning, 1, _icx, _icy, .75, .75);
                    if(_hover && point_in_circle(_m[0], _m[1], _icx, _icy, ui(10)))
                        TOOLTIP = "Node already exists."
                }
                
                draw_set_text(f_p2, fa_left, fa_center, _cc);
                draw_text_add(ui(8) + ss + ui(8), yc, _d.name);
                
                import_full++;
                hh += hg + ui(4); yy += hg + ui(4);
            }
        }
        
        ds_stack_destroy(_dir);
        
        return hh + ui(16);
    })
     
    function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var px = padding;
		var py = padding;
		var pw = w - (padding + padding);
		var ph = h - (padding + padding);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		var bh = ui(24);
		
		sp_content.verify(w - padding * 2, h - padding * 2 - bh - padding);
    	sp_content.setFocusHover(pFOCUS, pHOVER);
    	sp_content.drawOffset(px, py, mx, my);
    	
    	var bw   = w - padding * 2;
		var bx   = padding;
		var by   = h - padding - bh;
		var _cc  = COLORS._main_value_positive;
		
		if(importing) {
		    draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw, bh, _cc, .4);
		    draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw * min(1, import_step / import_full), bh, _cc, .85);
    		draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, _cc, .85);
    		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_value_positive);
    		draw_text_add(bx + bw / 2, by + bh / 2, __txt("Importing"));
    		
    		import_step++;
    		
    		if(import_step >= import_full) {
                __initNodes(false);
                noti_status($"Import {import_full} nodes complete.", noone, COLORS._main_value_positive);
                close();
    		}
    		
		    return;
		}
		
		var _hov = pHOVER && point_in_rectangle(mx, my, bx, by, bx + bw, by + bh);
		var _cc  = _hov? COLORS._main_value_positive : COLORS._main_icon;
		
		draw_sprite_stretched_ext(THEME.ui_panel, 0, bx, by, bw, bh, _cc, .3 + _hov * .1);
		draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, _cc, .6 + _hov * .25);
		draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_positive : COLORS._main_icon_light);
		draw_text_add(bx + bw / 2, by + bh / 2, __txt("Import"));
		
		if(_hov && mouse_press(mb_left, pFOCUS)) {
		    importing = true;
		    for( var i = 0, n = array_length(directory); i < n; i++ ) {
                var _dir   = directory[i];
		        var _dirTo = $"{DIRECTORY}Nodes/{filename_name_only(_dir)}";
                directory_copy(_dir, _dirTo);
		    }
		}
    }
}