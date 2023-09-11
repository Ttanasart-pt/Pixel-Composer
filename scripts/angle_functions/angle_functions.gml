function angle_random_eval(range, seed = undefined) {
	if(is_real(range)) 
		return range;
	
	if(seed != undefined) random_set_seed(seed);
	
	if(array_length(range) < 2) 
		return range
	else if(array_length(range) == 2) 
		return irandom_range(range[0], range[1]);
	else if(array_length(range) > 2) {
		switch(range[0]) {
			case 0 : return irandom_range(range[1], range[2]);
			case 1 : return irandom_range(range[1] - range[2], range[1] + range[2]);
			case 2 : return choose(irandom_range(range[1], range[2]), irandom_range(range[3], range[4]));
			case 3 : return choose(irandom_range(range[1] - range[3], range[1] + range[3]), irandom_range(range[2] - range[3], range[2] + range[3]));
		}
	}
	
	return range;
}