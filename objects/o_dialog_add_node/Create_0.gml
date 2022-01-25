/// @description init
event_inherited();

#region data
	draggable = false;
	
	node_target_x = 0;
	node_target_y = 0;
	node_called   = noone;
	junction_hovering = noone;
	
	dialog_w = ADD_NODE_W;
	dialog_h = ADD_NODE_H;
	
	destroy_on_click_out = true;
	
	node_selecting = 0;
	node_focusing = -1;
	
	anchor = ANCHOR.left | ANCHOR.top;
	
	page_key   = ADD_NODE_PAGE == ""? NODE_CATAGORY[| 2] : ADD_NODE_PAGE;
	page       = ALL_NODES[? page_key];
	
	function buildNode(_node, _param = "") {
		instance_destroy();
		
		if(!_node) return;
		
		var _new_node = _node.build(node_target_x, node_target_y, _param);
		
		if(_new_node) {
			if(node_called != noone) {
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
			} else if(junction_hovering != noone) {
				var to = junction_hovering;
				var from = junction_hovering.value_from;
				
				for( var i = 0; i < ds_list_size(_new_node.inputs); i++ ) {
					var _in = _new_node.inputs[| i];
					if(value_bit(_in.type) & value_bit(from.type)) {
						_in.setFrom(from);
						break;
					}
				}
				
				for( var i = 0; i < ds_list_size(_new_node.outputs); i++ ) {
					var _ot = _new_node.outputs[| i];
					if(value_bit(_ot.type) & value_bit(to.type)) {
						to.setFrom(_ot);
						break;
					}
				}
			}
		}
	}
	
	catagory_pane = new scrollPane(132, dialog_h - 28, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		
		var hh  = 0;
		var hg  = 28;
		var key = ds_map_find_first(ALL_NODES);
		var cnt = PANEL_GRAPH.getCurrentContext();
		var context = cnt == -1? "" : instanceof(cnt);
		
		for(var i = 0; i < ds_list_size(NODE_CATAGORY); i++) {
			var key = NODE_CATAGORY[| i];
			draw_set_text(f_p0, fa_left, fa_center, c_white);
			
			switch(key) {
				case "Group" : 
					if(context != "Node_Group") continue; 
					draw_set_text(f_p0, fa_left, fa_center, c_ui_orange);
					break;	
				case "Loop" : 
					if(context != "Node_Iterate") continue; 
					draw_set_text(f_p0, fa_left, fa_center, c_ui_orange);
					break;	
			}
			
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
		var amo = 0;
		
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
					
					var spr_x = _boxx + grid_size / 2;
					var spr_y = yy + grid_size / 2;
					if(variable_struct_exists(_node, "spr") && sprite_exists(_node.spr))
						draw_sprite(_node.spr, 0, spr_x, spr_y);
					
					draw_set_text(f_p1, fa_center, fa_top, c_white);
					name_height = max(name_height, string_height_ext(_node.name, -1, grid_size) + 8);
					draw_text_ext(_boxx + grid_size / 2, yy + grid_size + 4, _node.name, -1, grid_width);
					
					amo++;
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
		
		var grid_size = 64;
		var grid_width = 80;
		var grid_space = 16;
		var col = floor(search_pane.surface_w / (grid_width + grid_space));
		var hh = (grid_space + grid_size) * 2;
		var yy = _y + grid_space;
		var index = 0;
		var name_height = 0;
		var amo = 0;
		var cnt = PANEL_GRAPH.getCurrentContext();
		var context = cnt == -1? "" : instanceof(cnt);
		
		var search_lower = string_lower(search_string);
		
		for(var i = 0; i < ds_list_size(NODE_CATAGORY); i++) {
			var key = NODE_CATAGORY[| i];
			
			switch(key) {
				case "Group" : 
					if(context != "Node_Group") continue; 
					break;	
				case "Loop" : 
					if(context != "Node_Iterate") continue; 
					break;	
			}
			
			var _page = ALL_NODES[? key];
			
			for(var j = 0; j < ds_list_size(_page); j++) {
				var _node = _page[| j];

				if(!_node) continue;
				var match = string_pos(search_lower, string_lower(_node.name)) > 0;
				var param = "";
				for( var k = 0; k < array_length(_node.tags); k++ ) {
					if(string_pos(search_lower, _node.tags[k]) > 0) {
						match = true;
						param = _node.tags[k];
					}
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
						node_selecting = amo;
						if(mouse_check_button_pressed(mb_left))
							buildNode(_node, param);
					}
					
					if(node_selecting == amo) {
						draw_sprite_stretched(s_node_active, 0, _boxx, yy, grid_size, grid_size);
						if(keyboard_check_pressed(vk_enter))
							buildNode(_node, param);
					}
					
					if(node_focusing == amo) {
						search_pane.scroll_y_to = -max(0, hh - search_pane.h);	
					}
					
					if(++index >= col) {
						index = 0;
						var hght = grid_size + grid_space + name_height;
						name_height = 0;
						hh += hght;
						yy += hght;
					}
					
					amo++;
				}
			}
		}
		
		node_focusing = -1;
		
		if(keyboard_check_pressed(vk_up)) {
			node_selecting = safe_mod(node_selecting - 1 + amo, amo);
			node_focusing = node_selecting;
		}
		
		if(keyboard_check_pressed(vk_down)) {
			node_selecting = safe_mod(node_selecting + 1, amo);
			node_focusing = node_selecting;
		}
		
		return hh;
	});
#endregion