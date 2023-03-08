function Panel_Collection() : PanelContent() constructor {
	expandable = false;
	
	group_w   = ui(180);
	group_w_dragging = false;
	group_w_sx = false;
	group_w_mx = false;
	
	function initSize() {
		content_w = w - ui(8) - group_w;
		content_h = h - ui(40) - ui(16);
	}
	initSize();
	
	min_w = group_w + ui(40);
	min_h = ui(40);
	
	roots = [ ["Collections", COLLECTIONS] , ["Assets", global.ASSETS] ];
	mode  = 0;
	root = roots[mode][1];
	context = root;
	
	search_list = ds_list_create();
	
	file_dragging = noone;
	_menu_node = noone;
	
	updated_path = noone;
	updated_prog = 0;
	data_path = "";
	
	static initMenu = function() {
		if(_menu_node == noone) return;
		var meta = _menu_node.getMetadata();
		
		contentMenu = [];
		
		if(meta == noone || !meta.steam) {
			contentMenu = [
				menuItem(get_text("panel_collection_replace", "Replace with selected"), function() { 
					saveCollection(_menu_node.path, false, _menu_node.meta);
				}),
				menuItem(get_text("panel_collection_edit_meta", "Edit metadata") + "...", function() { 
					var dia = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(-320));
					var meta = _menu_node.getMetadata();
					if(meta != noone && meta != undefined) 
						dia.meta = meta;
			
					dia.updating	= _menu_node;
					dia.doExpand();
				}),
				-1,
				menuItem(get_text("delete", "Delete"), function() { 
					file_delete(_menu_node.path);
					refreshContext();
				})
			];
			
			if(STEAM_ENABLED) 
				array_push(contentMenu, -1);
		} 
		
		if(STEAM_ENABLED) {
			if(!meta.steam) {
				array_push(contentMenu, menuItem(get_text("panel_collection_workshop_upload", "Upload to Steam Workshop") + "...", function() { 
					var dia = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(-320));
					var meta = _menu_node.getMetadata();
					if(meta != noone && meta != undefined) 
						dia.meta = meta;
				
					dia.ugc			= 1;
					dia.updating	= _menu_node;
					dia.doExpand();
				}));
			} else {
				if(meta.author_steam_id == STEAM_USER_ID && meta.file_id != 0) {
					array_push(contentMenu, menuItem(get_text("panel_collection_workshop_update", "Update Steam Workshop content") + "...", function() { 
						var dia = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(-320));
						var meta = _menu_node.getMetadata();
						if(meta != noone && meta != undefined) 
							dia.meta = meta;
						
						dia.ugc			= 2;
						dia.updating	= _menu_node;
						dia.doExpand();
					}));
				}
				
				array_push(contentMenu, menuItem("Unsubscribe", function() {
					var meta = _menu_node.getMetadata();
					var del_id = meta.file_id;
					
					for( var i = 0; i < ds_list_size(STEAM_COLLECTION); i++ ) {
						print(STEAM_COLLECTION[| i].meta.file_id);
						if(STEAM_COLLECTION[| i].getMetadata().file_id == del_id) {
							ds_list_delete(STEAM_COLLECTION, i);
							break;
						}
					}
					steam_ugc_unsubscribe_item(del_id);
				}));
			}
		}
	}
	initMenu();
	
	search_string = "";
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) { 
		search_string = string(str); 
		searchCollection(search_list, search_string);
	});
	tb_search.auto_update = true;
	
	contentView = 0;
	contentPane = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var nodes = search_string == ""? context.content : search_list;
		if(mode == 0 && context == root) nodes = STEAM_COLLECTION;
		var steamNode = [];
		for( var i = 0; i < ds_list_size(STEAM_COLLECTION); i++ ) {
			var meta = STEAM_COLLECTION[| i].meta;	
			if(array_exists(meta.tags, context.name))
				array_push(steamNode, STEAM_COLLECTION[| i]);	
		}
		
		var node_list  = ds_list_size(nodes);
		var node_count = node_list + array_length(steamNode);
		var hh = 0;
		var frame = current_time * PREF_MAP[? "collection_preview_speed"] / 3000;
		var _cw = contentPane.surface_w;
		var _hover = pHOVER && contentPane.hover;
		
		updated_prog = lerp_linear(updated_prog, 0, 0.01);
		
		if(contentView == 0) {
			var grid_size  = ui(64);
			var grid_width = ui(80);
			var grid_space = ui(12);
			var col = max(1, floor(_cw / (grid_width + grid_space)));
			var row = ceil(node_count / col);
			var yy  = _y + grid_space;
			var name_height = 0;
				
			hh += grid_space;
			
			for(var i = 0; i < row; i++) {
				name_height = 0;
				for(var j = 0; j < col; j++) {
					var index = i * col + j;
					if(index >= node_count) break;
					
					var _node = index < node_list? nodes[| index] : steamNode[index - node_list];
					var _nx   = grid_space + (grid_width + grid_space) * j;
					var _boxx = _nx + (grid_width - grid_size) / 2;
						
					BLEND_OVERRIDE;
					draw_sprite_stretched(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size);
					BLEND_NORMAL;
						
					var meta = noone;
					if(variable_struct_exists(_node, "getMetadata")) 
						meta = _node.getMetadata();
						
					if(_hover && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
						draw_sprite_stretched_ext(THEME.node_active, 0, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
						if(mouse_press(mb_left, pFOCUS))
							file_dragging = _node;
							
						if(!DEMO && mouse_press(mb_right, pFOCUS)) {
							_menu_node = _node;
							initMenu();
							menuCall(,, contentMenu);	
						}
						
						if(!instance_exists(o_dialog_menubox) && meta != noone && meta != undefined) {
							meta.name = _node.name;
							TOOLTIP = meta;
						}
					}
						
					if(_node.path == updated_path && updated_prog > 0) 
						draw_sprite_stretched_ext(THEME.node_glow, 0, _boxx - 9, yy - 9, grid_size + 18, grid_size + 18, COLORS._main_value_positive, updated_prog);
						
					if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
						
					if(sprite_exists(_node.spr)) {
						var sw = sprite_get_width(_node.spr);
						var sh = sprite_get_height(_node.spr);
						var ss = ui(32) / max(sw, sh);
							
						var xo = (sprite_get_xoffset(_node.spr) - sw / 2) * ss;
						var yo = (sprite_get_yoffset(_node.spr) - sh / 2) * ss;
						var sx = _boxx + grid_size / 2 + xo;
						var sy = yy + grid_size / 2 + yo;
							
						draw_sprite_ext(_node.spr, frame, sx, sy, ss, ss, 0, c_white, 1);
					} else
						draw_sprite_ui_uniform(THEME.group, 0, _boxx + grid_size / 2, yy + grid_size / 2, 1, c_white);
					
					if(meta != noone && mode == 0) {
						if(meta.steam) {
							draw_sprite_ui_uniform(THEME.steam, 0, _boxx + ui(12), yy + ui(12), 1, COLORS._main_icon_dark, 1);
							if(meta.author_steam_id == STEAM_USER_ID) 
								draw_sprite_ui_uniform(THEME.steam_creator, 0, _boxx + grid_size - ui(8), yy + ui(12), 1, COLORS._main_icon_dark, 1);
						}
						
						if(meta.version < SAVEFILE_VERSION) {
							draw_set_color(COLORS._main_accent);
							draw_circle(_boxx + grid_size - ui(8), yy + grid_size - ui(8), 3, false);
						}
					}
					
					draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
					name_height = max(name_height, string_height_ext(_node.name, -1, grid_width) + 8);
					draw_text_ext_over(_boxx + grid_size / 2, yy + grid_size + ui(4), _node.name, -1, grid_width);
				}
				
				var hght = grid_size + name_height + ui(8);
				hh += hght;
				yy += hght;
			}
		} else {
			var list_width  = _cw;
			var list_height = ui(28);
			var yy         = _y + list_height / 2;
			hh += list_height;
		
			for(var i = 0; i < node_count; i++) {
				var _node = i < node_list? nodes[| i] : steamNode[i - node_list];
				if(!_node) continue;
				
				if(i % 2) {
					BLEND_OVERRIDE;
					draw_sprite_stretched_ext(THEME.node_bg, 0, ui(4), yy, list_width - 8, list_height, c_white, 0.2);
					BLEND_NORMAL;
				}
				
				if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, list_width, yy + list_height - 1)) {
					draw_sprite_stretched_ext(THEME.node_active, 0, ui(4), yy, list_width - ui(8), list_height, COLORS._main_accent, 1);
					if(mouse_press(mb_left, pFOCUS))
						file_dragging = _node;
						
					if(!DEMO && mouse_press(mb_right, pFOCUS)) {
						_menu_node = _node;
						initMenu();
						menuCall(,, contentMenu);
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
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_over(list_height + ui(20), yy + list_height / 2, _node.name);
				
				yy += list_height;
				hh += list_height;
			}
		}
		
		return hh;
	});
	
	folderPane = new scrollPane(group_w - ui(4), content_h, function(_y, _m) {
		draw_clear(COLORS.panel_bg_clear);
		var hh = ui(8);
		
		for(var i = 0; i < ds_list_size(root.subDir); i++) {
			var hg = root.subDir[| i].draw(self, ui(8), _y, _m, folderPane.w - ui(20), pHOVER && folderPane.hover, pFOCUS, root);
			hh += hg;
			_y += hg;
		}
		
		return hh;
	});
	
	function onResize() {
		initSize();
		
		folderPane.resize(group_w - ui(4), content_h);
		contentPane.resize(content_w, content_h);
		folderPane.resize(group_w - ui(4), content_h);
	}
	
	function setContext(cont) {
		context = cont;
		contentPane.scroll_y_raw = 0;
		contentPane.scroll_y_to	 = 0;
	}
	
	function refreshContext() {
		context.scan([".json", ".pxcc"]);	
		
		if(STEAM_ENABLED)
			steamUCGload();
	}
	
	function saveCollection(_name, save_surface = true, metadata = noone) {
		if(PANEL_INSPECTOR.inspecting == noone) return;
		
		var _pre_name = (data_path == ""? "" : data_path + "/") + _name;
		var ext = filename_ext(_pre_name);
		var _path = ext == ".pxcc"? _pre_name : _pre_name + ".pxcc";
		
		if(ds_list_empty(PANEL_GRAPH.nodes_select_list))
			SAVE_COLLECTION(PANEL_INSPECTOR.inspecting, _path, save_surface, metadata);
		else
			SAVE_COLLECTIONS(PANEL_GRAPH.nodes_select_list, _path, save_surface, metadata);
		
		updated_path = _path;
		updated_prog = 1;
		
		refreshContext();
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var content_y = ui(48);
		draw_sprite_stretched(THEME.ui_panel_bg, 1, group_w, content_y, content_w, content_h);
		contentPane.active = pHOVER;
		contentPane.draw(group_w, content_y, mx - group_w, my - content_y);
		
		folderPane.active = pHOVER;
		folderPane.draw(0, content_y, mx, my - content_y);
		
		#region resize width
			if(group_w_dragging) {
				CURSOR = cr_size_we;
				
				var _gw = group_w_sx + (mx - group_w_mx);
				_gw = max(ui(180), _gw);
				group_w = _gw;
				
				onResize();
				
				if(mouse_release(mb_left)) {
					group_w_dragging = false;
				}
			}
			
			if(pHOVER && point_in_rectangle(mx, my, group_w - ui(2), content_y, group_w + ui(2), content_y + content_h)) {
				CURSOR = cr_size_we;
				if(pFOCUS && mouse_press(mb_left)) {
					group_w_dragging = true;
					group_w_mx = mx;
					group_w_sx = group_w;
				}
			}
		#endregion
		
		var _x = ui(16);
		var _y = ui(24);
		var bh = line_height(f_p0b, 8);
		var rootx = 0;
		
		for( var i = 0; i < array_length(roots); i++ ) {
			var r = roots[i];
			var b = buttonInstant(THEME.button_hide_fill, _x - ui(8), _y - bh / 2, string_width(r[0]) + ui(20), bh, [mx, my], pFOCUS, pHOVER);
			if(b == 2) {
				mode = i;
				root = r[1];
				context = root;
			}
			
			draw_set_text(f_p0b, fa_left, fa_center, i == mode? COLORS._main_text
				: COLORS._main_text_sub);
			draw_text(_x, _y, r[0]);
			
			_x += string_width(r[0]) + ui(20);
		}
		
		rootx = _x;
		
		var bx = w - ui(40);
		var by = ui(12);
		
		if(search_string == "") {
			if(bx > rootx) {
				var txt = contentView? get_text("view_grid", "Grid view") : get_text("view_list", "List view");
				if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), [mx, my], pFOCUS, pHOVER, txt, THEME.view_mode, contentView) == 2) {
					contentView = !contentView;
				}
			}
			bx -= ui(32);
			
			if(mode == 0 && !DEMO) {
				if(bx > rootx) {
					if(context != root) {
						var txt = get_text("panel_collection_add_node", "Add selecting node as collection");
						if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), [mx, my], pFOCUS, pHOVER, txt, THEME.add, 0, COLORS._main_value_positive) == 2) {
							if(PANEL_INSPECTOR.inspecting != noone) {
								data_path = context.path;
								var dia = dialogCall(o_dialog_file_name_collection, mouse_mx + ui(8), mouse_my + ui(8));
								if(PANEL_INSPECTOR.inspecting)
									dia.meta.name = PANEL_INSPECTOR.inspecting.display_name;
							}
						}
					} else {
						draw_sprite_ui_uniform(THEME.add, 0, bx + ui(12), by + ui(12), 1, COLORS._main_icon_dark);	
					}
				}
				bx -= ui(32);
		
				if(bx > rootx) {
					var txt = get_text("panel_collection_add_folder", "Add folder");
					if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), [mx, my], pFOCUS, pHOVER, txt) == 2) {
						var dia = dialogCall(o_dialog_file_name, mouse_mx + 8, mouse_my + 8);
						dia.onModify = function (txt) {
							directory_create(txt);
							refreshContext();
						};
						dia.path = context.path + "/";
					}
					draw_sprite_ui_uniform(THEME.folder_add, 0, bx + ui(12), by + ui(12), 1, COLORS._main_icon);
					draw_sprite_ui_uniform(THEME.folder_add, 1, bx + ui(12), by + ui(12), 1, COLORS._main_value_positive);
				}
				bx -= ui(32);
			}
		
			if(bx > rootx) {
				var txt = get_text("panel_collection_open_file", "Open in file explorer");
				if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), [mx, my], pFOCUS, pHOVER, txt, THEME.folder) == 2)
					shellOpenExplorer(context.path);
			}
			bx -= ui(32);
			
			if(bx > rootx) {
				var txt = get_text("refresh", "Refresh");
				if(buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), [mx, my], pFOCUS, pHOVER, txt, THEME.refresh) == 2)
					refreshContext();
			}
			bx -= ui(32);
		} else {
			var tb_w = ui(200);
			var tb_x = w - ui(10) - tb_w;
			var tb_y = ui(10);
			
			tb_search.draw(tb_x, tb_y, tb_w, TEXTBOX_HEIGHT, search_string, [mx, my]);
		}
		
		if(file_dragging) {
			if(file_dragging.spr)
				draw_sprite_ext(file_dragging.spr, 0, mx, my, 1, 1, 0, c_white, 0.5);
			
			if(panelHover(PANEL_GRAPH)) 
				dragToGraph();
			
			if(mouse_release(mb_left)) 
				file_dragging = noone;
		}
	}
	
	static dragToGraph = function() {
		var path = file_dragging.path;
		ds_list_clear(PANEL_GRAPH.nodes_select_list);
		
		if(string_lower(filename_ext(path)) == ".png") {
			var app = Node_create_Image_path(0, 0, path);
			
			PANEL_GRAPH.node_focus	  = app;
			PANEL_GRAPH.node_dragging = app;
			PANEL_GRAPH.node_drag_sx  = app.x;
			PANEL_GRAPH.node_drag_sy  = app.y;
		} else {
			var app = APPEND(file_dragging.path);
			
			if(!is_struct(app) && ds_exists(app, ds_type_list)) {
				PANEL_GRAPH.node_focus	      = noone;
				ds_list_copy(PANEL_GRAPH.nodes_select_list, app);
					
				if(!ds_list_empty(app)) {
					PANEL_GRAPH.node_dragging = app[| 0];
					PANEL_GRAPH.node_drag_sx  = app[| 0].x;
					PANEL_GRAPH.node_drag_sy  = app[| 0].y;
				}
				ds_list_destroy(app);
			} else {
				PANEL_GRAPH.node_focus	  = app;
				PANEL_GRAPH.node_dragging = app;
				PANEL_GRAPH.node_drag_sx  = app.x;
				PANEL_GRAPH.node_drag_sy  = app.y;
			}
		}
		
		PANEL_GRAPH.node_drag_mx  = 0;
		PANEL_GRAPH.node_drag_my  = 0;
				
		PANEL_GRAPH.node_drag_ox  = 0;
		PANEL_GRAPH.node_drag_oy  = 0;
		
		file_dragging = false;
	}
}