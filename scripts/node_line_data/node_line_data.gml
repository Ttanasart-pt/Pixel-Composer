function Node_Line_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {	
	name = "Draw Line Data";
	
	newInput( 4, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	
	////- =Data
	newInput( 1, nodeValue_Struct( "Line Data" )).setArrayDepth(1).setVisible(true, true);
	
	////- =Adjustment
	newInput( 2, nodeValue_Float(   "Extension",    2            ));
	newInput( 3, nodeValue_RotRand( "Random Angle", ROTRAN_DEF_0 ));
	// 5
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 4, 0, 
		[ "Path Data",  false ],  1, 
		[ "Adjustment", false ],  2,  3, 
	];
	
	////- Node
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _seed   = _data[ 4];
			var _dim    = _data[ 0];
			
			var _ldata  = _data[ 1];
			
			var _extn   = _data[ 2];
			var _ranAng = _data[ 3];
		#endregion
		
		random_set_seed(_seed);
		
		var _outSurf = _outData;
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		var _ldepth = array_get_depth(_ldata);
		if(_ldepth != 1) return _outSurf;
		
		var _samo = array_length(_ldata);
		var ox, oy, nx, ny;
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			for( var i = 0; i < _samo; i++ ) {
				var p = _ldata[i];
				nx = p.x;
				ny = p.y;
				
				if(i) {
					var cx = (ox + nx) / 2;
					var cy = (oy + ny) / 2;
					
					var dir = point_direction(cx, cy, nx, ny);
					var dis = point_distance( cx, cy, nx, ny);
					
					dir += rotation_random_eval(_ranAng);
					dis *= _extn;
					
					var x0 = cx - lengthdir_x(dis, dir);
					var y0 = cy - lengthdir_y(dis, dir);
					
					var x1 = cx + lengthdir_x(dis, dir);
					var y1 = cy + lengthdir_y(dis, dir);
					
					draw_set_color(c_white);
					draw_line(x0, y0, x1, y1);
				}
				
				ox = nx;
				oy = ny;
			}
		surface_reset_target();
		
		return _outSurf;
	}

}
	