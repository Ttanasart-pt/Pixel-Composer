function Node_Cache_Array(_x, _y, _group = noone) : __Node_Cache(_x, _y, _group) constructor {
	name	  = "Cache Array";
	use_cache = CACHE_USE.manual;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Int("Start frame", self, -1, "Frame index to start caching, set to -1 to start at the first frame."));
	
	newInput(2, nodeValue_Int("Stop frame", self, -1, "Frame index to stop caching (inclusive), set to -1 to stop at the last frame."));
	
	newInput(3, nodeValue_Int("Step", self, 1, "Cache every N frames, set to 1 to cache every frame."));
	
	newOutput(0, nodeValue_Output("Cache array", self, VALUE_TYPE.surface, []));
	
	input_display_list = [
		["Surfaces",  true], 0, 
		["Range",    false], 1, 2, 3,
	];
	
	cache_loading			= false;
	cache_content			= "";
	cache_loading_progress	= 0;
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ], function() /*=>*/ { clearCache(); enableNodeGroup(); });
	
	static step = function() {
		if(!cache_loading) return;
		
		var _content = cache_content[cache_loading_progress];
			
		cached_output[cache_loading_progress] = __surface_array_deserialize(_content);
		cache_result[cache_loading_progress]  = true;
		cache_loading_progress++;
			
		if(cache_loading_progress == array_length(cache_content)) {
			cache_loading = false;
			update();
		}
	}
	
	static update = function() {
		if(cache_loading) return;
	
		if(!inputs[0].value_from) return;
		if(!inputs[0].value_from.node.renderActive) {
			if(!cacheExist(CURRENT_FRAME))
				enableNodeGroup();
			return;
		}
		
		var ss  = [];
		var str = getInputData(1);
		var lst = getInputData(2);
		var stp = getInputData(3);
		
		if(str < 0) str = 1;
		if(lst < 0) lst = TOTAL_FRAMES;
		
		str -= 1;
		lst -= 1;
		
		if(CURRENT_FRAME < str) return;
		if(CURRENT_FRAME > lst) return;
		
		cacheCurrentFrame(getInputData(0));
		
		if(lst > str && stp > 0) 
		for( var i = str; i <= lst; i += stp )
			if(cacheExist(i)) array_push(ss, cached_output[i]);
		
		outputs[0].setValue(ss);
		
		disableNodeGroup();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(cache_loading) draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
	static doSerialize = function(_map) {
		_map.cache = surface_array_serialize(cached_output);
	}
	
	static postDeserialize = function() {
		refreshCacheGroup();
		
		if(!struct_has(load_map, "cache")) return;
		cache_content			= json_try_parse(load_map.cache);
		cache_loading_progress  = 0;
		cache_loading			= true;
	}
}