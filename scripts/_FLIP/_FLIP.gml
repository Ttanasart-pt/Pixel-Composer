function FLIP_Obstracle(domain) constructor {
	x = 0;
	y = 0;
	r = 20;
	
	self.domain = domain;
	raw = FLIP_createObstracle(domain);
	
	static apply = function() {
		FLIP_setObstacle_circle(domain, raw, x, y, r, false);
		return self;
	}
	
	static draw = function() {
		draw_set_color(c_red);
		draw_circle(x, y, r, false);
		return self;
	}
}