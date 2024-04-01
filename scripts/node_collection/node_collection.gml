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
			
			for( var k = 0, n = array_length(ctx.members); k < n; k++ ) {
				if(array_exists(nodeArray, ctx.members[k])) continue;
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
	
	var _io = { inputs: {}, outputs: {}, map: {} };
	
	if(check_connect) { #region IO creation
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
	UNDO_HOLDING = true;
	var _content = [];
	var node_list = collection.getNodeList();
	
	while(!ds_list_empty(node_list)) {
		var remNode = node_list[| 0];
		if(!remNode.destroy_when_upgroup)
			array_push(_content, remNode);
		
		collection.remove(remNode); 
	}
	
	nodeDelete(collection);
	UNDO_HOLDING = false;
	
	if(record) recordAction(ACTION_TYPE.ungroup, collection, { content: _content });
} #endregion

function Node_Collection(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 
	nodes       = ds_list_create();
	node_length = ds_list_size(nodes);
	
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
	
	hasInsp1 = false;
	insp1UpdateTooltip   = __txtx("panel_inspector_execute", "Execute node contents");
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	hasInsp2 = false;
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static inspector1Update    = function() { onInspector1Update(); }
	static onInspector1Update  = function() { RenderList(nodes, true); }
	static hasInspector1Update = function() { INLINE return hasInsp1; }
	
	static inspector2Update    = function() { onInspector2Update(); }
	static onInspector2Update  = function() { #region
		var i = 0;
		
		repeat(node_length) {
			if(nodes[| i].hasInspector2Update())
				nodes[| i].inspector2Update();
			i++;
		}
	} #endregion
	static hasInspector2Update = function() { INLINE return hasInsp2; }
	
	will_refresh = false;
	static refreshNodes = function() { #region
		will_refresh = false; 
		node_length  = ds_list_size(nodes);
		
		hasInsp1 = false;
		hasInsp2 = false;
		
		var i = 0;
		repeat(node_length) {
			hasInsp1 |= nodes[| i].hasInspector1Update();
			hasInsp2 |= nodes[| i].hasInspector2Update();
			
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
	
	static getInput = function(junc = noone) { #region
		return input_dummy;
	} #endregion
	
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
	
	static setRenderStatus = function(result) { #region
		LOG_BLOCK_START();
		if(rendered == result) return;
		
		LOG_IF(global.FLAG.render == 1, $"Set render status for {INAME} : {result}");
		rendered = result;
		
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
		
		for( var i = custom_input_index, n = ds_list_size(inputs); i < n; i++ ) 
			if(inputs[| i].isActiveDynamic(frame) || !inputs[| i].from.rendered) return true;
		
		return false;
	} #endregion
	
	static exitGroup = function() {}
	
	static add = function(_node) { #region
		ds_list_add(getNodeList(), _node);
		var list = _node.group == noone? PANEL_GRAPH.nodes_list : _node.group.getNodeList();
		ds_list_remove(list, _node);
		
		recordAction(ACTION_TYPE.group_added, self, _node);
		_node.group = self;
		
		will_refresh = true;
	} #endregion
	
	static remove = function(_node) { #region
		var node_list = getNodeList();
		var _pos = ds_list_find_index(node_list, _node);
		ds_list_delete(node_list, _pos);
		var list = group == noone? PANEL_GRAPH.nodes_list : group.getNodeList();
		ds_list_add(list, _node);
		
		recordAction(ACTION_TYPE.group_removed, self, _node);
		
		if(struct_has(_node, "ungroup"))
			_node.ungroup();
			
		if(_node.destroy_when_upgroup) 
			nodeDelete(_node);
		else
			_node.group = group;
			
		will_refresh = true;
	} #endregion
	
	static clearCache = function() { #region
		var node_list = getNodeList();
		for(var i = 0; i < ds_list_size(node_list); i++) {
			node_list[| i].clearCache();
		}
	} #endregion
	
	static stepBegin = function() { 
		if(will_refresh) refreshNodes();
		doStepBegin(); 
	}
	
	static step = function() { #region
		if(combine_render_time) {
			render_time = 0;
			var node_list = getNodeList();
			for(var i = 0; i < ds_list_size(node_list); i++)
				render_time += node_list[| i].render_time;
		}
		
		onStep();
	} #endregion
	
	static onStep = function() {}
	
	static onPreDraw = function(_x, _y, _s, _iny, _outy) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		input_dummy.x = xx;
		input_dummy.y = _iny;
	} #endregion
	
	static preConnect = function() { #region
		sortIO();
		deserialize(load_map, load_scale);
	} #endregion
	
	static onDrawJunctions = function(_x, _y, _mx, _my, _s) { #region
		input_dummy.visible = false;
		
		if(draw_dummy) {
			input_dummy.visible = true;
			input_dummy.drawJunction(_s, _mx, _my);
		}
		
		draw_dummy = false;
	} #endregion
	
	static sortIO = function() { #region
		for( var i = 0; i < ds_list_size(inputs); i++ ) 
			array_push_unique(attributes.input_display_list, i);
		input_display_list = attributes.input_display_list;
		
		for( var i = 0; i < ds_list_size(outputs); i++ ) 
			array_push_unique(attributes.output_display_list, i);
		output_display_list = attributes.output_display_list;
		
		refreshNodeDisplay();
	} #endregion
	
	static getTool = function() { #region
		for(var i = 0; i < node_length; i++) { 
			var _node = nodes[| i];
			if(!_node.active) continue;
			if(_node.isTool) return _node.getTool();
		}
		
		return self;
	} #endregion 
	
	static onClone = function(_newNode, target = PANEL_GRAPH.getCurrentContext()) { #region
		if(instanceBase != noone) {
			_newNode.instanceBase = instanceBase;
			return;
		}
		
		var dups = ds_list_create();
		
		for(var i = 0; i < node_length; i++) {
			var _node = nodes[| i];
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
		var node_list = getNodeList();
		for( var i = 0; i < ds_list_size(node_list); i++ )
			node_list[| i].enable();
	} #endregion
	
	static disable = function() { #region
		active = false;
		var node_list = getNodeList();
		for( var i = 0; i < ds_list_size(node_list); i++ )
			node_list[| i].disable();
	} #endregion
	
	static resetRender = function(_clearCache = false) { #region
		LOG_LINE_IF(global.FLAG.render == 1, $"Reset Render for {INAME}");
		
		setRenderStatus(false);
		if(_clearCache) clearInputCache();
		
		for( var i = 0; i < node_length; i++ )
			nodes[| i].resetRender(_clearCache);
	} #endregion
	
	static setInstance = function(node) { #region
		instanceBase = node;
	} #endregion
	
	static resetInstance = function() { #region
		instanceBase = noone;
	} #endregion
	
	static onDoubleClick = function(panel) { #region
		__temp_panel = panel;
		
		if(PREFERENCES.graph_open_group_in_tab)
			run_in(1, function() { __temp_panel.openGroupTab(self) });
		else
			panel.addContext(self);
		
		if(ononDoubleClick != noone)
			ononDoubleClick(panel);
	} #endregion
	
	static ononDoubleClick = noone;
	
	static getGraphPreviewSurface = function() { #region
		var _output_junc = outputs[| preview_channel];
		
		for( var i = 0, n = node_length; i < n; i++ ) {
			if(!nodes[| i].active) continue;
			if(is_instanceof(nodes[| i], Node_Group_Thumbnail))
				_output_junc = nodes[| i].inputs[| 0];
		}
		
		if(!is_instanceof(_output_junc, NodeValue)) return noone;
		
		switch(_output_junc.type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				return _output_junc.getValue();
		}
		
		return noone;
	} #endregion
	
	static enable = function() { #region
		active = true; timeline_item.active = true;
		for( var i = 0, n = node_length; i < n; i++ ) nodes[| i].enable();
	} #endregion
	
	static disable = function() { #region
		active = false; timeline_item.active = false;
		for( var i = 0, n = node_length; i < n; i++ ) nodes[| i].disable();
	} #endregion
	
	static processSerialize = function(_map) { #region
		_map[? "instance_base"]	= instanceBase? instanceBase.node_id : noone;
	} #endregion
	
	static preConnect = function() { #region 
		instanceBase = GetAppendID(struct_try_get(load_map, "instance_base", noone));
		
		sortIO();
		applyDeserialize();
	} #endregion
	
}