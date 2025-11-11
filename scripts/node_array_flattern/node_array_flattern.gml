function Node_Array_Flattern(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Flatten";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array in", self, CONNECT_TYPE.input, VALUE_TYPE.any, [])).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Flattened Array", VALUE_TYPE.any, []));
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		outputs[0].setType(type);
		
		var _arr = getInputData(0);
		if(!is_array(_arr)) return;
		
		var _arrSpr = array_spread(_arr);
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
		
		draw_sprite_fit(s_node_array_flattern, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}