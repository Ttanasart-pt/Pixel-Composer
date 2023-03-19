function Point(x = 0, y = 0) constructor {
	if(is_array(x)) {
		self.x = x[0];
		self.y = x[1];
	} else {
		self.x = x;
		self.y = y;
	}
	
	u = 0;
	v = 0;
	
	static add      = function(x, y)	{ self.x += x;   self.y += y;   return self; }
	static addPoint = function(p)		{ self.x += p.x; self.y += p.y; return self; }
	static lerpTo   = function(p, rat)	{ return new Point( lerp(x, p.x, rat), lerp(y, p.y, rat) ); }
	static directionTo  = function(p)	{ return point_direction(x, y, p.x, p.y); }
	static distanceTo   = function(p)	{ return point_distance(x, y, p.x, p.y); }
	
	static equal = function(p) { return x == p.x && y == p.y; }
	static clone = function(){ return new Point(x, y); }
	static toArray = function() { return [ x, y ]; }
}