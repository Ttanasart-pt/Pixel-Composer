function Node_PCX(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Compute Node";
	setDimension(96, 48);;
	
	destroy_when_upgroup = true;
}