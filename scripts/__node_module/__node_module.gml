function NodeModule(parent) constructor {
	self.parent = parent;
	
	inputs   = ds_list_create();
	
	load_map   = -1;
	load_scale = false;
	
	static isLeaf = function() { #region
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ ) {
			var _inp = inputs[| i];
			if(!_inp.isLeaf()) return false;
		}
		
		return true;
	} #endregion
	
	static drawConnections = function(params = {}, _inputs = []) { #region
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var jun = inputs[| i];
			
			if(jun.isLeaf()) continue;
			if(!jun.value_from.node.active) continue;
			if(!jun.isVisible()) continue;
			
			if(i >= 0) array_push(_inputs, jun);
		}
	} #endregion
	
	static isRendered = function() { #region //Check if every input is ready (updated)
		for(var j = 0; j < ds_list_size(inputs); j++)
			if(!inputs[| j].isRendered()) return false;
		
		return true;
	} #endregion
	
	static resetCache = function() { #region
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(!is_instanceof(inputs[| i], NodeValue)) continue;
			inputs[| i].resetCache();
		}
	} #endregion
	
	static serialize = function(scale = false, preset = false) { #region
		var _map = {};
		
		var _inputs = [];
		for(var i = 0; i < ds_list_size(inputs); i++)
			array_push(_inputs, inputs[| i].serialize(scale, preset));
		_map.inputs = _inputs;
		
		_map.outputs = [];
		
		return _map;
	} #endregion
	
	static deserialize = function(_map, scale = false, preset = false) { #region
		load_map   = _map;
		load_scale = scale;
	} #endregion
	
	static applyDeserialize = function(preset = false) { #region
		var _inputs = load_map.inputs;
		var amo = min(ds_list_size(inputs), array_length(_inputs));
		
		for(var i = 0; i < amo; i++)
			inputs[| i].applyDeserialize(_inputs[i], load_scale, preset);
	} #endregion
	
	static connect = function() { #region
		for(var i = 0; i < ds_list_size(inputs); i++)
			inputs[| i].connect(false);
	} #endregion
}