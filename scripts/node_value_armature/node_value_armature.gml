function nodeValue_Armature(_name = "Armature", _value = noone, _tooltip = "") { return new __NodeValue_Armature(_name, self, _value, _tooltip); }
function __NodeValue_Armature(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.armature, _value, _tooltip) constructor {
	
}