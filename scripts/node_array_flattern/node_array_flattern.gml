function Node_Array_Flattern(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Flatten";
	setDimension(96, 48);
	setDrawIcon(s_node_array_flattern);
	
	newInput(0, nodeValue_Any( "Array in", []) ).setVisible(true, true);
	newInput(1, nodeValue_Int( "Depth",    0 ) );
	
	newOutput(0, nodeValue_Output("Flattened Array", VALUE_TYPE.any, []));
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		outputs[0].setType(type);
		
		var _arr = getInputData(0);
		var _dep = getInputData(1);
		if(!is_array(_arr)) return;
		
		var _arrSpr = array_spread(_arr, [], _dep);
		
		outputs[0].setValue(_arrSpr);
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