function LineDrawer(thick) constructor {
	ox = undefined;
	oy = undefined;
	oc = undefined;
	
	th = thick;
	
	x2 = undefined; y2 = undefined;
	x3 = undefined; y3 = undefined;
	
	draw_primitive_begin(pr_trianglestrip);
	
	static add = function(_x, _y, _c = oc) {
		if(ox != undefined) {
			var dx = _x - ox;
			var dy = _y - oy;
			var line_length = point_distance(_x, _y, ox, oy);
			var px = -dy / line_length * th / 2;
			var py = dx / line_length * th / 2;
	
			// Calculate vertices of the rectangle
			var _x0 = x2 ?? ox + px;
			var _y0 = y2 ?? oy + py;
			var _x1 = x3 ?? ox + px;
			var _y1 = y3 ?? oy + py;
			var _x2 = _x + px;
			var _y2 = _y + py;
			var _x3 = _x - px;
			var _y3 = _y - py;
			
			// Draw vertices
			draw_vertex_color(_x0, _y0, _c, 1);
			draw_vertex_color(_x1, _y1, _c, 1);
			draw_vertex_color(_x2, _y2, oc, 1);
			draw_vertex_color(_x3, _y3, oc, 1);
			
			x2 = _x2; y2 = _y2;
			x3 = _x3; y3 = _y3;
		}
		
		ox = _x;
		oy = _y;
		oc = _c;
	}
	
	static finish = function() {
		draw_primitive_end();
	}
}