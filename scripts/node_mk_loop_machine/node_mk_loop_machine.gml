function Node_MK_Loop_Machine(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "MK Loop Machine";
	use_cache = CACHE_USE.manual;
	
	is_simulation = true;
	
	newInput(0, nodeValue_Surface("Surface"));
	
	newInput(1, nodeValue_Int("Delay Amounts", 4));
	
	newInput(2, nodeValue_Int("Delay Frames", 1));
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Loop",   false], 1, 2, 7, 
		["Render", false], 3, 5, 6, 4, 8, 9, 
	];
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() { clearCache(); }
	
	static update = function() {  
		
	}
}