function Node_Cache_Results(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	  = "Cache Results";
	doUpdate  = doUpdateLite;
	setCacheManual();
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Int(     "Amount", 4  ));
	
	newOutput(0, nodeValue_Output("Cache Surfaces", VALUE_TYPE.surface, []));
	
	input_display_list = [
		[ "Surfaces", false ], 0, 1, 
	];
	
	////- Node
	
	surfaceIndex = 0;
	surfaces     = [];
	
	buttonCacheClear = button(function() /*=>*/ { surface_array_free(surfaces); surfaceIndex = 0; clearCache(true); }).setTooltip(__txt("Clear cache"))
		.setIcon(THEME.dCache_clear, 0, COLORS._main_icon).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	buttonCacheClear.visible = true;
	
	static update = function() {
		var _surf  = inputs[0].getValue();
		var _amou  = inputs[1].getValue();
		
		if(_amou < array_length(surfaces)) {
			for( var i = _amou, n = array_length(surfaces); i < n; i++ ) 
				surface_free_safe(surfaces[i]);
			array_resize(surfaces, _amou);
		}
		
		if(IS_FIRST_FRAME) {
			if(array_length(surfaces) == _amou) {
				var s = surfaces[0];
				surface_free_safe(s);
				array_delete(surfaces, 0, 1);
			}
			
			surfaceIndex = array_length(surfaces);
			surfaces[surfaceIndex] = surface_create(1,1);
		}
		
		outputs[0].setValue(surfaces);
		if(!is_surface(_surf)) return;
		
		var _d = surface_get_dimension(_surf);
		var _s = array_safe_get_fast(surfaces, surfaceIndex);
		    _s = surface_verify(_s, _d[0], _d[1]);
		
		surface_set_shader(_s);
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		surfaces[surfaceIndex] = _s;
		outputs[0].setValue(surfaces);
	}
}