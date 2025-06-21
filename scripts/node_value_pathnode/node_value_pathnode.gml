function nodeValue_PathNode(_name, _value = noone, _tooltip = "") { return new __NodeValue_PathNode(_name, self, _value, _tooltip); }
function __NodeValue_PathNode(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.pathnode, _value, _tooltip) constructor {
	setVisible(true, true);
}