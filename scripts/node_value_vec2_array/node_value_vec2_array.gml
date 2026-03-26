function nodeValue_Vec2Arr( _name, _value, _data = {}) { return new __NodeValue_Vec2Arr( _name, self, _value, _data); }
function __NodeValue_Vec2Arr(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
	setArrayDepth(1);
	
	def_length = 2;
	sepable    = false;
	
	////- GET
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) {
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0]; 
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		var typ = nod.type;
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		if(!getAnim()) return array_empty(animator.values)? 0 : animator.values[0].value;
		return animator.getValue(_time);
	}
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		var _af = array_safe_length(__f, -1);
		var _at = array_safe_length(__t, -1);
		if(_af ==  0 || _at ==  0) return 0;
		
		var _as  = min(_af, _at);
		var _res = array_create(_as);
		
		for( var i = 0; i < _as; i++ )
			_res[i] = [ lerp(__f[i][0], __t[i][0], __i), lerp(__f[i][1], __t[i][1], __i) ];
		
		return _res;
	}
	
}