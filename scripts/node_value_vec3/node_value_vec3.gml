function nodeValue_Vec3(_name, _node, _value, _tooltip = "") { return new NodeValue_Vec3(_name, _node, _value, _tooltip); }

function NodeValue_Vec3(_name, _node, _value, _tooltip = "") : NodeValue_Array(_name, _node, _value, _tooltip, 3) constructor {
	setDisplay(VALUE_DISPLAY.vector, 3);
}