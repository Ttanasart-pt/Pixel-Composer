function Node_Cache_Array(_x, _y, _group = noone) : __Node_Cache(_x, _y, _group) constructor {
	name	  = "Cache Array";
	use_cache = CACHE_USE.manual;
	
	////- =Surfaces
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Range
	newInput(1, nodeValue_Int("Start frame", -1, "Frame index to start caching, set to -1 to start at the first frame."));
	newInput(2, nodeValue_Int("Stop frame", -1, "Frame index to stop caching (inclusive), set to -1 to stop at the last frame."));
	newInput(3, nodeValue_Int("Step", 1, "Cache every N frames, set to 1 to cache every frame."));
	
	newOutput(0, nodeValue_Output("Cache array", VALUE_TYPE.surface, []));
	
	input_display_list = [
		["Surfaces",  true], 0, 
		["Range",    false], 1, 2, 3,
	];
	
	////- Node
	
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
		if(cache_loading || !IS_PLAYING) return;
	
		if(!inputs[0].value_from) return;
		if(!inputs[0].value_from.node.renderActive) {
			enableNodeGroup();
			return;
		}
		
		var surf = getInputData(0);
		var str  = getInputData(1);
		var lst  = getInputData(2);
		var stp  = getInputData(3);
		
		if(str < 0) str = 1;
		if(lst < 0) lst = TOTAL_FRAMES;
		str -= 1;
		
		if(lst < str || stp <= 0) return;
		if(IS_LAST_FRAME) disableNodeGroup();
		if(CURRENT_FRAME <  str || CURRENT_FRAME >= lst) return;
		
		cacheCurrentFrame(surf);
		
		var ss   = outputs[0].getValue();
		var _len = 0;
		
		for( var i = str; i < lst; i += stp )
			ss[_len++] = cacheExist(i)? cached_output[i] : -1;
		
		array_resize(ss, _len);
		outputs[0].setValue(ss);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(cache_loading) draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
	////- Serialize
	
	static doSerialize = function(_map) {
		_map.cache = surface_array_serialize(cached_output);
	}
	
	static postDeserialize = function() {
		refreshCacheGroup();
		
		if(!attributes.serialize) return; 
		if(!struct_has(load_map, "cache")) return;
		cache_content			= json_try_parse(load_map.cache);
		cache_loading_progress  = 0;
		cache_loading			= true;
	}
}