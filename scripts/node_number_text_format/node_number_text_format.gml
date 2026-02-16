function Node_Number_Text_Format(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Format Number";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Float("Number", 0)).setVisible(true, true);
	
	////- =Pad Integer
	newInput( 1, nodeValue_Bool( "Pad Integer",   false ));
	newInput( 2, nodeValue_Int(  "Minimum Digit", 2     ));
	newInput( 3, nodeValue_Text( "Pad Letter",    "0"   ));
	newInput( 7, nodeValue_Text( "Thousands Sep", ""    ));
	
	////- =Pad Decimal
	newInput( 4, nodeValue_Bool( "Pad Decimal",   false ));
	newInput( 5, nodeValue_Int(  "Minimum Digit", 2     ));
	newInput( 6, nodeValue_Text( "Pad Letter",    "0"   ));
	newInput( 8, nodeValue_Text( "Decimal Sep",   "."   ));
	// 9
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	input_display_list = [ 0, 
		[ "Pad Integer", false, 1 ], 2, 3, 7, 
		[ "Pad Decimal", false, 4 ], 5, 6, 8, 
	];
	
	////- Node
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		#region data
			var _val = _data[0];
			
			var _pint     = _data[1];
			var _pint_dig = _data[2];
			var _pint_txt = _data[3];
			var _thou_sep = _data[7];
			
			var _pdec     = _data[4];
			var _pdec_dig = _data[5];
			var _pdec_txt = _data[6];
			var _pdec_sep = _data[8];
		#endregion
		
		var s    = string_format(_val, 0, _pdec_dig);
		var sSpl = string_split(s, ".");
		
		var _sint = array_safe_get_fast(sSpl, 0, "");
		var _sdec = array_safe_get_fast(sSpl, 1, "");
		    _sdec = string_trim_end(_sdec, ["0"]);
		
		if(_pint) {
			var _pp = _pint_dig - string_length(_sint);
			repeat(_pp) _sint = _pint_txt + _sint; 
		}
		
		if(_thou_sep != "") {
			var _len = string_length(_sint);
			var _amo = floor((_len - 1) / 3);
			
			repeat(_amo) {
				_sint = string_insert(_thou_sep, _sint, _len - 3 + 1);
				_len -= 3;
			}
		}
		
		if(_pdec) {
			var _pp = _pdec_dig - string_length(_sdec);
			repeat(_pp) _sdec = _sdec + _pdec_txt;  
		}
		
		var _ss = _sint;
		if(_sdec != "") _ss += $"{_pdec_sep}{_sdec}";
		
		return _ss;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str  = outputs[0].getValue();
		var bbox = draw_bbox;
		draw_text_bbox(bbox, str);
	}
}