function __NodeValue_Number(_name, _node, _type, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, _type, _value, _tooltip) constructor {
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		
		if(!is_array(__f)) return lerp(__f, __t, __i);
		return array_map(__f, function(f,i) /*=>*/ {return lerp(__f[i], __t[i], __i)});
	}
	
}
