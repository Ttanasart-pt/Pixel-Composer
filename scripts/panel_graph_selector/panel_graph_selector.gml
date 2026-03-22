function Panel_Graph_Selector(_graph) : PanelContent() constructor {
	title = __txt("Node Selector");
	graph = _graph;
	auto_pin = true;
	
	w = ui(360); min_w = ui(64);
	h = ui(36);  min_h = h;
	
	#region data
		padding  = ui(6);
		wdgw     = ui(64);
		font     = f_p3;
	
		bg_y    = -1;
		bg_y_to = -1;
		bg_a    =  0;
		
		prop_height = line_get_height(font, 12);
	#endregion
	
	#region selector
		text     = "";
		nodetype = "";
		node     = undefined;
		recur    = false;
		color    = -1;
		
		static select = function() {
			if(!is(graph, Panel_Graph)) return;
			
			var hasCond = text != "" || nodetype != "" || color != -1;
			if(!hasCond) return;
			
			var _nod = graph.getNodeList();
			if(array_empty(_nod)) return;
			
			var _sel = [];
			
			for( var i = 0, len = array_length(_nod); i < len; i++ ) {
				var n = _nod[i];
				var c = false;
				var mAny = false;
				var mAll = true;
				
				if(text != "") {
					var s = regex_match_c(string_lower(n.getDisplayName()), string_lower(text));
					mAny |= s; mAll &= s;
				}
				
				if(nodetype != "") {
					var s = instanceof(n) == nodetype;
					mAny |= s; mAll &= s;
				}
				
				if(color != -1) {
					var s = n.attributes.color == color;
					mAny |= s; mAll &= s;
				}
				
				if(mAll) array_push(_sel, n);
			}
			
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		}
	#endregion
	
	#region widget
		type_list = [ "Name", "Type", "Color", "From", "To", "Sibling", "Connected", 
			-1, "Has Animation", "Use Cache", "Non-Render", "Orphan", 
			-1, "Inverse Selection" 
		];
		
		prop_name = textBox_Text(function(t) /*=>*/ { 
			text = t; 
			select(); 
		}).setEmpty().setClearable();
		
		prop_node_type = button(function() /*=>*/ {return graph.dropperActive(function(n) /*=>*/ {
			nodetype = is(n, Node)? instanceof(n) : "";
			select();
		})}, THEME.node_drop).iconPad(ui(6)).setTooltip(__txt("Fitler Node Type"));
		
		prop_color         = new buttonColor(function(c) /*=>*/ { color = c; }).hideAlpha();
		prop_color.padding = ui(4);
		prop_color.trigger = function() /*=>*/ {return graph.dropperActive(function(n) /*=>*/ {
			color = is(n, Node)? n.attributes.color : -1; 
			select();
		})};
		
		prop_node_from     = button(function() /*=>*/ {return graph.dropperActive(function(n) /*=>*/ {
			if(!is(n, Node)) return;
			var _sel = recur? n.getAllNodeFrom() : n.getNodeFrom();
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		})}, THEME.node_sel_from).iconPad(ui(6)).setTooltip(__txt("Select Node From"));
		
		prop_node_to       = button(function() /*=>*/ {return graph.dropperActive(function(n) /*=>*/ {
			if(!is(n, Node)) return;
			var _sel = recur? n.getAllNodeTo() : n.getNodeTo();
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		})}, THEME.node_sel_to).iconPad(ui(6)).setTooltip(__txt("Select Node To"));
		
		prop_node_sibling  = button(function() /*=>*/ {return graph.dropperActive(function(n) /*=>*/ {
			if(!is(n, Node)) return;
			_sel = [];
			var _tos = n.getNodeTo();
			
			for( var i = 0, len = array_length(_tos); i < len; i++ ) {
				var _to = _tos[i];
				var _fr = _to.getNodeFrom();
				_sel = array_append(_sel, _fr);
			}
			
			_sel = array_unique(_sel);
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		})}, THEME.node_sel_sib).iconPad(ui(6)).setTooltip(__txt("Select Siblings"));
		
		prop_node_con      = button(function() /*=>*/ {return graph.dropperActive(function(n) /*=>*/ {
			if(!is(n, Node)) return;
			_sel = array_append(n.getAllNodeFrom(), n.getAllNodeTo());
			array_push(_sel, n);
			
			_sel = array_unique(_sel);
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		})}, THEME.node_sel_conn).iconPad(ui(6)).setTooltip(__txt("Select Connected Node"));
		
		filter_buttons = [
			prop_node_from,
			prop_node_to,
			prop_node_sibling,
			prop_node_con,
		];
		
		///////////////////////////////////////////////////////////////////////////////////////////
		
		show_action = false;
		prop_action_toggle  = button(function() /*=>*/ {
			show_action = !show_action;
		}, THEME.arrow).iconPad(ui(2)).setTooltip(__txt("Actions"));
		
		prop_sel_anim    = button(function() /*=>*/ {
			var _nod = graph.getNodeList();
			if(array_empty(_nod)) return;
			
			var _sel = array_filter(_nod, function(n,i) /*=>*/ {return n.isAnimated()});
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		}, THEME.node_sel_anim).iconPad(ui(6)).setTooltip(__txt("Has Animation"));
		
		prop_sel_cache   = button(function() /*=>*/ {
			var _nod = graph.getNodeList();
			if(array_empty(_nod)) return;
			
			var _sel = array_filter(_nod, function(n,i) /*=>*/ {return n.attributes.cache});
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		}, THEME.node_sel_cache).iconPad(ui(6)).setTooltip(__txt("Has Cache"));
		
		prop_sel_non_render = button(function() /*=>*/ {
			var _nod = graph.getNodeList();
			if(array_empty(_nod)) return;
			
			var _sel = array_filter(_nod, function(n,i) /*=>*/ {return !n.renderActive});
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		}, THEME.node_sel_render_none).iconPad(ui(6)).setTooltip(__txt("Not Rendered"));
		
		prop_sel_orphan  = button(function() /*=>*/ {
			var _nod = graph.getNodeList();
			if(array_empty(_nod)) return;
			
			var _sel = array_filter(_nod, function(n,i) /*=>*/ {return array_empty(n.getNodeFrom()) && array_empty(n.getNodeTo())});
			if(!array_empty(_sel)) graph.selectNodes(_sel);
			
		}, THEME.node_sel_orphan).iconPad(ui(6)).setTooltip(__txt("Orphan"));
		
		prop_sel_invert  = button(function() /*=>*/ {
			var _nod = graph.getNodeList();
			var _sel = array_substract(_nod, graph.nodes_selecting);
			graph.selectNodes(_sel);
			
		}, THEME.node_sel_invert).iconPad(ui(6)).setTooltip(__txt("Invert Selection"));
		
		action_buttons = [
			prop_sel_anim, 
			prop_sel_cache, 
			prop_sel_non_render, 
			prop_sel_orphan, 
		];
		
		prop_recur = new checkBox(function() /*=>*/ { recur = !recur; });
	#endregion
	
	function drawContent() {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		var ty = py;
		var tw = ui(128); 
		var th = ph;
		var bs = ph;
		
		var hover = pHOVER;
		var xx = w - padding;
		var m  = [mx,my];
		
		xx -= bs;
		prop_sel_invert.setFocusHover(pFOCUS, hover);
		prop_sel_invert.drawParam(new widgetParam(xx, ty, bs, bs, 0, undefined, m, x, y)); 
		xx -= ui(4);
		
		xx -= ui(12);
		prop_action_toggle.icon_index = show_action * 2;
		prop_action_toggle.icon_blend = show_action? COLORS._main_accent : COLORS._main_icon_light;
		prop_action_toggle.setFocusHover(pFOCUS, hover);
		prop_action_toggle.drawParam(new widgetParam(xx, ty, ui(12), bs, 0, undefined, m, x, y)); 	
		xx -= ui(4);
		
		if(show_action) {
			for( var i = 0, n = array_length(action_buttons); i < n; i++ ) {
				var b = action_buttons[i];
				xx -= bs;
				b.setFocusHover(pFOCUS, hover);
				b.drawParam(new widgetParam(xx, ty, bs, bs, 0, undefined, m, x, y)); 	
				xx -= ui(4);
			}
			xx -= ui(4);
		}
		
		if(mx > xx) hover = false;
		
		var scis = gpu_get_scissor();
		gpu_set_scissor(0, 0, xx, h);
		var xx = padding;
		
		prop_name.setFocusHover(pFOCUS, hover);
		prop_name.register();
		prop_name.drawParam(new widgetParam(xx, ty, tw, th, text, undefined, m, x, y).setFont(font)); 
		xx += tw + ui(4);
		
		prop_node_type.icon_blend = nodetype == ""? COLORS._main_icon_light : COLORS._main_accent;
		prop_node_type.setFocusHover(pFOCUS, hover);
		prop_node_type.drawParam(new widgetParam(xx, ty, bs, bs, 0, undefined, m, x, y)); 
		xx += bs + ui(4);
		
		prop_color.setFocusHover(pFOCUS, hover);
		prop_color.drawParam(new widgetParam(xx, ty, bs, bs, color, undefined, m, x, y)); 
		xx += bs + ui(4);
		
		for( var i = 0, n = array_length(filter_buttons); i < n; i++ ) {
			var b = filter_buttons[i];
			b.setFocusHover(pFOCUS, hover);
			b.drawParam(new widgetParam(xx, ty, bs, bs, 0, undefined, m, x, y)); 	
			xx += bs + ui(4);
		}
		
		gpu_set_scissor(scis);
	}
}