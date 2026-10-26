function Node_Array_Reverse(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Reverse";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_Any( "Array" )).setVisible(true, true);
	// 1
		
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, 0));
	
	////- =Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			outputs[0].setTypeSignature(isig);
			
			var _arr = getInputData(0);
			if(!is_array(_arr)) return;
		#endregion
		
		outputs[0].setTypeSignature(is_array(isig)? array_reverse(isig) : isig);
		outputs[0].setValue(array_reverse(_arr));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
			return;
		}
	}
}