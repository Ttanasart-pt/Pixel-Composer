function Node_Array_Unique(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Unique";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array in", self, CONNECT_TYPE.input, VALUE_TYPE.any, []))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Unique Array", self, VALUE_TYPE.any, []));
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		outputs[0].setType(type);
		
		var arr = getInputData(0);
		if(!is_array(arr)) return;
		arr = array_unique(arr);
		
		outputs[0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
			return;
		}
		
		draw_sprite_fit(s_node_array_unique, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}