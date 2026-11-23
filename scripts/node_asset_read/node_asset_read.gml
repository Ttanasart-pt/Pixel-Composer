function Node_Asset_Read(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Asset";
	color = COLORS.node_blend_input;
	
	newInput( 0, nodeValue_FPath(    "Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: FILE_SEL_IMAGE }).rejectArray();
}