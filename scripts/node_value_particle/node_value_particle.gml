function nodeValue_Particle(_name = "Particles", _value = noone, _tooltip = "") { return new __NodeValue_Particle(_name, self, _value, _tooltip); }
function __NodeValue_Particle(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.particle, _value, _tooltip) constructor {
	setVisible(true, true);
}