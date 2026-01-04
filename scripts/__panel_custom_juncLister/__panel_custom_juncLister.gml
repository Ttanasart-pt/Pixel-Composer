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