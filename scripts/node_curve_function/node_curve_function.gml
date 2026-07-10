function Node_Curve_Function(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Curve Fn";
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Function
	newInput( 0, nodeValue_EScroll( "Type",       0, [ "Linear", "Wave", "Zigzag", "Saw", "Step" ] ));
	newInput( 5, nodeValue_Range(   "Range",     [0,1] ));
	newInput( 6, nodeValue_Float(   "Frequency",  1    ));
	newInput( 7, nodeValue_Float(   "Phase",      0    ));
	newInput( 8, nodeValue_Int(     "Resolution", 0    ));
	newInput( 9, nodeValue_Int(     "Step",       4    ));
	
	////- =Curve 
	newInput( 1, nodeValue_Float(  "Shift",         0    ));
	newInput( 2, nodeValue_Float(  "Scale",         1    ));
	newInput( 3, nodeValue_Range(  "Output Range", [0,1] ));
	newInput( 4, nodeValue_Range(  "Y Range",      [0,1] ));
	// 10
	
	newOutput(0, nodeValue_Output("Curve", VALUE_TYPE.curve, CURVE_DEF_01 ));
	
	input_display_list = [ 
		[ "Function", false ],  0,  5,  6,  7,  8,  9, 
		[ "Curve",    false ],  1,  2,  3,  4,  
	];
	
	////- Node
	
	static update = function() {
		#region data
			var _type  = getInputData( 0); 
			var _range = getInputData( 5); 
			var _freq  = getInputData( 6); 
			var _phase = getInputData( 7); 
			var _reso  = getInputData( 8); 
			var _step  = getInputData( 9); 
			
			var _shft  = getInputData( 1); 
			var _scal  = getInputData( 2); 
			var _orng  = getInputData( 3); 
			var _yrng  = getInputData( 4); 
			
			inputs[ 6].setVisible(false);
			inputs[ 7].setVisible(false);
			inputs[ 8].setVisible(false);
			inputs[ 9].setVisible(false);
		#endregion
		
		var _ctype = 0;
		switch(_type) {
			case 0 : _ctype = 0; break;
			case 1 : _ctype = 0; break;
			case 2 : _ctype = 0; break;
			case 3 : _ctype = 0; break;
			case 4 : _ctype = 1; break;
		}
		
		var _segs = [];
		outputs[0].setValue(_segs);
		
		_segs[0] = _shft;    // x shift
		_segs[1] = _scal;    // x scale
		_segs[2] = _ctype;   // type
		_segs[3] = _orng[0]; // min y
		_segs[4] = _orng[1]; // max y
		_segs[5] = 0;        // -
		
		// curve format [-cx0, -cy0, x0, y0, +cx0, +cy0, // -cx1, -cy1, x1, y1, +cx1, +cy1]
		
		var _ind = 6;
		
		switch(_type) {
			case 0 :
				_segs[_ind++] = 0;
				_segs[_ind++] = 0;
				_segs[_ind++] = 0;
				_segs[_ind++] = _range[0];
				_segs[_ind++] = 0;
				_segs[_ind++] = 0;
				
				_segs[_ind++] = 0;
				_segs[_ind++] = 0;
				_segs[_ind++] = 1;
				_segs[_ind++] = _range[1];
				_segs[_ind++] = 0;
				_segs[_ind++] = 0;
				break;
				
			case 1 : 
				inputs[ 6].setVisible( true);
				inputs[ 7].setVisible( true);
				inputs[ 8].setVisible( true);
				
				for( var i = 0; i <= _reso; i++ ) {
					var _x = i / _reso;
					
					var _y = sin((_x * _freq - _phase) * pi * 2) * .5 + .5;
					    _y = lerp(_range[0], _range[1], _y);
					
					_segs[_ind++] = 0;
					_segs[_ind++] = 0;
					_segs[_ind++] = _x;
					_segs[_ind++] = _y;
					_segs[_ind++] = 0;
					_segs[_ind++] = 0;
				}
				break;
				
			case 2 : 
				inputs[ 6].setVisible( true);
				inputs[ 7].setVisible( true);
				inputs[ 8].setVisible( true);
				
				for( var i = 0; i <= _reso; i++ ) {
					var _x = i / _reso;
					
					var _y = abs(frac(frac(_x * _freq - _phase) + 1) * 2 - 1);
					    _y = lerp(_range[0], _range[1], _y);
					
					_segs[_ind++] = 0;
					_segs[_ind++] = 0;
					_segs[_ind++] = _x;
					_segs[_ind++] = _y;
					_segs[_ind++] = 0;
					_segs[_ind++] = 0;
				}
				break;
			
			case 3 : 
				inputs[ 6].setVisible( true);
				inputs[ 7].setVisible( true);
				inputs[ 8].setVisible( true);
				
				for( var i = 0; i <= _reso; i++ ) {
					var _x = i / _reso;
					
					var _y = frac(frac(_x * _freq - _phase) + 1);
					    _y = lerp(_range[0], _range[1], _y);
					
					_segs[_ind++] = 0;
					_segs[_ind++] = 0;
					_segs[_ind++] = _x;
					_segs[_ind++] = _y;
					_segs[_ind++] = 0;
					_segs[_ind++] = 0;
				}
				break;
			
			case 4 : 
				inputs[ 9].setVisible( true);
				
				for( var i = 0; i <= _step; i++ ) {
					var _x = i / _step;
					var _y = lerp(_range[0], _range[1], clamp(i / (_step - 1), 0, 1));
					
					_segs[_ind++] = 0;
					_segs[_ind++] = 0;
					_segs[_ind++] = _x;
					_segs[_ind++] = _y;
					_segs[_ind++] = 0;
					_segs[_ind++] = 0;
				}
				break;
				
		}
	}
	
}