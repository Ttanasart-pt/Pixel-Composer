function rearrange_priority(node, newpri) {
	if(node.anim_priority == floor(newpri)) return;
	node.anim_priority = newpri;
	
	var amo = ds_map_size(PROJECT.nodeMap);
	var k   = ds_map_find_first(PROJECT.nodeMap);
	var pr  = ds_priority_create();
	
	repeat(amo) {
		var _node = PROJECT.nodeMap[? k];
		k = ds_map_find_next(PROJECT.nodeMap, k);
		
		if(!_node.active) continue;
		ds_priority_add(pr, _node, _node.anim_priority);
	}
	
	var _prRun = 0;
	while(!ds_priority_empty(pr)) {
		var _node = ds_priority_delete_min(pr);
		_node.anim_priority = _prRun++;
	}
	
	ds_priority_destroy(pr);
	
	PANEL_ANIMATION.updatePropertyList();
}