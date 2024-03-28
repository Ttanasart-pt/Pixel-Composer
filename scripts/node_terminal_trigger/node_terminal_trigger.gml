function Node_Terminal_Trigger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Terminal Trigger";
	setDimension(96, 32 + 24 * 1);
	
	draw_padding = 8;
	
	outputs[| 0] = nodeValue("Terminal", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, noone);
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_sprite_bbox(s_node_terminal_trigger, 0, bbox);
	}
}