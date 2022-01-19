function getWiggle(_min, _max, _fmin, _fmax, _time, seed_shift = 0) {
	random_set_seed(GLOBAL_SEED + seed_shift);
	
	var _x0 = random_range(_min, _max);
	var _x1 = random_range(_min, _max);
	var _t_next = 0, _t_prev = 0;
		
	while(_t_next < _time) {
		_x0 = _x1;
		_x1 = random_range(_min, _max);
			
		_t_prev = _t_next;
		_t_next = _t_prev + irandom_range(_fmin, _fmax);
	}
	
	var _val = lerp(_x0, _x1, (_time - _t_prev) / (_t_next - _t_prev));
	return _val;
}

function generateUUID() {
	randomize();
	var uuid;
	do {
		uuid = irandom(1000000000);
	} until(!ds_map_exists(NODE_MAP, uuid))
	return uuid;
}