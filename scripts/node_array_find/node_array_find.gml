function Node_Array_Find(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Find";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Any( "Array", 0 )).setVisible(true, true);
	newInput( 1, nodeValue_Any( "Value", 0 )).setVisible(true, true).rejectArray();
	// 2
	
	newOutput(0, nodeValue_Output("Index", VALUE_TYPE.integer, 0));
	
	input_display_list = [ 
		[ "Array", false ],  0, 
		[ "Find",  false ],  1, 
	];
	
	////- =Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr  = getInputData(0);
			var value = getInputData(1);
			
			var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			inputs[1].setType(type);
			
			if(!is_array(_arr)) return;
		#endregion
		
		outputs[0].setValue(array_find(_arr, value));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(outputs[0].getValue()));
	}
}