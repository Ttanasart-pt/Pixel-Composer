function Panel_Custom_Node_Output() : Panel_Custom_Element() constructor {
	type = "output";
	name = "Output";
	icon = THEME.panel_icon_element_node_output;
	
	node_id = undefined;
	junc_id = undefined;
	
	node       = undefined;
	junction   = undefined;
	editWidget = undefined;
	
	dataOnly = true;
	font     = 1;
	halign   = fa_left;
	valign   = fa_top;
	color    = ca_white;
	surface_fit = 0;
	
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
			for( var i = 0, n = array_length(node.outputs); i < n; i++ ) {
				var _junc = node.outputs[i];
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
		
		new Panel_Custom_Element_Editor("Output", new scrollBoxFn(function() /*=>*/ {return getJuncList()}, function(i) /*=>*/ { setJunction(juncList[i]); } ), 
			function() /*=>*/ {return junction? junction.name : ""}, function(n) /*=>*/ { node = n; }), 
		
		new Panel_Custom_Element_Editor("Data Only", new checkBox( function() /*=>*/ { dataOnly = !dataOnly; } ), function() /*=>*/ {return dataOnly}, function(t) /*=>*/ { dataOnly = t; }), 
		
		[ "Text", false ], 	
		new Panel_Custom_Element_Editor("Font", new scrollBox( [ 
			"Content 1", 
			"Content 2", 
			"Content 3", 
			"Content 4", 
		], function(t) /*=>*/ { font = t; } ), function() /*=>*/ {return font}, function(t) /*=>*/ { font = t; }), 
		new Panel_Custom_Element_Editor("H Align", new buttonGroup( array_create(3, THEME.inspector_text_halign), function(c) /*=>*/ { halign = c; }), function() /*=>*/ {return halign}, function(c) /*=>*/ { halign = c; }), 
		new Panel_Custom_Element_Editor("V Align", new buttonGroup( array_create(3, THEME.inspector_text_valign), function(c) /*=>*/ { valign = c; }), function() /*=>*/ {return valign}, function(c) /*=>*/ { valign = c; }), 
		new Panel_Custom_Element_Editor("Surface Fit", new scrollBox( [ 
			"Keep Ratio min", 
			"Keep Ratio max", 
			"Stretch", 
		], function(t) /*=>*/ { surface_fit = t; } ), function() /*=>*/ {return surface_fit}, function(t) /*=>*/ { surface_fit = t; }), 
		
		[ "Display", false ], 	
		new Panel_Custom_Element_Editor("Color", new buttonColor( function(c) /*=>*/ { color = c; }), function() /*=>*/ {return color}, function(c) /*=>*/ { color = c; }), 
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
		
		var _junc = array_safe_get_fast(_node.outputs, junc_id); 
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
			var _dat = _junc.showValue();
			
			if(dataOnly) {
				switch(_junc.type) {
					case VALUE_TYPE.surface : 
						if(!is_surface(_dat)) break;
						
						if(surface_fit == 2) {
							draw_surface_stretched_ext(_dat, x, y, w, h, color, _color_get_a(color));
							break;
						}
						
						var sw = surface_get_width(_dat);
						var sh = surface_get_height(_dat);
						var ss = surface_fit? max(w / sw, h / sh) : min(w / sw, h / sh);
						var sww = sw * ss;
						var shh = sh * ss;
						
						var tx = x;
						var ty = y;
						
						switch(halign) {
							case fa_left   : tx = x;                   break;
							case fa_center : tx = x + w / 2 - sww / 2; break;
							case fa_right :  tx = x + w - sww;         break;
						}
						
						switch(valign) {
							case fa_left   : ty = y;                   break;
							case fa_center : ty = y + h / 2 - shh / 2; break;
							case fa_right :  ty = y + h - shh;         break;
						}
						
						var scis = gpu_get_scissor();
						gpu_set_scissor(x,y,w,h);
						draw_surface_ext_safe(_dat, tx, ty, ss, ss, 0, color, _color_get_a(color));
						gpu_set_scissor(scis);
						break;
						
					default :
						var tx = x;
						var ty = y;
						
						switch(halign) {
							case fa_left   : tx = x;         break;
							case fa_center : tx = x + w / 2; break;
							case fa_right :  tx = x + w;     break;
						}
						
						switch(valign) {
							case fa_left   : ty = y;         break;
							case fa_center : ty = y + h / 2; break;
							case fa_right :  ty = y + h;     break;
						}
						
						draw_set_text(_font, halign, valign, color, _color_get_a(color));
						draw_text(tx, ty, string(_dat));
						draw_set_alpha(1);
				} 
				
			} else {
				var _param = new widgetParam(x, y, w, h, _dat, _junc.display_data, _m, rx, ry)	
					.setFont(_font)
					.setHalign(halign)
					.setValign(valign)
					.setColor(color)
				editWidget.drawParam(_param);
			}
		}
		
		var _hov = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		if(_hov) panel.hovering_element = self;
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {
		_m.dataOnly    = dataOnly;
		_m.font        = font;
		_m.halign      = halign;
		_m.valign      = valign;
		_m.color       = color;
		_m.surface_fit = surface_fit;
		
		var _junc = getJunction();
		_m.node_id = _junc? _junc.node.node_id : "";
		_m.junc_id = _junc? _junc.index : 0;
		
		return _m;
	}
	
	static doDeserialize = function(_m) { 
		node_id = _m.node_id;
		junc_id = _m.junc_id;
		
		dataOnly    = _m[$ "dataOnly"]    ?? dataOnly;
		font        = _m[$ "font"]        ?? font;
		halign      = _m[$ "halign"]      ?? halign;
		valign      = _m[$ "valign"]      ?? valign;
		color       = _m[$ "color"]       ?? color;
		surface_fit = _m[$ "surface_fit"] ?? surface_fit;
		
		return self;
	}
}