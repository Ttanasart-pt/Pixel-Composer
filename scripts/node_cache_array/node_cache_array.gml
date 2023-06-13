function Node_Cache_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Cache Array";
	use_cache   = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Start frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, -1, "Frame index to start caching, set to -1 to start at the first frame.");
	
	inputs[| 2] = nodeValue("Stop frame", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, -1, "Frame index to stop caching (inclusive), set to -1 to stop at the last frame.");
	
	inputs[| 3] = nodeValue("Step", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1, "Cache every N frames, set to 1 to cache every frame.");
	
	outputs[| 0] = nodeValue("Cache array", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, []);
	
	input_display_list = [
		["Output",  true], 0, 
		["Range",  false], 1, 2, 3,
	];
	
	cache_loading			= false;
	cache_content			= "";
	cache_loading_progress  = 0;
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static step = function() { 
		if(cache_loading) {
			cached_output[cache_loading_progress] = surface_array_deserialize(cache_content, cache_loading_progress);
			cache_result[cache_loading_progress] = true;
			cache_loading_progress++;
			
			if(cache_loading_progress == ANIMATOR.frames_total) {
				cache_loading = false;
				update();
			}
		}
	}
	
	static update = function() {
		if(recoverCache()) return;
		
		var ss  = [];
		var str = inputs[| 1].getValue();
		var lst = inputs[| 2].getValue();
		var stp = inputs[| 3].getValue();
		
		if(str == -1) str = 0;
		if(lst == -1) lst = ANIMATOR.frames_total;
		
		if(lst > str && stp > 0) 
		for( var i = str; i <= lst; i += stp ) {
			if(cacheExist(i))
				array_push(ss, cached_output[i]);
		}
		outputs[| 0].setValue(ss);
		
		if(!ANIMATOR.is_playing) return;
		if(!inputs[| 0].value_from) return;
		
		var _surf  = inputs[| 0].getValue();
		cacheCurrentFrame(_surf);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(cache_loading)
			draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
	static doSerialize = function(_map) {
		_map[? "cache"] = surface_array_serialize(cached_output);
	}
	
	static postDeserialize = function() {
		if(!struct_has(load_map, "cache")) return;
		cache_content			= load_map.cache;
		cache_loading_progress  = 0;
		cache_loading			= true;
	}
}