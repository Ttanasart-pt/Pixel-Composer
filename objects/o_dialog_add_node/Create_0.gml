/// @description init
event_inherited();

#region data
	draggable = false;
	
	node_target_x	  = 0;
	node_target_y	  = 0;
	node_called		  = noone;
	junction_hovering = noone;
	
	dialog_w = PREF_MAP[? "dialog_add_node_w"];
	dialog_h = PREF_MAP[? "dialog_add_node_h"];
	
	destroy_on_click_out = true;
	
	node_selecting = 0;
	node_focusing  = -1;
	
	node_show_connectable = true;
	node_tooltip   = noone;
	node_tooltip_x = 0;
	node_tooltip_y = 0;
	
	anchor = ANCHOR.left | ANCHOR.top;
	node_menu_selecting = noone;
	
	var _con    = PANEL_GRAPH.getCurrentContext();
	var context = _con == noone? "" : instanceof(_con);
	
	#region ---- category ----
		category = NODE_CATEGORY;
		switch(context) {
			case "Node_Pixel_Builder" : category = NODE_PB_CATEGORY;  break;
			case "Node_DynaSurf" :      category = NODE_PCX_CATEGORY; break;
		}
	
		draw_set_font(f_p0);
		var maxLen = 0;
		for(var i = 0; i < ds_list_size(category); i++) {
			var cat  = category[| i];
		
			if(array_length(cat.filter) && !array_exists(cat.filter, context))
				continue;
			
			var name = __txt(cat.name);
			maxLen   = max(maxLen, string_width(name));
		}
		category_width = maxLen + ui(44);
	#endregion
	
	function rightClick(node) { #region
		if(!is_instanceof(node, NodeObject)) return;
		
		node_menu_selecting = node;
		var fav  = array_exists(global.FAV_NODES, node.node);
		
		var menu = [
			menuItem(fav? __txtx("add_node_remove_favourite", "Remove from favourite") : __txtx("add_node_add_favourite", "Add to favourite"), 
			function() {
				if(array_exists(global.FAV_NODES, node_menu_selecting.node))
					array_remove(global.FAV_NODES, node_menu_selecting.node);
				else 
					array_push(global.FAV_NODES, node_menu_selecting.node);
			}, THEME.star)
		];
		
		menuCall("add_node_window_manu",,, menu,, node_menu_selecting);
	} #endregion
	
	function filtered(node) { #region
		if(!node_show_connectable) return true;
		if(node_called == noone && junction_hovering == noone) return true;
		if(!struct_has(node, "node")) return true;
		if(!struct_has(global.NODE_GUIDE, node.node)) return true;
		
		var io = global.NODE_GUIDE[$ node.node];
		
		if(node_called) {
			var call_in = node_called.connect_type == JUNCTION_CONNECT.input;
			var ar = call_in? io.outputs : io.inputs;
			var typ = node_called.type;
			
			for( var i = 0, n = array_length(ar); i < n; i++ ) {
				if(!ar[i].visible) continue;
				
				var _in = call_in? node_called.type : ar[i].type;
				var _ot = call_in? ar[i].type : node_called.type;
				
				if(typeCompatible(_in, _ot, false)) return true;
			}
			
			return false;
		} else if(junction_hovering) {
			var to = junction_hovering.type;
			var fr = junction_hovering.value_from.type;
			
			for( var i = 0, n = array_length(io.inputs); i < n; i++ ) {
				var _in = fr;
				var _ot = io.inputs[i].type;
				if(!io.inputs[i].visible) continue;
				
				if(typeCompatible(_in, _ot, false)) return true;
			}
			
			for( var i = 0, n = array_length(io.outputs); i < n; i++ ) {
				var _in = io.outputs[i].type;
				var _ot = to;
				
				if(typeCompatible(_in, _ot, false)) return true;
			}
			
			return false;
		}
		
		return false;
	} #endregion
	
	#region ---- set page ----
		function setPage(pageIndex) {
			ADD_NODE_PAGE	= min(pageIndex, ds_list_size(category) - 1);
			node_list		= pageIndex == -1? noone : category[| ADD_NODE_PAGE].list;
		}
		ADD_NODE_PAGE = 0;
		setPage(NODE_PAGE_DEFAULT);
	#endregion
	
	function buildNode(_node, _param = {}) { #region
		if(!_node) {
			instance_destroy();
			instance_destroy(o_dialog_menubox);
			return;
		}
		
		if(is_instanceof(_node, AddNodeItem)) {
			_node.onClick({
				node_called,
				junction_hovering
			});
			instance_destroy(o_dialog_menubox);
			instance_destroy();
			return;
		}
		
		var _new_node = noone;
		var _inputs = 0, _outputs = 0;
		
		if(is_instanceof(_node, NodeObject)) {
			_new_node = _node.build(node_target_x, node_target_y,, _param);
			if(!_new_node) {
				instance_destroy();
				instance_destroy(o_dialog_menubox);
				return;
			}
			
			if(category == NODE_CATEGORY && _node.show_in_recent) {
				array_remove(global.RECENT_NODES, _node.node);
				array_insert(global.RECENT_NODES, 0, _node.node);
				if(array_length(global.RECENT_NODES) > 20)
					array_pop(global.RECENT_NODES);
			}
			
			_inputs  = _new_node.inputs;
			_outputs = _new_node.outputs;
		} else if(is_instanceof(_node, NodeAction)) {
			var res = _node.build(node_target_x, node_target_y,, _param);
			
			if(_node.inputNode != noone)
				_inputs  = res[$ _node.inputNode].inputs;
			
			if(_node.outputNode != noone)
				_outputs = res[$ _node.outputNode].outputs;
		} else {
			var _new_list = APPEND(_node.path);
			_inputs  = ds_list_create();
			_outputs = ds_list_create();
			
			var tx = 99999;
			var ty = 99999;
			for( var i = 0; i < ds_list_size(_new_list); i++ ) {
				tx = min(tx, _new_list[| i].x);
				ty = min(tx, _new_list[| i].y);
			}
			
			var shx = tx - node_target_x;
			var shy = ty - node_target_y;
			
			for( var i = 0; i < ds_list_size(_new_list); i++ ) {
				_new_list[| i].x -= shx;
				_new_list[| i].y -= shy;
			}
			
			for( var i = 0; i < ds_list_size(_new_list); i++ ) {
				var _in = _new_list[| i].inputs;
				for( var j = 0; j < ds_list_size(_in); j++ ) {
					if(_in[| j].isLeaf())
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
		
		//try to connect
		if(node_called != noone) { //dragging from junction
			var _call_input = node_called.connect_type == JUNCTION_CONNECT.input;
			var _node_list  = _call_input? _outputs : _inputs;
			for(var i = 0; i < ds_list_size(_node_list); i++) {
				var _target = _node_list[| i]; 
				if(!_target.visible) continue;
				
				if(_target.auto_connect) {
					if(_call_input && node_called.isConnectable(_node_list[| i])) {
						node_called.setFrom(_node_list[| i]);
						_new_node.x -= _new_node.w;
					} else if(!_call_input && _node_list[| i].isConnectable(node_called))
						_node_list[| i].setFrom(node_called);
					break;
				}
			}
		} else if(junction_hovering != noone) { //right click on junction
			var to = junction_hovering;
			var from = junction_hovering.value_from;
				
			for( var i = 0; i < ds_list_size(_inputs); i++ ) {
				var _in = _inputs[| i];
				
				if(_in.auto_connect && _in.isConnectable(from)) {
					_in.setFrom(from);
					break;
				}
			}
				
			for( var i = 0; i < ds_list_size(_outputs); i++ ) {
				var _ot = _outputs[| i];
				if(to.isConnectable(_ot)) {
					to.setFrom(_ot);
					break;
				}
			}
		}
		
		instance_destroy();
		instance_destroy(o_dialog_menubox);
	} #endregion
	
	catagory_pane = new scrollPane(category_width, dialog_h - ui(66), function(_y, _m) { #region
		draw_clear_alpha(COLORS._main_text, 0);
		
		var hh  = 0;
		var hg  = ui(28);
		var context = PANEL_GRAPH.getCurrentContext();
		context = context == noone? "" : instanceof(context);
		
		var start = category == NODE_CATEGORY? -1 : 0;
		
		for(var i = start; i < ds_list_size(category); i++) {
			var name = "";
			
			if(i == -1) {
				draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text_accent);
				name = "All";
			} else {
				var cat = category[| i];
				name = cat.name;
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
			
				if(array_length(cat.filter)) {
					if(!array_exists(cat.filter, context)) {
						if(ADD_NODE_PAGE == i) 
							setPage(NODE_PAGE_DEFAULT);
						continue;
					}
					draw_set_color(COLORS._main_text_accent);
				}
			}
			
			BLEND_OVERRIDE;
			if(i == ADD_NODE_PAGE) {
				draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, _y + hh, category_width, hg);
			} else if(sHOVER && catagory_pane.hover && point_in_rectangle(_m[0], _m[1], 0, _y + hh, category_width - ui(32), _y + hh + hg - 1)) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y + hh, category_width, hg, c_white, 0.75);
				if(mouse_click(mb_left, sFOCUS)) {
					setPage(i);
					content_pane.scroll_y		= 0;
					content_pane.scroll_y_raw	= 0;
					content_pane.scroll_y_to	= 0;
				}
			}
			BLEND_NORMAL;
			
			name = __txt(name);
			draw_text(ui(8), _y + hh + hg / 2, name);
			hh += hg;
		}
		
		return hh;
	}); #endregion
	
	content_pane = new scrollPane(dialog_w - category_width - ui(8), dialog_h - ui(66), function(_y, _m) { #region
		draw_clear_alpha(c_white, 0);
		var hh = 0;
		var _hover = sHOVER && content_pane.hover;
		var _list  = node_list;
		
		if(ADD_NODE_PAGE == -1) {
			var context = PANEL_GRAPH.getCurrentContext();
			context = context == noone? "" : instanceof(context);
		
			_list = ds_list_create();
			for(var i = 0; i < ds_list_size(category); i++) {
				var cat = category[| i];			
				if(array_length(cat.filter) && !array_exists(cat.filter, context))
					continue;
				
				for( var j = 0; j < ds_list_size(cat.list); j++ ) {
					if(is_string(cat.list[| j])) continue;
					ds_list_add(_list, cat.list[| j]);
				}
			}
		} else if(ADD_NODE_PAGE == NODE_PAGE_DEFAULT) {
			_list = ds_list_create();
			
			var sug = [];
			
			if(node_called != noone) {
				array_append(sug, nodeReleatedQuery(
					node_called.connect_type == JUNCTION_CONNECT.input? "connectTo" : "connectFrom", 
					node_called.type
				));
			}
			
			var _cont = PANEL_GRAPH.getCurrentContext();
			if(_cont != noone)
				array_append(sug, nodeReleatedQuery("context", instanceof(_cont)));			
			if(array_length(sug)) {
				ds_list_add(_list, "Related");
				for( var i = 0, n = array_length(sug); i < n; i++ )
					ds_list_add(_list, ALL_NODES[? sug[i]]);
			}
			
			ds_list_add(_list, "Favourites");
			for( var i = 0, n = array_length(global.FAV_NODES); i < n; i++ ) {
				var _nodeIndex = global.FAV_NODES[i];
				if(!ds_map_exists(ALL_NODES, _nodeIndex)) continue;
				
				var _node = ALL_NODES[? _nodeIndex];
				if(_node.show_in_recent) 
					ds_list_add(_list, _node);
			}
			
			ds_list_add(_list, "Recents");
			for( var i = 0, n = array_length(global.RECENT_NODES); i < n; i++ ) {
				var _nodeIndex = global.RECENT_NODES[i];
				if(!ds_map_exists(ALL_NODES, _nodeIndex)) continue;
				
				var _node = ALL_NODES[? _nodeIndex];
				if(_node.show_in_recent) 
					ds_list_add(_list, _node);
			}
		}
		
		if(_list == noone) {
			setPage(NODE_PAGE_DEFAULT);
			return 0;
		}
		
		var node_count = ds_list_size(_list);
		
		//if(ADD_NODE_PAGE == NODE_PAGE_DEFAULT && array_length(global.FAV_NODES) == 0) {
		//	draw_set_text(f_h3, fa_center, fa_bottom, COLORS._main_text_sub);
		//	draw_text(content_pane.w / 2, content_pane.h / 2 - ui(8), "No favorites");
			
		//	draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text_sub);
		//	draw_text(content_pane.w / 2, content_pane.h / 2 - ui(4), "Right click on a node and select 'Add to favorite'\nto add node to favorite panel.");
		//}
		var group_labels = [];
			
		if(PREF_MAP[? "dialog_add_node_view"] == 0) { //grid
			var grid_size  = ui(64);
			var grid_width = ui(80);
			var grid_space = ui(12);
			var col        = floor(content_pane.surface_w / (grid_width + grid_space));
			var row        = ceil(node_count / col);
			var yy         = _y + grid_space;
			var curr_height = 0;
			var cProg = 0;
			hh += grid_space;
			
			grid_width   = round(content_pane.surface_w - grid_space) / col - grid_space;
			
			for(var index = 0; index < node_count; index++) {
				var _node = _list[| index];
				if(is_undefined(_node)) continue;
				
				if(is_string(_node)) {
					if(!PREF_MAP[? "dialog_add_node_grouping"])
						continue;
					hh += curr_height;
					yy += curr_height;
					
					cProg = 0;
					curr_height = 0;
					
					array_push(group_labels, {
						y: yy,
						text: __txt(_node)
					});
					
					hh += ui(24 + 12);
					yy += ui(24 + 12);
					continue;
				}
				
				if(!filtered(_node)) continue;
				
				var _nx   = grid_space + (grid_width + grid_space) * cProg;
				var _boxx = _nx + (grid_width - grid_size) / 2;
				
				BLEND_OVERRIDE;
				if(is_instanceof(_node, NodeObject))
					draw_sprite_stretched(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size);
				else if(is_instanceof(_node, NodeAction))
					draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, COLORS.add_node_blend_action, 1);
				else if(is_instanceof(_node, AddNodeItem))
					draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, COLORS.add_node_blend_generic, 1);
				else
					draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, COLORS.dialog_add_node_collection, 1);
				BLEND_NORMAL;
						
				if(_hover && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
					draw_sprite_stretched_ext(THEME.node_active, 0, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
					if(mouse_press(mb_left, sFOCUS))
						buildNode(_node);
					else if(mouse_press(mb_right, sFOCUS))
						rightClick(_node);
				}
						
				var spr_x = _boxx + grid_size / 2;
				var spr_y = yy + grid_size / 2;
				
				if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
				if(sprite_exists(_node.spr)) 
					draw_sprite_ui_uniform(_node.spr, 0, spr_x, spr_y, 0.5);
				
				if(is_instanceof(_node, NodeAction))
					draw_sprite_ui_uniform(THEME.play_action, 0, _boxx + grid_size - 16, yy + grid_size - 16, 1, COLORS.add_node_blend_action);
					
				if(_node.getTooltip() != "") {
					if(point_in_rectangle(_m[0], _m[1], _boxx, yy, _boxx + ui(16), yy + ui(16))) {
						draw_sprite_ui_uniform(THEME.info, 0, _boxx + ui(8), yy + ui(8), 0.7, COLORS._main_icon, 1.0);
						node_tooltip   = _node;
						node_tooltip_x = content_pane.x + _nx;
						node_tooltip_y = content_pane.y + yy;
					} else 
						draw_sprite_ui_uniform(THEME.info, 0, _boxx + ui(8), yy + ui(8), 0.7, COLORS._main_icon, 0.5);
				}
				
				if(_node.new_node) {
					draw_sprite_ui_uniform(THEME.node_new_badge, 0, _boxx + grid_size - ui(12), yy + ui(6),, COLORS._main_accent);
					draw_sprite_ui_uniform(THEME.node_new_badge, 1, _boxx + grid_size - ui(12), yy + ui(6));
				}
				
				if(struct_try_get(_node, "deprecated")) {
					draw_sprite_ui_uniform(THEME.node_deprecated_badge, 0, _boxx + grid_size - ui(12), yy + ui(6),, COLORS._main_value_negative);
					draw_sprite_ui_uniform(THEME.node_deprecated_badge, 1, _boxx + grid_size - ui(12), yy + ui(6));
				}
				
				if(is_instanceof(_node, NodeObject)) {
					var fav = array_exists(global.FAV_NODES, _node.node);
					if(fav) draw_sprite_ui_uniform(THEME.star, 0, _boxx + grid_size - ui(10), yy + grid_size - ui(10), 0.7, COLORS._main_accent, 1.);
				}
				
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
				draw_text_ext_add(_boxx + grid_size / 2, yy + grid_size + 4, _node.getName(), -1, grid_width);
				
				var name_height = string_height_ext(_node.getName(), -1, grid_width) + 8;
				curr_height = max(curr_height, grid_size + grid_space + name_height);
				
				if(++cProg >= col) {
					hh += curr_height;
					yy += curr_height;
					
					cProg = 0;
					curr_height = 0;
				}
			}
			
			var len = array_length(group_labels);
			if(len) {
				gpu_set_blendmode(bm_subtract);
				draw_set_color(c_white);
				draw_rectangle(0, 0, content_pane.surface_w, ui(16 + 24 / 2), false);
				gpu_set_blendmode(bm_normal);
			}
				
			for( var i = 0; i < len; i++ ) {
				var lb = group_labels[i];
				var _yy = max(lb.y, i == len - 1? ui(8) : min(ui(8), group_labels[i + 1].y - ui(32)));
				
				BLEND_OVERRIDE;
				draw_sprite_stretched(THEME.group_label, 0, ui(16), _yy, content_pane.surface_w - ui(32), ui(24));
				BLEND_NORMAL;
					
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text(ui(16 + 16), _yy + ui(12), lb.text);
			}
			
			hh += curr_height;
			yy += curr_height;
		} else if(PREF_MAP[? "dialog_add_node_view"] == 1) { //list
			var list_width  = content_pane.surface_w;
			var list_height = ui(28);
			var yy      = _y + list_height / 2;
			var bg_ind	= 0;
			hh += list_height;
			
			for(var i = 0; i < node_count; i++) {
				var _node = _list[| i];
				if(is_undefined(_node)) continue;
				
				if(is_string(_node)) {
					if(!PREF_MAP[? "dialog_add_node_grouping"])
						continue;
						
					hh += ui(8);
					yy += ui(8);
					
					array_push(group_labels, {
						y: yy,
						text: __txt(_node)
					});
					
					hh += ui(32);
					yy += ui(32);
					continue;
				}
				
				if(!filtered(_node)) continue;
				
				if(++bg_ind % 2) {
					BLEND_OVERRIDE;
					draw_sprite_stretched_ext(THEME.node_bg, 0, ui(4), yy, list_width - ui(8), list_height, c_white, 0.2);
					BLEND_NORMAL;
				}
				
				if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, list_width, yy + list_height - 1)) {
					if(_node.getTooltip() != "") {
						node_tooltip   = _node;
						node_tooltip_x = content_pane.x + 0;
						node_tooltip_y = content_pane.y + yy
					}
					
					draw_sprite_stretched_ext(THEME.node_active, 0, ui(4), yy, list_width - ui(8), list_height, COLORS._main_accent, 1);
					if(mouse_press(mb_left, sFOCUS))
						buildNode(_node);
					else if(mouse_press(mb_right, sFOCUS))
						rightClick(_node);
				}
				
				if(is_instanceof(_node, NodeObject)) {
					var fav = array_exists(global.FAV_NODES, _node.node);
					if(fav) draw_sprite_ui_uniform(THEME.star, 0, ui(20), yy + list_height / 2, 0.7, COLORS._main_accent, 1.);
				}
				
				var spr_x = list_height / 2 + ui(32);
				var spr_y = yy + list_height / 2;
				
				if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
				if(sprite_exists(_node.spr)) {
					var ss = (list_height - ui(8)) / max(sprite_get_width(_node.spr), sprite_get_height(_node.spr));
					draw_sprite_ext(_node.spr, 0, spr_x, spr_y, ss, ss, 0, c_white, 1);
				}
				
				if(is_instanceof(_node, NodeAction))
					draw_sprite_ui_uniform(THEME.play_action, 0, spr_x + list_height / 2 - 8, spr_y + list_height / 2 - 8, 0.5, COLORS.add_node_blend_action);
					
				var tx = list_height + ui(40);
				
				if(_node.new_node) {
					draw_sprite_ui_uniform(THEME.node_new_badge, 0, tx + ui(16), yy + list_height / 2 + ui(1),, COLORS._main_accent);
					draw_sprite_ui_uniform(THEME.node_new_badge, 1, tx + ui(16), yy + list_height / 2 + ui(1));
					tx += ui(40);
				}
				
				if(struct_try_get(_node, "deprecated")) {
					draw_sprite_ui_uniform(THEME.node_deprecated_badge, 0, tx + ui(16), yy + list_height / 2 + ui(1),, COLORS._main_value_negative);
					draw_sprite_ui_uniform(THEME.node_deprecated_badge, 1, tx + ui(16), yy + list_height / 2 + ui(1));
					tx += ui(40);
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(tx, yy + list_height / 2, _node.getName());
				
				yy += list_height;
				hh += list_height;
			}
			
			gpu_set_blendmode(bm_subtract);
			draw_set_color(c_white);
			draw_rectangle(0, 0, content_pane.surface_w, ui(16 + 24 / 2), false);
			gpu_set_blendmode(bm_normal);
			
			var len = array_length(group_labels);
			for( var i = 0; i < len; i++ ) {
				var lb = group_labels[i];
				var _yy = max(lb.y, i == len - 1? ui(8) : min(ui(8), group_labels[i + 1].y - ui(32)));
				
				BLEND_OVERRIDE;
				draw_sprite_stretched(THEME.group_label, 0, ui(16), _yy, content_pane.surface_w - ui(32), ui(24));
				BLEND_NORMAL;
					
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text(ui(16 + 16), _yy + ui(12), lb.text);
			}
		}
		
		if(ADD_NODE_PAGE == -1) 
			ds_list_destroy(_list);
		
		return hh;
	}); #endregion
	
	content_pane.always_scroll = true;
#endregion

#region resize
	dialog_resizable = true;
	dialog_w_min = ui(320);
	dialog_h_min = ui(320);
	dialog_w_max = ui(960);
	dialog_h_max = ui(800);
	
	onResize = function() {
		catagory_pane.resize(category_width, dialog_h - ui(66));
		content_pane.resize(dialog_w - category_width - ui(8), dialog_h - ui(66));
		search_pane.resize(dialog_w - ui(36), dialog_h - ui(66));
		
		PREF_MAP[? "dialog_add_node_w"] = dialog_w;
		PREF_MAP[? "dialog_add_node_h"] = dialog_h;
	}
#endregion

#region search
	search_string		= "";
	search_list			= ds_list_create();
	keyboard_lastchar	= "";
	KEYBOARD_STRING		= "";
	keyboard_lastkey	= -1;
	
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) { 
		search_string = string(str); 
		searchNodes();
	});
	tb_search.align			= fa_left;
	tb_search.auto_update	= true;
	WIDGET_CURRENT			= tb_search;
	
	function searchNodes() {
		ds_list_clear(search_list);
		var pr_list = ds_priority_create();
		
		var cnt			 = PANEL_GRAPH.getCurrentContext();
		var context		 = cnt == noone? "" : instanceof(cnt);
		var search_lower = string_lower(search_string);
		var search_map	 = ds_map_create();
		
		for(var i = 0; i < ds_list_size(category); i++) {
			var cat = category[| i];
			
			if(!struct_has(cat, "list"))
				continue;
			if(array_length(cat.filter) && !array_exists(cat.filter, context))
				continue;
			
			var _content = cat.list;
			for(var j = 0; j < ds_list_size(_content); j++) {
				var _node = _content[| j];

				if(is_string(_node)) continue;
				if(ds_map_exists(search_map, _node)) continue;
				if(struct_try_get(_node, "deprecated")) continue;
				
				var match = string_partial_match(string_lower(_node.getName()), search_lower);
				var param = "";
				for( var k = 0; k < array_length(_node.tags); k++ ) {
					var mat = string_partial_match(_node.tags[k], search_lower) - 1000;
					if(mat > match) {
						match = mat;
						param = _node.tags[k];
					}
				}
				
				if(match == -9999) continue;
				
				ds_priority_add(pr_list, [_node, param], match);
				search_map[? _node] = 1;
			}
		}
		
		ds_map_destroy(search_map);
		
		searchCollection(pr_list, search_string, false);
		
		repeat(ds_priority_size(pr_list))
			ds_list_add(search_list, ds_priority_delete_max(pr_list));
		
		ds_priority_destroy(pr_list);
	}
	
	search_pane = new scrollPane(dialog_w - ui(36), dialog_h - ui(66), function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var equation = string_char_at(search_string, 0) == "=";
		var amo		 = ds_list_size(search_list);
		var hh		 = 0;
		var _hover	 = sHOVER && search_pane.hover;
		
		var grid_size  = ui(64);
		var grid_width = ui(80);
		var grid_space = ui(16);
			
		if(equation) {
			var eq = string_replace(search_string, "=", "");
			
			draw_set_text(f_h5, fa_center, fa_bottom, COLORS._main_text_sub);
			draw_text_line(search_pane.w / 2, search_pane.h / 2 - ui(8), 
				__txtx("add_node_create_equation", "Create equation") + ": " + eq, -1, search_pane.w - ui(32));
			
			draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_add(round(search_pane.w / 2), round(search_pane.h / 2 - ui(4)), 
				__txtx("add_node_equation_enter", "Press Enter to create equation node."));
			
			if(keyboard_check_pressed(vk_enter))
				buildNode(ALL_NODES[? "Node_Equation"], { query: eq } );
			return hh;
		}
		
		if(PREF_MAP[? "dialog_add_node_view"] == 0) { //grid view
			var col = floor(search_pane.surface_w / (grid_width + grid_space));
			var yy = _y + grid_space;
			var index = 0;
			var name_height = 0;
			
			grid_width = round(search_pane.surface_w - grid_space) / col - grid_space;
			hh += (grid_space + grid_size) * 2;
			
			for(var i = 0; i < amo; i++) {
				var s_res = search_list[| i];
				var _node = noone, _param = {};
				if(is_array(s_res)) {
					_node = s_res[0];
					_param.query = s_res[1];
				} else
					_node = s_res;
			
				var _nx   = grid_space + (grid_width + grid_space) * index;
				var _boxx = _nx + (grid_width - grid_size) / 2;
				
				BLEND_OVERRIDE;
				if(is_instanceof(_node, NodeObject))
					draw_sprite_stretched(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size);
				else if(is_instanceof(_node, NodeAction))
					draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, COLORS.add_node_blend_action, 1);
				else if(is_instanceof(_node, AddNodeItem))
					draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, COLORS.add_node_blend_generic, 1);
				else
					draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, COLORS.dialog_add_node_collection, 1);
				BLEND_NORMAL;
					
				if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
				if(sprite_exists(_node.spr)) {
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
				
				if(is_instanceof(_node, NodeAction))
					draw_sprite_ui_uniform(THEME.play_action, 0, _boxx + grid_size - 16, yy + grid_size - 16, 1, COLORS.add_node_blend_action);
					
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
				var txt = _node.getName();
				name_height = max(name_height, string_height_ext(txt, -1, grid_width) + ui(8));
				draw_text_ext_add(_boxx + grid_size / 2, yy + grid_size + 4, txt, -1, grid_width);
				
				if(_hover && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
					node_selecting = i;
					if(mouse_press(mb_left, sFOCUS))
						buildNode(_node, _param);
					else if(struct_has(_node, "node") && mouse_press(mb_right, sFOCUS))
						rightClick(_node);
				}
				
				if(node_selecting == i) {
					draw_sprite_stretched_ext(THEME.node_active, 0, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
					if(keyboard_check_pressed(vk_enter))
						buildNode(_node, _param);
				}
				
				if(struct_has(_node, "tooltip") && _node.getTooltip() != "") {
					if(point_in_rectangle(_m[0], _m[1], _boxx, yy, _boxx + ui(16), yy + ui(16))) {
						draw_sprite_ui_uniform(THEME.info, 0, _boxx + ui(8), yy + ui(8), 0.7, COLORS._main_icon, 1.0);
						node_tooltip   = _node;
						node_tooltip_x = search_pane.x + _nx;
						node_tooltip_y = search_pane.y + yy
					} else 
						draw_sprite_ui_uniform(THEME.info, 0, _boxx + ui(8), yy + ui(8), 0.7, COLORS._main_icon, 0.5);
				}
				if(is_instanceof(_node, NodeObject)) {
					var fav = struct_has(_node, "node") && array_exists(global.FAV_NODES, _node.node);
					if(fav) draw_sprite_ui_uniform(THEME.star, 0, _boxx + grid_size - ui(10), yy + grid_size - ui(10), 0.7, COLORS._main_accent, 1.);
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
		} else if(PREF_MAP[? "dialog_add_node_view"] == 1) { //list view
			var list_width  = search_pane.surface_w;
			var list_height = ui(28);
			var yy = _y + list_height / 2;
			hh += list_height;
		
			for(var i = 0; i < amo; i++) {
				var s_res = search_list[| i];
				var _node = noone, _param = {};
				if(is_array(s_res)) {
					_node = s_res[0];
					_param.query = s_res[1];
				} else
					_node = s_res;
				
				if(i % 2) {
					BLEND_OVERRIDE;
					draw_sprite_stretched_ext(THEME.node_bg, 0, ui(4), yy, list_width - ui(8), list_height, c_white, 0.2);
					BLEND_NORMAL;
				}
				
				if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
				if(sprite_exists(_node.spr)) {
					var _si = current_time * PREF_MAP[? "collection_preview_speed"] / 3000;
					var _sw = sprite_get_width(_node.spr);
					var _sh = sprite_get_height(_node.spr);
					var _ss = (list_height - ui(8)) / max(_sw, _sh);
				
					var _sox = sprite_get_xoffset(_node.spr);
					var _soy = sprite_get_yoffset(_node.spr);
					
					var _sx = list_height / 2 + ui(32);
					var _sy = yy + list_height / 2;
					_sx += _sw * _ss / 2 - _sox * _ss;
					_sy += _sh * _ss / 2 - _soy * _ss;
				
					draw_sprite_ext(_node.spr, _si, _sx, _sy, _ss, _ss, 0, c_white, 1);
					
					if(is_instanceof(_node, NodeAction))
						draw_sprite_ui_uniform(THEME.play_action, 0, _sx + list_height / 2 - 8, _sy + list_height / 2 - 8, 0.5, COLORS.add_node_blend_action);
				}
					
				if(is_instanceof(_node, NodeObject)) {
					var fav = struct_has(_node, "node") && array_exists(global.FAV_NODES, _node.node);
					if(fav) draw_sprite_ui_uniform(THEME.star, 0, ui(20), yy + list_height / 2, 0.7, COLORS._main_accent, 1.);
				}
				
				draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
				draw_text_add(list_height + ui(40), yy + list_height / 2, _node.getName());
				
				if(_hover && point_in_rectangle(_m[0], _m[1], 0, yy, list_width, yy + list_height - 1)) {
					if(struct_has(_node, "tooltip") && _node.getTooltip() != "") {
						node_tooltip   = _node;
						node_tooltip_x = search_pane.x + 0;
						node_tooltip_y = search_pane.y + yy
					}
					
					node_selecting = i;
					if(mouse_press(mb_left, sFOCUS))
						buildNode(_node, _param);
					else if(struct_has(_node, "node") && mouse_press(mb_right, sFOCUS))
						rightClick(_node);
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