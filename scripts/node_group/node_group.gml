function Node_create_Group(_x, _y) {
	var node = new Node_Group(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Group(_x, _y) : Node_Collection(_x, _y) constructor {
	name  = "Group";
	color = c_ui_yellow;
	icon  = s_group_16;
}