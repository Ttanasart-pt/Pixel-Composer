function rotation_random_eval(_range, seed = random_get_seed(), _index = 0) {
	if(is_real(_range)) return _range;
	var _l = array_length(_range);
	
	if(_l > 2) {
		switch(_range[0]) {
			case 0 : return random_range_seed(_range[1], _range[2], seed);
			case 1 : return random_range_seed(_range[1] - _range[2], _range[1] + _range[2], seed);
			
			case 2 : 
				var _type = _l > 5? _range[5] : 0;
				if(_type == 0) 
					return choose(random_range_seed(_range[1], _range[2], seed), 
				                  random_range_seed(_range[3], _range[4], seed));
				else if(_type == 1) {
					var indx = _index % 2;
					return indx? random_range_seed(_range[1], _range[2], seed) : 
				                 random_range_seed(_range[3], _range[4], seed);
				}
				break;
			                       
			case 3 : 
				var _type = _l > 5? _range[5] : 0;
				if(_type == 0) 
					return choose(random_range_seed(_range[1] - _range[3], _range[1] + _range[3], seed), 
				                  random_range_seed(_range[2] - _range[3], _range[2] + _range[3], seed));
				else if(_type == 1) {
					var indx = _index % 2;
					return indx? random_range_seed(_range[1] - _range[3], _range[1] + _range[3], seed) : 
				                 random_range_seed(_range[2] - _range[3], _range[2] + _range[3], seed);
				}
				break;
		}
	} 
	
	if(_l == 2) return random_range_seed(_range[0], _range[1], seed);
	if(_l == 1) return _range[0];
	return 0;
}

function rotation_random_eval_uniform(range, ratio) {
	switch(range[0]) {
		case 0 : return        lerp(range[1], range[2], ratio);
		case 1 : return        lerp(range[1] - range[2], range[1] + range[2], ratio);
		case 2 : 
			var _rng1 = abs(range[1] - range[2]);
			var _rng2 = abs(range[3] - range[4]);
			var _rat1 = _rng1 / (_rng1 + _rng2);
			var _rat2 = _rng2 / (_rng1 + _rng2);
			
			if(ratio < _rat1) return lerp(range[1], range[2], ratio / _rat1);
			return lerp(range[3], range[4], (ratio - _rat1) / _rat2);
			
		case 3 : 
			if(ratio < .5) return lerp(range[1] - range[3], range[1] + range[3], ratio / .5);
			return lerp(range[2] - range[3], range[2] + range[3], (ratio - .5) / .5);
	}
	return 0;
}