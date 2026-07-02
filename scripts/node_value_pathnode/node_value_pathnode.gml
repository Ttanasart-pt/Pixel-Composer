function nodeValue_Path(_name = "Path", _value = noone, _tooltip = "") { return new __NodeValue_Path(_name, self, _value, _tooltip); }
function __NodeValue_Path(_name, _node, _value, _tooltip = "") : __NodeValue_Object_Generic(_name, _node, VALUE_TYPE.pathnode, _value, _tooltip) constructor {
	setVisible(true, true);
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params = {}) { 
		if(attributes[$ "mapped"]) return -1;
		if(expUse) return -1;
		
		var _path = getValue();
		if(!is_path(_path)) return -1;
		
		return _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
}