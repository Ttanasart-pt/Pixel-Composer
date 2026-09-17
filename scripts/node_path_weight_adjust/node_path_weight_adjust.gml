function Node_Path_Weight_Adjust(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Weight Adjust";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Path
	newInput( 0, nodeValue_Path( "Path"        ));
	newInput( 7, nodeValue_Bool( "Loop", false ));
	
	////- =Adjustment
	newInput( 4, nodeValue_EScroll( "Adjust Type",  0, [ "Constant", "Curve", "Direction" ] ));
	newInput( 1, nodeValue_EScroll( "Apply Mode",   0, [ "Additive", "Multiplicative", "Override" ] ));
	
	newInput( 2, nodeValue_Float(   "Value", 0            ));
	newInput( 3, nodeValue_Curve(   "Curve", CURVE_DEF_11 ));
	newInput( 6, nodeValue_Rotation( "Direction Shift", 0 ));
	newInput( 5, nodeValue_Vec2(    "Value Range", [0,1]  ));
	// 8
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 
		[ "Path",       false ],  0,  7, 
	    [ "Adjustment", false ],  4,  1, -1,  2,  3,  6,  5, 
    ];
    
    ////- Node
	
	curr_path  = noone;
	curr_loop  = false;
	
	curr_type  = 0;
	curr_mode  = 0;
	
	curr_value  = 0;
	curr_dirr   = 0;
	curr_curve  = noone;
	curr_val_st = 0;
	curr_val_ed = 1;
	
	temp_p = new __vec2P();
	
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
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		if(!is_path(curr_path)) return out;
		
		temp_p = curr_path.getPointRatio(_rat, ind, temp_p);
		out.x  = temp_p.x;
		out.y  = temp_p.y;
		
		var _v = curr_value;
		
		switch(curr_type) {
			case 0 : _v = curr_value; break;
			case 1 : _v = lerp(curr_val_st, curr_val_ed, curr_curve.get(_rat)); break;
			case 2 : 
				if(curr_loop) temp_p = curr_path.getPointRatio(pfract(_rat - .001), ind, temp_p);
				else          temp_p = curr_path.getPointRatio(clamp(_rat - .001, 0, .999), ind, temp_p);
				var x0 = temp_p.x;
				var y0 = temp_p.y;
				
				if(curr_loop) temp_p = curr_path.getPointRatio(pfract(_rat + .001), ind, temp_p);
				else          temp_p = curr_path.getPointRatio(clamp(_rat + .001, 0, .999), ind, temp_p);
				var x1 = temp_p.x;
				var y1 = temp_p.y;
				
				var _dir = angle_difference(point_direction(x0, y0, x1, y1), curr_dirr);
				_v = lerp(curr_val_st, curr_val_ed, abs(_dir) / 180);
				break;
		}
		
		switch(curr_mode) {
		    case 0 : out.weight = max(0, temp_p.weight + _v); break;
		    case 1 : out.weight = temp_p.weight * _v;         break;
		    case 2 : out.weight = _v;                         break;
		}
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(), ind, out); }
	
	static update = function() {
		curr_path  = getInputData( 0);
		curr_loop  = getInputData( 7);
		
	    curr_type  = getInputData( 4);
		curr_mode  = getInputData( 1);
		
		inputs[ 2].setVisible(curr_type == 0);
		inputs[ 3].setVisible(curr_type == 1);
		inputs[ 6].setVisible(curr_type == 2);
		inputs[ 5].setVisible(curr_type != 0);
		
	    curr_value = getInputData( 2);
	    curr_dirr  = getInputData( 6);
	    
	    var _curve = getInputData( 3);
	    var _curvr = getInputData( 5);
	    
	    curr_curve  = new curveMap(_curve, TOTAL_FRAMES);
	    curr_val_st = _curvr[0];
	    curr_val_ed = _curvr[1];
		
		outputs[0].setValue(self);
	}
	
}