function value_snap(val, snap = 1) {
	gml_pragma("forceinline")
	
	if(!is_array(val)) {
		if(snap == 0) return val;
		return round(val / snap) * snap;
	}
	
	var _val = [];
	for( var i = 0, n = array_length(val); i < n; i++ ) 
		_val[i] = snap == 0? val[i] : round(val[i] / snap) * snap;
	return _val;
}