function spriteAtlasData(x = 0, y = 0, w = 1, h = 1, surface = noone, index = 0) constructor {
	self.surface = surface;
	self.index	 = index;
	self.x = x;
	self.y = y;
	self.w = w;
	self.h = h;
	
	static clone = function() { return new spriteAtlasData(x, y, w, h, surface, index); }
}