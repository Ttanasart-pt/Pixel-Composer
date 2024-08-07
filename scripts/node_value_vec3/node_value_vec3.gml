function nodeValue_Vec3(_name, _node, _value, _data = {}) { return new NodeValue_Vec3(_name, _node, _value, _data); }

function NodeValue_Vec3(_name, _node, _value, _data = {}) : NodeValue_Array(_name, _node, _value, "", 3) constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
}