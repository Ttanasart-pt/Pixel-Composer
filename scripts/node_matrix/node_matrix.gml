function Node_Matrix(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix";
	color = COLORS.node_blend_number;
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_IVec2(  "Size", [ 3, 3 ]      ));
	newInput(1, nodeValue_Matrix( "Data", new Matrix(3) ));
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Matrix", VALUE_TYPE.float, new Matrix(3))).setDisplay(VALUE_DISPLAY.matrix);
		
	input_display_list = [ 0, 1 ];
	
	////- Nodes
	
	__prev_size = [ 0, 0 ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			var _siz = _data[0];
			var _dat = _data[1];
		#endregion
		
		var _outp = is(_outData, Matrix)? _outData : new Matrix();
		
		if(__prev_size[0] != _siz[0] || __prev_size[1] != _siz[1]) {
			var _v = inputs[1].animator.values;
			for( var i = 0, n = array_length(_v); i < n; i++ )
				_v[i].value.setSize(_siz);
				
			__prev_size[0] = _siz[0];
			__prev_size[1] = _siz[1];
		}
		
		_outp.setSize(_siz);
		_outp.setArray(is(_dat, Matrix)? _dat.raw : _dat);
		
		return _outp;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var siz  = getInputSingle(0);
		var str  = $"[{siz[0]}x{siz[1]}]";
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}