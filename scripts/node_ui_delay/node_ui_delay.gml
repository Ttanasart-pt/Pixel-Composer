function Node_UI_Delay(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "UI Lagger";
	
	newInput(0, nodeValue_Any(   "Input"        )).setVisible(true, true);
	newInput(1, nodeValue_Float( "Delay (s)", 0 ));
	
	newOutput(0, nodeValue_Output("Nothing", VALUE_TYPE.any, noone));
	
	input_display_list = [ 0, 1 ];
	
	////- Nodes
	
	static update = function() {
		var value    = inputs[0].getValue();
		var delaySec = inputs[1].getValue();
		var a, sec = 0;
		
		while(sec < delaySec) {
			var t = get_timer();
			repeat(10000) a = random(1);
			sec += (get_timer() - t) / 1_000_000;
		}
		
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		
		inputs[0].setType(type);
		outputs[0].setType(type);
		outputs[0].setValue(value);
	}
}
