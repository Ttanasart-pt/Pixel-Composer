function Node_Path_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Combine";
	setDimension(96, 48);
	
	cached_pos = ds_map_create();
	
	newOutput(0, nodeValue_Output("Combined Path", self, VALUE_TYPE.pathnode, self));
	
	curr_path  = [];
	
	static createNewInput = function() {
		var index = array_length(inputs);
		
		newInput(index, nodeValue_PathNode("Path", self, noone ))
			.setVisible(true, true);
		
		array_push(input_display_list, index);
		return inputs[index];
	} setDynamicInput(1, true, VALUE_TYPE.pathnode);
	
	static getLineCount = function() {
		var l = 0;
		for( var i = 0, n = array_length(curr_path); i < n; i++ )
			l += curr_path[i].getLineCount(); 
		
		return l; 
	}
	
	static getSegmentCount = function(ind = 0) {
		for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
			var lc = curr_path[i].getLineCount() 
			
			if(ind < lc) return curr_path[i].getSegmentCount(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getLength = function(ind = 0) {
		for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getLength(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getAccuLength = function(ind = 0) {
		for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getAccuLength(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getPointRatio = function(_rat, ind = 0) {
		for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getPointRatio(_rat, ind);
			ind -= lc;
		}
		
		return new __vec2P();
	}
	
	static getPointDistance = function(_dist, ind = 0) {
		for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getPointDistance(_dist, ind);
			ind -= lc;
		}
		
		return new __vec2P();
	}
	
	static getBoundary = function(ind = 0) {
		for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getBoundary(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		for( var i = 0, n = array_length(curr_path); i < n; i++ ) {
			if(!struct_has(curr_path[i], "drawOverlay")) continue;
			
			curr_path[i].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
		
		curr_path  = [];
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _path   = getInputData(i);
			var _ispath = _path != noone && struct_has(_path, "getPointRatio");
			
			if(_ispath) array_push(curr_path, _path);
		}
	}
}