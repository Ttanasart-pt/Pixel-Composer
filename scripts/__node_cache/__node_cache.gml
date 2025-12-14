#region global
	enum CACHE_USE { none, manual, auto }
#endregion

function __node_cache() {
	setCacheAuto();
	cached_output	= [];
	cache_result	= [];
	cache_group     = noone;
	
	clearCacheOnChange	= true;
	
	////- Method
	
	static isAllCached = function() {
		for( var i = 0; i < TOTAL_FRAMES; i++ )
			if(!cacheExist(i)) return false;
		return true;
	}
	
	static cacheCheck = function() {
		INLINE
		
		if(cache_group) cache_group.enableNodeGroup();
		if(group != noone) group.cacheCheck();
	}
	
	static getAnimationCacheExist = function(frame) { return cacheExist(frame); }
	
	static clearInputCache = function() {
		for( var i = 0; i < array_length(inputs); i++ )
			inputs[i].cache_value[0] = false;
	}
	
	static cacheArrayCheck = function() {
		cached_output = array_verify(cached_output, TOTAL_FRAMES + 1);
		cache_result  = array_verify(cache_result,  TOTAL_FRAMES + 1);
	}
	
	static cacheCurrentFrame = function(_surface) {
		cacheArrayCheck();
		var _frame = NODE_CURRENT_FRAME;
		
		if(_frame < 0) return;
		if(_frame >= array_length(cached_output)) return;
		
		if(is_array(_surface)) {
			surface_array_free(cached_output[_frame]);
			cached_output[_frame] = surface_array_clone(_surface);
			
		} else if(surface_exists(_surface)) {
			var _sw = surface_get_width(_surface);
			var _sh = surface_get_height(_surface);
			
			cached_output[_frame] = surface_verify(cached_output[_frame], _sw, _sh);
			surface_set_target(cached_output[_frame]);
				DRAW_CLEAR BLEND_OVERRIDE
				draw_surface(_surface, 0, 0);
			surface_reset_target();
		}
		
		array_safe_set(cache_result, _frame, true);
		
		return cached_output[_frame];
	}
	
	static cacheExist = function(frame = NODE_CURRENT_FRAME) {
		if(frame < 0) return false;
		
		if(frame >= array_length(cached_output)) return false;
		if(frame >= array_length(cache_result))  return false;
		if(!array_safe_get_fast(cache_result, frame, false)) return false;
		
		var s = array_safe_get_fast(cached_output, frame);
		return is_array(s) || surface_exists(s);
	}
	
	static getCacheFrame = function(frame = NODE_CURRENT_FRAME) {
		if(frame < 0) return false;
		
		if(!cacheExist(frame)) return noone;
		var surf = array_safe_get_fast(cached_output, frame);
		return surf;
	}
	
	static recoverCache = function(frame = NODE_CURRENT_FRAME) {
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[NODE_CURRENT_FRAME];
		outputs[0].setValue(_s);
			
		return true;
	}
	
	static clearCache = function(_force = false) {
		clearInputCache();
		
		if(!_force) {
			if(!use_cache)          return;
			if(!clearCacheOnChange) return;
			if(!isRenderActive())   return;
		}
		
		if(array_length(cached_output) != TOTAL_FRAMES)
			array_resize(cached_output, TOTAL_FRAMES);
		for(var i = 0; i < array_length(cached_output); i++) {
			var _s = cached_output[i];
			if(is_surface(_s))
				surface_free(_s);
			cached_output[i] = 0;
			cache_result[i] = false;
		}
	}
	
	static clearCacheForward = function() {
		if(!isRenderActive()) return;
		
		clearCache();
		var arr = getNextNodesRaw();
		for( var i = 0, n = array_length(arr); i < n; i++ )
			arr[i].clearCacheForward();
	}
	
	static cachedPropagate = function(_group = group) {
		if(group != _group) return;
		setRenderStatus(true);
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _input = inputs[i];
			if(_input.value_from == noone) continue;
			
			_input.value_from.node.cachedPropagate(_group);
		}
	}
	
	static clearInputCache = function() {
		for( var i = 0; i < array_length(inputs); i++ ) {
			if(!is(inputs[i], NodeValue)) continue;
			inputs[i].resetCache();
		}
	}
	
}