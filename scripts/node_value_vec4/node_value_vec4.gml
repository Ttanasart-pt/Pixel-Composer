function nodeValue_Vec4(_name, _node, _value, _data = {}) { return new NodeValue_Vec4(_name, _node, _value, _data); }

function NodeValue_Vec4(_name, _node, _value, _data = {}) : NodeValue_Array(_name, _node, _value, "", 4) constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
}