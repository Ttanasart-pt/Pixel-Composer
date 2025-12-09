function Node_Smoke_Domain_Queue(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name = "Queue Domain";
	setDimension(96, 48);
	setDrawIcon(s_node_smoke_domain_queue);
	
	manual_ungroupable	 = false;
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.sdomain, noone));
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue("Input", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone ))
			.setVisible(true, true);
		
		return inputs[index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.sdomain);
	
	static update = function() {
		for( var i = 0; i < array_length(inputs); i++ ) {
			var _dom = getInputData(i);
			
			if(is(_dom, smokeSim_Domain))
				outputs[0].setValue(_dom);
		}
	}
	
}