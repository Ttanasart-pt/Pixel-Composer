function __NodeValue_Number(_name, _node, _type, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, _type, _value, _tooltip) constructor {
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		var _af = array_safe_length(__f, -1);
		var _at = array_safe_length(__t, -1);
		
		return lerp(__f, __t, __i);
	}
	
}
