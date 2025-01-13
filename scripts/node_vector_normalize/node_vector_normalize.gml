function Node_Vector_Normalize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Vector Normalize";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue("Vector", self, CONNECT_TYPE.input, VALUE_TYPE.float, []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Normalized Vector", self, VALUE_TYPE.float, []))
	    .setArrayDepth(1);
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _vec = _data[0];
		if(!is_array(_vec)) return 0;
		
		switch(array_length(_vec)) {
			case 0 : return 1;
			case 1 : return [ 1 ];
			
			case 2 : 
			    var _len = sqrt(sqr(_vec[0]) + sqr(_vec[1]));
			    return _len == 0? [0, 0] : [ _vec[0] / _len, _vec[1] / _len ];
			    
			case 3 : 
			    var _len = sqrt(sqr(_vec[0]) + sqr(_vec[1]) + sqr(_vec[2]));
			    return _len == 0? [0, 0, 0] : [ _vec[0] / _len, _vec[1] / _len, _vec[2] / _len ];
			    
			case 4 : 
			    var _len = sqrt(sqr(_vec[0]) + sqr(_vec[1]) + sqr(_vec[2]) + sqr(_vec[3]));
			    return _len == 0? [0, 0, 0, 0] : [ _vec[0] / _len, _vec[1] / _len, _vec[2] / _len, _vec[3] / _len ];
			
			default : 
				__len = sqrt(array_reduce(_vec, function(_p, _c) /*=>*/ { return _p + _c * _c; }, 0));
				return __len == 0? array_create(array_length(_vec), 0) : array_map(_vec, function(v) /*=>*/ {return v / __len});
		}
		
		return 1;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var val  = outputs[0].getValue();
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(val));
	}
}