enum COLLECTION_TAG {
	group = 1,
	loop = 2
}

function groupNodes(nodeArray, _group = noone, record = true, check_connect = true) {
	#region check inline
		var _ctx_nodes = [];
	
		for(var i = 0; i < array_length(nodeArray); i++) { 
			var node = nodeArray[i];
			var ctx  = node.inline_context;
		
			if(ctx == noone) continue;
			array_push_unique(_ctx_nodes, ctx);
			
			for( var k = 0, n = array_length(ctx.nodes); k < n; k++ ) {
				if(array_exists(nodeArray, ctx.nodes[k])) continue;
				
				noti_warning("Grouping incomplete inline group is not allowed.");
				return;
			}
		} 
	#endregion
	
	UNDO_HOLDING = true;
	
	if(_group == noone) {
		var cx = 0;
		var cy = 0;
		for(var i = 0; i < array_length(nodeArray); i++) {
			var _node = nodeArray[i];
			cx += _node.x;
			cy += _node.y;
		}
		
		cx = value_snap(cx / array_length(nodeArray), 32);
		cy = value_snap(cy / array_length(nodeArray), 32);
		
		_group = new Node_Group(cx, cy, PANEL_GRAPH.getCurrentContext());
	}
	
	var _content = [];
	
	for(var i = 0; i < array_length(nodeArray); i++) {
		_group.add(nodeArray[i]);
		_content[i] = nodeArray[i];
	}
	
	for( var i = 0, n = array_length(_ctx_nodes); i < n; i++ ) {
		_group.add(_ctx_nodes[i]);
		_content[i] = _ctx_nodes[i];
	}
	
	if(check_connect) { // IO creation
		var _io = { inputs: {}, outputs: {}, map: {} };
		
		for(var i = 0; i < array_length(nodeArray); i++)
			nodeArray[i].checkConnectGroup(_io);
		
		var _in    = _io.inputs;
		var _inKey = struct_get_names(_in);
		var _x, _y, m;
			
		for( var i = 0, n = array_length(_inKey); i < n; i++ ) {
			var _frm = _io.map[$ _inKey[i]];
			var _tos = _in[$ _inKey[i]];
			
			_x = 0
			_y = 0;
			 m = array_length(_tos);
			
			for( var j = 0; j < m; j++ ) {
				var _to = _tos[j];
				
				_x  = min(_x, _to.node.x);
				_y += _to.node.y;
			}
			
			_x = value_snap(_x - 64 - 128, 32);
			_y = value_snap(_y / m, 32);
			
			var _n  = new Node_Group_Input(_x, _y, _group);
			var _ti = array_find(GROUP_IO_TYPE_MAP, _frm.type);
			if(_ti >= 0) _n.inputs[2].setValue(_ti);
			
			_n.onValueUpdate(0);
			_n.inParent.setFrom(_frm);
				
			for( var j = 0; j < m; j++ ) {
				var _to = _tos[j];
				_to.setFrom(_n.outputs[0]);
			}
		}
		
		var _ot    = _io.outputs;
		var _otKey = struct_get_names(_ot);
			
		for( var i = 0, n = array_length(_otKey); i < n; i++ ) {
			var _frm = _io.map[$ _otKey[i]];
			var _tos = _ot[$ _otKey[i]];
			
			_x = value_snap(_frm.node.x + _frm.node.w + 64, 32);
			_y = value_snap(_frm.node.y, 32);
			 m = array_length(_tos);
			
			var _n = new Node_Group_Output(_x, _y, _group);
			_n.inputs[0].setFrom(_frm);
			
			for( var j = 0; j < m; j++ ) {
				var _to = _tos[j];
				_to.setFrom(_n.outParent);
			}
		}
	}
	
	UNDO_HOLDING = false;	
	if(record) recordAction(ACTION_TYPE.group, _group, { content: _content });
	
	return _group;
}

function upgroupNode(collection, record = true) {
	UNDO_HOLDING  = true;
	var _content  = [], _deleted = [];
	var _node_arr = collection.getNodeList();
	var _conn_to  = collection.getJunctionTos();
	
	var _cx = 0, _cy = 0;
	var _nn = 0;
	
	for (var i = 0, n = array_length(_node_arr); i < n; i++) {
		var _node = _node_arr[i];
		if(!_node.selectable) continue;
		
		_cx += _node.x;
		_cy += _node.y;
		_nn++;
	}
	
	if(_nn) {
		_cx = collection.x - _cx / _nn;
		_cy = collection.y - _cy / _nn;
	}
	
	for (var i = array_length(_node_arr) - 1; i >= 0; i--) {
		var remNode    = _node_arr[i];
			remNode.x += _cx;
			remNode.y += _cy;
		
		if(remNode.destroy_when_upgroup) {
			var _vto = remNode.getJunctionTos();
			array_push(_deleted, { node: remNode, value_to : _vto });
		} else
			array_push(_content, remNode);
			
		collection.remove(remNode);
	}
	
	collection.destroy();
	UNDO_HOLDING = false;
	
	if(!record) return;
	
	recordAction(ACTION_TYPE.ungroup, collection, { 
		content :   _content,
		deleted :   _deleted,
		connectTo : _conn_to,
	});
}

function Node_Collection(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 
	nodes       = [];
	node_length = 0;
	
	ungroupable			= true;
	auto_render_time	= false;
	combine_render_time = true;
	previewable         = true;
	
	reset_all_child 	= false;
	isInstancer			= false;
	instanceBase		= noone;
	
	input_display_list_def = [];
	custom_input_index     = 0;
	custom_output_index    = 0;
	
	metadata = new MetaDataManager();
	
	group_input_display_list		= [];
	group_output_display_list		= [];
	attributes.input_display_list   = [];
	attributes.output_display_list  = [];
	attributes.lock_input           = false;
	
	managedRenderOrder = false;
	
	skipDefault();
	
	__dummy_input = nodeValue("Add to group", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0);
	__dummy_input.setDummy(function() /*=>*/ { var input = nodeBuild("Node_Group_Input", 0, 0, self); return input.inParent; }, function(_junc) /*=>*/ { _junc.from.destroy() } );
	
	__dummy_input.onSetFrom = function(juncFrom) {
		array_remove(juncFrom.value_to, __dummy_input);
		__dummy_input.value_from = noone;
		
		var input = nodeBuild("Node_Group_Input", 0, 0, self);
		var _type = juncFrom.type;
		var _tind = array_find(GROUP_IO_TYPE_MAP, _type);
		
		input.attributes.inherit_type = false;
		if(_tind != -1) input.inputs[2].setValue(_tind);
			
		input.inParent.setFrom(juncFrom);
		
		if(onNewInputFromGraph != noone) onNewInputFromGraph(juncFrom);
	}
	
	onNewInputFromGraph = noone;
	
	/////========== Attributes ===========
	
	attribute_surface_depth();
	attribute_interpolation();
	attribute_oversample();
	
	tool_node = noone;
	draw_input_overlay = true;
	
	array_push(attributeEditors, "Group IO");
	array_push(attributeEditors, ["Lock Input",          function() /*=>*/ {return attributes.lock_input}, new checkBox(function() /*=>*/ { attributes.lock_input = !attributes.lock_input   }) ]);
	array_push(attributeEditors, ["Edit Input Display",  function() /*=>*/ {return 0}, button(function() /*=>*/ { dialogCall(o_dialog_group_input_order).setNode(self, CONNECT_TYPE.input);  }) ]);
	array_push(attributeEditors, ["Edit Output Display", function() /*=>*/ {return 0}, button(function() /*=>*/ { dialogCall(o_dialog_group_input_order).setNode(self, CONNECT_TYPE.output); }) ]);
	
	/////========== INSPECTOR ===========
	
	hasInsp1 = false;
	insp1UpdateTooltip   = __txtx("panel_inspector_execute", "Execute node contents");
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	hasInsp2 = false;
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static inspector1Update    = function() { onInspector1Update(); }
	static onInspector1Update  = function() { array_foreach(NodeListSort(nodes), function(n) { if(n.hasInspector1Update()) n.inspector1Update(); }); }
	static hasInspector1Update = function() { INLINE return hasInsp1; }
	
	static inspector2Update    = function() { onInspector2Update(); }
	static onInspector2Update  = function() { array_foreach(NodeListSort(nodes), function(n) { if(n.hasInspector2Update()) n.inspector2Update(); }); }
	static hasInspector2Update = function() { INLINE return hasInsp2; }
	
	/////============ GROUP =============
	
	will_refresh = false;
	static refreshNodes = function() {
		will_refresh = false; 
		
		hasInsp1 = false;
		hasInsp2 = false;
		
		node_length  = array_length(nodes);
		
		var i = 0;
		repeat(node_length) {
			hasInsp1 |= nodes[i].hasInspector1Update();
			hasInsp2 |= nodes[i].hasInspector2Update();
			
			i++;
		}
		
	}
	
	static getNodeBase = function() { return instanceBase == noone?  self : instanceBase.getNodeBase(); }
	static getNodeList = function() { return instanceBase == noone? nodes : instanceBase.getNodeList(); }
	
	static exitGroup = function() {}
	
	static onAdd = function(_node) {}
	static add = function(_node) {
		array_push(getNodeList(), _node);
		var list = _node.group == noone? PANEL_GRAPH.nodes_list : _node.group.getNodeList();
		array_remove(list, _node);
		
		recordAction(ACTION_TYPE.group_added, self, _node);
		_node.group = self;
		_node.checkGroup();
		
		will_refresh = true;
		node_length  = array_length(nodes);
		
		onAdd(_node);
	}
	
	static onRemove = function(_node) {}
	static remove = function(_node) {
		var _hide = _node.destroy_when_upgroup;
		
		if(!_hide) {
			var node_list = getNodeList();
			var list = group == noone? PANEL_GRAPH.nodes_list : group.getNodeList();
			
			array_remove(node_list, _node);
			array_push(list, _node);
		}
		
		recordAction(ACTION_TYPE.group_removed, self, _node);
		
		if(struct_has(_node, "onUngroup"))
			_node.onUngroup();
			
		if(_hide) _node.disable();
		else      _node.group = group;
		_node.checkGroup();
		
		will_refresh = true;
		node_length  = array_length(nodes);
		onRemove(_node);
	}
	
	/////============= STEP ==============
	
	static stepBegin = function() {
		dummy_input = attributes.lock_input? noone : __dummy_input;
		
		if(will_refresh) refreshNodes();
		doStepBegin(); 
	}
	
	static step = function() {
		if(combine_render_time) {
			render_time = 0;
			array_foreach(getNodeList(), function(node) { render_time += node.render_time; });
		}
		
		onStep();
	}
	
	static onStep = function() {}
	
	/////========== JUNCTIONS ==========
	
	static getOutputNodes = function() {
		var _nodes = [];
		for( var i = custom_output_index; i < array_length(outputs); i++ ) {
			var _junc = outputs[i];
			
			for( var j = 0; j < array_length(_junc.value_to); j++ ) {
				var _to = _junc.value_to[j];
				if(_to.value_from != _junc) continue;
				array_push_unique(_nodes, _to.node);
			}
		}
		return _nodes;
	}
	
	static preConnect = function() {
		sortIO();
		deserialize(load_map, load_scale);
	}
	
	static sortIO = function() {
		var _ilen = array_length(inputs);
		var _iarr = attributes.input_display_list;
		
		for( var i = custom_input_index; i < _ilen; i++ ) 
			array_push_unique(_iarr, i);
			
		for( var i = array_length(_iarr) - 1; i >= 0; i-- ) {
			if(is_array(_iarr[i])) continue;
			if(_iarr[i] >= _ilen) array_delete(_iarr, i, 1);
		}
		
		input_display_list = array_merge(group_input_display_list, attributes.input_display_list);
		
		///////////////////////////////////////////////////////////////////
		
		var _olen = array_length(outputs);
		var _oarr = attributes.output_display_list;
		
		for( var i = custom_output_index; i < _olen; i++ ) 
			array_push_unique(_oarr, i);
		for( var i = array_length(_oarr) - 1; i >= 0; i-- ) {
			if(is_array(_oarr[i])) continue;
			if(_oarr[i] >= _olen) array_delete(_oarr, i, 1);
		}
		
		output_display_list = array_merge(group_output_display_list, attributes.output_display_list);
		
		///////////////////////////////////////////////////////////////////
		
		refreshNodeDisplay();
	}
	
	static preConnect = function() { 
		instanceBase = GetAppendID(struct_try_get(load_map, "instance_base", noone));
		
		sortIO();
		applyDeserialize();
	}
	
	/////========== RENDERING ===========
	
	static getNextNodes = function() { return getNextNodesInternal(); } 
	
	static getNextNodesInternal = function() { //get node inside the group
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"→→→→→ Call get next node from group: {INAME}");
		
		var _nodes = [];
		if(isRenderActive()) {
			var allReady = true;
			for(var i = custom_input_index; i < array_length(inputs); i++) {
				var _in = inputs[i].from;
				if(!_in.isRenderActive()) continue;
			
				if(!_in.isRenderable()) {
					LOG_IF(global.FLAG.render == 1, $"Node {_in.internalName} not ready, loop skip.");
					LOG_BLOCK_END();
					return [];
				}
			}
		
			_nodes = __nodeLeafList(getNodeList());
		}
		
		LOG_BLOCK_END();
		return _nodes;
	}
	
	static getNextNodesExternal = function() { //get node connected to the parent object
		LOG_IF(global.FLAG.render == 1, $"Checking next node external for {INAME}");
		LOG_BLOCK_START();
		
		var nextNodes = [];
		for( var i = 0; i < array_length(outputs); i++ ) {
			var _ot = outputs[i];
			if(!_ot.forward) continue;
			if(_ot.type == VALUE_TYPE.node) continue;
				
			var _tos = _ot.getJunctionTo();
			for( var j = 0, n = array_length(_tos); j < n; j++ ) {
				var _to   = _tos[j];
				var _node = _to.node;
				
				LOG_IF(global.FLAG.render == 1, $"Checking node {_node.internalName} : {_node.isRenderable()}");
				if(!_node.isRenderable()) continue;
				
				array_push(nextNodes, _to.node);
			}
		}
		LOG_BLOCK_END();
		
		return nextNodes;
	}
	
	static clearTopoSorted = function() { INLINE topoSorted = false; for( var i = 0, n = array_length(nodes); i < n; i++ ) { nodes[i].clearTopoSorted(); } }
	
	static setRenderStatus = function(result) {
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"Set render status for {INAME} : {result}");
		rendered = result;
		if(rendered == result) {
			LOG_BLOCK_END();
			return;
		}
		
		if(result)
		for( var i = custom_output_index, n = array_length(outputs); i < n; i++ ) {
			var _o = outputs[i];
			if(_o.from.rendered) continue;
				
			LOG_IF(global.FLAG.render == 1, $"Set fail because {_o.from.internalName} is not rendered.");
			rendered = false;
			break;
		}
		
		if(rendered) exitGroup();
		
		if(!result && group != noone) 
			group.setRenderStatus(result);
		LOG_BLOCK_END();
	}
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) {
		if(update_on_frame) return true;
		if(!rendered)       return true;
		
		for( var i = custom_input_index, n = array_length(inputs); i < n; i++ ) 
			if(inputs[i].isActiveDynamic(frame) || !inputs[i].from.rendered) return true;
		
		return false;
	}
	
	static resetRender = function(_clearCache = false) {
		LOG_LINE_IF(global.FLAG.render == 1, $"Reset Render for group {INAME}");
		
		setRenderStatus(false);
		if(_clearCache) clearInputCache();
		
		if(reset_all_child)
		for(var i = 0, n = array_length(nodes); i < n; i++)
			nodes[i].resetRender(_clearCache);
	}
	
	/////============= DRAW =============
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!draw_input_overlay) return;
		
		for(var i = custom_input_index; i < array_length(inputs); i++) {
			var _in   = inputs[i];
			var _show = _in.from.getInputData(6);
			
			if(!_show) continue;
			var _hov = _in.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			if(_hov != undefined) active &= !_hov;
		}
	}
	
	static onPreDraw = function(_x, _y, _s, _iny, _outy) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		__dummy_input.x = xx;
		__dummy_input.y = _iny;
		
		var _hv = PANEL_GRAPH.pHOVER && PANEL_GRAPH.node_hovering == self && (!PREFERENCES.panel_graph_group_require_shift || key_mod_press(SHIFT));
		bg_spr_add = 0.1 + (0.1 * _hv);
	}
	
	static drawNodeBase = function(xx, yy, _s) {
		var _hv = PANEL_GRAPH.pHOVER && PANEL_GRAPH.node_hovering == self && (!PREFERENCES.panel_graph_group_require_shift || key_mod_press(SHIFT));
		var _aa = (.25 + .5 * renderActive) * (.25 + .75 * isHighlightingInGraph()) + _hv * 0.1;
		
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, getColor(), _aa);
	}
	
	static drawNodeOverlay = function(xx, yy, _mx, _my, _s) {
		if(_s < 0.75) return;
		
		var _bx = (xx + w * _s) - 10;
		var _by = previewable? (yy + h * _s) - 10 : yy + h / 2 * _s;
		
		var _hv = PANEL_GRAPH.pHOVER && PANEL_GRAPH.node_hovering == self && PANEL_GRAPH._value_focus == noone;
		    _hv &= point_in_circle(_mx, _my, _bx, _by, 8);
		
		draw_sprite_ext_add(THEME.animate_node_go, 0, _bx, _by, 1, 1, 0, _hv? COLORS._main_accent : c_white, 0.3 + _hv * 0.7);
		
		if(_hv && PANEL_GRAPH.pFOCUS && mouse_press(mb_left))
			panelSetContext(PANEL_GRAPH);
	}
	
	static getTool = function() {
		for(var i = 0, n = array_length(nodes); i < n; i++) { 
			var _node = nodes[i];
			if(!_node.active) continue;
			if(_node.isTool) return _node.getTool();
		}
		
		return self;
	} 
	
	/////============ PREVIEW ============
	
	static getGraphPreviewSurface = function() { 
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			if(!nodes[i].active) continue;
			if(is_instanceof(nodes[i], Node_Group_Thumbnail))
				return nodes[i].inputs[0].getValue();
		}
		
		var _oj = array_safe_get(outputs, preview_channel);
		if(!is_instanceof(_oj, NodeValue)) return noone;
		
		if(_oj.from == noone) return noone;
		var _fr = array_safe_get(_oj.from.inputs, 0);
		return _fr.value_from == noone? noone : _fr.value_from.node.getGraphPreviewSurface();
	}
	
	function getPreviewingNode() {
		var _oj = array_safe_get(outputs, preview_channel, noone);
		if(_oj == noone) return self;
		
		switch(_oj.type) {
			case VALUE_TYPE.d3Mesh   : 
			case VALUE_TYPE.d3Camera : 
			case VALUE_TYPE.d3Light  : 
			case VALUE_TYPE.d3Scene  : 
			case VALUE_TYPE.d3object : 
			case VALUE_TYPE.sdf : 
				var _fr = _oj.from.inputs[0];
				return _fr.value_from == noone? self : _fr.value_from.node;
		}
		
		return self;
	}
	
	/////============= CACHE =============
	
	static clearCache = function() { array_foreach(getNodeList(), function(node) /*=>*/ { node.clearCache(); }); }
	
	/////========== INSTANCING ===========
	
	static setInstance   = function(node) { instanceBase = node; }
	static resetInstance = function() { instanceBase = noone; }
	
	/////========= SERIALIZATION =========
	
	static attributeSerialize = function() {
		sortIO();
		
		var _attr = {};
		
		_attr.custom_input_list = [];
		for( var i = custom_input_index, n = array_length(inputs); i < n; i++ ) {
			if(struct_has(inputs[i], "from"))
				array_push(_attr.custom_input_list, inputs[i].from.node_id);
		}
		
		_attr.custom_output_list = [];
		for( var i = custom_output_index, n = array_length(outputs); i < n; i++ ) {
			if(struct_has(outputs[i], "from"))
				array_push(_attr.custom_output_list , outputs[i].from.node_id);
		}
		
		return _attr;
	}
	
	static preApplyDeserialize = function() {
		var attr = attributes;
		
		if(LOADING_VERSION < 11690) {
			var pr = ds_priority_create();
			
			for( var i = array_length(inputs) - 1; i >= custom_input_index; i-- ) {
				if(!struct_has(inputs[i].attributes, "input_priority")) continue;
				
				var _pri = inputs[i].attributes.input_priority;
				ds_priority_add(pr, inputs[i], _pri);
				array_delete(inputs, i, 1);
			}
			
			repeat(ds_priority_size(pr)) array_push(inputs, ds_priority_delete_min(pr));
			
			for( var i = array_length(outputs) - 1; i >= custom_output_index; i-- ) {
				if(!struct_has(outputs[i].attributes, "output_priority")) continue;
				
				var _pri = outputs[i].attributes.output_priority;
				ds_priority_add(pr, outputs[i], _pri);
				array_delete(outputs, i, 1);
			}
			
			repeat(ds_priority_size(pr)) array_push(outputs, ds_priority_delete_min(pr));
			
			ds_priority_destroy(pr);
			return;
		}
		
		if(struct_has(attr, "custom_input_list")) {
			var _ilist = attr.custom_input_list;
			var _inarr = {};
			var _dilst = [];
			
			if(APPENDING)
			for( var i = 0, n = array_length(_ilist); i < n; i++ ) 
				_ilist[i] = ds_map_try_get(APPEND_MAP, _ilist[i], _ilist[i]);
			
			for( var i = array_length(inputs) - 1; i >= custom_input_index; i-- ) {
				if(!struct_has(inputs[i], "from")) continue;
				
				var _frNode = inputs[i].from.node_id;
				if(array_exists(_ilist, _frNode)) {
					_inarr[$ _frNode] = inputs[i];
					array_delete(inputs, i, 1);
				}
			}
			
			for( var i = 0, n = array_length(_ilist); i < n; i++ ) {
				if(!struct_has(_inarr, _ilist[i])) continue;
				
				var _inJunc = _inarr[$ _ilist[i]];
				_inJunc.index = array_length(inputs);
				array_push(inputs, _inJunc);
			}
			
		}
		
		if(struct_has(attr, "custom_output_list")) {
			var _ilist = attr.custom_output_list;
			var _inarr = {};
			
			if(APPENDING)
			for( var i = 0, n = array_length(_ilist); i < n; i++ ) 
				_ilist[i] = ds_map_try_get(APPEND_MAP, _ilist[i], _ilist[i]);
			
			for( var i = array_length(outputs) - 1; i >= custom_output_index; i-- ) {
				if(!struct_has(outputs[i], "from")) continue;
				
				var _frNode = outputs[i].from.node_id;
				if(array_exists(_ilist, _frNode)) {
					_inarr[$ _frNode] = outputs[i];
					array_delete(outputs, i, 1);
				}
			}
			
			for( var i = 0, n = array_length(_ilist); i < n; i++ ) {
				if(!struct_has(_inarr, _ilist[i])) continue;
				
				var _outJunc = _inarr[$ _ilist[i]];
				_outJunc.index = array_length(outputs);
				array_push(outputs, _outJunc);
			}
			
		}
		
	}
	
	static processSerialize = function(_map) {
		_map.instance_base	= instanceBase? instanceBase.node_id : noone;
	}
	
	/////============ ACTION ============
	
	static onClone = function(_newNode, target = PANEL_GRAPH.getCurrentContext()) {
		if(instanceBase != noone) {
			_newNode.instanceBase = instanceBase;
			return;
		}
		
		var dups = ds_list_create();
		
		for(var i = 0, n = array_length(nodes); i < n; i++) { 
			var _node = nodes[i];
			var _cnode = _node.clone(target);
			ds_list_add(dups, _cnode);
			
			APPEND_MAP[? _node.node_id] = _cnode.node_id;
		}
		
		APPENDING = true;
		for(var i = 0; i < ds_list_size(dups); i++) {
			var _node = dups[| i];
			_node.connect();
		}
		APPENDING = false;
		
		ds_list_destroy(dups);
	}
	
	static enable = function() {
		active = true;
		array_foreach(getNodeList(), function(node) { node.enable(); });
	}
	
	static disable = function() {
		active = false;
		array_foreach(getNodeList(), function(node) { node.disable(); });
	}
	
	function onDoubleClick(panel) {
		if(PREFERENCES.panel_graph_group_require_shift && !key_mod_press(SHIFT)) return false;
		
		panelSetContext(panel);
		
		if(ononDoubleClick != noone)
			ononDoubleClick(panel);
			
		return true;
	}
	
	static panelSetContext = function(panel) {
		__temp_panel = panel;
		
		if(PREFERENCES.graph_open_group_in_tab) 
			run_in(1, function() { __temp_panel.openGroupTab(self) });
		else
			panel.addContext(self);
	}
	
	static ononDoubleClick = noone;
	
	static enable = function() {
		active = true; timeline_item.active = true;
		for( var i = 0, n = array_length(nodes); i < n; i++ ) nodes[i].enable();
	}
	
	static disable = function() {
		active = false; timeline_item.active = false;
		for( var i = 0, n = array_length(nodes); i < n; i++ ) nodes[i].disable();
	}
	
}