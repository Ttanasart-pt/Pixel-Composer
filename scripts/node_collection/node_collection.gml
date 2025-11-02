function Node_Collection(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 
	doUpdate = doUpdateLite;
	managedRenderOrder = false;
	skipDefault();
	
	#region group
		nodes       = [];
		node_length = 0;
		modifiable  = true;
		
		ungroupable			= true;
		auto_render_time	= false;
		combine_render_time = true;
		previewable         = true;
	
		isPure    = false;
		nodeTopo  = [];
		nodeTree  = noone;
		thumbnail = noone;
	
		reset_all_child = false;
		isInstancer		= false;
		
		metadata = new MetaDataManager();
		collPath = "";
		
		toolNode = undefined;
	#endregion
	
	#region io
		input_display_list_def = [];
		custom_input_index     = 0;
		custom_output_index    = 0;
		
		group_input_display_list		= [];
		group_output_display_list		= [];
		attributes.input_display_list   = [];
		attributes.output_display_list  = [];
	
		__dummy_input = nodeValue("Add to group", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0);
		__dummy_input.setDummy(function(juncFrom) /*=>*/ { 
			var input = nodeBuild("Node_Group_Input", 0, 0, self); 
			var _tind = array_find(GROUP_IO_TYPE_MAP, juncFrom.type);
			
			input.attributes.inherit_type = false;
			if(_tind != -1) input.inputs[2].setValue(_tind);
			
			return input.inParent; 
		}, function(_junc) /*=>*/ { _junc.from.destroy() } );
	#endregion
	
	////- Attributes
	
	attribute_surface_depth();
	attribute_interpolation();
	attribute_oversample();
	
	attributes.lock_input    = false;
	attributes.pure_function =  true;
	
	tool_node = noone;
	draw_input_overlay = true;
	
	array_push(attributeEditors, "Group");
	array_push(attributeEditors, ["Pure Function", function() /*=>*/ {return attributes.pure_function}, new checkBox(function() /*=>*/ {
		toggleAttribute("pure_function"); checkPureFunction(); }) ]);
		
	array_push(attributeEditors, ["Lock Input",          function() /*=>*/ {return attributes.lock_input}, new checkBox(function() /*=>*/ {return toggleAttribute("lock_input")})    ]);
	array_push(attributeEditors, ["Edit Input Display",  function() /*=>*/ {return 0}, button(function() /*=>*/ { dialogCall(o_dialog_group_input_order).setNode(self, CONNECT_TYPE.input);  }) ]);
	array_push(attributeEditors, ["Edit Output Display", function() /*=>*/ {return 0}, button(function() /*=>*/ { dialogCall(o_dialog_group_input_order).setNode(self, CONNECT_TYPE.output); }) ]);
	
	////- INSPECTOR
	
	hasInsp1 = false;
	setTrigger(1, __txtx("panel_inspector_execute", "Execute node contents"), [ THEME.sequence_control, 1, COLORS._main_value_positive ], function() /*=>*/ {
		array_foreach(NodeListSort(nodes, project), function(n) /*=>*/ { if(n.hasInspector1Update()) n.inspector1Update(); }); 
	});
	
	hasInsp2 = false;
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ], function() /*=>*/ { 
		array_foreach(NodeListSort(nodes, project), function(n) /*=>*/ { if(n.hasInspector2Update()) n.inspector2Update(); }); 
	});
	
	static hasInspector1Update = function() /*=>*/ {return hasInsp1};
	static hasInspector2Update = function() /*=>*/ {return hasInsp2};
	
	////- GROUP
	
	will_refresh = false;
	static refreshNodes = function() {
		will_refresh = false; 
		
		hasInsp1 = false;
		hasInsp2 = false;
		
		node_length  = array_length(nodes);
		checkPureFunction();
	}
	
	static checkPureFunction = function(updateTopo = true) {
		var p = attributes.pure_function;
		
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _node = nodes[i];
			hasInsp1 = hasInsp1 || _node.hasInspector1Update();
			hasInsp2 = hasInsp2 || _node.hasInspector2Update();
			
			p = p && !is(_node, Node_Collection_Inline) && !is(_node, Node_Collection);
			p = p && !_node.isAnimated();
			if(!p) break;
		}
		
		icon_blend = p? COLORS._main_value_positive : undefined;
		
		if(updateTopo || !isPure && p) nodeTopo = NodeListSort(nodes, project);
		isPure = p;
		
		// if(group) group.checkPureFunction(updateTopo);
	}
	
	static getNodeList = function() /*=>*/ {return nodes};
	
	static exitGroup = function() {}
	
	static onAdd = function(_node) /*=>*/ {}
	static add   = function(_node) {
		array_push(getNodeList(), _node);
		var list = _node.group == noone? project.nodes : _node.group.getNodeList();
		if(NOT_LOAD) array_remove(list, _node);
		
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
			var list = group == noone? project.nodes : group.getNodeList();
			
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
	
	////- STEP
	
	static stepBegin = function() {
		dummy_input = attributes.lock_input? noone : __dummy_input;
		
		if(will_refresh) refreshNodes();
		
		if(toRefreshNodeDisplay) {
			refreshNodeDisplay();
			toRefreshNodeDisplay = false;
		}
	}
	
	////- JUNCTIONS
	
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
		if(instanceBase != noone) {
			attributes.input_display_list  = array_clone(instanceBase.attributes.input_display_list);
			attributes.output_display_list = array_clone(instanceBase.attributes.output_display_list);
		} 
		
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
		sortIO();
		applyDeserialize();
	}
	
	////- RENDERING
	
	static update = function(frame = CURRENT_FRAME) {
		thumbnail = noone;
		if(isPure) renderTopo(frame);
	}
	
	static renderTopo = function(frame) {
		__frame = frame;
		array_foreach(nodeTopo, function(n) /*=>*/ { n.doUpdate(__frame); });
	}
	
	static postRender = function() {
		if(combine_render_time) 
			render_time = array_reduce(getNodeList(), function(val, node) /*=>*/ { val += node.render_time; return val; }, 0);
	}
	
	static getNextNodes = function(checkLoop = false) { return isPure? getNextNodesExternal() : getNextNodesInternal(); } 
	
	static getNextNodesInternal = function() { //get node inside the group
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"→→→→→ Call get next node from group: {getInternalName()}");
		
		var _nodes = [];
		if(isRenderActive()) {
			var allReady = true;
			for(var i = custom_input_index; i < array_length(inputs); i++) {
				var _in = inputs[i].from;
				if(!_in.isRenderActive()) continue;
			
				if(!_in.isRenderable()) {
					LOG_IF(global.FLAG.render == 1, $"Node {_in.internalName} not ready, group skip.");
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
		LOG_IF(global.FLAG.render == 1, $"Checking next node external for {getInternalName()}");
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
	
	static setRenderStatus = function(result) {
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"Set render status for {getInternalName()} : {result}");
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
		LOG_LINE_IF(global.FLAG.render == 1, $"Reset Render for group {getInternalName()}");
		
		setRenderStatus(false);
		if(_clearCache) clearInputCache();
		
		if(reset_all_child)
		for(var i = 0, n = array_length(nodes); i < n; i++)
			nodes[i].resetRender(_clearCache);
	}
	
	////- DRAW
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(!draw_input_overlay) return;
		
		var hovering = false;
		for(var i = custom_input_index; i < array_length(inputs); i++) {
			var _in = inputs[i];
			var _hv = _in.from.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
			if(_hv != undefined) {
				active   = active && !_hv;
				hovering = hovering || _hv;
			}
		}
		
		return hovering;
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
		var cc = colorMultiply(getColor(), COLORS.node_base_bg);
		var hv = PANEL_GRAPH.pHOVER && PANEL_GRAPH.node_hovering == self && (!PREFERENCES.panel_graph_group_require_shift || key_mod_press(SHIFT));
		var aa = (.25 + .5 * renderActive) * (.25 + .75 * isHighlightingInGraph()) + hv * 0.1;
		
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, cc, aa);
	}
	
	static drawNodeOverlay = function(xx, yy, _mx, _my, _s) {
		if(_s < 0.75) return;
		
		var _bx = (xx + w * _s) - 10;
		var _by = previewable? (yy + h * _s) - 10 : yy + h / 2 * _s;
		
		var _hv = PANEL_GRAPH.pHOVER && PANEL_GRAPH.node_hovering == self && PANEL_GRAPH._value_focus == noone;
		    _hv = _hv && point_in_circle(_mx, _my, _bx, _by, 8);
		
		var _ss = 1 / THEME_SCALE;
		
		draw_sprite_ext_add(THEME.animate_node_go, 0, _bx, _by, _ss, _ss, 0, _hv? COLORS._main_accent : c_white, 0.3 + _hv * 0.7);
		
		if(_hv && PANEL_GRAPH.pFOCUS && mouse_press(mb_left))
			panelSetContext(PANEL_GRAPH);
	}
	
	static getTool = function() { return toolNode ?? self; } 
	
	static setTool = function(tool) { toolNode = toolNode == tool? undefined : tool; }
	
	////- PREVIEW
	
	static getGraphPreviewSurface = function() { 
		if(is_surface(thumbnail)) return thumbnail;
		
		preview_channel = clamp(preview_channel, 0, array_length(outputs) - 1);
		var _oj = array_safe_get(outputs, preview_channel_temp ?? preview_channel);
		if(!is(_oj, NodeValue)) return noone;
		
		if(_oj.from == noone) return noone;
		var _fr = array_safe_get(_oj.from.inputs, 0);
		return _fr.value_from == noone? noone : _fr.value_from.node.getGraphPreviewSurface();
	}
	
	function getPreviewingNode() {
		preview_channel = clamp(preview_channel, 0, array_length(outputs) - 1);
		var _oj = array_safe_get(outputs, preview_channel);
		if(!is(_oj, NodeValue)) return noone;
		
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
	
	static getPreviewValues = function() {
		if(preview_channel < 0 || preview_channel >= array_length(outputs)) return noone;
		
		var _type = outputs[preview_channel].type;
		if(_type != VALUE_TYPE.surface && _type != VALUE_TYPE.dynaSurface)
			return noone;
		
		var val = outputs[preview_channel].getValue();
		if(is_struct(val) && is(val, dynaSurf))
			val = array_safe_get_fast(val.surfaces, 0, noone);
		
		return val;
	}
	
	////- CACHE
	
	static clearCache = function() { array_foreach(getNodeList(), function(node) /*=>*/ { node.clearCache(); }); }
	
	////- SERIALIZATION
	
	// toolNode
	
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
	static doSerialize		  = function(_map) {
		_map.tool = toolNode == undefined? -4 : toolNode.node_id;
	}
	
	static preApplyDeserialize = function() {
		var attr = struct_try_get(load_map, "attri", attributes);
		
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
	static doDeserialize       = function(_map) {
		var _toolNode = _map[$ "tool"] ?? -4;
		if(_toolNode != -4) {
			if(APPENDING) _toolNode = GetAppendID(_toolNode);
			toolNode = project.nodeMap[? _toolNode];
		}
	}
	
	////- ACTION
	
	static onClone = function(_newNode, target = PANEL_GRAPH.getCurrentContext()) {
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
		
		if(PREFERENCES.graph_open_group_in_tab) 
			run_in(1, function(panel) /*=>*/ { panel.open_group_tab(getNodeBase()) }, [panel]);
		else
			panel.addContext(getNodeBase());
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

#region Actions
	function groupNodes(nodeArray, _group = noone, record = true, check_connect = true) {
		var amo = array_length(nodeArray);
		if(amo == 0) return;
		
		#region check inline
			var _ctx_nodes = [];
			var _idmap     = {};
			var _selIO     = false;
			
			for(var i = 0; i < amo; i++) {
				var _n = nodeArray[i];
				
				_idmap[$ _n.node_id] = _n;
				array_push(_ctx_nodes, _n.inline_context);
				
				_selIO = _selIO || !_n.inline_input || !_n.inline_output;
			}
			
			_ctx_nodes = array_unique(_ctx_nodes);
			
			var _ctx_all = true;
			var _ctx_amo = array_length(_ctx_nodes);
			
			for( var i = 0; i < _ctx_amo; i++ ) {
				var ictx = _ctx_nodes[i];
				if(ictx == noone) continue;
				
				for( var j = 0, m = array_length(ictx.nodes); j < m; j++ ) {
					var _n = ictx.nodes[j];
					if(!_n.active) continue;
					
					if(!has(_idmap, _n.node_id)) { // doesn't select every node in the inline group
						_ctx_all = false;
						if(_ctx_amo == 1) continue;
						
						noti_warning("Grouping nodes from multiple partial inline groups is not allowed.");
						return;
					}
				}
				
			}
			
			if(!_ctx_all && _ctx_nodes[0] != noone && _selIO) {
				noti_warning("Grouping incomplete inline group IO is not allowed.");
				return;
			}
		#endregion
		
		UNDO_HOLDING = true;
		
		if(_group == noone) {
			var cx  = 0;
			var cy  = 0;
			for( var i = 0; i < amo; i++ ) {
				var _node = nodeArray[i];
				cx += _node.x;
				cy += _node.y;
			}
			
			var _grd = PROJECT.graphGrid.size;
			cx = value_snap(cx / amo, _grd);
			cy = value_snap(cy / amo, _grd);
			
			_group = new Node_Group(cx, cy, PANEL_GRAPH.getCurrentContext());
		}
		
		var _content = [];
		
		for(var i = 0; i < amo; i++) {
			var _n = nodeArray[i];
			
			_group.add(_n);
			_content[i] = _n;
			
			if(_n.inline_context != noone && !_ctx_all) 
				_n.inline_context.removeNode(_n);
		}
		
		if(_ctx_all)
		for( var i = 0, n = array_length(_ctx_nodes); i < n; i++ ) {
			var ictx = _ctx_nodes[i];
			if(ictx == noone) continue;
			
			_group.add(ictx);
			_content[i] = ictx;
		}
		
		if(check_connect) { // IO creation
			var _io = { inputs: {}, outputs: {}, map: {} };
			
			for(var i = 0; i < amo; i++)
				nodeArray[i].checkConnectGroup(_io);
			
			var _inKey = struct_get_names(_io.inputs);
			var _x, _y, m;
			
			for( var i = 0, n = array_length(_inKey); i < n; i++ ) {
				var _frm = _io.map[$ _inKey[i]];
				var _tos = _io.inputs[$ _inKey[i]];
				
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
				
				// connect to parent input if one of the input already connect to outside junction
				var _conn = false;
				for( var j = 0, _gi = array_length(_group.inputs); j < _gi; j++ ) {
					var _inp = _group.inputs[j];
					if(_inp.value_from == _frm) {
						for( var k = 0; k < m; k++ )
							_tos[k].setFrom(_inp.from.outputs[0]);
						_conn = true;
						break;
					}
				}
				
				if(_conn) continue;
				
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
			
			var _otKey = struct_get_names(_io.outputs);
				
			for( var i = 0, n = array_length(_otKey); i < n; i++ ) {
				var _frm = _io.map[$ _otKey[i]];
				var _tos = _io.outputs[$ _otKey[i]];
				
				var _conn = false;
				for( var j = 0, m = array_length(_group.outputs); j < m; j++ ) {
					var _oup = _group.outputs[j];
					if(_oup.from.value_from == _frm) {
						for( var k = 0; k < p; k++ )
							_tos[k].setFrom(_oup);
						
						_conn = true;
						break;
					}
				}
				
				if(_conn) continue;
				
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
		
		if(record) {
			recordAction(ACTION_TYPE.ungroup, collection, { 
				content :   _content,
				deleted :   _deleted,
				connectTo : _conn_to,
			});
		}
	}
#endregion