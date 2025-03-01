function nodeValue_Pbbox(_name, _node, _value, _tooltip = "") { return new __NodeValue_Pbbox(_name, _node, _value, _tooltip); }

function __NodeValue_Pbbox(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.pbBox, _value, _tooltip) constructor {
	setVisible(true, true)
	
}