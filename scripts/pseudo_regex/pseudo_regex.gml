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
	static delim = ["*", "(", ")", "|", "+", "?", "[", "]", "{", "}", "^", "-"];
	
	self.regx = regx;
	nodes = [];
	
	var prev = noone;
	var delm = "";
	var len  = string_length(regx);
	
	for( var i = 1; i <= len; i++ )  {
		var _chr = string_char_at(regx, i);
		
		if(array_exists(_chr, delim)) {
			if(prev != noone)
			switch(_chr) {
				case "*" : prev.setNext(_chr, prev); break;
			}
		} else {
			var node = new regex_node(_chr, i == len);
			if(prev != noone) 
				prev.setNext(_chr, node);
			prev = node;
			array_push(nodes, node);
		}
	}
	
	static isMatch = function(str) {
		if(array_length(nodes) == 0) return true;
		var pntr	= nodes[0];
		var len		= string_length(str);
		
		for( var i = 1; i <= len; i++ ) {
			var _chr = string_char_at(str, i);
			pntr = pntr.consume(_chr);
		}
		
		return pntr.accept;
	}
}