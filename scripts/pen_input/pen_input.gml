#region global
	globalvar PEN_USE; PEN_USE      = false;
	globalvar PEN_POOL; PEN_POOL     = 0;
	globalvar PEN_CONTACT; PEN_CONTACT  = false;
	globalvar PEN_PRESSED; PEN_PRESSED  = false;
	globalvar PEN_RELEASED; PEN_RELEASED = false;
	
	globalvar PEN_X; PEN_X        = 0;
	globalvar PEN_Y; PEN_Y        = 0;
	globalvar PEN_X_DELTA; PEN_X_DELTA  = 0;
	globalvar PEN_Y_DELTA; PEN_Y_DELTA  = 0;
	globalvar PEN_PRESSURE; PEN_PRESSURE = 0;
	
	globalvar PEN_RIGHT_CLICK; PEN_RIGHT_CLICK   = false;
	globalvar PEN_RIGHT_PRESS; PEN_RIGHT_PRESS   = false;
	globalvar PEN_RIGHT_RELEASE; PEN_RIGHT_RELEASE = false;
#endregion

function __initPen() {
	if(os_type != os_windows) return;
	
	var c = tabletstuff_get_init_error_code();
	if (c != tabletstuff_error_none)
	    show_error("Unable to initialize TabletStuff. Code=" + tabletstuff_error_to_string(c), true);
}