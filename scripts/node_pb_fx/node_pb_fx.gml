function Node_PB_Fx(_x, _y, _group = noone) : Node_PB(_x, _y, _group) constructor {
	name = "PB FX";
	
	inputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
		
	static getpBox = function() {
		var _n = inputs[| 0].value_from;
		if(_n == noone) return;
		
		_n = _n.node;
		
		if(is_instanceof(_n, Node_PB_Draw))
			return _n.outputs[| 1].getValue();
		else if(is_instanceof(_n, Node_PB_Fx))
			return _n.getpBox();
	}
}