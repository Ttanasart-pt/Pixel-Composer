function nodeValue_Vec2_Range(_name, _node, _value, _tooltip = "") { return new NodeValue_Vec2_Range(_name, _node, _value, _tooltip); }

function NodeValue_Vec2_Range(_name, _node, _value, _data, _tooltip = "") : NodeValue_Array(_name, _node, _value, _tooltip, 4) constructor {
	setDisplay(VALUE_DISPLAY.vector_range, _data);
	
}