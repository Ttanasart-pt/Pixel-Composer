function Node_Smoke_Domain_Queue(_x, _y, _group = noone) : Node_Smoke(_x, _y, _group) constructor {
	name = "Queue Domain";
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	newOutput(0, nodeValue_Output("Domain", self, VALUE_TYPE.sdomain, noone));
	
	static createNewInput = function(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue("Input", self, CONNECT_TYPE.input, VALUE_TYPE.sdomain, noone ))
			.setVisible(true, true);
		
		array_push(input_display_list, inAmo);
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
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_smoke_domain_queue, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}