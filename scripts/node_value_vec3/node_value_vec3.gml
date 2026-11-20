function nodeValue_Vec3(  _name, _value, _data = {} ) { return new __NodeValue_Vec3(  _name, self, _value, _data ); }
function nodeValue_IVec3( _name, _value, _data = {} ) { return new __NodeValue_IVec3( _name, self, _value, _data ); }

function __NodeValue_Vec3(_name, _node, _value, _data = {}) : __NodeValue_Array(_name, _node, _value, "", 3) constructor {
	if(is_bool(_data)) _data = {linked: _data};
	
	_data.length = 3;
	setDisplay(VALUE_DISPLAY.vector, _data);
	
	extract_node = "Node_Vector3";
	anim_presets = [
		[ "0, 1",  [ [0, [0,0,0]], [1, [1,1,1]] ], THEME.apreset_01 ], 
		[ "1, 0",  [ [0, [1,1,1]], [1, [0,0,0]] ], THEME.apreset_10 ], 
		-1, 
		[ "Zero to Current", [[0,[0,0,0]], noone] ], 
		[ "Current to One ", [noone, [1,[1,1,1]]] ], 
	];
	
	////- ANIMATOR
	
	static lerpAnimSmooth = function(keys, rat) { 
		var from = keys[1];
		var to   = keys[2];
		
		if(to.ease_in_type == CURVE_TYPE.catmulrom || from.ease_out_type == CURVE_TYPE.catmulrom) {
			return sep_axis? lerp_catmul(keys[0].value, keys[1].value, keys[2].value, keys[3].value, rat) : [
				lerp_catmul(keys[0].value[0], keys[1].value[0], keys[2].value[0], keys[3].value[0], rat),
				lerp_catmul(keys[0].value[1], keys[1].value[1], keys[2].value[1], keys[3].value[1], rat),
				lerp_catmul(keys[0].value[2], keys[1].value[2], keys[2].value[2], keys[3].value[2], rat),
			];
		}
		
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		
		return sep_axis? lerp(__f, __t, __i) : [
			lerp(__f[0], __t[0], __i),
			lerp(__f[1], __t[1], __i),
			lerp(__f[2], __t[2], __i),
		];
	}
	
}

function __NodeValue_IVec3(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.integer, _value, "") constructor {
	type_array = 1;
	def_length = 3;
	
	setDisplay(VALUE_DISPLAY.vector, _data);
}