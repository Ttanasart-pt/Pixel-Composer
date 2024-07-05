enum COLLECTION_TAG {
	group = 1,
	loop = 2
}

function groupNodes(nodeArray, _group = noone, record = true, check_connect = true) { #region
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
	
	if(check_connect) { #region IO creation
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
			
			var _n = new Node_Group_Input(_x, _y, _group);
			_n.inputs[| 2].setValue(_frm.type);
			_n.onValueUpdate(0);
			_n.inParent.setFrom(_frm);
				
			for( var j = 0; j < m; j++ ) {
				var _to = _tos[j];
				_to.setFrom(_n.outputs[| 0]);
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
			_n.inputs[| 0].setFrom(_frm);
			
			for( var j = 0; j < m; j++ ) {
				var _to = _tos[j];
				_to.setFrom(_n.outParent);
			}
		}
		
	} #endregion
	
	UNDO_HOLDING = false;	
	if(record) recordAction(ACTION_TYPE.group, _group, { content: _content });
	
	return _group;
} #endregion

function upgroupNode(collection, record = true) { #region
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
} #endregion

function Node_Collection(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 
	nodes       = [];
	node_length = 0;
	
	ungroupable			= true;
	auto_render_time	= false;
	combine_render_time = true;
	previewable         = true;
	
	reset_all_child = false;
	isInstancer		= false;
	instanceBase	= noone;
	
	input_display_list_def = [];
	custom_input_index     = 0;
	custom_output_index    = 0;
	
	metadata = new MetaDataManager();
	
	group_input_display_list  = [];
	group_output_display_list = [];
	attributes.input_display_list  = [];
	attributes.output_display_list = [];
	
	managedRenderOrder = false;
	
	input_dummy = nodeValue("Add to group", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0);
	draw_dummy  = false;
	
	input_dummy.onSetFrom = function(juncFrom) { #region
		array_remove(juncFrom.value_to, input_dummy);
		input_dummy.value_from = noone;
		
		var input = nodeBuild("Node_Group_Input", 0, 0, self);
		var _type = juncFrom.type;
		var _tind = array_find(input.data_type_map, juncFrom.type);
		
		input.attributes.inherit_type = false;
		if(_tind != -1)
			input.inputs[| 2].setValue(_tind);
			
		input.inParent.setFrom(juncFrom);
		
		if(onNewInputFromGraph != noone) onNewInputFromGraph(juncFrom);
	} #endregion
	
	onNewInputFromGraph = noone;
	
	tool_node = noone;
	draw_input_overlay = true;
	
	array_push(attributeEditors, ["Edit Input Display", function() { return 0; },
		button(function() { dialogCall(o_dialog_group_input_order).setNode(self, JUNCTION_CONNECT.input); }) ]);
	
	array_push(attributeEditors, ["Edit Output Display", function() { return 0; },
		button(function() { dialogCall(o_dialog_group_input_order).setNode(self, JUNCTION_CONNECT.output); }) ]);
	
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
	static refreshNodes = function() { #region
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
		
	} #endregion
	
	static getNodeBase = function() { #region 
		if(instanceBase == noone) return self;
		return instanceBase.getNodeBase();
	} #endregion
	
	static getNodeList = function() { #region
		INLINE
		if(instanceBase == noone) return nodes;
		return instanceBase.getNodeList();
	} #endregion
	
	static exitGroup = function() {}
	
	static onAdd = function(_node) {}
	static add = function(_node) {
		array_push(getNodeList(), _node);
		var list = _node.group == noone? PANEL_GRAPH.nodes_list : _node.group.getNodeList();
		array_remove(list, _node);
		
		recordAction(ACTION_TYPE.group_added, self, _node);
		_node.group = self;
		
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
			
		will_refresh = true;
		node_length  = array_length(nodes);
		onRemove(_node);
	}
	
	/////============= STEP ==============
	
	static stepBegin = function() { #region
		if(will_refresh) refreshNodes();
		doStepBegin(); 
	} #endregion
	
	static step = function() { #region
		if(combine_render_time) {
			render_time = 0;
			array_foreach(getNodeList(), function(node) { render_time += node.render_time; });
		}
		
		onStep();
	} #endregion
	
	static onStep = function() {}
	
	/////========== JUNCTIONS ==========
	
	static getOutputNodes = function() { #region
		var _nodes = [];
		for( var i = custom_output_index; i < ds_list_size(outputs); i++ ) {
			var _junc = outputs[| i];
			
			for( var j = 0; j < array_length(_junc.value_to); j++ ) {
				var _to = _junc.value_to[j];
				if(_to.value_from != _junc) continue;
				array_push_unique(_nodes, _to.node);
			}
		}
		return _nodes;
	} #endregion
	
	static getInput = function(_y = 0, junc = noone) { #region
		return input_dummy;
	} #endregion
	
	static preConnect = function() { #region
		sortIO();
		deserialize(load_map, load_scale);
	} #endregion
	
	static sortIO = function() { #region
		var _ilen = ds_list_size(inputs);
		var _iarr = attributes.input_display_list;
		
		for( var i = custom_input_index; i < _ilen; i++ ) 
			array_push_unique(_iarr, i);
			
		for( var i = array_length(_iarr) - 1; i >= 0; i-- ) {
			if(is_array(_iarr[i])) continue;
			if(_iarr[i] >= _ilen) array_delete(_iarr, i, 1);
		}
		
		input_display_list = array_merge(group_input_display_list, attributes.input_display_list);
		
		///////////////////////////////////////////////////////////////////
		
		var _olen = ds_list_size(outputs);
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
	} #endregion
	
	static preConnect = function() { #region 
		instanceBase = GetAppendID(struct_try_get(load_map, "instance_base", noone));
		
		sortIO();
		applyDeserialize();
	} #endregion
	
	/////========== RENDERING ===========
	
	static getNextNodes = function() { return getNextNodesInternal(); } 
	
	static getNextNodesInternal = function() { #region //get node inside the group
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"→→→→→ Call get next node from group: {INAME}");
		
		var _nodes = [];
		if(isRenderActive()) {
			var allReady = true;
			for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
				var _in = inputs[| i].from;
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
	} #endregion
	
	static getNextNodesExternal = function() { #region //get node connected to the parent object
		LOG_IF(global.FLAG.render == 1, $"Checking next node external for {INAME}");
		LOG_BLOCK_START();
		
		var nextNodes = [];
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			var _ot = outputs[| i];
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
	} #endregion
	
	static clearTopoSorted = function() { INLINE topoSorted = false; for( var i = 0, n = array_length(nodes); i < n; i++ ) { nodes[i].clearTopoSorted(); } }
	
	static setRenderStatus = function(result) { #region
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"Set render status for {INAME} : {result}");
		rendered = result;
		if(rendered == result) {
			LOG_BLOCK_END();
			return;
		}
		
		if(result)
		for( var i = custom_output_index, n = ds_list_size(outputs); i < n; i++ ) {
			var _o = outputs[| i];
			if(_o.from.rendered) continue;
				
			LOG_IF(global.FLAG.render == 1, $"Set fail because {_o.from.internalName} is not rendered.");
			rendered = false;
			break;
		}
		
		if(rendered) exitGroup();
		
		if(!result && group != noone) 
			group.setRenderStatus(result);
		LOG_BLOCK_END();
	} #endregion
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) { #region
		if(update_on_frame) return true;
		if(!rendered)       return true;
		
		for( var i = custom_input_index, n = ds_list_size(inputs); i < n; i++ ) 
			if(inputs[| i].isActiveDynamic(frame) || !inputs[| i].from.rendered) return true;
		
		return false;
	} #endregion
	
	static resetRender = function(_clearCache = false) { #region
		LOG_LINE_IF(global.FLAG.render == 1, $"Reset Render for group {INAME}");
		
		setRenderStatus(false);
		if(_clearCache) clearInputCache();
		
		if(reset_all_child)
		for(var i = 0, n = array_length(nodes); i < n; i++)
			nodes[i].resetRender(_clearCache);
	} #endregion
	
	/////============= DRAW =============
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		if(!draw_input_overlay) return;
		
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var _in   = inputs[| i];
			var _show = _in.from.getInputData(6);
			
			if(!_show) continue;
			var _hov = _in.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			if(_hov != undefined) active &= !_hov;
		}
	} #endregion
	
	static onPreDraw = function(_x, _y, _s, _iny, _outy) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		input_dummy.x = xx;
		input_dummy.y = _iny;
		
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
		var _by = (yy + h * _s) - 10;
		
		var _hv = PANEL_GRAPH.pHOVER && PANEL_GRAPH.node_hovering == self;
		    _hv &= point_in_circle(_mx, _my, _bx, _by, 8);
		
		BLEND_ADD
		draw_sprite_ext(THEME.animate_node_go, 0, _bx, _by, 1, 1, 0, getColor(), 0.2 + _hv * 0.3);
		BLEND_NORMAL
		
		if(_hv && PANEL_GRAPH.pFOCUS && mouse_press(mb_left))
			panelSetContext(PANEL_GRAPH);
	}
	
	static onDrawJunctions = function(_x, _y, _mx, _my, _s) { #region
		input_dummy.visible = false;
		
		if(draw_dummy) {
			input_dummy.visible = true;
			input_dummy.drawJunction(_s, _mx, _my);
		}
		
		draw_dummy = false;
	} #endregion
	
	static getTool = function() { #region
		for(var i = 0, n = array_length(nodes); i < n; i++) { 
			var _node = nodes[i];
			if(!_node.active) continue;
			if(_node.isTool) return _node.getTool();
		}
		
		return self;
	} #endregion 
	
	/////============ PREVIEW ============
	
	static getGraphPreviewSurface = function() { #region
		var _output_junc = outputs[| preview_channel];
		
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			if(!nodes[i].active) continue;
			if(is_instanceof(nodes[i], Node_Group_Thumbnail))
				_output_junc = nodes[i].inputs[| 0];
		}
		
		if(!is_instanceof(_output_junc, NodeValue)) return noone;
		
		switch(_output_junc.type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				return _output_junc.getValue();
		}
		
		return noone;
	} #endregion
	
	/////============= CACHE =============
	
	static clearCache = function() { #region
		array_foreach(getNodeList(), function(node) { node.clearCache(); });
	} #endregion
	
	/////========== INSTANCING ===========
	
	static setInstance = function(node) { #region
		instanceBase = node;
	} #endregion
	
	static resetInstance = function() { #region
		instanceBase = noone;
	} #endregion
	
	/////========= SERIALIZATION =========
	
	static attributeSerialize = function() { #region
		sortIO();
		
		var _attr = variable_clone(attributes);
		
		_attr.custom_input_list = [];
		for( var i = custom_input_index, n = ds_list_size(inputs); i < n; i++ ) {
			if(struct_has(inputs[| i], "from"))
				array_push(_attr.custom_input_list, inputs[| i].from.node_id);
		}
		
		_attr.custom_output_list = [];
		for( var i = custom_output_index, n = ds_list_size(outputs); i < n; i++ ) {
			if(struct_has(outputs[| i], "from"))
				array_push(_attr.custom_output_list , outputs[| i].from.node_id);
		}
		
		return _attr;
	} #endregion
	
	static preApplyDeserialize = function() { #region
		var attr = attributes;
		
		if(LOADING_VERSION < 11690) { #region
			var pr = ds_priority_create();
			
			for( var i = ds_list_size(inputs) - 1; i >= custom_input_index; i-- ) {
				if(!struct_has(inputs[| i].attributes, "input_priority")) continue;
				
				var _pri = inputs[| i].attributes.input_priority;
				ds_priority_add(pr, inputs[| i], _pri);
				ds_list_delete(inputs, i);
			}
			
			repeat(ds_priority_size(pr)) ds_list_add(inputs, ds_priority_delete_min(pr));
			
			for( var i = ds_list_size(outputs) - 1; i >= custom_output_index; i-- ) {
				if(!struct_has(outputs[| i].attributes, "output_priority")) continue;
				
				var _pri = outputs[| i].attributes.output_priority;
				ds_priority_add(pr, outputs[| i], _pri);
				ds_list_delete(outputs, i);
			}
			
			repeat(ds_priority_size(pr)) ds_list_add(outputs, ds_priority_delete_min(pr));
			
			ds_priority_destroy(pr);
			return;
		} #endregion
		
		if(struct_has(attr, "custom_input_list")) {
			var _ilist = attr.custom_input_list;
			var _inarr = {};
			var _dilst = [];
			
			if(APPENDING)
			for( var i = 0, n = array_length(_ilist); i < n; i++ ) 
				_ilist[i] = ds_map_try_get(APPEND_MAP, _ilist[i], _ilist[i]);
			
			for( var i = ds_list_size(inputs) - 1; i >= custom_input_index; i-- ) {
				if(!struct_has(inputs[| i], "from")) continue;
				
				var _frNode = inputs[| i].from.node_id;
				if(array_exists(_ilist, _frNode)) {
					_inarr[$ _frNode] = inputs[| i];
					ds_list_delete(inputs, i);
				}
			}
			
			for( var i = 0, n = array_length(_ilist); i < n; i++ ) {
				if(!struct_has(_inarr, _ilist[i])) continue;
				
				ds_list_add(inputs, _inarr[$ _ilist[i]]);
			}
			
		}
		
		if(struct_has(attr, "custom_output_list")) {
			var _ilist = attr.custom_output_list;
			var _inarr = {};
			
			if(APPENDING)
			for( var i = 0, n = array_length(_ilist); i < n; i++ ) 
				_ilist[i] = ds_map_try_get(APPEND_MAP, _ilist[i], _ilist[i]);
			
			for( var i = ds_list_size(outputs) - 1; i >= custom_output_index; i-- ) {
				if(!struct_has(outputs[| i], "from")) continue;
				
				var _frNode = outputs[| i].from.node_id;
				if(array_exists(_ilist, _frNode)) {
					_inarr[$ _frNode] = outputs[| i];
					ds_list_delete(outputs, i);
				}
			}
			
			for( var i = 0, n = array_length(_ilist); i < n; i++ ) {
				if(!struct_has(_inarr, _ilist[i])) continue;
				
				ds_list_add(outputs, _inarr[$ _ilist[i]]);
			}
			
		}
		
	} #endregion
	
	static processSerialize = function(_map) { #region
		_map.instance_base	= instanceBase? instanceBase.node_id : noone;
	} #endregion
	
	/////============ ACTION ============
	
	static onClone = function(_newNode, target = PANEL_GRAPH.getCurrentContext()) { #region
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
	} #endregion
	
	static enable = function() { #region
		active = true;
		array_foreach(getNodeList(), function(node) { node.enable(); });
	} #endregion
	
	static disable = function() { #region
		active = false;
		array_foreach(getNodeList(), function(node) { node.disable(); });
	} #endregion
	
	function onDoubleClick(panel) { #region
		if(PREFERENCES.panel_graph_group_require_shift && !key_mod_press(SHIFT)) return false;
		
		panelSetContext(panel);
		
		if(ononDoubleClick != noone)
			ononDoubleClick(panel);
			
		return true;
	} #endregion
	
	static panelSetContext = function(panel) {
		__temp_panel = panel;
		
		if(PREFERENCES.graph_open_group_in_tab) 
			run_in(1, function() { __temp_panel.openGroupTab(self) });
		else
			panel.addContext(self);
	}
	
	static ononDoubleClick = noone;
	
	static enable = function() { #region
		active = true; timeline_item.active = true;
		for( var i = 0, n = array_length(nodes); i < n; i++ ) nodes[i].enable();
	} #endregion
	
	static disable = function() { #region
		active = false; timeline_item.active = false;
		for( var i = 0, n = array_length(nodes); i < n; i++ ) nodes[i].disable();
	} #endregion
	
}