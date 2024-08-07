function nodeValue_Padding(_name, _node, _value, _tooltip = "") { return new NodeValue_Padding(_name, _node, _value, _tooltip); }

function NodeValue_Padding(_name, _node, _value, _tooltip = "") : NodeValue_Array(_name, _node, _value, _tooltip, 4) constructor {
	setDisplay(VALUE_DISPLAY.padding);
}