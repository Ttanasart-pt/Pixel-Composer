#macro nodeValue_Range2 nodeValue_Vec2_Range
function nodeValue_Vec2_Range(_name, _value = [0,0,0,0], _data = {}) { return new __NodeValue_Vec2_Range(_name, self, _value, _data); }

function __NodeValue_Vec2_Range(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 4) constructor {
	if(is_bool(_data)) _data = { linked : _data };
	setDisplay(VALUE_DISPLAY.vector_range, _data);
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		return [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
			lerp(__f[2], __t[2], __i),
			lerp(__f[3], __t[3], __i),
		];
	}
	
}