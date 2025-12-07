function Node_Revert(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	  = "Reverse";
	setCacheManual();
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surfaces",  true], 0, 
	];
	
	static update = function(_frame = CURRENT_FRAME) {
		if(!inputs[0].value_from) return;
		if(!inputs[0].value_from.node.renderActive) return;
		
		var _surf = getInputData(0);
		cacheCurrentFrame(_surf);
		
		var _frm = TOTAL_FRAMES - _frame - 1;
		if(!cacheExist(_frm)) return;
		
		outputs[0].setValue(getCacheFrame(_frm));
	}
}