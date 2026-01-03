function Panel_Custom_Node_Input() : Panel_Custom_Element() constructor {
	type = "input";
	name = "Input";
	icon = THEME.panel_icon_element_node_input;
	
	node_id = undefined;
	junc_id = undefined;
	
	node       = undefined;
	junction   = undefined;
	editWidget = undefined;
	
	font = 1;
	
	#region node junc data
		nodeList     = [];
		nodeListName = [];
		static getNodeList = function() {
			nodeList     = [];
			nodeListName = [];
			for( var i = 0, n = array_length(PROJECT.allNodes); i < n; i++ ) {
				var _node = PROJECT.allNodes[i];
				nodeList[i]     = _node;
				nodeListName[i] = _node.getDisplayName();
			}
			
			return nodeListName;
		}
		
		juncList     = [];
		juncListName = [];
		static getJuncList = function() {
			if(node == undefined) return [];
			
			juncList     = [];
			juncListName = [];
			for( var i = 0, n = array_length(node.inputs); i < n; i++ ) {
				var _junc = node.inputs[i];
				juncList[i]     = _junc;
				juncListName[i] = _junc.name;
			}
			
			return juncListName;
		}
	#endregion
	
	array_append(editors, [
		[ "Data", false ], 
		new Panel_Custom_Element_Editor("Node", new scrollBoxFn(function() /*=>*/ {return getNodeList()}, function(i) /*=>*/ { node = nodeList[i]; junction = undefined; } ), 
			function() /*=>*/ {return node? node.getDisplayName() : ""}, function(n) /*=>*/ { node = n; }), 
		
		new Panel_Custom_Element_Editor("Input", new scrollBoxFn(function() /*=>*/ {return getJuncList()}, function(i) /*=>*/ { setJunction(juncList[i]); } ), 
			function() /*=>*/ {return junction? junction.name : ""}, function(n) /*=>*/ { node = n; }), 
		
		[ "Text", false ], 
		new Panel_Custom_Element_Editor("Font", new scrollBox( [ 
			"Content 1", 
			"Content 2", 
			"Content 3", 
			"Content 4", 
		], function(t) /*=>*/ { font = t; } ), function() /*=>*/ {return font}, function(t) /*=>*/ { font = t; }), 
		
	]);
	
	static setJunction = function(_junc) {
		if(!is(_junc, NodeValue)) return self;
		
		node       = _junc.node;
		junction   = _junc;
		editWidget = junction.editWidget.clone();
		
		node_id = _junc.node.node_id;
		junc_id = _junc.index;

		return self;
	}
	
	static getNode = function() {
		if(is(node, Node)) return node;
		if(node_id == undefined) return undefined;
		
		var _node = PROJECT.getNodeFromID(node_id);
		if(_node) node = _node;
		return node;
	} 
	
	static getJunction = function() {
		if(is(junction, NodeValue)) return junction;
		
		var _node = getNode();
		if(!_node) return junction;
		
		var _junc = array_safe_get_fast(_node.inputs, junc_id); 
		setJunction(_junc);
		
		return junction;
	}
	
	////- Draw
	
	static draw = function(panel, _m) {
		var _font = f_p2;
		switch(font) {
			case 0 : _font = f_p1; break;
			case 1 : _font = f_p2; break;
			case 2 : _font = f_p3; break;
			case 3 : _font = f_p4; break;
		}
		
		var _junc = getJunction();
		if(_junc && editWidget) {
			var _dat   = _junc.showValue();
			var _param = new widgetParam(x, y, w, h, _dat, _junc.display_data, _m, rx, ry)
				.setFont(_font);
			
			var _inter = is(panel, Panel_Custom);
			editWidget.setInteract(_inter);
			editWidget.setFocusHover(_inter && panel.pHOVER, _inter && panel.pFOCUS);
			editWidget.drawParam(_param);
			
		} else {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, x, y, w, h);
		}
		
		var _hov = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		if(_hov) panel.hovering_element = self;
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.font = font;
		
		var _junc = getJunction();
		_m.node_id = _junc? _junc.node.node_id : "";
		_m.junc_id = _junc? _junc.index : 0;
		
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		node_id = _m.node_id;
		junc_id = _m.junc_id;
		
		font = _m[$ "font"] ?? font;
		
		return self;
	}
}