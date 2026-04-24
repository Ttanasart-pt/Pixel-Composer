function nodeValue_Fdomain(_name = "Domain", _value = noone, _tooltip = "") { 
	return new __NodeValue_Object_Generic(_name, self, VALUE_TYPE.fdomain, _value, _tooltip).setVisible(true, true);
}

function nodeValue_Sdomain(_name = "Domain", _value = noone, _tooltip = "") { 
	return new __NodeValue_Object_Generic(_name, self, VALUE_TYPE.sdomain, _value, _tooltip).setVisible(true, true); 
}
