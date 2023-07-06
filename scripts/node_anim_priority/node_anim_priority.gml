function rearrange_priority(node, newpri) {
	if(node.anim_priority == newpri) return;
	
	var prev = node.anim_priority;
	var down = prev > newpri;
	node.anim_priority = newpri;
	
	var amo = ds_map_size(PROJECT.nodeMap);
	var k = ds_map_find_first(PROJECT.nodeMap);
	
	repeat(amo) {
		var _node = PROJECT.nodeMap[? k];
		k = ds_map_find_next(PROJECT.nodeMap, k);
		
		if(!_node.active) continue;
		if(_node == node) continue;
			
		if(down && _node.anim_priority >= newpri && _node.anim_priority <= prev)
			_node.anim_priority++;
		if(!down && _node.anim_priority <= newpri && _node.anim_priority >= prev)
			_node.anim_priority--;
	}
	
	PANEL_ANIMATION.updatePropertyList();
}