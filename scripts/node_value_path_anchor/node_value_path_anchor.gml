function nodeValue_Path_Anchor(_name, _value, _tooltip = "") { return new __NodeValue_Path_Anchor(_name, self, _value, _tooltip); }
function __NodeValue_Path_Anchor(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, _ANCHOR.amount) constructor {
	setDisplay(VALUE_DISPLAY.path_anchor);
}

function nodeValue_Path_Anchor_3D(_name, _value, _tooltip = "") { return new __NodeValue_Path_Anchor_3D(_name, self, _value, _tooltip); }
function __NodeValue_Path_Anchor_3D(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, _ANCHOR3.amount) constructor {
	setDisplay(VALUE_DISPLAY.path_anchor);
}