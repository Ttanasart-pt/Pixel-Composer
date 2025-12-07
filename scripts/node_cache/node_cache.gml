function Node_Cache(_x, _y, _group = noone) : __Node_Cache(_x, _y, _group) constructor {
	name	  = "Cache";
	use_cache = CACHE_USE.auto;
	doUpdate  = doUpdateLite;
	
	////- =Surfaces
	newInput(0, nodeValue_Surface("Surface In"));
	
	newOutput(0, nodeValue_Output("Cache surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surfaces",  true], 0, 
	];
	
	////- Node
	
	cache_loading			= false;
	cache_content			= "";
	cache_loading_progress  = 0;
	
	insp2button = button(function() /*=>*/ { clearCache(true); enableNodeGroup(); }).setTooltip(__txt("Clear cache"))
		.setIcon(THEME.dCache_clear, 0, COLORS._main_icon).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
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
		if(!IS_PLAYING) {
			recoverCache();
			return;
		}
		
		if(recoverCache() || cache_loading) return;
		
		if(!inputs[0].value_from) return;
		if(!inputs[0].value_from.node.renderActive) {
			enableNodeGroup();
			return;
		}
		
		var _surf  = inputs[0].getValue();
		cacheCurrentFrame(_surf);
		if(IS_LAST_FRAME) disableNodeGroup();
		
		outputs[0].setValue(_surf);
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
		cache_loading_progress	= 0;
		cache_loading			= true;
	}
}