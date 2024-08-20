function Node_Vector_Magnitude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Magnitude";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue("Vector", self, CONNECT_TYPE.input, VALUE_TYPE.float, []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	outputs[0] = nodeValue_Output("Magnitude", self, VALUE_TYPE.float, 0 );
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _vec = _data[0];
		if(!is_array(_vec)) return 0;
		
		switch(array_length(_vec)) {
			case 0 : return 0;
			case 1 : return _vec[0];
			case 2 : return sqrt(sqr(_vec[0]) + sqr(_vec[1]));
			case 3 : return sqrt(sqr(_vec[0]) + sqr(_vec[1]) + sqr(_vec[2]));
			case 4 : return sqrt(sqr(_vec[0]) + sqr(_vec[1]) + sqr(_vec[2]) + sqr(_vec[3]));
			
			default : 
				var _red = array_reduce(_vec, function(_p, _c) { return _p + _c * _c; }, 0);
				return sqrt(_red);
		}
		
		return 0;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var val  = outputs[0].getValue();
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(val));
	}
}