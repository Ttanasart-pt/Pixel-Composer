function Node_Cache_Value_Array(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Cache Value Array";
	setDimension(96, 48);
	setDrawIcon(s_node_cache_value_array);
	
	newInput(0, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, noone))
	    .setVisible(true, true);
	
	newInput(1, nodeValue_Int("Start frame", -1, "Frame index to start caching, set to -1 to start at the first frame."));
	
	newInput(2, nodeValue_Int("Stop frame", -1, "Frame index to stop caching (inclusive), set to -1 to stop at the last frame."));
	
	newOutput(0, nodeValue_Output("Cache array", VALUE_TYPE.any, []));
	
	input_display_list = [
		["Value",  true], 0, 
		["Range", false], 1, 2,
	];
	
	cache = [];
	
	static update = function() {
		if(!inputs[0].value_from) {
		    inputs[0].setType(VALUE_TYPE.any);
		    outputs[0].setType(VALUE_TYPE.any);
		    return;
		}
		
		var val = getInputData(0);
		var str = getInputData(1);
		var lst = getInputData(2);
		
		if(str < 0) str = 1;
		if(lst < 0) lst = TOTAL_FRAMES;
		
		str -= 1;
		lst -= 1;
		
		if(CURRENT_FRAME >= str && CURRENT_FRAME <= lst)
	        cache[CURRENT_FRAME] = array_clone(val);
	    
	    inputs[0].setType(inputs[0].value_from.type);    
        outputs[0].setType(inputs[0].value_from.type);
		outputs[0].setValue(cache);
	}
}