function rotation_random_eval(range, seed = random_get_seed()) {
	if(is_real(range)) return range;
	
	if(array_empty(range)) return 0;
	var _l = array_length(range);
	
	if(_l < 2) 
		return range[0]
		
	else if(_l == 2) 
		return random_range_seed(range[0], range[1], seed);
		
	else if(_l > 2) {
		switch(range[0]) {
			case 0 : return        random_range_seed(range[1], range[2], seed);
			case 1 : return        random_range_seed(range[1] - range[2], range[1] + range[2], seed);
			case 2 : return choose(random_range_seed(range[1], range[2], seed), 
			                       random_range_seed(range[3], range[4], seed));
			case 3 : return choose(random_range_seed(range[1] - range[3], range[1] + range[3], seed), 
			                       random_range_seed(range[2] - range[3], range[2] + range[3], seed));
		}
	}
	
	return array_safe_get_fast(range, 0);
}

function rotation_random_eval_fast(range, seed = random_get_seed()) {
	
	switch(range[0]) {
		case 0 : return        random_range_seed(range[1], range[2], seed);
		case 1 : return        random_range_seed(range[1] - range[2], range[1] + range[2], seed);
		case 2 : return choose(random_range_seed(range[1], range[2], seed), 
		                       random_range_seed(range[3], range[4], seed));
		case 3 : return choose(random_range_seed(range[1] - range[3], range[1] + range[3], seed), 
		                       random_range_seed(range[2] - range[3], range[2] + range[3], seed));
	}
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