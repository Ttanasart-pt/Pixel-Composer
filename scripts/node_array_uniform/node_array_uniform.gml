function Node_Array_Uniform(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Uniform Array";
	setDimension(96, 32);
	
	newInput( 0, nodeValue_Any( "Data"      )).setVisible(true, true);
	newInput( 1, nodeValue_Int( "Length", 1 ));
	
	newOutput(0, nodeValue_Output("Array Out", VALUE_TYPE.any, noone));
	
	input_display_list = [ 0, 1 ];
	
	////- Nodes
	
	static update = function() {
		var _data = getInputData( 0);
		var _len  = getInputData( 1);
		
		var _type = inputs[0].value_from? inputs[0].value_from.type : VALUE_TYPE.any;
		inputs[0].setType(_type);
		outputs[0].setType(_type);
		
		var _arr  = array_create(_len, _data);
		outputs[0].setValue(_arr);
	}
}
