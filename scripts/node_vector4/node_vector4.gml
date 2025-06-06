function Node_Vector4(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Vector4";
	color = COLORS.node_blend_number;
	setDimension(96, 32 + 24 * 4);
	
	newInput(0, nodeValue_Float("x", 0))
		.setVisible(true, true);
		
	newInput(1, nodeValue_Float("y", 0))
		.setVisible(true, true);
		
	newInput(2, nodeValue_Float("z", 0))
		.setVisible(true, true);
		
	newInput(3, nodeValue_Float("w", 0))
		.setVisible(true, true);
	
	newInput(4, nodeValue_Bool("Integer", false));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Vector", VALUE_TYPE.float, [ 0, 0, 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
		
	newOutput(1, nodeValue_Output("x", VALUE_TYPE.float, 0))
		
	newOutput(2, nodeValue_Output("y", VALUE_TYPE.float, 0))
		
	newOutput(3, nodeValue_Output("z", VALUE_TYPE.float, 0))
		
	newOutput(4, nodeValue_Output("w", VALUE_TYPE.float, 0))
		
	input_display_list = [ 0, 1, 2, 3, 4, 
	];
	
	static step = function() {
		var int = getInputData(4);
		for( var i = 0; i < 4; i++ )
			inputs[i].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
		
		outputs[0].setType(int? VALUE_TYPE.integer : VALUE_TYPE.float);
	}
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _x   = _data[0];
		var _y   = _data[1];
		var _z   = _data[2];
		var _w   = _data[3];
		var _int = _data[4];
		
		_outData[0][0] = _int? round(_x) : _x;
		_outData[0][1] = _int? round(_y) : _y;
		_outData[0][2] = _int? round(_z) : _z;
		_outData[0][3] = _int? round(_w) : _w;
		
		_outData[1] = _outData[0][0];
		_outData[2] = _outData[0][1];
		_outData[3] = _outData[0][2];
		_outData[4] = _outData[0][3];
		
		return _outData;
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