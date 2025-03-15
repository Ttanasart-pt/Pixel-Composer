function Panel_HLSL_Libraries() : PanelContent() constructor {
    title    = __txt("HLSL Libraries");
	w        = ui(640);
	h        = ui(480);
	auto_pin = true;
	
	lib_w = ui(200);
	
	curr_type    = 0;
	curr_lib     = "";
	curr_content = "";
	curr_file    = "";
	blank_text   = @"Type `using <lib>` to apply library code.

Libraries in the global scope will be add to project automatically.";
	
	libData    = PROJECT.data[$ "hlsl"] ?? {};
	PROJECT.data.hlsl = libData;
	
	editor = new textArea(TEXTBOX_INPUT.text, function(s) /*=>*/ {
	    if(curr_lib == "") { blank_text = s; return; }
	    
	    curr_content = s;
	         if(curr_type == 0) file_text_write_all(curr_file, s);
        else if(curr_type == 1) libData[$ curr_lib] = curr_content;
	});
	
	editor.font                  = f_code;
	editor.format                = TEXT_AREA_FORMAT.codeHLSL;
    editor.autocomplete_server	 = hlsl_autocomplete_server;
	editor.function_guide_server = hlsl_function_guide_server;
	editor.parser_server		 = hlsl_document_parser;
	editor.select_on_click       = false;
	editor.shift_new_line        = false;
	editor.border_heightlight_color = COLORS._main_icon;
	
	new_file_type = noone;
	new_file_name = "";
	tb_new_file = new textBox(TEXTBOX_INPUT.text, function(s) /*=>*/ {
	    if(s == "") { new_file_type = noone; return; }
	    
	    if(new_file_type == 0) {
	        var _pth = $"{DIRECTORY}Nodes/HLSL/{s}.hlsl";
	        if(!file_exists(_pth)) {
    	        filename_verify_dir(_pth);
    	        file_text_write_all(_pth, "");
    	        __initHLSL();
	        }
	        
	    } else if(new_file_type == 1) {
	        if(!struct_has(libData, s))
	            libData[$ s] = "";
	    }
	    
	    refreshKey();
        open(s, new_file_type);
	    new_file_type = noone;
	});
	tb_new_file.font = f_p2;
	tb_new_file.onDeactivate = function() /*=>*/ { new_file_type = noone; };
	
	lib_selecting      = noone;
	lib_selecting_type = noone;
	
	right_menu = [
	    new MenuItem("Delete", function() /*=>*/ {
	        if(lib_selecting == noone) return;
	        
	        if(curr_type == lib_selecting_type && curr_lib == lib_selecting) 
                open();
	                
	        if(lib_selecting_type == 0) {
	            var _fil = HLSL_LIBRARIES[$ lib_selecting];
	            file_delete(_fil);
	            __initHLSL();
	            
	        } else if(lib_selecting_type == 1) {
	            struct_remove(libData, lib_selecting);
	            refreshKey();
	            
	        }
	    })
    ]
	
	static refreshKey = function() {
	    libDataKey = struct_get_names(libData);
        array_sort(libDataKey, true);
	} refreshKey();
	
    static open = function(_l = noone, _type = 0) {
        if(_l == noone) {
            curr_type    = 0;
            curr_file    = "";
            curr_lib     = "";
            curr_content = "";
            return;
        }
        
        curr_type = _type;
        
        if(_type == 0) {
            var _f = HLSL_LIBRARIES[$ _l];
            curr_file    = _f;
            curr_lib     = _l;
            curr_content = file_read_all(_f);
            
        } else if(_type == 1) {
            curr_file    = "";
            curr_lib     = _l;
            curr_content = libData[$ _l];
        }
    }
    
    sp_content_all = new scrollPane(lib_w, h - padding * 2, function(_y, _m) /*=>*/ {
        draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
        var ww = sp_content_all.surface_w;
        var hg = ui(20);
        var hh = ui(8);
        var yy = _y + ui(8);
        
        var _hover = sp_content_all.hover;
        var _focus = sp_content_all.active;
        
        for( var i = 0, n = array_length(HLSL_LIBRARIES_ARR); i < n; i++ ) {
            var _lib = HLSL_LIBRARIES_ARR[i];
            var _fil = HLSL_LIBRARIES[$ _lib];
            var _hig = curr_type == 0 && _lib == curr_lib;
            
            var _hov = _hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg);
            var _cc  = _hov? COLORS._main_text : COLORS._main_text_sub;
            if(_hig) _cc = COLORS._main_accent;
            
            draw_set_text(f_p2, fa_left, fa_center, _cc);
            draw_text_add(ui(8), yy + hg / 2, _lib);
            
            if(new_file_type == noone && _hov) {
                if(mouse_press(mb_left, _focus))
                    open(_hig? noone : _lib, 0);
                    
                if(mouse_press(mb_right, _focus)) {
                    lib_selecting      = _lib;
                	lib_selecting_type = 0;
                	
                    menuCall("", right_menu);
                }
            }
            
            yy += hg + ui(1);
            hh += hg + ui(1);
        }
        
        return hh + ui(16);
    });
     
    sp_content = new scrollPane(lib_w, h - padding * 2, function(_y, _m) /*=>*/ {
        draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
        var ww = sp_content.surface_w;
        var hg = ui(20);
        var hh = ui(8);
        var yy = _y + ui(8);
        
        var _hover = sp_content.hover;
        var _focus = sp_content.active;
        
        for( var i = 0, n = array_length(libDataKey); i < n; i++ ) {
            var _lib = libDataKey[i];
            var _fil = libData[$ _lib];
            var _hig = curr_type == 1 && _lib == curr_lib;
            
            var _hov = _hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg);
            var _cc  = _hov? COLORS._main_text : COLORS._main_text_sub;
            if(_hig) _cc = COLORS._main_accent;
            
            draw_set_text(f_p2, fa_left, fa_center, _cc);
            draw_text_add(ui(8), yy + hg / 2, _lib);
            
            if(new_file_type == noone && _hov) {
                if(mouse_press(mb_left, _focus))
                    open(_hig? noone : _lib, 1);
                    
                if(mouse_press(mb_right, _focus)) {
                    lib_selecting      = _lib;
                	lib_selecting_type = 1;
                	
                    menuCall("", right_menu);
                }
            }
            
            yy += hg + ui(1);
            hh += hg + ui(1);
        }
        
        return hh + ui(16);
    });
    
    function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var px = padding;
		var py = padding + ui(24 + 4);
		var pw = lib_w;
		var ph = (h / 2 - ui(16)) - py;
		
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(px + ui(8), py - ui(16), "Project");
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px, py, lib_w, ph);
		sp_content.verify(lib_w - ui(16), ph - ui(4));
    	sp_content.setFocusHover(pFOCUS, pHOVER);
    	sp_content.drawOffset(px + ui(8), py + ui(2), mx, my);
    	
    	var _bs = ui(24);
    	var _bx = px + pw - _bs;
    	var _by = py - _bs - ui(4);
    	
    	if(buttonInstant(THEME.button_hide_fill, _bx, _by, _bs, _bs, [ mx, my ], pHOVER, pFOCUS, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
    	    new_file_type = 1;
    	    new_file_name = "";
    	    
    	    tb_new_file.activate();
    	} _bx -= _bs + ui(4);
    	
    	if(new_file_type == 1) {
    	    tb_new_file.setFocusHover(pFOCUS, pHOVER);
    	    tb_new_file.drawParam(new widgetParam(px + ui(8), py + ui(8), pw - ui(16), ui(26), new_file_name, {}, [ mx, my ], x, y));
    	}
    	
    	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    	
    	var py = h / 2 + ui(16);
		var pw = lib_w;
		var ph = (h - padding) - py;
		
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(px + ui(8), py - ui(16), "Global");
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px, py, lib_w, ph);
		sp_content_all.verify(lib_w - ui(16), ph - ui(4));
    	sp_content_all.setFocusHover(pFOCUS, pHOVER);
    	sp_content_all.drawOffset(px + ui(8), py + ui(2), mx, my);
    	
    	var _bs = ui(24);
    	var _bx = px + pw - _bs;
    	var _by = py - _bs - ui(4);
    	
    	if(buttonInstant(THEME.button_hide_fill, _bx, _by, _bs, _bs, [ mx, my ], pHOVER, pFOCUS, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
    	    new_file_type = 0;
    	    new_file_name = "";
    	    
    	    tb_new_file.activate();
    	} _bx -= _bs + ui(4);
    	
    	if(curr_lib != "") {
    	    var _ind = curr_type == 0? 1 : 3;
    	    var _txt = curr_type == 0? "Copy to project" : "Copy to global";
    	    
        	if(buttonInstant(THEME.button_hide_fill, _bx, _by, _bs, _bs, [ mx, my ], pHOVER, pFOCUS, _txt, THEME.arrow, _ind, COLORS._main_icon) == 2) {
        	    if(curr_type == 0) {
            	    var _f = HLSL_LIBRARIES[$ curr_lib];
                    PROJECT.data.hlsl[$ curr_lib] = file_read_all(_f);
                    
        	    } else {
        	        var _pth = $"{DIRECTORY}Nodes/HLSL/{curr_lib}.hlsl";
        	        if(file_exists(_pth)) file_delete(_pth);
        	        filename_verify_dir(_pth);
        	        file_text_write_all(_pth, PROJECT.data.hlsl[$ curr_lib]);
        	        __initHLSL();
        	    }
        	} 
    	} else draw_sprite_ui(THEME.arrow, 1, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
    	_bx -= _bs + ui(4);
    	
    	if(new_file_type == 0) {
    	    tb_new_file.setFocusHover(pFOCUS, pHOVER);
    	    tb_new_file.drawParam(new widgetParam(px + ui(8), py + ui(8), pw - ui(16), ui(26), new_file_name, {}, [ mx, my ], x, y));
    	}
    	
    	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    	
    	var  x1 = w - padding;
    	px = px + pw + ui(8);
    	py = padding + ui(24 + 4);
    	pw = x1 - px;
    	ph = h - (py + padding);
    	
		editor.setMaxHeight(ph);
		editor.register();
		editor.setFocusHover(pFOCUS, pHOVER);
		editor.boxColor = merge_color(CDEF.main_white, CDEF.main_ltgrey, .5);
		
		editor.format = curr_lib == ""? TEXT_AREA_FORMAT._default : TEXT_AREA_FORMAT.codeHLSL;
		editor.color  = curr_lib == ""? COLORS._main_text_sub : c_white;
		var _cc       = curr_lib == ""? blank_text : curr_content;
		editor.drawParam(new widgetParam(px, py, pw, ph, _cc, {}, [ mx, my ], x, y).setFont(f_code));
		
		py = padding;
		
		if(curr_lib == "") {
		    draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
		    draw_text_add(px, py + ui(12), "no file");
		    
		} else {
		    var _icon = curr_type == 0;
		    
    		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
    		var _tw = ui(4 + 4 + 18 * _icon) + string_width(curr_lib) + ui(2 + 16 + 4);
    		var _th = ui(24);
    		
    		var _hov = pHOVER && point_in_rectangle(mx, my, px, py, px + _tw, py + _th);
    		var _aa  = .5 + .5 * _hov;
    		
    		draw_sprite_stretched_ext(THEME.box_r5_clr, 0, px, py, _tw, _th, c_white, _aa);
    		if(curr_type == 0) {
    		    gpu_set_tex_filter(true);
    		    draw_sprite_ui(THEME.globe, 0, px + ui(4 + 10), py + _th / 2, .75, .75);
    		    gpu_set_tex_filter(false);
    		}
    		
    		draw_text_add(px + ui(4 + 4 + 18 * _icon), py + _th / 2, curr_lib);
    		
    		var _hov = pHOVER && point_in_rectangle(mx, my, px + _tw - ui(22), py, px + _tw, py + _th);
    		gpu_set_tex_filter(true);
    		draw_sprite_ui(THEME.cross, 0, px + _tw - 8 - 4, py + _th / 2, .5, .5, 0, _hov? COLORS._main_value_negative : COLORS._main_icon, .5 + .5 * _hov);
    		gpu_set_tex_filter(false);
    		
    		if(_hov && mouse_press(mb_left, pFOCUS))
    		    open();
		    
		}
    }
}