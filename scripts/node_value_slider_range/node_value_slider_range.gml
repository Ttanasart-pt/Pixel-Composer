function nodeValue_Slider_Range(_name, _node, _value, _data = {}) { return new NodeValue_Slider_Range(_name, _node, _value, _data); }

function NodeValue_Slider_Range(_name, _node, _value, _data = {}) : NodeValue_Array(_name, _node, _value, "", 2) constructor {
	setDisplay(VALUE_DISPLAY.slider_range, _data);
	
}