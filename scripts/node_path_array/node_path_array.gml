function Node_Path_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Combine";
	setDrawIcon(s_node_path_array);
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Combined Path", VALUE_TYPE.pathnode, self));
	
	cached_pos    = ds_map_create();
	curr_path     = [];
	curr_path_amo = 0;
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_PathNode("Path" ));
		
		return inputs[index];
	} setDynamicInput(1, true, VALUE_TYPE.pathnode);
	
	////- Path
	
	static getLineCount = function() {
		var l = 0;
		for( var i = 0; i < curr_path_amo; i++ )
			l += curr_path[i].getLineCount(); 
		
		return l; 
	}
	
	static getSegmentCount = function(ind = 0) {
		for( var i = 0; i < curr_path_amo; i++ ) {
			var lc = curr_path[i].getLineCount() 
			
			if(ind < lc) return curr_path[i].getSegmentCount(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getLength = function(ind = 0) {
		for( var i = 0; i < curr_path_amo; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getLength(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getAccuLength = function(ind = 0) {
		for( var i = 0; i < curr_path_amo; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getAccuLength(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		for( var i = 0; i < curr_path_amo; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getPointRatio(_rat, ind, out);
			ind -= lc;
		}
		
		return new __vec2P();
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) {
		for( var i = 0; i < curr_path_amo; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getPointDistance(_dist, ind, out);
			ind -= lc;
		}
		
		return new __vec2P();
	}
	
	static getBoundary = function(ind = 0) {
		for( var i = 0; i < curr_path_amo; i++ ) {
			var lc = curr_path[i].getLineCount(); 
			
			if(ind < lc) return curr_path[i].getBoundary(ind);
			ind -= lc;
		}
		
		return new BoundingBox();
	}
	
	static pathSpread = function(arr, p) {
		if(is_path(p)) {
			array_push(arr, p);
			return;
		}
		
		if(is_array(p)) {
			for( var i = 0, n = array_length(p); i < n; i++ ) 
				pathSpread(arr, p[i]);
		}
	}
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		for( var i = 0; i < curr_path_amo; i++ ) {
			if(!has(curr_path[i], "drawOverlay")) continue;
			InputDrawOverlay(curr_path[i].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		}
		
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		ds_map_clear(cached_pos);
		outputs[0].setValue(self);
		
		curr_path  = [];
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _path = getInputData(i);
			pathSpread(curr_path, _path);
		}
		
		curr_path_amo = array_length(curr_path);
	}
	
}