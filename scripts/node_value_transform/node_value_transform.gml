function   nodeValue_Transform(_name, _value=[0,0,0,1] ) { return new __NodeValue_Transform(_name, self, _value); }
function __NodeValue_Transform(_name, _node, _value) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.transform);
}