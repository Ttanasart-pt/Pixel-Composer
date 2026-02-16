function node_filter_by_type(nodeList, _type) {
	__type = _type;
	return array_filter(nodeList, function(n,i) /*=>*/ {return instanceof(n) == __type});
}

function node_filter_by_name(nodeList, _filt, _case = false) {
	__filt = _filt;
	return array_filter(nodeList, function(n,i) /*=>*/ {return regex_match_c(n.getDisplayName(), __filt)});
}

function node_filter_by_color(nodeList, _color) {
	__color = _color;
	return array_filter(nodeList, function(n,i) /*=>*/ {return n.attributes.color == __color});
}

function Panel_Graph_Selector(_graph) : Panel_Linear_Setting() constructor {
	title = __txt("Node Selector");
	graph = _graph;
	auto_pin = true;
	
	type     = noone;
	text     = "";
	nodetype = "";
	node     = undefined;
	recur    = false;
	color    = -1;
	
	static setType = function(_type) {
		if(type == _type) return;
		type = _type;
		
		switch(type_list[type]) {
			case "Name"    : properties = [ prop_type, prop_name      ];             break;
			case "Type"    : properties = [ prop_type, prop_node_type ];             break;
			case "Color"   : properties = [ prop_type, prop_node_colr, prop_color ]; break;
			
			case "From"    : 
			case "To"      : properties = [ prop_type, prop_node, prop_recur ];      break;
			
			case "Sibling"   : properties = [ prop_type, prop_node ]; break;
			case "Connected" : properties = [ prop_type, prop_node ]; break;
			
			default : 
				properties = [ prop_type ]; 
				select(); 
				break;
		}
	}
	
	static setNodeColor = function(_node = noone) { color    = is(_node, Node)? _node.attributes.color : -1; select(); } mself_mf0 setNodeColor mself_mf1 setNodeColor mself_mf2;
	static setNodeType  = function(_node = noone) { nodetype = is(_node, Node)? instanceof(_node) : ""; select(); }      mself_mf0 setNodeType mself_mf1 setNodeType mself_mf2;
	static setNode      = function(_node = noone) { node     = _node; select(); }                                        mself_mf0 setNode mself_mf1 setNode mself_mf2;
	
	static select = function() {
		if(!is(graph, Panel_Graph)) return;
		
		var _nod = graph.getNodeList();
		if(array_empty(_nod)) return;
		
		var _sel = undefined;
		
		switch(type_list[type]) {
			case "Name"  : if(text == "")      return; _sel = node_filter_by_name(_nod, text, false);            break;
			case "Type"  : if(nodetype == "")  return; _sel = node_filter_by_type(_nod, nodetype);               break;
			case "Color" : if(color == -1)     return; _sel = node_filter_by_color(_nod, color);                 break;
			case "From"  : if(!is(node, Node)) return; _sel = recur? node.getAllNodeFrom() : node.getNodeFrom(); break;
			case "To"    : if(!is(node, Node)) return; _sel = recur? node.getAllNodeTo()   : node.getNodeTo();   break;
			
			case "Sibling": if(!is(node, Node)) return; 
				_sel = [];
				var _tos = node.getNodeTo();
				
				for( var i = 0, n = array_length(_tos); i < n; i++ ) {
					var _to = _tos[i];
					var _fr = _to.getNodeFrom();
					_sel = array_append(_sel, _fr);
				}
				
				_sel = array_unique(_sel);
				break;
			
			case "Connected": if(!is(node, Node)) return; 
				_sel = array_append(node.getAllNodeFrom(), node.getAllNodeTo());
				array_push(_sel, node);
				
				_sel = array_unique(_sel);
				break;
			
			case "Has Animation" : _sel = array_filter(_nod, function(n,i) /*=>*/ {return n.isAnimated()});      break; 
			case "Use Cache" :     _sel = array_filter(_nod, function(n,i) /*=>*/ {return n.attributes.cache});  break; 
			case "Non-Render" :    _sel = array_filter(_nod, function(n,i) /*=>*/ {return !n.renderActive});     break; 
			case "Orphan" :        _sel = array_filter(_nod, function(n,i) /*=>*/ {return array_empty(n.getNodeFrom()) && array_empty(n.getNodeTo())}); break; 
			
			case "Inverse Selection" : _sel = array_substract(_nod, graph.nodes_selecting);     break; 
		}
		
		if(_sel != undefined) graph.selectNodes(_sel, key_mod_press(SHIFT));
		
	} select = method(self, select);
	
	type_list = [ "Name", "Type", "Color", "From", "To", "Sibling", "Connected", 
		-1, "Has Animation", "Use Cache", "Non-Render", "Orphan", 
		-1, "Inverse Selection" 
	];
	prop_type = new __Panel_Linear_Setting_Item( __txt("Type"),   new scrollBox(type_list, function(i) /*=>*/ { setType(i); }).setUpdateHover(false), function() /*=>*/ {return type}  );
	
	prop_name      = new __Panel_Linear_Setting_Item( __txt("RegEx"), textBox_Text(function(t) /*=>*/ { text = t; select(); }), function() /*=>*/ {return text} );
	prop_node_type = new __Panel_Linear_Setting_Item( __txt("Node"), button(function() /*=>*/ {return graph.dropperActive(setNodeType)}, THEME.node_drop).iconPad(), function() /*=>*/ {return nodetype} );
	
	prop_node      = new __Panel_Linear_Setting_Item( __txt("Node"), button(function() /*=>*/ {return graph.dropperActive(setNode)},     THEME.node_drop).iconPad(), function() /*=>*/ {return nodetype} );
	prop_recur     = new __Panel_Linear_Setting_Item( __txt("Recursive"), new checkBox(function() /*=>*/ { recur = !recur; }),  function() /*=>*/ {return recur} );
	
	prop_color     = new __Panel_Linear_Setting_Item( __txt("Color"), new buttonColor(function(c) /*=>*/ { color = c; }).hideAlpha(), function() /*=>*/ {return color} );
	prop_node_colr = new __Panel_Linear_Setting_Item( __txt("Sample"), button(function() /*=>*/ {return graph.dropperActive(setNodeColor)}, THEME.node_drop).iconPad(), function() /*=>*/ {return nodetype} );
	
	properties = [
		prop_type
	];
	
	setType(0);
}