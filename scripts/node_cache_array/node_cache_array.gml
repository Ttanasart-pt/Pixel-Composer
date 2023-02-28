function Node_Cache_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Cache Array";
	use_cache   = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue("Cache array", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, []);
	
	input_display_list = [
		["Surface",			 true], 0, 
	];
	
	static update = function() {
		if(!inputs[| 0].value_from) return;
		if(!ANIMATOR.is_playing) return;
		
		var _surf  = inputs[| 0].getValue();
		cacheCurrentFrame(_surf);
		outputs[| 0].setValue(cached_output);
	}
}