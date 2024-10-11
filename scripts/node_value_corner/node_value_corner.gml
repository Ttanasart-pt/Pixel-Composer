function nodeValue_Corner(_name, _node, _value, _tooltip = "") { return new __NodeValue_Corner(_name, _node, _value, _tooltip); }

function __NodeValue_Corner(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, 4) constructor {
	setDisplay(VALUE_DISPLAY.corner);
}