function nodeValue_Slider_Range(_name, _node, _value, _tooltip = "") { return new NodeValue_Slider_Range(_name, _node, _value, _tooltip); }

function NodeValue_Slider_Range(_name, _node, _value, _tooltip = "") : NodeValue_Array(_name, _node, _value, _tooltip, 2) constructor {
	setDisplay(VALUE_DISPLAY.slider_range);
	
}