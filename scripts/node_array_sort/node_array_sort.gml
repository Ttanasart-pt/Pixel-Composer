function Node_Array_Sort(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Sort Array";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, []))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Button("Order", self,  0, [ "Ascending", "Descending" ]))
		.rejectArray();
	
	outputs[0] = nodeValue_Output("Sorted array", self, VALUE_TYPE.any, []);
	
	outputs[1] = nodeValue_Output("Sorted index", self, VALUE_TYPE.integer, [])
		.setVisible(false);
	
	static sortAcs = function(v1, v2) { return v2.val - v1.val; }
	static sortDes = function(v1, v2) { return v1.val - v2.val; }
	
	static update = function(frame = CURRENT_FRAME) {
		var arr = getInputData(0);
		var asc = getInputData(1);
		
		inputs[0].setType(VALUE_TYPE.any);
		outputs[0].setType(VALUE_TYPE.any);
			
		if(!is_array(arr)) return;
		
		var len = array_length(arr);
		
		if(inputs[0].value_from != noone) {
			inputs[0].setType(inputs[0].value_from.type);
			outputs[0].setType(inputs[0].value_from.type);
		}
		
		var _arr = array_map(arr, function(v, i) { return { index: i, val: v }; });
		array_sort(_arr, asc? sortAcs : sortDes);
		
		var resV = array_verify(outputs[0].getValue(), len);
		var resO = array_verify(outputs[1].getValue(), len);
		
		for( var i = 0; i < len; i++ ) {
			resO[i] = _arr[i].index;
			resV[i] = _arr[i].val;
		}
		
		outputs[0].setValue(resV);
		outputs[1].setValue(resO);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_sort, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}