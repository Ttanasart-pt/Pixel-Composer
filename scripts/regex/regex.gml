function regex_node(val, accept = false) constructor {
	self.val	= val;
	self.accept = accept;
	
	states = ds_map_create();
	
	static free = function() {
		ds_map_destroy(states);	
	}
	
	static setNext = function(key, node) {
		states[? key] = node;
	}
	
	static consume = function(key) {
		if(ds_map_exists(states, key))	return states[? key];
		if(ds_map_exists(states, "*"))	return states[? "*"];
		return self;
	}
}

function regex_tree(regx) constructor {
	self.regx = regx;
	graph = ds_list_create();
	
	var prev = noone;
	var len = string_length(regx);
	for( var i = 1; i <= len; i++ )  {
		var _chr = string_char_at(regx, i);
		var node = new regex_node(_chr, i == len);
		
		if(_chr == "*") {
			
		} else {
			
		}
		
		if(i > 1) prev.setNext(_chr, node);
		prev = node;
		ds_list_add(graph, node);
	}
	
	static eval = function(str) {
		if(ds_list_empty(graph)) return true;
		var pntr	= graph[| 0];
		var len		= string_length(str);
		
		for( var i = 1; i <= len; i++ ) {
			var _chr = string_char_at(str, i);
			pntr = pntr.consume(_chr);
		}
		
		return pntr.accept;
	}
	
	static free = function() {
		for( var i = 0; i < ds_list_size( graph ); i++ )  {
			graph[| i].free();
		}
		
		ds_list_destroy(graph);
	}
}