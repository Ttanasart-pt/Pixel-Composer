/// @description init
event_inherited();

#region data
	draggable = false;
	dialog_w  = PREFERENCES.dialog_add_node_w;
	dialog_h  = PREFERENCES.dialog_add_node_h;
	destroy_on_click_out = true;
	
	title = "Add node";
	node_target_x	  = 0;
	node_target_y	  = 0;
	node_target_x_raw = 0;
	node_target_y_raw = 0;
	
	junction_called   = noone;
	
	node_list      = [];
	node_selecting =  0;
	node_focusing  = -1;
	
	node_show_connectable = false;
	node_tooltip   = noone;
	node_tooltip_x = 0;
	node_tooltip_y = 0;
	node_icon      = noone;
	node_icon_x    = 0;
	node_icon_y    = 0;
	
	anchor = ANCHOR.left | ANCHOR.top;
	node_menu_selecting = noone;
	
	display_grid_size    = ui(56);
	display_grid_size_to = display_grid_size;
	display_list_size    = ui(28);
	display_list_size_to = display_list_size;
	
	left_free  = true;
	right_free = !mouse_click(mb_right);
	is_global  = PANEL_GRAPH.getCurrentContext() == noone;
	
	tooltip_surface   = -1;
	content_hoverable = true;
	
	canvas    = false;
	collapsed = {};
	
	subgroups      = [];
	subgroups_size = [];
	subgroup_index = 0;
	
	view_tooltip = new tooltipSelector("View", [
		__txtx("view_grid", "Grid view"),
		__txtx("view_list", "List view"),
	]);
	
	group_tooltip = new tooltipSelector("Group", [
		__txt("Disabled"),
		__txt("Inline"),
		__txt("Stacked"),
	]);
	
	#region ---- category ----
	
		switch(instanceof(context)) {
			case "Node_Pixel_Builder" : category = NODE_PB_CATEGORY;  break;
			case "Node_DynaSurf" :      category = NODE_PCX_CATEGORY; break;
			default :                   category = NODE_CATEGORY;
		}
		
		draw_set_font(f_p0);
		var maxLen = 0;
		for(var i = 0; i < array_length(category); i++) {
			var cat = category[i];
			
			if(cat[$ "filter"] != undefined && !array_exists(cat.filter, instanceof(context)))
				continue;
			
			var name = __txt(cat.name);
			maxLen   = max(maxLen, string_width(name));
		}
		
		category_width = maxLen + ui(48);
	#endregion
	
	function isTop() { return true; }
	
	function trigger_favourite() {
		if(node_menu_selecting == noone) return;
		
		struct_toggle(global.FAV_NODES, node_menu_selecting.nodeName);
		PREF_SAVE();
	}
	
	registerFunction("Add Node", "Trigger Favourite",	"",	   MOD_KEY.none,	trigger_favourite);
	
	function rightClick(node) {
		if(!is_instanceof(node, NodeObject)) return;
		
		node_menu_selecting = node;
		var fav  = struct_exists(global.FAV_NODES, node.nodeName);
		var menu = [
			menuItem(fav? __txtx("add_node_remove_favourite", "Remove from favourite") : __txtx("add_node_add_favourite", "Add to favourite"), trigger_favourite, THEME.star)
		];
		
		menuCall("add_node_window_menu", menu, 0, 0, fa_left);
	}
	
	function checkValid(node, skipConnect = false) {
		if(!is(node, NodeObject))             return true;
		if(node.patreon && !IS_PATREON)       return false;
		if(!node.show_in_global && is_global) return false;
		if(skipConnect || junction_called == noone || !node_show_connectable) return true;
		
		var _b = junction_called.connect == CONNECT_TYPE.input? node.output_type_mask : node.input_type_mask;
		return bool(_b & value_bit(junction_called.type));
	}
	
	function setPage(pageIndex, subPageIndex = 0) {
		ADD_NODE_PAGE = min(pageIndex, array_length(category) - 1);
		subgroups      = [];
		subgroup_index = 0;
		node_list      = [];
		
		if(ADD_NODE_PAGE == -2) {
			for(var i = 0; i < array_length(category); i++) {
				var cat = category[i];			
				if(struct_has(cat, "filter") && !array_exists(cat.filter, instanceof(context)))
					continue;
				
				for( var j = 0; j < array_length(cat.list); j++ )
					array_push(node_list, cat.list[j]);
			}
	
		} else if(ADD_NODE_PAGE == -1) {
			for( var i = 0, n = array_length(NEW_NODES); i < n; i++ )
				array_push(node_list, NEW_NODES[i]);
	
		} else if(ADD_NODE_PAGE == NODE_PAGE_DEFAULT && category == NODE_CATEGORY) { // page 0 global context
			var sug = [];
			
			if(junction_called != noone) {
				array_append(sug, nodeReleatedQuery(
					junction_called.connect_type == CONNECT_TYPE.input? "connectTo" : "connectFrom", 
					junction_called.type
				));
			}
			
			array_append(sug, nodeReleatedQuery("context", instanceof(context)));
			
			if(!array_empty(sug)) {
				array_push(node_list, "Related");
				for( var i = 0, n = array_length(sug); i < n; i++ ) {
					var k = array_safe_get_fast(sug, i);
					if(k == 0) continue;
					if(struct_has(ALL_NODES, k))
						array_push(node_list, ALL_NODES[$ k]);
				}
			}
			
			array_push(node_list, "Favourites");
			var _favs = struct_get_names(global.FAV_NODES);
			for( var i = 0, n = array_length(_favs); i < n; i++ ) {
				var _nodeIndex = _favs[i];
				if(!struct_has(ALL_NODES, _nodeIndex)) continue;
				
				var _node = ALL_NODES[$ _nodeIndex];
				if(_node.show_in_recent) 
					array_push(node_list, _node);
			}
			
			array_push(node_list, "Recents");
			if(is_array(global.RECENT_NODES))
			for( var i = 0, n = array_length(global.RECENT_NODES); i < n; i++ ) {
				var _nodeIndex = global.RECENT_NODES[i];
				if(!struct_has(ALL_NODES, _nodeIndex)) continue;
				
				var _node = ALL_NODES[$ _nodeIndex];
				if(_node.show_in_recent) 
					array_push(node_list, _node);
			}
		} else {
			var _l = category[ADD_NODE_PAGE].list;
			for( var i = 0, n = array_length(_l); i < n; i++ ) 
				array_push(node_list, _l[i]);
		}
		
		for( var i = 0, n = array_length(node_list); i < n; i++ ) {
			var _node = node_list[i];
			if(!is_string(_node)) continue;
			if(string_starts_with(_node, "/")) continue;
			
			array_push(subgroups, _node);
		}
		
		setSubgroup(subPageIndex);
	}
	
	function setSubgroup(_subg) {
		subgroup_index   = _subg;
		ADD_NODE_SUBPAGE = _subg;
	}
#endregion

#region build
	function buildNode(_node, _param = {}) {
		instance_destroy();
		instance_destroy(o_dialog_menubox);
		
		if(!_node) return;
		
		if(canvas) {
			UNDO_HOLDING = true;
			context.nodeTool = new canvas_tool_node(context, _node).init();
			UNDO_HOLDING = false;
			return;
		}
		
		var _new_node = noone;
		var _inputs   = [];
		var _outputs  = [];
		
		if(is_instanceof(_node, NodeObject)) {
			_new_node = _node.build(node_target_x, node_target_y,, _param);
			if(!_new_node) return;
			
			if(category == NODE_CATEGORY && _node.show_in_recent) {
				array_remove(global.RECENT_NODES, _node.nodeName);
				array_insert(global.RECENT_NODES, 0, _node.nodeName);
				if(array_length(global.RECENT_NODES) > PREFERENCES.node_recents_amount)
					array_pop(global.RECENT_NODES);
			}
			
			if(is_instanceof(context, Node_Collection_Inline))
				context.addNode(_new_node);
			
			for( var i = 0, n = array_length(_new_node.inputs); i < n; i++ ) 
				array_push(_inputs, _new_node.inputs[i]);
			
			if(_new_node.dummy_input)
				array_push(_inputs, _new_node.dummy_input);
			
			for( var i = 0, n = array_length(_new_node.outputs); i < n; i++ ) 
				array_push(_outputs, _new_node.outputs[i]);
			
			if(PANEL_INSPECTOR) PANEL_INSPECTOR.setInspecting(_new_node);
			
			if(PANEL_GRAPH) {
				if(PREFERENCES.node_add_select) 
					PANEL_GRAPH.selectDragNode(_new_node, junction_called == noone);
				var _ins = instanceof(_new_node);
				if(struct_has(HOTKEYS, _ins)) FOCUS_STR = _ins;
			}
			
		} else if(is_instanceof(_node, NodeAction)) {  // NOT IMPLEMENTED
			var _dat = _node.build(node_target_x, node_target_y,, _param);
			var _node_in  = _dat.inputNode;
			var _node_out = _dat.outputNode;
			
			if(_node_in != noone)
			for( var i = 0, n = array_length(_node_in.inputs); i < n; i++ ) 
				array_push(_inputs, _node_in.inputs[i]);
			
			if(_node_out != noone)
			for( var i = 0, n = array_length(_node_out.outputs); i < n; i++ ) 
				array_push(_outputs, _node_out.outputs[i]);
			
		} else {
			var _new_list = APPEND(_node.path);
			if(_new_list == noone) return;
			
			var tx = 99999;
			var ty = 99999;
			for( var i = 0; i < array_length(_new_list); i++ ) {
				tx = min(tx, _new_list[i].x);
				ty = min(tx, _new_list[i].y);
				
				if(is_instanceof(context, Node_Collection_Inline) && !is_instanceof(_new_list[i], Node_Collection_Inline))
					context.addNode(_new_list[i]);
			}
			
			var shx = tx - node_target_x;
			var shy = ty - node_target_y;
			
			for( var i = 0; i < array_length(_new_list); i++ ) {
				_new_list[i].x -= shx;
				_new_list[i].y -= shy;
			}
			
			for( var i = 0; i < array_length(_new_list); i++ ) {
				var _in = _new_list[i].inputs;
				for( var j = 0; j < array_length(_in); j++ ) {
					if(_in[j].value_from == noone)
						array_push(_inputs, _in[j]);
				}
				
				var _ot = _new_list[i].outputs;
				for( var j = 0; j < array_length(_ot); j++ ) {
					if(array_empty(_ot[j].value_to))
						array_push(_outputs, _ot[j]);
				}
			}
		}
		
		if(junction_called == noone) return;
		
		//connect to called junction
		var _call_input = junction_called.connect_type == CONNECT_TYPE.input;
		var _from       = junction_called.value_from;
		var _junc_list  = _call_input? _outputs : _inputs;
		
		for(var i = 0; i < array_length(_junc_list); i++) {
			var _target = _junc_list[i]; 
			if(!_target.auto_connect) continue;
			
			if(_call_input && junction_called.isConnectableStrict(_junc_list[i]) == 1) {
				junction_called.setFrom(_junc_list[i]);
				_new_node.x -= _new_node.w;
				break;
			} 
			
			if(!_call_input && _junc_list[i].isConnectableStrict(junction_called) == 1) {
				_junc_list[i].setFrom(junction_called);
				break;
			}
		}
		
		if(!_call_input || _from == noone) return;
		
		for(var i = 0; i < array_length(_inputs); i++) {
			var _target = _inputs[i]; 
			
			if(_target.isConnectableStrict(_from) == 1) {
				_target.setFrom(_from);
				break;
			}
		}
		
	}
#endregion

#region content
	catagory_pane = new scrollPane(category_width, dialog_h - ui(66), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var ww = catagory_pane.surface_w;
		var hh = 0;
		var hg = line_get_height(f_p1, 6);
		
		var start = category == NODE_CATEGORY? -2 : 0;
		
		for(var i = start; i < array_length(category); i++) {
			var name  = "";
			
			     if(i == -2) name = "All";
			else if(i == -1) name = "New";
			else {
				var cat = category[i];
				name    = cat.name;
				
				if(cat[$ "filter"] != undefined) {
					if(!array_exists(cat.filter, instanceof(context))) {
						if(ADD_NODE_PAGE == i) 
							setPage(NODE_PAGE_DEFAULT);
						continue;
					}
					draw_set_color(COLORS._main_text_accent);
				}
				
				if(cat[$ "color"] != undefined) {
					BLEND_OVERRIDE
					draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y + hh, ww, hg, merge_color(c_white, cat.color, 0.5), 1);
					BLEND_NORMAL
				}
			}
			
			var _hov = false;
			
			if(sHOVER && catagory_pane.hover && point_in_rectangle(_m[0], _m[1], 0, _y + hh, ww, _y + hh + hg - 1)) {
				catagory_pane.hover_content = true;
				
				BLEND_OVERRIDE
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _y + hh, ww, hg, CDEF.main_white, 1);
				BLEND_NORMAL
				
				_hov = true;
				
				if(i != ADD_NODE_PAGE && mouse_click(mb_left, sFOCUS)) {
					setPage(i);
					content_pane.scroll_y		= 0;
					content_pane.scroll_y_raw	= 0;
					content_pane.scroll_y_to	= 0;
				}
			}
			
			var cc = COLORS._main_text_inner;
			
			switch(name) {
				case "All" : 
				case "New" : 
				case "Favourites" : 
				case "Action" : 
				case "Custom" : 
				case "Extra" : 
					cc = merge_color(COLORS._main_text_inner, COLORS._main_text_sub, 0.75);
					break;
			}
			
			if(i == ADD_NODE_PAGE) draw_set_text(f_p1b, fa_left, fa_center, COLORS._main_text_accent);
			else				   draw_set_text(f_p1,  fa_left, fa_center, cc);
			
			var _is_extra = name == "Extra";
			name = __txt(name);
			
			var _tx = ui(8);
			var _ty = _y + hh + hg / 2;
			draw_text_add(_tx, _ty, name);
			
			if(_is_extra) {
				var _cx = _tx + string_width(name) + ui(4);
				var _cy = _ty - string_height(name) / 2 + ui(6);
				
				gpu_set_colorwriteenable(1, 1, 1, 0);
				draw_sprite_ext(THEME.patreon_supporter, 0, _cx, _cy, 1, 1, 0, _hov? COLORS._main_icon_dark : COLORS.panel_bg_clear, 1);
				gpu_set_colorwriteenable(1, 1, 1, 1);
				
				draw_sprite_ext(THEME.patreon_supporter, 1, _cx, _cy, 1, 1, 0, i == ADD_NODE_PAGE? COLORS._main_text_accent : cc, 1);
			}
			
			hh += hg;
		}
		
		return hh;
	});
	catagory_pane.scroll_color_bg        = undefined;
	catagory_pane.scroll_color_bar_alpha = .5;
	
	subcatagory_pane = new scrollPane(ui(96), dialog_h - ui(66), function(_y, _m) {
		draw_clear_alpha(COLORS._main_text, 0);
		var yy = _y + ui(4);
		var hh = 0 + ui(4);
		var hg = line_get_height(f_p2, 6);
		
		var  ww     = subcatagory_pane.surface_w;
		var _hover  = subcatagory_pane.hover;
		var _active = subcatagory_pane.active;
		
		for( var i = 0, n = array_length(subgroups); i < n; i++ ) {
			var _hv = _hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg - ui(1)); 
			var _sz = array_safe_get(subgroups_size, i, 1);
			if(_sz == 0) continue;
			
			if(_hv) {
				draw_sprite_stretched_add(THEME.ui_panel_bg, 0, ui(4), yy, ww - ui(4), hg, CDEF.main_white, .2);
				if(mouse_click(mb_left, _active)) setSubgroup(i);
			}
			
			var _f  = i == subgroup_index? f_p2b : f_p2;
			var _bc = CDEF.main_ltgrey;
			var _c  = i == subgroup_index? COLORS._main_text_accent : _bc;
			
			draw_set_text(_f, fa_left, fa_top, _c);
			draw_text_add(ui(12), yy + ui(2), subgroups[i]);
			
			yy += hg;
			hh += hg;
		}
		
		return hh;
	});
	
	content_pane = new scrollPane(dialog_w - category_width - ui(40), dialog_h - ui(66), function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var _hover = sHOVER && content_pane.hover;
		var _focus = sFOCUS && content_pane.active;
		var _list  = [];
		var ww     = content_pane.surface_w;
		var hh     = 0;
		
		if(node_list == noone) {
			setPage(NODE_PAGE_DEFAULT); 
			return 0;
		}
		
		var _subg_cur = -1;
		subgroups_size = array_create(array_length(subgroups), 0);
		
		for( var i = 0, n = array_length(node_list); i < n; i++ ) {
			var _n = node_list[i];
			if(!checkValid(_n)) continue;
				
			if(PREFERENCES.dialog_add_node_grouping != 2 || array_empty(subgroups)) {
				array_push(_list, _n); 
				continue;
			}
			
			if(is_string(_n) && !string_starts_with(_n, "/"))
				_subg_cur++
			else if(_subg_cur == subgroup_index)
				array_push(_list, _n);
			
			if(is(_n, NodeObject) && _subg_cur >= 0) subgroups_size[_subg_cur]++;
		}
		
		var node_count    = array_length(_list);
		var group_labels  = [];
		var _hoverContent = _hover;
		var _lbh = PREFERENCES.dialog_add_node_grouping == 1? ui(24) : ui(16);
		
		if(!content_hoverable) _hoverContent = false;
		content_hoverable = true;
			
		if(PREFERENCES.dialog_add_node_view == 0) { // grid
			var grid_size  = display_grid_size;
			var grid_width = grid_size * 1.25;
			var grid_space = ui(12);
			var col        = floor(ww / (grid_width + grid_space));
			var row        = ceil(node_count / col);
			var yy         = _y + grid_space;
			var curr_height = 0;
			var cProg = 0;
			hh += grid_space;
			
			grid_width   = round(ww - grid_space) / col - grid_space;
			
			for(var index = 0; index < node_count; index++) {
				var _node = _list[index];
				if(is_undefined(_node)) continue;
				if(is_instanceof(_node, NodeObject)) {
					if(_node.patreon && !IS_PATREON) continue;
					if(is_global && !_node.show_in_global)    continue;
				}
				
				if(is_string(_node)) {
					if(PREFERENCES.dialog_add_node_grouping == 0) continue;
					if(PREFERENCES.dialog_add_node_grouping == 1 && string_starts_with(_node, "/")) continue;
					
					hh += curr_height;
					yy += curr_height;
					
					cProg = 0;
					curr_height = 0;
					var _key = $"{ADD_NODE_PAGE}:{index}";
					
					array_push(group_labels, { y: yy, text: __txt(string_trim_start(__txt(_node), ["/"])), key: _key });
					
					if(struct_try_get(collapsed, _key, 0)) {
						hh += _lbh + ui(4);
						yy += _lbh + ui(4);
						
						while(index + 1 < node_count) {
							var _s = _list[index + 1];
							if(is_string(_s) && (!string_starts_with(_s, "/") || PREFERENCES.dialog_add_node_grouping == 2)) break;
							
							index++;
						}
					} else {
						hh += _lbh + ui(12);
						yy += _lbh + ui(12);
					}
					continue;
				}
				
				var _nx   = grid_space + (grid_width + grid_space) * cProg;
				var _boxx = _nx + (grid_width - grid_size) / 2;
				var cc    = c_white;
				
					 if(is_instanceof(_node, NodeObject))	cc = c_white;
				else if(is_instanceof(_node, NodeAction))	cc = COLORS.add_node_blend_action;
				else if(is_instanceof(_node, AddNodeItem))	cc = COLORS.add_node_blend_generic;
				else										cc = COLORS.dialog_add_node_collection;
				
				if(!struct_try_get(_node, "hide_bg", false)) {
					BLEND_OVERRIDE
					draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, cc, 1);
					BLEND_NORMAL
				}
				
				if(_hoverContent && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_width, yy + grid_size)) {
					content_pane.hover_content = true;
					
					draw_sprite_stretched_ext(THEME.node_bg, 1, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
					
					if(sFOCUS) {
						if(mouse_release(mb_left,  left_free))  buildNode(_node);
						if(mouse_release(mb_right, right_free)) rightClick(_node);
					}
				}
				
				if(is_instanceof(_node, NodeObject)) {
					_node.drawGrid(_boxx, yy, _m[0], _m[1], grid_size);
				} else {
					var spr_x = _boxx + grid_size / 2;
					var spr_y = yy + grid_size / 2;
					
					if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
					if(sprite_exists(_node.spr)) 
						draw_sprite_ui_uniform(_node.spr, 0, spr_x, spr_y, 0.5);
					
					if(is_instanceof(_node, NodeAction) && !struct_try_get(_node, "hide_bg", false))
						draw_sprite_ui_uniform(THEME.play_action, 0, _boxx + grid_size - 16, yy + grid_size - 16, 1, COLORS.add_node_blend_action);
				}
				
				if(_node.getTooltip() != "" || _node.getTooltipSpr() != noone) {
					gpu_set_tex_filter(true);
					if(_hoverContent && point_in_rectangle(_m[0], _m[1], _boxx, yy, _boxx + ui(16), yy + ui(16))) {
						content_pane.hover_content = true;
						
						draw_sprite_ui_uniform(THEME.info, 0, _boxx + ui(8), yy + ui(8), 0.7, COLORS._main_icon, 1.0);
						node_tooltip   = _node;
						node_tooltip_x = content_pane.x + _nx;
						node_tooltip_y = content_pane.y + yy;
					} else 
						draw_sprite_ui_uniform(THEME.info, 0, _boxx + ui(8), yy + ui(8), 0.7, COLORS._main_icon, 0.5);
					gpu_set_tex_filter(false);
				}
				
				var _name = _node.getName();
				
				draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text);
				draw_text_ext_add(_boxx + grid_size / 2, yy + grid_size + 4, _name, -1, grid_width);
				
				var name_height = string_height_ext(_name, -1, grid_width) + 8;
				curr_height = max(curr_height, grid_size + grid_space + name_height);
				
				if(++cProg >= col) {
					hh += curr_height;
					yy += curr_height;
					
					cProg = 0;
					curr_height = 0;
				}
			}
			
			if(PREFERENCES.dialog_add_node_grouping) {
				var len = array_length(group_labels);
				if(len && group_labels[0].y < 0) {
					gpu_set_blendmode(bm_subtract);
					draw_set_color(c_white);
					draw_rectangle(0, 0, ww, _lbh + ui(12), false);
					gpu_set_blendmode(bm_normal);
					
					content_hoverable &= !point_in_rectangle(_m[0], _m[1], 0, 0, ww, _lbh + ui(12));
				}
				
				var _cAll = 0;
				
				for( var i = 0; i < len; i++ ) {
					var lb    = group_labels[i];
					var _name = lb.text;
					var _key  = lb.key;
					var _coll = struct_try_get(collapsed, _key, 0);
					
					var _yy = max(lb.y, i == len - 1? ui(8) : min(ui(8), group_labels[i + 1].y - ui(32)));
					var _hv = _hover && point_in_rectangle(_m[0], _m[1], 0, _yy, ww, _yy + _lbh);
					var _tc = CDEF.main_ltgrey;
					
					BLEND_OVERRIDE
					if(PREFERENCES.dialog_add_node_grouping == 1)
                    	draw_sprite_stretched_ext(THEME.box_r5_clr, 0, ui(16), _yy, ww - ui(32), _lbh, _hv? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg, 1);
                    else {
                    	draw_set_color(COLORS.panel_bg_clear_inner);
                    	draw_rectangle(ui(16), _yy, ww - ui(16), _yy + _lbh, false);
                    }
                    
					if(_hv && _focus) {
						if(PREFERENCES.dialog_add_node_grouping == 2) _tc = CDEF.main_white;
						
                    	if(DOUBLE_CLICK) {
                    		_cAll = _coll? -1 : 1;
                    		left_free = false;
                    		
                    	} else if(mouse_press(mb_left)) {
                        	if(_coll) struct_set(collapsed, _key, 0);
                        	else      struct_set(collapsed, _key, 1);
                    		left_free = false;
                        }
                    }
                        
					BLEND_NORMAL
					
					draw_sprite_ui(THEME.arrow, _coll? 0 : 3, ui(16 + 16), _yy + _lbh / 2, 1, 1, 0, _tc, 1);    
					draw_set_text(f_p2, fa_left, fa_center, _tc);
					draw_text_add(ui(16 + 28), _yy + _lbh / 2, _name);
				}
				
					 if(_cAll ==  1) { for( var i = 0; i < len; i++ ) struct_set(collapsed, group_labels[i].key, 0); } 
				else if(_cAll == -1) { for( var i = 0; i < len; i++ ) struct_set(collapsed, group_labels[i].key, 1); }
			}
			
			hh += curr_height;
			yy += curr_height;
			
			if(_hover && key_mod_press(CTRL)) {
				if(mouse_wheel_down()) display_grid_size_to = clamp(display_grid_size_to - ui(8), ui(32), ui(128));
				if(mouse_wheel_up())   display_grid_size_to = clamp(display_grid_size_to + ui(8), ui(32), ui(128));
			}
			display_grid_size = lerp_float(display_grid_size, display_grid_size_to, 3);
			
		} else if(PREFERENCES.dialog_add_node_view == 1) { // list
			var list_width  = ww;
			var list_height = display_list_size;
			
			var bg_ind = 0;
			var yy     = _y + ui(12);
			var pd     = ui(8);
			var sec_pd = ui(4);
			hh += list_height;
			
			for(var i = 0; i < node_count; i++) {
				var _node = _list[i];
				if(is_undefined(_node)) continue;
				if(is_instanceof(_node, NodeObject)) {
					if(_node.patreon && !IS_PATREON) continue;
					if(is_global && !_node.show_in_global) continue;
				}
				
				if(is_string(_node)) {
					if(PREFERENCES.dialog_add_node_grouping == 0) continue;
					if(PREFERENCES.dialog_add_node_grouping == 1 && string_starts_with(_node, "/")) continue;
					
					hh += sec_pd * bool(i);
					yy += sec_pd * bool(i);
					
					var _key = $"{ADD_NODE_PAGE}:{i}";
					
					array_push(group_labels, { y: yy, text: string_trim_start(__txt(_node), ["/"]), key: _key });
					
					if(struct_try_get(collapsed, _key, 0)) {
						hh += _lbh;
						yy += _lbh;
						
						while(i + 1 < node_count) {
							var _s = _list[i + 1];
							if(is_string(_s) && (!string_starts_with(_s, "/") || PREFERENCES.dialog_add_node_grouping == 2)) break;
							
							i++;
						}
					} else {
						hh += _lbh + sec_pd;
						yy += _lbh + sec_pd;
					}
					continue;
				}
				
				if(++bg_ind % 2) draw_sprite_stretched_add(THEME.node_bg, 0, pd, yy, list_width - pd * 2, list_height, c_white, 0.1);
				
				if(_hoverContent && point_in_rectangle(_m[0], _m[1], pd + ui(16 * 2), yy, list_width, yy + list_height - 1)) {
					content_pane.hover_content = true;
					node_icon      = _node.spr;
					node_icon_x    = content_pane.x + pd + list_height / 2 + ui(32);
					node_icon_y    = content_pane.y + yy + list_height / 2;
					
					draw_sprite_stretched_ext(THEME.node_bg, 1, pd, yy, list_width - pd * 2, list_height, COLORS._main_accent, 1);
					
					if(sFOCUS) {
						if(mouse_press(mb_left,  left_free))  buildNode(_node);
						if(mouse_press(mb_right, right_free)) rightClick(_node);
					}
				}
				
				var tx;
				
				if(is_instanceof(_node, NodeObject)) {
					tx = _node.drawList(pd, yy, _m[0], _m[1], list_height, list_width - pd);
					
				} else {
					var spr_x = pd + list_height / 2 + ui(32);
					var spr_y = yy + list_height / 2;
					
					if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
					if(sprite_exists(_node.spr)) {
						var ss = (list_height - ui(8)) / max(sprite_get_width(_node.spr), sprite_get_height(_node.spr));
						draw_sprite_ext(_node.spr, 0, spr_x, spr_y, ss, ss, 0, c_white, 1);
					}
					
					if(is_instanceof(_node, NodeAction) && !struct_try_get(_node, "hide_bg", false))
						draw_sprite_ui_uniform(THEME.play_action, 0, spr_x + list_height / 2 - 8, spr_y + list_height / 2 - 8, 0.5, COLORS.add_node_blend_action);
					
					tx = pd + list_height + ui(32 + 4);
					draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
					draw_text_add(tx, yy + list_height / 2, _node.getName());
					tx += string_width(_node.getName());
				}
				
				if(_hoverContent && point_in_rectangle(_m[0], _m[1], 0, yy, pd + ui(32), yy + list_height - 1)) {
					gpu_set_tex_filter(true); BLEND_ADD
					draw_sprite_ui_uniform(THEME.star, 0, pd + ui(16), yy + list_height / 2, .8, c_white, .5);
					gpu_set_tex_filter(false); BLEND_NORMAL
					
					if(mouse_press(mb_left, sFOCUS)) struct_toggle(global.FAV_NODES, _node.nodeName);
				}
				
				var _hinfo = _hoverContent && point_in_circle(_m[0], _m[1], tx + ui(12), yy + list_height / 2, list_height / 2);
				if(_node.getTooltip() != "" || _node.getTooltipSpr() != noone) {
					gpu_set_tex_filter(true);
					draw_sprite_ui_uniform(THEME.info, 0, tx + ui(12), yy + list_height / 2, 0.7, COLORS._main_icon, .5 + _hinfo * .25);
					gpu_set_tex_filter(false);
					
					if(_hinfo) {
						node_tooltip   = _node;
						node_tooltip_x = content_pane.x + pd;
						node_tooltip_y = content_pane.y + yy
					}
				}
				
				yy += list_height;
				hh += list_height;
			}
			
			if(PREFERENCES.dialog_add_node_grouping) {
				var len = array_length(group_labels);
				if(len && group_labels[0].y < 0) {
					gpu_set_blendmode(bm_subtract);
					draw_set_color(c_white);
					draw_rectangle(0, 0, ww, _lbh + sec_pd + ui(4), false);
					gpu_set_blendmode(bm_normal);
					
					content_hoverable &= !point_in_rectangle(_m[0], _m[1], 0, 0, ww, _lbh + ui(12));
				}
				
				var _cAll = 0;
				
				for( var i = 0; i < len; i++ ) {
					var lb = group_labels[i];
					var _name = lb.text;
					var _key  = lb.key;
					var _coll = struct_try_get(collapsed, _key, 0);
					
					var _yy = max(lb.y, i == len - 1? ui(8) : min(ui(8), group_labels[i + 1].y - ui(32)));
					var _hv = _hover && point_in_rectangle(_m[0], _m[1], 0, _yy, ww, _yy + _lbh);
					var _tc = CDEF.main_ltgrey;
					
					BLEND_OVERRIDE
					if(PREFERENCES.dialog_add_node_grouping == 1)
                    	draw_sprite_stretched_ext(THEME.box_r5_clr, 0, ui(16), _yy, ww - ui(32), _lbh, _hv? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg, 1);
                	else {
                    	draw_set_color(COLORS.panel_bg_clear_inner);
                    	draw_rectangle(ui(16), _yy, ww - ui(16), _yy + _lbh, false);
                    }
                    
					if(_hv && _focus) {
						if(PREFERENCES.dialog_add_node_grouping == 2) _tc = CDEF.main_white;
						
                    	if(DOUBLE_CLICK) {
                    		_cAll = _coll? -1 : 1;
                    		left_free = false;
                    		
                    	} else if(mouse_press(mb_left)) {
                        	if(_coll) struct_set(collapsed, _key, 0);
                        	else      struct_set(collapsed, _key, 1);
                    		left_free = false;
                        	
                        }
                    }
                        
					BLEND_NORMAL
					
					draw_sprite_ui(THEME.arrow, _coll? 0 : 3, ui(16 + 16), _yy + _lbh / 2, 1, 1, 0, _tc, 1);    
					
					draw_set_text(f_p2, fa_left, fa_center, _tc);
					draw_text_add(ui(16 + 28), _yy + _lbh / 2, _name);
				}
				
					 if(_cAll ==  1) { for( var i = 0; i < len; i++ ) struct_set(collapsed, group_labels[i].key, 0); } 
				else if(_cAll == -1) { for( var i = 0; i < len; i++ ) struct_set(collapsed, group_labels[i].key, 1); }
			}
			
			if(_hover && key_mod_press(CTRL)) {
				if(mouse_wheel_down()) display_list_size_to = clamp(display_list_size_to - ui(4), ui(16), ui(64));
				if(mouse_wheel_up())   display_list_size_to = clamp(display_list_size_to + ui(4), ui(16), ui(64));
				display_list_size = lerp_float(display_list_size, display_list_size_to, 3);
			}
		}
		
		if(mouse_release(mb_left)) left_free = true;
		
		return hh;
	});
	
	if(PREFERENCES.add_node_remember) {
		content_pane.scroll_y_raw = ADD_NODE_SCROLL;
		content_pane.scroll_y_to  = ADD_NODE_SCROLL;
		
	} else {
		ADD_NODE_PAGE    = 0;
		ADD_NODE_SUBPAGE = 0;
	}
	
	setPage(ADD_NODE_PAGE, ADD_NODE_SUBPAGE);
#endregion

#region resize
	dialog_resizable = true;
	dialog_w_min = ui(320);
	dialog_h_min = ui(320);
	dialog_w_max = ui(960);
	dialog_h_max = ui(800);
	
	onResize = function() {
		var _ch = dialog_h - ui(66);
		
		catagory_pane.resize(category_width, _ch);
		search_pane.resize(dialog_w - ui(36), _ch);
		
		PREFERENCES.dialog_add_node_w = dialog_w;
		PREFERENCES.dialog_add_node_h = dialog_h;
	}
#endregion

#region search
	search_string = "";
	search_list   = [];
	KEYBOARD_RESET
	
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_string = string(str); searchNodes(); })
                 .setAlign(fa_left)
                 .setAutoupdate();
	WIDGET_CURRENT = tb_search;
	
	function searchNodes() { 
		search_list = [];
		var pr_list = ds_priority_create();
		
		var search_lower = string_lower(search_string);
		var search_split = string_split(search_lower, " ", true);
		var search_map	 = ds_map_create();
		
		for( var i = 0, n = array_length(category); i < n; i++ ) {
			var cat = category[i];
			
			if(!struct_has(cat, "list")) continue;
				
			if(cat[$ "filter"] != undefined && !array_exists(cat.filter, instanceof(context)))
				continue;
			
			var _content = cat.list;
			for( var j = 0, m = array_length(_content); j < m; j++ ) {
				var _node = _content[j];
				
				if(is_string(_node))					continue;
				if(ds_map_exists(search_map, _node))	continue;
				
				var match = string_partial_match_res(string_lower(_node.getName()), search_lower, search_split);
								
				if(is_instanceof(_node, NodeObject)) {
					if(_node.deprecated) continue;
					if(match[0] > -9000 && struct_exists(global.FAV_NODES, _node.nodeName)) 
						match[0] += 10000;
				}
				
				var param = "";
				for( var k = 0, p = array_length(_node.tags); k < p; k++ ) {
					var mat = string_partial_match_res(_node.tags[k], search_lower, search_split);
					mat[0] -= 10;
					
					if(mat[0] > match[0]) {
						match = mat;
						param = _node.tags[k];
					}
				}
				
				if(match[0] == -9999) continue;
				
				ds_priority_add(pr_list, [ _node, param, match ], match[0]);
				search_map[? _node] = 1;
			}
		}
		
		ds_map_destroy(search_map);
		
		searchCollection(pr_list, search_string, false);
		
		repeat(ds_priority_size(pr_list))
			array_push(search_list, ds_priority_delete_max(pr_list));
		
		ds_priority_destroy(pr_list);
	}
	
	search_pane = new scrollPane(dialog_w - ui(36), dialog_h - ui(66), function(_y, _m) {
		draw_clear_alpha(c_white, 0);
		
		var equation = string_char_at(search_string, 0) == "=";
		var amo		 = array_length(search_list);
		var hh		 = 0;
		var _hover	 = sHOVER && search_pane.hover;
		
		var grid_size  = ui(56);
		var grid_width = ui(80);
		var grid_space = ui(16);
		
		var highlight  = PREFERENCES.dialog_add_node_search_high;
		
		if(equation) {
			var eq = string_replace(search_string, "=", "");
			
			draw_set_text(f_h5, fa_center, fa_bottom, COLORS._main_text_sub);
			draw_text_line(search_pane.w / 2, search_pane.h / 2 - ui(8), 
				__txtx("add_node_create_equation", "Create equation") + ": " + eq, -1, search_pane.w - ui(32));
			
			draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_add(round(search_pane.w / 2), round(search_pane.h / 2 - ui(4)), 
				__txtx("add_node_equation_enter", "Press Enter to create equation node."));
			
			if(keyboard_check_pressed(vk_enter))
				buildNode(ALL_NODES[$ "Node_Equation"], { query: eq } );
			return hh;
		}
		
		if(PREFERENCES.dialog_add_node_view == 0) { // grid
			
			var cc;
			var col    = floor(search_pane.surface_w / (grid_width + grid_space));
			var yy     = _y + grid_space;
			var index  = 0;
			var name_height = 0;
			
			grid_width = round(search_pane.surface_w - grid_space) / col - grid_space;
			hh += (grid_space + grid_size) * 2;
			
			for(var i = 0; i < amo; i++) {
				var s_res  = search_list[i];
				var _node  = noone;
				var _param = {};
				var _query = "";
				var _mrng  = noone;
				
				if(is_array(s_res)) {
					_node        = s_res[0];
					_query       = s_res[1];
					_mrng        = s_res[2][1];
				} else
					_node = s_res;
					
				if(!checkValid(_node, false)) continue;
				
				_param.search_string = highlight? search_string : 0;
				_param.query = _query;
				
				var _nx   = grid_space + (grid_width + grid_space) * index;
				var _boxx = _nx + (grid_width - grid_size) / 2;
				
				var _drw = yy > -grid_size && yy < search_pane.h;
				
				if(_drw) {
					
						 if(is_instanceof(_node, NodeObject))	cc = c_white;
					else if(is_instanceof(_node, NodeAction))	cc = COLORS.add_node_blend_action;
					else if(is_instanceof(_node, AddNodeItem))	cc = COLORS.add_node_blend_generic;
					else										cc = COLORS.dialog_add_node_collection;
					
					if(!struct_try_get(_node, "hide_bg", false)) {
						BLEND_OVERRIDE
						draw_sprite_stretched_ext(THEME.node_bg, 0, _boxx, yy, grid_size, grid_size, cc, 1);
						BLEND_NORMAL
					}
					
					var _minput = _hover && (MOUSE_MOVED || mouse_release(mb_any));
					if(_minput && point_in_rectangle(_m[0], _m[1], _nx, yy, _nx + grid_size, yy + grid_size)) {
						search_pane.hover_content = true;
						node_selecting = i;
						
						if(mouse_release(mb_left, sFOCUS))
							buildNode(_node, _param);
						else if(struct_has(_node, "node") && mouse_release(mb_right, right_free && sFOCUS))
							rightClick(_node);
					}
					
					if(node_selecting == i) {
						draw_sprite_stretched_ext(THEME.node_bg, 1, _boxx, yy, grid_size, grid_size, COLORS._main_accent, 1);
						if(keyboard_check_pressed(vk_enter))
							buildNode(_node, _param);
					}
					
					if(is_instanceof(_node, NodeObject)) {
						_node.drawGrid(_boxx, yy, _m[0], _m[1], grid_size, _param);
					} else {
						if(variable_struct_exists(_node, "getSpr")) _node.getSpr();
						if(sprite_exists(_node.spr)) {
							var _si = current_time * PREFERENCES.collection_preview_speed /  3000;
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
					
						if(is_instanceof(_node, NodeAction) && !struct_try_get(_node, "hide_bg", false))
							draw_sprite_ui_uniform(THEME.play_action, 0, _boxx + grid_size - 16, yy + grid_size - 16, 1, COLORS.add_node_blend_action);
					}
					
					if(struct_has(_node, "tooltip") && (_node.getTooltip() != "" || _node.getTooltipSpr() != noone)) {
						if(_hover && point_in_rectangle(_m[0], _m[1], _boxx, yy, _boxx + ui(16), yy + ui(16))) {
							search_pane.hover_content = true;
							
							draw_sprite_ui_uniform(THEME.info, 0, _boxx + ui(8), yy + ui(8), 0.7, COLORS._main_icon, 1.0);
							node_tooltip   = _node;
							node_tooltip_x = search_pane.x + _nx;
							node_tooltip_y = search_pane.y + yy
						} else 
							draw_sprite_ui_uniform(THEME.info, 0, _boxx + ui(8), yy + ui(8), 0.7, COLORS._main_icon, 0.5);
					}
				
				}
				
				var _name = _node.getName();
				var _showQuery = _query != "";
				
				draw_set_font(_showQuery? f_p3 : f_p2);
				var _nmh = string_height_ext(_name, -1, grid_width);
				var _nmy = yy + grid_size + 4;
				var _drw = _nmy > -grid_size && _nmy < search_pane.h;
				
				if(_showQuery) {
					_query = string_title(_query);
					
					draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text_sub);
					if(_drw) draw_text_add(_boxx + grid_size / 2, _nmy, _name); 
					_nmy += _nmh - ui(2);
					
					draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text);
					var _qhh = string_height_ext(_query, -1, grid_width);
					if(_drw) {
						if(highlight && _mrng != noone) _qhh = draw_text_match_range_ext(_boxx + grid_size / 2, _nmy, _query, grid_width, _mrng); 
						else draw_text_ext(_boxx + grid_size / 2, _nmy, _query, -1, grid_width); 
					}
					_nmy += _qhh;
					_nmh += _qhh;
					
				} else {
					draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text);
					if(_drw) {
						if(highlight && _mrng != noone) _nmh = draw_text_match_range_ext(_boxx + grid_size / 2, _nmy, _name, grid_width, _mrng);
						else draw_text_ext(_boxx + grid_size / 2, _nmy, _name, -1, grid_width);
					}
				}
				
				name_height = max(name_height, _nmh);
				
				if(node_focusing == i) search_pane.scroll_y_to = -max(0, hh - search_pane.h);	
					
				if(++index >= col) {
					index = 0;
					var hght = grid_size + grid_space + name_height;
					name_height = 0;
					hh += hght;
					yy += hght;
				}
			}
			
		
		} else if(PREFERENCES.dialog_add_node_view == 1) { // list
			
			var list_width  = search_pane.surface_w;
			var list_height = ui(28);
			var sy  = _y + list_height / 2;
			var pd  = ui(8);
			var ind = 0;
			
			for(var i = 0; i < amo; i++) {
				var s_res  = search_list[i];
				var  yy    = sy + list_height * ind;
				var _node  = noone;
				var _param = {};
				var _query = "";
				var _mrng  = noone;
				
				if(is_array(s_res)) {
					_node        = s_res[0];
					_query       = s_res[1];
					_mrng        = s_res[2][1];
				} else
					_node = s_res;
					
				if(!checkValid(_node, false)) continue;
				ind++;
				
				if(yy < -list_height || yy > search_pane.h) continue;
				_param.search_string = highlight? search_string : 0;
				_param.query = _query;
				_param.range = _mrng;
				
				if(i % 2) draw_sprite_stretched_add(THEME.node_bg, 0, pd, yy, list_width - pd * 2, list_height, c_white, 0.1);
				
				var _minput  = _hover && (MOUSE_MOVED || mouse_release(mb_any));
				var _mouseOn = point_in_rectangle(_m[0], _m[1], pd + ui(16 * 2), yy, list_width, yy + list_height - 1);
				
				if(_mouseOn) {
					search_pane.hover_content = true;
					node_icon   = _node.spr;
					node_icon_x = search_pane.x + pd + list_height / 2 + ui(32);
					node_icon_y = search_pane.y + yy + list_height / 2;
				}
				
				if(_minput && _mouseOn) {
					node_selecting = i;
					
					if(sFOCUS) {
						if(mouse_release(mb_left))
							buildNode(_node, _param);
							
						if(struct_has(_node, "node") && mouse_release(mb_right, right_free))
							rightClick(_node);
					}
				}
				
				if(node_selecting == i) {
					draw_sprite_stretched_ext(THEME.node_bg, 1, pd, yy, list_width - pd * 2, list_height, COLORS._main_accent, 1);
					if(keyboard_check_pressed(vk_enter)) buildNode(_node, _param);
				}
				
				var tx;
				
				if(is_instanceof(_node, NodeObject)) {
					var tx = _node.drawList(pd, yy, _m[0], _m[1], list_height, list_width - pd, _param);
					
				} else {
					if(struct_has(_node, "getSpr")) _node.getSpr();
					if(sprite_exists(_node.spr)) {
						var _si = current_time * PREFERENCES.collection_preview_speed / 3000;
						var _sw = sprite_get_width(_node.spr);
						var _sh = sprite_get_height(_node.spr);
						var _ss = (list_height - ui(8)) / max(_sw, _sh);
					
						var _sox = sprite_get_xoffset(_node.spr);
						var _soy = sprite_get_yoffset(_node.spr);
					
						var _sx = pd + list_height / 2 + ui(32);
						var _sy = yy + list_height / 2;
						_sx += _sw * _ss / 2 - _sox * _ss;
						_sy += _sh * _ss / 2 - _soy * _ss;
				
						draw_sprite_ext(_node.spr, _si, _sx, _sy, _ss, _ss, 0, c_white, 1);
					
						if(is_instanceof(_node, NodeAction) && !struct_try_get(_node, "hide_bg", false))
							draw_sprite_ui_uniform(THEME.play_action, 0, _sx + list_height / 2 - 8, _sy + list_height / 2 - 8, 0.5, COLORS.add_node_blend_action);
					}
					
					tx = pd + list_height + ui(32 + 4);
					draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
					if(highlight) draw_text_match(tx, yy + list_height / 2, _node.getName(), search_string);
					else          draw_text(      tx, yy + list_height / 2, _node.getName());
					
					tx += string_width(_node.getName());
				}
				
				if(_hover && MOUSE_MOVED && point_in_rectangle(_m[0], _m[1], 0, yy, pd + ui(32), yy + list_height - 1)) {
					node_selecting = noone;
					
					gpu_set_tex_filter(true); BLEND_ADD
					draw_sprite_ui_uniform(THEME.star, 0, pd + ui(16), yy + list_height / 2, .8, c_white, .5);
					gpu_set_tex_filter(false); BLEND_NORMAL
					
					if(mouse_press(mb_left, sFOCUS)) struct_toggle(global.FAV_NODES, _node.nodeName);
				}
				
				var _hinfo = _hover && point_in_circle(_m[0], _m[1], tx + ui(12), yy + list_height / 2, list_height / 2);
				if((struct_has(_node, "getTooltip") && _node.getTooltip() != "") || (struct_has(_node, "getTooltipSpr") && _node.getTooltipSpr() != noone)) {
					gpu_set_tex_filter(true);
					draw_sprite_ui_uniform(THEME.info, 0, tx + ui(12), yy + list_height / 2, 0.7, COLORS._main_icon, .5 + _hinfo * .25);
					gpu_set_tex_filter(false);
					
					if(_hinfo) {
						node_tooltip   = _node;
						node_tooltip_x = search_pane.x + pd;
						node_tooltip_y = search_pane.y + yy;
					}
				}
			}
			
			hh = list_height * (ind + 1);
		}
		
		node_focusing = -1;
		
		if(KEYBOARD_PRESSED == vk_up) {
			if(PREFERENCES.dialog_add_node_view == 0) {
				node_selecting = safe_mod(node_selecting - 1 + amo, amo);
				node_focusing  = node_selecting;
			} else {
				node_selecting--;
				if(node_selecting < 0) {
					node_selecting = amo - 1;
					search_pane.scroll_y_to = -list_height * node_selecting + list_height * 4;
				} else 
					search_pane.scroll_y_to = max(search_pane.scroll_y_to, -list_height * node_selecting + list_height * 4);
			}
		}
		
		if(KEYBOARD_PRESSED == vk_down) {
			if(PREFERENCES.dialog_add_node_view == 0) {
				node_selecting = safe_mod(node_selecting + 1, amo);
				node_focusing  = node_selecting;
			} else {
				node_selecting++;
				if(node_selecting >= amo) {
					node_selecting = 0;
					search_pane.scroll_y_to = -list_height * node_selecting + list_height * 4;
				} else 
					search_pane.scroll_y_to = min(search_pane.scroll_y_to, -list_height * node_selecting - list_height * 4 + search_pane.h);
			}
		}
		
		return hh;
	});
#endregion