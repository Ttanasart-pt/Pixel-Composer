function nodeValue_Tileset(_name, _node, _value, _tooltip = "") { return new __NodeValue_Tileset(_name, _node, _value, _tooltip); }

function __NodeValue_Tileset(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.tileset, _value, _tooltip) constructor {}