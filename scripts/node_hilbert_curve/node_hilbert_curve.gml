function Node_Hilbert(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Hilbert";
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Hilbert
	newInput( 1, nodeValue_Int(     "Iteration",   2 ));
	newInput( 2, nodeValue_EButton( "Orientation", 1, [ "L", "T", "R", "B" ] ));
	
	////- =Rendering
	newInput( 5, nodeValue_Float(    "Thickness",  2               ));
	newInput( 3, nodeValue_Color(    "BG Color",   ca_black        ));
	newInput( 4, nodeValue_Gradient( "Path Color", gra_white       ));
	newInput( 6, nodeValue_Slider(   "Path Shift", 0, [-1, 1, .01] ));
	// 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  0,
		[ "Hilbert",   false ],  1,  2, 
		[ "Rendering", false ],  5,  3,  4,  6, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static hilbertIterate = function(xc, yc, xh, yh, ori, flip = false) {
		var p00 = [ xc - xh, yc - xh ];
		var p01 = [ xc - xh, yc + xh ];
		var p10 = [ xc + xh, yc - xh ];
		var p11 = [ xc + xh, yc + xh ];
		
		switch(ori) {
			case 0 : return [ p01, p11, p10, p00, ori, flip ];
			case 1 : return [ p01, p00, p10, p11, ori, flip ];
			case 2 : return [ p10, p00, p01, p11, ori, flip ];
			case 3 : return [ p10, p11, p01, p00, ori, flip ];
		}
		
		return undefined;
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim = _data[ 0];
			
			var _itr = _data[ 1];
			var _ori = _data[ 2];
			
			var _thk = _data[ 5];
			var _bgc = _data[ 3];
			var _pcl = _data[ 4]; _pcl.cache();
			var _psh = _data[ 6];
		#endregion
		
		var sw = _dim[0] / 4;
		var sh = _dim[1] / 4;
		
		var _points = hilbertIterate(_dim[0]/2, _dim[1]/2, sw, sh, _ori, !(_ori % 2));
		
		repeat(_itr - 1) {
			sw /= 2;
			sh /= 2;
			
			var len = array_length(_points);
			var npt = array_create(len * 4);
			var ind = 0;
			
			for (var i = 0; i < len; i += 6) {
				var _ori = _points[i + 4];
				var _fli = _points[i + 5];
				
				var _p = _points[i + 0];
				var _h = hilbertIterate(_p[0], _p[1], sw, sh, (_ori + 3 - _fli * 2) % 4);
				npt[ind++] = _h[0];
				npt[ind++] = _h[1];
				npt[ind++] = _h[2];
				npt[ind++] = _h[3];
				npt[ind++] = _h[4];
				npt[ind++] = !_fli;
				
				var _p = _points[i + 1];
				var _h = hilbertIterate(_p[0], _p[1], sw, sh, _ori);
				npt[ind++] = _h[0];
				npt[ind++] = _h[1];
				npt[ind++] = _h[2];
				npt[ind++] = _h[3];
				npt[ind++] = _h[4];
				npt[ind++] = _fli;
				
				var _p = _points[i + 2];
				var _h = hilbertIterate(_p[0], _p[1], sw, sh, _ori);
				npt[ind++] = _h[0];
				npt[ind++] = _h[1];
				npt[ind++] = _h[2];
				npt[ind++] = _h[3];
				npt[ind++] = _h[4];
				npt[ind++] = _fli;
				
				var _p = _points[i + 3];
				var _h = hilbertIterate(_p[0], _p[1], sw, sh, (_ori + 1 + _fli * 2) % 4);
				npt[ind++] = _h[0];
				npt[ind++] = _h[1];
				npt[ind++] = _h[2];
				npt[ind++] = _h[3];
				npt[ind++] = _h[4];
				npt[ind++] = !_fli;
				
				
			}
			
			_points = npt;
		}
		
		
		surface_set_target(_outSurf);
			draw_clear_alpha(_bgc, color_get_alpha(_bgc));
			
			var ox = _points[0][0], oy = _points[0][1];
			var nx, ny;
			var _plen = array_length(_points) / 6 * 4;
			var _pind = 0;
			
			draw_set_color(c_white);
			for( var i = 0, n = array_length(_points); i < n; i += 6 ) {
				draw_set_color(_pcl.evalFast(frac(frac(_pind/_plen+_psh)+1))); _pind++;
				nx = _points[i+0][0]; ny = _points[i+0][1];
				draw_line_width(ox, oy, nx, ny, _thk);
				ox = nx; oy = ny;
				
				draw_set_color(_pcl.evalFast(frac(frac(_pind/_plen+_psh)+1))); _pind++;
				nx = _points[i+1][0]; ny = _points[i+1][1];
				draw_line_width(ox, oy, nx, ny, _thk);
				ox = nx; oy = ny;
				
				draw_set_color(_pcl.evalFast(frac(frac(_pind/_plen+_psh)+1))); _pind++;
				nx = _points[i+2][0]; ny = _points[i+2][1];
				draw_line_width(ox, oy, nx, ny, _thk);
				ox = nx; oy = ny;
				
				draw_set_color(_pcl.evalFast(frac(frac(_pind/_plen+_psh)+1))); _pind++;
				nx = _points[i+3][0]; ny = _points[i+3][1];
				draw_line_width(ox, oy, nx, ny, _thk);
				ox = nx; oy = ny;
			}
		surface_reset_target();
		
		return _outSurf; 
	}
}