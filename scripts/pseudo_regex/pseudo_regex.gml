function regex_node(val, accept = false) constructor {
	self.val	= val;
	self.accept = accept;
	
	states = {};
	
	static setNext = function(key, node) {
		states[$ key] = node;
	}
	
	static consume = function(key) {
		return struct_has(states, key)? states[$ key] : self;
	}
}

function regex_tree(regx) constructor {
	regs = string_splice(regx, ";", false, false);
	
	static isMatch = function(str) {
		for (var i = 0, n = array_length(regs); i < n; i++) {
			var rgx = regs[i];
			if(RegexMatch(str, rgx))
				return true;
		}
		
		return false;
	}
}