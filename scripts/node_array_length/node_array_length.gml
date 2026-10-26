function Node_Array_Length(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Length";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Any( "Array" )).setVisible(true, true);
	// 1
	
	newOutput(0, nodeValue_Output("Size", VALUE_TYPE.integer, 0));
	
	input_display_list = [ 
		[ "Array", false ],  0,
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr = getInputData(0);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
		#endregion
		
		outputs[0].setValue(array_safe_length(_arr));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(outputs[0].getValue()));
	}
}