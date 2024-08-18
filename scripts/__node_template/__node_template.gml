function Node_Template(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "";
	
	newInput(0, nodeValue_Surface("", self));
	
	outputs[0] = nodeValue_Output("", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static update = function() {}
}