globalvar EASERS; EASERS = [];

function Easer_UI(_defVal = 0) constructor {
	array_push(EASERS, self);
	value  = _defVal;
	target = value;
	
	curve = undefined;
	switch(THEME_VALUE.easing) {
		case "linear" : curve = ac_linear;     break;
		case "smooth" : curve = ac_smoothstep; break;
		case "liquid" : curve = ac_liquid;     break;
	}
	
	prog       = 1;
	startValue = value;
	
	static goto = function(t) /*=>*/ {
		if(target == t) return;
		
		startValue = value;
		target = t;
		prog   = 0;
	}
	
	static step = function() /*=>*/ {
		var duration   = THEME_VALUE.ease_duration; // duration in sec
		if(value == undefined || curve == undefined || duration <= 0) {
			value = target;
			prog  = 1;
			return;
		}
		
		if(value == target) {
			prog = 1;
			return;
		}
		
		prog = lerp_linear(prog, 1, DELTA_TIME / duration);
    	var pr = animation_curve_eval(curve, prog);
    	value = lerp(startValue, target, pr);
    	
    	if(prog == 1) 
    		value = target;
	}
}

function easerStep() {
	for( var i = 0, n = array_length(EASERS); i < n; i++ ) 
		EASERS[i].step();
}