function Node_Path_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Array";
	previewable = false;
	
	w = 96;
	
	input_fix_len = ds_list_size(inputs);
	data_length   = 1;
	
	outputs[| 0] = nodeValue("Path array", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone )
			.setVisible(true, true);
		
		return inputs[| index];
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _l = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ ) 
			_l[| i] = inputs[| i];
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;	
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static getLineCount = function() { 
		var l = 0;
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _path = inputs[| i].getValue();
			l += struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
		}
		return l; 
	}
	
	static getLength = function(ind = 0) { 
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _path = inputs[| i].getValue();
			var lc    = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getLength(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getBoundary = function(ind = 0) { 
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _path = inputs[| i].getValue();
			var lc    = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getBoundary(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getAccuLength = function(ind = 0) { 
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _path = inputs[| i].getValue();
			var lc    = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getAccuLength(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getSegmentCount = function(ind = 0) { 
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _path = inputs[| i].getValue();
			var lc    = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getSegmentCount(ind);
			ind -= lc;
		}
		
		return 0;
	}
	
	static getPointRatio = function(_rat, ind = 0) {
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _path = inputs[| i].getValue();
			var lc = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getPointRatio(_rat, ind).clone();
			ind -= lc;
		}
		
		return new Point();
	}
	
	static getPointDistance = function(_dist, ind = 0) {
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _path = inputs[| i].getValue();
			var lc = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getPointDistance(_dist, ind).clone();
			ind -= lc;
		}
		
		return new Point();
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		outputs[| 0].setValue(self);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = input_fix_len; i < array_length(_inputs); i += data_length)
			createNewInput();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		
	}
}