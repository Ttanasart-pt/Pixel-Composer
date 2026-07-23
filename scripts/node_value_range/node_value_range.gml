function nodeValue_Range(_name, _value, _data = {}) { return new __NodeValue_Range(_name, self, _value, _data); }

function __NodeValue_Range(_name, _node, _value, _data) : __NodeValue_Array(_name, _node, _value, "", 2) constructor {
	if(is_bool(_data)) _data = { linked : _data };
	setDisplay(VALUE_DISPLAY.range, _data);
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		
		return sep_axis? lerp(__f, __t, __i) : [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
		];
	}
	
}