enum COLLECTION_TAG {
	group = 1,
	loop = 2
}

function groupNodes(nodeArray, _group = noone, record = true, check_connect = true) {
	UNDO_HOLDING = true;
	
	if(_group == noone) {
		var cx = 0;
		var cy = 0;
		for(var i = 0; i < array_length(nodeArray); i++) {
			var _node = nodeArray[i];
			cx += _node.x;
			cy += _node.y;
		}
		cx = round(cx / array_length(nodeArray) / 32) * 32;
		cy = round(cy / array_length(nodeArray) / 32) * 32;
		
		_group = new Node_Group(cx, cy, PANEL_GRAPH.getCurrentContext());
	}
	
	var _content = [];
		
	for(var i = 0; i < array_length(nodeArray); i++) {
		_group.add(nodeArray[i]);
		_content[i] = nodeArray[i];
	}
		
	var _io = [];
	if(check_connect) 
	for(var i = 0; i < array_length(nodeArray); i++)
		array_append(_io, nodeArray[i].checkConnectGroup());
			
	UNDO_HOLDING = false;	
	if(record) recordAction(ACTION_TYPE.group, _group, { io: _io, content: _content });
	
	return _group;
}

function upgroupNode(collection, record = true) {
	UNDO_HOLDING = true;
	var _content = [];
	var _io = [];
	var node_list = collection.getNodeList();
	while(!ds_list_empty(node_list)) {
		var remNode = node_list[| 0];
		if(remNode.destroy_when_upgroup)	
			array_push(_io, remNode);
		else 
			array_push(_content, remNode);
		
		collection.remove(remNode); 
	}
	
	nodeDelete(collection);
	UNDO_HOLDING = false;
	
	if(record) recordAction(ACTION_TYPE.ungroup, collection, { io: _io, content: _content });
}

function Node_Collection(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	nodes = ds_list_create();
	ungroupable = true;
	auto_render_time = false;
	combine_render_time = true;
	
	reset_all_child = false;
	isInstancer  = false;
	instanceBase = noone;
	
	custom_input_index = 0;
	custom_output_index = 0;
	
	metadata = new MetaDataManager();
	
	attributes[? "Separator"] = [];
	attributes[? "w"] = 128;
	attributes[? "h"] = 128;
	
	array_push(attributeEditors, ["Edit separator", "Separator",
		button(function() {
			var dia = dialogCall(o_dialog_group_input_order);
			dia.node = self;
		}) ]);
	
	insp1UpdateTooltip   = get_text("panel_inspector_execute", "Execute node contents");
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static inspector1Update   = function() { onInspector1Update(); }
	static onInspector1Update = function() { RenderListAction(nodes, group); }
	
	static hasInspector1Update = function(group = false) { 
		if(!group) return false;
		
		for( var i = 0; i < ds_list_size(nodes); i++ ) {
			if(nodes[| i].hasInspector1Update())
				return true;
		}
		
		return false;
	}
	
	static getNodeBase = function() {
		if(instanceBase == noone) return self;
		return instanceBase.getNodeBase();
	}
	
	static getNodeList = function() {
		if(instanceBase == noone) return nodes;
		return instanceBase.getNodeList();
	}
	
	static setHeight = function() {
		var _hi = ui(32);
		var _ho = ui(32);
		
		for( var i = 0; i < ds_list_size(inputs); i++ )
			if(inputs[| i].isVisible()) _hi += 24;
		
		for( var i = 0; i < ds_list_size(outputs); i++ )
			if(outputs[| i].isVisible()) _ho += 24;
		
		var preH = (preview_surface && previewable)? 128 : 0;
		
		h = max(min_h, preH, _hi, _ho);
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var _in   = inputs[| i];
			var _show = _in.from.inputs[| 6].getValue();
			
			if(!_show) continue;
			_in.drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		}
	}
	
	static getNextNodes = function() { //get node inside the group
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render, $"→→→→→ Call get next node from group");
		
		var allReady = true;
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i].from;
			if(!_in.renderActive) continue;
			
			if(!_in.isRenderable()) {
				LOG_IF(global.FLAG.render, $"Node {_in.internalName} not ready, loop skip.");
				LOG_BLOCK_END();
				return [];
			}
		}
		
		var nodes = __nodeLeafList(getNodeList());
		LOG_BLOCK_END();
		return nodes;
	}
	
	static getNextNodesExternal = function() { //get node connected to the parent object
		var nodes = [];
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			var _ot = outputs[| i];
			
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to   = _ot.value_to[| j];
				var _node = _to.node;
				
				if(!_node.renderActive) continue;
				
				if(_node.active && _to.value_from != noone && _to.value_from.node == group && _node.isRenderable())
					array_push(nodes, _to.node);
			}
		}
		
		return nodes;
	}
	
	static setRenderStatus = function(result) {
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render, $"Set render status for {internalName} : {result}");
		LOG_BLOCK_END();
		rendered = result;
		
		if(result) {
			var siz = ds_list_size(outputs);
			for( var i = custom_output_index; i < siz; i++ ) {
				var _o = outputs[| i];
				if(_o.node.rendered) continue;
				
				rendered = false;
				break;
			}
		}
		
		if(rendered)
			exitGroup();
		
		if(!result && group != noone) 
			group.setRenderStatus(result);
	}
	
	static exitGroup = function() {}
	
	function add(_node) {
		ds_list_add(getNodeList(), _node);
		var list = _node.group == noone? PANEL_GRAPH.nodes_list : _node.group.getNodeList();
		var _pos = ds_list_find_index(list, _node);
		ds_list_delete(list, _pos);
		
		recordAction(ACTION_TYPE.group_added, self, _node);
		_node.group = self;
	}
	
	function remove(_node) {
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
	}
	
	static clearCache = function() {
		var node_list = getNodeList();
		for(var i = 0; i < ds_list_size(node_list); i++) {
			node_list[| i].clearCache();
		}
	}
	
	static stepBegin = function() {
		use_cache = false;
		
		array_safe_set(cache_result, ANIMATOR.current_frame, true);
		
		var node_list = getNodeList();
		for(var i = 0; i < ds_list_size(node_list); i++) {
			var n = node_list[| i];
			n.stepBegin();
			if(!n.use_cache) continue;
			
			use_cache = true;
			if(!array_safe_get(n.cache_result, ANIMATOR.current_frame))
				array_safe_set(cache_result, ANIMATOR.current_frame, false);
		}
		
		var out_surf = false;
		
		for( var i = 0; i < ds_list_size(outputs); i++) {
			if(outputs[| i].type == VALUE_TYPE.surface) 
				out_surf = true;
		}
		
		if(out_surf) {
			w = 128;
			min_h = 128;
		} else {
			w = 96;
			
		}
		
		setHeight();
		doStepBegin();
	}
	
	static step = function() {
		if(combine_render_time) render_time = 0;
		
		var node_list = getNodeList();
		for(var i = 0; i < ds_list_size(node_list); i++) {
			node_list[| i].step();
			if(combine_render_time) 
				render_time += node_list[| i].render_time;
		}
		
		w = attributes[? "w"];
		
		onStep();
	}
	
	static onStep = function() {}
	
	PATCH_STATIC
	
	//static triggerRender = function() {
	//	for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
	//		var jun_node = inputs[| i].from;
	//		jun_node.triggerRender();
	//	}
	//}
	
	static preConnect = function() {
		sortIO();
		deserialize(load_map, load_scale);
	}
	
	static sortIO = function() {
		input_display_list = [];
		
		var sep = attributes[? "Separator"];		
		array_sort(sep, function(a0, a1) { return a0[0] - a1[0]; });
		var siz = ds_list_size(inputs);
		var ar  = ds_priority_create();
		
		for( var i = custom_input_index; i < siz; i++ ) {
			var _in = inputs[| i];
			var _or = _in.from.inputs[| 5].getValue();
			
			ds_priority_add(ar, _in, _or);
		}
		
		for( var i = siz - 1; i >= custom_input_index; i-- )
			ds_list_delete(inputs, i);
		
		for( var i = 0; i < custom_input_index; i++ ) 
			array_push(input_display_list, i);
			
		for( var i = custom_input_index; i < siz; i++ ) {
			var _jin = ds_priority_delete_min(ar);
			_jin.index = i;
			ds_list_add(inputs, _jin);
			array_push(input_display_list, i);
		}
		
		for( var i = array_length(sep) - 1; i >= 0; i-- ) {
			array_insert(input_display_list, sep[i][0], [ sep[i][1], false, i ]);
		}
		
		ds_priority_destroy(ar);
		
		var siz = ds_list_size(outputs);
		var ar = ds_priority_create();
		
		for( var i = custom_output_index; i < siz; i++ ) {
			var _out = outputs[| i];
			var _or = _out.from.inputs[| 1].getValue();
			
			ds_priority_add(ar, _out, _or);
		}
		
		for( var i = siz - 1; i >= custom_output_index; i-- ) {
			ds_list_delete(outputs, i);
		}
		
		for( var i = custom_output_index; i < siz; i++ ) {
			var _jout = ds_priority_delete_min(ar);
			_jout.index = i;
			ds_list_add(outputs, _jout);
		}
		
		ds_priority_destroy(ar);
	}
	
	static onClone = function(_newNode, target = PANEL_GRAPH.getCurrentContext()) {
		if(instanceBase != noone) {
			_newNode.instanceBase = instanceBase;
			return;
		}
		
		var dups = ds_list_create();
		
		for(var i = 0; i < ds_list_size(nodes); i++) {
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
	}
	
	static enable = function() { 
		active = true;
		var node_list = getNodeList();
		for( var i = 0; i < ds_list_size(node_list); i++ )
			node_list[| i].enable();
	}
	
	static disable = function() {
		active = false;
		var node_list = getNodeList();
		for( var i = 0; i < ds_list_size(node_list); i++ )
			node_list[| i].disable();
	}
	
	static resetRender = function() {
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render, $"Reset Render for {internalName}");
		
		for( var i = 0; i < ds_list_size(nodes); i++ ) {
			//LOG_IF(global.FLAG.render, $"Reset Render for {nodes[| i].internalName}");
			nodes[| i].resetRender();
		}
		
		setRenderStatus(false);
		
		LOG_BLOCK_END();
	}
	
	static setInstance = function(node) {
		instanceBase = node;
	}
	
	static resetInstance = function() {
		instanceBase = noone;
	}
	
	static processSerialize = function(_map) {
		_map[? "instance_base"]	= instanceBase? instanceBase.node_id : noone;
	}
	
	static preConnect = function() {
		instanceBase = GetAppendID(ds_map_try_get(load_map, "instance_base", noone));
		
		sortIO();
		applyDeserialize();
	}
	
	static attributeSerialize = function() {
		var att = ds_map_create();
		att[? "Separator"] = json_stringify(attributes[? "Separator"]);
		att[? "w"] = attributes[? "w"];
		att[? "h"] = attributes[? "h"];
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		if(ds_map_exists(attr, "Separator"))
			attributes[? "Separator"] = json_parse(attr[? "Separator"]);
		attributes[? "w"] = ds_map_try_get(attr, "w", 128);
		attributes[? "h"] = ds_map_try_get(attr, "h", 128);
	}
	
}