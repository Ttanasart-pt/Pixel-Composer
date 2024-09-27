#region funtion calls
	function __fnInit_Collection() {
		registerFunction("Collection", "Toggle Search",		"F",  MOD_KEY.ctrl,	panel_collection_search_toggle		).setMenu("collection_search_toggle")
		registerFunction("Collection", "Replace",			"",   MOD_KEY.none,	panel_collection_replace			).setMenu("collection_replace")
		registerFunction("Collection", "Edit Meta",			"",   MOD_KEY.none,	panel_collection_edit_meta			).setMenu("collection_edit_meta")
		registerFunction("Collection", "Update Thumbnail",	"",   MOD_KEY.none,	panel_collection_update_thumbnail	).setMenu("collection_update_thumbnail")
		registerFunction("Collection", "Delete Collection",	"",   MOD_KEY.none,	panel_collection_delete_collection	).setMenu("collection_delete_collection",	THEME.cross)
		
		registerFunction("Collection", "Upload To Steam",	"",   MOD_KEY.none,	panel_collection_steam_file_upload	).setMenu("collection_upload_to_steam", 	THEME.workshop_upload)
		registerFunction("Collection", "Update Steam",		"",   MOD_KEY.none,	panel_collection_steam_file_update	).setMenu("collection_update_steam",    	THEME.workshop_update)
		registerFunction("Collection", "Unsubscribe",		"",   MOD_KEY.none,	panel_collection_steam_unsubscribe	).setMenu("collection_unsubscribe")
	}
	
	function panel_collection_search_toggle()		{ CALL("collection_search_toggle");		PANEL_COLLECTION.search_toggle();		}
	function panel_collection_replace()				{ CALL("collection_replace");			PANEL_COLLECTION.replace();				}
	function panel_collection_edit_meta()			{ CALL("collection_edit_meta");			PANEL_COLLECTION.edit_meta();			}
	function panel_collection_update_thumbnail()	{ CALL("collection_update_thumbnail");	PANEL_COLLECTION.update_thumbnail();	}
	function panel_collection_delete_collection()	{ CALL("collection_delete_collection");	PANEL_COLLECTION.delete_collection();	}
	
	function panel_collection_steam_file_upload()	{ CALL("collection_steam_file_upload");	PANEL_COLLECTION.steam_file_upload();	}
	function panel_collection_steam_file_update()	{ CALL("collection_steam_file_update");	PANEL_COLLECTION.steam_file_update();	}
	function panel_collection_steam_unsubscribe()	{ CALL("collection_steam_unsubscribe");	PANEL_COLLECTION.steam_unsubscribe();	}
#endregion

function Panel_Collection() : PanelContent() constructor {
	title = __txt("Collections");
	expandable = false;
	
	group_w          = ui(180);
	group_w_dragging = false;
	group_w_sx       = false;
	group_w_mx       = false;
	
	static initSize = function() {
		content_w = w - ui( 8) - group_w;
		content_h = h - ui(56);
	}
	initSize();
	
	min_w = group_w + ui(40);
	min_h = ui(40);
	
	roots = [ ["Collections", COLLECTIONS], ["Assets", global.ASSETS], ["Projects", STEAM_PROJECTS], ["Nodes", ALL_NODES] ];
	
	pageStr  = array_create_ext(array_length(roots), function(i) /*=>*/ {return roots[i][0]});
	sc_pages = new scrollBox(pageStr, function(i) /*=>*/ { setPage(i); });
	sc_pages.align = fa_left;
	sc_pages.type  = 1;
	
	page    = 0;
	root    = roots[page][1];
	context = root;
	
	file_dragging = noone;
	_menu_node    = noone;
	updated_path  = noone;
	updated_prog  = 0;
	data_path     = "";
	
	PANEL_COLLECTION = self;
	
	#region ++++++++++++ Actions ++++++++++++
		function replace() { 
			if(_menu_node == noone) return;
			
			var _path = filename_dir(_menu_node.path);
			var _name = filename_name(_menu_node.path);
			
			saveCollection(PANEL_INSPECTOR.getInspecting(), _path, _name, false, _menu_node.meta);
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
		
		function delete_collection() {
			if(_menu_node == noone) return;
			
			file_delete(_menu_node.path);
			refreshContext();
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
			
			for( var i = 0; i < ds_list_size(STEAM_COLLECTION); i++ ) {
				if(STEAM_COLLECTION[| i].getMetadata().file_id != del_id) continue;
				
				ds_list_delete(STEAM_COLLECTION, i);
				break;
			}
			
			steam_ugc_unsubscribe_item(del_id);
		}
		
		function search_toggle() {
			searching = !searching;
			if(searching) { doSearch(); tb_search.activate(); }
		}
	#endregion
	
	static initMenu = function() {
		if(_menu_node == noone) return;
		var meta = _menu_node.getMetadata();
		
		contentMenu = [];
		
		if(meta == noone || !meta.steam) {
			contentMenu = [
				MENU_ITEMS.collection_replace,
				MENU_ITEMS.collection_edit_meta,
				MENU_ITEMS.collection_update_thumbnail,
				-1,
				MENU_ITEMS.collection_delete_collection,
			];
			
			if(STEAM_ENABLED) 
				array_push(contentMenu, -1);
		} 
		
		if(STEAM_ENABLED) {
			if(meta.steam == FILE_STEAM_TYPE.local) {
				array_push(contentMenu, MENU_ITEMS.collection_upload_to_steam);
				
			} else {
				if(meta.author_steam_id && meta.author_steam_id == STEAM_USER_ID)
					array_push(contentMenu, MENU_ITEMS.collection_update_steam);
				array_push(contentMenu, MENU_ITEMS.collection_unsubscribe);
			}
		}
	}
	initMenu();
	
	searching     = false;
	search_string = "";
	search_list   = ds_list_create();
	
	function doSearch() {
		var search_lower = string_lower(search_string);
		ds_list_clear(search_list);
		
		switch(pageStr[page]) {
			case "Collections" :
			case "Assets" : 
				searchCollection(search_list, search_string);
				break;
				
			case "Projects" : 
				var st = ds_stack_create();
				var ll = ds_priority_create();
				
				for( var i = 0, n = ds_list_size(STEAM_PROJECTS); i < n; i++ ) {
					var _nd = STEAM_PROJECTS[| i];
						
					var match = string_partial_match(string_lower(_nd.name), search_lower);
					if(match == -9999) continue;
					
					ds_priority_add(ll, _nd, match);
				}
				
				repeat(ds_priority_size(ll))
					ds_list_add(search_list, ds_priority_delete_max(ll));
				
				ds_priority_destroy(ll);
				ds_stack_destroy(st);
				break;
				
			case "Nodes" : 
				var pr_list    = ds_priority_create();
				var search_map = ds_map_create();
				
				for(var i = 0; i < ds_list_size(NODE_CATEGORY); i++) {
					var cat = NODE_CATEGORY[| i];
					
					if(!struct_has(cat, "list")) continue;
					if(!array_empty(cat.filter)) continue;
					
					var _content = cat.list;
					for(var j = 0; j < ds_list_size(_content); j++) {
						var _node = _content[| j];
						
						if(is_string(_node))				      continue;
						if(ds_map_exists(search_map, _node))      continue;
						if(!is_instanceof(_node, NodeObject))     continue;
						if(_node.is_patreon_extra && !IS_PATREON) continue;
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
					ds_list_add(search_list, ds_priority_delete_max(pr_list));
				
				ds_priority_destroy(pr_list);
				break;
		}
	}
	
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_string = string(str); doSearch(); });
	tb_search.auto_update = true;
	
	grid_size    = ui(48);
	grid_size_to = grid_size;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	contentView = 0;
	contentPane = new scrollPane(content_w - ui(8), content_h - ui(4), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var content;
		var steamNode = [];
		
		switch(page) {
		    case 0 :
    		    if(!COLLECTIONS.scanned) 
    				COLLECTIONS.scan([".json", ".pxcc"]); 
    			
    			if(context == root) content = STEAM_COLLECTION;
    			else				content = context.content;
    			
    			for( var i = 0; i < ds_list_size(STEAM_COLLECTION); i++ ) {
    				var meta = STEAM_COLLECTION[| i].meta;	
    				if(array_exists(meta.tags, context.name))
    					array_push(steamNode, STEAM_COLLECTION[| i]);	
    			}
		        break;
		       
	        case 1 : content = context.content;     break;
	        case 2 : content = context;             break;
		}
		
		if(searching) content = search_list;
		
		var node_list  = ds_list_size(content);
		var node_count = node_list + array_length(steamNode);
		var frame	   = PREFERENCES.collection_animated? current_time * PREFERENCES.collection_preview_speed / 3000 : 0;
		var _cw		   = contentPane.surface_w;
		var _hover	   = pHOVER && contentPane.hover;
		
		updated_prog   = lerp_linear(updated_prog, 0, 0.01);
		var hh = 0;
		
		if(contentView == 0) {
			var grid_width = round(grid_size * 1.25);
			if(grid_width > ui(80)) grid_width = grid_size;
			
			var grid_space = round(grid_size * 0.1875);
			
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
					
					var _node = index < node_list? content[| index] : steamNode[index - node_list];
					var _nx   = grid_space + (grid_width + grid_space) * j;
					var _boxx = _nx + (grid_width - grid_size) / 2;
					_boxx = round(_boxx);
					
					var gr_x1 = _boxx + grid_size;
					var gr_y1 = yy + grid_size;
					
					if(yy + grid_size >= 0 && yy <= contentPane.surface_h) {
						BLEND_OVERRIDE;
						draw_sprite_stretched(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size);
						BLEND_NORMAL;
						
						var meta = noone;
						if(variable_struct_exists(_node, "getMetadata")) 
							meta = _node.getMetadata();
						
						if(_hover && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
							contentPane.hover_content = true;
							draw_sprite_stretched_ext(THEME.node_bg, 1, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
							
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
							
							if(!instance_exists(o_dialog_menubox) && meta != noone && meta != undefined)
								TOOLTIP = meta;
						}
						
						if(_node.path == updated_path && updated_prog > 0) 
							draw_sprite_stretched_ext(THEME.node_bg, 1, _boxx, yy, grid_size, grid_size, COLORS._main_value_positive, updated_prog * 2);
						
						if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
						
						if(sprite_exists(_node.spr)) {
							var sw = sprite_get_width(_node.spr);
							var sh = sprite_get_height(_node.spr);
							var ss = (grid_size - ui(10)) * PREFERENCES.collection_scale / max(sw, sh);
							
							var xo = (sprite_get_xoffset(_node.spr) - sw / 2) * ss;
							var yo = (sprite_get_yoffset(_node.spr) - sh / 2) * ss;
							var sx = _boxx + grid_size / 2 + xo;
							var sy = yy + grid_size / 2 + yo;
							
							BLEND_ALPHA_MULP
							draw_sprite_ext(_node.spr, frame, sx, sy, ss, ss, 0, c_white, 1);
							BLEND_NORMAL
						} else
							draw_sprite_ui_uniform(THEME.group, 0, _boxx + grid_size / 2, yy + grid_size / 2, 1, c_white);
					
						if(meta != noone && page == 0) {
							if(struct_try_get(meta, "steam")) {
								draw_sprite_ui_uniform(THEME.steam, 0, _boxx + ui(12), yy + ui(12), 1, COLORS._main_icon_dark, 1);
								if(meta.author_steam_id == STEAM_USER_ID)
									draw_sprite_ui_uniform(THEME.steam_creator, 0, _boxx + grid_size - ui(8), yy + ui(12), 1, COLORS._main_icon_dark, 1);
							}
						
							if(floor(meta.version) != floor(SAVE_VERSION)) {
								draw_set_color(COLORS._main_accent);
								draw_circle_prec(_boxx + grid_size - ui(8), yy + grid_size - ui(8), 3, false);
							}
						}
					}
					
					draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text_inner);
					var _txtH = draw_text_ext_add(_boxx + grid_size / 2, yy + grid_size + ui(4), _node.name, -1, grid_width, 1, true);
					name_height = max(name_height, _txtH + 8);
				}
				
				var hght = grid_size + name_height + ui(8);
				hh += hght;
				yy += hght;
			}
			
			if(pHOVER && key_mod_press(CTRL) && point_in_rectangle(_m[0], _m[1], 0, 0, contentPane.surface_w, contentPane.surface_h)) {
				if(mouse_wheel_down()) grid_size_to = clamp(grid_size_to - ui(4), ui(32), ui(160));
				if(mouse_wheel_up())   grid_size_to = clamp(grid_size_to + ui(4), ui(32), ui(160));
			}
			grid_size = lerp_float(grid_size, grid_size_to, 5);
			
		} else {
			var list_width  = _cw;
			var list_height = ui(28);
			var yy         = _y + list_height / 2;
			hh += list_height;
		
			for(var i = 0; i < node_count; i++) {
				var _node = i < node_list? content[| i] : steamNode[i - node_list];
				if(!_node) continue;
				
				if(yy + list_height >= 0 && yy <= contentPane.surface_h) {
					if(i % 2) {
						BLEND_OVERRIDE;
						draw_sprite_stretched_ext(THEME.node_bg, 0, ui(4), yy, list_width - 8, list_height, c_white, 0.2);
						BLEND_NORMAL;
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
					
						draw_sprite_ext(_node.spr, frame, sx, sy, ss, ss, 0, c_white, 1);
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
	
	folderPane = new scrollPane(group_w - ui(8), content_h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var hh = ui(8);
		_y += ui(8);
		
		folderPane.hover_content = true;
		if(pHOVER && folderPane.hover && point_in_rectangle(_m[0], _m[1], ui(32), _y - ui(2), group_w - ui(32), _y + ui(24))) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(32), _y - ui(2), group_w - ui(64), ui(24), CDEF.main_white, 1);
			if(mouse_press(mb_left, pFOCUS))
				setContext(root);
		}
		
		draw_set_alpha(0.25 + (context == root) * 0.5);
		draw_set_text(f_p2, fa_center, fa_top, context == root? COLORS._main_text_accent : COLORS._main_text_inner);
		draw_text(group_w / 2, _y, __txt("uncategorized"));
		draw_set_alpha(1);
		_y += ui(24);
		
		var _font  = f_p0;
		var _param = { font : _font };
		
		for(var i = 0; i < ds_list_size(root.subDir); i++) {
			var hg = root.subDir[| i].draw(self, ui(8 + in_dialog * 8), _y, _m, folderPane.w - ui(20), pHOVER && folderPane.hover, pFOCUS, root, _param);
			hh += hg;
			_y += hg;
		}
		
		return hh + ui(28);
	});
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
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
		if(!is_instanceof(node, NodeObject)) return;
		
		node_menu_selecting = node;
		var fav  = struct_exists(global.FAV_NODES, node.node);
		var menu = [
			menuItem(fav? __txtx("add_node_remove_favourite", "Remove from favourite") : __txtx("add_node_add_favourite", "Add to favourite"), trigger_favourite, THEME.star)
		];
		
		menuCall("add_node_window_menu", menu, 0, 0, fa_left);
	}
	
	nodeListPane = new scrollPane(group_w - ui(8), content_h, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var hh = ui(8);
		   _y += ui(8);
		nodeListPane.hover_content = true;
		
		var  ww  = nodeListPane.surface_w;
		var _hg  = ui(28);
		var _hov = pHOVER && nodeListPane.hover;
		var _foc = pFOCUS;
		
		for (var i = 0, n = ds_list_size(NODE_CATEGORY); i < n; i++) {
			var _cat = NODE_CATEGORY[| i];
			var _nam = _cat.name;
			var _fil = _cat.filter;
			
			if(!array_empty(_fil))   continue;
			
			var _y0 = _y;
			var _y1 = _y + _hg;
			
			if(_hov && point_in_rectangle(_m[0], _m[1], 0, _y0, ww, _y1)) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(16), _y0, ww - ui(20), _hg, CDEF.main_white, 1);
				
				if(mouse_press(mb_left, _foc))
					nodeListPane_page = i;
			}
			
			draw_set_text(f_p0, fa_left, fa_center, nodeListPane_page == i? COLORS._main_text_accent : COLORS._main_text_inner);
			draw_text_add(ui(24), _y + _hg / 2, _nam);
			
			_y += _hg;
			hh += _hg;
		}
		
		return hh + ui(16);
	});
	
	nodecontentPane = new scrollPane(content_w - ui(8), content_h - ui(4), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var hh    = ui(0);
		var _cat  = NODE_CATEGORY[| nodeListPane_page];
		var _list = _cat.list;
		
		if(searching) {
			_list = search_list;
			
		} else if(nodeListPane_page == 0) {
			ds_list_clear(node_temp_list);
			
			var _favs = struct_get_names(global.FAV_NODES);
			for( var i = 0, n = array_length(_favs); i < n; i++ ) {
				var _nodeIndex = _favs[i];
				if(!ds_map_exists(ALL_NODES, _nodeIndex)) continue;
				
				var _node = ALL_NODES[? _nodeIndex];
				if(_node.show_in_recent) 
					ds_list_add(node_temp_list, _node);
			}
			_list = node_temp_list;
		} 
		
		var grid_width = max(ui(40), round(grid_size * 1.25));
		var node_count = ds_list_size(_list);
		var grid_space = round(grid_size * 0.1875);
		
		var name_height = 0;
		var _cw    = nodecontentPane.surface_w;
		var col    = max(1, floor(_cw / (grid_width + grid_space)));
		var row    = ceil(node_count / col);
		var yy     = _y + grid_space;
		var _hover = pHOVER && nodecontentPane.hover;
		
		var i, j, ii = 0;
		var font   = f_p3;
		grid_width = round(nodecontentPane.surface_w - grid_space) / col - grid_space;
			
		hh += grid_space;
		
		for(var index = 0; index < node_count; index++) {
			var _node = _list[| index];
			
			if(!is_instanceof(_node, NodeObject))     continue;
			if(_node.is_patreon_extra && !IS_PATREON) continue;
			if(_node.deprecated)					  continue;
			
			i = floor(ii / col);
			j = safe_mod(ii, col);
			ii++;
			
			var _nx   = grid_space + (grid_width + grid_space) * j;
			var _boxx = _nx + (grid_width - grid_size) / 2;
			    _boxx = round(_boxx);
			
			var gr_x1 = _boxx + grid_size;
			var gr_y1 = yy + grid_size;
			
			if(yy + grid_size >= 0 && yy <= nodecontentPane.surface_h) {
				BLEND_OVERRIDE;
				draw_sprite_stretched(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size);
				BLEND_NORMAL;
				
				if(_hover && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
					nodecontentPane.hover_content = true;
					draw_sprite_stretched_ext(THEME.node_bg, 1, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
					
					if(pFOCUS) {
						if(mouse_press(mb_left))  DRAGGING = { type : "Node", data : _node };
						if(mouse_press(mb_right)) rightClickNode(_node);
					}
				}
				
				var ss = grid_size / 96;
				var sx = _boxx + grid_size / 2;
				var sy = yy + grid_size / 2;
				
				BLEND_ALPHA_MULP
				draw_sprite_ext(_node.spr, 0, sx, sy, ss, ss, 0, c_white, 1);
				BLEND_NORMAL
				
				var fav = struct_exists(global.FAV_NODES, _node.node);
				if(fav) draw_sprite_ui_uniform(THEME.star, 0, _boxx + grid_size - ui(8), yy + grid_size - ui(8), 0.7, COLORS._main_accent, 1.);
				
			}
			
			draw_set_text(font, fa_center, fa_top, COLORS._main_text_inner);
			var _txtH = draw_text_ext_add(_boxx + grid_size / 2, yy + grid_size + ui(4), _node.name, -1, grid_width);
			name_height = max(name_height, _txtH + 8);
			
			if(j == col - 1) {
				var hght = grid_size + name_height + ui(8);
				hh += hght;
				yy += hght;
				
				name_height = 0;
			}
		}
		
		var hght = grid_size + name_height + ui(8);
		hh += hght;
		yy += hght;
		
		if(pHOVER && key_mod_press(CTRL) && point_in_rectangle(_m[0], _m[1], 0, 0, nodecontentPane.surface_w, nodecontentPane.surface_h)) {
			if(mouse_wheel_down()) grid_size_to = clamp(grid_size_to - ui(4), ui(32), ui(160));
			if(mouse_wheel_up())   grid_size_to = clamp(grid_size_to + ui(4), ui(32), ui(160));
		}
		grid_size = lerp_float(grid_size, grid_size_to, 5);
		
		return hh + ui(16);
	});
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function setPage(i) {
		page    = i;
		root    = roots[i][1];
		context = root;
		onResize();
	}
	
	function onFocusBegin() { PANEL_COLLECTION = self; }
	
	function onResize() { 
		initSize();
		
		folderPane.resize(  group_w - ui(8), content_h);
		
		if(pageStr[page] == "Projects")	contentPane.resize(w - ui(24),        content_h - ui(4));
		else			                contentPane.resize(content_w - ui(8), content_h - ui(4));
		
		nodeListPane.resize(group_w - ui(8), content_h);
		nodecontentPane.resize(content_w - ui(8), content_h - ui(4));
	} 
	
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
		
		var content_y = ui(48);
		var ppd = ui(2);
		
		switch(pageStr[page]) {
			case "Collections" : 
			case "Assets" : 
			case "Nodes" : 
				draw_sprite_stretched(THEME.ui_panel_bg, 1, group_w, content_y, content_w, content_h);
				
				if(pageStr[page] == "Nodes") {
					nodeListPane.setFocusHover(pFOCUS, pHOVER);
					nodecontentPane.setFocusHover(pFOCUS, pHOVER);
					
					nodeListPane.draw(0, content_y, mx, my - content_y);
					nodecontentPane.draw(group_w + ppd, content_y + ppd, mx - group_w - ppd, my - content_y - ppd);
					
				} else {
					folderPane.setFocusHover(pFOCUS, pHOVER);
					contentPane.setFocusHover(pFOCUS, pHOVER);
					
					folderPane.draw(0, content_y, mx, my - content_y);
					contentPane.draw(group_w + ppd, content_y + ppd, mx - group_w - ppd, my - content_y - ppd);
				}
				
				if(group_w_dragging) {
					CURSOR  = cr_size_we;
					group_w = max(ui(128), group_w_sx + (mx - group_w_mx));
					
					onResize();
				
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
				var pad = ui(8);
				
				draw_sprite_stretched(THEME.ui_panel_bg, 1, pad, content_y, w - pad * 2, content_h);
				contentPane.setFocusHover(pFOCUS, pHOVER);
				contentPane.draw(pad + ppd, content_y + ppd, mx - pad - ppd, my - content_y - ppd);
				
				break;
				
		}
		
		var _x = ui(10);
		var _y = ui(10);
		var _w = ui(160);
		var _h = line_get_height(f_p0b, 8);
		
		var bh    = line_get_height(f_p0b, 8);
		var rootx = _x;
		
		sc_pages.setFocusHover(pFOCUS, pHOVER);
		sc_pages.draw(_x, _y, _w, _h, pageStr[page], [mx, my], x, y);
		rootx = _x + _w + ui(8);
		
		var bx = w - ui(40);
		var by = ui(9);
		var bs = ui(32);
		
		if(buttonInstant(THEME.button_hide, bx, by, bs, bs, [mx, my], pFOCUS, pHOVER, __txt("Search"), THEME.search_24, 0, searching? COLORS._main_accent : COLORS._main_icon) == 2)
			search_toggle();
			
		bx -= ui(36);
		
		if(searching) {
			var tb_w = ui(200);
			var tb_x = bx - tb_w + ui(28);
			var tb_y = ui(11);
			
			tb_search.setFocusHover(pFOCUS, pHOVER);
			tb_search.draw(tb_x, tb_y, tb_w, ui(28), search_string, [mx, my]);
			return;
		}
		
		if(pageStr[page] == "Collections" && !DEMO) {
			if(bx < rootx) return;
			if(context != root) {
				var txt = __txtx("panel_collection_add_node", "Add selecting node as collection");
				if(buttonInstant(THEME.button_hide, bx, by, bs, bs, [mx, my], pFOCUS, pHOVER, txt, THEME.add_20, 0, COLORS._main_value_positive) == 2) {
					if(PANEL_INSPECTOR.getInspecting() != noone) {
						data_path = context.path;
						var dia = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(8));
						if(PANEL_INSPECTOR.getInspecting()) {
							dia.meta.name = PANEL_INSPECTOR.getInspecting().display_name;
							dia.node	  = PANEL_INSPECTOR.getInspecting();
							dia.data_path = data_path;
						}
					}
				}
			} else
				draw_sprite_ui_uniform(THEME.add, 0, bx + bs / 2, by + bs / 2, 1, COLORS._main_icon_dark);	
			bx -= ui(36);
			
			if(bx < rootx) return;
			var txt = __txtx("panel_collection_add_folder", "Add folder");
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, [mx, my], pFOCUS, pHOVER, txt) == 2) {
				fileNameCall(context.path, function (txt) {
					directory_create(txt);
					refreshContext();
				});
			}
			draw_sprite_ui_uniform(THEME.folder_add, 0, bx + bs / 2, by + bs / 2, 1, COLORS._main_icon);
			draw_sprite_ui_uniform(THEME.folder_add, 1, bx + bs / 2, by + bs / 2, 1, COLORS._main_value_positive);
			bx -= ui(36);
		}
	
		if(pageStr[page] != "Nodes") {
			if(bx < rootx) return;
			var txt = __txtx("panel_collection_open_file", "Open in file explorer");
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, [mx, my], pFOCUS, pHOVER, txt, THEME.path_open) == 2)
				shellOpenExplorer(context.path);
			draw_sprite_ui_uniform(THEME.path_open, 1, bx + bs / 2, by + bs / 2, 1, c_white);
			bx -= ui(36);
			
			if(bx < rootx) return;
			var txt = __txt("Refresh");
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, [mx, my], pFOCUS, pHOVER, txt, THEME.refresh_icon) == 2)
				refreshContext();
			bx -= ui(36);
			
			if(bx < rootx) return;
			var txt = __txt("Settings");
			if(buttonInstant(THEME.button_hide, bx, by, bs, bs, [mx, my], pFOCUS, pHOVER, txt, THEME.gear) == 2)
				dialogPanelCall(new Panel_Collections_Setting(), x + bx, y + by - 8, { anchor: ANCHOR.bottom | ANCHOR.left }); 
			bx -= ui(36);
		
		}
	}
		
}