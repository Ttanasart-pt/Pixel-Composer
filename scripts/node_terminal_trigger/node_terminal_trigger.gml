function Node_Terminal_Trigger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Terminal Trigger";
	w     = 96;
	min_h = 32 + 24 * 1;
	
	draw_padding = 8;
	
	outputs[| 0] = nodeValue("Terminal", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, noone);
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_bbox(s_node_terminal_trigger, 0, bbox);
	}
}

function Terminal_Trigger() {
	var keys = ds_map_keys_to_array(PROJECT.nodeMap);
	
	for( var i = 0, n = array_length(keys); i < n; i++ ) {
		var node = PROJECT.nodeMap[? keys[i]];
		if(!is_instanceof(node, Node_Terminal_Trigger)) continue;
		
		node.outputs[| 0].setValue(true);
	}
}