function Node_Quaternion_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Quaternion";
	always_pad = true;
	reactive_on_hover  = true;
	setDimension(128, 128);
		
	newInput(0, nodeValue_Vec3("Euler Rotation", [0,0,0] )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Rotation", VALUE_TYPE.float, [0,0,0,1])).setDisplay(VALUE_DISPLAY.d3quarternion);
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _eul = _data[0];
		#endregion
		
		var _quar = quarternionFromEulerArray(_eul);
		
		return _quar; 
	}
	
	////- Draw
	
	rotating  = false;
	rotate_sv = undefined;
	rotate_mx = undefined;
	rotate_my = undefined;
	
	__m = [0,0];
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		__m[0] = _mx;
		__m[1] = _my;
		
		var _ein   = inputs[0].getValue();
		var _qout  = outputs[0].getValue();
		
		var xc = draw_bbox.xc;
		var yc = draw_bbox.yc;
		var ww = draw_bbox.w - 8 * _s;
		var hh = draw_bbox.h - 8 * _s;
		
		var rr = min(ww, hh) / 2;
		
		var _hv  = rotating;
        if(_hover && point_in_circle(_mx, _my, xc, yc, rr)) {
            _hv = true;
            
            if(mouse_lpress(_focus)) {
                rotating  = true;
                rotate_sv = array_clone(_ein);
				rotate_mx = _mx;
				rotate_my = _my;
            }
        }
        
        draggable = !_hv;
        
		draw_circle_ui(xc, yc, rr,   0, COLORS._main_icon_dark, .5);
		draw_circle_ui(xc, yc, rr, .02, COLORS._main_icon,      .5 + _hv * .3);
		
    	var _qview = new BBMOD_Quaternion(_qout[0], _qout[1], _qout[2], _qout[3]);
        var _as = [
            new BBMOD_Vec3(-1, 0, 0),
            new BBMOD_Vec3(0,  0, 1),
            new BBMOD_Vec3(0, -1, 0),
        ];
        
        for(var i = 0; i < 3; i++) {
            _as[i] = _qview.Rotate(_as[i]);
            
            draw_set_color(COLORS.axis[i]);
            draw_line_round(xc, yc, xc + _as[i].X * (rr * .75), yc + _as[i].Y * (rr * .75), 2 * _s);
        }
        
        if(rotating) {
        	var dx = (_mx - rotate_mx) / rr * 180;
        	var dy = (_my - rotate_my) / rr * 180;
        	
        	var rx = rotate_sv[0];
        	var ry = rotate_sv[1] + dx;
        	var rz = rotate_sv[2] + dy;
        	
        	if(inputs[0].setValue([rx, ry, rz]))
        		UNDO_HOLDING = true;
        	
        	if(mouse_lrelease()) {
        		UNDO_HOLDING = false;
        		rotating     = false;
        	}
        }
	}
}