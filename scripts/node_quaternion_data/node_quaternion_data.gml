function Node_Quaternion_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Spherical Quaternion";
	always_pad = true;
	reactive_on_hover  = true;
	setDimension(128, 128);
		
	newInput( 0, nodeValue_Rotation( "Azimuth",  0 )).setVisible(true, true);
	newInput( 1, nodeValue_Rotation( "Altitude", 0 )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Rotation", VALUE_TYPE.float, [0,0,0,1])).setDisplay(VALUE_DISPLAY.d3quarternion);
	
	input_display_list = [ 
		[ "Axes", false ], 0, 1,
	];
	
	////- Nodes
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _ax = _data[ 0];
			var _ay = _data[ 1];
		#endregion
		
		qCurr =  new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 0, -1), _ax)
			.Mul(new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, 1,  0), _ay))
		
		qView =  new BBMOD_Quaternion().FromEuler(30, 45, 0)
		    .Mul(new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0, -1, 0), _ax))
			.Mul(new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(0,  0, 1), _ay))
		
		return qCurr.ToArray(); 
	}
	
	////- Draw
	
	qCurr = new BBMOD_Quaternion(0, 0, 0, 1);
	
	qIso  = new BBMOD_Quaternion().FromEuler(30, 45, 0);
	qView = new BBMOD_Quaternion(0, 0, 0, 1);
	qDrag = undefined;
	
    mainAxis = [
        new BBMOD_Vec3( 0,  0,  1),
        new BBMOD_Vec3( 1,  0,  0),
        new BBMOD_Vec3( 0, -1,  0),
    ];
    
    prevAxis = new BBMOD_Vec3( 1,  0,  0);
    heigAxis = new BBMOD_Vec3( 0,  0,  1);
    
	rotating  = false;
	rotate_mx = undefined;
	rotate_my = undefined;
	
	rotate_sx = undefined;
	rotate_sy = undefined;
	
	__m = [0,0];
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		__m[0] = _mx;
		__m[1] = _my;
		
		var xc = draw_bbox.xc;
		var yc = draw_bbox.yc;
		var ww = draw_bbox.w - 8 * _s;
		var hh = draw_bbox.h - 8 * _s;
		
		var rr = min(ww, hh) / 2;
		
		var _hv  = rotating;
        if(point_in_circle(_mx, _my, xc, yc, rr)) {
            _hv = true;
            
            if(mouse_lpress(_focus)) {
                rotating  = true;
                rotate_mx = _mx;
				rotate_my = _my;
                rotate_sx = inputs[0].getValue();
				rotate_sy = inputs[1].getValue();
            }
        }
        
        draggable = !_hv;
		draw_circle_ui(xc, yc, rr,   0, COLORS._main_icon_dark, .5);
        
        var ar = rr * 1;
        for(var i = 0; i < 3; i++) {
            var a = qIso.Rotate(mainAxis[i]);
            
            draw_set_color(COLORS.axis[i]);
            draw_line_dashed(xc, yc, xc + a.X * ar, yc + a.Y * ar, 1 * _s, 4 * _s);
        }
        
        var a = qView.Rotate(prevAxis);
        var tx = xc + a.X * rr * .75;
        var ty = yc + a.Y * rr * .75;
        
        draw_set_color(COLORS._main_icon);
        draw_line_round(xc, yc, tx, ty, 2 * _s);
		draw_circle_ui(tx, ty, 6 * _s, 0, COLORS._main_icon_dark);
		draw_circle_ui(tx, ty, 4 * _s, 0, COLORS._main_icon);
        
		draw_circle_ui(xc, yc, rr, .02, COLORS._main_icon_dark);
		draw_circle_ui(xc, yc, rr, .02, COLORS._main_icon, .5 + _hv * .3);
		
        if(rotating) {
        	draggable = false;
        	var dx = (_mx - rotate_mx) / rr * 90;
        	var dy = (_my - rotate_my) / rr * 90;
        	
        	var ed0 = inputs[0].setValue(rotate_sx + dx);
        	var ed1 = inputs[1].setValue(rotate_sy - dy);

			if(ed0 || ed1) UNDO_HOLDING = true;
        	
        	if(mouse_lrelease()) {
        		UNDO_HOLDING = false;
        		rotating     = false;
        	}
        }
	}
}