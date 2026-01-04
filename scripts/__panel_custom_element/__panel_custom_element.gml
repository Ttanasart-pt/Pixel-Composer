function Panel_Custom_Element(_data) constructor {
	data = _data;
	type = "element";
	name = "Element";
	icon = THEME.panel_icon_element_frame;
	
	contents       = [];
	is_container   = false;
	modifyContent  = true;
	outline_expand = true;
	mouseEvent     = true;
	
	outline_h = ui(24);
	
	#region position
		pbBox = new __pbBox();
		pbBox.anchor_x_type = PB_AXIS_ANCHOR.minimum;
		pbBox.anchor_y_type = PB_AXIS_ANCHOR.minimum;
		pbBox.anchor_w = 64; pbBox.anchor_w_fract = false;
		pbBox.anchor_h = 64; pbBox.anchor_h_fract = false;
		bbox = [0,0,1,1];
		
		x = 0;
		y = 0;
		w = 1;
		h = 1;
		
		rx = 0;
		ry = 0;
	#endregion
	
	parent    = undefined;
	hover     = false;
	focus     = false;
	draggable = true;
	elementHover = false;
	
	editors = [
		[ "Main", false ], 
		Simple_Editor("Name",        textBox_Text( function(t) /*=>*/ { name = t; } ), function() /*=>*/ {return name}, function(t) /*=>*/ { name = t; }), 
		Simple_Editor("Position",    new pbBoxBox(), function() /*=>*/ {return pbBox}, function(v) /*=>*/ { pbBox = v; }), 
		Simple_Editor("Mouse Event", new checkBox(function() /*=>*/ { mouseEvent = !mouseEvent; }), function() /*=>*/ {return mouseEvent}, function(v) /*=>*/ { mouseEvent = v; }), 
	];
	
	////- Contents
	
	static addContent = function(cont) {
		array_push(contents, cont);
		cont.parent = self;
	}
	
	////- BBOX
	
	static setSize = function(_pBbox, _rx, _ry) {
		bbox = pbBox.setBase(_pBbox).getBBOX(bbox);
		x  = bbox[0];
		y  = bbox[1];
		w  = bbox[2] - bbox[0];
		h  = bbox[3] - bbox[1];
		
		rx = _rx;
		ry = _ry;
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].setSize(bbox, _rx, _ry);
	}
	
	static checkMouse = function(panel, _m) {
		elementHover = panel._hovering_element == self;
		
		var _hov = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		if(_hov) {
			if(mouseEvent) panel.hovering_element = self;
			
			if(is_container || key_mod_press(CTRL)) 
				panel.hovering_frame = self;
		}
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].checkMouse(panel, _m);
	}
	
	////- Draw
	
	static setFocusHover = function(_focus, _hover) {
		focus = _focus;
		hover = _hover;
		for( var i = 0, n = array_length(contents); i < n; i++ ) 
			contents[i].setFocusHover(_focus, _hover);
		return self;
	}
	
	static draw   = function(panel, _m) {}
	static doDraw = function(panel, _m) {
		draw(panel, _m);
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].doDraw(panel, _m);
	}
	
	static drawBox = function(panel) {
		var aa = .25 + .5 * (panel._hovering_element == self);
		draw_sprite_stretched_add(THEME.ui_panel, 1, x, y, w, h, COLORS._main_icon, aa);
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) 
			contents[i].drawBox(panel);
	}
	
	static drawOutlineContent = function(_depth, _panel, _x, _y, _w, _m, hov) { 
		var lh = outline_h;
		
		if(modifyContent) {
			if(_panel.element_adding) {
				if(_panel._hovering_frame == self)
					draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y - lh, _w, lh, COLORS._main_accent);
					
				if(hov) _panel.hovering_frame = self;
			}
			
			if(_panel.outline_drag && _panel.outline_drag != _panel._hovering_element) {
				var hovIn = point_in_rectangle(_m[0], _m[1], _x + _w - ui(32), _y - lh, _x + _w, _y);
				draw_sprite_ui_uniform(THEME.icon_default, 0, _x + _w - ui(16), _y - lh / 2, .75, 
					hovIn? COLORS._main_accent : COLORS._main_icon, .5 + .5 * hovIn);
				
				if(hovIn) _panel.outline_drag_frame = self;
			}
		}
		
		if(!outline_expand) return 0;
		
		var _h  = 0;
		var _y0 = _y;
		var _y1 = _y;
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var con = contents[i];
			
			var hh = con.drawOutline(_depth + 1, _panel, _x + ui(16), _y, _w - ui(16), _m);
			_h += hh;
			_y += hh;
			if(i < n - 1) _y1 = _y;
		}
		
		if(n) {
			draw_set_color(CDEF.main_dark);
			draw_line(_x + ui(12), _y0, _x + ui(12), _y1 + lh / 2);
		}
		
		return _h;
	}
		
	static drawOutline = function(_depth, _panel, _x, _y, _w, _m) {
		var lh = outline_h;
		var _h = lh;
		var yc = _y + lh / 2;
		
		if(_depth) {
			draw_set_color(CDEF.main_dark);
			draw_line(_x - ui(4), yc, _x, yc);
		}
		
		draw_sprite_ui_uniform(icon, 0, _x + ui(12), yc, .25, c_white);
		var ttx = _x + ui(24);
		if(is_container || !array_empty(contents)) {
			var hov = _panel.pHOVER && point_in_circle(_m[0], _m[1], _x + ui(24+8), yc, lh / 2);
			draw_sprite_ui_uniform(THEME.arrow, outline_expand * 3, _x + ui(24+8), yc + outline_expand * ui(1), .75, c_white, .5 + hov * .5);
			if(hov && mouse_lpress(_panel.pFOCUS))
				outline_expand = !outline_expand;
			ttx += ui(16);
		}
		
		draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
		draw_text_add(ttx, yc, name);
		
		if(_panel.element_adding == undefined && _panel.element_selecting == self)
			draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y, _w, lh, COLORS._main_accent);
		
		var hov = _panel.pHOVER && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + lh - 1);
		if(hov) {
			draw_sprite_stretched_add(THEME.box_r2, 1, _x, _y, _w, lh, COLORS._main_icon, .3);
			_panel.hovering_element  = self;
			_panel.outline_hover     = self;
			_panel.outline_drag_side = _m[1] > yc? 1 : 0;
			
			if(_panel.outline_drag && _panel.outline_drag != self) {
				var ly = _panel.outline_drag_side? _y + lh : _y;
				draw_set_color(COLORS._main_accent);
				draw_line_round(_x, ly, _x + _w, ly, 2);
			}
			
			if(_panel.element_adding && hov)
				_panel.hovering_frame = parent;
			
			if(mouse_lpress(_panel.pFOCUS)) {
				_panel.element_selecting = self;
				if(draggable) _panel.outline_drag = self;
			}
		}
		
		_y += lh;
		_h += drawOutlineContent(_depth, _panel, _x, _y, _w, _m, hov);
		
		return _h;
	}
	
	////- Actions
	
	static postBuild = function() {}
	
	static remove = function() {
		if(parent == undefined) return;
		
		array_remove(parent.contents, self);
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {}
	static serialize   = function() {
		var _m = {};
		
		_m.box  = pbBox.serialize().uiScale(true);
		_m.name = name;
		_m.type = type;
		_m.draggable  = draggable;
		_m.mouseEvent = mouseEvent;
		
		_m.contents = array_map(contents, function(c) /*=>*/ {return c.serialize()});
		
		doSerialize(_m);
		return _m;
	}
	
	static doDeserialize = function(_m) {}
	static deserialize   = function(_m) { 
		var _ele = undefined;
		switch(_m.type) {
			case "frame":      _ele = new Panel_Custom_Frame(data).doDeserialize(_m);       break;
			case "framesplit": _ele = new Panel_Custom_Frame_Split(data).doDeserialize(_m); break;
			
			case "input":      _ele = new Panel_Custom_Node_Input(data).doDeserialize(_m);  break;
			case "output":     _ele = new Panel_Custom_Node_Output(data).doDeserialize(_m); break;
			
			case "button":     _ele = new Panel_Custom_Button(data).doDeserialize(_m);      break;
			case "choices":    _ele = new Panel_Custom_Choices(data).doDeserialize(_m);     break;
			case "color":      _ele = new Panel_Custom_Color(data).doDeserialize(_m);       break;
			case "knob":       _ele = new Panel_Custom_Knob(data).doDeserialize(_m);        break;
			case "slider":     _ele = new Panel_Custom_Slider(data).doDeserialize(_m);      break;
			case "text":       _ele = new Panel_Custom_Text(data).doDeserialize(_m);        break;
			case "textbox":    _ele = new Panel_Custom_Textbox(data).doDeserialize(_m);     break;
		}
		
		if(_ele == undefined) return self;
		
		_ele.pbBox.deserialize(_m.box).uiScale(false);
		_ele.name       = _m[$ "name"]       ?? name;
		_ele.draggable  = _m[$ "draggable"]  ?? draggable;
		_ele.mouseEvent = _m[$ "mouseEvent"] ?? mouseEvent;
		
		if(has(_m, "contents"))
		for( var i = 0, n = array_length(_m.contents); i < n; i++ )
			_ele.addContent(new Panel_Custom_Element(data).deserialize(_m.contents[i]));
		
		return _ele;
	}
	
	static toString = function() { return $"[Custom Element {instanceof(self)}] {name}"; }
}

function   Simple_Editor(_name, _widget, _getter, _setter) { return new __Simple_Editor(_name, _widget, _getter, _setter); }
function __Simple_Editor(_name, _widget, _getter, _setter) constructor {
	name       = _name;   static setName = function(n) /*=>*/ { name = n; return self; }
	editWidget = _widget;
	getter     = _getter;
	setter     = _setter;
}

function JuncLister(_data, _name, _type = CONNECT_TYPE.input, _widget = false) constructor {
	data = _data;
	name = _name;
	type = _type;
	mode = "node";
	
	node_id  = undefined;
	junc_id  = undefined;
	
	node     = undefined;
	junction = undefined;
	
	getWidget  = _widget;
	editWidget = undefined;
	
	////- Editors
	
	node_selector   = Simple_Editor("Node", new scrollBoxFn(function() /*=>*/ {return getNodeList()}, function(i) /*=>*/ { 
		node     = nodeList[i]; 
		node_id  = undefined;
		junction = undefined; 
		
		if(is(node, Node)) {
			mode    = "node"
			node_id = node.node_id;
			
		} else if(is(node, IO_Redirect)) {
			mode    = "redir"
			node_id = node.uuid;
		}
	} ), 
		function() /*=>*/ {return node? node.getDisplayName() : ""}, function(n) /*=>*/ { node = n; });
	
	if(type == CONNECT_TYPE.input)
		junc_selector = Simple_Editor("Input", new scrollBoxFn(function() /*=>*/ {return getInputs()}, 
			function(i) /*=>*/ { setJunction(juncInList[i]); } ), function() /*=>*/ {return junction? junction.name : ""}, function(n) /*=>*/ { setJunction(n); });
	else 
		junc_selector = Simple_Editor("Output", new scrollBoxFn(function() /*=>*/ {return getOutputs()}, 
			function(i) /*=>*/ { setJunction(juncOutList[i]); } ), function() /*=>*/ {return junction? junction.name : ""}, function(n) /*=>*/ { setJunction(n); });
	
	static draw = function(wdx, wdy, wdw, wdh, _m, foc, hov, rx, ry) {
		if(mode == "node") {
			getJunction();
			
			var scw = wdw / 2 - ui(4);
			
			var _data  = node_selector.getter();
			var _param = new widgetParam(wdx, wdy, scw, wdh, _data, {}, _m, rx, ry).setFont(f_p4);
			node_selector.editWidget.setFocusHover(foc, hov);
			node_selector.editWidget.drawParam(_param);
			
			var _data  = junc_selector.getter();
			var _param = new widgetParam(wdx + scw + ui(4), wdy, scw, wdh, _data, {}, _m, rx, ry).setFont(f_p4);
			junc_selector.editWidget.setFocusHover(foc, hov);
			junc_selector.editWidget.drawParam(_param);
			
		} else if(mode == "redir") {
			getNode();
			
			var _data  = node_selector.getter();
			var _param = new widgetParam(wdx, wdy, wdw, wdh, _data, {}, _m, rx, ry).setFont(f_p4);
			node_selector.editWidget.setFocusHover(foc, hov);
			node_selector.editWidget.drawParam(_param);
			
		}
		
		return wdh;
	}
	
	////- Lister
	
	nodeList     = [];
	nodeListName = [];
	static getNodeList = function() {
		nodeList     = [];
		nodeListName = [];
		
		var _i = 0;
		
		nodeList[_i]     = undefined;
		nodeListName[_i] = "None";
		_i++;
		
		for( var i = 0, n = array_length(data.io_redirect); i < n; i++ ) {
			var _node = data.io_redirect[i];
			nodeList[_i]     = _node;
			nodeListName[_i] = _node.name;
			_i++;
		}
		
		nodeList[_i]     = -1;
		nodeListName[_i] = -1;
		_i++;
		
		for( var i = 0, n = array_length(PROJECT.allNodes); i < n; i++ ) {
			var _node = PROJECT.allNodes[i];
			nodeList[_i]     = _node;
			nodeListName[_i] = _node.getDisplayName();
			_i++;
		}
		
		return nodeListName;
	}
	
	juncOutList     = [];
	juncOutListName = [];
	static getOutputs = function() {
		if(node == undefined) return [];
		
		juncOutList     = [];
		juncOutListName = [];
		for( var i = 0, n = array_length(node.outputs); i < n; i++ ) {
			var _juncOut = node.outputs[i];
			juncOutList[i]     = _juncOut;
			juncOutListName[i] = _juncOut.name;
		}
		
		return juncOutListName;
	}
	
	juncInList     = [];
	juncInListName = [];
	static getInputs = function() {
		if(node == undefined) return [];
		
		juncInList     = [];
		juncInListName = [];
		for( var i = 0, n = array_length(node.inputs); i < n; i++ ) {
			var _juncIn = node.inputs[i];
			juncInList[i]     = _juncIn;
			juncInListName[i] = _juncIn.name;
		}
		
		return juncInListName;
	}
	
	////- Get Set
	
	static setJunction = function(_junc) {
		if(!is(_junc, NodeValue)) return self;
		
		node       = _junc.node;
		junction   = _junc;
		if(getWidget) editWidget = junction.editWidget.clone();
		
		node_id = _junc.node.node_id;
		junc_id = _junc.index;
		
		return self;
	}
	
	static getNode = function() {
		if(is(node, Node)) return node;
		if(node_id == undefined) return undefined;
		
		if(mode == "redir") {
			if(node_id == undefined) return junction;
			var _redir = data.io_redirect_map[$ node_id];
			if(_redir) node = _redir;
			return node;
		}
		
		var _node = PROJECT.getNodeFromID(node_id);
		if(_node) node = _node;
		return node;
	} 
	
	static getJunction = function(_depth = 0) {
		if(is(junction, NodeValue)) return junction;
		
		if(mode == "redir") {
			var _redir = getNode();
			if(!_redir) return junction;
			return _redir.getJunction(_depth + 1);
		}
		
		var _node = getNode();
		if(!_node) return junction;
		
		var _junc = array_safe_get_fast(type == CONNECT_TYPE.input? _node.inputs : _node.outputs, junc_id); 
		setJunction(_junc);
		
		return junction;
	}
	
	////- Serialize
	
	static serialize = function() {
		var _m = {};
		
		var _junc  = getJunction();
		_m.mode    = mode;
		_m.node_id = "";
		
		if(is(node, Node)) {
			_m.node_id = _junc? _junc.node.node_id : "";
			_m.junc_id = _junc? _junc.index : 0;
			
		} else if(is(node, IO_Redirect)) {
			_m.node_id = node.uuid;
		}
		
		return _m;
	}
	
	static deserialize = function(_m) { 
		mode    = _m[$ "mode"]    ?? mode;
		node_id = _m[$ "node_id"] ?? node_id;
		junc_id = _m[$ "junc_id"] ?? junc_id;
		
		return self;
	}
	
	static toString = function() { return $"{node_id}, {junc_id}" }
}