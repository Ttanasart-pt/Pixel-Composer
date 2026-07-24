function Node_Process_Template(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
		
		#endregion
		
		return _outSurf; 
	}
}

/* dynamic inputs
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_Surface("Input")).setVisible(true, true);
		refreshDynamicDisplay();
		return inputs[index];
	} 
	
	setDynamicInput(1);
*/