#macro nodeValue_SliRange nodeValue_Slider_Range
function nodeValue_Slider_Range(_name, _value, _data = {}) { return new __NodeValue_Slider_Range(_name, self, _value, _data); }

function __NodeValue_Slider_Range(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 2) constructor {
	setDisplay(VALUE_DISPLAY.slider_range, is_array(_data)? { range: _data } : _data);
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		return [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
		];
	}
	
}