function Node_Vector3(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name  = "Vector3";
	color = COLORS.node_blend_number;
	
	w = 96;
	min_h = 32 + 24 * 3;
	draw_padding = 4;
	
	inputs[| 0] = nodeValue("x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue("y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
		
	inputs[| 2] = nodeValue("z", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	inputs[| 3] = nodeValue("Integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static step = function() { #region
		var int = getInputData(3);
		for( var i = 0; i < 3; i++ ) {
			inputs[| i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
			inputs[| i].editWidget.setSlidable(int? 0.1 : 0.01);
		}
		
		outputs[| 0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var vec = [ _data[0], _data[1], _data[2] ];
		for( var i = 0, n = array_length(vec); i < n; i++ ) 
			vec[i] = _data[3]? round(vec[i]) : vec[i];
			
		return vec; 
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var vec = getSingleValue(0,, true);
		var v0 = array_safe_get(vec, 0);
		var v1 = array_safe_get(vec, 1);
		var v2 = array_safe_get(vec, 2);

		var str	= $"{v0}\n{v1}\n{v2}";
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
} #endregion