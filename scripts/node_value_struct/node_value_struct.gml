function nodeValue_Struct(_name, _value = {}, _tooltip = "") { return new __NodeValue_Struct(_name, self, _value, _tooltip); }

function __NodeValue_Struct(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.struct, _value, _tooltip) constructor {
	constructRef    = undefined;
	constructStatic = undefined;
	
	static setConstructor = function(c) /*=>*/ { 
		constructRef    = c; 
		constructStatic = static_get(c); 
		return self; 
	}
	
	static shortenDisplay = function( ) /*=>*/ { getEditWidget().shorted = true; return self; }
}