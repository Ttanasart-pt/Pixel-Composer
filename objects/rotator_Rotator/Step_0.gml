/// @description Insert description here
var dx  = mouse_rx - drag_mx;
var dy  = mouse_ry - drag_my;

drag_mx = mouse_rx;
drag_my = mouse_ry;

drag_sx += dx;
drag_sy += dy;

var _dirr = point_direction(drag_cx, drag_cy, drag_sx, drag_sy);
delta     = angle_difference(_dirr, drag_sa);
delta_acc += delta;
drag_sa   = _dirr;