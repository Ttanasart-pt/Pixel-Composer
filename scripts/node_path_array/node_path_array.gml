function Node_Path_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path Array";
	setDimension(96, 48);;
	
	cached_pos = ds_map_create();
	
	outputs[| 0] = nodeValue("Path array", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone )
			.setVisible(true, true);
		
		return inputs[| index];
	} setDynamicInput(1, true, VALUE_TYPE.pathnode);
	
	static getLineCount = function() { #region
		var l = 0;
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _path = getInputData(i);
			l += struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
		}
		return l; 
	} #endregion
	
	static getSegmentCount = function(ind = 0) { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _path = getInputData(i);
			var lc    = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getSegmentCount(ind);
			ind -= lc;
		}
		
		return 0;
	} #endregion
	
	static getLength = function(ind = 0) { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _path = getInputData(i);
			var lc    = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getLength(ind);
			ind -= lc;
		}
		
		return 0;
	} #endregion
	
	static getAccuLength = function(ind = 0) { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _path = getInputData(i);
			var lc    = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getAccuLength(ind);
			ind -= lc;
		}
		
		return 0;
	} #endregion
	
	static getPointRatio = function(_rat, ind = 0) { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _path = getInputData(i);
			var lc = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getPointRatio(_rat, ind).clone();
			ind -= lc;
		}
		
		return new __vec2();
	} #endregion
	
	static getPointDistance = function(_dist, ind = 0) { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _path = getInputData(i);
			var lc = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getPointDistance(_dist, ind).clone();
			ind -= lc;
		}
		
		return new __vec2();
	} #endregion
	
	static getBoundary = function(ind = 0) { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _path = getInputData(i);
			var lc    = struct_has(_path, "getLineCount")? _path.getLineCount() : 1; 
			
			if(ind < lc) return _path.getBoundary(ind);
			ind -= lc;
		}
		
		return 0;
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _path = getInputData(i);
			if(!struct_has(_path, "drawOverlay")) continue;
			
			if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		ds_map_clear(cached_pos);
		outputs[| 0].setValue(self);
	} #endregion
}