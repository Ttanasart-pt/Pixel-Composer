function Queue() constructor {
	data = [];
	
	static enqueue = function(val) {
		if(array_contains(data, val)) return self;
		//array_remove(data, val);
		array_push(data, val);
		
		return self;
	}
	
	static dequeue = function() {
		if(array_length(data) < 1) return undefined;
		
		var val = data[0];
		array_delete(data, 0, 1);
		return val;
	}
	
	static clear = function() {
		data = [];
		return self;
	}
	
	static size  = function() { return array_length(data); }
	static empty = function() { return size() == 0; }
	
	static toString = function() { return "";
		var ss = "[";
		for( var i = 0, n = array_length(data); i < n; i++ ) 
			ss += (i? ", " : "") + data[i].internalName;
		ss += "]"
		return ss;
	}
}