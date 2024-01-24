function angle_random_eval(range, seed = undefined) {
	if(is_real(range)) return range;
	
	if(seed != undefined) random_set_seed(seed);
	
	if(array_empty(range)) return 0;
	var _l = array_length(range);
	
	if(_l < 2) 
		return range[0]
		
	else if(_l == 2) 
		return irandom_range(range[0], range[1]);
		
	else if(_l > 2) {
		switch(range[0]) {
			case 0 : return irandom_range(range[1], range[2]);
			case 1 : return irandom_range(range[1] - range[2], range[1] + range[2]);
			case 2 : return choose(irandom_range(range[1], range[2]), irandom_range(range[3], range[4]));
			case 3 : return choose(irandom_range(range[1] - range[3], range[1] + range[3]), irandom_range(range[2] - range[3], range[2] + range[3]));
		}
	}
	
	return array_safe_get(range, 0);
}

function angle_random_eval_fast(range) {
	switch(range[0]) {
		case 0 : return irandom_range(range[1], range[2]);
		case 1 : return irandom_range(range[1] - range[2], range[1] + range[2]);
		case 2 : return choose(irandom_range(range[1], range[2]), irandom_range(range[3], range[4]));
		case 3 : return choose(irandom_range(range[1] - range[3], range[1] + range[3]), irandom_range(range[2] - range[3], range[2] + range[3]));
	}
	return 0;
}