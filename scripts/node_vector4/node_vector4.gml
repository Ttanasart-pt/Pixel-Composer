function Node_Vector4(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Vector4";
	color = COLORS.node_blend_number;
	setDimension(96, 32 + 24 * 4);
	
	inputs[| 0] = nodeValue_Float("x", self, 0)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue_Float("y", self, 0)
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue_Float("z", self, 0)
		.setVisible(true, true);
		
	inputs[| 3] = nodeValue_Float("w", self, 0)
		.setVisible(true, true);
	
	inputs[| 4] = nodeValue_Bool("Integer", self, false);
	
	outputs[| 0] = nodeValue_Output("Vector", self, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	static step = function() {
		var int = getInputData(4);
		for( var i = 0; i < 4; i++ )
			inputs[| i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
		
		outputs[| 0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var vec = [ _data[0], _data[1], _data[2], _data[3] ];
		for( var i = 0, n = array_length(vec); i < n; i++ ) 
			vec[i] = _data[4]? round(vec[i]) : vec[i];
			
		return vec; 
	} 
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var vec = getSingleValue(0,, true);
		var v0 = array_safe_get_fast(vec, 0);
		var v1 = array_safe_get_fast(vec, 1);
		var v2 = array_safe_get_fast(vec, 2);
		var v3 = array_safe_get_fast(vec, 3);
		
		var str	= $"{v0}\n{v1}\n{v2}\n{v3}";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}