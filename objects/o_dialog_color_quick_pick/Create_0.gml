/// @description 
depth = -9999;

with(o_dialog_color_quick_pick) { if(id != other.id) instance_destroy(); }

selecting = noone;
onApply   = noone;

palette   = array_clone(DEF_PALETTE);
use_mouse = mouse_lclick();
use_key   = 0;
