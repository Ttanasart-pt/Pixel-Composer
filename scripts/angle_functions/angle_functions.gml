function angle_random_eval(range, seed = random_get_seed()) {
	if(is_real(range)) return range;
	
	if(array_empty(range)) return 0;
	var _l = array_length(range);
	
	if(_l < 2) 
		return range[0]
		
	else if(_l == 2) 
		return random_range_seed(range[0], range[1], seed);
		
	else if(_l > 2) {
		switch(range[0]) {
			case 0 : return random_range_seed(range[1], range[2], seed);
			case 1 : return random_range_seed(range[1] - range[2], range[1] + range[2], seed);
			case 2 : return choose(random_range_seed(range[1], range[2], seed), random_range_seed(range[3], range[4], seed));
			case 3 : return choose(random_range_seed(range[1] - range[3], range[1] + range[3], seed), random_range_seed(range[2] - range[3], range[2] + range[3], seed));
		}
	}
	
	return array_safe_get_fast(range, 0);
}

function angle_random_eval_fast(range, seed = random_get_seed()) {
	
	switch(range[0]) {
		case 0 : return random_range_seed(range[1], range[2], seed);
		case 1 : return random_range_seed(range[1] - range[2], range[1] + range[2], seed);
		case 2 : return choose(random_range_seed(range[1], range[2], seed), random_range_seed(range[3], range[4], seed));
		case 3 : return choose(random_range_seed(range[1] - range[3], range[1] + range[3], seed), random_range_seed(range[2] - range[3], range[2] + range[3], seed));
	}
	return 0;
}