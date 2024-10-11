function nodeValue_Vec3(_name, _node, _value, _data = {}) { return new __NodeValue_Vec3(_name, _node, _value, _data); }

function __NodeValue_Vec3(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 3) constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
}