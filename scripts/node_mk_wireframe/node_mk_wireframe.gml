function Node_MK_WireFrame(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK WireFrame";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	
	////- =Path
	newInput( 1, nodeValue_PathNode( "Path"       ));
	newInput( 2, nodeValue_Int(      "Sample", 16 ));
	newInput( 7, nodeValue_Slider(   "Offset", 0  ));
	
	////- =Thickness
	newInput( 3, nodeValue_Vec2(  "Offset",  [.25,.25]     )).setUnitSimple();
	newInput( 4, nodeValue_Int(   "Step",      1           ));
	newInput(11, nodeValue_Curve( "Profile",  CURVE_DEF_11 ));
	newInput(12, nodeValue_Int(   "Sample",    2           ));
	newInput(13, nodeValue_Bool(  "Both Side", true        ));
	
	////- =Render
	newInput( 5, nodeValue_Float( "Face Thickness", 1         ));
	newInput( 6, nodeValue_Color( "Front Color",    ca_white  ));
	newInput(10, nodeValue_Color( "Back Color",     ca_white  ));
	newInput( 8, nodeValue_Float( "Side Thickness", 1         ));
	newInput( 9, nodeValue_Gradient( "Side Color",  gra_white ));
	// 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",    false ],  0,
		[ "Path",      false ],  1,  2,  7,  
		[ "Thickness", false ],  3,  4, 11, 12, 13, 
		[ "Render",    false ],  5,  6, 10,  8,  9, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _dim  = getInputSingle(0);
		var _offs = getInputSingle(3);
		
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		var _ox = _cx + _offs[0] * _s;
		var _oy = _cy + _offs[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_line_dashed(_cx, _cy, _ox, _oy);
		
		InputDrawOverlay(inputs[3].drawOverlay( w_hoverable, active, _cx, _cy, _s, _mx, _my ));
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim  = _data[ 0];
			
			var _path = _data[ 1];
			var _samp = _data[ 2];
			var _poff = _data[ 7];
			
			var _offs = _data[ 3];
			var _wstp = _data[ 4]; _wstp = max(1, _wstp);
			var _prof = _data[11];
			var _Tsam = _data[12]; _Tsam = max(2, _Tsam);
			var _both = _data[13];
			
			var _Fthk = _data[ 5];
			var _Fcol = _data[ 6];
			var _Bcol = _data[10];
			var _Tthk = _data[ 8];
			var _Tgrd = _data[ 9]; _Tgrd.cache();
			
			if(!is_path(_path) || _samp < 2) return _outSurf; 
		#endregion
		
		var _prfMap = new curveMap(_prof, _Tsam);
		var _points = array_create(_samp + 1);
		var _stp    = .999 / _samp;
		var _p      = new __vec2P();
		var _cx     = [ 0, 0 ]
		
		for( var i = 0; i < _samp; i++ ) {
			var _prg = frac(_poff + _stp * i);
			_p = _path.getPointRatio(_prg, 0, _p);
			
			_points[i] = [ _p.x, _p.y ];
			_cx[0] += _p.x;
			_cx[1] += _p.y;
		}
		
		_cx[0] /= _samp;
		_cx[1] /= _samp;
		_points[_samp] = _points[0];
		
		var ofx = _offs[0];
		var ofy = _offs[1];
		
		var bofx = _both? -ofx : 0;
		var bofy = _both? -ofy : 0;
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var op, np, ss;
			for( var i = 0; i <= _samp; i++ ) {
				ss = _prfMap.get(0);
				np = [
					_cx[0] + (_points[i][0] - _cx[0]) * ss,
					_cx[1] + (_points[i][1] - _cx[1]) * ss,
				];
				
				if(i) {
					var x00 = op[0] + bofx;
					var y00 = op[1] + bofy;
					var x01 = np[0] + bofx;
					var y01 = np[1] + bofy;
					
					draw_set_color_ext(_Bcol);
					draw_line_width(x00, y00, x01, y01, _Fthk);
				}
				
				op = np;
			}
			
			var os, ns;
			var _ts = 1 / _Tsam;
			for( var j = 0; j < _Tsam; j++ ) {
				var _t0 = (j + 0) * _ts;
				var _t1 = (j + 1) * _ts;
				
				var os = _prfMap.get(_t0);
				var ns = _prfMap.get(_t1);
				
				var _ofx0 = lerp(bofx, ofx, _t0);
				var _ofy0 = lerp(bofy, ofy, _t0);
				
				var _ofx1 = lerp(bofx, ofx, _t1);
				var _ofy1 = lerp(bofy, ofy, _t1);
				
				var oc = _Tgrd.evalFast(_t0);
				var nc = _Tgrd.evalFast(_t1);
				
				for( var i = 0; i <= _samp; i += _wstp ) {
					var pp = _points[i];
					
					var x00 = _cx[0] + (pp[0] - _cx[0]) * os + _ofx0;
					var y00 = _cx[1] + (pp[1] - _cx[1]) * os + _ofy0;
					var x10 = _cx[0] + (pp[0] - _cx[0]) * ns + _ofx1;
					var y10 = _cx[1] + (pp[1] - _cx[1]) * ns + _ofy1;
					
					draw_line_width_color(x00, y00, x10, y10, _Tthk, oc, nc);
				}
			}
			
			var op, np;
			for( var i = 0; i <= _samp; i++ ) {
				ss = _prfMap.get(1);
				np = [
					_cx[0] + (_points[i][0] - _cx[0]) * ss,
					_cx[1] + (_points[i][1] - _cx[1]) * ss,
				];
				
				if(i) {
					var x10 = op[0] + ofx, y10 = op[1] + ofy;
					var x11 = np[0] + ofx, y11 = np[1] + ofy;
					
					draw_set_color_ext(_Fcol);
					draw_line_width(x10, y10, x11, y11, _Fthk);
				}
				
				op = np;
			}
			
		surface_reset_target();
		
		return _outSurf; 
	}
}