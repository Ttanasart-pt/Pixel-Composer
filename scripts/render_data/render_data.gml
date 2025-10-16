enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

#region globalvar
	globalvar UPDATE, RENDER_QUEUE, RENDER_ORDER;
	
	globalvar UPDATE_RENDER_ORDER; UPDATE_RENDER_ORDER = false;
	globalvar LIVE_UPDATE; LIVE_UPDATE         = false;
	globalvar RENDERING; RENDERING           = undefined;
	globalvar WILL_RENDERING; WILL_RENDERING      = undefined;
	
	#macro RENDER_ALL             RenderAll();
	#macro RENDER_ALL_REORDER     RenderAllReorder();
	#macro RENDER_PARTIAL         RenderPartial();
	#macro RENDER_PARTIAL_REORDER RenderPartialReorder();
	
	function RenderAll() { 
		UPDATE |= RENDER_TYPE.full; 
	}
	
	function RenderAllReorder() { 
		UPDATE |= RENDER_TYPE.full;    
		UPDATE_RENDER_ORDER = true; 
	}
	
	function RenderPartial() { 
		UPDATE |= RENDER_TYPE.partial; 
	}
	
	function RenderPartialReorder() { 
		UPDATE |= RENDER_TYPE.partial; 
		UPDATE_RENDER_ORDER = true; 
	}
	
	global.getvalue_hit = 0;
#endregion

function NodeTopoSort(_project = PROJECT) {
	LOG_IF(global.FLAG.render == 1, $"======================= RESET TOPO =======================")
	
	var amo  = array_length(_project.allNodes);
	var _t   = get_timer();
	
	array_foreach(_project.allNodes, function(n) /*=>*/ { if(is(n, Node_Collection)) n.refreshNodes(); });
	
	_project.nodeTopo   = [];
	__topoSort(_project.nodeTopo, _project.nodes, {}, _project);
	
	array_foreach(_project.allNodes, function(n) /*=>*/ { if(is(n, Node_Group)) n.updateInstance(); });
	
	_project.nodeTopoID = UUID_generate();
	LOG_IF(global.FLAG.render == 1, $"+++++++ Topo Sort Completed: {array_length(_project.nodeTopo)}/{amo} nodes sorted in {(get_timer() - _t) / 1000} ms +++++++");
	
	NodeTreeSort(_project);
}

function NodeListSort(_nodeList, _project = PROJECT) {
	var _arr = __topoSort([], _nodeList, {}, _project); return _arr;
}

function __sortNode(_arr, _node, _sorted, _nodeMap = undefined, _project = PROJECT) {
	if(struct_has(_sorted, _node.node_id)) return;
	
	var _parents = [];
	var _prev    = _node.getPreviousNodes();
		
	for( var i = 0, n = array_length(_prev); i < n; i++ ) {
		var _in = _prev[i];
		if(_in == noone || struct_has(_sorted, _in.node_id))            continue;
		if(_nodeMap != undefined && !struct_has(_nodeMap, _in.node_id)) continue;
		
		array_push(_parents, _in);
	}
		
	// print($"> Checking {_node.name}: {array_length(_parents)} {_parents}");
	
	if(is_instanceof(_node, Node_Collection) && !_node.managedRenderOrder)
		__topoSort(_arr, _node.nodes, _sorted, _project);
	
	for( var i = 0, n = array_length(_parents); i < n; i++ ) 
		__sortNode(_arr, _parents[i], _sorted, _nodeMap, _project);
	
	if(struct_has(_sorted, _node.node_id)) return;
	array_push(_arr, _node);
	_sorted[$ _node.node_id] = 1;
	_node.__nextNodes        = noone;
	_node.__nextNodesToLoop  = noone;
		
	// print($"        > Adding > {_node.name} | {_arr}");
}

function __topoSort(_arr = [], _nodeArr = [], _sorted = {}, _project = PROJECT) {
	var _leaf     = [];
	var _leftOver = [];
	var _global   = _nodeArr == _project.nodes;
	var _nodeMap  = _global? undefined : {};
	__temp_nodeList = _nodeArr;
	
	for( var i = 0, n = array_length(_nodeArr); i < n; i++ ) {
		var _node   = _nodeArr[i];
		var _isLeaf = true;
		
		if(!_global) _nodeMap[$ _node.node_id]  = 1;
		
		if(is_instanceof(_node, Node_Collection_Inline) && !_node.is_root) { array_push(_leftOver, _node); continue; }
		
		if(_node.attributes.show_update_trigger && !array_empty(_node.updatedOutTrigger.getJunctionTo())) {
			_isLeaf = false;
			
		} else {
			for( var j = 0, m = array_length(_node.outputs); j < m; j++ ) {
				var _to = _node.outputs[j].getJunctionTo();
				
				if(_global) _isLeaf = _isLeaf &&  array_empty(_to);
				else        _isLeaf = _isLeaf && !array_any(_to, function(_val) /*=>*/ {return array_exists(__temp_nodeList, _val.node)});
				
				if(!_isLeaf) break;
			}
		}
		
		if(_isLeaf) array_push(_leaf, _node);
	}
	
	// print($"Leaf: {_leaf}");
	
	for( var i = 0, n = array_length(_leaf); i < n; i++ ) 
		__sortNode(_arr, _leaf[i], _sorted, _nodeMap, _project);
	
	for( var i = 0, n = array_length(_leftOver); i < n; i++ ) {
		if(!struct_has(_sorted, _leftOver[i].node_id))
			array_insert(_arr, 0, _leftOver[i]);
	}
	
	__temp_nodeList = [];
	return _arr;
}

function __nodeLeafList(_arr) {
	var nodes     = [];
	var nodeNames = [];
	
	for( var i = 0, n = array_length(_arr); i < n; i++ ) {
		var _node = _arr[i];
		
		if(!_node.active)			 { LOG_LINE_IF(global.FLAG.render == 1, $"Reject {_node.internalName} [inactive]");       continue; }
		if(!_node.isLeafList(_arr))  { LOG_LINE_IF(global.FLAG.render == 1, $"Reject {_node.internalName} [not leaf]");       continue; }
		if(!_node.isRenderable())    { LOG_LINE_IF(global.FLAG.render == 1, $"Reject {_node.internalName} [not renderable]"); continue; }
		
		array_push(nodes, _node);
		array_push(nodeNames, _node.internalName);
	}
	
	LOG_LINE_IF(global.FLAG.render == 1, $"Push node {nodeNames} to queue");
	return nodes;
}

function __nodeIsRenderLeaf(_node) {
	if(is_undefined(_node)) { LOG_IF(global.FLAG.render == 1, $"Skip undefiend		  [{_node}]"); return false; }
	if(!is(_node, Node))    { LOG_IF(global.FLAG.render == 1, $"Skip non-node		  [{_node}]"); return false; }
	
	if(_node.is_group_io)   { LOG_IF(global.FLAG.render == 1, $"Skip group IO		  [{_node.internalName}]"); return false; }
	
	if(!_node.active)				   { LOG_IF(global.FLAG.render == 1, $"Skip inactive         [{_node.internalName}]"); return false; }
	if(!_node.isRenderActive())		   { LOG_IF(global.FLAG.render == 1, $"Skip render inactive  [{_node.internalName}]"); return false; }
	if(!_node.attributes.update_graph) { LOG_IF(global.FLAG.render == 1, $"Skip non-auto update  [{_node.internalName}]"); return false; }
			
	if(_node.passiveDynamic) { _node.forwardPassiveDynamic();  LOG_IF(global.FLAG.render == 1, $"Skip passive dynamic  [{_node.internalName}]"); return false; }
	
	if(!_node.isActiveDynamic()) { LOG_IF(global.FLAG.render == 1, $"Skip rendered static  [{_node.internalName}]"); return false; }
	// if(!_node.isLeaf())          { LOG_IF(global.FLAG.render == 1, $"Skip connected  [{_node.internalName}]");       return false; }
	
	if(_node.inline_context != noone && _node.inline_context.managedRenderOrder) {
		LOG_IF(global.FLAG.render == 1, $"Skip managedRenderOrder  [{_node.internalName}]"); 
		_node.forwardPassiveDynamic(); 
		return false;
	}
	
	return true;
}

function Render(_project = PROJECT, _partial = false, _runAction = false) { 
	if(RENDERING == undefined) {
		WILL_RENDERING = undefined;
		return new RenderObject(_project, _partial, _runAction);
	}
	
	WILL_RENDERING = { project: _project, partial: _partial };
	return noone; 
}

function RenderSync(_project = PROJECT, _partial = false, _runAction = false) {
	var _ = new RenderObject(_project, _partial, _runAction).Rendering(infinity);
}

function RenderObject(_project = PROJECT, _partial = false, _runAction = false) constructor {
	project   = _project;
	partial   = _partial;
	runAction = _runAction;
	
	RENDERING = self;
	// node_auto_organize(_project.nodes);
	// print($"======================== RENDER {GLOBAL_CURRENT_FRAME} ========================")
	
	LOG_END();

	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render, $"============================== RENDER START [{partial? "PARTIAL" : "FULL"}] [frame {GLOBAL_CURRENT_FRAME}] ==============================");
	
	project.preRender();
	t  = get_timer();
	t1 = get_timer();
	
	render_time = 0;
	leaf_time   = 0;
	error       = 0;
	reset_all   = !partial;
	
	if(reset_all) {
		LOG_IF(global.FLAG.render == 1, $"xxxxxxxxxx Resetting {array_length(project.nodeTopo)} nodes xxxxxxxxxx");
		array_foreach(project.allNodes, function(n) /*=>*/ {return n.setRenderStatus(false)});
	}
	
	// get leaf node
	LOG_IF(global.FLAG.render == 1, $"----- Finding leaf from {array_length(project.nodeTopo)} nodes -----");
	RENDER_QUEUE.clear();
	array_foreach(project.nodeTopo, function(n) /*=>*/ { 
		n.passiveDynamic = false;
		n.render_time    = 0;
	});
	
	array_foreach(project.nodeTopo, function(n) /*=>*/ { 
		if(!__nodeIsRenderLeaf(n)) return;
		
		LOG_IF(global.FLAG.render == 1, $"    Found leaf [{n.internalName}]");
		RENDER_QUEUE.enqueue(n);
		n.forwardPassiveDynamic();
	});
	
	if(PROFILER_STAT) array_push(PROFILER_DATA, {
		type  : "message",
		level : 1, 
		node  : undefined,
		text  : $"---- {RENDER_QUEUE.size()} leaves ----",
	});
	
	leaf_time = get_timer() - t;
	LOG_IF(global.FLAG.render >= 1, $"Get leaf complete: found {RENDER_QUEUE.size()} leaves in {(get_timer() - t) / 1000} ms."); t = get_timer();
	LOG_IF(global.FLAG.render == 1,  "================== Start rendering ==================");
	
	function Rendering(_maxDuration = PREFERENCES.render_max_time) {
		var _time_frame = get_timer();
		var _rendered   = 0;
		
		try {
			// render forward
			while(!RENDER_QUEUE.empty()) {
				LOG_BLOCK_START();
				// LOG_IF(global.FLAG.render == 1, $"➤➤➤➤➤➤ CURRENT RENDER QUEUE {RENDER_QUEUE} [{RENDER_QUEUE.size()}] ");
				
				var rendering  = RENDER_QUEUE.dequeue();
				var renderable = rendering.isRenderable();
				
				// LOG_IF(global.FLAG.render == 1, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"} ({rendering.rendered})");
				
				if(renderable) {
					var render_pt = get_timer();
					
					// print($" >>> Rendering: {rendering.name}");
					rendering.doUpdate(); 
					render_time += get_timer() - render_pt;
					_rendered++;
					
					var nextNodes = rendering.getNextNodes();
					
					for( var i = 0, n = array_length(nextNodes); i < n; i++ ) {
						var nextNode = nextNodes[i];
						if(!is(nextNode, __Node_Base) || !nextNode.isRenderable()) continue;
						
						// LOG_IF(global.FLAG.render == 1, $"→→ Push {nextNode.internalName} to queue.");
						RENDER_QUEUE.enqueue(nextNode);
						
						if(PROFILER_STAT) array_push(rendering.nextn, nextNode);
					}
					
					// if(runAction && rendering.hasInspector1Update()) rendering.inspector1Update();
						
					if(PROFILER_STAT) rendering.summarizeReport(render_pt);
					
				} else if(rendering.force_requeue)
					RENDER_QUEUE.enqueue(rendering);
				
				LOG_BLOCK_END();
				
				if(_maxDuration != infinity && (get_timer() - _time_frame) / 1_000_000 >= _maxDuration) {
					// print($"Break rendering midframe after {_rendered} nodes.")
					return false;
				}
			}
		
		} catch(e) {
			noti_warning(exception_print(e));
		}
		
		render_time /= 1000;
			
		LOG_IF(global.FLAG.renderTime || global.FLAG.render >= 1, $"=== RENDER FRAME {GLOBAL_CURRENT_FRAME} COMPLETE IN {(get_timer() - t1) / 1000} ms ===\n");
		LOG_IF(global.FLAG.render >  1, $"=== RENDER SUMMARY STA ===");
		LOG_IF(global.FLAG.render >  1, $"  total time:  {(get_timer() - t1) / 1000} ms");
		LOG_IF(global.FLAG.render >  1, $"  leaf:        {leaf_time / 1000} ms");
		LOG_IF(global.FLAG.render >  1, $"  render loop: {(get_timer() - t) / 1000} ms");
		LOG_IF(global.FLAG.render >  1, $"  render only: {render_time} ms");
		LOG_IF(global.FLAG.render >  1, $"=== RENDER SUMMARY END ===");
		
		// print("\n============== render stat ==============");
		// print($"Get value hit: {global.getvalue_hit}");
		
		project.postRender();
		
		LOG_END();
		RENDERING = undefined;
		PANEL_GRAPH.draw_refresh = true;
		
		return true;
	}
	
	Rendering();
}

function __renderListReset(arr) { 
	array_foreach(arr, function(a) /*=>*/ { a.setRenderStatus(false); if(has(a, "nodes")) __renderListReset(a.nodes); });
}

function RenderList(arr) {
	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render == 1, $"=============== RENDER LIST START [{array_length(arr)}] ===============");
	var queue = ds_queue_create();
	
	try {
		var rendering = noone;
		var error	  = 0;
		var t		  = current_time;
		
		__renderListReset(arr);
		
		// get leaf node
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
			var _node = arr[i];
			_node.passiveDynamic = false;
		}
		
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
			var _node = arr[i];
			
			if(!__nodeIsRenderLeaf(_node))
				continue;
			
			LOG_IF(global.FLAG.render == 1, $"Found leaf {_node.internalName}");
			ds_queue_enqueue(queue, _node);
			_node.forwardPassiveDynamic();
		}
		
		LOG_IF(global.FLAG.render == 1, "Get leaf complete: found " + string(ds_queue_size(queue)) + " leaves.");
		LOG_IF(global.FLAG.render == 1, "=== Start rendering ===");
		
		// render forward
		while(!ds_queue_empty(queue)) {
			LOG_BLOCK_START();
			rendering = ds_queue_dequeue(queue)
			var renderable = rendering.isRenderable();
			
			LOG_IF(global.FLAG.render == 1, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"}");
			
			if(renderable) {
				rendering.doUpdate();
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0, n = array_length(nextNodes); i < n; i++ ) {
					var _node = nextNodes[i];
					if(array_exists(arr, _node) && _node.isRenderable())
						ds_queue_enqueue(queue, _node);
				}
			} 
			
			LOG_BLOCK_END();
		}
	
	} catch(e) {
		noti_warning(exception_print(e));
	}
	
	LOG_BLOCK_END();	
	LOG_IF(global.FLAG.render == 1, "=== RENDER COMPLETE ===\n");
	LOG_END();
	
	ds_queue_destroy(queue);
}

 ////- Tree
 
function NodeTreeItem(_node = noone) constructor {
	x = 0;
	y = 0;
	
	node     = _node;
	children = [];
	parent   = noone;
	height   = 1;
	
	hovering = false;
	selected = false;
	expanded = true;
	
	if(node != noone) {
		var _fr = node.getNodeFrom();
		for( var i = 0, n = array_length(_fr); i < n; i++ ) {
			children[i] = new NodeTreeItem(_fr[i]);
			children[i].parent = self;
		}
	}
	
	static pokeHeight = function() { return array_length(children) == 1? children[0] : noone; }
	
	static setHeight = function() {
		var _len = array_length(children);
		if(_len == 0) return;
		
		if(_len == 1) {
			var hh = 0;
			var lh, ch = self;
			
			do {
				lh = ch;
				ch = ch.pokeHeight();
				hh++;
			} until(ch == noone);
			
			height = hh;
			
			for( var i = 0, n = array_length(lh.children); i < n; i++ ) 
				lh.children[i].setHeight();
			
		} else {
			for( var i = 0, n = array_length(children); i < n; i++ ) 
				children[i].setHeight();
		}
	}

	static toggleExpand = function(_exp) {
		
		var _len = array_length(children);
		if(_len > 1) { expanded = _exp; return; } 
		
		if(_len == 1) children[0].toggleExpand();
	}
}

function NodeTreeSort(_project = PROJECT, _nlist = _project.nodes) {
	var roots = [];
	var tree  = [];
	
	for( var i = 0, n = array_length(_nlist); i < n; i++ ) {
		var _node = _nlist[i];
		if(is(_node, Node_Frame)) continue;
		
		if(is(_node, Node_Collection)) 
			_node.nodeTree = NodeTreeSort(_project, _node.nodes);
		
		if(array_empty(_node.getNodeTo())) 
			array_push(tree, new NodeTreeItem(_node));
	}
	
	array_foreach(tree, function(t) /*=>*/ {return t.setHeight()});
	
	var _tree = new NodeTreeItem();
	    _tree.children = tree;
	   
	if(_nlist == _project.nodes)
		_project.nodeTree = _tree;
		
	return _tree;
}