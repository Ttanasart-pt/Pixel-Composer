function Node_3D(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "3D";
	
	is_3D = true;
	
	//inputs[| 0] = nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [])
	//	.setVisible(true, true);
	
	//outputs[| 0] = nodeValue("Shuffled array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static submit   = function(params = {}, shader = noone) {}
	static submitUI = function(params = {}, shader = noone) {}
	
	static update = function(frame = PROJECT.animator.current_frame) {}
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {}
}