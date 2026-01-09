function Node_To_Text(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "To Text";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0)).setVisible(true, true);
	
	////- =Pad Integer
	newInput( 1, nodeValue_Bool( "Pad Integer",   false ));
	newInput( 2, nodeValue_Int(  "Minimum Digit", 2     ));
	newInput( 3, nodeValue_Text( "Pad Letter",    "0"   ));
	
	////- =Pad Decimal
	newInput( 4, nodeValue_Bool( "Pad Decimal",   false ));
	newInput( 5, nodeValue_Int(  "Minimum Digit", 2     ));
	newInput( 6, nodeValue_Text( "Pad Letter",    "0"   ));
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	input_display_list = [ 0, 
		[ "Pad Integer", false, 1 ], 2, 3, 
		[ "Pad Decimal", false, 4 ], 5, 6, 
	];
	
	////- Node
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		#region data
			var _val = _data[0];
			
			var _pint     = _data[1];
			var _pint_dig = _data[2];
			var _pint_txt = _data[3];
			
			var _pdec     = _data[4];
			var _pdec_dig = _data[5];
			var _pdec_txt = _data[6];
		#endregion
		
		var s    = string_format(_val, 0, _pdec_dig);
		var sSpl = string_split(s, ".");
		
		if(array_length(sSpl) >= 2) sSpl[1] = string_trim_end(sSpl[1], ["0"]);
		
		if(_pint) {
			var _pp = _pint_dig - string_length(sSpl[0]);
			repeat(_pp) sSpl[0] = _pint_txt + sSpl[0]; 
		}
		
		if(_pdec && array_length(sSpl) >= 2) {
			var _pp = _pdec_dig - string_length(sSpl[1]);
			repeat(_pp) sSpl[1] = sSpl[1] + _pdec_txt;  
		}
		
		var _ss = "";
		for( var i = 0, n = array_length(sSpl); i < n; i++ )
			_ss += (i? "." : "") + sSpl[i];
		
		return _ss;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str  = outputs[0].getValue();
		var bbox = draw_bbox;
		draw_text_bbox(bbox, str);
	}
}