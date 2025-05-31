function Panel_Nodes_Manager() : PanelContent() constructor {
	w = ui(800);
	h = ui(640);
	
	title      = "Nodes Manager";
	auto_pin   = true;
	stack      = ds_stack_create();
	selectDir  = noone;
	selectNode = noone;
	
	toSelectDir  = "";
	toSelectNode = "";
	
	static setRootDir = function(d) /*=>*/ { 
		internalDir = new DirectoryObject(d).scan(["NodeObject"]); 
		rootDir     = d;
	}
	setRootDir("D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/data/Nodes/Internal");
	
	parseArray = function(t) /*=>*/ {return (t != "" && !string_pos(",", t))? [ t ] : json_try_parse(t, [])};
	
	tb_root  = textBox_Text(function(t) /*=>*/ { setRootDir(t); }).setFont(f_p2).setColor(COLORS._main_text_sub);
	
	tb_inode = textBox_Text(   function(t) /*=>*/ { selectNode.info[$ "baseNode"]         = t;  selectNode.updateInfo(); });
	tb_name  = textBox_Text(   function(t) /*=>*/ { selectNode.info[$ "name"]             = t;  selectNode.updateInfo(); });
	tb_tips  = textArea_Text(  function(t) /*=>*/ { selectNode.info[$ "tooltip"]          = t;  selectNode.updateInfo(); });
	tb_spr   = textBox_Text(   function(t) /*=>*/ { selectNode.info[$ "spr"]              = t;  selectNode.updateInfo(); });
	tb_vers  = textBox_Number( function(t) /*=>*/ { selectNode.info[$ "pxc_version"]      = t;  selectNode.updateInfo(); });
	tb_io    = textBox_Text(   function(t) /*=>*/ { selectNode.info[$ "io"]    = parseArray(t); selectNode.updateInfo(); });
	tb_alias = textBox_Text(   function(t) /*=>*/ { selectNode.info[$ "alias"] = parseArray(t); selectNode.updateInfo(); });
	
	tb_show_recent = new checkBox(function(t) /*=>*/ { selectNode.info[$ "show_in_recent"] = !(selectNode.info[$ "show_in_recent"] ?? true); selectNode.updateInfo(); });
	
	editWidgets = [ 
		[ "inode",   tb_inode,       function() /*=>*/ {return selectNode.info[$ "baseNode"]       ?? ""}    ], 
		[ "name",    tb_name,        function() /*=>*/ {return selectNode.info[$ "name"]           ?? ""}    ], 
		[ "tips",    tb_tips,        function() /*=>*/ {return selectNode.info[$ "tooltip"]        ?? ""}    ], 
		[ "spr",     tb_spr,         function() /*=>*/ {return selectNode.info[$ "spr"]            ?? ""}    ], 
		[ "version", tb_vers,        function() /*=>*/ {return selectNode.info[$ "pxc_version"]    ?? 0}     ], 
		[ "recent",  tb_show_recent, function() /*=>*/ {return selectNode.info[$ "show_in_recent"] ?? true}  ], 
		[ "io",      tb_io,          function() /*=>*/ {return selectNode.info[$ "io"]             ?? []}    ], 
		[ "alias",   tb_alias,       function() /*=>*/ {return selectNode.info[$ "alias"]          ?? []}    ], 
	];
	
	array_foreach(editWidgets, function(e) /*=>*/ {return e[1].setFont(f_p2)});
	
	sc_folder = new scrollPane(ui(8), h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww = sc_folder.surface_w;
		var _h = 0;
		var hg = ui(20);
		var yy = _y;
		var xx = 0;
		
		var _hover = sc_folder.hover;
		var _focus = sc_folder.active;
		
		ds_stack_clear(stack);
		
		var _list = internalDir.subDir;
	    for( var i = 0, n = ds_list_size(_list); i < n; i++ ) 
	        ds_stack_push(stack, [ _list[| i], 0]);
        
		while(!ds_stack_empty(stack)) {
		    var _stack = ds_stack_pop(stack);
		    var st = _stack[0];
		    var ly = _stack[1]; 
		    
		    var _list = st.subDir;
		    for( var i = 0, n = ds_list_size(_list); i < n; i++ ) 
		        ds_stack_push(stack, [ _list[| i], ly + 1]);
		        
	        var cc = COLORS._main_text_sub;
	        if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg - 1)) {
	            cc = COLORS._main_text;
	            
	            if(mouse_press(mb_left, _focus)) {
	            	selectDir = selectDir == st? noone : st;
	            	selectNode = noone;
	            }
	        }
	        
	        if(toSelectDir == st.path) selectDir = st;
	        if(selectDir == st) cc = COLORS._main_accent;
		        
		    draw_set_text(f_p2, fa_left, fa_center, cc);
    		draw_text_add(xx + ui(ly * 16 + 8), yy + hg / 2, st.name);
            
	        _h += hg;
		    yy += hg;
		}
		
		toSelectDir = "";
		return _h;
	});
	
	sc_content = new scrollPane(ui(8), h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		if(selectDir == noone) return 0;
		
		var ww = sc_content.surface_w;
		var _h = 0;
		var hg = ui(20);
		var yy = _y;
		var xx = 0;
		
		var _hover = sc_content.hover;
		var _focus = sc_content.active;
		
		var _list = selectDir.content;
		
		for( var i = 0, n = ds_list_size(_list); i < n; i++ ) {
		    var _con = _list[| i];
		    
		    var cc = COLORS._main_text_sub;
		    if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg - 1)) {
	            cc = COLORS._main_text;
	            
	            if(mouse_press(mb_left, _focus))
	            	selectNode = selectNode == _con? noone : _con;
	        }
	        
	        if(toSelectNode == _con.path) selectNode = _con;
	        if(selectNode == _con) cc = COLORS._main_accent;
		        
		    draw_set_text(f_p2, fa_left, fa_center, cc);
		    draw_text_add(xx, yy + hg / 2, _con.name);
		    
		    _h += hg;
		    yy += hg;
		}
		
		toSelectNode = "";
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var _pd = padding;
		
		// Root
		var wdh = TEXTBOX_HEIGHT;
		var ndx = _pd;
		var ndy = _pd + wdh + ui(8);
		
		tb_root.setFocusHover(pFOCUS, pHOVER);
		tb_root.draw(_pd, _pd, w - _pd * 2, wdh, rootDir, [ mx, my ] );
		
		// Editor
		var _edit_w = ui(320);
		
		var bw = _edit_w;
		var bh = TEXTBOX_HEIGHT;
		var bx = w - _edit_w - _pd;
		var by = ndy;
		
		if(buttonInstant(THEME.button_def, bx, by, bw, bh, [ mx, my ], pHOVER, pFOCUS) == 2)
			__test_load_all_nodes();
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		draw_text_add(bx + bw / 2, by + bh / 2, "Load All Nodes");
		by += bh + ui(4);
		
		if(selectDir != noone) {
			if(buttonInstant(THEME.button_def, bx, by, bw, bh, [ mx, my ], pHOVER, pFOCUS) == 2) {
				fileNameCall("", function(txt) /*=>*/ {
					if(txt == "") return;
					var _inode = string_trim(txt, ["/"])
					
					var _dirpath = $"{selectDir.path}/{_inode}";
					directory_create(_dirpath);
					
					var _infpath = $"{_dirpath}/info.json";
					var _newNode = {
						name:        "",
					    spr:         $"s_{string_lower(_inode)}",
					    baseNode:    $"{_inode}",
					    pxc_version: VERSION,
					}
					json_save_struct(_infpath, _newNode);
					setRootDir(rootDir);
					
					toSelectDir  = selectDir.path;
					toSelectNode = _dirpath;
					
				}).setName("BaseNode")
			}
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
			draw_text_add(bx + bw / 2, by + bh / 2, "Add Node");
			by += bh + ui(4);
		}
		
		if(selectNode != noone) {
			by += ui(8);
			var _info = selectNode.info;
			
			for( var i = 0, n = array_length(editWidgets); i < n; i++ ) {
				var _editw = editWidgets[i];
				var _tit   = _editw[0];
				var _wdg   = _editw[1];
				var _dat   = _editw[2]();
				
				var _tw = ui(64);
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(bx, by + bh / 2, _tit);
				
				var wgx = bx + _tw;
				var wgw = bw - _tw;
				
				if(_tit == "version") {
					wgw -= ui(32);
					
					if(buttonInstant(THEME.button_hide_fill, wgx + wgw + ui(4), by, ui(28), bh, [ mx, my ], pHOVER, pFOCUS, "", THEME.icon_default) == 2) {
						selectNode.info[$ "pxc_version"] = 1_18_09_0;
						selectNode.updateInfo();
					}
				}
				
				_wdg.setFocusHover(pFOCUS, pHOVER);
				var _pa = new widgetParam(wgx, by, wgw, bh, _dat, {}, [ mx, my ])
				           .setFont(f_p2);
				var _wh = _wdg.drawParam(_pa);
				
				by += _wh + ui(4);
			}
			
			by += ui(4);
			if(buttonInstant(THEME.button_def, bx, by, bw, bh, [ mx, my ], pHOVER, pFOCUS) == 2)
				selectNode.updateInfo();
			
			draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
			draw_text_add(bx + bw / 2, by + bh / 2, "Update");
			by += bh + ui(4);
		}
		
		// Lists
		var con_w = w - _edit_w - _pd * 2 - ui(16) - ui(8);
		var con_h = h - _pd - ndy - ui(16);
		
		var ndw = con_w + ui(16);
		var ndh = con_h + ui(16);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, ndx, ndy, ndw, ndh);
		
		var _fol_w = con_w / 2 - ui(6);
		sc_folder.verify(_fol_w, con_h);
		sc_folder.setFocusHover(pFOCUS, pHOVER);
		sc_folder.drawOffset(ndx + ui(8), ndy + ui(8), mx, my);
		
		var _cnt_w = con_w / 2 - ui(6);
		sc_content.verify(_cnt_w, con_h);
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.drawOffset(ndx + ui(8) + _fol_w + ui(12), ndy + ui(8), mx, my);
		
	}
	
}