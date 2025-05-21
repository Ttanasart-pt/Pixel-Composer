function nodeValue_Pbbox(_name = "PBBOX", _value = new __pbBox(), _tooltip = "") { return new __NodeValue_Pbbox(_name, self, _value, _tooltip); }
function __NodeValue_Pbbox(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.pbBox, _value, _tooltip) constructor {
	setVisible(true, true)
	is_modified = true; 
}