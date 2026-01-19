function Node_Array_Range(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Array Range";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Float( "Start",         0 ));
	newInput( 1, nodeValue_Float( "End",          10 ));
	newInput( 2, nodeValue_Float( "Step",          1 ));
	newInput( 3, nodeValue_Bool(  "Inclusive", false ));
	// 4
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.float, []));
	
	input_display_list = [
		[ "Range", false ], 0, 1, 2, 3,
	];
	
	////- Node
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var st  = _data[0];
			var ed  = _data[1];
			var stp = _data[2];
			var inE = _data[3];
			
			if(st == ed) return array_create(abs(stp), st);
		#endregion
		
		stp = abs(stp) * sign(ed - st);
		
		var amo = floor(abs((ed - st + inE) / stp));
		var arr = array_verify(_outData, amo);
		
		for( var i = 0; i < amo; i++ )
			arr[i] = st + i * stp;
		
		return arr;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = getInputSingle(0);
		var edd = getInputSingle(1);
		var stp = getInputSingle(2);
		var arr = outputs[0].getValue();
		
		var str	= "";
		switch(array_length(arr)) {
			case 0 : str = $"[]" break;
			case 1 : 
			case 2 : 
			case 3 : str = $"{arr}" break;
			
			default : str = $"[{arr[0]}, {arr[1]}, ..., {array_safe_get(arr, -1,, ARRAY_OVERFLOW.loop)}]"; break;
		}
		
		var bbox = draw_bbox;
		draw_text_bbox(bbox, str);
	}
}