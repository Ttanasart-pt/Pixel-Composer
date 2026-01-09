function Node_Image_Grid_Patreon(_x, _y, _group = undefined) : Node(_x, _y, _group) constructor {
	name = "Patreon Grid";
	
	newInput(4, nodeValue_Surface( "Surfaces", [])).setVisible(true, true);
	newInput(0, nodeValue_Text(    "Tiers", undefined)).setVisible(true, true);
	
	////- =Grid
	newInput(1, nodeValue_Int(     "Column", 4)).setValidator(VV_min(1)).rejectArray();
	newInput(2, nodeValue_Vec2(    "Spacing", [ 0, 0 ])).rejectArray();
	newInput(3, nodeValue_Padding( "Padding", [ 0, 0, 0, 0 ])).rejectArray();
	
	newOutput(0, nodeValue_Output("Atlas data", VALUE_TYPE.atlas, []));
	
	temp_surface = [ undefined, undefined ];
	
	input_display_list = [ 4, 0,
	    ["Grid", false], 1, 2, 3, 
	];
	
	static update = function(frame = CURRENT_FRAME) {
		var _grup = getInputData(0);
		var _surf = getInputData(4);
		
		var _col  = getInputData(1);
		var _spac = getInputData(2);
		var _padd = getInputData(3);
		
		var _coli = 0;
		var _xx   = 0;
		var _yy   = 0;
		
		var _colW = 0;
		
		var _curG = "";
		var atlas = [];
		
		var _amo  = min(array_length(_surf), array_length(_grup));
		
		for( var j = 0; j < _amo; j++ ) {
			var _s  = _surf[j];
			var _g  = _grup[j];
			
			var _sw = surface_get_width(_s);
			var _sh = surface_get_height(_s);
			
			var _newL = _coli >= _col;
			if(j && _curG != _g) {
				if(_g == "Supporter") {
				    _newL  = true;
				    _colW += 64;
				    
				} else {
					_sh += 80;
					
				}
			}
			_curG = _g;
			
			if(_newL) {
				_coli = 0;
				_xx  += _colW + _spac[0];
				_yy   = 0;
				_colW = 0;
			}
			
			array_push(atlas, new SurfaceAtlas(undefined, _xx, _yy));
			
			_colW = max(_colW, _sw);
			_yy += _sh + _spac[1];
			_coli++;
		}
		
		outputs[0].setValue(atlas);
	}
}

