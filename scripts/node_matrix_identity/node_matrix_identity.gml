function Node_Matrix_Identity(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Identity Matrix";
	color = COLORS.node_blend_number;
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Int(  "Size", 3 ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Matrix", VALUE_TYPE.float, new Matrix(3))).setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0 ];
	
	////- Nodes
	
	__prev_size = [ 0, 0 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			var _siz = _data[0];
		#endregion
		
		var _outp = is(_outData, Matrix)? _outData : new Matrix();
		_outp.setSize(_siz);
		
		for( var i = 0; i < _siz; i++ ) 
		for( var j = 0; j < _siz; j++ ) 
			_outp.raw[i * _siz + j] = i == j;
		
		return _outp;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var siz  = getInputSingle(0);
		var str  = $"[{siz}x{siz}]";
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}