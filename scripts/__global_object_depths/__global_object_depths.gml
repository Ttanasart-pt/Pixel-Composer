function __global_object_depths() {
	// Initialise the global array that allows the lookup of the depth of a given object
	// GM2.0 does not have a depth on objects so on import from 1.x a global array is created
	// NOTE: MacroExpansion is used to insert the array initialisation at import time
	gml_pragma( "global", "__global_object_depths()");

	// insert the generated arrays here
	global.__objectDepths[0] = -10; // obj_fd_example_slider
	global.__objectDepths[1] = 0; // obj_fd_example_leaf
	global.__objectDepths[2] = -10; // obj_fd_example_button_dissipation_type
	global.__objectDepths[3] = -10; // obj_fd_example_toggle_box
	global.__objectDepths[4] = -10; // obj_fd_example_dropdown
	global.__objectDepths[5] = 0; // obj_fd_rectangle
	global.__objectDepths[6] = -10; // obj_fd_example_button_change_room
	global.__objectDepths[7] = 0; // obj_fd_example_main


	global.__objectNames[0] = "obj_fd_example_slider";
	global.__objectNames[1] = "obj_fd_example_leaf";
	global.__objectNames[2] = "obj_fd_example_button_dissipation_type";
	global.__objectNames[3] = "obj_fd_example_toggle_box";
	global.__objectNames[4] = "obj_fd_example_dropdown";
	global.__objectNames[5] = "obj_fd_rectangle";
	global.__objectNames[6] = "obj_fd_example_button_change_room";
	global.__objectNames[7] = "obj_fd_example_main";


	// create another array that has the correct entries
	var len = array_length(global.__objectDepths);
	global.__objectID2Depth = [];
	for( var i=0; i<len; ++i ) {
		var objID = asset_get_index( global.__objectNames[i] );
		if (objID >= 0) {
			global.__objectID2Depth[ objID ] = global.__objectDepths[i];
		} // end if
	} // end for


}
