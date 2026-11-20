function __NodeValue_Number(_name, _node, _type, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, _type, _value, _tooltip) constructor {
	
	////- ANIMATOR
	
	static lerpAnimSmooth = function(keys, rat) { 
		var from = keys[1];
		var to   = keys[2];
		
		if(to.ease_in_type == CURVE_TYPE.catmulrom || from.ease_out_type == CURVE_TYPE.catmulrom) {
			if(!is_array(from.value)) return lerp_catmul(keys[0].value, keys[1].value, keys[2].value, keys[3].value, rat);
			
			__k = keys;
			__i = rat;
			
			return array_create_ext(min(_af, _at), function(i) /*=>*/ 
				{return lerp_catmul(__k[0].value[i], __k[1].value[i], __k[2].value[i], __k[3].value[i], __i)}
			);
		}
		
		__f = from.value;
		__t = to.value;
		__i = KeyframeInterpolate(from, to, rat);
		
		if(!is_array(__f)) return lerp(__f, __t, __i);
		return array_map(__f, function(f,i) /*=>*/ {return lerp(__f[i], __t[i], __i)});
	}
	
}
