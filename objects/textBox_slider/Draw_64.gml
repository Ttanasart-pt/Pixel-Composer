/// @description 
if(tb == noone) exit;

MOUSE_BLOCK = true;
CURSOR_LOCK = true;

if(mouse_check_button_pressed(mb_right)) {
	tb._input_text = string_real(def_val);
	tb.apply();
	tb.sliding = false;
	tb.deactivate();
	
	UNDO_HOLDING = false;
	tb = noone;
	exit;
}

var _s  = tb.slide_speed;
var _dx = window_mouse_get_delta_x();

if(key_mod_press(CTRL)) _s *= 10;
if(key_mod_press(ALT))  _s /= 10;

cur_val += _dx * _s;

if(tb.slide_range != noone) 
	cur_val = clamp(cur_val, tb.curr_range[0], tb.curr_range[1]);

var _val = value_snap(cur_val, _s);
if(tb.slide_int)
	_val = round(_val);

tb._input_text = string_real(_val);
if(tb.apply()) UNDO_HOLDING = true;

tb = noone;
CURSOR = cr_none;