function Node_PB_Box(_x, _y, _group = noone) : Node_PB(_x, _y, _group) constructor {
	name = "PB Box";
	
	newInput(0, nodeValue_Int("Layer Shift", self, 0 ))
}