function Node_Scatter_Point_Fibonacci(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Fibonacci Points";
	color = COLORS.node_blend_number;
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Base
	newInput(0, nodeValueSeed()).rejectArray();
	
	////- =Points
	newInput( 2, nodeValue_Int(      "Amount",     16    ));
	newInput( 1, nodeValue_Vec2(     "Center",   [.5,.5] )).setHotkey("G").setUnitSimple();
	newInput( 6, nodeValue_Rotation( "Rotation",   0     )).setHotkey("R");
	newInput( 3, nodeValue_Vec2(     "Scale",     [1,1]  )).setHotkey("S");
	
	////- =Fibonacci
	newInput( 4, nodeValue_Float( "Rotation", (1 + sqrt(5)) / 2 ));
	newInput( 5, nodeValue_Float( "Step",     1 ));
	// inputs 7
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, [ 0, 0 ])).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		[ "Points",    false ], 2, 1, 6, 3, 
		[ "Fibonacci", false ], 4, 5, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed = _data[ 0];
			
			var _amo  = _data[ 2];
			var _cen  = _data[ 1];
			var _rot  = _data[ 6];
			var _sca  = _data[ 3];
			
			var _rota = _data[ 4];
			var _step = _data[ 5];
		#endregion
		
		random_set_seed(_seed);
		
		_outData = array_verify(_outData, _amo);
		
		var cx = _cen[0];
		var cy = _cen[1];
		
		var ww = _sca[0];
		var hh = _sca[1];
		
		var _dir = _rot;
		var _len = 0;
		var _rev = _rota * 360;
		
		for( var i = 0; i < _amo; i++ ) {
			var _x = cx + lengthdir_x(_len, _dir) * ww;
			var _y = cy + lengthdir_y(_len, _dir) * hh;
			
			_dir += _rev;
			_len += _step;
			
			_outData[i] = [ _x, _y ];
		}
		
		return _outData;
	}
	
}