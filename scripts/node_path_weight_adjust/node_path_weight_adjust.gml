function Node_Path_Weight_Adjust(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Weight Adjust";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Path
	newInput( 0, nodeValue_Path( "Path"        ));
	newInput( 7, nodeValue_Bool( "Loop", false ));
	
	////- =Adjustment
	newInput( 1, nodeValue_EScroll( "Apply Mode",   0, [ "Additive", "Multiplicative", "Override" ] ));
	
	newInput( 4, nodeValue_EScroll( "Value Type",  0, [ "Constant", "Curve", "Direction", "Curvature" ] ));
	newInput( 2, nodeValue_Float(   "Value",           0            ));
	newInput( 6, nodeValue_Rot(     "Direction Shift", 0            ));
	newInput( 5, nodeValue_Vec2(    "Value Range",    [0,1]         ));
	newInput( 3, nodeValue_Curve(   "Curve",           CURVE_DEF_01 ));
	
	////- =Algorithm
	newInput( 8, nodeValue_Float(   "Span", .01 ));
	// 9
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 
		[ "Path",       false ],  0,  7, 
	    [ "Adjustment", false ],  1, -2,  4,  2,  6,  5,  3, 
		[ "Algorithm",  false ],  8, 
    ];
    
    ////- Node
	
	#region path
		curr_path  = noone;
		curr_loop  = false;
		
		curr_type  = 0;
		curr_mode  = 0;
		
		curr_value  = 0;
		curr_dirr   = 0;
		curr_curve  = noone;
		curr_val_st = 0;
		curr_val_ed = 1;
		
		curr_t      = 1;
		
		temp_p = new PathPoint();
		
		static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
			if(has(curr_path, "drawOverlay")) drawOverlayInput(curr_path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
			return w_hovering;
		}
		
		static getLineCount    = function(       ) /*=>*/ {return is_path(curr_path)? curr_path.getLineCount()       : 1};
		static getSegmentCount = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getSegmentCount(ind) : 0};
		static getLength       = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getLength(ind)       : 0};
		static getAccuLength   = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getAccuLength(ind)   : []};
		static getBoundary     = function(ind = 0) /*=>*/ {return is_path(curr_path)? curr_path.getBoundary(ind)     : new BoundingBox( 0, 0, 1, 1 )};
		
		static getPointRatio = function(_rat, ind = 0, out = undefined) {
			if(!is(out, PathPoint)) out = new PathPoint(); else out.reset();
			if(!is_path(curr_path)) return out;
			
			temp_p = curr_path.getPointRatio(_rat, ind, temp_p);
			out.apply(temp_p);
			
			var _v = curr_value;
			var  t = curr_t;
			
			switch(curr_type) {
				case 0 : _v = curr_value; break;
				case 1 : _v = lerp(curr_val_st, curr_val_ed, curr_curve.get(_rat)); break;
				
				case 2 : // direction
					if(curr_loop) temp_p = curr_path.getPointRatio(pfract(_rat - t), ind, temp_p);
					else          temp_p = curr_path.getPointRatio(clamp(_rat - t, 0, 1-t), ind, temp_p);
					var x0 = temp_p.x;
					var y0 = temp_p.y;
					
					if(curr_loop) temp_p = curr_path.getPointRatio(pfract(_rat + t), ind, temp_p);
					else          temp_p = curr_path.getPointRatio(clamp(_rat + t, 0, 1-t), ind, temp_p);
					var x1 = temp_p.x;
					var y1 = temp_p.y;
					
					var _dir = point_direction(x0, y0, x1, y1) - curr_dirr;
					    _dir = (_dir % 360 + 360) % 360;
					
					_v = lerp(curr_val_st, curr_val_ed, curr_curve.get(_dir / 360));
					break;
					
				case 3 : // curvature
					if(curr_loop) temp_p = curr_path.getPointRatio(pfract(_rat - t), ind, temp_p);
					else          temp_p = curr_path.getPointRatio(clamp(_rat - t, 0, 1-t), ind, temp_p);
					var x0 = temp_p.x;
					var y0 = temp_p.y;
					
					temp_p = curr_path.getPointRatio(_rat, ind, temp_p);
					var x1 = temp_p.x;
					var y1 = temp_p.y;
					
					if(curr_loop) temp_p = curr_path.getPointRatio(pfract(_rat + t), ind, temp_p);
					else          temp_p = curr_path.getPointRatio(clamp(_rat + t, 0, 1-t), ind, temp_p);
					var x2 = temp_p.x;
					var y2 = temp_p.y;

					var dx0 = (x1 - x0) / t;
					var dy0 = (y1 - y0) / t;

					var dx1 = (x2 - x1) / t;
					var dy1 = (y2 - y1) / t;

					var ddx = (dx1 - dx0) / t;
					var ddy = (dy1 - dy0) / t;

					var crv = abs(dx0 * ddy - dy0 * ddx) / power(dx0 * dx0 + dy0 * dy0, 1.5);
					
					_v = lerp(curr_val_st, curr_val_ed, curr_curve.get(crv));
					break;
			}
			
			switch(curr_mode) {
			    case 0 : out.w = max(0, temp_p.w + _v); break;
			    case 1 : out.w = temp_p.w * _v;         break;
			    case 2 : out.w = _v;                    break;
			}
			
			return out;
		}
		
		static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	#endregion
		
	static update = function() {
		#region data
			curr_path  = getInputData( 0);
			curr_loop  = getInputData( 7);
			
			curr_mode  = getInputData( 1);
			
		    curr_type  = getInputData( 4);
		    curr_value = getInputData( 2);
		    curr_dirr  = getInputData( 6);
		    var _curvr = getInputData( 5);
		    var _curve = getInputData( 3);
		    
		    curr_t     = getInputData( 8);
		    
			inputs[ 2].setVisible(curr_type == 0);
			inputs[ 6].setVisible(curr_type == 2);
			inputs[ 5].setVisible(curr_type != 0);
			inputs[ 3].setVisible(curr_type != 0);
	    #endregion
	    
	    curr_curve  = new curveMap(_curve, 128);
	    curr_val_st = _curvr[0];
	    curr_val_ed = _curvr[1];
		
		outputs[0].setValue(self);
	}
	
}