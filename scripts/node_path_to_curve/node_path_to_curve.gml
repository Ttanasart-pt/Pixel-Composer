function Node_Path_to_Curve(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path to Curve";
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Path
	newInput( 0, nodeValue_PathNode( "Path"           ));
	newInput( 1, nodeValue_Int(      "Resolution", 16 ));
	
	////- =Curve 
	newInput( 5, nodeValue_EScroll( "Type",         0, [ "Curve", "Step" ] ));
	newInput( 2, nodeValue_Float(  "Shift",         0    ));
	newInput( 3, nodeValue_Float(  "Scale",         1    ));
	newInput( 4, nodeValue_Range(  "Output Range", [0,1] ));
	newInput( 6, nodeValue_Range(  "Y Range",      [0,1] ));
	// input 7
	
	newOutput(0, nodeValue_Output("Curve", VALUE_TYPE.curve, CURVE_DEF_01 ));
	
	input_display_list = [ 
		[ "Path",   false ], 0, 1, 
		[ "Curve",  false ], 5, 2, 3, 4, 6, 
	];
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
	}
	
	static update = function() {
		#region data
			var _path = getInputData(0);
			var _reso = getInputData(1); 
			
			var _type = getInputData(5); 
			var _shft = getInputData(2); 
			var _scal = getInputData(3); 
			var _orng = getInputData(4); 
			var _yrng = getInputData(6); 
			
			if(!is_path(_path)) return;
		#endregion
		
		var _clen = CURVE_PADD + (_reso + 1) * 6;
		var _segs = array_verify(outputs[0].getValue(), _clen);
		outputs[0].setValue(_segs);
		
		var _bbox = _path.getBoundary();
		
		var minx = _bbox.minx;
		var miny = _bbox.miny;
		var maxx = _bbox.maxx;
		var maxy = _bbox.maxy;
		
		var width  = max(1, abs(maxx - minx));
		var height = max(1, abs(maxy - miny));
		
		_segs[0] = _shft; // x shift
		_segs[1] = _scal; // x scale
		_segs[2] = _type; // type
		_segs[3] = _orng[0]; // min y
		_segs[4] = _orng[1]; // max y
		_segs[5] = 0; // -
		
		// curve format [-cx0, -cy0, x0, y0, +cx0, +cy0, -cx1, -cy1, x1, y1, +cx1, +cy1]
		
		var _p = new __vec2P();
		for( var i = 0; i <= _reso; i++ ) {
			var _r = i / _reso;
			var sind = CURVE_PADD + i * 6;
			
			_p = _path.getPointRatio(_r, 0, _p);
			
			var _cx = (_p.x - minx) / width;
			var _cy = (_p.y - miny) / height;
			
			_segs[sind + 0] = 0;
			_segs[sind + 1] = 0;
			
			_segs[sind + 2] = _cx;
			_segs[sind + 3] = lerp(_yrng[0], _yrng[1], _cy);
			
			_segs[sind + 4] = 0;
			_segs[sind + 5] = 0;
			
		}
			
	}
	
}