function Node_create_Condition(_x, _y) {
	var node = new Node_Condition(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Condition(_x, _y) : Node(_x, _y) constructor {
	name = "Condition";
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue( 0, "Check", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue( 1, "If", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Equal", "Not equal", "Less", "Less or equal", "Greater", "Greater or equal"]);
	inputs[| 2] = nodeValue( 2, "To / Than", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	inputs[| 3] = nodeValue( 3, "True", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1 )
		.setVisible(true, true);
	inputs[| 4] = nodeValue( 4, "False", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1 )
		.setVisible(true, true);
	
	input_display_list = [
		["Condition", false], 0, 1, 2,
		["Result",	  false], 3, 4
	]
	
	outputs[| 0] = nodeValue(0, "Result", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	static update = function() {
		var _chck = inputs[| 0].getValue();
		var _cond = inputs[| 1].getValue();
		var _valu = inputs[| 2].getValue();
		
		var _true = inputs[| 3].getValue();
		var _fals = inputs[| 4].getValue();
		
		var res = false;
		
		switch(_cond) {
			case 0 : res = _chck == _valu; break;
			case 1 : res = _chck != _valu; break;
			case 2 : res = _chck <  _valu; break;
			case 3 : res = _chck <= _valu; break;
			case 4 : res = _chck >  _valu; break;
			case 5 : res = _chck >= _valu; break;
		}
		
		output[| 0].setValue(res? _true : _fals);
	}
}