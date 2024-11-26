function Node_Revert(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	  = "Revert";
	use_cache = CACHE_USE.manual;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newOutput(0, nodeValue_Output("Output", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surfaces",  true], 0, 
	];
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() { 
		clearCache(true); 
	}
	
	static update = function() {
		if(!inputs[0].value_from) return;
		if(!inputs[0].value_from.node.renderActive) return;
		
		var _surf = getInputData(0);
		cacheCurrentFrame(_surf);
		
		var _frm = TOTAL_FRAMES - CURRENT_FRAME - 1;
		if(!cacheExist(_frm)) return;
		
		outputs[0].setValue(getCacheFrame(_frm));
	}
}