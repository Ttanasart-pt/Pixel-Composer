function nodeValue_D3Mesh(_name, _tooltip = "") { return new __NodeValue_D3Mesh(_name, self, noone, _tooltip); }

function __NodeValue_D3Mesh(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.d3Mesh, _value, _tooltip) constructor {
	setVisible(true, true);
}