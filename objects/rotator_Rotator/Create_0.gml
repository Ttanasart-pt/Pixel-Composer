/// @description Insert description here
drag_mx   = mouse_mx;
drag_my   = mouse_my;

drag_sx   = 0;
drag_sy   = 0;

drag_cx  = 0;
drag_cy  = 0;

drag_sa  = 0;

delta     = 0;
delta_acc = 0;

function init(_m, cx, cy) {
	drag_sx = _m[0];
	drag_sy = _m[1];
	drag_cx = cx;
	drag_cy = cy;
	drag_sa = point_direction(drag_cx, drag_cy, drag_sx, drag_sy);
	
	return self;
}