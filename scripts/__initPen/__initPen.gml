globalvar PEN_USE, PEN_CONTACT, PEN_RELEASED, PEN_PRESSURE, PEN_X, PEN_Y;
globalvar PEN_RIGHT_CLICK, PEN_RIGHT_PRESS, PEN_RIGHT_RELEASE;

PEN_X = 0;
PEN_Y = 0;

PEN_CONTACT  = false;
PEN_PRESSURE = 0;

PEN_RIGHT_CLICK   = false;
PEN_RIGHT_PRESS   = false;
PEN_RIGHT_RELEASE = false;

function __initPen() {
	var c = tabletstuff_get_init_error_code();
	if (c != tabletstuff_error_none)
	    show_error("Unable to initialize TabletStuff. Code=" + tabletstuff_error_to_string(c), true);
}