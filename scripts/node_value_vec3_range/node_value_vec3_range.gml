#macro RANGE3_0 [ 0,0,0, /**/ 0,0,0 ]
#macro RANGE3_1 [ 1,1,1, /**/ 1,1,1 ]

#macro nodeValue_Range3 nodeValue_Vec3_Range
function nodeValue_Vec3_Range(_name, _value, _data = {}) { return new __NodeValue_Vec3_Range(_name, self, _value, _data); }

function __NodeValue_Vec3_Range(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 6) constructor {
	if(is_bool(_data)) _data = { linked : _data };
	setDisplay(VALUE_DISPLAY.vector_range, _data);
	
	////- ANIMATOR
	
	static lerpAnimSmooth = function(keys, rat) { 
		var from = keys[1];
		var to   = keys[2];
		
		if(to.ease_in_type == CURVE_TYPE.catmulrom || from.ease_out_type == CURVE_TYPE.catmulrom) {
			return sep_axis? KeyframeInterpolateAuto(keys[0].value, keys[1].value, keys[2].value, keys[3].value, rat) : [
				KeyframeInterpolateAuto(keys[0].value[0], keys[1].value[0], keys[2].value[0], keys[3].value[0], rat),
				KeyframeInterpolateAuto(keys[0].value[1], keys[1].value[1], keys[2].value[1], keys[3].value[1], rat),
				KeyframeInterpolateAuto(keys[0].value[2], keys[1].value[2], keys[2].value[2], keys[3].value[2], rat),
				
				KeyframeInterpolateAuto(keys[0].value[3], keys[1].value[3], keys[2].value[3], keys[3].value[3], rat),
				KeyframeInterpolateAuto(keys[0].value[4], keys[1].value[4], keys[2].value[4], keys[3].value[4], rat),
				KeyframeInterpolateAuto(keys[0].value[5], keys[1].value[5], keys[2].value[5], keys[3].value[5], rat),
			];
		}
		
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		
		return sep_axis? lerp(__f, __t, __i) : [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
			lerp(__f[2], __t[2], __i),
			
			lerp(__f[3], __t[3], __i),
			lerp(__f[4], __t[4], __i),
			lerp(__f[5], __t[5], __i),
		];
	}
	
}