function __pbBox() constructor {
	layer = 0;
	
	x = 0;
	y = 0;
	w = 32;
	h = 32;
	
	layer_w = 32;
	layer_h = 32;
	
	mask = noone;
	
	mirror_h = false;
	mirror_v = false;
	
	rotation = 0;
	
	static clone = function() {
		var _pbbox = new __pbBox();
		
		_pbbox.layer = layer;
		_pbbox.x = x;
		_pbbox.y = y;
		_pbbox.w = w;
		_pbbox.h = h;
		
		_pbbox.layer_w = layer_w;
		_pbbox.layer_h = layer_h;
		
		_pbbox.mirror_h = mirror_h;
		_pbbox.mirror_v = mirror_v;
		
		_pbbox.rotation = rotation;
		
		return _pbbox;
	}
}