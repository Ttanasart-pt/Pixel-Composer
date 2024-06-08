function rearrange_priority(node, newpri) {
	if(node.anim_priority == floor(newpri)) return;
	node.anim_priority = newpri;
	
	var k   = ds_map_find_first(PROJECT.nodeMap);
	var pr  = ds_priority_create();
	
	for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
		var _node = PROJECT.allNodes[i];
		
		if(!_node.active) continue;
		ds_priority_add(pr, _node, _node.anim_priority);
	}
	
	var _prRun = 0;
	while(!ds_priority_empty(pr)) {
		var _node = ds_priority_delete_min(pr);
		_node.anim_priority = _prRun++;
	}
	
	ds_priority_destroy(pr);
}