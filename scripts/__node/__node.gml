function __Node_Base(x, y) constructor {
	self.x = x;
	self.y = y;
	
	display_name = "";
	inputs  = ds_list_create();
	outputs = ds_list_create();
	input_value_map = {};
	
	active_index	= -1;
	preview_index	= 0;
	anim_priority	= -999;
	
	static step   = function() {}
	static update = function(frame = CURRENT_FRAME) {}
	
	static valueUpdate = function(index) {}
	static triggerRender = function() {}
	
	static onValidate = function() {}
	static onDestroy = function() {}
	
	static clearCache = function() {}
	static clearCacheForward = function() {}
	
	static serialize = function() {}
	static deserialize = function(_map) {}
}