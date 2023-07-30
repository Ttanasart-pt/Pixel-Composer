function Node_Cache(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Cache";
	use_cache   = true;
	clearCacheOnChange = false;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue("Cache surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, 0);
	
	input_display_list = [
		["Output",  true], 0, 
	];
	
	cache_loading			= false;
	cache_content			= "";
	cache_loading_progress  = 0;
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { clearCache(); }
	
	static step = function() {
		if(cache_loading) {
			cached_output[cache_loading_progress] = __surface_array_deserialize(cache_content[cache_loading_progress]);
			cache_result[cache_loading_progress]  = true;
			cache_loading_progress++;
			
			if(cache_loading_progress == PROJECT.animator.frames_total) {
				cache_loading = false;
				update();
			}
		}
	}
	
	static update = function() { 
		if(recoverCache()) return;
		if(!inputs[| 0].value_from) return;
		
		var _surf  = inputs[| 0].getValue();
		cacheCurrentFrame(_surf);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(cache_loading)
			draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	}
	
	static doSerialize = function(_map) {
		_map.cache = surface_array_serialize(cached_output);
	}
	
	static postDeserialize = function() { 
		if(!struct_has(load_map, "cache")) return;
		cache_content			= json_try_parse(load_map.cache);
		cache_loading_progress	= 0;
		cache_loading			= true;
	}
}