function Node_Globalvar(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Globalvar";
	
	newInput(0, nodeValue_Text("Globalvar"));
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.any, noone));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static update = function() {
		
	}
}
