function NodeValue_Static(_name, _node, _value = 0) constructor {
	name  = _name;
	node  = _node;
	
	value = _value;
	
	editWidget   = undefined;
	editWidgetFn = undefined;
	
	////- Get Set
	
	static getValue = function() {
		return value;
	}
	
	static setValue = function(v) {
		value = v;
		return self;
	}
	
	static getEditWidget = function() {
		if(editWidget != undefined) return editWidget;
		
		if(editWidgetFn != undefined) editWidget = editWidgetFn();
		return editWidget;
	}
	
	////- Serialize
	
	static serialize = function() {
		var m = {};
		
		m.v = value;
		
		return m;
	}
	
	static deserialize = function(m) {
		value = m[$ "v"] ?? value;
		
		return self;
	}
}