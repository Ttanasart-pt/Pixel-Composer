function nodeValue_Vec4(_name, _value, _data = {}) { return new __NodeValue_Vec4(_name, self, _value, _data); }

function __NodeValue_Vec4(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 4) constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
	
	anim_presets = [
		[ "0, 1",  [ [ 0, [ 0, 0, 0, 0 ] ], [ 1, [ 1, 1, 1, 1 ] ]], THEME.apreset_01 ], 
		[ "1, 0",  [ [ 0, [ 1, 1, 1, 1 ] ], [ 1, [ 0, 0, 0, 0 ] ]], THEME.apreset_10 ], 
	];
	
}