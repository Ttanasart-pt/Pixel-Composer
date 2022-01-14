function Node_create_Fracture(_x, _y) {
	var node = new Node_Fracture(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Fracture(_x, _y) : Node(_x, _y) constructor {
	name = "Fracture";
	auto_update = false;
	use_cache = true;
	
}