function __MK_Tree_Segment(_x, _y, _t) constructor {
	x = _x;
	y = _y;
	thickness = _t;
}

function __MK_Tree() constructor {
	x = 0;
	y = 0;
	
	length = [ 0, 0 ];
	thick  = [ 0, 0 ];
	angle  = [ 0, 0, 0, 0, 0 ];
	
	amount   = 1;
	segments = [];
	children = [];
	
	static grow = function() {
		segments = array_create(amount + 1);
		
		var ox = x, oy = y, i = 1;
		var tt = random_range(thick[0], thick[1]);
		
		segments[0] = new __MK_Tree_Segment(ox, oy, tt);
		
		repeat(amount) {
			var ll = random_range(length[0], length[1]);
			var aa = rotation_random_eval(angle);
			
			ox += lengthdir_x(ll, aa);
			oy += lengthdir_y(ll, aa);
			
			segments[i++] = new __MK_Tree_Segment(ox, oy);
		}
	}
	
}