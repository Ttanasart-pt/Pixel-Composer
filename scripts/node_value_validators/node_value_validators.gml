function ValueValidator() constructor {
	static validate = function(val) { return val; } 
}

function   VV_min(minimum) { return new __VV_min(minimum); };
function __VV_min(minimum) : ValueValidator() constructor {
	self.minimum = minimum;
	static validate = function(val) { return is_array(val)? array_map(val, function(v) /*=>*/ {return validate(v)}) : max(minimum, val); } 
}

function   VV_max(maximum) { return new __VV_max(maximum); };
function __VV_max(maximum) : ValueValidator() constructor {
	self.maximum = maximum;
	static validate = function(val) { return is_array(val)? array_map(val, function(v) /*=>*/ {return validate(v)}) : min(maximum, val); } 
}

function   VV_clamp(minimum, maximum) { return new __VV_clamp(minimum, maximum); };
function __VV_clamp(minimum, maximum) : ValueValidator() constructor {
	self.minimum = minimum;
	self.maximum = maximum;
	static validate = function(val) { return is_array(val)? array_map(val, function(v) /*=>*/ {return validate(v)}) : clamp(val, minimum, maximum); } 
}
