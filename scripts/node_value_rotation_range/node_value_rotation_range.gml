function nodeValue_Rotation_Range(_name, _value, _tooltip = "") { return new __NodeValue_Rotation_Range(_name, self, _value, _tooltip); }

function __NodeValue_Rotation_Range(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, 2) constructor {
	setDisplay(VALUE_DISPLAY.rotation_range);
	
}