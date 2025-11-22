#region ___funtion calls
	function panel_collection_search_toggle()		{ CALL("collection_search_toggle");		PANEL_COLLECTION.search_toggle();		}
	function panel_collection_replace()				{ CALL("collection_replace");			PANEL_COLLECTION.replace();				}
	function panel_collection_edit_meta()			{ CALL("collection_edit_meta");			PANEL_COLLECTION.edit_meta();			}
	function panel_collection_update_thumbnail()	{ CALL("collection_update_thumbnail");	PANEL_COLLECTION.update_thumbnail();	}
	function panel_collection_delete_collection()	{ CALL("collection_delete_collection");	PANEL_COLLECTION.delete_collection();	}
	function panel_collection_edit_default()        { CALL("collection_edit_collection");   PANEL_COLLECTION.edit_collection();     }
	
	function panel_collection_steam_file_upload()	{ CALL("collection_steam_file_upload");	PANEL_COLLECTION.steam_file_upload();	}
	function panel_collection_steam_file_update()	{ CALL("collection_steam_file_update");	PANEL_COLLECTION.steam_file_update();	}
	function panel_collection_steam_unsubscribe()	{ CALL("collection_steam_unsubscribe");	PANEL_COLLECTION.steam_unsubscribe();	}
	
	function panel_collection_toggle_default()      { CALL("collection_toggle_default");    PANEL_COLLECTION.toggle_default();      }
	
	function __fnInit_Collection() {
		registerFunction("Collection", "Toggle Search",     "F", MOD_KEY.ctrl, panel_collection_search_toggle     ).setMenu("collection_search_toggle")
		registerFunction("Collection", "Replace with Selecting","",MOD_KEY.none, panel_collection_replace         ).setMenu("collection_replace")
		registerFunction("Collection", "Edit Meta",         "",  MOD_KEY.none, panel_collection_edit_meta         ).setMenu("collection_edit_meta")
		registerFunction("Collection", "Edit Collection",   "",  MOD_KEY.none, panel_collection_edit_default      ).setMenu("collection_edit_collection",   THEME.group_s)
		registerFunction("Collection", "Update Thumbnail",  "",  MOD_KEY.none, panel_collection_update_thumbnail  ).setMenu("collection_update_thumbnail")
		registerFunction("Collection", "Delete Collection", "",  MOD_KEY.none, panel_collection_delete_collection ).setMenu("collection_delete_collection",	THEME.cross)
		
		registerFunction("Collection", "Upload To Workshop",	     "", MOD_KEY.none, panel_collection_steam_file_upload ).setMenu("collection_upload_to_steam", 	THEME.workshop_upload)
		registerFunction("Collection", "Update Content to Workshop", "", MOD_KEY.none, panel_collection_steam_file_update ).setMenu("collection_update_steam",    	THEME.workshop_update)
		registerFunction("Collection", "Unsubscribe",		         "", MOD_KEY.none, panel_collection_steam_unsubscribe ).setMenu("collection_unsubscribe")
		
		registerFunction("Collection", "Toggle Default",    "", MOD_KEY.none, panel_collection_toggle_default ).setMenu("collection_toggle_default")
	}
	
#endregion

function Panel_Collection() : PanelContent() constructor {
	title = __txt("Collections");
	PANEL_COLLECTION = self;
	
	#region dimension
		expandable = false;
		
		group_w          = ui(140);
		group_w_dragging = false;
		group_w_sx       = false;
		group_w_mx       = false;
		
		top_h     = ui(36);
		content_w = w - ui( 8) - group_w;
		content_h = h - top_h - ui(8);
		
		min_w = group_w + ui(40);
		min_h = ui(40);
	#endregion
	
	#region pages
		roots    = [ ["Collections", COLLECTIONS], ["Assets", global.ASSETS], ["Projects", STEAM_PROJECTS], ["Nodes", ALL_NODES] ];
		pageStr  = array_create_ext(array_length(roots), function(i) /*=>*/ {return roots[i][0]});
		sc_pages = new scrollBox(pageStr, function(i) /*=>*/ { setPage(i); }).setType(1).setAlign(fa_left);
		
		page     = 0;
		root     = roots[page][1];
		context  = root;
		
		file_dragging = noone;
		_menu_node    = noone;
		updated_path  = noone;
		updated_prog  = 0;
		data_path     = "";
			
		grid_size     = ui(52);
		grid_size_to  = grid_size;
		
	#endregion
	
	#region search
		searching     = false;
		search_string = "";
		search_list   = [];
		
		tb_search = textBox_Text(function(str) /*=>*/ { search_string = string(str); doSearch(); }).setAutoupdate().setFont(f_p3);
		
		function doSearch() {
			var search_lower = string_lower(search_string);
			search_list = [];
			
			switch(pageStr[page]) {
				case "Collections" :
				case "Assets" : 
					searchCollection(search_list, search_string);
					break;
					
				case "Projects" : 
					var st = ds_stack_create();
					var ll = ds_priority_create();
					
					for( var i = 0, n = array_length(STEAM_PROJECTS); i < n; i++ ) {
						var _nd = STEAM_PROJECTS[i];
							
						var match = string_partial_match(string_lower(_nd.name), search_lower);
						if(match == -9999) continue;
						
						ds_priority_add(ll, _nd, match);
					}
					
					repeat(ds_priority_size(ll))
						array_push(search_list, ds_priority_delete_max(ll));
					
					ds_priority_destroy(ll);
					ds_stack_destroy(st);
					break;
					
				case "Nodes" : 
					var pr_list    = ds_priority_create();
					var search_map = ds_map_create();
					
					for(var i = 0; i < array_length(NODE_CATEGORY); i++) {
						var cat = NODE_CATEGORY[i];
						
						if(!struct_has(cat, "list")) continue;
						if(!array_empty(cat[$ "filter"])) continue;
						
						var _content = cat.list;
						for(var j = 0; j < array_length(_content); j++) {
							var _node = _content[j];
							
							if(is_string(_node))				      continue;
							if(ds_map_exists(search_map, _node))      continue;
							if(!is(_node, NodeObject))     continue;
							if(_node.patreon && !IS_PATREON)          continue;
							if(_node.deprecated)					  continue;
							
							var match = string_partial_match(string_lower(_node.getName()), search_lower);
							var param = "";
							
							for( var k = 0; k < array_length(_node.tags); k++ ) {
								var mat = string_partial_match(_node.tags[k], search_lower) - 10;
								if(mat > match) {
									match = mat;
									param = _node.tags[k];
								}
							}
							
							if(match == -9999) continue;
							
							ds_priority_add(pr_list, _node, match);
							search_map[? _node] = 1;
						}
					}
					
					ds_map_destroy(search_map);
					
					repeat(ds_priority_size(pr_list))
						array_push(search_list, ds_priority_delete_max(pr_list));
					
					ds_priority_destroy(pr_list);
					break;
			}
		}
		
		function search_toggle() {
			searching = !searching;
			if(!searching) return;
			
			doSearch(); 
			tb_search.activate(); 
		}
	
	#endregion
	
	#region ++++++++++++ Actions ++++++++++++
		function replace() { 
			if(_menu_node == noone) return;
			saveCollection(PANEL_INSPECTOR.getInspecting(), _menu_node.path, false, _menu_node.meta);
		}
		
		function edit_meta() { 
			if(_menu_node == noone) return;
			
			var dia  = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(-320));
			var meta = _menu_node.getMetadata();
			if(meta != noone && meta != undefined) 
				dia.meta = meta;
			
			dia.node = PANEL_INSPECTOR.getInspecting();
			dia.data_path = data_path;
			dia.updating  = _menu_node;
			dia.doExpand();
		}
		
		function update_thumbnail() { 
			if(_menu_node == noone) return;
			
			var _path = _menu_node.path;
			var preview_surface = PANEL_PREVIEW.getNodePreviewSurface();
			if(!is_surface(preview_surface)) {
				noti_warning("Please send any node to preview panel to use as a thumbnail.")
				return;
			}
			
			var icon_path = string_replace(_path, filename_ext(_path), ".png");
			surface_save_safe(preview_surface, icon_path);
			
			refreshContext();
		}
		
		function toggle_default() { 
			if(_menu_node == noone) return;
			
			var _meta = _menu_node.meta;
			var _path = _menu_node.meta_path;
			
			_meta.isDefault = !_meta.isDefault;
			json_save_struct(_path, _meta, true);
			
			refreshContext();
		}
		
		function delete_collection() {
			if(_menu_node == noone) return;
			
			file_delete(_menu_node.path);
			refreshContext();
		}
		
		function edit_collection() {
			if(_menu_node == noone) return;
			
			var _cont = json_load_struct(_menu_node.path);
			var _proj = new Runner().appendMap(_cont).fetchIO();
			    _proj.project.path = _menu_node.path;
			
			var _graph = new Panel_Graph(_proj.project);
			    _graph.setSize(ui(800), ui(480));
			    _graph.setTitle(_menu_node.name);
			    _graph.noGlobal();
			    _graph.addContext(_proj.io_node);
			
			var _dia = dialogPanelCall(_graph);
			
			_graph.title_actions = [
				[ "Save and Close", [ THEME.toolbar_check, 0, c_white ], function(d) /*=>*/ {
					saveCollection(d.project.io_node, d.path, false);
					instance_destroy(d.dialog);
				}, { project: _proj, path: _menu_node.path, dialog: _dia}  ], 
				
				[ "Cancel", [ THEME.toolbar_check, 1, c_white ], function(d) /*=>*/ { instance_destroy(d); }, _dia ], 
			];
			
		}
		
		function steam_file_upload() { 
			if(_menu_node == noone) return;
			
			var dia = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(-320));
			var meta = _menu_node.getMetadata();
			if(meta != noone && meta != undefined) 
				dia.meta = meta;
			
			dia.data_path	= data_path;
			dia.ugc			= 1;
			dia.updating	= _menu_node;
			dia.doExpand();
		}
		
		function steam_file_update() { 
			if(_menu_node == noone) return;
			
			var _node = PANEL_INSPECTOR.getInspecting();
			if(_node == noone) {
				noti_warning("No node selected. Select a node in graph panel to update workshop content.");
				return;
			}
			var dia = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(-320));
			var meta = _menu_node.getMetadata();
			if(meta != noone && meta != undefined) 
				dia.meta = meta;
			
			dia.node		= _node;
			dia.data_path	= data_path;
			dia.ugc			= 2;
			dia.updating	= _menu_node;
			dia.doExpand();
		}
		
		function steam_unsubscribe() {
			if(_menu_node == noone) return;
			
			var meta   = _menu_node.getMetadata();
			var del_id = meta.file_id;
			if(del_id == 0) return;
			
			for( var i = 0; i < array_length(STEAM_COLLECTION); i++ ) {
				if(STEAM_COLLECTION[i].getMetadata().file_id != del_id) continue;
				array_delete(STEAM_COLLECTION, i, 1);
				break;
			}
			
			steam_ugc_unsubscribe_item(del_id);
		}
		
	#endregion
	
	static initMenu = function() {
		if(_menu_node == noone) return;
		var meta = _menu_node.getMetadata();
		
		contentMenu = [];
		
		if(meta == noone || meta.file_id == 0) {
			contentMenu = [
				MENU_ITEMS.collection_edit_collection,
				MENU_ITEMS.collection_edit_meta,
				MENU_ITEMS.collection_replace,
				MENU_ITEMS.collection_update_thumbnail,
			];
			
			if(TESTING) array_push(contentMenu, MENU_ITEMS.collection_toggle_default);
			
			array_append(contentMenu, [
				-1,
				MENU_ITEMS.collection_delete_collection,
			]);
		} 
		
		if(STEAM_ENABLED) {
			if(!array_empty(contentMenu)) array_push(contentMenu, -1);
			
			if(meta.file_id == 0) {
				array_push(contentMenu, MENU_ITEMS.collection_upload_to_steam);
				
			} else {
				if(meta.author_steam_id && meta.author_steam_id == STEAM_USER_ID)
					array_push(contentMenu, MENU_ITEMS.collection_update_steam);
					
				array_push(contentMenu, MENU_ITEMS.collection_unsubscribe, -1);
				array_push(contentMenu, menuItem( __txt("View on Workshop..."), function(_fid) /*=>*/ {
					var _p = new Panel_Steam_Workshop().navigate({ type: "fileid", fileid: _fid });
                    dialogPanelCall(_p);
                    
				}, THEME.steam_invert_24).setParam(meta.file_id) );
			}
		}
	} initMenu();
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	contentView = 0;
	contentPane = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var content;
		var steamNode = [];
		
		switch(page) {
		    case 0 :
    		    if(!COLLECTIONS.scanned) 
    				COLLECTIONS.scan([".json", ".pxcc"]); 
    			
    			if(context == root) content = STEAM_COLLECTION;
    			else				content = context.content;
    			
    			for( var i = 0; i < array_length(STEAM_COLLECTION); i++ ) {
    				var meta = STEAM_COLLECTION[i].meta;	
    				if(array_exists(meta.tags, context.name))
    					array_push(steamNode, STEAM_COLLECTION[i]);	
    			}
		        break;
		       
	        case 1 : content = context.content;     break;
	        case 2 : content = context;             break;
		}
		
		if(searching) content = search_list;
		
		var node_list  = array_length(content);
		var node_count = node_list + array_length(steamNode);
		var frame	   = PREFERENCES.collection_animated? current_time * PREFERENCES.collection_preview_speed / 3000 : 0;
		var _cw		   = contentPane.surface_w;
		var _hover	   = pHOVER && contentPane.hover;
		var hh         = 0;
		
		updated_prog   = lerp_linear(updated_prog, 0, 0.01);
		
		if(contentView == 0) {
			var grid_width = PREFERENCES.collection_label? round(grid_size * 1.25) : grid_size;
			var grid_space = ui(6);
			
			var col = max(1, floor(_cw / (grid_width + grid_space)));
			var row = ceil(node_count / col);
			var yy  = _y + grid_space;
			var name_height = 0;
				
			grid_width = round(contentPane.surface_w - grid_space) / col - grid_space;
			
			hh += grid_space;
			
			for(var i = 0; i < row; i++) {
				name_height = 0;
				
				for(var j = 0; j < col; j++) {
					var index = i * col + j;
					if(index >= node_count) break;
					
					var _node = index < node_list? content[index] : steamNode[index - node_list];
					var _nx   = grid_space + (grid_width + grid_space) * j;
					var _boxx = _nx + (grid_width - grid_size) / 2;
					_boxx = round(_boxx);
					
					var gr_x1 = _boxx + grid_size;
					var gr_y1 = yy + grid_size;
					
					if(has(_node, "getSpr")) _node.getSpr();
					
					if(yy + grid_size >= 0 && yy <= contentPane.surface_h) {
						BLEND_OVERRIDE
						draw_sprite_stretched_ext(THEME.node_bg, 0, _nx, yy, grid_width, grid_size, CDEF.main_black);
						BLEND_NORMAL
						draw_sprite_stretched_ext(THEME.node_bg, 1, _nx, yy, grid_width, grid_size, CDEF.main_dkgrey);
						
						var meta = has(_node, "getMetadata")? _node.getMetadata() : noone;
						if(_hover && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
							contentPane.hover_content = true;
							draw_sprite_stretched_ext(THEME.node_bg, 1, _nx, yy, grid_width, grid_size, COLORS._main_accent, 1);
							
							if(mouse_press(mb_left, pFOCUS)) {
								var _typ = "";
								switch(_node.type) {
									case FILE_TYPE.collection : _typ = "Collection"; break;
									case FILE_TYPE.assets     : _typ = "Asset";      break;
									case FILE_TYPE.project    : _typ = "Project";    break;
								}
								
								DRAGGING = { type : _typ, data : _node };
							}
							
							if(!DEMO && mouse_press(mb_right, pFOCUS)) {
								_menu_node = _node;
								initMenu();
								menuCall("collection_menu", contentMenu);	
							}
							
							if(!instance_exists(o_dialog_menubox) && meta != noone && meta != undefined) {
								meta.thumbnail = _node.spr;
								TOOLTIP = meta;
							}
						}
						
						if(_node.path == updated_path && updated_prog > 0) 
							draw_sprite_stretched_ext(THEME.node_bg, 1, _nx, yy, grid_width, grid_size, COLORS._main_value_positive, updated_prog * 2);
						
						if(sprite_exists(_node.spr)) {
							var sw = sprite_get_width(_node.spr);
							var sh = sprite_get_height(_node.spr);
							var ss = (grid_size - ui(4)) * PREFERENCES.collection_scale / max(sw, sh);
							
							var xo = (sprite_get_xoffset(_node.spr) - sw / 2) * ss;
							var yo = (sprite_get_yoffset(_node.spr) - sh / 2) * ss;
							
							var sx = _boxx + grid_size / 2 + xo;
							var sy =    yy + grid_size / 2 + yo;
							
							if(ss < 1) gpu_set_tex_filter(true);
							BLEND_ALPHA_MULP
							draw_sprite_ext(_node.spr, frame, sx, sy, ss, ss, 0, c_white, 1);
							BLEND_NORMAL
							if(ss < 1) gpu_set_tex_filter(false);
							
						} else
							draw_sprite_ui_uniform(THEME.group, 0, _boxx + grid_size / 2, yy + grid_size / 2, 1, c_white);
					
						if(meta != noone && page == 0) {
							if(meta.file_id != 0) {
								var icc = COLORS._main_icon;
								var ipd = ui(10);
								BLEND_ADD
								draw_sprite_ui_uniform(THEME.steam, 0, _nx + ipd, yy + ipd, .75, icc, .5);
								if(meta.author_steam_id == STEAM_USER_ID)
									draw_sprite_ui_uniform(THEME.steam_creator, 0, _nx + grid_width - ipd + ui(2), yy + ipd, .75, icc, .5);
								BLEND_NORMAL
							}
						
							if(floor(meta.version) != floor(SAVE_VERSION)) {
								draw_set_color(COLORS._main_accent);
								draw_circle_prec(_nx + grid_width - ui(8), yy + grid_size - ui(8), 3, false);
							}
						}
					}
					
					if(PREFERENCES.collection_label) {
						draw_set_text(f_p4, fa_center, fa_top, COLORS._main_text_inner);
						
						var _tx = _boxx + grid_size / 2;
						var _ty = yy + grid_size + ui(2);
						var _tw = grid_width + grid_space;
						
						BLEND_ALPHA_MULP
						draw_text_ext(_tx, _ty, _node.name, -1, _tw);
						BLEND_NORMAL
						
						var _txtH   = string_height_ext(_node.name, -1, _tw);
						name_height = max(name_height, _txtH + ui(4));
					}
				}
				
				var hght = grid_size + name_height + ui(4);
				hh += hght;
				yy += hght;
			}
			
			var hov = pHOVER && point_in_rectangle(_m[0], _m[1], 0, 0, contentPane.surface_w, contentPane.surface_h);
			if(hov && key_mod_press(CTRL)) grid_size_to = clamp(grid_size_to + ui(4) * MOUSE_WHEEL, ui(32), ui(160));
			grid_size = lerp_float(grid_size, grid_size_to, 5);
			
		} else {
			var list_width  = _cw;
			var list_height = ui(28);
			var yy         = _y + list_height / 2;
			hh += list_height;
		
			for(var i = 0; i < node_count; i++) {
				var _node = i < node_list? content[i] : steamNode[i - node_list];
				if(!_node) continue;
				
				if(yy + list_height >= 0 && yy <= contentPane.surface_h) {
					if(i % 2) {
						BLEND_OVERRIDE
						draw_sprite_stretched_ext(THEME.node_bg, 0, ui(4), yy, list_width - 8, list_height, CDEF.main_black, 0.2);
						BLEND_NORMAL
					}
				
					if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, list_width, yy + list_height - 1)) {
						contentPane.hover_content = true;
						
						draw_sprite_stretched_ext(THEME.node_bg, 1, ui(4), yy, list_width - ui(8), list_height, COLORS._main_accent, 1);
						if(mouse_press(mb_left, pFOCUS))
							DRAGGING = { type : _node.type == FILE_TYPE.collection? "Collection" : "Asset", data : _node }
						
						if(!DEMO && mouse_press(mb_right, pFOCUS)) {
							_menu_node = _node;
							initMenu();
							menuCall("collection_menu", contentMenu);
						}
					}
				
					var spr_x = list_height / 2 + ui(14);
					var spr_y = yy + list_height / 2;
					var spr_s = list_height - ui(8);
					if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
					if(sprite_exists(_node.spr)) {
						var sw = sprite_get_width(_node.spr);
						var sh = sprite_get_height(_node.spr);
						var ss = spr_s / max(sw, sh);
							
						var xo = (sprite_get_xoffset(_node.spr) - sw / 2) * ss;
						var yo = (sprite_get_yoffset(_node.spr) - sh / 2) * ss;
						var sx = spr_x + xo;
						var sy = spr_y + yo;
					
						if(ss < 1) gpu_set_tex_filter(true);
						draw_sprite_ext(_node.spr, frame, sx, sy, ss, ss, 0, c_white, 1);
						if(ss < 1) gpu_set_tex_filter(false);
						
					} else
						draw_sprite_ui_uniform(THEME.group, 0, spr_x, spr_y, 0.75, c_white);
				
					draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_inner);
					draw_text_add(list_height + ui(20), yy + list_height / 2, _node.name);
				}
				
				yy += list_height;
				hh += list_height;
			}
		}
		
		return hh;
	});
	
	folderPane = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var hh = ui(8);
		_y += ui(8);
		
		var _ww = folderPane.surface_w;
		
		folderPane.hover_content = true;
		if(pHOVER && folderPane.hover && point_in_rectangle(_m[0], _m[1], 0, _y - ui(2), _ww, _y + ui(24))) {
			draw_sprite_stretched_ext(THEME.button_hide_fill, 1, ui(8), _y - ui(2), _ww - ui(16), ui(24), CDEF.main_white, 1);
			if(mouse_press(mb_left, pFOCUS))
				setContext(root);
		}
		
		draw_set_alpha(0.25 + (context == root) * 0.5);
		draw_set_text(f_p3, fa_center, fa_top, context == root? COLORS._main_text_accent : COLORS._main_text_inner);
		draw_text(_ww / 2, _y, __txt("uncategorized"));
		draw_set_alpha(1);
		_y += ui(24);
		
		var _x  = ui(8 + in_dialog * 8);
		var ww  = folderPane.w - ui(20);
		var hov = pHOVER && folderPane.hover;
		var foc = pFOCUS;
		var _params = {
			font: f_p3, 
		};
		
		for( var i = 0, n = array_length(root.subDir); i < n; i++ ) {
			var hg = root.subDir[i].draw(self, _x, _y, _m, ww, hov, foc, root, _params);
			hh += hg;
			_y += hg;
		}
		
		return hh + ui(28);
	});
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	nodeListPane_page   = 0;
	node_temp_list      = ds_list_create();
	node_menu_selecting = noone;
	
	function trigger_favourite() {
		if(node_menu_selecting == noone) return;
		
		var _node = node_menu_selecting.node;
		if(struct_exists(global.FAV_NODES, _node))	struct_remove(global.FAV_NODES, _node);
		else										global.FAV_NODES[$ _node] = 1;
		
		PREF_SAVE();
	}
	
	function rightClickNode(node) {
		if(!is(node, NodeObject)) return;
		
		node_menu_selecting = node;
		var fav  = struct_exists(global.FAV_NODES, node.node);
		var menu = [
			menuItem(fav? __txtx("add_node_remove_favourite", "Remove from favourite") : __txtx("add_node_add_favourite", "Add to favourite"), trigger_favourite, THEME.star)
		];
		
		menuCall("add_node_window_menu", menu, 0, 0, fa_left);
	}
	
	nodeListPane = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var hh = ui(8);
		   _y += ui(8);
		nodeListPane.hover_content = true;
		
		var  ww  = nodeListPane.surface_w;
		var _hg  = line_get_height(f_p2, 4);
		var _hov = pHOVER && nodeListPane.hover;
		var _foc = pFOCUS;
		
		for (var i = 0, n = array_length(NODE_CATEGORY); i < n; i++) {
			var _cat = NODE_CATEGORY[i];
			var _nam = _cat.name;
			var _fil = _cat[$ "filter"];
			if(_fil != undefined && !array_empty(_fil)) continue;
			
			var _y0 = _y;
			var _y1 = _y + _hg;
			
			if(_hov && point_in_rectangle(_m[0], _m[1], 0, _y0, ww, _y1)) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(16), _y0, ww - ui(20), _hg, CDEF.main_white, 1);
				
				if(mouse_click(mb_left, _foc))
					nodeListPane_page = i;
			}
			
			draw_set_text(f_p2, fa_left, fa_center, nodeListPane_page == i? COLORS._main_text_accent : COLORS._main_text_inner);
			draw_text_add(ui(24), _y + _hg / 2, _nam);
			
			_y += _hg;
			hh += _hg;
		}
		
		return hh + ui(16);
	});
	
	nodecontentPane = new scrollPane(1, 1, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var hh    = ui(0);
		var _cat  = NODE_CATEGORY[nodeListPane_page];
		var _list;
		
		if(searching) {
			_list = search_list;
			
		} else if(nodeListPane_page == 0) {
			ds_list_clear(node_temp_list);
			
			var _favs = struct_get_names(global.FAV_NODES);
			for( var i = 0, n = array_length(_favs); i < n; i++ ) {
				var _nodeIndex = _favs[i];
				if(!struct_has(ALL_NODES, _nodeIndex)) continue;
				
				var _node = ALL_NODES[$ _nodeIndex];
				if(_node.show_in_recent) 
					ds_list_add(node_temp_list, _node);
			}
			_list = node_temp_list;
			
		} else {
			ds_list_clear(node_temp_list);
			
			for( var i = 0, n = array_length(_cat.list); i < n; i++ )
				ds_list_add(node_temp_list, _cat.list[i]);
			
			_list = node_temp_list;
		}
		
		var grid_width  = PREFERENCES.collection_label? max(ui(40), round(grid_size * 1.25)) : grid_size;
		var node_count  = ds_list_size(_list);
		var grid_space  = ui(6);
		var name_height = 0;
		
		var _cw    = nodecontentPane.surface_w;
		var col    = max(1, floor(_cw / (grid_width + grid_space)));
		var row    = ceil(node_count / col);
		var yy     = _y + grid_space;
		var _hover = pHOVER && nodecontentPane.hover;
		
		var i, j, ii = 0;
		var font   = f_p4;
		grid_width = round(nodecontentPane.surface_w - grid_space) / col - grid_space;
			
		hh += grid_space;
		
		for(var index = 0; index < node_count; index++) {
			var _node = _list[| index];
			
			if(!is(_node, NodeObject)) continue;
			if(_node.patreon && !IS_PATREON)      continue;
			if(_node.deprecated)                  continue;
			
			i = floor(ii / col);
			j = safe_mod(ii, col);
			ii++;
			
			var _nx   = grid_space + (grid_width + grid_space) * j;
			var _boxx = _nx + (grid_width - grid_size) / 2;
			    _boxx = round(_boxx);
			
			var gr_x1 = _boxx + grid_size;
			var gr_y1 = yy + grid_size;
			
			if(yy + grid_size >= 0 && yy <= nodecontentPane.surface_h) {
				BLEND_OVERRIDE
				draw_sprite_stretched_ext(THEME.node_bg, 0, _nx, yy, grid_width, grid_size, CDEF.main_black);
				BLEND_NORMAL
				draw_sprite_stretched_ext(THEME.node_bg, 1, _nx, yy, grid_width, grid_size, CDEF.main_dkgrey);
				
				if(_hover && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
					TOOLTIP = _node.name;
					nodecontentPane.hover_content = true;
					draw_sprite_stretched_ext(THEME.node_bg, 1, _nx, yy, grid_width, grid_size, COLORS._main_accent);
					
					if(pFOCUS) {
						if(mouse_press(mb_left))  DRAGGING = { type : "Node", data : _node };
						if(mouse_press(mb_right)) rightClickNode(_node);
					}
				}
				
				var ss = (grid_size * .8) / max(sprite_get_width(_node.spr), sprite_get_height(_node.spr));
				var sx = _boxx + grid_size / 2;
				var sy = yy + grid_size / 2;
				
				gpu_set_texfilter(true);
					BLEND_ALPHA_MULP
					draw_sprite_ext(_node.spr, 0, sx, sy, ss, ss, 0, c_white, 1);
					BLEND_NORMAL
				gpu_set_texfilter(false);
				
				var fav = struct_exists(global.FAV_NODES, _node.node);
				if(fav) draw_sprite_ui_uniform(THEME.star, 0, _boxx + grid_size - ui(8), yy + grid_size - ui(8), 0.7, COLORS._main_accent, 1.);
				
			}
			
			if(PREFERENCES.collection_label) {
				draw_set_text(font, fa_center, fa_top, COLORS._main_text_inner);
				
				var _tx = _nx + grid_width / 2;
				var _ty =  yy + grid_size + ui(2);
				var _tw = round(grid_width + grid_space);
				
				BLEND_ALPHA_MULP
				draw_text_ext(_tx, _ty, _node.name, -1, _tw);
				BLEND_NORMAL
				
				var _txtH = string_height_ext(_node.name, -1, _tw);
				name_height = max(name_height, _txtH + ui(4));
			}
			
			if(j == col - 1) {
				var hght = grid_size + name_height + ui(4);
				hh += hght;
				yy += hght;
				
				name_height = 0;
			}
		}
		
		var hght = grid_size + name_height + ui(4);
		hh += hght;
		yy += hght;
		
		var hov = pHOVER && point_in_rectangle(_m[0], _m[1], 0, 0, nodecontentPane.surface_w, nodecontentPane.surface_h);
		if(hov && key_mod_press(CTRL)) grid_size_to = clamp(grid_size_to + ui(4) * MOUSE_WHEEL, ui(32), ui(160));
		grid_size = lerp_float(grid_size, grid_size_to, 5);
		
		return hh + ui(16);
	});
	
	////- Draw
		
	function setPage(i) {
		page    = i;
		title   = roots[i][0];
		root    = roots[i][1];
		context = root;
	}
	
	function onFocusBegin() { PANEL_COLLECTION = self; }
	
	function setContext(cont) { 
		context = cont;
		contentPane.scroll_y_raw = 0;
		contentPane.scroll_y_to	 = 0;
	} 
	
	function refreshContext() { 
		if(page == 0)		context.scan([ ".json", ".pxcc" ]);	
		else if(page == 1)	context.scan([ ".png", ".jpg", ".gif" ]);	
		
		if(STEAM_ENABLED) steamUCGload();
	} 
	
	function drawContent(panel) { 
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		content_w = w - ui( 8) - group_w;
		content_h = h - top_h - ui(8);
		
		var content_y = top_h;
		var ppd       = ui(2);
		var pageS     = pageStr[page];
		
		var foc = pFOCUS;
		var hov = pHOVER;
		var m   = [ mx, my ];
		
		switch(pageS) {
			case "Collections" : 
			case "Assets" : 
			case "Nodes" : 
				contentPane.verify(content_w - ui(8), content_h - ui(4));
				
				if(pageS == "Nodes") {
					draw_sprite_stretched(THEME.ui_panel_bg, 1, group_w, content_y, content_w, content_h);
					nodeListPane.verify(group_w - ui(8), content_h);
					nodecontentPane.verify(content_w - ui(8), content_h - ui(4));
					
					nodeListPane.setFocusHover(pFOCUS, pHOVER);
					nodecontentPane.setFocusHover(pFOCUS, pHOVER);
					
					nodeListPane.draw(0, content_y, mx, my - content_y);
					nodecontentPane.draw(group_w + ppd, content_y + ppd, mx - group_w - ppd, my - content_y - ppd);
					
				} else {
					draw_sprite_stretched(THEME.ui_panel_bg, 1, group_w, content_y, content_w, content_h);
					folderPane.verify(  group_w - ui(8), content_h);
					
					folderPane.setFocusHover(pFOCUS, pHOVER);
					contentPane.setFocusHover(pFOCUS, pHOVER);
					
					folderPane.draw(0, content_y, mx, my - content_y);
					contentPane.draw(group_w + ppd, content_y + ppd, mx - group_w - ppd, my - content_y - ppd);
				}
				
				if(group_w_dragging) {
					CURSOR  = cr_size_we;
					group_w = max(ui(128), group_w_sx + (mx - group_w_mx));
					
					if(mouse_release(mb_left))
						group_w_dragging = false;
				}
			
				if(pHOVER && point_in_rectangle(mx, my, group_w - ui(2), content_y, group_w + ui(2), content_y + content_h)) {
					CURSOR = cr_size_we;
					if(pFOCUS && mouse_press(mb_left)) {
						group_w_dragging = true;
						group_w_mx = mx;
						group_w_sx = group_w;
					}
				}
				break;
				
			case "Projects" : 
				contentPane.verify(w - ui(24), content_h - ui(4));
				
				var pad = ui(8);
				
				draw_sprite_stretched(THEME.ui_panel_bg, 1, pad, content_y, w - pad * 2, content_h);
				contentPane.setFocusHover(pFOCUS, pHOVER);
				contentPane.draw(pad + ppd, content_y + ppd, mx - pad - ppd, my - content_y - ppd);
				
				break;
				
		}
		
		////- Title bar
		
		var _sx = ui(10);
		var _sy = ui(6);
		var _sw = ui(160);
		var _sh = line_get_height(f_p0b, 4);
		var rootx = _sx;
		
		sc_pages.setFocusHover(foc, hov);
		sc_pages.draw(_sx, _sy, _sw, _sh, pageS, m, x, y);
		rootx = _sx + _sw + ui(8);
		
		var bb = THEME.button_hide_fill;
		var pd = ui(4);
		var bs = ui(28);
		var bx = w - (bs + pd);
		var by = pd;
		var bc = searching? COLORS._main_accent : COLORS._main_icon;
		
		if(buttonInstant(bb, bx, by, bs, bs, m, hov, foc, __txt("Search"), THEME.search_24, 0, bc, 1, .9) == 2)
			search_toggle();
			
		bx -= bs + ui(4);
		
		////- =Topbar
		
		if(searching) {
			var tb_w = ui(200);
			var tb_x = bx - tb_w + ui(28);
			var tb_y = by;
			
			tb_search.setFocusHover(foc, hov);
			tb_search.draw(tb_x, tb_y + ui(2), tb_w, bs - ui(4), search_string, m);
			return;
		}
		
		if(pageS == "Collections" && !DEMO) {
			if(context != root && PANEL_INSPECTOR.getInspecting() != noone) {
				var txt = __txtx("panel_collection_add_node", "Add inspecting node as a collection");
				if(buttonInstant(bb, bx, by, bs, bs, m, hov, foc, txt, THEME.add_20, 0, COLORS._main_value_positive, 1, .9) == 2) {
					data_path = context.path;
					
					var dia = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(8));
					dia.meta.name = PANEL_INSPECTOR.getInspecting().display_name;
					dia.node	  = PANEL_INSPECTOR.getInspecting();
					dia.data_path = data_path;
				}
				
			} else
				draw_sprite_ui_uniform(THEME.add, 0, bx + bs / 2, by + bs / 2, 1, COLORS._main_icon_dark);	
			bx -= bs + ui(4); if(bx < rootx) return;
			
			var txt = __txtx("panel_collection_add_folder", "Add folder");
			if(buttonInstant(bb, bx, by, bs, bs, m, hov, foc, txt, THEME.dFolder_add, 0, COLORS._main_icon, 1, .9) == 2) 
				fileNameCall(context.path, function(txt) /*=>*/ { directory_create(txt); refreshContext(); })
					.setLabel(__txt("Folder name")).setPrefix(string_replace(context.path, $"{DIRECTORY}Collections", "") + "/");
			bx -= bs + ui(4); if(bx < rootx) return;
		}
	
		if(pageS != "Nodes") {
			var txt = __txtx("panel_collection_open_file", "Open in file explorer");
			if(buttonInstant(bb, bx, by, bs, bs, m, hov, foc, txt, THEME.dPath_open, 0, COLORS._main_icon, 1, .9) == 2)
				shellOpenExplorer(context.path);
			bx -= bs + ui(4); if(bx < rootx) return;
			
			var txt = __txt("Refresh");
			if(buttonInstant(bb, bx, by, bs, bs, m, hov, foc, txt, THEME.refresh_icon, 0, COLORS._main_icon, 1, .9) == 2)
				refreshContext();
			bx -= bs + ui(4); if(bx < rootx) return;
		}
		
		var txt = __txt("Settings");
		if(buttonInstant(bb, bx, by, bs, bs, m, hov, foc, txt, THEME.gear, 0, COLORS._main_icon, 1, .9) == 2)
			dialogPanelCall(new Panel_Collections_Setting(), x + bx, y + by - 8, { anchor: ANCHOR.bottom | ANCHOR.left }); 
		bx -= bs + ui(4); if(bx < rootx) return;
		
		if(TESTING) {
			var txt = __txt("Collection Manager");
			if(buttonInstant(bb, bx, by, bs, bs, m, hov, foc, txt, THEME.gear, 0, COLORS._main_icon, .75, .9) == 2)
				dialogPanelCall(new Panel_Collection_Manager()); 
			bx -= bs + ui(4); if(bx < rootx) return;
			
			var txt = __txt("Create default Zip");
			if(buttonInstant(bb, bx, by, bs, bs, m, hov, foc, txt, THEME.gear, 0, COLORS._main_icon, .75, .9) == 2)
				__test_zip_collection(COLLECTIONS);
			bx -= bs + ui(4); if(bx < rootx) return;
		}
	}
	
	////- Serialize
		
    static serialize = function() { 
        _map = {}; 
        
        _map.name    = instanceof(self);
        _map.page    = page;
        _map.group_w = group_w / UI_SCALE;
        
        return _map;
    }
    
    static deserialize = function(data) { 
        var p = data[$ "page"] ?? 0;
        setPage(p);
        
        group_w = struct_has(data, "group_w")? ui(data.group_w) : group_w;
        
        return self; 
    }
    
}