function nodeValue_Matrix(_name, _value, _data = {}) { return new __NodeValue_Matrix(_name, self, _value, _data); }
function __NodeValue_Matrix(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.matrix, _data);
	
	/////============== GET =============
	
	__temp_matrix_object = new Matrix(3);
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		
		if(is(val, Matrix)) return val;
		if(is_array(val)) {
		    var _len = array_length(val);
		    var _siz = floor(sqrt(_len));
		    
		    __temp_matrix_object.setSize(_len);
		    __temp_matrix_object.setArray(val);
		}
		
		return __temp_matrix_object;
	}
	
	static setValueDirect = function(val = 0, index = noone, record = true, time = NODE_CURRENT_FRAME, _update = true) {
	    is_modified = true;
	    var _val = val;
	    
	    if(index != noone) {
    		_val = animator.getValue(time);
    	    _val.raw[index] = val;
	    }
		
		animator.setValue(_val, record, time);
		
		var _val = animator.getValue(time);
		node.inputs_data[self.index]         = _val; // setInputData(self.index, _val);
		node.input_value_map[$ internalName] = _val;
		draw_junction_index = type;
		
		if(_update) {
			node.triggerRender();
			node.valueUpdate(self.index);
			node.clearCacheForward();
		}
		
		if(fullUpdate) RENDER_ALL
					
		if(!LOADING) PROJECT.modified = true;
					
		cache_value[0] = false;
		onValidate();
		
		return true;
	}
}