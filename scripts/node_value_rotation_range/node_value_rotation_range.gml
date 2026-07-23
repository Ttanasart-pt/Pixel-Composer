#macro nodeValue_RotRange nodeValue_Rotation_Range
function nodeValue_Rotation_Range(_name, _value, _tooltip = "") { return new __NodeValue_Rotation_Range(_name, self, _value, _tooltip); }

function __NodeValue_Rotation_Range(_name, _node, _value, _tooltip = "") : __NodeValue_Array(_name, _node, _value, _tooltip, 2) constructor {
	setDisplay(VALUE_DISPLAY.rotation_range);
	
	////- Draw
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _rad = 64, _type = 0) { 
		if(attributes[$ "mapped"]) return -1;
		if(expUse) return -1;
		
		__preview_bbox = node.__preview_bbox;
		return preview_overlay_rotation_range(hover, active, _x, _y, _s, _mx, _my, _rad, _type);
	}
	
	////- ANIMATOR
	
	static lerpAnimKeys = function(from, to, rat) {
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		
		return sep_axis? lerp(__f, __t, __i) : [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
		];
	}
	
}