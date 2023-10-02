function Node_Rate_Remap(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Rate Remap";
	use_cache = CACHE_USE.manual;
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Framerate", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10);
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
	
	outputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 2,
		0, 1
	];
	
	static step = function() {
		
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _surf = _data[0];
		var _rate = _data[1];
		var _time = PROJECT.animator.current_frame;
		var _step = PROJECT.animator.framerate / _rate;
		var _targ = floor(_time / _step) * _step;
		
		cacheCurrentFrameIndex(_surf, _array_index);
		var s = getCacheFrameIndex(_targ, _array_index);
		
		return s;
	}
}