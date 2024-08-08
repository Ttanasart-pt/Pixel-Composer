function NodeModule(parent) constructor {
	self.parent = parent;
	
	inputs   = [];
	
	load_map   = -1;
	load_scale = false;
	
	static isLeaf = function() {
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i];
			if(_inp.value_from != noone) return false;
		}
		
		return true;
	}
	
	static drawConnections = function(params = {}, _inputs = []) {
		for(var i = 0; i < array_length(inputs); i++) {
			var jun = inputs[i];
			
			if(jun.value_from == noone) continue;
			if(!jun.value_from.node.active) continue;
			if(!jun.isVisible()) continue;
			
			if(i >= 0) array_push(_inputs, jun);
		}
	}
	
	static isRendered = function() { //Check if every input is ready (updated)
		for(var j = 0; j < array_length(inputs); j++)
			if(!inputs[j].isRendered()) return false;
		
		return true;
	}
	
	static resetCache = function() {
		for( var i = 0; i < array_length(inputs); i++ ) {
			if(!is_instanceof(inputs[i], NodeValue)) continue;
			inputs[i].resetCache();
		}
	}
	
	static serialize = function(scale = false, preset = false) {
		var _map = {};
		
		var _inputs = [];
		for(var i = 0; i < array_length(inputs); i++)
			array_push(_inputs, inputs[i].serialize(scale, preset));
		_map.inputs = _inputs;
		
		_map.outputs = [];
		
		return _map;
	}
	
	static deserialize = function(_map, scale = false, preset = false) {
		load_map   = _map;
		load_scale = scale;
	}
	
	static applyDeserialize = function(preset = false) {
		var _inputs = load_map.inputs;
		var amo = min(array_length(inputs), array_length(_inputs));
		
		for(var i = 0; i < amo; i++)
			inputs[i].applyDeserialize(_inputs[i], load_scale, preset);
	}
	
	static connect = function() {
		for(var i = 0; i < array_length(inputs); i++)
			inputs[i].connect(false);
	}
}