#macro nodeValue_SliRange nodeValue_Slider_Range
function nodeValue_Slider_Range(_name, _value, _data = {}) { return new __NodeValue_Slider_Range(_name, self, _value, _data); }

function __NodeValue_Slider_Range(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 2) constructor {
	setDisplay(VALUE_DISPLAY.slider_range, is_array(_data)? { range: _data } : _data);
}