function BoundingBox(minx = noone, miny = noone, maxx = noone, maxy = noone) constructor {
	self.minx = minx;
	self.miny = miny;
	self.maxx = maxx;
	self.maxy = maxy;
	
	self.width  = maxx - minx;
	self.height = maxy - miny;
	
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

function BoundingBox3D(minx = noone, miny = noone, minz = noone, maxx = noone, maxy = noone, maxz = noone) : BoundingBox(minx, miny, maxx, maxy) constructor {
	self.minz = minz;
	self.maxz = maxz;
	
	depth  = maxz - minz;
	
	static addPoint = function(px, py, pz) {
		minx = minx == noone? px : min(minx, px);
		miny = miny == noone? py : min(miny, py);
		minz = minz == noone? pz : min(minz, pz);
		
		maxx = maxx == noone? px : max(maxx, px);
		maxy = maxy == noone? py : max(maxy, py);
		maxz = maxz == noone? pz : max(maxz, pz);
		
		width  = maxx - minx;
		height = maxy - miny;
		depth  = maxz - minz;
	}
	
	static lerpTo = function(bbox, rat) {
		var b = new BoundingBox3D(
			lerp( minx, bbox.minx, rat ), 
			lerp( miny, bbox.miny, rat ), 
			lerp( minz, bbox.minz, rat ), 
			
			lerp( maxx, bbox.maxx, rat ), 
			lerp( maxy, bbox.maxy, rat ),
			lerp( maxz, bbox.maxz, rat ),
		);		
		return b;
	}
	
	static clone = function() { return new BoundingBox3D(minx, miny, minz, maxx, maxy, maxz); }
}

function BBOX() { return new __BBOX(); }
function __BBOX() constructor {
	x0 = 0; x1 = 0; 
	y0 = 0; y1 = 0; 
	
	xc = 0; yc = 0;
	w  = 0; h  = 0;
	
	static fromPoints = function(x0, y0, x1, y1) {
		self.x0 = x0; 
		self.x1 = x1; 
		self.y0 = y0; 
		self.y1 = y1; 
	
		xc = (x0 + x1) / 2; 
		yc = (y0 + y1) / 2;
		w  = x1 - x0; 
		h  = y1 - y0;
		
		return self;
	}
	
	static fromWH = function(x0, y0, w, h) {
		self.x0 = x0; 
		self.x1 = x0 + w; 
		self.y0 = y0; 
		self.y1 = y0 + h; 
	
		self.xc = (x0 + x1) / 2; 
		self.yc = (y0 + y1) / 2;
		self.w  = w; 
		self.h  = h;
		
		return self;
	}
	
	static toSquare = function() {
		var _span = min(w, h) / 2;
		
		x0 = xc - _span;
		x1 = xc + _span;
		y0 = yc - _span;
		y1 = yc + _span;
		
		return self;
	}
	
	static pad = function(padding) {
		x0 += padding;
		x1 -= padding;
		y0 += padding;
		y1 -= padding;
		
		return self;
	}
	
	static clone = function() { return BBOX().fromPoints(x0, y0, x1, y1); };
}