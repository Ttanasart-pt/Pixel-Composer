function Node_Terminal_Trigger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Terminal Trigger";
	setDimension(96, 48);
	
	draw_padding = 8;
	
	newOutput(0, nodeValue_Output("Terminal", VALUE_TYPE.trigger, false ));
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_terminal_trigger, 0, bbox);
	}
}