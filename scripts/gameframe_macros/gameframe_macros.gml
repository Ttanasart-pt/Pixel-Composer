global.__display_gui_args = [0, 0, 0, 0, 0];

#macro __display_set_gui_size_base display_set_gui_size
#macro display_set_gui_size __display_set_gui_size_hook
function __display_set_gui_size_hook(_width, _height) {
	__display_set_gui_size_base(_width, _height);
	global.__display_gui_args[@0] = -1;
	global.__display_gui_args[@1] = _width;
	global.__display_gui_args[@2] = _height;
	global.__display_gui_args[@3] = 0;
	global.__display_gui_args[@4] = 0;
}

#macro __display_set_gui_maximize_base display_set_gui_maximize
#macro __display_set_gui_maximise_base display_set_gui_maximise
#macro display_set_gui_maximize __display_set_gui_maximize_hook
#macro display_set_gui_maximise __display_set_gui_maximize_hook
function __display_set_gui_maximize_hook() {
	global.__display_gui_args[@0] = argument_count;
	var i = 0;
	for (; i < argument_count; i++) global.__display_gui_args[@i + 1] = argument[i];
	for (; i < 4; i++) global.__display_gui_args[@i + 1] = 0;
}

function __display_gui_restore() {
	var _args = global.__display_gui_args;
	switch (_args[0]) {
		case -1: __display_set_gui_size_base(_args[1], _args[2]); break;
		case  0: __display_set_gui_maximise_base(); break;
		case  1: __display_set_gui_maximise_base(_args[1]); break;
		case  2: __display_set_gui_maximise_base(_args[1], _args[2]); break;
		case  3: __display_set_gui_maximise_base(_args[1], _args[2], _args[3]); break;
		case  4: __display_set_gui_maximise_base(_args[1], _args[2], _args[3], _args[4]); break;
	}
}

