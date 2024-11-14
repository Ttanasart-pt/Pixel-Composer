function nodeValue_Struct(_name, _node, _value, _tooltip = "") { return new __NodeValue_Struct(_name, _node, _value, _tooltip); }

function __NodeValue_Struct(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.struct, _value, _tooltip) constructor {
	
	static shortenDisplay = function() { editWidget.shorted = true; return self; }
}