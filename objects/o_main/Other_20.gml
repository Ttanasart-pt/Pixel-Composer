/// @description Pen tablet event

var e; e = tabletstuff_get_event_data();
if (!ds_map_exists(e, "pointer_info_pen")) exit;

/*
    See:
        https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-pointer_pen_info
    for flags and constants in the fields.
*/

var f = e[? "pointer_info_flags"];

var pp = e[? "pointer_info_pen_pressure"];
var pr = e[? "pointer_info_pen_rotation"];
var px = e[? "pointer_info_pixel_location_x"] - window_get_x();
var py = e[? "pointer_info_pixel_location_y"] - window_get_y();
var pb = e[? "pointer_info_button_change_type"];

var tx = e[? "pointer_info_pen_tilt_x"];
var ty = e[? "pointer_info_pen_tilt_y"];

PEN_X_DELTA = px - PEN_X;
PEN_Y_DELTA = py - PEN_Y;

PEN_X = px;
PEN_Y = py;

// print($"{PEN_X} | {PEN_X_DELTA}");

PEN_PRESSURE = pp;

var contact = bool(f & 0x4);
if(PEN_CONTACT && !contact)
	PEN_RELEASED = true;
PEN_CONTACT = contact;

var b1 = bool(f & 0x10); // POINTER_FLAG_FIRSTBUTTON
var b2 = bool(f & 0x20); // POINTER_FLAG_SECONDBUTTON

if(!PEN_RIGHT_CLICK && b2) PEN_RIGHT_PRESS   = true;
if(PEN_RIGHT_CLICK && !b2) PEN_RIGHT_RELEASE = true;

PEN_RIGHT_CLICK = b2;

//print($"{PEN_RIGHT_CLICK} | {PEN_RIGHT_PRESS}, {PEN_RIGHT_RELEASE}");
if(f & 0x2) {
	PEN_POOL = PREFERENCES.pen_pool_delay;
	PEN_USE  = true;
}