#macro nodeValue_pn nodeValue_PathNode
function nodeValue_PathNode(_name, _node, _value, _tooltip = "") { return new __NodeValue_PathNode(_name, _node, _value, _tooltip); }

function __NodeValue_PathNode(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.pathnode, _value, _tooltip) constructor {
	
}