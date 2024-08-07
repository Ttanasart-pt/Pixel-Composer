function nodeValue_Path_Anchor(_name, _node, _value, _tooltip = "") { return new NodeValue_Path_Anchor(_name, _node, _value, _tooltip); }

function NodeValue_Path_Anchor(_name, _node, _value, _tooltip = "") : NodeValue_Array(_name, _node, _value, _tooltip, _ANCHOR.amount) constructor {
	setDisplay(VALUE_DISPLAY.path_anchor);
}