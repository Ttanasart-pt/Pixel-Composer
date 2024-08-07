function Node_Cache(_x, _y, _group = noone) : __Node_Cache(_x, _y, _group) constructor {
	name	  = "Cache";
	use_cache = CACHE_USE.auto;
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	outputs[| 0] = nodeValue_Output("Cache surface", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surfaces",  true], 0, 
	];
	
	cache_loading			= false;
	cache_content			= "";
	cache_loading_progress  = 0;
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { 
		clearCache(true); 
		enableNodeGroup();
	}
	
	static step = function() { #region
		if(cache_loading) {
			cached_output[cache_loading_progress] = __surface_array_deserialize(cache_content[cache_loading_progress]);
			cache_result[cache_loading_progress]  = true;
			cache_loading_progress++;
			
			if(cache_loading_progress == TOTAL_FRAMES) {
				cache_loading = false;
				update();
			}
		}
	} #endregion
	
	static update = function() { #region
		if(recoverCache() || cache_loading) return;
		
		if(!inputs[| 0].value_from) return;
		if(!inputs[| 0].value_from.node.renderActive) {
			enableNodeGroup();
			return;
		}
		
		var _surf  = getInputData(0);
		cacheCurrentFrame(_surf);
		
		disableNodeGroup();
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		if(cache_loading)
			draw_sprite_ui(THEME.loading, 0, xx + w * _s / 2, yy + h * _s / 2, _s, _s, current_time / 2, COLORS._main_icon, 1);
	} #endregion
	
	static doSerialize = function(_map) { #region
		_map.cache = surface_array_serialize(cached_output);
	} #endregion
	
	static postDeserialize = function() { #region
		refreshCacheGroup();
		
		if(!struct_has(load_map, "cache")) return;
		cache_content			= json_try_parse(load_map.cache);
		cache_loading_progress	= 0;
		cache_loading			= true;
	} #endregion
}