function   nodeValue_Puppet(_name, _value) { return new __NodeValue_Puppet(_name, self, _value); }
function __NodeValue_Puppet(_name, _node, _value) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.puppet_control);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _flag = 0b0011) { 
		if(expUse) return -1;
		return preview_overlay_puppet(hover, active, _x, _y, _s, _mx, _my);
	}
	
}