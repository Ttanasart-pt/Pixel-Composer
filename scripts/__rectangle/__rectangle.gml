function Rectangle(x, y, w, h) constructor {
    self.x = x;
    self.y = y;
    self.w = w;
    self.h = h;
	
	static hashOrigin = function() { return "x" + string(x) + "y" + string(y); }
	static clone = function() { return new Rectangle(x, y, w, h); }
}

function rectangleOverlap(rect1, rect2) {
    return rect1.x < rect2.x + rect2.w && rect1.x + rect1.w > rect2.x &&
           rect1.y < rect2.y + rect2.h && rect1.y + rect1.h > rect2.y;
}