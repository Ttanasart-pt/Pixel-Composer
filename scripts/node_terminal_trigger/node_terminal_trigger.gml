function Node_Terminal_Trigger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Terminal Trigger";
	draw_padding = 8;
	setDrawIcon(s_node_terminal_trigger);
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Terminal", VALUE_TYPE.trigger, false ));
	
}