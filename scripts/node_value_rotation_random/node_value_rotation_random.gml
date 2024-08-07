#macro ROTATION_RANDOM_LENGTH 5

function nodeValue_Rotation_Random(_name, _node, _value, _tooltip = "") { return new NodeValue_Rotation_Random(_name, _node, _value, _tooltip); }

function NodeValue_Rotation_Random(_name, _node, _value, _tooltip = "") : NodeValue_Array(_name, _node, _value, _tooltip, ROTATION_RANDOM_LENGTH) constructor {
	setDisplay(VALUE_DISPLAY.rotation_random);
	
}