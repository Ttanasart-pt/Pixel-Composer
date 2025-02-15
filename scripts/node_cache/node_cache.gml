function Node_Cache(_x, _y, _group = noone) : __Node_Cache(_x, _y, _group) constructor {
	name	  = "Cache";
	use_cache = CACHE_USE.auto;
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newOutput(0, nodeValue_Output("Cache surface", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surfaces",  true], 0, 
	];
	
	cache_loading			= false;
	cache_content			= "";
	cache_loading_progress  = 0;
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ], function() /*=>*/ { clearCache(true); enableNodeGroup(); });
	
	static step = function() {
		if(!cache_loading) return;
		
		cached_output[cache_loading_progress] = __surface_array_deserialize(cache_content[cache_loading_progress]);
		cache_result[cache_loading_progress]  = true;
		cache_loading_progress++;
		
		if(cache_loading_progress == TOTAL_FRAMES) {
			cache_loading = false;
			update();
		}
	}
	
	static update = function() {
		if(recoverCache() || cache_loading) return;
		
		if(!inputs[0].value_from) return;
		if(!inputs[0].value_from.node.renderActive) {
			enableNodeGroup();
			return;
		}
		
		var _surf  = getInputData(0);
		cacheCurrentFrame(_surf);
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
		
		if(!attributes.serialize) return; 
		if(!struct_has(load_map, "cache")) return;
		cache_content			= json_try_parse(load_map.cache);
		cache_loading_progress	= 0;
		cache_loading			= true;
	}
}