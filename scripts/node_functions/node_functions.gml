#macro def_surf_size PREF_MAP[? "default_surface_side"]
#macro def_surf_size2 [PREF_MAP[? "default_surface_side"], PREF_MAP[? "default_surface_side"]]

function node_input_visible(node, vis) {
	node.show_in_inspector	= vis;
}