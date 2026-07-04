function nodeValue_Vec4(_name, _value, _data = {}) { return new __NodeValue_Vec4(_name, self, _value, _data); }

function __NodeValue_Vec4(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 4) constructor {
	setDisplay(VALUE_DISPLAY.vector, _data);
	
	extract_node = "Node_Vector4";
	anim_presets = [
		[ "0, 1",  [ [0, [0,0,0,0]], [1, [1,1,1,1]] ], THEME.apreset_01 ], 
		[ "1, 0",  [ [0, [1,1,1,1]], [1, [0,0,0,0]] ], THEME.apreset_10 ], 
		-1, 
		[ "Zero to Current", [[0,[0,0,0,0]], noone] ], 
		[ "Current to One ", [noone, [1,[1,1,1,1]]] ], 
	];
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		return [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
			lerp(__f[2], __t[2], __i),
			lerp(__f[3], __t[3], __i),
		];
	}
	
}