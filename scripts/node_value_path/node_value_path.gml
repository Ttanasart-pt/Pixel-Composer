function nodeValue_FPath(_name, _value = "", _tooltip = "") { return new __NodeValue_FPath(_name, self, _value, _tooltip); }
function __NodeValue_FPath(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.path, _value, _tooltip) constructor {
	
	////- Get
	
	static valueProcess = function(value, nodeFrom = undefined, applyUnit = true, arrIndex = 0) {
		return is_string(value)? filepath_resolve(value) : value; 
	}
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		
		if(is_array(val)) val = array_map(val, function(v) /*=>*/ {return valueProcess(v)});
		else              val = valueProcess(val);
		
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
	
	////- Set
	
	static onValidate = function() {
		var _val = value_validation, str = "";
		value_validation = VALIDATION.pass; 
		widgetBoxColor   = c_white;
		
		switch(display_type) {
			case VALUE_DISPLAY.path_load: 
				var path = animator.getValue();
				if(is_array(path)) path = path[0];
				
				if(!is_string(path) || path == "") {
					widgetBoxColor = COLORS._main_value_negative;
					str = $"Path invalid: {path}";
					break;
				}
				
				if(!file_exists_empty(path_get(path))) {
					widgetBoxColor   = COLORS._main_value_negative;
					value_validation = VALIDATION.error;	
					str = $"File not exist: {path}";
				}
				break;
				
			case VALUE_DISPLAY.path_array: 
				var paths = animator.getValue();
				if(is_array(paths)) {
					for( var i = 0, n = array_length(paths); i < n; i++ ) {
						if(file_exists_empty(path_get(paths[i]))) continue;
						value_validation = VALIDATION.error;	
						str = $"File not exist: {paths[i]}";
					} 
				} else {
					value_validation = VALIDATION.error;	
					str = $"File not exist: {paths}";
				}
				break;
		}
		
		if(_val == value_validation) return self;
		
		if(value_validation == VALIDATION.error && error_notification == noone) {
			error_notification = noti_error(str);
			error_notification.onClick = function() /*=>*/{ PANEL_GRAPH.focusNode(node); };
		}
			
		if(value_validation == VALIDATION.pass && error_notification != noone) {
			noti_remove(error_notification);
			error_notification = noone;
		}
		
		return self;
	}
	
}