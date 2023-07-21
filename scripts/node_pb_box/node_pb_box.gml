function Node_PB_Box(_x, _y, _group = noone) : Node_PB(_x, _y, _group) constructor {
	name = "PB Box";
	
	inputs[| 0] = nodeValue("Layer Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
}