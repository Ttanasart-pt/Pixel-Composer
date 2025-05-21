function Node_Array_Boolean_Opr(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Boolean Opr";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array 1", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue("Array 2", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
		
	newInput(2, nodeValue_Enum_Scroll("Operation", 0, [ "Union", "Subtract", "Intersect", "XOR" ]))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array out", VALUE_TYPE.any, []));
	
	input_display_list = [ 2, 0, 1 ];
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		inputs[1].setType(type);
		outputs[0].setType(type);
		
		var arr1 = getInputData(0);
		var arr2 = getInputData(1);
		var opr  = getInputData(2);
		if(!is_array(arr1) || !is_array(arr2)) return;
		
		var _arr;
		
		switch(opr) {
		    case 0 : _arr = array_union(arr1, arr2);         break;
	        case 1 : _arr = array_substract(arr1, arr2);     break;
	        case 2 : _arr = array_intersection(arr1, arr2);  break;
	        case 3 : _arr = array_xor(arr1, arr2);           break;
		}
		
		outputs[0].setValue(_arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var opr  = getInputData(2);
		var str  = "";
		
		switch(opr) {
		    case 0 : str = "union"        break;
	        case 1 : str = "substract"    break;
	        case 2 : str = "intersection" break;
	        case 3 : str = "xor"          break;
		}
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}