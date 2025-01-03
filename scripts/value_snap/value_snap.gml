function value_snap_real(val, snap = 1) { INLINE return snap == 0? val : round(val / snap) * snap; }

function value_snap(val, snap = 1) {
	INLINE
	
	if(!is_array(val)) return value_snap_real(val, snap);
	
	var _val = [];
	for( var i = 0, n = array_length(val); i < n; i++ ) 
		_val[i] = value_snap(val[i], snap);
	return _val;
}