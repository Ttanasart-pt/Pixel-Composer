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

function   BBOX() { return new __BBOX(); }
function __BBOX() constructor {
	x0 = 0; x1 = 0; 
	y0 = 0; y1 = 0; 
	
	xc = 0; yc = 0;
	w  = 0; h  = 0;
	
	////- Create
	
	static fromPoints = function(_x0, _y0, _x1, _y1) {
		x0 = _x0; 
		x1 = _x1; 
		y0 = _y0; 
		y1 = _y1; 
		
		setValue();
		return self;
	}
	
	static fromWH = function(_x0, _y0, _w, _h) {
		x0 = _x0; 
		x1 = _x0 + _w; 
		y0 = _y0; 
		y1 = _y0 + _h; 
		
		setValue();
		return self;
	}
	
	static fromBoundingBox = function(box) {
		self.x0 = box.minx; 
		self.x1 = box.maxx; 
		self.y0 = box.miny; 
		self.y1 = box.maxy; 
		
		setValue();
		return self;
	}
	
	static setValue = function() {
		xc = (x0 + x1) / 2; 
		yc = (y0 + y1) / 2;
		w  = abs(x1 - x0);
		h  = abs(y1 - y0);
		
		return self;
	}
	
	////- Actions
	
	static toSquare = function() {
		var _span = min(w, h) / 2;
		
		x0 = xc - _span;
		x1 = xc + _span;
		y0 = yc - _span;
		y1 = yc + _span;
		
		setValue();
		return self;
	}
	
	static pad = function(padding) {
		x0 += padding;
		x1 -= padding;
		y0 += padding;
		y1 -= padding;
		
		setValue();
		return self;
	}
	
	static addPoint = function(_x, _y) {
		x0 = min(x0, _x);
		x1 = max(x1, _x);
		y0 = min(y0, _y);
		y1 = max(y1, _y);
		
		setValue();
		return self;
	}
	
	static addArea = function(_area) {
		var _x0   = _area[0] - _area[2];
		var _y0   = _area[1] - _area[3];
		var _x1   = _area[0] + _area[2];
		var _y1   = _area[1] + _area[3];
		
		addPoint(_x0, _y0);
		addPoint(_x0, _y1);
		addPoint(_x1, _y0);
		addPoint(_x1, _y1);
		
		return self;
	}
	
	static clone = function() { return BBOX().fromPoints(x0, y0, x1, y1); };
}