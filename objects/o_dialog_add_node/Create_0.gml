/// @description init
event_inherited();

#region data
	draggable = false;
	
	node_target_x = 0;
	node_target_y = 0;
	node_called   = noone;
	junction_hovering = noone;
	
	if(ADD_NODE_W == -1 || ADD_NODE_H == -1) {
		ADD_NODE_W = ui(532);
		ADD_NODE_H = ui(346);	
	}
	
	dialog_w = ADD_NODE_W;
	dialog_h = ADD_NODE_H;
	
	destroy_on_click_out = true;
	
	node_selecting = 0;
	node_focusing = -1;
	
	anchor = ANCHOR.left | ANCHOR.top;
	
	page_key   = ADD_NODE_PAGE == ""? NODE_CATAGORY[| 3] : ADD_NODE_PAGE;
	page       = ALL_NODES[? page_key];
	
	function buildNode(_node, _param = "") {
		instance_destroy();
		
		if(!_node) return;
		
		var _new_node = noone;
		var _inputs = 0, _outputs = 0;
		
		if(is_struct(_node) && instanceof(_node) == "NodeObject") {
			_new_node = _node.build(node_target_x, node_target_y, _param);
			if(!_new_node) return;
			_inputs = _new_node.inputs;
			_outputs = _new_node.outputs;
		} else {
			var _new_list = APPEND(_node.path);
			_inputs = ds_list_create();
			_outputs = ds_list_create();
			
			for( var i = 0; i < ds_list_size(_new_list); i++ ) {
				var _in = _new_list[| i].inputs;
				for( var j = 0; j < ds_list_size(_in); j++ ) {
					if(_in[| j].value_from == noone)
						ds_list_add(_inputs, _in[| j]);
				}
				
				var _ot = _new_list[| i].outputs;
				for( var j = 0; j < ds_list_size(_ot); j++ ) {
					if(ds_list_empty(_ot[| j].value_to))
						ds_list_add(_outputs, _ot[| j]);
				}
			}
			
			ds_list_destroy(_new_list);
		}
		
		if(node_called != noone) {
			var _node_list = node_called.connect_type == JUNCTION_CONNECT.input? _outputs : _inputs;
			for(var i = 0; i < ds_list_size(_node_list); i++) {
				var _target = _node_list[| i]; 
				if( _target.isVisible() && (value_bit(_target.type) & value_bit(node_called.type)) ) {
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
				
			for( var i = 0; i < ds_list_size(_inputs); i++ ) {
				var _in = _inputs[| i];
				if(value_bit(_in.type) & value_bit(from.type)) {
					_in.setFrom(from);
					break;
				}
			}
				
			for( var i = 0; i < ds_list_size(_outputs); i++ ) {
				var _ot = _outputs[| i];
				if(value_bit(_ot.type) & value_bit(to.type)) {
					to.setFrom(_ot);
					break;
				}
			}
		}
	}
	
	catagory_pane = new scrollPane(ui(132), dialog_h - ui(66), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh  = 0;
		var hg  = ui(28);
		var key = ds_map_find_first(ALL_NODES);
		var cnt = PANEL_GRAPH.getCurrentContext();
		var context = cnt == -1? "" : instanceof(cnt);
		
		for(var i = 0; i < ds_list_size(NODE_CATAGORY); i++) {
			var key = NODE_CATAGORY[| i];
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			
			switch(key) {
				case "Group" : 
					if(context != "Node_Group") continue; 
					draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_accent);
					break;	
				case "Loop" : 
					if(context != "Node_Iterate") continue; 
					draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_accent);
					break;	
				case "VFX" : 
					if(context != "Node_VFX_Group") continue; 
					draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_accent);
					break;	
			}
			
			if(key == page_key) {
				draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, _y + hh, ui(132), hg);
			} else if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, _y + hh, ui(100), _y + hh + hg - 1)) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y + hh + ui(3), ui(103), hg - ui(6), c_white, 0.75);
				if(mouse_click(mb_left, sFOCUS)) {
					page_key		= key;
					ADD_NODE_PAGE	= key;
					page			= ALL_NODES[? page_key];
					content_pane.scroll_y		= 0;
					content_pane.scroll_y_to	= 0;
				}
			}
			
			draw_text(ui(8), _y + hh + hg / 2, key);
			hh += hg;
		}
		
		return hh;
	});
	
	content_pane = new scrollPane(dialog_w - ui(144), dialog_h - ui(66), function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var nodes	   = page;
		var node_count = ds_list_size(nodes);
		var hh         = 0;
		
		if(ADD_NODE_MODE == 0) {
			var grid_size  = ui(64);
			var grid_width = ui(80);
			var grid_space = ui(12);
			var col        = floor(content_pane.surface_w / (grid_width + grid_space));
			var row        = ceil(node_count / col);
			var yy         = _y + grid_space;
			var name_height = 0;
			hh += grid_space;
		
			for(var i = 0; i < row; i++) {
				name_height = 0;
				for(var j = 0; j < col; j++) {
					var index = i * col + j;
					if(index < node_count) {
						var _node = nodes[| index];
						if(!_node) continue;
					
						var _nx   = grid_space + (grid_width + grid_space) * j;
						var _boxx = _nx + (grid_width - grid_size) / 2;
						
						BLEND_ADD
						draw_sprite_stretched(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size);
						BLEND_NORMAL
						
						if(sHOVER && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
							draw_sprite_stretched_ext(THEME.node_active, 0, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
							if(mouse_press(mb_left, sFOCUS))
								buildNode(_node);
						}
						
						var spr_x = _boxx + grid_size / 2;
						var spr_y = yy + grid_size / 2;
						if(variable_struct_exists(_node, "spr") && sprite_exists(_node.spr))
							draw_sprite_ui_uniform(_node.spr, 0, spr_x, spr_y);
					
						draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
						name_height = max(name_height, string_height_ext(_node.name, -1, grid_width) + 8);
						draw_text_ext(_boxx + grid_size / 2, yy + grid_size + 4, _node.name, -1, grid_width);
					}
				}
				var hght = grid_size + grid_space + name_height;
				hh += hght;
				yy += hght;
			}	
		} else if(ADD_NODE_MODE == 1) {
			var list_width  = content_pane.surface_w;
			var list_height = ui(28);
			var yy         = _y + list_height / 2;
			hh += list_height;
		
			for(var i = 0; i < node_count; i++) {
				var _node = nodes[| i];
				if(!_node) continue;
				
				if(i % 2) {
					BLEND_ADD
					draw_sprite_stretched_ext(THEME.node_bg, 0, ui(4), yy, list_width - ui(8), list_height, c_white, 0.2);
					BLEND_NORMAL
				}
				
				if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, list_width, yy + list_height - 1)) {
					draw_sprite_stretched_ext(THEME.node_active, 0, ui(4), yy, list_width - ui(8), list_height, COLORS._main_accent, 1);
					if(mouse_press(mb_left, sFOCUS))
						buildNode(_node);
				}
					
				var spr_x = list_height / 2 + ui(14);
				var spr_y = yy + list_height / 2;
				if(variable_struct_exists(_node, "spr") && sprite_exists(_node.spr)) {
					var ss = (list_height - ui(8)) / max(sprite_get_width(_node.spr), sprite_get_height(_node.spr));
					draw_sprite_ext(_node.spr, 0, spr_x, spr_y, ss, ss, 0, c_white, 1);
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text(list_height + ui(20), yy + list_height / 2, _node.name);
				
				yy += list_height;
				hh += list_height;
			}
		}
		
		return hh;
	});
#endregion

#region resize
	dialog_resizable = true;
	dialog_w_min = ui(200);
	dialog_h_min = ui(120);
	dialog_w_max = ui(800);
	dialog_h_max = ui(640);
	
	onResize = function() {
		catagory_pane.resize(ui(132), dialog_h - ui(66));
		content_pane.resize(dialog_w - ui(144), dialog_h - ui(66));
		search_pane.resize(dialog_w - ui(40), dialog_h - ui(66));
		
		ADD_NODE_W = dialog_w;
		ADD_NODE_H = dialog_h;
	}
#endregion

#region search
	search_string = "";
	search_list = ds_list_create();
	keyboard_lastchar = "";
	KEYBOARD_STRING = "";
	keyboard_lastkey = -1;
	
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) { 
		search_string = string(str); 
		searchNodes();
	});
	tb_search.auto_update	= true;
	TEXTBOX_ACTIVE			= tb_search;
	
	function searchNodes() {
		ds_list_clear(search_list);
		
		var cnt = PANEL_GRAPH.getCurrentContext();
		var context = cnt == -1? "" : instanceof(cnt);
		var search_lower = string_lower(search_string);
		
		for(var i = 0; i < ds_list_size(NODE_CATAGORY); i++) {
			var key = NODE_CATAGORY[| i];
			
			switch(key) {
				case "Group" : if(context != "Node_Group") continue; break;	
				case "Loop" : if(context != "Node_Iterate") continue; break;	
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
				
				if(match)
					ds_list_add(search_list, [_node, param]);
			}
		}
		
		searchCollection(search_list, search_string, false);
	}
	
	search_pane = new scrollPane(dialog_w - ui(40), dialog_h - ui(66), function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var amo = ds_list_size(search_list);
		var hh = 0;
		
		if(ADD_NODE_MODE == 0) {
			var grid_size = ui(64);
			var grid_width = ui(80);
			var grid_space = ui(16);
			var col = floor(search_pane.surface_w / (grid_width + grid_space));
			var yy = _y + grid_space;
			var index = 0;
			var name_height = 0;
			
			hh += (grid_space + grid_size) * 2;
			
			for(var i = 0; i < amo; i++) {
				var s_res = search_list[| i];
				var _node = noone, _param = "";
				if(is_array(s_res)) {
					_node = s_res[0];
					_param = s_res[1];
				} else
					_node = s_res;
			
				var _nx   = grid_space + (grid_width + grid_space) * index;
				var _boxx = _nx + (grid_width - grid_size) / 2;
				
				BLEND_ADD
				if(is_array(s_res))
					draw_sprite_stretched(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size);
				else
					draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, COLORS.dialog_add_node_collection, 1);
				BLEND_NORMAL
					
				if(variable_struct_exists(_node, "spr") && sprite_exists(_node.spr)) {
					var _si = current_time * PREF_MAP[? "collection_preview_speed"] / 3000;
					var _sw = sprite_get_width(_node.spr);
					var _sh = sprite_get_height(_node.spr);
					var _ss = ui(32) / max(_sw, _sh);
				
					var _sox = sprite_get_xoffset(_node.spr);
					var _soy = sprite_get_yoffset(_node.spr);
				
					var _sx = _boxx + grid_size / 2;
					var _sy = yy + grid_size / 2;
					_sx += _sw * _ss / 2 - _sox * _ss;
					_sy += _sh * _ss / 2 - _soy * _ss;
				
					draw_sprite_ext(_node.spr, _si, _sx, _sy, _ss, _ss, 0, c_white, 1);
				}
			
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
				var txt = _node.name;
				name_height = max(name_height, string_height_ext(txt, -1, grid_width) + ui(8));
				draw_text_ext(_boxx + grid_size / 2, yy + grid_size + 4, txt, -1, grid_width);
				
				if(sHOVER && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
					node_selecting = i;
					if(mouse_press(mb_left, sFOCUS))
						buildNode(_node, _param);
				}
				
				if(node_selecting == i) {
					draw_sprite_stretched_ext(THEME.node_active, 0, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
					if(keyboard_check_pressed(vk_enter))
						buildNode(_node, _param);
				}
					
				if(node_focusing == i)
					search_pane.scroll_y_to = -max(0, hh - search_pane.h);	
					
				if(++index >= col) {
					index = 0;
					var hght = grid_size + grid_space + name_height;
					name_height = 0;
					hh += hght;
					yy += hght;
				}
			}
		} else if(ADD_NODE_MODE == 1) {
			var list_width  = search_pane.surface_w;
			var list_height = ui(28);
			var yy = _y + list_height / 2;
			hh += list_height;
		
			for(var i = 0; i < amo; i++) {
				var s_res = search_list[| i];
				var _node = noone, _param = "";
				if(is_array(s_res)) {
					_node = s_res[0];
					_param = s_res[1];
				} else
					_node = s_res;
				
				if(i % 2) {
					BLEND_ADD
					draw_sprite_stretched_ext(THEME.node_bg, 0, ui(4), yy, list_width - ui(8), list_height, c_white, 0.2);
					BLEND_NORMAL
				}
				
				if(variable_struct_exists(_node, "spr") && sprite_exists(_node.spr)) {
					var _si = current_time * PREF_MAP[? "collection_preview_speed"] / 3000;
					var _sw = sprite_get_width(_node.spr);
					var _sh = sprite_get_height(_node.spr);
					var _ss = (list_height - ui(8)) / max(_sw, _sh);
				
					var _sox = sprite_get_xoffset(_node.spr);
					var _soy = sprite_get_yoffset(_node.spr);
					
					var _sx = list_height / 2 + ui(14);
					var _sy = yy + list_height / 2;
					_sx += _sw * _ss / 2 - _sox * _ss;
					_sy += _sh * _ss / 2 - _soy * _ss;
				
					draw_sprite_ext(_node.spr, _si, _sx, _sy, _ss, _ss, 0, c_white, 1);
				}
			
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text(list_height + ui(20), yy + list_height / 2, _node.name);
				
				if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, list_width, yy + list_height - 1)) {
					node_selecting = i;
					if(mouse_press(mb_left, sFOCUS))
						buildNode(_node, _param);
				}
				
				if(node_selecting == i) {
					draw_sprite_stretched_ext(THEME.node_active, 0, ui(4), yy, list_width - ui(8), list_height, COLORS._main_accent, 1);
					if(keyboard_check_pressed(vk_enter))
						buildNode(_node, _param);
				}
					
				if(node_focusing == i)
					search_pane.scroll_y_to = -max(0, hh - search_pane.h);	
				
				hh += list_height;
				yy += list_height;
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