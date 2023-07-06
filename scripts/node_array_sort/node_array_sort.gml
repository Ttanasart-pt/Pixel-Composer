function Node_Array_Sort(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Sort Array";
	previewable = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Array in", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [])
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Ascending", "Descending" ])
		.rejectArray();
	
	outputs[| 0] = nodeValue("Sorted array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	outputs[| 1] = nodeValue("Sorted index", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, []);
	
	static sortAcs = function(v1, v2) { return v1[1] < v2[1]; }
	static sortDes = function(v1, v2) { return v1[1] > v2[1]; }
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var arr = inputs[| 0].getValue();
		var asc = inputs[| 1].getValue();
		
		inputs[| 0].type = VALUE_TYPE.any;
		outputs[| 0].type = VALUE_TYPE.any;
			
		if(!is_array(arr)) return;
		
		if(inputs[| 0].value_from != noone) {
			inputs[| 0].type = inputs[| 0].value_from.type;
			outputs[| 0].type = inputs[| 0].value_from.type;
		}
		
		var _arr = [];
		for( var i = 0; i < array_length(arr); i++ )
			_arr[i] = [ i, arr[i] ];
		
		array_sort(_arr, asc? sortAcs : sortDes);
		
		var res = [ [], [] ];
		for( var i = 0; i < array_length(_arr); i++ ) {
			res[0][i] = _arr[i][0];
			res[1][i] = _arr[i][1];
		}
		
		outputs[| 0].setValue(res[1]);
		outputs[| 1].setValue(res[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_sort, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}