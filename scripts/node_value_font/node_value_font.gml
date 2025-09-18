function nodeValue_Font(_name = "Font", _value = "", _tooltip = "") { return new __NodeValue_Font(_name, self, _value, _tooltip); }
function __NodeValue_Font(_name, _node, _value = "", _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.font, _value, _tooltip) constructor {
	
	/////============== GET =============
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		if(!is_string(value)) return value;
		
		if(struct_has(FONT_MAP, value)) return FONT_MAP[$ value];
		
		var _path = filepath_resolve(value); 
		if(_path != "" && !file_exists(_path)) noti_warning($"Font data: Font path {_path} not exists.");
		
		return _path;
	}
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		
		if(is_array(val)) val = array_map(val, function(v) /*=>*/ {return valueProcess(v)});
		else              val = valueProcess(val);
		
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		var _anims = animators;
		
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}