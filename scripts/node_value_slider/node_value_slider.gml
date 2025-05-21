function nodeValue_Slider(_name, _value, _data = {}) { return new __NodeValue_Slider(_name, self, _value, _data); }
function __NodeValue_Slider(_name, _node, _value, _data = {}) : __NodeValue_Float(_name, _node, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.slider, is_array(_data)? { range: _data } : _data);
}

function nodeValue_ISlider(_name, _value, _data = {}) { return new __NodeValue_ISlider(_name, self, _value, _data); }
function __NodeValue_ISlider(_name, _node, _value, _data = {}) : __NodeValue_Int(_name, _node, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.slider, is_array(_data)? { range: _data } : _data);
}