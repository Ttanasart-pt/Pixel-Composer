function Node_Padding_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Padding Data";
	color = COLORS.node_blend_number;
	setDrawIcon();
	setDimension(96, 48);
	
	////- Relative
	newInput( 4, nodeValue_Bool(    "Use Relative", false ));
	newInput( 5, nodeValue_Surface( "Reference Surface"     ));
	
	////- Padding
	newInput( 6, nodeValue_EScroll( "Mode",    0, ["Scalar", "Vec4 LR-TB"] ));
	newInput( 0, nodeValue_Float(   "Left",    0 ));
	newInput( 1, nodeValue_Float(   "Right",   0 ));
	newInput( 2, nodeValue_Float(   "Top",     0 ));
	newInput( 3, nodeValue_Float(   "Bottom",  0 ));
	newInput( 7, nodeValue_Vec4(    "Vec4",   [0,0,0,0] ));
	// 8
	
	newOutput(0, nodeValue_Output("Padding", VALUE_TYPE.float, [ 0, 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.padding);
	
	input_display_list = [ 
		[ "Relative", false, 4 ],  5, 
		[ "Padding",  false    ],  6,  0,  1,  2,  3,  7,  
	];
	
	////- Node
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		#region data
			var _ref = _data[ 4];
			var _sur = _data[ 5];
			
			var _mod = _data[ 6];
			var _sl  = _data[ 0];
			var _sr  = _data[ 1];
			var _st  = _data[ 2];
			var _sb  = _data[ 3];
			var _vec = _data[ 7];
			
			inputs[ 0].setVisible(_mod == 0);
			inputs[ 1].setVisible(_mod == 0);
			inputs[ 2].setVisible(_mod == 0);
			inputs[ 3].setVisible(_mod == 0);
			inputs[ 7].setVisible(_mod == 1);
		#endregion
		
		var _sw = surface_get_width_safe(_sur);
		var _sh = surface_get_height_safe(_sur);
		
		var _l = 1;
		var _r = 1;
		var _t = 1;
		var _b = 1;

		switch(_mod) {
			case 0 :
				_l = _sl;
				_r = _sr;
				_t = _st;
				_b = _sb;
				break;
				
			case 1 : 
				_l = _vec[0];
				_r = _vec[1];
				
				_t = _vec[2];
				_b = _vec[3];
				break;
				
		}

		if(_ref) {
			_l *= _sw;
			_r *= _sw;
			
			_t *= _sh;
			_b *= _sh;
		}
		
		return [ _r, _t, _l, _b ];
	}
	
}