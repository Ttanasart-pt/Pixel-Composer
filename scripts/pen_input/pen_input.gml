globalvar PEN_USE, PEN_POOL, PEN_CONTACT, PEN_RELEASED, PEN_PRESSURE;
globalvar PEN_X, PEN_Y, PEN_X_DELTA, PEN_Y_DELTA;
globalvar PEN_RIGHT_CLICK, PEN_RIGHT_PRESS, PEN_RIGHT_RELEASE;

PEN_USE  = false;
PEN_POOL = 0;

PEN_X = 0;
PEN_Y = 0;

PEN_X_DELTA = 0;
PEN_Y_DELTA = 0;

PEN_CONTACT  = false;
PEN_PRESSURE = 0;

PEN_RIGHT_CLICK   = false;
PEN_RIGHT_PRESS   = false;
PEN_RIGHT_RELEASE = false;

function __initPen() {
	if(os_type != os_windows) return;
	
	var c = tabletstuff_get_init_error_code();
	if (c != tabletstuff_error_none)
	    show_error("Unable to initialize TabletStuff. Code=" + tabletstuff_error_to_string(c), true);
}