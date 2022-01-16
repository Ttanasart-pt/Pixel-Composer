/// @description init
event_inherited();

#region data
	draggable = false;
	
	node_target_x = 0;
	node_target_y = 0;
	node_called   = noone;
	
	dialog_w = ADD_NODE_W;
	dialog_h = ADD_NODE_H;
	
	destroy_on_click_out = true;
	
	anchor = ANCHOR.left | ANCHOR.top;
	
	if(PANEL_GRAPH.getCurrentContext() == -1 && ADD_NODE_PAGE == "Group")
		ADD_NODE_PAGE = NODE_CATAGORY[| 0];
		
	page_key   = ADD_NODE_PAGE == ""? NODE_CATAGORY[| 0] : ADD_NODE_PAGE;
	page       = ALL_NODES[? page_key];
	
	function buildNode(_node) {
		instance_destroy();
		
		if(!_node) return;
		
		var _new_node = _node.build(node_target_x, node_target_y);
		
		if(_new_node && node_called) {
			var _node_list = node_called.connect_type == JUNCTION_CONNECT.input? _new_node.outputs : _new_node.inputs;
			for(var i = 0; i < ds_list_size(_node_list); i++) {
				var _target = _node_list[| i]; 
				if(_target.isVisible() && (value_bit(_target.type) & value_bit(node_called.type))) {
					if(node_called.connect_type == JUNCTION_CONNECT.input) {
						node_called.setFrom(_node_list[| i]);
						_new_node.x -= _new_node.w;
					} else
						_node_list[| i].setFrom(node_called);
					break;
				}
			}
		}
	}
	
	catagory_pane = new scrollPane(132, dialog_h - 28, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		
		var hh  = 0;
		var hg  = 28;
		var key = ds_map_find_first(ALL_NODES);
		
		for(var i = 0; i < ds_list_size(NODE_CATAGORY); i++) {
			var key = NODE_CATAGORY[| i];
			if(PANEL_GRAPH.getCurrentContext() == -1 && key == "Group") continue;
			
			draw_set_text(f_p0, fa_left, fa_center, c_white);
			if(key == page_key) {
				draw_sprite_stretched(s_ui_panel_bg, 0, 0, _y + hh, 132, hg);
			} else if(point_in_rectangle(_m[0], _m[1], 0, _y + hh, 100, _y + hh + hg - 1)) {
				draw_sprite_stretched_ext(s_ui_panel_bg, 0, 0, _y + hh, 132, hg, c_white, 0.5);
				if(mouse_check_button(mb_left)) {
					page_key		= key;
					ADD_NODE_PAGE	= key;
					page			= ALL_NODES[? page_key];
					content_pane.scroll_y		= 0;
					content_pane.scroll_y_to	= 0;
				}
			}
			
			draw_text(8, _y + hh + hg / 2, key);
			hh += hg;
		}
		
		return hh;
	});
	
	content_pane = new scrollPane(dialog_w - 144, dialog_h - 28, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		
		var grid_size  = 64;
		var grid_width = 80;
		var grid_space = 12;
		var nodes	   = page;
		var node_count = ds_list_size(nodes);
		var col        = floor(content_pane.surface_w / (grid_width + grid_space));
		var row        = ceil(node_count / col);
		var hh         = grid_space;
		var yy         = _y + grid_space;
		var name_height = 0;
		
		for(var i = 0; i < row; i++) {
			name_height = 0;
			for(var j = 0; j < col; j++) {
				var index = i * col + j;
				if(index < node_count) {
					var _node = nodes[| index];
					if(!_node) continue;
					
					var _nx   = grid_space + (grid_width + grid_space) * j;
					var _boxx = _nx + (grid_width - grid_size) / 2;
					
					draw_sprite_stretched(s_node_bg, 0, _boxx, yy, grid_size, grid_size);
					
					if(point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
						draw_sprite_stretched(s_node_active, 0, _boxx, yy, grid_size, grid_size);	
						if(mouse_check_button_pressed(mb_left)) {
							buildNode(_node);
						}
					}
					
					if(variable_struct_exists(_node, "spr") && sprite_exists(_node.spr))
						draw_sprite(_node.spr, 0, _boxx + grid_size / 2, yy + grid_size / 2);
				
					draw_set_text(f_p1, fa_center, fa_top, c_white);
					name_height = max(name_height, string_height_ext(_node.name, -1, grid_size) + 8);
					draw_text_ext(_boxx + grid_size / 2, yy + grid_size + 4, _node.name, -1, grid_width);
				}
			}
			var hght = grid_size + grid_space + name_height;
			hh += hght;
			yy += hght;
		}
		
		return hh;
	});
#endregion

#region resize
	dialog_resizable = true;
	dialog_w_min = 200;
	dialog_h_min = 120;
	dialog_w_max = 640;
	dialog_h_max = 480;
	
	onResize = function() {
		catagory_pane.resize(132, dialog_h - 28);
		content_pane.resize(dialog_w - 144, dialog_h - 28);
		search_pane.resize(dialog_w - 32, dialog_h - 52 - 14);
		
		ADD_NODE_W = dialog_w;
		ADD_NODE_H = dialog_h;
	}
#endregion

#region search
	search_string = "";
	keyboard_lastchar = "";
	keyboard_string = "";
	keyboard_lastkey = -1;
	
	tb_search				= new textBox(TEXTBOX_INPUT.text, function(str) { search_string = string(str); });
	tb_search.auto_update	= true;
	TEXTBOX_ACTIVE			= tb_search;
	
	search_pane = new scrollPane(dialog_w - 32, dialog_h - 52 - 14, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		
		var grid_size  = 64;
		var grid_width = 80;
		var grid_space = 16;
		var col        = floor(search_pane.surface_w / (grid_width + grid_space));
		var hh         = (grid_space + grid_size) * 2;
		var yy         = _y + grid_space;
		var index      = 0;
		var name_height = 0;
		
		var search_lower = string_lower(search_string);
		for(var i = 0; i < ds_list_size(NODE_CATAGORY); i++) {
			var _page = ALL_NODES[? NODE_CATAGORY[| i]];
			
			for(var j = 0; j < ds_list_size(_page); j++) {
				var _node = _page[| j];

				if(!_node) continue;
				var match = string_pos(search_lower, string_lower(_node.name)) > 0;
				for( var k = 0; k < array_length(_node.tags); k++ ) {
					if(string_pos(search_lower, _node.tags[k]) > 0)
						match = true;
				}
				
				if(match) {
					var _nx   = grid_space + (grid_width + grid_space) * index;
					var _boxx = _nx + (grid_width - grid_size) / 2;
					
					draw_sprite_stretched(s_node_bg, 0, _boxx, yy, grid_size, grid_size);
					
					if(variable_struct_exists(_node, "spr") && sprite_exists(_node.spr))
						draw_sprite(_node.spr, 0, _boxx + grid_size / 2, yy + grid_size / 2);
				
					draw_set_text(f_p1, fa_center, fa_top, c_white);
					name_height = max(name_height, string_height_ext(_node.name, -1, grid_size) + 8);
					draw_text_ext(_boxx + grid_size / 2, yy + grid_size + 4, _node.name, -1, grid_width);
				
					if(point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
						draw_sprite_stretched(s_node_active, 0, _boxx, yy, grid_size, grid_size);	
						if(mouse_check_button_pressed(mb_left))
							buildNode(_node);
					}
					
					if(++index >= col) {
						index = 0;
						var hght = grid_size + grid_space + name_height;
						name_height = 0;
						hh += hght;
						yy += hght;
					}
				}
			}
		}
		
		return hh;
	});
#endregion