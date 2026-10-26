function Node_Array_Uniform(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Uniform Array";
	setDimension(96, 32);
	
	newInput( 0, nodeValue_Any( "Data"      )).setVisible(true, true);
	newInput( 1, nodeValue_Int( "Length", 1 ));
	// 2
	
	newOutput(0, nodeValue_Output("Array Out", VALUE_TYPE.any, noone));
	
	input_display_list = [ 0, 1 ];
	
	////- Node
	
	static update = function() {
		#region data
			var _data = getInputData( 0);
			var _len  = getInputData( 1);
			
			var _type = inputs[0].getType();
			var isig  = inputs[0].getTypeSignature();
			
			inputs[0].setType(_type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(_type);
		#endregion
		
		var _arr  = array_create(_len, _data);
		var  sig  = array_create(_len,  isig);
		
		inputs[0].setTypeSignature(sig);
		outputs[0].setValue(_arr);
		
	}
}
