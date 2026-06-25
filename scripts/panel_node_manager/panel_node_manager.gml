function Panel_Nodes_Manager() : PanelContent() constructor {
	#region data
		w = ui(1200);
		h = ui(900);
		
		edit_w = ui(400);
		
		title      = "Nodes Manager";
		auto_pin   = true;
		stack      = ds_stack_create();
		selectDir  = noone;
		selectNode = noone; 
		
		loadall_comfirm = false;
		
		static update = function() /*=>*/ {return selectNode.updateInfo()};
	#endregion
		
	#region directories
		toSelectDir  = "";
		toSelectNode = "";
			
		static setRootDir = function(d) /*=>*/ { 
			internalDir = new DirectoryObject(d).scan(["NodeObject"]); 
			rootDir     = d;
		} 
		
		setRootDir("D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datasrc/Nodes/Internal");
		sourceDir = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/scripts";
	#endregion
	
	#region editors
		arr_io  = [ "surface" ];
		arr_ali = [];
		arr_tag = [ "Patreon" ];
		
		parseArray = function(t) /*=>*/ {return (t != "" && !string_pos(",", t))? [ t ] : json_try_parse(t, [])};
		
		tb_root   = textBox_Text(function(t) /*=>*/ { setRootDir(t);    }).setFont(f_p2);
		tb_search = textBox_Text(function(t) /*=>*/ { searchContent(t); }).setFont(f_p2).setEmpty().setAutoupdate();
		
		tb_inode = textBox_Text(   function(t) /*=>*/ { selectNode.info[$ "baseNode"]    = t;  update(); });
		tb_name  = textBox_Text(   function(t) /*=>*/ { selectNode.info[$ "name"]        = t;  update(); });
		tb_tips  = textArea_Text(  function(t) /*=>*/ { selectNode.info[$ "tooltip"]     = t;  update(); });
		tb_spr   = textBox_Text(   function(t) /*=>*/ { selectNode.info[$ "spr"]         = t;  update(); });
		tb_vers  = textBox_Number( function(t) /*=>*/ { selectNode.info[$ "pxc_version"] = t;  update(); });
		tb_io    = new textArrayBox(function() /*=>*/ {return selectNode.info[$ "io"]    ?? []}, arr_io,  function(a) /*=>*/ { selectNode.info[$ "io"]    = a; update(); }).setAddable();
		tb_alias = new textArrayBox(function() /*=>*/ {return selectNode.info[$ "alias"] ?? []}, arr_ali, function(a) /*=>*/ { selectNode.info[$ "alias"] = a; update(); }).setAddable();
		ta_tags  = new textArrayBox(function() /*=>*/ {return selectNode.info[$ "tags"]  ?? []}, arr_tag, function(a) /*=>*/ { selectNode.info[$ "tags"]  = a; update(); }).setAddable();
		
		cb_recent = new checkBox(function(t) /*=>*/ { selectNode.info[$ "show_in_recent"] = !(selectNode.info[$ "show_in_recent"] ?? true); update(); });
		cb_dep    = new checkBox(function(t) /*=>*/ { selectNode.info[$ "deprecated"]     = !(selectNode.info[$ "deprecated"] ?? false);    update(); });
		
		editWidgets = [ 
			[ "inode",      tb_inode,  function() /*=>*/ {return selectNode.info[$ "baseNode"]       ?? ""}    ], 
			[ "name",       tb_name,   function() /*=>*/ {return selectNode.info[$ "name"]           ?? ""}    ], 
			[ "tips",       tb_tips,   function() /*=>*/ {return selectNode.info[$ "tooltip"]        ?? ""}    ], 
			[ "spr",        tb_spr,    function() /*=>*/ {return selectNode.info[$ "spr"]            ?? ""}    ], 
			[ "version",    tb_vers,   function() /*=>*/ {return selectNode.info[$ "pxc_version"]    ?? 0}     ], 
			[ "recent",     cb_recent, function() /*=>*/ {return selectNode.info[$ "show_in_recent"] ?? true}  ], 
			[ "io",         tb_io,     function() /*=>*/ {return selectNode.info[$ "io"]             ?? []}    ], 
			[ "alias",      tb_alias,  function() /*=>*/ {return selectNode.info[$ "alias"]          ?? []}    ], 
			[ "tags",       ta_tags,   function() /*=>*/ {return selectNode.info[$ "tags"]           ?? []}    ], 
			[ "deprecated", cb_dep,    function() /*=>*/ {return selectNode.info[$ "deprecated"]     ?? false} ], 
		];
		font = f_p3;
		
		array_foreach(editWidgets, function(e) /*=>*/ {return e[1].setFont(f_p2)});
	#endregion
	
	#region raw code data
		script_name_exception = {
			"Node_3D_Mesh_Vertex_Points":   "node_3d_vertex_points",
			"Node_Fn_WaveTable":            "node_fn_wave_table",
			"Node_Wiggler":                 "node_fn_wiggler",
			"Node_Blend_Height":            "node_height_blend",
			"Node_Color_Separate":          "node_separate_color",
			"Node_Hough_Transform":         "node_hough",
			"Node_Dotted":                  "node_dot_pattern",
			"Node_Gradient_Points_N":       "node_gradient_point_n",
			"Node_Hilbert":                 "node_hilbert_curve",
			"Node_Honeycomb_Noise":         "node_honey_noise",
			"Node_Kisrhombille":            "node_grid_kisrhombille",
			"Node_GMRoom":                  "node_gm_room",
			"Node_Image_mp4":               "node_mp4",
			"Node_Tile_Convert":            "node_tiler_convert",
			"Node_Tile_Drawer":             "node_tiler",
			"Node_Tile_Render":             "node_tiler_render",
			"Node_Tile_Rule":               "node_tiler_rule",
			"Node_Tile_Tilemap_Export":     "node_tiler_export",
			"Node_Tile_Tileset":            "node_tiler_tileset",
			"Node_Iterator_Each_Length":    "node_iterator_each_size",
			"Node_MK_Tree_Path_Root":       "node_mk_tree_root_path",
			"Node_PB_Draw_Curve":           "node_pb_draw_line_curve",
			"Node_PB_Draw_Quadrilateral":   "node_pb_draw_quadri",
			"Node_PB_FX_Bevel":             "node_pb_filter_bevel",
			"Node_PB_FX_Extrude":           "node_pb_filter_extrude",
			"Node_PB_FX_Highlight":         "node_pb_filter_highlight",
			"Node_PB_FX_Shine":             "node_pd_filter_shine",
			"Node_Matrix_Set_Vector":       "node_matric_set_vector",
			"Node_Matrix_Transpose":        "node_matrix_tranpose",
			"Node_Point_3D_Camera":         "node_points_3d_camera",
			"Node_Point_SDF":               "node_points_sdf",
			"Node_Scatter_Point_Fibonacci": "node_scatter_point_fibo",
			"Node_Atlas_Struct":            "node_atlas_to_struct",
			"Node_Vector_Cart_To_Polar":    "node_vec2_cart_to_polar",
			"Node_Vector_Polar_To_Cart":    "node_vec2_polar_to_cart",
			"Node_VerletSim_Inline":        "node_verletSim_group_inline",
			"Node_pSystem_3D_Trail":        "node_psystem_3d_trail_path",
		}
	#endregion
	
	#region search
		searching    = false;
		searchText   = "";
		searchTextL  = "";
		
		function searchContent(_str) {
			searching   = _str != "";
			searchText  = _str;
			searchTextL = string_lower(_str);
		}
	#endregion
	
	////- Draw
	
	function setNode(_node) {
		selectNode = _node;
		if(selectNode) selectNode.getInfo();
		return self;
	}
	
	#region draw
		function drawDirectory(_ind, _dir, yy, _m) {
			var _hover = sc_folder.hover;
			var _focus = sc_folder.active;
			
			var _list = _dir.subDir;
			
			var col = 1;
			var cl  = 0;
			
			var sw = sc_folder.surface_w;
			var ww = sw / col;
			var hg = line_get_height(font, 2);
			var hh = hg;
			
		    for( var i = 0, n = array_length(_list); i < n; i++ ) {
		        var dr = _list[i];
		        
		        if(!array_empty(dr.subDir) && cl) {
		        	cl  = 0;
	            	hh += hg;
			    	yy += hg;
		        }
		        
			    var xx = ww * cl;
			    var _h = hg;
			    
		        var cc = COLORS._main_text_sub;
		        if(_hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + hg - 1)) {
		            cc = COLORS._main_text;
		            
		            if(mouse_lpress(_focus)) {
		            	selectDir  = selectDir == dr? noone : dr;
		            	setNode(noone);
		            }
		        }
		        
		        if(searching) {
		        	var _contain = string_pos(searchTextL, string_lower(dr.name));
		        	for( var j = 0, m = array_length(dr.content); j < m; j++ ) {
		        		var _con = dr.content[j];
		        		
		        		if(searchTextL == string_lower(_con.name)) {
		        			if(selectDir != dr)    selectDir = dr;
		        			if(selectNode != _con) setNode(_con);
		        		}
		        		
		        		if(string_pos(searchTextL, string_lower(_con.name)))  
				        	_contain = true;
		        	}
		        	
		        	if(_contain) cc = COLORS._main_text;
		        }
		        	
		        if(toSelectDir == dr.path) selectDir = dr;
		        if(selectDir   == dr) cc = COLORS._main_accent;
			    
			    draw_set_text(font, fa_left, fa_center, cc);
	    		draw_text_add(xx + ui(8 + 8 * _ind), yy + hg / 2, dr.name);
	            
	            if(!array_empty(dr.subDir)) {
		        	hh += _h;
			    	yy += _h;
		            
	            	var sh = drawDirectory(_ind + 1, dr, yy, _m);
	            	// draw_sprite_stretched_ext(THEME.ui_panel, 1, 0, yy - _h + ui(2), sw, sh + _h - ui(2), COLORS._main_icon, .5);
	            	
	            	cl  = 0;
	            	hh += sh;
			    	yy += sh;
			    	
	            } else {
	            	cl++;
		            if(cl >= col) {
		            	cl = 0;
			        	hh += _h;
				    	yy += _h;
		            }
		            
	            }
	            
			}
			
			if(cl == 0) {
				hh -= hg;
			}
			
			return hh;
		}
		
		sc_folder  = new scrollPane(ui(8), h, function(_y, _m) /*=>*/ {
			draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
			
			var hh = drawDirectory(0, internalDir, _y, _m);
			toSelectDir = "";
			
			return hh;
		});
		
		sc_content = new scrollPane(ui(8), h, function(_y, _m) /*=>*/ {
			draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
			if(selectDir == noone) return 0;
			if(!selectDir.scanned) selectDir.scan(["NodeObject"]); 
			
			var ww = sc_content.surface_w;
			var _h = 0;
			var hg = line_get_height(font, 2);
			var yy = _y;
			var xx = 0;
			
			var _hover = sc_content.hover;
			var _focus = sc_content.active;
			
			var _list = selectDir.content;
			
			for( var i = 0, n = array_length(_list); i < n; i++ ) {
			    var _con = _list[i];
			    
			    var cc = COLORS._main_text_sub;
			    if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg - 1)) {
		            cc = COLORS._main_text;
		            
		            if(mouse_lpress(_focus))
		            	setNode(selectNode == _con? noone : _con);
		        }
		        
		        if(searching && string_pos(searchTextL, string_lower(_con.name)))  
		        	cc = COLORS._main_text;
		        
		        if(toSelectNode == _con.path) setNode(_con);
		        if(selectNode == _con) cc = COLORS._main_accent;
		        
			    draw_set_text(font, fa_left, fa_center, cc);
			    draw_text_add(xx, yy + hg / 2, _con.name);
			    
			    _h += hg;
			    yy += hg;
			}
			
			toSelectNode = "";
			return _h;
		});
	#endregion
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var _pd = padding;
		var m = [ mx, my ];
		
		// Root
		var rx  = x;
		var ry  = y;
		
		var wx  = _pd;
		var wy  = _pd;
		var sdw = ui(240);
		var wdw = w - _pd * 2 - sdw - ui(8);
		var wdh = TEXTBOX_HEIGHT;
		
		var ndx = _pd;
		var ndy = _pd + wdh + ui(8);
		
		tb_root.setFocusHover(pFOCUS, pHOVER);
		tb_root.draw(wx, wy, wdw, wdh, rootDir, m );
		
		tb_search.setFocusHover(pFOCUS, pHOVER);
		tb_search.draw(wx + wdw + ui(8), wy, sdw, wdh, searchText, m );
		
		// Editor
		var bw = edit_w;
		var bh = TEXTBOX_HEIGHT;
		var bx = w - edit_w - _pd;
		var by = ndy;
		
		draw_set_font(f_p2);
		var bt = loadall_comfirm? "Comfirm Load All Nodes" : "Load All Nodes";
		var b  = buttonTextInstant(true, THEME.button_def, bx, by, bw, bh, m, pHOVER, pFOCUS, "", bt);
		if(b == 0) loadall_comfirm = false;
		if(b == 2) {
			if(loadall_comfirm) __test_load_all_nodes();
			else loadall_comfirm = true;
		}
		by += bh + ui(4);
		
		if(selectDir != noone) {
			draw_set_font(f_p2);
			if(buttonTextInstant(true, THEME.button_def, bx, by, bw, bh, m, pHOVER, pFOCUS, "", "Add Node") == 2) {
				fileNameCall("", function(txt) /*=>*/ {
					if(txt == "") return;
					var _inode = string_trim(txt, ["/"])
					var _lnode = string_lower(_inode);
					
					var _srcFile = $"{sourceDir}/{_lnode}/{_lnode}.gml";
					if(!file_exists(_srcFile)) {
						noti_warning($"Source file {_srcFile} not found.");
						return;
					}
					
					var _dirpath = $"{selectDir.path}/{_inode}";
					directory_create(_dirpath);
					
					var _name = "";
					
					var _ff = file_text_open_read(_srcFile);
					while(!file_text_eof(_ff)) {
						var _l = file_text_readln(_ff);
						    _l = string_trim(_l);
						    
						if(string_starts_with(_l, "name") && string_pos("=", _l)) {
							var _spr = string_splice(_l, "=");
							var _nam = string_trim(_spr[1], [" ", ";", "\""]);
							_name = _nam;
							break;
						}
					}
					file_text_close(_ff);
					
					var _infpath = $"{_dirpath}/info.json";
					var _newNode = {
						name:        _name,
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
			by += bh + ui(4);
		}
		
		if(selectNode != noone) {
			by += ui(8);
			var _info = selectNode.getInfo();
			
			for( var i = 0, n = array_length(editWidgets); i < n; i++ ) {
				var _editw = editWidgets[i];
				var _tit   = _editw[0];
				var _wdg   = _editw[1];
				var _dat   = _editw[2]();
				
				var _tw = ui(96);
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(bx, by + bh / 2, _tit);
				
				var wgx = bx + _tw;
				var wgw = bw - _tw;
				
				if(_tit == "version") {
					wgw -= ui(32);
					
					if(buttonInstant(THEME.button_hide_fill, wgx + wgw + ui(4), by, ui(28), bh, m, pHOVER, pFOCUS, "", THEME.icon_default) == 2) {
						selectNode.info[$ "pxc_version"] = 1_18_09_0;
						update();
					}
				}
				
				_wdg.setFocusHover(pFOCUS, pHOVER);
				var _pa = new widgetParam(wgx, by, wgw, bh, _dat, undefined, m, rx, ry)
				           .setFont(f_p2);
				var _wh = _wdg.drawParam(_pa);
				
				by += _wh + ui(4);
			}
			
			by += ui(4);
			
			draw_set_font(f_p2);
			if(buttonTextInstant(true, THEME.button_def, bx, by, bw, bh, m, pHOVER, pFOCUS, "", "Update") == 2)
				update();
			
			by += bh + ui(4);
		}
		
		// Lists
		var con_w = w - edit_w - _pd * 2 - ui(16) - ui(8);
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
		
		// Misc tools
		var bw = edit_w;
		var bh = line_get_height(f_p2, 4);
		var bx = w - edit_w - _pd;
		var by = h - _pd - bh;
		
		// draw_set_font(f_p3);
		// if(buttonTextInstant(true, THEME.button_def, bx, by, bw, bh, m, pHOVER, pFOCUS, "", "Scan Enums") == 2)
		// 	scanEnum();
		// by -= bh + ui(4);
		
	}
	
	////- Actions
	
	static scanEnum = function(_dir = internalDir) {
		for( var i = 0, n = array_length(_dir.content); i < n; i++ ) {
			var _cont = _dir.content[i];
			var _info = _cont.getInfo();
			var _base = _info.baseNode;
			var _file = has(script_name_exception, _base)? script_name_exception[$ _base] : string_lower(_base);
			
			var _scrPath = $"D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/scripts/{_file}/{_file}.gml";
			if(!file_exists(_scrPath)) { print($"{_base}"); continue; }
			
			var _txt = $"==== Scanning: {_base} ====";
			var _prt = false;
			var f = file_text_open_read(_scrPath);
			
			while(!file_text_eof(f)) {
				var l = file_text_readln(f);
				if(string_starts_with(l, "newOutput")) break;
				
				if(string_pos("nodeValue_EButton", l)) {
					_txt += $"\n{l}";
					_prt  = true;
				}
				
				if(string_pos("nodeValue_EScroll", l)) {
					_txt += $"\n{l}";
					_prt  = true;
				}
			}
			
			file_text_close(f);
			if(_prt) print(_txt);
			
		}
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ )
			scanEnum(_dir.subDir[i]);
	}
}