function __Node_Base(x, y) constructor {
	self.x = x;
	self.y = y;
	
	inputs  = ds_list_create();
	outputs = ds_list_create();
	
	preview_index = 0;
	
	static step   = function() {}
	static update = function(frame = ANIMATOR.current_frame) {}
	
	static valueUpdate = function(index) {}
	static triggerRender = function() {}
	
	static onValidate = function() {}
	static onDestroy = function() {}
	
	static clearCache = function() {}
	static clearCacheForward = function() {}
	
	static serialize = function() {}
	static deserialize = function(_map) {}
}