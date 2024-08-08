function nodeValue_Vec2_Range(_name, _node, _value, _data = {}) { return new NodeValue_Vec2_Range(_name, _node, _value, _data); }

function NodeValue_Vec2_Range(_name, _node, _value, _data = {}) : NodeValue_Array(_name, _node, _value, "", 4) constructor {
	setDisplay(VALUE_DISPLAY.vector_range, _data);
	
}