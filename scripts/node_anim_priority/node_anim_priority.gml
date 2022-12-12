function rearrange_priority(node, newpri) {
	if(node.anim_priority == newpri) return;
	
	var prev = node.anim_priority;
	var down = prev > newpri;
	node.anim_priority = newpri;
	
	var amo = ds_map_size(NODE_MAP);
	var k = ds_map_find_first(NODE_MAP);
	
	repeat(amo) {
		var _node = NODE_MAP[? k];
		k = ds_map_find_next(NODE_MAP, k);
		
		if(!_node.active) continue;
		if(_node == node) continue;
			
		if(down && _node.anim_priority >= newpri && _node.anim_priority <= prev)
			_node.anim_priority++;
		if(!down && _node.anim_priority <= newpri && _node.anim_priority >= prev)
			_node.anim_priority--;
	}
	
	PANEL_ANIMATION.updatePropertyList();
}