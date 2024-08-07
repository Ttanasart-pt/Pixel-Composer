function nodeValue_Vec4(_name, _node, _value, _tooltip = "") { return new NodeValue_Vec4(_name, _node, _value, _tooltip); }

function NodeValue_Vec4(_name, _node, _value, _tooltip = "") : NodeValue_Array(_name, _node, _value, _tooltip, 4) constructor {
	setDisplay(VALUE_DISPLAY.vector, 4);
}