function BoundingBox(minx = noone, miny = noone, maxx = noone, maxy = noone) constructor {
	self.minx = minx;
	self.miny = miny;
	self.maxx = maxx;
	self.maxy = maxy;
	
	self.width  = 0;
	self.height = 0;
	
	static addPoint = function(px, py) {
		minx = minx == noone? px : min(minx, px);
		miny = miny == noone? py : min(miny, py);
		maxx = maxx == noone? px : max(maxx, px);
		maxy = maxy == noone? py : max(maxy, py);
		
		width  = maxx - minx;
		height = maxy - miny;
	}
	
	static lerpTo = function(bbox, rat) {
		var b = new BoundingBox(
			lerp( minx, bbox.minx, rat ), 
			lerp( miny, bbox.miny, rat ), 
			lerp( maxx, bbox.maxx, rat ), 
			lerp( maxy, bbox.maxy, rat )
		);		
		return b;
	}
	
	static clone = function() { return new BoundingBox(minx, miny, maxx, maxy); }
}

function node_bbox(x0, y0, x1, y1) constructor {
	self.x0 = x0; 
	self.x1 = x1; 
	self.y0 = y0; 
	self.y1 = y1; 
	
	xc = (x0 + x1) / 2; 
	yc = (y0 + y1) / 2;
	w  = x1 - x0; 
	h  = y1 - y0;
	
	static clone = function() { return node_bbox(x0, y0, x1, y1); };
}